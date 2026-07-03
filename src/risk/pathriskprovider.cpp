#include "pathriskprovider.h"
#include "../ai/airiskprovider.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFileInfo>
#include <QTimer>

PathRiskProvider::PathRiskProvider(QObject *parent)
    : QObject(parent)
    , m_aiProvider(new AIRiskProvider(this))
{
    loadLocalConfig();
    connect(m_aiProvider, &AIRiskProvider::riskInfoReady, this, &PathRiskProvider::onAIRiskInfoReady);
    connect(m_aiProvider, &AIRiskProvider::configChanged, this, &PathRiskProvider::onAIConfigChanged);

    m_apiUrl = m_aiProvider->apiUrl();
    m_apiKey = m_aiProvider->apiKey();
    m_model = m_aiProvider->model();
    m_engine = m_aiProvider->engine();
}

PathRiskProvider::~PathRiskProvider()
{
}

bool PathRiskProvider::aiConfigured() const
{
    return m_aiProvider && m_aiProvider->isConfigured();
}

bool PathRiskProvider::aiEnabled() const
{
    return m_aiProvider && m_aiProvider->isEnabled();
}

void PathRiskProvider::setAIEnabled(bool enabled)
{
    if (m_aiProvider) {
        m_aiProvider->setEnabled(enabled);
    }
}

QString PathRiskProvider::apiUrl() const
{
    return m_apiUrl;
}

QString PathRiskProvider::apiKey() const
{
    return m_apiKey;
}

QString PathRiskProvider::model() const
{
    return m_model;
}

QString PathRiskProvider::engine() const
{
    return m_engine;
}

void PathRiskProvider::setApiUrl(const QString &url)
{
    if (m_apiUrl != url) {
        m_apiUrl = url;
        emit configChanged();
    }
}

void PathRiskProvider::setApiKey(const QString &key)
{
    if (m_apiKey != key) {
        m_apiKey = key;
        emit configChanged();
    }
}

void PathRiskProvider::setModel(const QString &model)
{
    if (m_model != model) {
        m_model = model;
        emit configChanged();
    }
}

void PathRiskProvider::setEngine(const QString &engine)
{
    if (m_engine != engine) {
        m_engine = engine;
        emit configChanged();
    }
}

void PathRiskProvider::applyConfig()
{
    if (m_aiProvider) {
        m_aiProvider->setApiConfig(m_apiUrl, m_apiKey, m_model, m_engine);
    }
}

void PathRiskProvider::saveConfig()
{
    applyConfig();
    if (m_aiProvider) {
        m_aiProvider->saveConfig();
    }
    emit aiConfigChanged();
}

void PathRiskProvider::clearCache()
{
    m_cache.clear();
    m_pendingPaths.clear();
    if (m_aiProvider) {
        m_aiProvider->clearCache();
    }
}

void PathRiskProvider::resetConfig()
{
    m_apiUrl = "https://ark.cn-beijing.volces.com/api/v3/chat/completions";
    m_apiKey = "";
    m_model = "";
    m_engine = "volcengine";
    applyConfig();
    emit configChanged();
    emit aiConfigChanged();
}

void PathRiskProvider::onAIConfigChanged()
{
    bool oldConfigured = aiConfigured();
    m_apiUrl = m_aiProvider->apiUrl();
    m_apiKey = m_aiProvider->apiKey();
    m_model = m_aiProvider->model();
    m_engine = m_aiProvider->engine();
    emit aiEnabledChanged();
    emit configChanged();
    if (oldConfigured != aiConfigured()) {
        emit aiConfigChanged();
    }
}

QVariantMap PathRiskProvider::getDefaultRiskInfo() const
{
    QVariantMap info;
    info["level"] = "safe";
    info["label"] = "安全";
    info["color"] = "#107C10";
    info["description"] = "";
    info["levelNum"] = 0;
    return info;
}

QString PathRiskProvider::normalizePathKey(const QString &path) const
{
    QString p = QDir::cleanPath(path);
    p = QDir::toNativeSeparators(p);
    if (p.length() == 2 && p[1] == ':') {
        p += "\\";
    }
    return p.toLower();
}

