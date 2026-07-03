#include "airiskprovider.h"

#include <QCoreApplication>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkRequest>
#include <QTimer>
#include <QDir>
#include <QStandardPaths>

AIRiskProvider::AIRiskProvider(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_configured(false)
    , m_enabled(true)
    , m_timeoutMs(15000)
{
    m_engine = "volcengine";
    loadConfig();
}

AIRiskProvider::~AIRiskProvider()
{
    for (auto it = m_replyToPath.begin(); it != m_replyToPath.end(); ++it) {
        QNetworkReply *reply = it.key();
        reply->abort();
        reply->deleteLater();
    }
    m_replyToPath.clear();
}

QString AIRiskProvider::getConfigFilePath() const
{
    QString configDir = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
    if (configDir.isEmpty()) {
        configDir = QCoreApplication::applicationDirPath();
    }
    return configDir + "/ai_config.json";
}

void AIRiskProvider::loadConfig()
{
    m_configured = false;

    QString configPath = getConfigFilePath();

    QStringList searchPaths = {
        configPath,
        QCoreApplication::applicationDirPath() + "/resources/ai_config.json",
        QCoreApplication::applicationDirPath() + "/ai_config.json",
        QDir::currentPath() + "/resources/ai_config.json",
        QDir::currentPath() + "/ai_config.json",
        ":/resources/ai_config.json",
        ":/ai_config.json"
    };

    QFile jsonFile;
    for (const QString &p : searchPaths) {
        jsonFile.setFileName(p);
        if (jsonFile.exists() && jsonFile.open(QIODevice::ReadOnly)) {
            break;
        }
    }

    if (!jsonFile.isOpen()) return;

    QByteArray data = jsonFile.readAll();
    jsonFile.close();

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(data, &err);
    if (err.error != QJsonParseError::NoError || !doc.isObject()) return;

    QJsonObject root = doc.object();
    m_apiUrl = root.value("apiUrl").toString();
    m_apiKey = root.value("apiKey").toString();
    m_model = root.value("model").toString();
    m_engine = root.value("engine").toString("volcengine");
    m_systemPrompt = root.value("systemPrompt").toString();
    m_timeoutMs = root.value("timeoutMs").toInt(15000);
    m_enabled = root.value("enabled").toBool(true);

    if (m_apiUrl.isEmpty() || m_apiKey.isEmpty() || m_model.isEmpty()) {
        m_configured = false;
        return;
    }

    if (m_systemPrompt.isEmpty()) {
        m_systemPrompt = "极简说明文件或文件夹的作用，以及删除该文件/文件夹的危险级别(danger/warning/caution/safe)，返回严格的JSON格式，不要有其他文字说明。level只能填以下四个值之一：danger（系统核心，删除导致系统崩溃）、warning（重要软件/数据，删除导致软件异常）、caution（临时/缓存文件，可以删除但需注意）、safe（用户文件，可以安全删除）。返回格式：{\"level\":\"\",\"description\":\"\"}";
    }

    if (m_engine.isEmpty()) {
        m_engine = "volcengine";
    }

    m_configured = true;
}

void AIRiskProvider::setEnabled(bool enabled)
{
    if (m_enabled != enabled) {
        m_enabled = enabled;
        emit configChanged();
    }
}

void AIRiskProvider::setApiConfig(const QString &url, const QString &key, const QString &model, const QString &engine)
{
    bool changed = false;
    if (m_apiUrl != url) { m_apiUrl = url; changed = true; }
    if (m_apiKey != key) { m_apiKey = key; changed = true; }
    if (m_model != model) { m_model = model; changed = true; }
    if (m_engine != engine) { m_engine = engine; changed = true; }

    bool wasConfigured = m_configured;
    m_configured = !m_apiUrl.isEmpty() && !m_apiKey.isEmpty() && !m_model.isEmpty();

    if (changed || wasConfigured != m_configured) {
        emit configChanged();
    }
}

void AIRiskProvider::saveConfig()
{
    QString configPath = getConfigFilePath();
    QDir().mkpath(QFileInfo(configPath).path());

    QJsonObject root;
    root["apiUrl"] = m_apiUrl;
    root["apiKey"] = m_apiKey;
    root["model"] = m_model;
    root["engine"] = m_engine;
    root["systemPrompt"] = m_systemPrompt;
    root["timeoutMs"] = m_timeoutMs;
    root["enabled"] = m_enabled;

    QFile file(configPath);
    if (file.open(QIODevice::WriteOnly)) {
        file.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
        file.close();
    }

    m_configured = !m_apiUrl.isEmpty() && !m_apiKey.isEmpty() && !m_model.isEmpty();
}

void AIRiskProvider::clearCache()
{
    m_cache.clear();
    for (auto it = m_replyToPath.begin(); it != m_replyToPath.end(); ++it) {
        QNetworkReply *reply = it.key();
        reply->abort();
        reply->deleteLater();
    }
    m_replyToPath.clear();
    m_pendingPaths.clear();
}

QString AIRiskProvider::normalizePathKey(const QString &path) const
{
    QString k = path;
    k.replace('/', '\\');
    return k.toLower();
}

void AIRiskProvider::queryPathRisk(const QString &fullPath)
{
    if (!m_enabled) return;

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

    if (!m_configured) {
        return;
    }

    m_pendingPaths.insert(key);

    QJsonObject requestBody;
    requestBody["model"] = m_model;

    QJsonArray messages;
    QJsonObject sysMsg;
    sysMsg["role"] = "system";
    sysMsg["content"] = m_systemPrompt;
    messages.append(sysMsg);

    QJsonObject userMsg;
    userMsg["role"] = "user";
    userMsg["content"] = fullPath;
    messages.append(userMsg);

    requestBody["messages"] = messages;
    requestBody["temperature"] = 0.3;
    requestBody["max_tokens"] = 300;

    QNetworkRequest request;
    request.setUrl(QUrl(m_apiUrl));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json; charset=utf-8");
    request.setRawHeader("Authorization", QString("Bearer %1").arg(m_apiKey).toUtf8());
    request.setTransferTimeout(m_timeoutMs);

    QNetworkReply *reply = m_networkManager->post(request, QJsonDocument(requestBody).toJson(QJsonDocument::Compact));
    m_replyToPath[reply] = fullPath;
    connect(reply, &QNetworkReply::finished, this, &AIRiskProvider::onReplyFinished);
}

bool AIRiskProvider::isQuerying(const QString &fullPath) const
{
    return m_pendingPaths.contains(normalizePathKey(fullPath));
}

bool AIRiskProvider::hasCachedResult(const QString &fullPath) const
{
    return m_cache.contains(normalizePathKey(fullPath));
}

QVariantMap AIRiskProvider::cachedResult(const QString &fullPath) const
{
    return m_cache.value(normalizePathKey(fullPath));
}

void AIRiskProvider::onReplyFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    QString fullPath = m_replyToPath.take(reply);
    QString key = normalizePathKey(fullPath);
    m_pendingPaths.remove(key);

    QVariantMap result;

    if (reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        result = parseAIResponse(data);
        if (!result.isEmpty()) {
            QFileInfo fi(fullPath);
            QString name = fi.fileName();
            if (name.isEmpty()) name = fullPath.left(3);
            result["displayName"] = name;
            m_cache.insert(key, result);
        }
    } else {
        qWarning() << "[AIRisk] Network error for" << fullPath << ":" << reply->errorString();
    }

    reply->deleteLater();

    emit riskInfoReady(fullPath, result);
}

