import QtQuick

QtObject {
    id: themeManager

    property string themeName: "light"

    readonly property bool isDarkTheme: themeName === "dark"

    property var themeDefs: ({
        "dark": {
            primaryColor: "#60cdff",
            secondaryColor: "#74d3ff",
            accentColor: "#60cdff",
            backgroundColor: "#202020",
            surfaceColor: "#2b2b2b",
            cardColor: "#2b2b2b",
            elevatedSurface: "#323232",
            textPrimary: "#ffffff",
            textSecondary: "#c5c5c5",
            textMuted: "#8a8a8a",
            textDisabled: "#5a5a5a",
            borderColor: "#292929",
            dividerColor: "#383838",
            controlStroke: "#4f4f4f",
            controlBackground: "#1f1f1f",
            statusBarBg: "#1b1b1b",
            statusBarText: "#a0a0a0",
            progressBarBg: "#3d3d3d",
            progressBarFill: "#60cdff",
            hoverColor: "#3a3a3a",
            selectedColor: Qt.rgba(96/255,205/255,255/255,0.2),
            activeColor: Qt.rgba(96/255,205/255,255/255,0.3),
            pressedColor: "#454545",
            successColor: "#6ccb5f",
            warningColor: "#fce100",
            chartColors: ["#60cdff", "#5fd07a", "#ffb454", "#ff8ea0", "#c495ff", "#fce100", "#ff7e65", "#4aecec"]
        },
        "light": {
            primaryColor: "#0067c0",
            secondaryColor: "#1985e0",
            accentColor: "#0078d4",
            backgroundColor: "#f3f3f3",
            surfaceColor: "#ffffff",
            cardColor: "#ffffff",
            elevatedSurface: "#ffffff",
            textPrimary: "#1a1a1a",
            textSecondary: "#5c5c5c",
            textMuted: "#8e8e8e",
            textDisabled: "#b8b8b8",
            borderColor: "#e5e5e5",
            dividerColor: "#f0f0f0",
            controlStroke: "#d0d0d0",
            controlBackground: "#fafafa",
            statusBarBg: "#f9f9f9",
            statusBarText: "#5c5c5c",
            progressBarBg: "#e6e6e6",
            progressBarFill: "#0078d4",
            hoverColor: "#f5f5f5",
            selectedColor: Qt.rgba(0/255,120/255,212/255,0.08),
            activeColor: Qt.rgba(0/255,120/255,212/255,0.15),
            pressedColor: "#ebebeb",
            successColor: "#107c10",
            warningColor: "#ffb900",
            chartColors: ["#0078d4", "#107c10", "#d83b01", "#e81123", "#5c2d91", "#ff8c00", "#008272", "#b4009e"]
        },
        "pink": {
            primaryColor: "#c2185b",
            secondaryColor: "#d84378",
            accentColor: "#e85a9f",
            backgroundColor: "#fdf4f8",
            surfaceColor: "#ffffff",
            cardColor: "#ffffff",
            elevatedSurface: "#ffffff",
            textPrimary: "#1a1a1a",
            textSecondary: "#5c5c5c",
            textMuted: "#8e8e8e",
            textDisabled: "#d4b8c6",
            borderColor: "#f0dce6",
            dividerColor: "#f8ebf1",
            controlStroke: "#e0c0d0",
            controlBackground: "#fef7fa",
            statusBarBg: "#fdf4f8",
            statusBarText: "#5c5c5c",
            progressBarBg: "#f5e0ea",
            progressBarFill: "#e85a9f",
            hoverColor: "#fceff5",
            selectedColor: Qt.rgba(232/255,90/255,159/255,0.1),
            activeColor: Qt.rgba(232/255,90/255,159/255,0.18),
            pressedColor: "#f8e0ec",
            successColor: "#107c10",
            warningColor: "#ffb900",
            chartColors: ["#e85a9f", "#107c10", "#d83b01", "#e81123", "#9c27b0", "#ff8c00", "#008272", "#795548"]
        },
        "purple": {
            primaryColor: "#6a3cbf",
            secondaryColor: "#8257e0",
            accentColor: "#8b5cf6",
            backgroundColor: "#f7f4fd",
            surfaceColor: "#ffffff",
            cardColor: "#ffffff",
            elevatedSurface: "#ffffff",
            textPrimary: "#1a1a1a",
            textSecondary: "#5c5c5c",
            textMuted: "#8e8e8e",
            textDisabled: "#c6bde0",
            borderColor: "#e3dcf2",
            dividerColor: "#f0ebf8",
            controlStroke: "#d0c4e8",
            controlBackground: "#faf8fe",
            statusBarBg: "#f7f4fd",
            statusBarText: "#5c5c5c",
            progressBarBg: "#e4daf7",
            progressBarFill: "#8b5cf6",
            hoverColor: "#f1ebfc",
            selectedColor: Qt.rgba(139/255,92/255,246/255,0.1),
            activeColor: Qt.rgba(139/255,92/255,246/255,0.18),
            pressedColor: "#e8dff9",
            successColor: "#107c10",
            warningColor: "#ffb900",
            chartColors: ["#8b5cf6", "#107c10", "#d83b01", "#e81123", "#e85a9f", "#ff8c00", "#008272", "#5c2d91"]
        },
        "yellow": {
            primaryColor: "#a67c00",
            secondaryColor: "#c4961a",
            accentColor: "#c8961e",
            backgroundColor: "#fdf9ef",
            surfaceColor: "#ffffff",
            cardColor: "#ffffff",
            elevatedSurface: "#ffffff",
            textPrimary: "#1a1a1a",
            textSecondary: "#5c5c5c",
            textMuted: "#8e8e8e",
            textDisabled: "#d9c9a2",
            borderColor: "#efe5c8",
            dividerColor: "#f8f2df",
            controlStroke: "#e0d0a0",
            controlBackground: "#fefcf5",
            statusBarBg: "#fdf9ef",
            statusBarText: "#5c5c5c",
            progressBarBg: "#f0e4c0",
            progressBarFill: "#c8961e",
            hoverColor: "#fcf5e2",
            selectedColor: Qt.rgba(200/255,150/255,30/255,0.1),
            activeColor: Qt.rgba(200/255,150/255,30/255,0.18),
            pressedColor: "#f7edcd",
            successColor: "#107c10",
            warningColor: "#c8961e",
            chartColors: ["#c8961e", "#107c10", "#d83b01", "#e81123", "#8b5cf6", "#e85a9f", "#008272", "#5c2d91"]
        }
    })

    property var _t: themeDefs[themeName] || themeDefs["light"]

    property font systemFont: Qt.font({
        family: "Segoe UI Variable, Segoe UI, Microsoft YaHei UI, sans-serif",
        pixelSize: 14,
        weight: Font.Normal
    })

    property color primaryColor: _t.primaryColor
    property color secondaryColor: _t.secondaryColor
    property color accentColor: _t.accentColor

    property color backgroundColor: _t.backgroundColor
    property color surfaceColor: _t.surfaceColor
    property color cardColor: _t.cardColor
    property color elevatedSurface: _t.elevatedSurface

    property color textPrimary: _t.textPrimary
    property color textSecondary: _t.textSecondary
    property color textMuted: _t.textMuted
    property color textOnPrimary: "#ffffff"
    property color textDisabled: _t.textDisabled

    property color borderColor: _t.borderColor
    property color dividerColor: _t.dividerColor
    property color controlStroke: _t.controlStroke
    property color controlBackground: _t.controlBackground

    property color statusBarBg: _t.statusBarBg
    property color statusBarText: _t.statusBarText

    property color progressBarBg: _t.progressBarBg
    property color progressBarFill: _t.progressBarFill

    property color hoverColor: _t.hoverColor
    property color selectedColor: _t.selectedColor
    property color activeColor: _t.activeColor
    property color pressedColor: _t.pressedColor

    property color dangerColor: "#c42b1c"
    property color successColor: _t.successColor
    property color warningColor: _t.warningColor

    property var chartColors: _t.chartColors

    property int cornerRadiusSmall: 4
    property int cornerRadiusMedium: 8
    property int cornerRadiusLarge: 12

    property int spacingXS: 4
    property int spacingS: 8
    property int spacingM: 12
    property int spacingL: 16
    property int spacingXL: 24

    function setTheme(name) {
        if (themeDefs[name]) {
            themeName = name
        }
    }

    function getChartColor(index) {
        return chartColors[index % chartColors.length]
    }
}
