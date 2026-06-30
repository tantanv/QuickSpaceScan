import QtQuick

// 白色主题配置
QtObject {
    id: lightTheme

    // 主色调
    property color primaryColor: "#4f46e5"
    property color secondaryColor: "#6366f1"
    property color accentColor: "#06b6d4"

    // 背景色
    property color backgroundColor: "#f8fafc"
    property color surfaceColor: "#ffffff"
    property color cardColor: "#ffffff"

    // 文字颜色
    property color textPrimary: "#0f172a"
    property color textSecondary: "#64748b"
    property color textMuted: "#94a3b8"

    // 边框
    property color borderColor: "#e2e8f0"
    property color dividerColor: "#f1f5f9"

    // 状态栏
    property color statusBarBg: "#1e293b"
    property color statusBarText: "#ffffff"

    // 进度条
    property color progressBarBg: "#e2e8f0"
    property color progressBarFill: "#4f46e5"

    // 悬停和选中
    property color hoverColor: "#f1f5f9"
    property color selectedColor: "#e0e7ff"
    property color activeColor: "#c7d2fe"

    // 图表颜色
    property list<color> chartColors: [
        "#4f46e5", "#0891b2", "#db2777", "#16a34a",
        "#ea580c", "#ca8a04", "#7c3aed", "#0d9488"
    ]
}
