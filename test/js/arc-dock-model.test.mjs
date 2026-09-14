import test from "node:test"
import assert from "node:assert/strict"

import {
  buildDockItems,
  closeTarget,
  matchDesktopEntry,
  nextWindow,
} from "../../shell/plugins/io.github.claudsondouglas.arcdock/ArcDockModel.js"

const entries = [
  { id: "foot", name: "Foot", startupWMClass: "foot" },
  { id: "dev.zed.Zed", name: "Zed", startupWMClass: "zed" },
  { id: "org.gnome.Nautilus", name: "Files", startupWMClass: "org.gnome.Nautilus" },
]

test("matches desktop entries by stable id before display name", () => {
  assert.equal(matchDesktopEntry({ appId: "dev.zed.Zed", title: "Other" }, entries).id, "dev.zed.Zed")
  assert.equal(matchDesktopEntry({ appId: "zed" }, entries).id, "dev.zed.Zed")
})

test("groups windows while preserving declarative pin order and recents", () => {
  const items = buildDockItems({
    pinnedIds: ["org.gnome.Nautilus", "foot"],
    recentIds: ["dev.zed.Zed", "foot"],
    desktopEntries: entries,
    windows: [
      { address: "0x2", appId: "foot" },
      { address: "0x1", appId: "foot" },
      { address: "0x3", appId: "dev.zed.Zed" },
    ],
  })

  assert.deepEqual(items.map(item => item.id), ["org.gnome.Nautilus", "foot", "dev.zed.Zed"])
  assert.deepEqual(items[1].windows.map(window => window.address), ["0x2", "0x1"])
})

test("cycles focus and chooses an explicit close address", () => {
  const windows = [{ address: "0x1" }, { address: "0x2" }]
  assert.equal(nextWindow(windows, "0x1").address, "0x2")
  assert.equal(nextWindow(windows, "0x2").address, "0x1")
  assert.equal(closeTarget(windows, "0x2"), "0x2")
})

test("keeps a missing pinned desktop entry as a non-launchable placeholder", () => {
  const [item] = buildDockItems({
    pinnedIds: ["missing.app"],
    recentIds: [],
    desktopEntries: entries,
    windows: [],
  })
  assert.equal(item.id, "missing.app")
  assert.equal(item.entry, null)
  assert.equal(item.launchable, false)
})