void PathRiskProvider::loadLocalConfig()
{
    m_riskRules.clear();
    m_riskLevels.clear();

    m_defaultRiskInfo = getDefaultRiskInfo();

    QStringList searchPaths = {
        ":/resources/system_paths.json",
        ":/system_paths.json",
        QCoreApplication::applicationDirPath() + "/resources/system_paths.json",
        QCoreApplication::applicationDirPath() + "/system_paths.json",
        QDir::currentPath() + "/resources/system_paths.json",
        QDir::currentPath() + "/system_paths.json"
    };

    QFile jsonFile;
    QString openedPath;
    for (const QString &p : searchPaths) {
        jsonFile.setFileName(p);
        if (jsonFile.exists()) {
            if (jsonFile.open(QIODevice::ReadOnly)) {
                openedPath = p;
                break;
            }
        }
    }

    if (!jsonFile.isOpen()) {
        qWarning() << "[PathRisk] Failed to open system_paths.json";
        return;
    }

    QByteArray data = jsonFile.readAll();
    jsonFile.close();

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(data, &err);
    if (err.error != QJsonParseError::NoError || !doc.isObject()) {
        qWarning() << "[PathRisk] JSON parse error:" << err.errorString();
        return;
    }

    QJsonObject root = doc.object();

    QJsonObject levels = root.value("riskLevels").toObject();
    for (auto it = levels.begin(); it != levels.end(); ++it) {
        QJsonObject lv = it.value().toObject();
        QVariantMap info;
        info["label"] = lv.value("label").toString();
        info["color"] = lv.value("color").toString();
        info["description"] = lv.value("description").toString();
        info["level"] = it.key();
        info["levelNum"] = lv.value("level").toInt();
        m_riskLevels[it.key()] = info;
    }

    QJsonArray paths = root.value("paths").toArray();
    int priority = 0;
    for (const QJsonValue &v : paths) {
        QJsonObject obj = v.toObject();
        PathRiskRule rule;
        rule.pattern = obj.value("path").toString();
        rule.displayName = obj.value("name").toString();
        rule.level = obj.value("level").toString();
        rule.description = obj.value("description").toString();
        rule.matchChildren = obj.value("matchChildren").toBool(false);
        rule.isWildcard = obj.value("isWildcard").toBool(false);
        rule.sortPriority = priority++;
        m_riskRules.append(rule);
    }
}

QString PathRiskProvider::getRelativePathFromRoot(const QString &fullPath)
{
    QString cleaned = QDir::cleanPath(QDir::fromNativeSeparators(fullPath));
    if (cleaned.length() >= 2 && cleaned[1] == ':') {
        if (cleaned.length() == 2) {
            return QString();
        }
        cleaned = cleaned.mid(3);
    }
    return cleaned;
}

