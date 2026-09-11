import QtQuick
import Quickshell
import Quickshell.Io

// Minimal backend façade used by bar widgets while daemon migration is incremental.
Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property string home: Quickshell.env("HOME")
  property string xdgRuntimeDir: Quickshell.env("XDG_RUNTIME_DIR") || (home + "/.local/state")

  property string daemonScript: omarchyPath + "/daemon/src/itterum/daemon.py"
  property string daemonSocketPath: xdgRuntimeDir + "/itterum/daemon.sock"
  property string pythonBinary: "python3"

  // Health states: ok (socket), degraded (fallback backend), unavailable (no useful snapshot)
  property string health: "unavailable"
  readonly property bool connected: root.health === "ok"
  readonly property bool ready: root.health === "ok" || root.health === "degraded"
  property string lastError: ""

  property int _requestSerial: 0
  property bool _requestBusy: false
  property var _requestQueue: []
  property var _activeRequest: ({})

  function _nextRequestId() {
    root._requestSerial += 1
    return String(root._requestSerial)
  }

  function _fallbackWorkspaceModel() {
    return [
      { id: 1, name: "1", focused: false, occupied: false, toplevels: { values: [] } },
      { id: 2, name: "2", focused: false, occupied: false, toplevels: { values: [] } },
      { id: 3, name: "3", focused: false, occupied: false, toplevels: { values: [] } },
      { id: 4, name: "4", focused: false, occupied: false, toplevels: { values: [] } },
      { id: 5, name: "5", focused: false, occupied: false, toplevels: { values: [] } }
    ]
  }

  function _coerceWorkspaces(raw) {
    if (!Array.isArray(raw)) return root._fallbackWorkspaceModel()

    var items = []
    for (var i = 0; i < raw.length; i++) {
      var value = raw[i]
      if (!value || typeof value !== "object") continue
      var numeric = Number(value.id)
      if (numeric !== numeric || numeric <= 0) continue
      if (numeric < 1 || numeric > 20) continue

      var occupied = !!value.occupied
      var tops = value.toplevels && value.toplevels.values
      if (!occupied && Array.isArray(tops)) occupied = tops.length > 0

      items.push({
        id: numeric,
        name: String(value.name || value.id || ""),
        focused: !!value.focused,
        occupied: occupied,
        toplevels: {
          values: Array.isArray(tops) ? tops : []
        }
      })
    }

    if (items.length === 0) return root._fallbackWorkspaceModel()

    items.sort(function(left, right) {
      return Number(left.id) - Number(right.id)
    })
    return items
  }

  property QtObject compositor: QtObject {
    id: compositorService
    property var workspaces: root._fallbackWorkspaceModel()
    property string backend: "unknown"

    function refresh() {
      root.refreshWorkspaces()
    }

    function focusWorkspace(workspaceId) {
      return root.requestWorkspaceFocus(workspaceId)
    }
  }

  function _setHealth(response, source, isFallback) {
    if (!response) {
      root.health = root.compositor.workspaces.length > 0 ? "degraded" : "unavailable"
      return
    }

    if (response.ok === true) {
      if (isFallback) {
        root.health = "degraded"
      } else if (source === "socket") {
        root.health = "ok"
      } else {
        root.health = "degraded"
      }
      return
    }

    if (response.error && response.error.code === "BACKEND_UNAVAILABLE") {
      root.health = "degraded"
      return
    }

    root.health = "unavailable"
  }

  function _runRequest() {
    if (root._requestBusy) return
    if (root._requestQueue.length === 0) return

    var next = root._requestQueue.shift()
    root._activeRequest = next
    root._requestBusy = true

    var params = JSON.stringify(next.params || {})
    rpcProcess.command = [
      root.pythonBinary,
      root.daemonScript,
      "--socket",
      root.daemonSocketPath,
      "--method",
      next.method,
      "--request-id",
      next.id,
      "--params",
      params
    ]
    rpcStdout.text = ""
    rpcStderr.text = ""
    rpcProcess.running = true
  }

  function call(method, params, onSuccess, onError) {
    root._requestQueue.push({
      id: root._nextRequestId(),
      method: String(method || ""),
      params: params || {},
      onSuccess: typeof onSuccess === "function" ? onSuccess : null,
      onError: typeof onError === "function" ? onError : null
    })
    root._runRequest()
  }

  function refreshWorkspaces() {
    root.call("compositor.getWorkspaces", {}, function(response) {
      var source = response.meta && response.meta.source ? String(response.meta.source) : ""
      var isFallback = source !== "socket"
      root._setHealth(response, source, isFallback)
      var result = response.result || {}
      var workspaces = root._coerceWorkspaces(result.workspaces)
      compositor.workspaces = workspaces
      lastError = ""
      compositor.backend = result.backend || "unknown"
    }, function(message) {
      root.lastError = message || "workspace update failed"
      root.health = root.compositor.workspaces.length > 0 ? "degraded" : "unavailable"
      if (root.compositor.workspaces.length === 0)
        compositor.workspaces = root._fallbackWorkspaceModel()
    })
  }

  function requestWorkspaceFocus(workspaceId) {
    root.call("compositor.focusWorkspace", { id: workspaceId }, function() {
      root.lastError = ""
    }, function(message) {
      root.lastError = message || "focus failed"
    })
  }

  function checkPing() {
    root.call("system.ping", {}, function(response) {
      var source = response.meta && response.meta.source ? String(response.meta.source) : ""
      root._setHealth(response, source, source !== "socket")
      lastError = ""
    }, function(message) {
      root.lastError = message || "daemon ping failed"
      root.health = root.compositor.workspaces.length > 0 ? "degraded" : "unavailable"
    })
  }

  Process {
    id: rpcProcess
    command: [ ]
    stdout: StdioCollector { id: rpcStdout; waitForEnd: true }
    stderr: StdioCollector { id: rpcStderr; waitForEnd: true }

    onExited: function(exitCode) {
      var request = root._activeRequest || {}
      root._activeRequest = ({})
      root._requestBusy = false

      var output = String(rpcStdout.text || "").trim()
      if (!output) {
        if (request.onError)
          request.onError(rpcStderr.text || "empty daemon response")
      } else {
        var payload = {}
        var parsed = false
        try {
          payload = JSON.parse(output)
          parsed = true
        } catch (error) {
          if (request.onError) request.onError(String(error))
        }

        if (parsed) {
          var source = payload.meta && payload.meta.source ? String(payload.meta.source) : ""
          var isFallback = source !== "socket"
          root._setHealth(payload, source, isFallback)

          if (payload.ok === true) {
            if (request.onSuccess) request.onSuccess(payload)
          } else {
            if (request.onError) request.onError(payload.error && payload.error.message
              ? String(payload.error.message)
              : "backend request failed")
          }
        }
      }

      if (request.onError && (exitCode !== 0)) {
        request.onError("daemon helper exited with " + String(exitCode))
      }

      root._runRequest()
    }
  }

  Process {
    id: daemonServer
    command: [root.pythonBinary, root.daemonScript, "--serve", "--socket", root.daemonSocketPath]
    onExited: function() {
      // Keep the service available via direct fallback mode in request handling.
      if (root.health === "ok") root.health = "degraded"
    }
  }

  Timer {
    interval: 800
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      // Start the daemon as soon as the shell comes up.
      if (daemonServer.running) return
      daemonServer.running = true
    }
  }

  Timer {
    id: healthRefresh
    interval: 7000
    running: true
    repeat: true
    onTriggered: root.checkPing()
  }

  Timer {
    id: workspaceRefresh
    interval: 1800
    running: true
    repeat: true
    onTriggered: root.refreshWorkspaces()
  }

  Component.onCompleted: {
    checkPing()
    refreshWorkspaces()
  }
}
