#include <QtQml/qqmlprivate.h>
#include <QtCore/qdir.h>
#include <QtCore/qurl.h>
#include <QtCore/qhash.h>
#include <QtCore/qstring.h>

namespace QmlCacheGeneratedCode {
namespace _qt_qml_QuickSpaceScan_Main_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_QuickSpaceScan_ui_views_HomeView_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_QuickSpaceScan_ui_views_Sidebar_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_QuickSpaceScan_ui_components_TreeListView_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_QuickSpaceScan_ui_components_TreeItemDelegate_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_QuickSpaceScan_ui_components_StatusBar_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_QuickSpaceScan_ui_components_IconButton_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_QuickSpaceScan_ui_themes_ThemeManager_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_QuickSpaceScan_ui_themes_LightTheme_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_QuickSpaceScan_ui_themes_DarkTheme_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}

}
namespace {
struct Registry {
    Registry();
    ~Registry();
    QHash<QString, const QQmlPrivate::CachedQmlUnit*> resourcePathToCachedUnit;
    static const QQmlPrivate::CachedQmlUnit *lookupCachedUnit(const QUrl &url);
};

Q_GLOBAL_STATIC(Registry, unitRegistry)


Registry::Registry() {
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/QuickSpaceScan/Main.qml"), &QmlCacheGeneratedCode::_qt_qml_QuickSpaceScan_Main_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/QuickSpaceScan/ui/views/HomeView.qml"), &QmlCacheGeneratedCode::_qt_qml_QuickSpaceScan_ui_views_HomeView_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/QuickSpaceScan/ui/views/Sidebar.qml"), &QmlCacheGeneratedCode::_qt_qml_QuickSpaceScan_ui_views_Sidebar_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/QuickSpaceScan/ui/components/TreeListView.qml"), &QmlCacheGeneratedCode::_qt_qml_QuickSpaceScan_ui_components_TreeListView_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/QuickSpaceScan/ui/components/TreeItemDelegate.qml"), &QmlCacheGeneratedCode::_qt_qml_QuickSpaceScan_ui_components_TreeItemDelegate_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/QuickSpaceScan/ui/components/StatusBar.qml"), &QmlCacheGeneratedCode::_qt_qml_QuickSpaceScan_ui_components_StatusBar_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/QuickSpaceScan/ui/components/IconButton.qml"), &QmlCacheGeneratedCode::_qt_qml_QuickSpaceScan_ui_components_IconButton_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/QuickSpaceScan/ui/themes/ThemeManager.qml"), &QmlCacheGeneratedCode::_qt_qml_QuickSpaceScan_ui_themes_ThemeManager_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/QuickSpaceScan/ui/themes/LightTheme.qml"), &QmlCacheGeneratedCode::_qt_qml_QuickSpaceScan_ui_themes_LightTheme_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/QuickSpaceScan/ui/themes/DarkTheme.qml"), &QmlCacheGeneratedCode::_qt_qml_QuickSpaceScan_ui_themes_DarkTheme_qml::unit);
    QQmlPrivate::RegisterQmlUnitCacheHook registration;
    registration.structVersion = 0;
    registration.lookupCachedQmlUnit = &lookupCachedUnit;
    QQmlPrivate::qmlregister(QQmlPrivate::QmlUnitCacheHookRegistration, &registration);
}

Registry::~Registry() {
    QQmlPrivate::qmlunregister(QQmlPrivate::QmlUnitCacheHookRegistration, quintptr(&lookupCachedUnit));
}

const QQmlPrivate::CachedQmlUnit *Registry::lookupCachedUnit(const QUrl &url) {
    if (url.scheme() != QLatin1String("qrc"))
        return nullptr;
    QString resourcePath = QDir::cleanPath(url.path());
    if (resourcePath.isEmpty())
        return nullptr;
    if (!resourcePath.startsWith(QLatin1Char('/')))
        resourcePath.prepend(QLatin1Char('/'));
    return unitRegistry()->resourcePathToCachedUnit.value(resourcePath, nullptr);
}
}
int QT_MANGLE_NAMESPACE(qInitResources_qmlcache_appQuickSpaceScan)() {
    ::unitRegistry();
    return 1;
}
Q_CONSTRUCTOR_FUNCTION(QT_MANGLE_NAMESPACE(qInitResources_qmlcache_appQuickSpaceScan))
int QT_MANGLE_NAMESPACE(qCleanupResources_qmlcache_appQuickSpaceScan)() {
    return 1;
}
