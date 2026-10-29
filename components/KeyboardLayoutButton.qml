import QtQuick.Controls
import QtQml
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Button {
    id: root

    property string keyboardName: ""
    property string activeLayout: ""

    text: layoutLabel(activeLayout)

    function layoutLabel(layoutName) {
        const normalizedName = layoutName.toLowerCase()

        if (normalizedName.includes("english"))
            return "US"

        if (normalizedName.includes("turkish"))
            return "TR"

        return layoutName || "--"
    }

    onClicked: {
        Quickshell.execDetached([
            "hyprctl",
            "switchxkblayout",
            "current",
            "next"
        ])
    }

    Process {
        command: ["hyprctl", "devices", "-j"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const devices = JSON.parse(text)
                    const keyboard = devices.keyboards.find(
                        candidate => candidate.main === true
                    )

                    if (keyboard) {
                        root.keyboardName = keyboard.name
                        root.activeLayout = keyboard.active_keymap
                    }
                } catch (error) {
                    console.warn("Could not read keyboard:", error)
                }
            }
        }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name !== "activelayout")
                return

            const eventArguments = event.parse(2)
            const changedKeyboard = eventArguments[0]
            const changedLayout = eventArguments[1]

            if (changedKeyboard === root.keyboardName)
                root.activeLayout = changedLayout
        }
    }
}
