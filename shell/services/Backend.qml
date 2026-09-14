import QtQuick

// Compatibility object kept until the compositor facade is introduced.
// It deliberately owns no daemon and reports unavailable actions honestly.
Item {
  id: root

  property string health: "unavailable"
  readonly property bool connected: false
  readonly property bool ready: false
  property string lastError: "compositor backend is not configured"

  property QtObject compositor: QtObject {
    property string backend: "unavailable"
    property var workspaces: [
      { id: 1, name: "1", focused: false, occupied: false, toplevels: { values: [] } },
      { id: 2, name: "2", focused: false, occupied: false, toplevels: { values: [] } },
      { id: 3, name: "3", focused: false, occupied: false, toplevels: { values: [] } },
      { id: 4, name: "4", focused: false, occupied: false, toplevels: { values: [] } },
      { id: 5, name: "5", focused: false, occupied: false, toplevels: { values: [] } }
    ]

    function refresh() {
      root.lastError = "compositor backend is not configured"
      return false
    }

    function focusWorkspace(workspaceId) {
      root.lastError = "cannot focus workspace " + String(workspaceId) + ": compositor backend is unavailable"
      return false
    }
  }
}
