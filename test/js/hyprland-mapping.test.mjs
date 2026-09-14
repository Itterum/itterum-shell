import assert from "node:assert/strict"
import { createRequire } from "node:module"
import test from "node:test"

const require = createRequire(import.meta.url)
const Mapping = require("../../shell/services/compositor/HyprlandMapping.js")

test("maps focused and powered outputs", () => {
  assert.deepEqual(Mapping.outputs([
    { id: 0, name: "DP-1", focused: true, disabled: false, dpmsStatus: true, scale: 1.25, x: 0, y: 0, width: 2560, height: 1440 },
    { id: 1, name: "HDMI-A-1", focused: false, disabled: true, dpmsStatus: false, scale: 1, x: 2560, y: 0, width: 1920, height: 1080 }
  ]), [
    { id: "DP-1", name: "DP-1", focused: true, enabled: true, powered: true, scale: 1.25, x: 0, y: 0, width: 2560, height: 1440 },
    { id: "HDMI-A-1", name: "HDMI-A-1", focused: false, enabled: false, powered: false, scale: 1, x: 2560, y: 0, width: 1920, height: 1080 }
  ])
})

test("maps workspace focus and occupancy", () => {
  assert.deepEqual(Mapping.workspaces(
    [{ id: 1, name: "1", monitor: "DP-1" }, { id: 2, name: "2", monitor: "DP-1" }],
    [{ address: "0x1", workspace: { id: 2 } }],
    { id: 2 }
  ), [
    { id: 1, name: "1", outputId: "DP-1", focused: false, occupied: false, windows: [] },
    { id: 2, name: "2", outputId: "DP-1", focused: true, occupied: true, windows: ["0x1"] }
  ])
})

test("maps active window metadata without compositor objects", () => {
  assert.deepEqual(Mapping.activeWindow({ address: "0xabc", class: "dev.zed.Zed", title: "shell.qml" }), {
    id: "0xabc",
    appId: "dev.zed.Zed",
    title: "shell.qml"
  })
  assert.equal(Mapping.activeWindow(null), null)
})

test("maps keyboard layout updates for the named keyboard", () => {
  const devices = {
    keyboards: [
      { name: "power-button", active_keymap: "English (US)", active_layout_index: 0, layout: "us,ru" },
      { name: "keychron-k2", active_keymap: "Russian", active_layout_index: 1, layout: "us,ru" }
    ]
  }
  assert.deepEqual(Mapping.keyboard(devices, "keychron-k2"), {
    keyboardId: "keychron-k2",
    name: "Russian",
    index: 1,
    count: 2,
    syncIds: ["power-button", "keychron-k2"]
  })
})
