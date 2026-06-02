// Theme.qml
pragma Singleton
import QtQuick 2.0

QtObject {
    // Primary Colors
    readonly property color primaryPurple: "#4b2ac0"
    readonly property color primaryLightPurple: "#a78bfa"
    readonly property color primaryDarkPurple: "#3b1e99"

    // Background Colors
    readonly property color backgroundDark: "#0a0a0f"
    readonly property color backgroundMedium: "#0f0f1a"
    readonly property color backgroundLight: "#1a1a2e"

    // Glass Effects
    readonly property color glassBackground: Qt.rgba(255, 255, 255, 0.08)
    readonly property color glassBorder: Qt.rgba(255, 255, 255, 0.15)
    readonly property color glassHover: Qt.rgba(255, 255, 255, 0.05)

    // Selection Colors
    readonly property color selectionBackground: Qt.rgba(75, 42, 192, 0.15)
    readonly property color selectionBorder: Qt.rgba(75, 42, 192, 0.3)
    readonly property color selectionGlow: "#4b2ac0"

    // Text Colors
    readonly property color textPrimary: "#ffffff"
    readonly property color textSecondary: Qt.rgba(255, 255, 255, 0.6)
    readonly property color textTertiary: Qt.rgba(255, 255, 255, 0.4)
    readonly property color textHighlight: "#a78bfa"

    // Status Colors
    readonly property color statusActive: "#10b981"
    readonly property color statusActiveLight: "#34d399"
    readonly property color statusWarning: "#f59e0b"
    readonly property color statusError: "#ef4444"

    // UI Elements
    readonly property color logoUnderline: Qt.rgba(255, 255, 255, 0.6)
    readonly property color cardBackground: Qt.rgba(255, 255, 255, 0.06)
    readonly property color cardBorder: Qt.rgba(255, 255, 255, 0.1)
    readonly property color codeBackground: Qt.rgba(0, 0, 0, 0.4)
    readonly property color codeText: "#86efac"

    // Gradients
    property Gradient backgroundGradient: Gradient {
        GradientStop { position: 0.0; color: "#0a0a0f" }
        GradientStop { position: 0.3; color: "#0f0f1a" }
        GradientStop { position: 0.7; color: "#0a0a14" }
        GradientStop { position: 1.0; color: "#06060a" }
    }

    property Gradient titleBarGradient: Gradient {
        GradientStop { position: 0.0; color: Qt.rgba(75, 42, 192, 0.25) }
        GradientStop { position: 1.0; color: Qt.rgba(75, 42, 192, 0.1) }
    }
}