QVariantMap PathRiskProvider::queryLocalRisk(const QString &fullPath)
{
    QString relPath = getRelativePathFromRoot(fullPath);
    if (relPath.isEmpty()) {
        QVariantMap root;
        root["level"] = "danger";
        root["label"] = "危险";
        root["color"] = "#E81123";
        root["displayName"] = "磁盘根目录";
        root["description"] = "磁盘根目录，删除其中的系统文件夹将导致严重问题。请仔细确认后再操作！";
        root["levelNum"] = 3;
        return root;
    }

    QString normalizedRel = QDir::fromNativeSeparators(relPath);
    QStringList pathParts = normalizedRel.split('/', Qt::SkipEmptyParts);

    const PathRiskRule *bestMatch = nullptr;
    int bestMatchDepth = -1;
    bool bestMatchIsChildren = false;

    for (const PathRiskRule &rule : m_riskRules) {
        QString pattern = rule.pattern;
        pattern.replace('\\', '/');
        QStringList patternParts = pattern.split('/', Qt::SkipEmptyParts);

        bool matches = false;
        bool isChildMatch = false;
        int matchDepth = patternParts.size();

        if (rule.isWildcard && patternParts.contains("*")) {
            int wildcardIdx = patternParts.indexOf("*");
            if (wildcardIdx == 0) {
                continue;
            }
            if (pathParts.size() < patternParts.size()) continue;
            bool ok = true;
            for (int i = 0; i < wildcardIdx; i++) {
                if (i >= pathParts.size() || patternParts[i].compare(pathParts[i], Qt::CaseInsensitive) != 0) {
                    ok = false; break;
                }
            }
            if (!ok) continue;
            int afterWild = wildcardIdx + 1;
            for (int i = afterWild; i < patternParts.size(); i++) {
                int pathIdx = pathParts.size() - (patternParts.size() - i);
                if (pathIdx <= wildcardIdx || patternParts[i].compare(pathParts[pathIdx], Qt::CaseInsensitive) != 0) {
                    ok = false; break;
                }
            }
            if (ok) {
                matches = true;
                isChildMatch = (pathParts.size() > patternParts.size()) && rule.matchChildren;
                if (pathParts.size() == patternParts.size()) isChildMatch = false;
            }
        } else {
            if (pathParts.size() == patternParts.size()) {
                bool eq = true;
                for (int i = 0; i < patternParts.size(); i++) {
                    if (patternParts[i].compare(pathParts[i], Qt::CaseInsensitive) != 0) {
                        eq = false; break;
                    }
                }
                if (eq) matches = true;
            } else if (rule.matchChildren && pathParts.size() > patternParts.size()) {
                bool eq = true;
                for (int i = 0; i < patternParts.size(); i++) {
                    if (patternParts[i].compare(pathParts[i], Qt::CaseInsensitive) != 0) {
                        eq = false; break;
                    }
                }
                if (eq) { matches = true; isChildMatch = true; }
            }
        }

        if (matches) {
            if (!bestMatch || matchDepth > bestMatchDepth ||
                (matchDepth == bestMatchDepth && rule.sortPriority > bestMatch->sortPriority && !bestMatchIsChildren)) {
                bestMatch = &rule;
                bestMatchDepth = matchDepth;
                bestMatchIsChildren = isChildMatch;
            }
        }
    }
    if (!bestMatch) {
        return m_defaultRiskInfo;
    }

    QVariantMap result;
    result["level"] = bestMatch->level;
    result["displayName"] = bestMatch->displayName;
    if (bestMatchIsChildren) {
        result["description"] = QString("[%1内的文件/子目录] %2").arg(bestMatch->displayName, bestMatch->description);
    } else {
        result["description"] = bestMatch->description;
    }
    if (m_riskLevels.contains(bestMatch->level)) {
        QVariantMap lv = m_riskLevels[bestMatch->level];
        result["label"] = lv["label"];
        result["color"] = lv["color"];
        result["levelNum"] = lv["levelNum"];
    } else {
        result["label"] = bestMatch->level;
        result["color"] = "#107C10";
        result["levelNum"] = 0;
    }

    return result;
}

QVariantMap PathRiskProvider::getRiskInfo(const QString &fullPath)
{
    QString key = normalizePathKey(fullPath);
    if (m_cache.contains(key)) {
        return m_cache.value(key);
    }
    return queryLocalRisk(fullPath);
}

bool PathRiskProvider::isRequestPending(const QString &fullPath)
{
    return m_pendingPaths.contains(normalizePathKey(fullPath));
}

void PathRiskProvider::requestRiskInfo(const QString &fullPath)
{
    QString key = normalizePathKey(fullPath);

    if (m_cache.contains(key)) {
        QTimer::singleShot(0, this, [this, fullPath, key]() {
            emit riskInfoReady(fullPath, m_cache.value(key));
        });
        return;
    }

    if (m_pendingPaths.contains(key)) {
        return;
    }

    if (m_aiProvider && m_aiProvider->isConfigured() && m_aiProvider->isEnabled()) {
        m_pendingPaths.insert(key);
        emit riskInfoLoading(fullPath);
        m_aiProvider->queryPathRisk(fullPath);
    } else {
        QVariantMap localInfo = queryLocalRisk(fullPath);
        m_cache.insert(key, localInfo);
        QTimer::singleShot(0, this, [this, fullPath, localInfo]() {
            emit riskInfoReady(fullPath, localInfo);
        });
    }
}

bool PathRiskProvider::hasCachedResult(const QString &fullPath)
{
    return m_cache.contains(normalizePathKey(fullPath));
}

QVariantMap PathRiskProvider::getCachedResult(const QString &fullPath)
{
    return m_cache.value(normalizePathKey(fullPath));
}

void PathRiskProvider::onAIRiskInfoReady(const QString &fullPath, const QVariantMap &info)
{
    QString key = normalizePathKey(fullPath);
    m_pendingPaths.remove(key);

    QVariantMap finalInfo;
    if (info.contains("description") && !info["description"].toString().isEmpty()) {
        finalInfo = info;
    } else {
        finalInfo = queryLocalRisk(fullPath);
    }
    m_cache.insert(key, finalInfo);
    emit riskInfoReady(fullPath, finalInfo);
}
