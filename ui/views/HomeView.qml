import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QuickSpaceScan 1.0
import "../components"
import "../themes"

Rectangle {
    id: homeView
    color: "transparent"

    property string currentScanPath: ""
    property bool isScanning: false

    property string statusText: "就绪"
    property int statusItemCount: 0
    property string statusSizeText: ""

    property alias aiLoadingTipPath: treeListView.loadingTipPath
    property alias aiLoadingTipPos: treeListView.loadingTipWindowPos

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
        property var dialogRiskInfo: null

        property int dialogLevelNum: dialogRiskInfo ? (dialogRiskInfo.levelNum | 0) : 0
        property string dialogLabel: dialogRiskInfo ? (dialogRiskInfo.label || "") : ""
        property string dialogDescription: dialogRiskInfo ? (dialogRiskInfo.description || "") : ""

        anchors.fill: parent
        z: 1000
        visible: dialogVisible

        Rectangle {
            anchors.fill: parent
            color: theme.isDarkTheme ? Qt.rgba(0, 0, 0, 0.6) : Qt.rgba(0, 0, 0, 0.3)
            MouseArea { anchors.fill: parent; onClicked: deleteDialog.dialogVisible = false }
        }

        Rectangle {
            id: dialogBox
            width: 440
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
                        spacing: 12

                        Text {
                            text: deleteDialog.dialogLevelNum >= 3 ? "危险操作确认" : (deleteDialog.dialogLevelNum >= 2 ? "警告：请谨慎操作" : "确认删除")
                            font.pixelSize: 18
                            font.weight: Font.DemiBold
                            color: deleteDialog.dialogLevelNum >= 3 ? "#E81123" : (deleteDialog.dialogLevelNum >= 2 ? "#FF8C00" : theme.textPrimary)
                        }

                        Text {
                            text: "确定要删除 \"" + deleteDialog.dialogName + "\" 吗？此操作不可撤销。"
                            font.pixelSize: 13
                            color: theme.textSecondary
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Rectangle {
                            visible: deleteDialog.dialogLevelNum >= 2
                            width: parent.width
                            implicitHeight: warnText.contentHeight + 16
                            radius: theme.cornerRadiusSmall
                            color: {
                                if (deleteDialog.dialogLevelNum >= 3)
                                    return theme.isDarkTheme ? Qt.rgba(232/255, 17/255, 35/255, 0.18) : Qt.rgba(232/255, 17/255, 35/255, 0.08)
                                return theme.isDarkTheme ? Qt.rgba(255/255, 140/255, 0/255, 0.18) : Qt.rgba(255/255, 140/255, 0/255, 0.08)
                            }
                            border.color: {
                                if (deleteDialog.dialogLevelNum >= 3)
                                    return theme.isDarkTheme ? Qt.rgba(232/255, 17/255, 35/255, 0.5) : Qt.rgba(232/255, 17/255, 35/255, 0.3)
                                return theme.isDarkTheme ? Qt.rgba(255/255, 140/255, 0/255, 0.5) : Qt.rgba(255/255, 140/255, 0/255, 0.3)
                            }
                            border.width: 1

                            Text {
                                id: warnText
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.topMargin: 8
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                text: (deleteDialog.dialogLevelNum >= 3 ? "⚠️ 【危险】 " : "⚠️ 【警告】 ") + (deleteDialog.dialogDescription ? deleteDialog.dialogDescription : (deleteDialog.dialogLevelNum >= 3 ? "此为系统核心目录/文件，删除将导致系统崩溃或无法启动！" : "删除可能导致软件异常或系统功能受损！"))
                                font.pixelSize: 12
                                color: deleteDialog.dialogLevelNum >= 3 ? "#E81123" : "#FF8C00"
                                wrapMode: Text.WordWrap
                                width: parent.width - 16
                            }
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
                            color: {
                                if (deleteDialog.dialogLevelNum >= 3) return deleteBtnArea.pressed ? "#a8221a" : (deleteBtnArea.containsMouse ? "#d1342b" : "#E81123")
                                if (deleteDialog.dialogLevelNum >= 2) return deleteBtnArea.pressed ? "#c26a00" : (deleteBtnArea.containsMouse ? "#e67e00" : "#FF8C00")
                                return deleteBtnArea.pressed ? "#a8221a" : (deleteBtnArea.containsMouse ? "#d1342b" : theme.dangerColor)
                            }

                            Text {
                                id: deleteBtnText
                                text: deleteDialog.dialogLevelNum >= 3 ? "仍然删除" : "删除"
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

                    Rectangle {
                        id: pathInputContainer
                        Layout.fillWidth: true
                        height: 28
                        radius: theme.cornerRadiusSmall
                        color: pathInput.focus || pathInput.hovered ? theme.controlBackground : "transparent"
                        border.color: pathInput.focus ? theme.accentColor : (pathInput.hovered ? theme.controlStroke : "transparent")
                        border.width: 1

                        TextField {
                            id: pathInput
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            text: currentScanPath || ""
                            font.pixelSize: 13
                            color: theme.textPrimary
                            selectByMouse: true
                            hoverEnabled: true
                            leftPadding: 0
                            rightPadding: 0
                            topPadding: 0
                            bottomPadding: 0
                            verticalAlignment: Text.AlignVCenter
                            background: Item { }

                            Text {
                                id: placeholderText
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: "选择左侧驱动器开始扫描，或输入路径后按回车跳转"
                                font.pixelSize: 13
                                color: theme.textDisabled
                                visible: !pathInput.activeFocus && !pathInput.text
                            }

                            function syncText() {
                                if (!activeFocus) {
                                    pathInput.text = currentScanPath || ""
                                }
                            }

                            Component.onCompleted: syncText()

                            Connections {
                                target: homeView
                                function onCurrentScanPathChanged() { pathInput.syncText() }
                            }

                            onActiveFocusChanged: {
                                if (!activeFocus) {
                                    pathInput.text = currentScanPath || ""
                                } else {
                                    if (!currentScanPath) {
                                        pathInput.text = ""
                                    }
                                    pathInput.selectAll()
                                }
                            }

                            onAccepted: {
                                var inputPath = pathInput.text.trim()
                                if (!inputPath) {
                                    pathInput.text = currentScanPath || ""
                                    pathInput.focus = false
                                    return
                                }
                                var normalized = inputPath.replace(/\//g, "\\")
                                if (!/^[a-zA-Z]:\\/.test(normalized)) {
                                    if (/^[a-zA-Z]:$/.test(normalized)) {
                                        normalized = normalized + "\\"
                                    } else if (/^[a-zA-Z]$/.test(normalized)) {
                                        normalized = normalized + ":\\"
                                    } else {
                                        statusText = "无效路径: 请输入类似 C:\\ 或 C:\\Users 的完整路径"
                                        pathInput.focus = false
                                        return
                                    }
                                }
                                var navigated = scanEngine.navigateToPath(normalized)
                                if (!navigated) {
                                    startScan(normalized, false)
                                }
                                pathInput.focus = false
                            }

                            Keys.onEscapePressed: {
                                pathInput.text = currentScanPath || ""
                                pathInput.color = currentScanPath ? theme.textPrimary : theme.textDisabled
                                pathInput.focus = false
                            }
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
                onRequestDeleteDialog: function(path, name, risk) {
                    pendingDeletePath = path
                    deleteDialog.dialogName = name
                    deleteDialog.dialogRiskInfo = risk
                    deleteDialog.dialogVisible = true
                    if (!pathRiskProvider.hasCachedResult(path)) {
                        pathRiskProvider.requestRiskInfo(path)
                    }
                }
            }

            Connections {
                target: pathRiskProvider
                function onRiskInfoReady(path, info) {
                    if (deleteDialog.dialogVisible && path === pendingDeletePath) {
                        deleteDialog.dialogRiskInfo = info
                    }
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
