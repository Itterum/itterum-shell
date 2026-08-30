import QtQuick
import "../../services"

Item {
    id: root

    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: workspaceRow.implicitHeight

    Row {
        id: workspaceRow
        spacing: 0

        Repeater {
            id: workspaceRepeater
            model: Compositor.workspaces

            Rectangle {
                required property var model

                readonly property bool occupied: Number(model.activeWindowId) !== 0
                readonly property bool focused: model.isFocused
                readonly property bool urgent: model.isUrgent

                width: 20
                height: 26
                radius: 3
                color: mouseArea.containsMouse ? Qt.rgba(0.79, 0.80, 0.80, 0.08) : "transparent"
                opacity: occupied || focused || urgent ? 1 : 0.45

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                }

                Text {
                    anchors.centerIn: parent
                    text: String(parent.model.index)
                    color: parent.urgent ? "#a55555" : (parent.focused ? "#89b4fa" : "#cacccc")
                    font.family: "monospace"
                    font.pixelSize: 12
                    renderType: Text.NativeRendering

                    Behavior on color {
                        ColorAnimation { duration: 160 }
                    }
                }

                Rectangle {
                    id: activeIndicator

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: 1
                    }

                    visible: parent.focused
                    width: 12
                    height: 2
                    radius: 1
                    color: "#89b4fa"
                }

                MouseArea {
                    id: mouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Compositor.focusWorkspace(parent.model.id)
                }
            }
        }
    }
}
