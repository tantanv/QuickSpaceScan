#include "appsettings.h"

AppSettings::AppSettings(QObject *parent)
    : QObject(parent)
    , m_settings("QuickSpaceScan", "QuickSpaceScan")
{
    if (m_settings.contains("ui/themeName")) {
        m_themeName = m_settings.value("ui/themeName", "light").toString();
    } else {
        bool oldDark = m_settings.value("ui/darkTheme", false).toBool();
        m_themeName = oldDark ? "dark" : "light";
    }
}

QString AppSettings::themeName() const
{
    return m_themeName;
}

void AppSettings::setThemeName(const QString &name)
{
    if (m_themeName != name) {
        m_themeName = name;
        emit themeNameChanged();
    }
}

void AppSettings::save()
{
    m_settings.setValue("ui/themeName", m_themeName);
    m_settings.sync();
}
