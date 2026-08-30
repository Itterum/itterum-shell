pragma Singleton

import QtQuick
import Niri

QtObject {
    id: root

    readonly property alias workspaces: niri.workspaces
    readonly property alias windows: niri.windows
    readonly property alias focusedWindow: niri.focusedWindow

    property Niri client: Niri {
        id: niri

        Component.onCompleted: niri.connect()

        onConnected: console.log("itterum-shell: connected to niri")
        onDisconnected: console.warn("itterum-shell: disconnected from niri")
        onErrorOccurred: function(error) {
            console.warn("itterum-shell: niri IPC error:", error)
        }
    }

    function focusWorkspace(id) {
        return niri.focusWorkspaceById(id)
    }

    function focusWindow(id) {
        return niri.focusWindow(id)
    }

    function closeWindow(id) {
        return niri.closeWindow(id)
    }
}
