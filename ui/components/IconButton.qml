import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: iconButton
    property alias iconSource: iconText.text
    property color iconColor: theme.textSecondary
    property color hoverColor: "transparent"
    property int iconPixelSize: 20
    signal clicked()

    width: 36
    height: 36
    radius: 8
    color: mouseArea.containsMouse ? hoverColor : "transparent"

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Text {
        id: iconText
        anchors.centerIn: parent
        font.pixelSize: iconPixelSize
        color: iconButton.iconColor
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: iconButton.clicked()
    }
}
