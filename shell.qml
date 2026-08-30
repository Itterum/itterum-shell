import QtQuick
import Quickshell

import "bar"

ShellRoot {
    id: shell

    Component.onCompleted: console.log("itterum-shell: minimal example loaded")

    Variants {
        model: Quickshell.screens

        delegate: Component {
            Bar {}
        }
    }
}
