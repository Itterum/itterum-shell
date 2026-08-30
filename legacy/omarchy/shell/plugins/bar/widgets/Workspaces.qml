import QtQuick
import QtQuick.Layouts
import qs.services

QtObject {
    id: workspaces

    readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

    implicitWidth: grid.implicitWidth + trailingGap
    implicitHeight: grid.implicitHeight

    GridLayout {
        id: grid

        anchors.fill: parent
        anchors.rightMargin: root.trailingGap

        columns: root.vertical ? 1 : Math.max(1, workspaceRepeater.count)
        columnSpacing: root.vertical ? 0 : Style.space(1)
        rowSpacing: root.vertical ? Style.space(2) : 0

        Repeater {
            id: workspaceRepeater
            model: Compositor.workspaces

            WidgetButton {
                readonly property bool occupied: Number(model.activeWindowId) !== 0

                readonly property bool focused: model.isFocused

                bar: root.bar

                text: focused ? "\uDB85\uDCFB" : (model.index === 10 ? "0" : String(model.index))

                opacity: occupied || focused ? 1 : 0.5

                horizontalMargin: 6
                verticalPadding: 6
                fixedWidth: root.vertical ? root.barSize : Style.space(20)
                fixedHeight: root.barSize

                onPressed: {
                    Compositor.focusWorkspace(model.id);
                }
            }
        }
    }
}
