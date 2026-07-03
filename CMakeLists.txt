cmake_minimum_required(VERSION 3.16)

project(QuickSpaceScan VERSION 1.0 LANGUAGES CXX RC)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(MSVC)
    add_compile_options("/utf-8")
endif()
set(QT_QML_GENERATE_QMLLS_INI ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Network)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appQuickSpaceScan
    main.cpp
    src/core/scanengine.h
    src/core/scanengine.cpp
    src/core/treeitem.h
    src/core/treeitem.cpp
    src/core/treemodel.h
    src/core/treemodel.cpp
    src/core/appsettings.h
    src/core/appsettings.cpp
    src/adapters/drivemanager.h
    src/adapters/drivemanager.cpp
    src/ai/airiskprovider.h
    src/ai/airiskprovider.cpp
    src/risk/pathriskprovider.h
    src/risk/pathriskprovider.cpp
)

qt_add_resources(appQuickSpaceScan "resources"
    PREFIX "/"
    BASE "resources"
    FILES
        resources/icons/app_icon.png
        resources/system_paths.json
        resources/ai_config.json
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
        ui/components/SettingsDialog.qml
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
    PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::Network
)

install(TARGETS appQuickSpaceScan
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

add_custom_command(TARGET appQuickSpaceScan POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory
        "$<TARGET_FILE_DIR:appQuickSpaceScan>/resources"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_SOURCE_DIR}/resources/system_paths.json"
        "$<TARGET_FILE_DIR:appQuickSpaceScan>/resources/system_paths.json"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_SOURCE_DIR}/resources/system_paths.json"
        "$<TARGET_FILE_DIR:appQuickSpaceScan>/system_paths.json"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_SOURCE_DIR}/resources/ai_config.json"
        "$<TARGET_FILE_DIR:appQuickSpaceScan>/resources/ai_config.json"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_SOURCE_DIR}/resources/ai_config.json"
        "$<TARGET_FILE_DIR:appQuickSpaceScan>/ai_config.json"
)
