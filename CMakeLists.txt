cmake_minimum_required(VERSION 3.16)

project(GSMKayakpro VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS
    Quick
    Core
    Bluetooth
    Gui
    Qml
    PrintSupport
    QuickControls2
)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appGSMKayakpro
    main.cpp
    BluetoothManager.cpp
)
set_source_files_properties(BluetoothManager.cpp PROPERTIES SKIP_AUTOMOC YES)
qt_add_qml_module(appGSMKayakpro
    URI GSMKayakpro
    QML_FILES
        Main.qml
        QML_FILES
        SOURCES BluetoothManager.h
        SOURCES PrintManager.cpp PrintManager.h
        SOURCES SharedData.cpp SharedData.h
        QML_FILES SetBluetoothAddress.qml
        QML_FILES Racing.qml
        RESOURCES images/bluetooth.png
        RESOURCES images/race_background.png
        RESOURCES images/race_result.png
        RESOURCES images/race_line.png
        RESOURCES images/race_vector_line.svg
        RESOURCES images/race_vector_passed.svg
        RESOURCES images/player_sprite.png
        RESOURCES images/player_sprite.png
        RESOURCES images/each_lane_rect.svg
        RESOURCES images/race_label.svg
        RESOURCES images/bluetooth.png images/each_lane_rect.svg  images/kayak.gif  images/player_sprite.png images/race_background.png images/race_label.svg images/race_line.png images/race_result.png images/race_vector_line.svg images/race_vector_passed.svg
        RESOURCES images/main_background.svg
        RESOURCES images/check_icon.svg
        RESOURCES images/CONNECTED.svg
        RESOURCES images/CONNECTING.svg images/FAILED.svg
        RESOURCES images/main_number.svg
        RESOURCES images/end_line.svg
        RESOURCES  images/icon.png
        RESOURCES  images/icon.png
        RESOURCES images/device_connect.png
        RESOURCES images/spin.svg
        QML_FILES App.qml FirstScreen.qml Main.qml Racing.qml
        #SOURCES BluetoothManager.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appGSMKayakpro PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appGSMKayakpro
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED YES

)

target_link_libraries(appGSMKayakpro
    PRIVATE Qt6::Quick
    Qt6::Bluetooth
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::PrintSupport
    Qt6::QuickControls2
)
# target_link_libraries(appGSMKayakpro
#     PRIVATE Qt6::Bluetooth

# )

include(GNUInstallDirs)
install(TARGETS appGSMKayakpro
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
