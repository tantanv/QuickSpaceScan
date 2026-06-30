import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../themes"

Rectangle {
    id: root
    property var itemData: null
    property int indent: 0
    property bool isExpanded: itemData ? itemData.item.expanded : false
    property bool hasChildren: itemData ? itemData.item.childCount > 0 : false
    property bool isDir: itemData ? itemData.item.isDir : false
    property int itemLevel: itemData ? itemData.level : 0

    height: 36
    color: mouseArea.containsMouse ? theme.hoverColor : "transparent"
    radius: 4

    signal toggleExpand()

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16 + indent
        anchors.rightMargin: 16
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            radius: 4
            color: hasChildren ? theme.surfaceColor : "transparent"
            visible: hasChildren

            Rectangle {
                anchors.centerIn: parent
                width: 8
                height: 8
                radius: 2
                color: theme.textMuted

                rotation: isExpanded ? 90 : 0

                Behavior on rotation {
                    NumberAnimation { duration: 150 }
                }

                Canvas {
                    anchors.centerIn: parent
                    width: 8
                    height: 8
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.fillStyle = parent.color
                        ctx.beginPath()
                        if (isExpanded) {
                            ctx.moveTo(2, 1)
                            ctx.lineTo(6, 4)
                            ctx.lineTo(2, 7)
                        } else {
                            ctx.moveTo(1, 2)
                            ctx.lineTo(4, 6)
                            ctx.lineTo(7, 2)
                        }
                        ctx.closePath()
                        ctx.fill()
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    toggleExpand()
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: hasChildren ? 4 : 24
            Layout.preferredHeight: 1
            visible: !hasChildren
        }

        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 4

            color: isDir ? theme.primaryColor : theme.textMuted

            Label {
                anchors.centerIn: parent
                text: isDir ? "📁" : "📄"
                font.pixelSize: 14
            }
        }

        Label {
            text: itemData ? itemData.item.name : ""
            font.pixelSize: 13
            color: theme.textPrimary
            elide: Text.ElideMiddle

            Layout.preferredWidth: 280
        }

        Label {
            text: itemData ? itemData.item.formattedSize : ""
            font.pixelSize: 13
            color: theme.textSecondary

            Layout.preferredWidth: 100
            horizontalAlignment: Text.AlignRight
        }

        Item { Layout.preferredWidth: 20 }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 16
            radius: 3
            color: theme.progressBarBg

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                radius: 3
                color: theme.getChartColor(itemLevel)

                width: parent.width * ((itemData && itemData.item.size > 0) ? (itemData.item.size / getMaxSize()) : 0)
            }
        }

        Label {
            text: itemData ? (itemData.item.percentage).toFixed(1) + "%" : ""
            font.pixelSize: 11
            color: theme.textMuted

            Layout.preferredWidth: 50
            Layout.leftMargin: 8
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: {
            if (hasChildren && mouse.x < 50) {
                toggleExpand()
            }
        }
    }

    function getMaxSize() {
        if (!itemData || !itemData.item) return 1
        var size = itemData.item.size
        return size > 0 ? size : 1
    }
}
