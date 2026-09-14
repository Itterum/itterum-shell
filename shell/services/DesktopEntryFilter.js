function normalizeId(value) {
  var id = String(value || "").trim()
  return id.slice(-8) === ".desktop" ? id.slice(0, -8) : id
}

function parseAllowlist(raw) {
  var values
  try { values = JSON.parse(String(raw || "")) } catch (error) { return [] }
  if (!Array.isArray(values)) return []
  var result = []
  for (var i = 0; i < values.length; i++) {
    var id = normalizeId(values[i])
    if (id && result.indexOf(id) === -1) result.push(id)
  }
  return result
}

function visible(entries, allowlist) {
  var allowed = {}
  var ids = Array.isArray(allowlist) ? allowlist : []
  for (var i = 0; i < ids.length; i++) {
    var allowedId = normalizeId(ids[i])
    if (allowedId) allowed[allowedId] = true
  }

  var seen = {}
  var result = []
  var values = Array.isArray(entries) ? entries : []
  for (var j = 0; j < values.length; j++) {
    var entry = values[j]
    var id = normalizeId(entry && entry.id)
    if (!id || !allowed[id] || seen[id]) continue
    if (entry.hidden === true || entry.noDisplay === true) continue
    seen[id] = true
    result.push(entry)
  }
  return result
}

if (typeof module !== "undefined") {
  module.exports = {
    normalizeId: normalizeId,
    parseAllowlist: parseAllowlist,
    visible: visible
  }
}
