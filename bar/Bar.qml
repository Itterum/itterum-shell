import Quickshell
import QtQuick

import "widgets"

PanelWindow {
    id: panel
    required property var modelData

    screen: modelData
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 26
    color: "#101315"

    Row {
        anchors {
            left: parent.left
            leftMargin: 6
            verticalCenter: parent.verticalCenter
        }

        spacing: 8

        Workspaces {}

        ActiveWindow {
            maxWidth: 280
        }
    }
}
