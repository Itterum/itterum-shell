function normalized(value) {
  var id = String(value || "").trim().toLowerCase()
  return id.endsWith(".desktop") ? id.slice(0, -8) : id
}

function matchDesktopEntry(window, entries) {
  var values = Array.isArray(entries) ? entries : []
  var appId = normalized(window && window.appId)
  for (var i = 0; i < values.length; i++) {
    if (normalized(values[i] && values[i].id) === appId) return values[i]
  }
  for (var j = 0; j < values.length; j++) {
    if (normalized(values[j] && values[j].startupWMClass) === appId) return values[j]
  }
  return null
}

function buildDockItems(options) {
  var pinnedIds = Array.isArray(options && options.pinnedIds) ? options.pinnedIds : []
  var recentIds = Array.isArray(options && options.recentIds) ? options.recentIds : []
  var entries = Array.isArray(options && options.desktopEntries) ? options.desktopEntries : []
  var windows = Array.isArray(options && options.windows) ? options.windows : []
  var orderedIds = []
  var seen = {}

  function append(id) {
    var key = normalized(id)
    if (!key || seen[key]) return
    seen[key] = true
    orderedIds.push(String(id))
  }

  pinnedIds.forEach(append)
  windows.forEach(function(window) {
    var entry = matchDesktopEntry(window, entries)
    append(entry ? entry.id : window && window.appId)
  })
  recentIds.forEach(append)

  return orderedIds.map(function(id) {
    var entry = null
    for (var i = 0; i < entries.length; i++) {
      if (normalized(entries[i] && entries[i].id) === normalized(id)) {
        entry = entries[i]
        break
      }
    }
    var grouped = windows.filter(function(window) {
      var matched = matchDesktopEntry(window, entries)
      return normalized(matched ? matched.id : window && window.appId) === normalized(id)
    })
    return { id: id, entry: entry, windows: grouped, launchable: entry !== null }
  })
}

function nextWindow(windows, activeAddress) {
  var values = Array.isArray(windows) ? windows : []
  if (values.length === 0) return null
  var current = -1
  for (var i = 0; i < values.length; i++) {
    if (String(values[i] && values[i].address) === String(activeAddress || "")) {
      current = i
      break
    }
  }
  return values[(current + 1) % values.length]
}

function closeTarget(windows, activeAddress) {
  var values = Array.isArray(windows) ? windows : []
  for (var i = 0; i < values.length; i++) {
    if (String(values[i] && values[i].address) === String(activeAddress || ""))
      return String(values[i].address)
  }
  return values.length > 0 ? String(values[0].address || "") : ""
}

if (typeof module !== "undefined") {
  module.exports = {
    buildDockItems: buildDockItems,
    closeTarget: closeTarget,
    matchDesktopEntry: matchDesktopEntry,
    nextWindow: nextWindow
  }
}
