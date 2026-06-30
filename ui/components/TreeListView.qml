import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QuickSpaceScan 1.0
import "../themes"

ListView {
    id: treeListView
    property TreeItem rootItem: null
    property string currentPath: ""
    clip: true
    focus: true

    signal folderOpenRequested(string path)
    signal goUpRequested()
    signal openInExplorerRequested(string path)
    signal deletePathRequested(string path)
    signal requestDeleteDialog(string path, string name)

    property int indentSize: 20
    property var flatData: []
    property string contextMenuPath: ""
    property string contextMenuName: ""
    property string selectedPath: ""

    function rebuildFlatList() {
        var newData = []

        var parentPath = ""
        if (currentPath && currentPath.length > 3) {
            var dir = currentPath
            if (dir.endsWith("/") || dir.endsWith("\\")) dir = dir.substring(0, dir.length - 1)
            var lastSlash = Math.max(dir.lastIndexOf("/"), dir.lastIndexOf("\\"))
            if (lastSlash > 0) {
                parentPath = dir.substring(0, lastSlash + 1)
            } else if (dir.length > 2) {
                parentPath = dir.substring(0, 3)
            }
        }

        if (parentPath !== "") {
            newData.push({ "isGoUp": true, "parentPath": parentPath, "item": null, "level": 0, "percentage": 0 })
        }

        if (rootItem) {
            function getSortedChildren(item) {
                var dirs = [], files = []
                for (var i = 0; i < item.childCount; i++) {
                    var child = item.child(i)
                    if (!child) continue
                    if (child.isDir) dirs.push(child); else files.push(child)
                }
                dirs.sort(function(a, b) { return b.size - a.size })
                files.sort(function(a, b) { return b.size - a.size })
                return dirs.concat(files)
            }

            function addItem(item, level, parentSize) {
                if (!item) return
                var pct = parentSize > 0 ? Math.min((item.size / parentSize) * 100, 100) : 0
                newData.push({ "isGoUp": false, "item": item, "level": level, "percentage": pct })
                if (item.expanded) {
                    var sorted = getSortedChildren(item)
                    var itemSize = item.size > 0 ? item.size : 1
                    for (var j = 0; j < sorted.length; j++) addItem(sorted[j], level + 1, itemSize)
                }
            }

            var rootSorted = getSortedChildren(rootItem)
            var rootSize = rootItem.size > 0 ? rootItem.size : 1
            for (var m = 0; m < rootSorted.length; m++) addItem(rootSorted[m], 0, rootSize)
        }
        flatData = newData
        count = newData.length
    }

    property int count: 0

    onRootItemChanged: rebuildFlatList()
    onCurrentPathChanged: rebuildFlatList()

    Connections {
        target: rootItem
        enabled: rootItem !== null
        function onChildrenChanged() { scheduleRefresh() }
        function onSizeChanged() { scheduleRefresh() }
    }

    function scheduleRefresh() { refreshTimer.restart() }

    Timer {
        id: refreshTimer
        interval: 100
        repeat: false
        onTriggered: rebuildFlatList()
    }

    Timer {
        id: liveUpdateTimer
        interval: 150
        repeat: true
        running: rootItem !== null
        onTriggered: rebuildFlatList()
    }

    model: count

    Item {
        id: contextMenu
        property string menuPath: ""
        property string menuName: ""
        property bool menuVisible: false
        z: 1000
        visible: menuVisible
        x: 0
        y: 0
        width: treeListView.width
        height: treeListView.height

        function showAt(px, py, path, name) {
            menuPath = path
            menuName = name
            contextMenuContent.x = Math.min(px, treeListView.width - 200)
            contextMenuContent.y = py
            menuVisible = true
        }

        function hide() {
            menuVisible = false
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: contextMenu.hide()
            z: -1
        }

        Rectangle {
            id: contextMenuContent
            width: 200
            implicitHeight: col.implicitHeight + 8
            radius: theme.cornerRadiusMedium
            color: theme.elevatedSurface
            border.color: theme.borderColor
            border.width: 1
            z: 1001

            Column {
                id: col
                anchors.fill: parent
                anchors.margins: 4
                spacing: 0

                Rectangle {
                    id: openItem
                    width: parent.width
                    implicitHeight: 32
                    radius: theme.cornerRadiusSmall
                    color: openItemArea.pressed ? theme.pressedColor : (openItemArea.containsMouse ? theme.hoverColor : "transparent")

                    Text {
                        text: "从文件资源管理器中打开"
                        font.pixelSize: 13
                        color: theme.textPrimary
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    MouseArea {
                        id: openItemArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton
                        onClicked: {
                            if (contextMenu.menuPath) treeListView.openInExplorerRequested(contextMenu.menuPath)
                            contextMenu.hide()
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: theme.dividerColor
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                }

                Rectangle {
                    id: deleteItem
                    width: parent.width
                    implicitHeight: 32
                    radius: theme.cornerRadiusSmall
                    color: deleteItemArea.pressed ? theme.pressedColor : (deleteItemArea.containsMouse ? theme.hoverColor : "transparent")

                    Text {
                        text: "删除"
                        font.pixelSize: 13
                        color: theme.dangerColor
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    MouseArea {
                        id: deleteItemArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton
                        onClicked: {
                            if (contextMenu.menuPath) {
                                treeListView.requestDeleteDialog(contextMenu.menuPath, contextMenu.menuName)
                            }
                            contextMenu.hide()
                        }
                    }
                }
            }
        }
    }

    header: Item {
        width: treeListView.width
        height: 36
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 16
            spacing: 0

            Label {
                text: "名称"
                font.pixelSize: 12
                color: theme.textMuted
                Layout.preferredWidth: 300
            }
            Label {
                text: "大小"
                font.pixelSize: 12
                color: theme.textMuted
                Layout.preferredWidth: 100
                horizontalAlignment: Text.AlignRight
            }
            Item { Layout.preferredWidth: 20 }
            Label {
                text: "占比"
                font.pixelSize: 12
                color: theme.textMuted
                Layout.fillWidth: true
                Layout.leftMargin: 8
            }
        }
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: theme.dividerColor
        }
    }

    footer: Item { width: treeListView.width; height: 16 }

    delegate: Rectangle {
        id: delegateRoot
        width: treeListView.width
        height: 36
        radius: theme.cornerRadiusSmall
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        property var entry: (index < flatData.length) ? flatData[index] : null
        property bool isGoUpItem: entry ? entry.isGoUp : false
        property var currentItem: entry ? entry.item : null
        property string itemPath: currentItem ? currentItem.path : ""
        property bool isSelected: itemPath !== "" && itemPath === treeListView.selectedPath
        color: isSelected ? theme.selectedColor :
               (delegateMouseArea.pressed ? theme.pressedColor :
               (delegateMouseArea.containsMouse ? theme.hoverColor : "transparent"))

        property int currentLevel: entry ? entry.level : 0
        property bool isExpanded: currentItem ? currentItem.expanded : false
        property bool hasChildren: currentItem ? currentItem.childCount > 0 : false
        property bool isDir: isGoUpItem ? true : (currentItem ? currentItem.isDir : false)
        property real itemPercentage: entry ? entry.percentage : 0

        signal toggleExpand()

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8 + (isGoUpItem ? 0 : currentLevel * indentSize)
            anchors.rightMargin: 8
            spacing: 0

            Item {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22

                Label {
                    anchors.centerIn: parent
                    text: isGoUpItem ? "↑" : ""
                    font.pixelSize: 12
                    font.bold: true
                    color: theme.textMuted
                    visible: isGoUpItem
                }

                Text {
                    anchors.centerIn: parent
                    text: isExpanded ? "▾" : "▸"
                    font.pixelSize: 20
                    color: theme.textMuted
                    visible: !isGoUpItem && hasChildren
                    Behavior on rotation { NumberAnimation { duration: 100 } }
                }

                MouseArea {
                    anchors.fill: parent
                    visible: !isGoUpItem && hasChildren
                    onClicked: function(mouse) { delegateRoot.toggleExpand() }
                }
            }

            Rectangle {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                radius: 5
                color: isDir ? theme.primaryColor : theme.textMuted

                Label {
                    anchors.centerIn: parent
                    text: isGoUpItem ? "📁" : (isDir ? "📁" : "📄")
                    font.pixelSize: 12
                    opacity: 1
                    color: "#ffffff"
                }

            }

            Label {
                text: isGoUpItem ? ".." : (currentItem ? currentItem.name : "")
                font.pixelSize: 13
                color: isGoUpItem ? theme.primaryColor : theme.textPrimary
                font.italic: isGoUpItem
                elide: Text.ElideMiddle
                Layout.preferredWidth: 280
            }

            Label {
                text: ""
                font.pixelSize: 13
                color: theme.textSecondary
                Layout.preferredWidth: 100
                horizontalAlignment: Text.AlignRight
                visible: isGoUpItem
            }

            Label {
                text: currentItem ? currentItem.formattedSize : ""
                font.pixelSize: 13
                color: theme.textSecondary
                Layout.preferredWidth: 100
                horizontalAlignment: Text.AlignRight
                visible: !isGoUpItem
            }

            Item { Layout.preferredWidth: 16 }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 4
                radius: 2
                color: "transparent"
                visible: isGoUpItem
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 4
                radius: 2
                color: theme.progressBarBg
                visible: !isGoUpItem

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    radius: 2
                    color: theme.getChartColor(currentLevel)
                    width: parent.width * (itemPercentage / 100)
                    Behavior on width { NumberAnimation { duration: 200 } }
                }
            }

            Label {
                text: ""
                font.pixelSize: 12
                color: theme.textMuted
                Layout.preferredWidth: 50
                Layout.leftMargin: 8
                visible: isGoUpItem
            }

            Label {
                text: itemPercentage.toFixed(1) + "%"
                font.pixelSize: 12
                color: theme.textMuted
                Layout.preferredWidth: 50
                Layout.leftMargin: 8
                visible: !isGoUpItem
            }
        }

        MouseArea {
            id: delegateMouseArea
            propagateComposedEvents: true
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) {
                    if (!isGoUpItem && currentItem) {
                        treeListView.selectedPath = currentItem.path
                        var mapped = delegateRoot.mapToItem(treeListView, mouse.x, mouse.y)
                        contextMenu.showAt(mapped.x, mapped.y, currentItem.path, currentItem.name)
                    }
                    return
                }
                if (isGoUpItem) {
                    treeListView.selectedPath = ""
                    treeListView.goUpRequested()
                    return
                }
                treeListView.selectedPath = currentItem ? currentItem.path : ""
                // if (hasChildren && mouse.x < 50) delegateRoot.toggleExpand()
                mouse.accepted = false;
            }
            onDoubleClicked: function(mouse) {
                if (isGoUpItem) return
                if (currentItem && currentItem.isDir) {
                    treeListView.selectedPath = currentItem.path
                    treeListView.folderOpenRequested(currentItem.path)
                }
            }
        }

        onToggleExpand: {
            if (currentItem) {
                currentItem.expanded = !currentItem.expanded
                rebuildFlatList()
            }
        }
    }

    ScrollBar.vertical: ScrollBar {
        active: true
        policy: ScrollBar.AsNeeded
        width: 8
        anchors.rightMargin: 2
        background: Rectangle {
            radius: 4
            color: "transparent"
        }
        contentItem: Rectangle {
            radius: 4
            color: theme.controlStroke
            opacity: 0.5
        }
    }
}
