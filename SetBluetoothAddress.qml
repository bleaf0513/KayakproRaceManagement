import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window

ApplicationWindow {
    id: root
    width: Screen.width - 20
    height: Screen.height - 50
    visible: true
    title: "KP3902 MAC Address Settings"

    property int consoleCount: 10
    property var macAddresses: Array(consoleCount).fill("")

    // Colors
    readonly property color bgColor: "#121212"
    readonly property color cardColor: "#1E1E2A"
    readonly property color cardBorder: "#333344"
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: "#BBBBBB"
    readonly property color accentGreen: "#18C77A"
    readonly property color accentHover: "#16B370"
    readonly property color fieldFocus: "#2D8CFF"

    Rectangle {
        anchors.fill: parent
        color: bgColor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Flow {
                id: flowGrid
                width: parent.width
                spacing: 20
                flow: Flow.LeftToRight

                Repeater {
                    model: consoleCount

                    Rectangle {
                        width: (flowGrid.width - flowGrid.spacing) / 2
                        height: content.implicitHeight + 40
                        radius: 20
                        color: cardColor
                        border.color: cardBorder
                        border.width: 1

                        property int consoleId: index + 1

                        ColumnLayout {
                            id: content
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 14

                            Text {
                                text: "Console " + (index + 1)
                                font.pixelSize: 24
                                font.bold: true
                                color: textPrimary
                            }

                            TextField {
                                Layout.fillWidth: true
                                placeholderText: "XX:XX:XX:XX:XX:XX"
                                text: macAddresses[index]
                                font.pixelSize: 18
                                color: textPrimary
                                padding: 10
                                background: Rectangle {
                                    radius: 12
                                    border.color:fieldFocus// control.activeFocus ? fieldFocus : cardBorder
                                    border.width: 1
                                    color: "#2A2A3B"
                                }
                                onTextChanged: macAddresses[index] = text
                            }
                        }
                    }
                }
            }
        }

        // Global Save All Button
    }
    Rectangle {
        //Layout.fillWidth: true
        width:root.width/10
        height: root.height/25
        x:root.width/2-width/2
        y:root.height*0.82
        radius: 14
        color: accentGreen

        Text {
            anchors.centerIn: parent
            text: "Save"
            font.pixelSize: 20
            font.bold: true
            color: "#FFFFFF"
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onEntered: parent.color = accentHover
            onExited: parent.color = accentGreen
            onClicked: saveAllMacAddresses()
        }
    }

    // Signal to C++ for saving all MAC addresses
    signal saveAllMacAddresses()
}
