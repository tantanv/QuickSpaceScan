import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../themes"

Rectangle {
    id: sidebar
    radius: theme.cornerRadiusMedium
    color: theme.surfaceColor
    clip: true

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            color: "transparent"

            Label {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: "此电脑"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: theme.textSecondary
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: theme.dividerColor
            }
        }

        ListView {
            id: driveListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: driveManager
            clip: true
            spacing: 2
            topMargin: 4
            bottomMargin: 4

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width - 8 : 0
                height: 64
                radius: theme.cornerRadiusSmall
                x: (ListView.view ? ListView.view.width - width : 0) / 2
                color: ListView.isCurrentItem ? theme.selectedColor :
                       (driveMouseArea.containsMouse ? theme.hoverColor : "transparent")

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Rectangle {
                        width: 36
                        height: 36
                        radius: theme.cornerRadiusSmall
                        color: theme.primaryColor

                        Label {
                            anchors.centerIn: parent
                            text: model.name ? model.name.charAt(0).toUpperCase() : (model.path ? model.path.charAt(0).toUpperCase() : "")
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: "#ffffff"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            text: model.name || model.path || ""
                            font.pixelSize: 13
                            font.weight: Font.Normal
                            color: theme.textPrimary
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 3
                            radius: 2
                            color: theme.progressBarBg

                            Rectangle {
                                Layout.fillHeight: true
                                radius: 2
                                color: theme.progressBarFill

                                property double usedRatio: {
                                    var di = driveManager.driveAt(index)
                                    if (di.totalBytes > 0) return (di.totalBytes - di.freeBytes) / di.totalBytes
                                    return 0
                                }

                                width: parent.width * usedRatio
                                Behavior on width { NumberAnimation { duration: 400 } }
                            }
                        }

                        Label {
                            text: model.freeSpace + " 可用 / " + model.totalSize
                            font.pixelSize: 11
                            color: theme.textMuted
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                MouseArea {
                    id: driveMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        driveListView.currentIndex = index
                        homeView.startScan(model.path)
                    }
                }
            }

            footer: Item { width: parent ? parent.width : 0; height: 8 }
        }
    }
}
