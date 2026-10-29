import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Widgets

Button {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter

    contentItem: IconImage {
        source: root.adapter?.enabled
            ? Qt.resolvedUrl("../icons/bt-enabled.svg")
            : Qt.resolvedUrl("../icons/bt-disabled.svg")
        implicitHeight: 22
        implicitWidth: 22
    }

    background: Rectangle {
        color: "transparent"
    }

    onClicked: bluetoothPopup.visible = !bluetoothPopup.visible

    PopupWindow {
        id: bluetoothPopup

        visible: false
        implicitWidth: 360
        implicitHeight: 420
        grabFocus: true
        color: "transparent"

        anchor {
            item: root
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

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        Layout.fillWidth: true
                        text: "Bluetooth"
                        color: "white"
                        font.bold: true
                    }

                    Switch {
                        checked: root.adapter?.enabled ?? false
                        enabled: root.adapter !== null

                        onToggled: {
                            if (root.adapter)
                                root.adapter.enabled = checked
                        }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    enabled: root.adapter?.enabled ?? false
                    text: root.adapter?.discovering
                        ? "Stop scanning"
                        : "Scan for devices"

                    onClicked: {
                        root.adapter.discovering = !root.adapter.discovering
                    }
                }

                ListView {
                    id: deviceList

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    clip: true
                    spacing: 6
                    model: root.adapter?.devices ?? null

                    delegate: Rectangle {
                        id: deviceDelegate

                        required property var modelData

                        height: 52
                        width: ListView.view.width
                        color: "#3c3836"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    text: deviceDelegate.modelData.name
                                    color: "white"
                                }

                                Label {
                                    text: deviceDelegate.modelData.address
                                    color: "#bdae93"
                                    font.pixelSize: 10
                                }
                            }

                            Button {
                                text: {
                                    if (deviceDelegate.modelData.connected)
                                        return "Disconnect"

                                    if (deviceDelegate.modelData.paired)
                                        return "Connect"

                                    return "Pair"
                                }

                                onClicked: {
                                    const device = deviceDelegate.modelData

                                    if (device.connected)
                                        device.disconnect()
                                    else if (device.paired)
                                        device.connect()
                                    else
                                        device.pair()
                                }
                            }
                        }
                    }
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    visible: deviceList.count === 0
                    text: root.adapter?.discovering
                        ? "Searching..."
                        : "Press Scan for devices"
                }
            }
        }
    }
}
