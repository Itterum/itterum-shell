import QtQuick

Item {
  id: root

  HyprlandBackend { id: backend }

  readonly property bool available: backend.available
  readonly property var outputs: backend.outputs
  readonly property string focusedOutputId: backend.focusedOutputId
  readonly property var workspaces: backend.workspaces
  readonly property int focusedWorkspaceId: backend.focusedWorkspaceId
  readonly property var activeWindow: backend.activeWindow
  readonly property var keyboardLayout: backend.keyboardLayout
  readonly property int rounding: backend.rounding
  readonly property int gapsOut: backend.gapsOut
  readonly property string actionState: backend.actionState
  readonly property string lastError: backend.lastError

  signal rawEvent(var event)

  function refresh() { backend.refresh() }
  function focusWorkspace(id) { return backend.focusWorkspace(id) }
  function focusWindow(id) { return backend.focusWindow(id) }
  function closeWindow(id) { return backend.closeWindow(id) }
  function switchKeyboardLayout(ids, index) { return backend.switchKeyboardLayout(ids, index) }
  function setOutputEnabled(id, enabled) { return backend.setOutputEnabled(id, enabled) }
  function setOutputPower(enabled) { return backend.setOutputPower(enabled) }

  Connections {
    target: backend
    function onRawEvent(event) { root.rawEvent(event) }
  }
}
