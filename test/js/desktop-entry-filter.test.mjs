import assert from "node:assert/strict"
import { createRequire } from "node:module"
import test from "node:test"

const require = createRequire(import.meta.url)
const Filter = require("../../shell/services/DesktopEntryFilter.js")

const entries = [
  { id: "foot", name: "Foot" },
  { id: "dev.zed.Zed", name: "Zed" },
  { id: "org.gnome.Nautilus", name: "Files" },
  { id: "hidden.desktop", name: "Hidden", hidden: true },
  { id: "nodisplay.desktop", name: "No Display", noDisplay: true },
  { id: "incidental.desktop", name: "Dependency Helper" },
  { id: "foot.desktop", name: "Foot duplicate" }
]

test("keeps only installed allowlisted desktop entries", () => {
  assert.deepEqual(
    Filter.visible(entries, ["dev.zed.Zed.desktop", "foot.desktop"])
      .map(entry => entry.id),
    ["foot", "dev.zed.Zed"]
  )
})

test("excludes hidden and NoDisplay entries even when allowlisted", () => {
  assert.deepEqual(
    Filter.visible(entries, ["hidden.desktop", "nodisplay.desktop"]),
    []
  )
})

test("deduplicates normalized desktop IDs stably", () => {
  assert.deepEqual(
    Filter.visible(entries, ["foot.desktop"]).map(entry => entry.name),
    ["Foot"]
  )
})

test("parses a declarative JSON allowlist", () => {
  assert.deepEqual(
    Filter.parseAllowlist('["foot.desktop", "dev.zed.Zed"]'),
    ["foot", "dev.zed.Zed"]
  )
  assert.deepEqual(Filter.parseAllowlist("not json"), [])
})
