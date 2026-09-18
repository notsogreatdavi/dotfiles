// Stratus: tela de login do SDDM (Qt 6)
// Tokens em 11.06_visual-identity/design-system.md

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: tokens.background

    QtObject {
        id: tokens
        readonly property color background: "#0C1018"
        readonly property color surface: "#131B28"
        readonly property color elevated: "#1B2637"
        readonly property color border: "#293849"
        readonly property color text: "#C8D4E3"
        readonly property color textSecondary: "#7A90A8"
        readonly property color textMuted: "#4A5A70"
        readonly property color accent: "#6BA3E8"
        readonly property color error: "#CC6070"
        readonly property string ui: "Geist"
        readonly property string mono: "VictorMono Nerd Font"
        readonly property int radius: 5
    }

    property int sessionIndex: sessionModel.lastIndex
    // Sem último usuário (primeiro boot), cai no primeiro da lista; NameRole = Qt.UserRole + 1
    property string userName: userModel.lastUser !== ""
        ? userModel.lastUser
        : userModel.data(userModel.index(0, 0), Qt.UserRole + 1)

    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = ""
            password.placeholderText = "senha incorreta"
            password.placeholderTextColor = tokens.error
            password.forceActiveFocus()
        }
    }

    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    // ─── Relógio (canto inferior direito) ────────────────────────────────────

    Column {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 64
        spacing: 4

        Text {
            id: clock
            anchors.right: parent.right
            color: tokens.text
            font { family: tokens.ui; pixelSize: 96; weight: Font.Bold; letterSpacing: -2.9 }
            text: Qt.formatTime(new Date(), "HH:mm")
        }
        Text {
            id: date
            anchors.right: parent.right
            color: tokens.text
            opacity: 0.8
            font { family: tokens.ui; pixelSize: 18; letterSpacing: 0.4 }
            text: Qt.formatDate(new Date(), "dddd, d MMMM")
        }
        Timer {
            interval: 10000; running: true; repeat: true
            onTriggered: {
                clock.text = Qt.formatTime(new Date(), "HH:mm")
                date.text = Qt.formatDate(new Date(), "dddd, d MMMM")
            }
        }
    }

    // ─── Painel lateral ──────────────────────────────────────────────────────

    Rectangle {
        id: panel
        width: 520
        height: parent.height
        color: Qt.rgba(12 / 255, 16 / 255, 24 / 255, 0.94)

        Rectangle {
            anchors.right: parent.right
            width: 1; height: parent.height
            color: tokens.border
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 64

            // Cloud mark + wordmark
            RowLayout {
                spacing: 16

                Shape {
                    width: 60; height: 26
                    preferredRendererType: Shape.CurveRenderer
                    ShapePath {
                        strokeColor: tokens.accent; strokeWidth: 1.5; fillColor: "transparent"
                        capStyle: ShapePath.RoundCap; joinStyle: ShapePath.RoundJoin
                        PathSvg { path: "M4 20H56C59 20 60 17 57 15C57 11 52 10 49 12C47 7 40 6 36 9C33 5 25 5 22 9C18 7 12 9 12 13C7 13 3 16 4 20Z" }
                    }
                    ShapePath {
                        strokeColor: Qt.alpha(tokens.accent, 0.6); strokeWidth: 1; fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        PathSvg { path: "M12 24.5H48" }
                    }
                    ShapePath {
                        strokeColor: Qt.alpha(tokens.accent, 0.5); strokeWidth: 0.9; fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        PathSvg { path: "M26 6.5C29 4.5 33 4.5 35 6" }
                    }
                }
                Text {
                    text: "stratus"
                    color: tokens.textSecondary
                    font { family: tokens.ui; pixelSize: 18; letterSpacing: -0.2 }
                }
            }

            Item { Layout.fillHeight: true }

            // Usuário
            RowLayout {
                spacing: 16

                Rectangle {
                    width: 64; height: 64; radius: 32
                    color: tokens.elevated
                    border { color: tokens.border; width: 1 }
                    Text {
                        anchors.centerIn: parent
                        text: root.userName.charAt(0).toUpperCase()
                        color: tokens.textSecondary
                        font { family: tokens.ui; pixelSize: 26; weight: Font.DemiBold }
                    }
                }
                Column {
                    spacing: 2
                    Text {
                        text: root.userName
                        color: tokens.text
                        font { family: tokens.ui; pixelSize: 24; weight: Font.DemiBold; letterSpacing: -0.5 }
                    }
                    Text {
                        text: sddm.hostName
                        color: tokens.textSecondary
                        font { family: tokens.mono; pixelSize: 13 }
                    }
                }
            }

            Item { Layout.preferredHeight: 32 }

            // Senha
            Text {
                text: "SENHA"
                color: tokens.textSecondary
                font { family: tokens.ui; pixelSize: 12; letterSpacing: 0.24 }
            }
            Item { Layout.preferredHeight: 8 }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                TextField {
                    id: password
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    echoMode: TextInput.Password
                    focus: true
                    color: tokens.text
                    placeholderTextColor: tokens.textMuted
                    font { family: tokens.mono; pixelSize: 16 }
                    leftPadding: 16
                    background: Rectangle {
                        color: tokens.surface
                        radius: tokens.radius
                        border { width: 1; color: password.activeFocus ? tokens.accent : tokens.border }
                    }
                    onTextEdited: placeholderTextColor = tokens.textMuted
                    onAccepted: sddm.login(root.userName, password.text, root.sessionIndex)
                }

                Button {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    Accessible.name: "Entrar"
                    onClicked: sddm.login(root.userName, password.text, root.sessionIndex)
                    contentItem: Text {
                        text: "󰁔"
                        color: tokens.background
                        font { family: tokens.mono; pixelSize: 20 }
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle { color: tokens.accent; radius: tokens.radius }
                }
            }

            Item { Layout.preferredHeight: 32 }

            // Sessão e layout de teclado
            RowLayout {
                Layout.fillWidth: true

                ComboBox {
                    id: session
                    Layout.preferredHeight: 36
                    model: sessionModel
                    textRole: "name"
                    currentIndex: root.sessionIndex
                    onActivated: root.sessionIndex = currentIndex
                    font { family: tokens.ui; pixelSize: 13 }
                    contentItem: Text {
                        leftPadding: 12
                        text: session.displayText
                        color: tokens.text
                        font: session.font
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        implicitWidth: 140
                        color: tokens.surface
                        radius: tokens.radius
                        border { width: 1; color: tokens.border }
                    }
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: keyboard.layouts.length > 0 ? keyboard.layouts[keyboard.currentLayout].shortName : ""
                    color: tokens.textSecondary
                    font { family: tokens.mono; pixelSize: 12 }
                }
            }

            Item { Layout.fillHeight: true }

            Rectangle { Layout.fillWidth: true; height: 1; color: tokens.border }
            Item { Layout.preferredHeight: 24 }

            // Energia
            RowLayout {
                spacing: 8
                Repeater {
                    model: [
                        { glyph: "󰤄", label: "Suspender", action: function() { sddm.suspend() }, danger: false, enabled: sddm.canSuspend },
                        { glyph: "󰑓", label: "Reiniciar", action: function() { sddm.reboot() }, danger: false, enabled: sddm.canReboot },
                        { glyph: "󰐥", label: "Desligar", action: function() { sddm.powerOff() }, danger: true, enabled: sddm.canPowerOff }
                    ]
                    delegate: Button {
                        required property var modelData
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        visible: modelData.enabled
                        Accessible.name: modelData.label
                        onClicked: modelData.action()
                        contentItem: Text {
                            text: modelData.glyph
                            color: modelData.danger ? tokens.error : tokens.textSecondary
                            font { family: tokens.mono; pixelSize: 18 }
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.hovered ? tokens.elevated : "transparent"
                            radius: tokens.radius
                            border { width: 1; color: tokens.border }
                        }
                    }
                }
            }
        }
    }
}
