import QtQuick

QtObject {
    id: themeManager

    property bool isDarkTheme: false

    property font systemFont: Qt.font({
        family: "Segoe UI Variable, Segoe UI, Microsoft YaHei UI, sans-serif",
        pixelSize: 14,
        weight: Font.Normal
    })

    property color primaryColor: isDarkTheme ? "#60cdff" : "#0067c0"
    property color secondaryColor: isDarkTheme ? "#74d3ff" : "#1985e0"
    property color accentColor: isDarkTheme ? "#60cdff" : "#0078d4"

    property color backgroundColor: isDarkTheme ? "#202020" : "#f3f3f3"
    property color surfaceColor: isDarkTheme ? "#2b2b2b" : "#ffffff"
    property color cardColor: isDarkTheme ? "#2b2b2b" : "#ffffff"
    property color elevatedSurface: isDarkTheme ? "#323232" : "#ffffff"

    property color textPrimary: isDarkTheme ? "#ffffff" : "#1a1a1a"
    property color textSecondary: isDarkTheme ? "#c5c5c5" : "#5c5c5c"
    property color textMuted: isDarkTheme ? "#8a8a8a" : "#8e8e8e"
    property color textOnPrimary: "#ffffff"

    property color borderColor: isDarkTheme ? "#292929" : "#e5e5e5"
    property color dividerColor: isDarkTheme ? "#383838" : "#f0f0f0"
    property color controlStroke: isDarkTheme ? "#4f4f4f" : "#d0d0d0"

    property color statusBarBg: isDarkTheme ? "#1b1b1b" : "#f9f9f9"
    property color statusBarText: isDarkTheme ? "#a0a0a0" : "#5c5c5c"

    property color progressBarBg: isDarkTheme ? "#3d3d3d" : "#e6e6e6"
    property color progressBarFill: isDarkTheme ? "#60cdff" : "#0078d4"

    property color hoverColor: isDarkTheme ? "#3a3a3a" : "#f5f5f5"
    property color selectedColor: isDarkTheme ? "rgba(96,205,255,0.2)" : "#e5f3ff"
    property color activeColor: isDarkTheme ? "rgba(96,205,255,0.3)" : "#cce4ff"
    property color pressedColor: isDarkTheme ? "#454545" : "#ebebeb"

    property color dangerColor: "#c42b1c"
    property color successColor: isDarkTheme ? "#6ccb5f" : "#107c10"
    property color warningColor: isDarkTheme ? "#fce100" : "#ffb900"

    property var chartColors: isDarkTheme
        ? ["#60cdff", "#5fd07a", "#ffb454", "#ff8ea0", "#c495ff", "#fce100", "#ff7e65", "#4aecec"]
        : ["#0078d4", "#107c10", "#d83b01", "#e81123", "#5c2d91", "#ff8c00", "#008272", "#b4009e"]

    property int cornerRadiusSmall: 4
    property int cornerRadiusMedium: 8
    property int cornerRadiusLarge: 12

    property int spacingXS: 4
    property int spacingS: 8
    property int spacingM: 12
    property int spacingL: 16
    property int spacingXL: 24

    function toggleTheme() {
        isDarkTheme = !isDarkTheme
    }

    function getChartColor(index) {
        return chartColors[index % chartColors.length]
    }
}
