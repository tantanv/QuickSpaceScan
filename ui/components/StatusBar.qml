import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../themes"

Rectangle {
    id: statusBar
    color: "transparent"

    property string statusText: "就绪"
    property int itemCount: 0
    property string sizeText: ""

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 8

        Rectangle {
            width: 6; height: 6
            radius: 3
            color: statusBar.statusText === "扫描中..." ? theme.progressBarFill :
                   statusBar.statusText === "扫描完成" ? theme.successColor :
                   statusBar.statusText.indexOf("错误") >= 0 ? theme.dangerColor :
                   theme.textMuted
        }

        Label {
            text: statusBar.statusText
            font.pixelSize: 12
            color: theme.textMuted
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true }

        Label {
            text: statusBar.sizeText.length > 0 ? statusBar.itemCount + " 个项目  |  " + statusBar.sizeText : statusBar.itemCount + " 个项目"
            font.pixelSize: 12
            color: theme.textMuted
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
