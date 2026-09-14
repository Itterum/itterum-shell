function outputs(monitors) {
  var values = Array.isArray(monitors) ? monitors : []
  return values.map(function(monitor) {
    var name = String((monitor && monitor.name) || "")
    return {
      id: name,
      name: name,
      focused: !!(monitor && monitor.focused),
      enabled: !(monitor && monitor.disabled === true),
      powered: !(monitor && monitor.dpmsStatus === false),
      scale: Number((monitor && monitor.scale) || 1),
      x: Number((monitor && monitor.x) || 0),
      y: Number((monitor && monitor.y) || 0),
      width: Number((monitor && monitor.width) || 0),
      height: Number((monitor && monitor.height) || 0)
    }
  }).filter(function(output) { return output.id !== "" })
}

function workspaces(rawWorkspaces, clients, activeWorkspace) {
  var values = Array.isArray(rawWorkspaces) ? rawWorkspaces : []
  var windowsByWorkspace = {}
  var windowValues = Array.isArray(clients) ? clients : []
  for (var i = 0; i < windowValues.length; i++) {
    var client = windowValues[i] || {}
    var workspaceId = Number(client.workspace && client.workspace.id)
    if (!isFinite(workspaceId)) continue
    if (!windowsByWorkspace[workspaceId]) windowsByWorkspace[workspaceId] = []
    windowsByWorkspace[workspaceId].push(String(client.address || ""))
  }

  var focusedId = Number(activeWorkspace && activeWorkspace.id)
  return values.map(function(workspace) {
    var id = Number(workspace && workspace.id)
    var windows = windowsByWorkspace[id] || []
    return {
      id: id,
      name: String((workspace && workspace.name) || id),
      outputId: String((workspace && workspace.monitor) || ""),
      focused: id === focusedId,
      occupied: windows.length > 0,
      windows: windows
    }
  }).filter(function(workspace) { return isFinite(workspace.id) && workspace.id > 0 })
    .sort(function(left, right) { return left.id - right.id })
}

function activeWindow(window) {
  if (!window || typeof window !== "object" || !window.address) return null
  return {
    id: String(window.address),
    appId: String(window.class || window.initialClass || ""),
    title: String(window.title || "")
  }
}

function keyboard(devices, preferredId) {
  var keyboards = devices && Array.isArray(devices.keyboards) ? devices.keyboards : []
  if (keyboards.length === 0) return null
  var selected = null
  for (var i = 0; i < keyboards.length; i++) {
    if (String(keyboards[i].name || "") === String(preferredId || "")) {
      selected = keyboards[i]
      break
    }
  }
  if (!selected) selected = keyboards[0]
  var layout = String(selected.layout || "")
  return {
    keyboardId: String(selected.name || ""),
    name: String(selected.active_keymap || ""),
    index: Number(selected.active_layout_index || 0),
    count: layout ? layout.split(",").length : 0,
    syncIds: keyboards.filter(function(item) {
      return String(item.layout || "") === layout
    }).map(function(item) { return String(item.name || "") }).filter(function(name) { return name !== "" })
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    outputs: outputs,
    workspaces: workspaces,
    activeWindow: activeWindow,
    keyboard: keyboard
  }
}
