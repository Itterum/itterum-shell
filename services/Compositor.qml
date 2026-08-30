pragma Singleton

import QtQuick

QtObject {
    readonly property var workspaces: NiriBackend.workspaces
    readonly property var windows: NiriBackend.windows
    readonly property var focusedWindow: NiriBackend.focusedWindow

    function workspaceById(id) {
        var row = workspaces.indexOfId(id)
        return row >= 0 ? workspaces.get(row) : null
    }

    function focusWorkspace(id) {
        var result = NiriBackend.focusWorkspace(id)

        if (result && !result.ok)
            console.warn("itterum-shell: cannot focus workspace:", result.error)

        return result
    }

    function focusWindow(id) {
        return NiriBackend.focusWindow(id)
    }

    function closeWindow(id) {
        return NiriBackend.closeWindow(id)
    }
}
