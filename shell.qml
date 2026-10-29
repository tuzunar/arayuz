//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import "components"

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            required property var modelData
            screen: modelData
            id: root

            implicitHeight: 38

            anchors {
                top: true
                left: true
                right: true
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Workspaces {}
                ActiveWindowTitle {}
                KeyboardLayoutButton {}
                BluetoothControl {}
                AudioControl {}
                SystemStats {}

                SystemTrayView {
                    panelWindow: root
                }

                Clock {}
                Power{}

            }
        }

    }
}