QVariantMap AIRiskProvider::parseAIResponse(const QByteArray &data) const
{
    QVariantMap emptyResult;

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(data, &err);
    if (err.error != QJsonParseError::NoError || !doc.isObject()) return emptyResult;

    QJsonObject root = doc.object();
    QJsonArray choices = root.value("choices").toArray();
    if (choices.isEmpty()) return emptyResult;

    QJsonObject firstChoice = choices.at(0).toObject();
    QJsonObject message = firstChoice.value("message").toObject();
    QString content = message.value("content").toString().trimmed();

    if (content.isEmpty()) return emptyResult;

    int jsonStart = content.indexOf('{');
    int jsonEnd = content.lastIndexOf('}');
    if (jsonStart >= 0 && jsonEnd > jsonStart) {
        content = content.mid(jsonStart, jsonEnd - jsonStart + 1);
    }

    QJsonDocument resDoc = QJsonDocument::fromJson(content.toUtf8(), &err);
    if (err.error != QJsonParseError::NoError || !resDoc.isObject()) return emptyResult;

    QJsonObject resObj = resDoc.object();
    QString level = resObj.value("level").toString().toLower().trimmed();
    QString description = resObj.value("description").toString().trimmed();

    static const QStringList validLevels = {"danger", "warning", "caution", "safe"};
    if (!validLevels.contains(level)) level = "caution";
    if (description.isEmpty()) return emptyResult;

    QVariantMap result;
    result["level"] = level;
    result["description"] = description;
    result["fromAI"] = true;

    QMap<QString, QVariantMap> levelInfo;
    levelInfo["danger"] = {{"label", "危险"}, {"color", "#E81123"}, {"levelNum", 3}};
    levelInfo["warning"] = {{"label", "警告"}, {"color", "#FF8C00"}, {"levelNum", 2}};
    levelInfo["caution"] = {{"label", "注意"}, {"color", "#F7B500"}, {"levelNum", 1}};
    levelInfo["safe"] = {{"label", "安全"}, {"color", "#107C10"}, {"levelNum", 0}};

    if (levelInfo.contains(level)) {
        const QVariantMap &li = levelInfo[level];
        result["label"] = li["label"].toString();
        result["color"] = li["color"].toString();
        result["levelNum"] = li["levelNum"].toInt();
    } else {
        result["label"] = level;
        result["color"] = "#107C10";
        result["levelNum"] = 0;
    }

    return result;
}
