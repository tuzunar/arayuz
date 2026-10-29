import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Rectangle {
    id: root

    Layout.preferredWidth: workspaceRow.width + 20
    Layout.fillHeight: true

    Row {
        id: workspaceRow

        anchors.left: parent.left
        anchors.leftMargin: 10

        Repeater {
            model: Hyprland.workspaces

            delegate: Item {
                required property var modelData

                width: 22
                height: 22

                Image {
                    anchors.fill: parent
                    source: modelData.active
                        ? Qt.resolvedUrl("../icons/circle-selected.svg")
                        : Qt.resolvedUrl("../icons/circle-empty.svg")
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: modelData.activate()
                }
            }
        }
    }
}
