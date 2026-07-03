import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QuickSpaceScan 1.0
import "../themes"

Rectangle {
    id: settingsDialog
    property bool dialogVisible: false
    property int currentPage: 0

    property string tempApiUrl: pathRiskProvider.apiUrl
    property string tempApiKey: pathRiskProvider.apiKey
    property string tempModel: pathRiskProvider.model
    property string tempEngine: pathRiskProvider.engine
    property bool tempAiEnabled: pathRiskProvider.aiEnabled
    property string tempThemeName: appSettings.themeName
    property string savedThemeName: appSettings.themeName

    anchors.fill: parent
    z: 1001
    visible: dialogVisible
    color: theme.isDarkTheme ? Qt.rgba(0, 0, 0, 0.65) : Qt.rgba(0, 0, 0, 0.45)

    function loadCurrentValues() {
        tempApiUrl = pathRiskProvider.apiUrl
        tempApiKey = pathRiskProvider.apiKey
        tempModel = pathRiskProvider.model
        tempEngine = pathRiskProvider.engine
        tempAiEnabled = pathRiskProvider.aiEnabled
        tempThemeName = appSettings.themeName
        savedThemeName = appSettings.themeName
        currentPage = 0
    }

    function previewTheme(name) {
        tempThemeName = name
        theme.themeName = name
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        hoverEnabled: true
        cursorShape: Qt.ArrowCursor
        onPressed: function(mouse) { mouse.accepted = true; }
        onReleased: function(mouse) { mouse.accepted = true; }
        onClicked: {}
        onDoubleClicked: {}
        onPressAndHold: {}
        onWheel: function(wheel) { wheel.accepted = true; }
        onPositionChanged: function(mouse) { mouse.accepted = true; }
        onEntered: {}
        onExited: {}
        preventStealing: true
    }

    Rectangle {
        id: dialogBox
        width: 620
        height: 420
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        radius: theme.cornerRadiusLarge
        color: theme.elevatedSurface
        border.color: theme.borderColor
        border.width: 1
        clip: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                height: 48
                color: "transparent"

                Text {
                    text: "设置"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: theme.textPrimary
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: theme.cornerRadiusSmall
                    color: closeBtnArea.containsMouse ? theme.hoverColor : "transparent"
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "✕"
                        font.pixelSize: 14
                        color: theme.textSecondary
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: closeBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton
                        onClicked: cancelSettings()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: theme.dividerColor
            }

            Row {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                Rectangle {
                    width: 160
                    height: parent.height
                    color: theme.backgroundColor

                    Column {
                        anchors.fill: parent
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8

                        Repeater {
                            model: ["外观", "AI搜索"]
                            delegate: Rectangle {
                                width: parent.width
                                height: 40
                                color: currentPage === index ? theme.activeColor : "transparent"
                                border.width: 0

                                Rectangle {
                                    visible: currentPage === index
                                    width: 3
                                    height: 20
                                    radius: 1.5
                                    color: theme.accentColor
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData
                                    font.pixelSize: 13
                                    color: currentPage === index ? theme.accentColor : theme.textPrimary
                                    anchors.left: parent.left
                                    anchors.leftMargin: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: currentPage = index
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: 1
                    height: parent.height
                    color: theme.dividerColor
                }

                ColumnLayout {
                    width: parent.width - 161
                    height: parent.height
                    spacing: 0

                    StackLayout {
                        id: contentStack
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        currentIndex: currentPage

                        ScrollView {
                            id: appearanceScroll
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            contentWidth: appearanceCol.width
                            contentHeight: appearanceCol.height

                            Column {
                                id: appearanceCol
                                width: appearanceScroll.availableWidth - 20
                                spacing: 16
                                x: 20
                                y: 20

                                Text {
                                    text: "主题"
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    color: theme.textPrimary
                                }

                                Grid {
                                    columns: 3
                                    spacing: 12

                                    Repeater {
                                        model: [
                                            { key: "dark",    name: "深色主题", bg: "#202020", fg: "#ffffff", accent: "#60cdff" },
                                            { key: "light",   name: "浅色主题", bg: "#ffffff", fg: "#1a1a1a", accent: "#0078d4" },
                                            { key: "pink",    name: "淡粉主题", bg: "#fdf4f8", fg: "#1a1a1a", accent: "#e85a9f" },
                                            { key: "purple",  name: "淡紫主题", bg: "#f7f4fd", fg: "#1a1a1a", accent: "#8b5cf6" },
                                            { key: "yellow",  name: "淡黄主题", bg: "#fdf9ef", fg: "#1a1a1a", accent: "#c8961e" }
                                        ]
                                        delegate: Rectangle {
                                            width: 120
                                            height: 80
                                            radius: theme.cornerRadiusSmall
                                            color: tempThemeName === modelData.key
                                                ? Qt.rgba(parseInt(modelData.accent.slice(1,3),16)/255,
                                                         parseInt(modelData.accent.slice(3,5),16)/255,
                                                         parseInt(modelData.accent.slice(5,7),16)/255, 0.12)
                                                : "transparent"
                                            border.color: tempThemeName === modelData.key ? modelData.accent : theme.controlStroke
                                            border.width: tempThemeName === modelData.key ? 2 : 1

                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: previewTheme(modelData.key)
                                            }

                                            Column {
                                                anchors.centerIn: parent
                                                spacing: 6

                                                Rectangle {
                                                    width: 56
                                                    height: 32
                                                    radius: 4
                                                    color: modelData.bg
                                                    border.color: modelData.key === "light" || modelData.key === "pink" || modelData.key === "purple" || modelData.key === "yellow" ? "#e0e0e0" : "#404040"
                                                    border.width: 1
                                                    Rectangle {
                                                        width: 10; height: 10; radius: 5
                                                        color: modelData.accent
                                                        x: 6; y: 6
                                                    }
                                                    Rectangle {
                                                        width: 28; height: 4; radius: 2
                                                        color: modelData.accent
                                                        opacity: 0.5
                                                        x: 6; y: 20
                                                    }
                                                }

                                                Text {
                                                    text: modelData.name
                                                    font.pixelSize: 12
                                                    color: theme.textPrimary
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        ScrollView {
                            id: aiScroll
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            contentWidth: aiCol.width
                            contentHeight: aiCol.height

                            Column {
                                id: aiCol
                                width: aiScroll.availableWidth - 40
                                spacing: 14
                                x: 20
                                y: 20

                                Row {
                                    spacing: 8
                                    Text {
                                        text: "启用AI搜索"
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                        color: theme.textPrimary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Item { width: 8; height: 1 }

                                    Rectangle {
                                        id: aiSwitch
                                        width: 40
                                        height: 22
                                        radius: 11
                                        color: tempAiEnabled ? theme.accentColor : theme.controlStroke
                                        anchors.verticalCenter: parent.verticalCenter

                                        MouseArea {
                                            id: switchArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: tempAiEnabled = !tempAiEnabled
                                        }

                                        Rectangle {
                                            width: 18
                                            height: 18
                                            radius: 9
                                            color: "#fff"
                                            anchors.verticalCenter: parent.verticalCenter
                                            x: tempAiEnabled ? parent.width - width - 2 : 2
                                            Behavior on x { NumberAnimation { duration: 150 } }
                                        }
                                    }

                                    Rectangle {
                                        id: helpBtn
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: helpBtnArea.containsMouse ? theme.hoverColor : "transparent"
                                        border.color: theme.controlStroke
                                        border.width: 1
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            text: "?"
                                            font.pixelSize: 12
                                            font.weight: Font.Bold
                                            color: theme.textSecondary
                                            anchors.centerIn: parent
                                        }

                                        MouseArea {
                                            id: helpBtnArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                        }

                                        ToolTip {
                                            visible: helpBtnArea.containsMouse
                                            text: "通过AI搜索文件夹作用，判断文件删除对电脑的影响"
                                            delay: 200
                                            timeout: 5000
                                        }
                                    }
                                }

                                Column {
                                    width: parent.width
                                    spacing: 10
                                    opacity: tempAiEnabled ? 1.0 : 0.4
                                    enabled: tempAiEnabled

                                    Row {
                                        width: parent.width
                                        spacing: 10

                                        Text {
                                            text: "引擎选择"
                                            font.pixelSize: 13
                                            color: theme.textPrimary
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 80
                                        }

                                        ComboBox {
                                            id: engineCombo
                                            width: parent.width - 90
                                            height: 32
                                            model: ["火山引擎"]
                                            font.pixelSize: 13
                                            currentIndex: 0

                                            background: Rectangle {
                                                radius: theme.cornerRadiusSmall
                                                color: theme.controlBackground
                                                border.color: engineCombo.hovered ? theme.textSecondary : theme.controlStroke
                                                border.width: 1
                                            }

                                            contentItem: Text {
                                                text: engineCombo.displayText
                                                font: engineCombo.font
                                                color: theme.textPrimary
                                                verticalAlignment: Text.AlignVCenter
                                                leftPadding: 8
                                                rightPadding: engineCombo.indicator.width + 8
                                            }

                                            indicator: Canvas {
                                                x: engineCombo.width - width - 8
                                                y: engineCombo.height / 2 - height / 2
                                                implicitWidth: 12
                                                implicitHeight: 8
                                                onPaint: {
                                                    var ctx = getContext("2d");
                                                    ctx.reset();
                                                    ctx.fillStyle = theme.textSecondary;
                                                    ctx.moveTo(0, 0);
                                                    ctx.lineTo(width, 0);
                                                    ctx.lineTo(width / 2, height);
                                                    ctx.closePath();
                                                    ctx.fill();
                                                }
                                            }

                                            popup: Popup {
                                                y: engineCombo.height + 2
                                                width: engineCombo.width
                                                padding: 4
                                                background: Rectangle {
                                                    radius: theme.cornerRadiusSmall
                                                    color: theme.elevatedSurface
                                                    border.color: theme.controlStroke
                                                    border.width: 1
                                                }
                                                contentItem: ListView {
                                                    id: comboPopupList
                                                    clip: true
                                                    implicitHeight: contentHeight
                                                    model: engineCombo.popup.visible ? engineCombo.delegateModel : null
                                                    currentIndex: engineCombo.highlightedIndex
                                                    ScrollIndicator.vertical: ScrollIndicator { }
                                                }
                                            }

                                            delegate: Item {
                                                width: engineCombo.width
                                                height: 30

                                                Rectangle {
                                                    anchors.fill: parent
                                                    anchors.margins: 2
                                                    radius: theme.cornerRadiusSmall
                                                    color: (comboPopupList.currentIndex === index || comboHover.containsMouse) ? theme.hoverColor : "transparent"
                                                }

                                                Text {
                                                    text: modelData
                                                    font: engineCombo.font
                                                    color: theme.textPrimary
                                                    anchors.left: parent.left
                                                    anchors.leftMargin: 8
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                MouseArea {
                                                    id: comboHover
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onClicked: {
                                                        engineCombo.currentIndex = index
                                                        engineCombo.popup.close()
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: 10

                                        Text {
                                            text: "API地址"
                                            font.pixelSize: 13
                                            color: theme.textPrimary
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 80
                                        }

                                        TextField {
                                            id: apiUrlField
                                            width: parent.width - 90
                                            height: 32
                                            text: tempApiUrl
                                            font.pixelSize: 13
                                            color: theme.textPrimary
                                            placeholderText: "请输入API地址"
                                            selectByMouse: true
                                            placeholderTextColor: theme.textMuted
                                            onTextEdited: tempApiUrl = text
                                            background: Rectangle {
                                                radius: theme.cornerRadiusSmall
                                                color: theme.controlBackground
                                                border.color: parent.activeFocus ? theme.accentColor : theme.controlStroke
                                                border.width: parent.activeFocus ? 2 : 1
                                            }
                                            leftPadding: 8
                                            rightPadding: 8
                                            topPadding: 0
                                            bottomPadding: 0
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: 10

                                        Text {
                                            text: "模型"
                                            font.pixelSize: 13
                                            color: theme.textPrimary
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 80
                                        }

                                        TextField {
                                            id: modelField
                                            width: parent.width - 90
                                            height: 32
                                            text: tempModel
                                            font.pixelSize: 13
                                            color: theme.textPrimary
                                            placeholderText: "请输入模型名称"
                                            selectByMouse: true
                                            placeholderTextColor: theme.textMuted
                                            onTextEdited: tempModel = text
                                            background: Rectangle {
                                                radius: theme.cornerRadiusSmall
                                                color: theme.controlBackground
                                                border.color: parent.activeFocus ? theme.accentColor : theme.controlStroke
                                                border.width: parent.activeFocus ? 2 : 1
                                            }
                                            leftPadding: 8
                                            rightPadding: 8
                                            topPadding: 0
                                            bottomPadding: 0
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: 10

                                        Text {
                                            text: "API Key"
                                            font.pixelSize: 13
                                            color: theme.textPrimary
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 80
                                        }

                                        TextField {
                                            id: apiKeyField
                                            width: parent.width - 90
                                            height: 32
                                            text: tempApiKey
                                            font.pixelSize: 13
                                            color: theme.textPrimary
                                            placeholderText: "请输入API Key"
                                            echoMode: TextInput.Password
                                            selectByMouse: true
                                            placeholderTextColor: theme.textMuted
                                            onTextEdited: tempApiKey = text
                                            background: Rectangle {
                                                radius: theme.cornerRadiusSmall
                                                color: theme.controlBackground
                                                border.color: parent.activeFocus ? theme.accentColor : theme.controlStroke
                                                border.width: parent.activeFocus ? 2 : 1
                                            }
                                            leftPadding: 8
                                            rightPadding: 8
                                            topPadding: 0
                                            bottomPadding: 0
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }

                                Text {
                                    visible: !tempAiEnabled || (!tempApiKey || !tempModel)
                                    text: tempAiEnabled ? "提示：请填写完整的API Key和模型信息以启用AI搜索" : "AI搜索已关闭，将仅使用本地规则判断风险"
                                    font.pixelSize: 12
                                    color: theme.textSecondary
                                    wrapMode: Text.WordWrap
                                    width: parent.width
                                    opacity: 0.7
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: theme.dividerColor
                    }

                    Item {
                        Layout.fillWidth: true
                        height: 52
                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            anchors.rightMargin: 20
                            spacing: 8
                            layoutDirection: Qt.RightToLeft

                            Rectangle {
                                id: saveBtn
                                implicitWidth: saveBtnText.implicitWidth + 32
                                height: 32
                                radius: theme.cornerRadiusSmall
                                color: saveBtnArea.pressed ? "#106ebe" : (saveBtnArea.containsMouse ? "#1682d9" : theme.accentColor)

                                Text {
                                    id: saveBtnText
                                    text: "保存"
                                    font.pixelSize: 13
                                    color: "#ffffff"
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    id: saveBtnArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.LeftButton
                                    onClicked: saveSettings()
                                }
                            }

                            Rectangle {
                                id: cancelBtn
                                implicitWidth: cancelBtnText.implicitWidth + 32
                                height: 32
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
                                    onClicked: cancelSettings()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function saveSettings() {
        appSettings.themeName = tempThemeName
        appSettings.save()

        pathRiskProvider.aiEnabled = tempAiEnabled
        pathRiskProvider.apiUrl = tempApiUrl
        pathRiskProvider.apiKey = tempApiKey
        pathRiskProvider.model = tempModel
        pathRiskProvider.engine = tempEngine
        pathRiskProvider.saveConfig()
        pathRiskProvider.clearCache()

        dialogVisible = false
    }

    function cancelSettings() {
        theme.themeName = savedThemeName
        loadCurrentValues()
        dialogVisible = false
    }
}
