import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QuickSpaceScan 1.0
import "../components"
import "../themes"

Rectangle {
    id: homeView
    color: "transparent"

    property ScanEngine scanEngine: ScanEngine {}
    property string currentScanPath: ""
    property bool isScanning: false

    property string statusText: "就绪"
    property int statusItemCount: 0
    property string statusSizeText: ""

    function isRootPath(path) {
        if (!path) return false
        var p = path.replace(/\\/g, "/")
        if (p.length <= 3 && p[1] === ":") return true
        return false
    }

    function refreshScan() {
        if (currentScanPath) {
            if (isRootPath(currentScanPath)) {
                startScan(currentScanPath, true)
            } else {
                statusText = "正在刷新..."
                statusItemCount = 0
                statusSizeText = ""
                scanEngine.rescanPath(currentScanPath)
            }
        }
    }

    Timer {
        id: autoRefreshTimer
        interval: 150
        repeat: true
        running: isScanning
        onTriggered: {
            treeListView.scheduleRefresh()
            statusItemCount = scanEngine.itemCount
            statusSizeText = formatTotalSize(scanEngine.totalSize)
        }
    }

    Connections {
        target: scanEngine
        function onScanningChanged() {
            isScanning = scanEngine.scanning
            statusText = isScanning ? "扫描中..." : "扫描完成"
        }
        function onRootItemChanged() {
            treeListView.rootItem = scanEngine.rootItem
            treeListView.currentPath = currentScanPath
            treeListView.rebuildFlatList()
        }
        function onScanFinished() {
            isScanning = false
            treeListView.rebuildFlatList()
            statusText = "扫描完成"
            statusItemCount = scanEngine.itemCount
            statusSizeText = formatTotalSize(scanEngine.totalSize)
        }
        function onBatchItemsAdded() {
            treeListView.scheduleRefresh()
            statusItemCount = scanEngine.itemCount
            statusSizeText = formatTotalSize(scanEngine.totalSize)
        }
        function onTotalSizeChanged() {
            statusSizeText = formatTotalSize(scanEngine.totalSize)
        }
        function onItemCountChanged() {
            statusItemCount = scanEngine.itemCount
        }
        function onCurrentPathChanged() {
            currentScanPath = scanEngine.currentPath
            treeListView.currentPath = currentScanPath
            treeListView.rootItem = scanEngine.rootItem
            treeListView.rebuildFlatList()
            statusText = isScanning ? "扫描中..." : "就绪"
            statusItemCount = scanEngine.itemCount
            statusSizeText = formatTotalSize(scanEngine.totalSize)
        }
        function onPathDeleted(path) {
            treeListView.selectedPath = ""
            treeListView.rebuildFlatList()
            statusText = "就绪"
            statusItemCount = scanEngine.itemCount
            statusSizeText = formatTotalSize(scanEngine.totalSize)
        }
        function onErrorOccurred(error) {
            statusText = "错误: " + error
        }
    }

    function startScan(path, forceRefresh) {
        currentScanPath = path
        treeListView.rootItem = null
        treeListView.selectedPath = ""
        if (forceRefresh) {
            statusText = "正在刷新..."
        } else {
            statusText = "正在准备扫描..."
        }
        statusItemCount = 0
        statusSizeText = ""
        scanEngine.startScan(path, forceRefresh === true)
    }

    function openFolder(path) {
        scanEngine.navigateToPath(path)
    }

    function goToParent() {
        scanEngine.navigateToParent()
    }

    function openInExplorer(path) { scanEngine.openInExplorer(path) }

    function deletePath(path) {
        var ok = scanEngine.deletePath(path)
        if (!ok) statusText = "删除失败: 文件可能被占用或权限不足"
        deleteDialog.dialogVisible = false
    }

    property string pendingDeletePath: ""

    Item {
        id: deleteDialog
        property bool dialogVisible: false
        property string dialogName: ""
        anchors.fill: parent
        z: 1000
        visible: dialogVisible

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.4)
            MouseArea { anchors.fill: parent; onClicked: deleteDialog.dialogVisible = false }
        }

        Rectangle {
            id: dialogBox
            width: 420
            implicitHeight: dialogCol.implicitHeight
            x: (parent.width - width) / 2
            y: (parent.height - implicitHeight) / 2
            radius: theme.cornerRadiusLarge
            color: theme.elevatedSurface
            border.color: theme.isDarkTheme ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.12)
            border.width: 1

            Column {
                id: dialogCol
                anchors.fill: parent
                spacing: 0

                Item {
                    width: parent.width
                    implicitHeight: msgCol.implicitHeight + 24
                    Column {
                        id: msgCol
                        anchors.fill: parent
                        anchors.margins: 24
                        anchors.bottomMargin: 12
                        spacing: 8

                        Text {
                            text: "确认删除"
                            font.pixelSize: 18
                            font.weight: Font.DemiBold
                            color: theme.textPrimary
                        }

                        Text {
                            text: "确定要删除 \"" + deleteDialog.dialogName + "\" 吗？此操作不可撤销。"
                            font.pixelSize: 13
                            color: theme.textSecondary
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }
                }

                Rectangle {
                    width: parent.width; height: 1
                    color: theme.dividerColor
                }

                Item {
                    width: parent.width
                    implicitHeight: 52
                    Row {
                        anchors.fill: parent
                        anchors.margins: 12
                        anchors.rightMargin: 16
                        spacing: 8
                        layoutDirection: Qt.RightToLeft

                        Rectangle {
                            id: confirmDeleteBtn
                            implicitWidth: deleteBtnText.implicitWidth + 32
                            implicitHeight: 32
                            radius: theme.cornerRadiusSmall
                            color: deleteBtnArea.pressed ? "#a8221a" : (deleteBtnArea.containsMouse ? "#d1342b" : theme.dangerColor)

                            Text {
                                id: deleteBtnText
                                text: "删除"
                                font.pixelSize: 13
                                color: "#ffffff"
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                id: deleteBtnArea
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton
                                onClicked: deletePath(pendingDeletePath)
                            }
                        }

                        Rectangle {
                            id: cancelBtn
                            implicitWidth: cancelBtnText.implicitWidth + 32
                            implicitHeight: 32
                            radius: theme.cornerRadiusSmall
                            color: cancelBtnArea.pressed ? theme.pressedColor : (cancelBtnArea.containsMouse ? theme.hoverColor : "transparent")
                            border.color: cancelBtnArea.containsMouse ? theme.controlStroke : "transparent"
                            border.width: 1

                            Text {
                                id: cancelBtnText
                                text: "取消"
                                font.pixelSize: 13
                                color: theme.textPrimary
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                id: cancelBtnArea
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton
                                onClicked: deleteDialog.dialogVisible = false
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
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

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 4

                    ToolButton {
                        width: 32
                        height: 32
                        visible: currentScanPath && !isRootPath(currentScanPath)
                        text: "‹"
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        onClicked: goToParent()
                        background: Rectangle {
                            radius: theme.cornerRadiusSmall
                            color: parent.hovered ? theme.hoverColor : "transparent"
                        }
                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: theme.textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: "返回上级目录"
                        ToolTip.delay: 500
                    }

                    Label {
                        text: currentScanPath || "选择左侧驱动器开始扫描"
                        font.pixelSize: 13
                        color: theme.textSecondary
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                    }

                    Row {
                        spacing: 6
                        visible: isScanning
                        BusyIndicator {
                            width: 16; height: 16
                            running: isScanning
                        }
                        Label {
                            text: formatTotalSize(scanEngine.totalSize)
                            font.pixelSize: 12
                            color: theme.textMuted
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: theme.dividerColor
                }
            }

            TreeListView {
                id: treeListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentPath: currentScanPath
                onFolderOpenRequested: function(path) { openFolder(path) }
                onGoUpRequested: function() { goToParent() }
                onOpenInExplorerRequested: function(path) { openInExplorer(path) }
                onRequestDeleteDialog: function(path, name) {
                    pendingDeletePath = path
                    deleteDialog.dialogName = name
                    deleteDialog.dialogVisible = true
                }
            }
        }
    }

    function formatTotalSize(bytes) {
        var units = ["B", "KB", "MB", "GB", "TB"]
        var unitIndex = 0
        var size = bytes
        while (size >= 1024 && unitIndex < units.length - 1) {
            size /= 1024
            unitIndex++
        }
        if (unitIndex === 0) return Math.floor(size) + " " + units[unitIndex]
        return size.toFixed(2) + " " + units[unitIndex]
    }
}
