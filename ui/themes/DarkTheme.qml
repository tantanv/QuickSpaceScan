import QtQuick

// 黑色主题配置
QtObject {
    id: darkTheme

    // 主色调
    property color primaryColor: "#6366f1"
    property color secondaryColor: "#818cf8"
    property color accentColor: "#22d3ee"

    // 背景色
    property color backgroundColor: "#0f172a"
    property color surfaceColor: "#1e293b"
    property color cardColor: "#334155"

    // 文字颜色
    property color textPrimary: "#f1f5f9"
    property color textSecondary: "#94a3b8"
    property color textMuted: "#64748b"

    // 边框
    property color borderColor: "#334155"
    property color dividerColor: "#1e293b"

    // 状态栏
    property color statusBarBg: "#020617"
    property color statusBarText: "#ffffff"

    // 进度条
    property color progressBarBg: "#334155"
    property color progressBarFill: "#6366f1"

    // 悬停和选中
    property color hoverColor: "#334155"
    property color selectedColor: "#4338ca"
    property color activeColor: "#3730a3"

    // 图表颜色
    property list<color> chartColors: [
        "#6366f1", "#22d3ee", "#f472b6", "#4ade80",
        "#fb923c", "#facc15", "#a78bfa", "#2dd4bf"
    ]
}
