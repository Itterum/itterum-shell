import QtQuick
import Quickshell
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "omarchy.menu"

  property string omarchyPath: {
    var fromEnv = Quickshell.env("OMARCHY_PATH")
    if (fromEnv && fromEnv.length > 0) return fromEnv

    var shellDir = Quickshell.shellDir || ""
    if (!shellDir.length) return ""
    if (shellDir.slice(-6) === "/shell") return shellDir.slice(0, -6)
    return shellDir
  }
  property string omarchyShellPath: root.omarchyPath.length > 0
    ? Util.shellQuote(root.omarchyPath + "/bin/omarchy-shell")
    : "omarchy-shell"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\ue900"
    fontFamily: "omarchy"
    horizontalMargin: 7.5
    onPressed: function(button) {
      if (!root.bar) return
      if (button === Qt.RightButton) root.bar.run("xdg-terminal-exec")
      else root.bar.run(root.omarchyShellPath + " shell toggle omarchy.menu '{\"menu\":\"root\"}'")
    }
  }
}
