import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

RowLayout {
    id: root

    required property var panelWindow

    Layout.preferredWidth: trayItems.width + 20
    Layout.fillHeight: true
    Layout.rightMargin: 6
    spacing: 6

    Repeater {
        id: trayItems

        model: SystemTray.items

        delegate: Image {
            id: trayIcon

            required property var modelData

            source: modelData.icon
            sourceSize.height: 22
            sourceSize.width: 22

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        trayIcon.modelData.activate()
                    } else if (mouse.button === Qt.MiddleButton) {
                        trayIcon.modelData.secondaryActivate()
                    } else if (
                        mouse.button === Qt.RightButton
                        && trayIcon.modelData.hasMenu
                    ) {
                        const position = root.panelWindow.itemPosition(trayIcon)
                        trayIcon.modelData.display(
                            root.panelWindow,
                            position.x,
                            position.y + trayIcon.height
                        )
                    }
                }

                onWheel: wheel => {
                    trayIcon.modelData.scroll(wheel.angleDelta.y, false)
                }
            }
        }
    }
}
