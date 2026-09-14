import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons
import "KeyboardLayoutModel.js" as KeyboardLayoutModel

BarWidget {
  id: root
  moduleName: "omarchy.keyboard-layout"


  property string layoutFull: ""
  readonly property var compositor: root.bar ? root.bar.compositor : null
  // The keyboard the last reading spoke for, which is the one a click switches,
  // and separately the one activelayout named as being typed on. A reading
  // confirms the first is really there, so the click has a keyboard to reach
  // from the first reading onwards rather than only after a switch, and stops
  // naming one that has been unplugged.
  property string keyboardName: ""
  property string typedKeyboardName: ""
  // Keyboards on the seat, buttons and virtual ones excluded, and whether the
  // last reading left that shape in doubt.
  property int keyboardCount: 0
  property bool keyboardUnresolved: false
  // Nothing to read or switch on the single-layout install most people run, so
  // the widget ships on the bar and stays out of the way until there are two.
  // An older Hyprland that doesn't report the list keeps showing the label.
  property bool multipleLayouts: true
  // Where the reading sits in the layout list, how long that list is, and every
  // keyboard sharing it. A switch moves that set together, so it needs all three.
  property int layoutIndex: 0
  property int layoutCount: 0
  property var syncNames: []
  // Short language code per layout description ("English (US)": "en"), read from
  // xkb's own table rather than maintained by hand.
  property var layoutBriefs: ({})
  readonly property string layoutLabel: KeyboardLayoutModel.shortLabel(layoutFull, layoutBriefs)

  // A query already in flight was started before this event, so it may read the
  // layout the switch replaced. Remember the request and re-run once it lands
  // rather than dropping it; nothing else would correct the label afterwards.
  property bool refreshPending: false

  function refresh() {
    if (root.compositor) root.compositor.refresh()
    root.applyLayout()
  }

  function applyLayout() {
    var next = root.compositor ? root.compositor.keyboardLayout : null
    if (!next) {
      root.layoutFull = ""
      root.keyboardName = ""
      root.layoutCount = 0
      root.syncNames = []
      return
    }
    root.layoutFull = String(next.name || "")
    root.keyboardName = String(next.keyboardId || "")
    root.layoutIndex = Number(next.index || 0)
    root.layoutCount = Number(next.count || 0)
    root.multipleLayouts = root.layoutCount > 1
    root.syncNames = Array.isArray(next.syncIds) ? next.syncIds : []
  }

  // Keyboards someone can actually type on, which is not everything Hyprland
  // calls a keyboard.
  function typedKeyboards(keyboards) {
    return keyboards.filter(k => KeyboardLayoutModel.isTypedKeyboard(k.name))
  }

  // The main flag names no keyboard for long: fcitx5 takes it with the virtual
  // keyboard it binds to inject, which leaves no typed keyboard holding it and
  // nothing to read at all, and once that unbinds it lands on whichever device
  // Hyprland saw last, a power button included. Go by layout progress instead,
  // and by the keyboard activelayout named.
  function selectKeyboard(typed) {
    return KeyboardLayoutModel.selectKeyboard(typed, root.typedKeyboardName)
  }

  // switchxkblayout is a hyprctl command rather than a dispatcher, so it has to
  // be run rather than sent over the dispatch socket.
  //
  // Move every keyboard holding the same layout list, rather than the single one
  // the last reading spoke for. Naming one device puts the whole switch behind
  // UNTYPED_KEYBOARDS recognising every non-keyboard by name, and that list
  // cannot keep up with what a seat carries: vendor hotkey blocks
  // (intel-hid-events, dell-wmi-hotkeys), HID consumer controls, and Bluetooth
  // AVRCP endpoints from a pair of headphones all arrive holding the seat's
  // layout list, and they sort ahead of the keyboard being typed on. The click
  // then advances a device nobody types on; that device is now the furthest
  // along, so it wins the next reading too, and the label describes it while the
  // real keyboard never moved.
  //
  // An absolute index rather than "next", because "next" advances each device
  // from wherever it already sits: a seat that has drifted apart stays drifted
  // and merely inverts. One index converges them in a single click, and a seat
  // in lockstep is what leaves the reading nothing to disagree about afterwards.
  //
  // Keyboards given their own kb_layout hold a different list and are left out:
  // an index into this list would not mean the same layout to them.
  function cycleLayout() {
    if (!root.bar || root.layoutCount < 2 || root.syncNames.length === 0) return
    const next = (root.layoutIndex + 1) % root.layoutCount
    root.compositor.switchKeyboardLayout(root.syncNames, next)
    refreshTimer.restart()
  }

  Component.onCompleted: {
    briefsProc.running = true
    refresh()
  }

  Connections {
    target: root.compositor
    function onKeyboardLayoutChanged() { root.applyLayout() }
  }

  // The table only changes when xkb data is upgraded, so read it at startup and
  // leave it alone. The bar is built per monitor, so this runs once per widget.
  // The exotic rulesets cover layouts like trans (IPA) that ship in the same xkb
  // package and set just as well, so load them or those labels lose their code.
  Process {
    id: briefsProc
    command: ["xkbcli", "list", "--load-exotic"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.layoutBriefs = KeyboardLayoutModel.layoutBriefs(text)
    }
  }

  Timer {
    id: refreshTimer
    interval: 600
    onTriggered: root.refresh()
  }

  // Which keyboard on a crowded seat the label is describing can change without
  // Hyprland announcing it, since a device arriving or leaving raises no event
  // of its own, and that can only be learned by asking. Poll while there is that
  // ambiguity, until a first reading lands so a query that failed at login still
  // recovers, and while a reading has left the seat's shape in doubt. The
  // one-keyboard install has none of those, and is left alone rather than
  // spawning hyprctl forever for an answer that cannot change.
  Timer {
    interval: 10000
    running: !root.keyboardName || root.keyboardUnresolved || root.keyboardCount > 1
    repeat: true
    onTriggered: root.refresh()
  }

  visible: layoutLabel !== "" && multipleLayouts
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.layoutLabel
    fontSize: Style.font.caption
    horizontalMargin: 6
    tooltipText: root.layoutFull
    onPressed: function() { root.cycleLayout() }
  }
}
