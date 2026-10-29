import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Button {
    id: power

    contentItem: IconImage {
        source: Qt.resolvedUrl("../icons/power.svg")
    }
    implicitHeight: 32
    implicitWidth: 32

    background: Rectangle {
        color: "transparent"
    }

    onClicked: powerMenu.visible = !powerMenu.visible

    PopupWindow {
        id: powerMenu

        visible: false
        implicitHeight: 100
        implicitWidth: 100
        grabFocus: true

        anchor{
            item: power
            edges: Edges.Bottom | Edges.Right
            gravity: Edges.Bottom | Edges.Left
        }

        Rectangle {
            anchors.fill: parent
            color: "#282828"
            border.color: "#504945"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12

                Button {
                    text: "Shutdown"

                    onClicked: {
                        Quickshell.execDetached([
                            "shutdown",
                            "-h",
                            "now"
                        ])
                    }
                }
                Button {
                    text: "Restart"

                    onClicked: {
                        Quickshell.execDetached([
                            "shutdown",
                            "-r",
                            "now"
                        ])
                    }
                }
                Button {
                    text: "Sleep"

                    onClicked: {
                        Quickshell.execDetached([
                            "systemctl",
                            "hybrid-sleep"
                        ])
                    }
                }
            }
        }
    }
}