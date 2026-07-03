#ifndef PATHRISKPROVIDER_H
#define PATHRISKPROVIDER_H

#include <QObject>
#include <QMap>
#include <QVariantMap>
#include <QSet>
#include <QString>
#include <QList>

class AIRiskProvider;

struct PathRiskRule {
    QString pattern;
    QString displayName;
    QString level;
    QString description;
    bool matchChildren;
    bool isWildcard;
    int sortPriority;
};

class PathRiskProvider : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool aiConfigured READ aiConfigured NOTIFY aiConfigChanged)
    Q_PROPERTY(bool aiEnabled READ aiEnabled WRITE setAIEnabled NOTIFY aiEnabledChanged)
    Q_PROPERTY(QString apiUrl READ apiUrl WRITE setApiUrl NOTIFY configChanged)
    Q_PROPERTY(QString apiKey READ apiKey WRITE setApiKey NOTIFY configChanged)
    Q_PROPERTY(QString model READ model WRITE setModel NOTIFY configChanged)
    Q_PROPERTY(QString engine READ engine WRITE setEngine NOTIFY configChanged)

public:
    explicit PathRiskProvider(QObject *parent = nullptr);
    ~PathRiskProvider();

    bool aiConfigured() const;
    bool aiEnabled() const;
    void setAIEnabled(bool enabled);

    QString apiUrl() const;
    QString apiKey() const;
    QString model() const;
    QString engine() const;

    void setApiUrl(const QString &url);
    void setApiKey(const QString &key);
    void setModel(const QString &model);
    void setEngine(const QString &engine);

    Q_INVOKABLE QVariantMap getRiskInfo(const QString &fullPath);
    Q_INVOKABLE void requestRiskInfo(const QString &fullPath);
    Q_INVOKABLE bool hasCachedResult(const QString &fullPath);
    Q_INVOKABLE QVariantMap getCachedResult(const QString &fullPath);
    Q_INVOKABLE bool isRequestPending(const QString &fullPath);
    Q_INVOKABLE void saveConfig();
    Q_INVOKABLE void clearCache();
    Q_INVOKABLE void resetConfig();

signals:
    void riskInfoReady(const QString &fullPath, const QVariantMap &info);
    void riskInfoLoading(const QString &fullPath);
    void aiConfigChanged();
    void aiEnabledChanged();
    void configChanged();

private slots:
    void onAIRiskInfoReady(const QString &fullPath, const QVariantMap &info);
    void onAIConfigChanged();

private:
    void loadLocalConfig();
    QString getRelativePathFromRoot(const QString &fullPath);
    QString normalizePathKey(const QString &path) const;
    QVariantMap queryLocalRisk(const QString &fullPath);
    QVariantMap getDefaultRiskInfo() const;
    void applyConfig();

    AIRiskProvider *m_aiProvider;

    QList<PathRiskRule> m_riskRules;
    QMap<QString, QVariantMap> m_riskLevels;
    QVariantMap m_defaultRiskInfo;

    QMap<QString, QVariantMap> m_cache;
    QSet<QString> m_pendingPaths;

    QString m_apiUrl;
    QString m_apiKey;
    QString m_model;
    QString m_engine;
};

#endif // PATHRISKPROVIDER_H
