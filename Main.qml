import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "ui/views"
import "ui/components"
import "ui/themes"

ApplicationWindow {
    id: rootWindow
    width: 1200
    height: 800
    minimumWidth: 900
    minimumHeight: 600
    visible: true
    title: "QuickSpaceScan"
    color: theme.backgroundColor

    ThemeManager {
        id: theme
        Component.onCompleted: themeName = appSettings.themeName
    }

    Connections {
        target: appSettings
        function onThemeNameChanged() {
            theme.themeName = appSettings.themeName
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            color: theme.surfaceColor
            border.width: 0

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: theme.dividerColor
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 8

                Label {
                    text: "QuickSpaceScan"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: theme.textPrimary
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                ToolButton {
                    width: 36
                    height: 36
                    display: AbstractButton.IconOnly
                    text: "⟳"
                    font.pixelSize: 16
                    onClicked: {
                        driveManager.refreshDrives()
                        if (homeView.currentScanPath) {
                            homeView.refreshScan()
                        }
                    }
                    background: Rectangle {
                        radius: theme.cornerRadiusSmall
                        color: parent.hovered ? theme.hoverColor : "transparent"
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: theme.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: "刷新"
                    ToolTip.delay: 500
                }

                ToolButton {
                    width: 36
                    height: 36
                    display: AbstractButton.IconOnly
                    text: "⚙"
                    font.pixelSize: 16
                    onClicked: {
                        settingsDialog.loadCurrentValues()
                        settingsDialog.dialogVisible = true
                    }
                    background: Rectangle {
                        radius: theme.cornerRadiusSmall
                        color: parent.hovered ? theme.hoverColor : "transparent"
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: theme.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: "设置"
                    ToolTip.delay: 500
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Sidebar {
                id: sidebar
                Layout.preferredWidth: 260
                Layout.fillHeight: true
                Layout.topMargin: 8
                Layout.bottomMargin: 8
                Layout.leftMargin: 8
                Layout.rightMargin: 0
            }

            HomeView {
                id: homeView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 8
            }
        }

        StatusBar {
            id: statusBar
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            statusText: homeView.statusText
            itemCount: homeView.statusItemCount
            sizeText: homeView.statusSizeText
        }
    }

    SettingsDialog {
        id: settingsDialog
    }

    Rectangle {
        id: aiLoadingTip
        visible: homeView.aiLoadingTipPath.length > 0
        z: 9999
        width: tipText.implicitWidth + 16
        height: 22
        radius: theme.cornerRadiusSmall
        color: theme.accentColor
        x: {
            var px = homeView.aiLoadingTipPos.x + 12
            if (px + width > rootWindow.width - 12) px = rootWindow.width - width - 12
            if (px < 12) px = 12
            return px
        }
        y: {
            var py = homeView.aiLoadingTipPos.y + 16
            if (py + height > rootWindow.height - 4) py = homeView.aiLoadingTipPos.y - height - 4
            if (py < 4) py = 4
            return py
        }

        Text {
            id: tipText
            text: "🔍 AI搜索中..."
            font.pixelSize: 11
            color: "#ffffff"
            anchors.centerIn: parent
        }
    }
}
