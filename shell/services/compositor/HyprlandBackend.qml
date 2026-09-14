import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "HyprlandMapping.js" as Mapping

Item {
  id: root

  property bool available: false
  property var outputs: []
  property string focusedOutputId: ""
  property var workspaces: []
  property int focusedWorkspaceId: 0
  property var activeWindow: null
  property var keyboardLayout: null
  property int rounding: 8
  property int gapsOut: 6
  property string preferredKeyboardId: ""
  property string actionState: "idle"
  property string lastError: ""
  property var _rawWorkspaces: []
  property var _rawClients: []
  property var _rawActiveWorkspace: ({})
  property var _actionQueue: []

  signal rawEvent(var event)

  function parseJson(text, fallback) {
    try { return JSON.parse(String(text || "")) } catch (error) { return fallback }
  }

  function refreshWorkspaceModel() {
    workspaces = Mapping.workspaces(_rawWorkspaces, _rawClients, _rawActiveWorkspace)
    focusedWorkspaceId = Number(_rawActiveWorkspace.id || 0)
  }

  function refresh() {
    if (!monitorsProc.running) monitorsProc.running = true
    if (!workspacesProc.running) workspacesProc.running = true
    if (!clientsProc.running) clientsProc.running = true
    if (!activeWorkspaceProc.running) activeWorkspaceProc.running = true
    if (!activeWindowProc.running) activeWindowProc.running = true
    if (!devicesProc.running) devicesProc.running = true
    if (!roundingProc.running) roundingProc.running = true
    if (!gapsProc.running) gapsProc.running = true
  }

  function enqueueAction(args) {
    if (!root.available) {
      root.actionState = "failed"
      root.lastError = "Hyprland IPC is unavailable"
      return false
    }
    root._actionQueue = root._actionQueue.concat([args])
    root.runNextAction()
    return true
  }

  function runNextAction() {
    if (actionProc.running || root._actionQueue.length === 0) return
    var queue = root._actionQueue.slice()
    actionProc.command = queue.shift()
    root._actionQueue = queue
    root.actionState = "pending"
    actionProc.running = true
  }

  function focusWorkspace(id) {
    return enqueueAction(["hyprctl", "dispatch", "workspace", String(id)])
  }

  function focusWindow(id) {
    return enqueueAction(["hyprctl", "dispatch", "focuswindow", "address:" + String(id)])
  }

  function closeWindow(id) {
    return enqueueAction(["hyprctl", "dispatch", "closewindow", "address:" + String(id)])
  }

  function switchKeyboardLayout(ids, index) {
    var values = Array.isArray(ids) ? ids : []
    if (values.length === 0) return false
    var accepted = true
    for (var i = 0; i < values.length; i++)
      accepted = enqueueAction(["hyprctl", "switchxkblayout", String(values[i]), String(index)]) && accepted
    return accepted
  }

  function setOutputEnabled(id, enabled) {
    var spec = String(id) + (enabled ? ",preferred,auto,auto" : ",disable")
    return enqueueAction(["hyprctl", "keyword", "monitor", spec])
  }

  function setOutputPower(enabled) {
    return enqueueAction(["hyprctl", "dispatch", "dpms", enabled ? "on" : "off"])
  }

  Process {
    id: monitorsProc
    command: ["hyprctl", "-j", "monitors", "all"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var next = Mapping.outputs(root.parseJson(text, []))
        root.outputs = next
        root.focusedOutputId = ""
        for (var i = 0; i < next.length; i++) if (next[i].focused) root.focusedOutputId = next[i].id
      }
    }
    onExited: function(code) {
      root.available = code === 0
      if (code !== 0) root.lastError = "could not query Hyprland monitors"
    }
  }

  Process {
    id: workspacesProc
    command: ["hyprctl", "-j", "workspaces"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: { root._rawWorkspaces = root.parseJson(text, []); root.refreshWorkspaceModel() } }
  }

  Process {
    id: clientsProc
    command: ["hyprctl", "-j", "clients"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: { root._rawClients = root.parseJson(text, []); root.refreshWorkspaceModel() } }
  }

  Process {
    id: activeWorkspaceProc
    command: ["hyprctl", "-j", "activeworkspace"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: { root._rawActiveWorkspace = root.parseJson(text, {}); root.refreshWorkspaceModel() } }
  }

  Process {
    id: activeWindowProc
    command: ["hyprctl", "-j", "activewindow"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.activeWindow = Mapping.activeWindow(root.parseJson(text, null)) }
  }

  Process {
    id: devicesProc
    command: ["hyprctl", "-j", "devices"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.keyboardLayout = Mapping.keyboard(root.parseJson(text, {}), root.preferredKeyboardId) }
  }

  Process {
    id: roundingProc
    command: ["hyprctl", "-j", "getoption", "decoration:rounding"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var value = Number(root.parseJson(text, {}).int)
        if (isFinite(value) && value >= 0) root.rounding = value
      }
    }
  }

  Process {
    id: gapsProc
    command: ["hyprctl", "-j", "getoption", "general:gaps_out"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var json = root.parseJson(text, {})
        var values = String(json.css || "").match(/-?\d+(?:\.\d+)?/g) || []
        var value = values.length > 0 ? Number(values[0]) : Number(json.int)
        if (isFinite(value) && value >= 0) root.gapsOut = Math.max(0, Math.round(value / 2))
      }
    }
  }

  Process {
    id: actionProc
    onExited: function(code) {
      root.actionState = code === 0 ? "succeeded" : "failed"
      root.lastError = code === 0 ? "" : "Hyprland action failed with exit code " + String(code)
      root.runNextAction()
      refreshTimer.restart()
    }
  }

  Timer {
    id: refreshTimer
    interval: 80
    onTriggered: root.refresh()
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      root.rawEvent(event)
      if (event && event.name === "activelayout") {
        var parts = String(event.data || "").split(",")
        if (parts[0]) root.preferredKeyboardId = String(parts[0])
      }
      refreshTimer.restart()
    }
  }

  Component.onCompleted: root.refresh()
}
