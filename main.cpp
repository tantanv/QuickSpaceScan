#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QtQuickControls2/QQuickStyle>

#include "src/core/scanengine.h"
#include "src/core/treeitem.h"
#include "src/core/treemodel.h"
#include "src/core/appsettings.h"
#include "src/adapters/drivemanager.h"
#include "src/risk/pathriskprovider.h"

int main(int argc, char *argv[])
{
    QQuickStyle::setStyle("Basic");
    QGuiApplication app(argc, argv);

    app.setApplicationName("QuickSpaceScan");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("QuickSpaceScan");
    app.setWindowIcon(QIcon(":/icons/app_icon.png"));

    qmlRegisterType<ScanEngine>("QuickSpaceScan", 1, 0, "ScanEngine");
    qmlRegisterType<TreeItem>("QuickSpaceScan", 1, 0, "TreeItem");
    qmlRegisterType<TreeModel>("QuickSpaceScan", 1, 0, "TreeModel");
    qmlRegisterType<DriveManager>("QuickSpaceScan", 1, 0, "DriveManager");
    qmlRegisterType<PathRiskProvider>("QuickSpaceScan", 1, 0, "PathRiskProvider");

    QQmlApplicationEngine engine;

    ScanEngine *scanEngine = new ScanEngine(&engine);
    TreeModel *treeModel = new TreeModel(&engine);
    DriveManager *driveManager = new DriveManager(&engine);
    PathRiskProvider *pathRiskProvider = new PathRiskProvider(&engine);
    AppSettings *appSettings = new AppSettings(&engine);

    engine.rootContext()->setContextProperty("scanEngine", scanEngine);
    engine.rootContext()->setContextProperty("treeModel", treeModel);
    engine.rootContext()->setContextProperty("driveManager", driveManager);
    engine.rootContext()->setContextProperty("pathRiskProvider", pathRiskProvider);
    engine.rootContext()->setContextProperty("appSettings", appSettings);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("QuickSpaceScan", "Main");

    return app.exec();
}
