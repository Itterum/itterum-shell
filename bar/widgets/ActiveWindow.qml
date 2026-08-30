import QtQuick
import "../../services"

Item {
    id: root

    property int maxWidth: 280

    readonly property var window: Compositor.focusedWindow
    readonly property string title: window ? (window.title || window.appId || "") : ""

    visible: title !== ""
    implicitWidth: visible ? Math.min(280, label.implicitWidth) : 0
    implicitHeight: 26

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Text {
        id: label

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

        width: Math.min(280, implicitWidth)
        text: root.title
        color: "#cacccc"
        opacity: 0.85

        font.family: "monospace"
        font.pixelSize: 12
        renderType: Text.NativeRendering

        elide: Text.ElideRight
    }

    MouseArea {
        anchors.fill: parent

        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: function (mouse) {
            if (!root.window)
                return;
            if (mouse.button === Qt.MiddleButton || mouse.button === Qt.RightButton) {
                Compositor.closeWindow(root.window.id);
            } else {
                Compositor.focusWindow(root.window.id);
            }
        }
    }
}
