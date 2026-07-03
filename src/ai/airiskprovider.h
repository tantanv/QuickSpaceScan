#ifndef AIRISKPROVIDER_H
#define AIRISKPROVIDER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QMap>
#include <QSet>
#include <QVariantMap>
#include <QJsonObject>
#include <QJsonArray>

class AIRiskProvider : public QObject
{
    Q_OBJECT
public:
    explicit AIRiskProvider(QObject *parent = nullptr);
    ~AIRiskProvider();

    bool isConfigured() const { return m_configured && m_enabled; }
    bool isEnabled() const { return m_enabled; }

    void queryPathRisk(const QString &fullPath);

    bool isQuerying(const QString &fullPath) const;
    bool hasCachedResult(const QString &fullPath) const;
    QVariantMap cachedResult(const QString &fullPath) const;

    Q_INVOKABLE void setEnabled(bool enabled);
    Q_INVOKABLE void setApiConfig(const QString &url, const QString &key, const QString &model, const QString &engine);
    Q_INVOKABLE QString apiUrl() const { return m_apiUrl; }
    Q_INVOKABLE QString apiKey() const { return m_apiKey; }
    Q_INVOKABLE QString model() const { return m_model; }
    Q_INVOKABLE QString engine() const { return m_engine; }
    Q_INVOKABLE void saveConfig();
    Q_INVOKABLE void clearCache();

signals:
    void riskInfoReady(const QString &fullPath, const QVariantMap &info);
    void configChanged();

private slots:
    void onReplyFinished();

private:
    void loadConfig();
    QString getConfigFilePath() const;
    QString normalizePathKey(const QString &path) const;
    QVariantMap parseAIResponse(const QByteArray &data) const;

    QNetworkAccessManager *m_networkManager;
    bool m_configured;
    bool m_enabled=false;
    QString m_apiUrl;
    QString m_apiKey;
    QString m_model;
    QString m_engine;
    QString m_systemPrompt;
    int m_timeoutMs;

    QMap<QString, QVariantMap> m_cache;
    QSet<QString> m_pendingPaths;

    QMap<QNetworkReply*, QString> m_replyToPath;
};

#endif // AIRISKPROVIDER_H
