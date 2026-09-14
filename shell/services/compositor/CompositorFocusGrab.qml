import QtQuick
import Quickshell.Hyprland

Item {
  id: root

  property bool active: false
  property var windows: []
  signal cleared()

  HyprlandFocusGrab {
    active: root.active
    windows: root.windows
    onCleared: root.cleared()
  }
}
