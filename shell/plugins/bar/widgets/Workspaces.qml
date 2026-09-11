import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  readonly property var fallbackWorkspaceModel: [
    { id: 1, name: "1", focused: true, occupied: false, toplevels: { values: [] } },
    { id: 2, name: "2", focused: false, occupied: false, toplevels: { values: [] } },
    { id: 3, name: "3", focused: false, occupied: false, toplevels: { values: [] } },
    { id: 4, name: "4", focused: false, occupied: false, toplevels: { values: [] } },
    { id: 5, name: "5", focused: false, occupied: false, toplevels: { values: [] } }
  ]

  property var backend: null
  property var backendCompositor: backend && backend.compositor ? backend.compositor : null

  onBarChanged: root.backend = root.bar && "backend" in root.bar ? root.bar.backend : null
  readonly property bool backendConnected: !!backend && backend.connected === true
  readonly property bool canInteract: !!root.bar && (backendConnected || typeof root.bar.run === "function")

  readonly property var workspaceValues: {
    if (!backendCompositor || !Array.isArray(backendCompositor.workspaces) || backendCompositor.workspaces.length === 0) {
      return fallbackWorkspaceModel
    }
    return backendCompositor.workspaces
  }

  function workspaceById(id) {
    var values = root.workspaceValues
    for (var i = 0; i < values.length; i++) {
      if (values[i] && values[i].id === id) return values[i]
    }
    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5]
    var values = root.workspaceValues

    for (var i = 0; i < values.length; i++) {
      var numeric = Number(values[i] && values[i].id)
      if (numeric > 0 && numeric <= 10 && ids.indexOf(numeric) === -1) ids.push(numeric)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  Component.onCompleted: {
    root.backend = root.bar && "backend" in root.bar ? root.bar.backend : null
  }

  function focusWorkspace(id) {
    if (!root.canInteract) return

    if (backendCompositor && typeof backendCompositor.focusWorkspace === "function") {
      backendCompositor.focusWorkspace(id)
      return
    }

    if (root.bar && typeof root.bar.run === "function") {
      root.bar.run("hyprctl dispatch " + Util.shellQuote("workspace " + String(id)))
    }
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels && Array.isArray(workspace.toplevels.values)
          && workspace.toplevels.values.length > 0
        readonly property bool focused: workspace !== null && workspace.focused === true

        bar: root.bar
        text: focused ? "\uDB85\uDCFB" : (modelData === 10 ? "0" : String(modelData))
        interactive: root.canInteract
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        tooltipText: focused ? "Workspace " + String(modelData) : ""
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
