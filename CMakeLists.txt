cmake_minimum_required(VERSION 3.16)

project(QuickSpaceScan VERSION 1.0 LANGUAGES CXX RC)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(MSVC)
    add_compile_options("/utf-8")
endif()
set(QT_QML_GENERATE_QMLLS_INI ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appQuickSpaceScan
    main.cpp
    src/core/scanengine.h
    src/core/scanengine.cpp
    src/core/treeitem.h
    src/core/treeitem.cpp
    src/core/treemodel.h
    src/core/treemodel.cpp
    src/adapters/drivemanager.h
    src/adapters/drivemanager.cpp
    resources/resources.qrc
)

if(WIN32)
    target_sources(appQuickSpaceScan PRIVATE resources/app.rc)
endif()

qt_add_qml_module(appQuickSpaceScan
    URI QuickSpaceScan
    QML_FILES
        Main.qml
        ui/views/HomeView.qml
        ui/views/Sidebar.qml
        ui/components/TreeListView.qml
        ui/components/TreeItemDelegate.qml
        ui/components/StatusBar.qml
        ui/components/IconButton.qml
        ui/themes/ThemeManager.qml
        ui/themes/LightTheme.qml
        ui/themes/DarkTheme.qml
)

set_target_properties(appQuickSpaceScan PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appQuickSpaceScan
    PRIVATE Qt6::Quick Qt6::QuickControls2
)

install(TARGETS appQuickSpaceScan
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
