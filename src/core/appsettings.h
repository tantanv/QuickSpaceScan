#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include <QObject>
#include <QSettings>

class AppSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString themeName READ themeName WRITE setThemeName NOTIFY themeNameChanged)

public:
    explicit AppSettings(QObject *parent = nullptr);

    QString themeName() const;
    void setThemeName(const QString &name);

    Q_INVOKABLE void save();

signals:
    void themeNameChanged();

private:
    QSettings m_settings;
    QString m_themeName;
};

#endif // APPSETTINGS_H
