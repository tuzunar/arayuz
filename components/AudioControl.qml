import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets

RowLayout {
    id: root

    readonly property var audioSink: Pipewire.defaultAudioSink
    readonly property bool hasAudio: audioSink !== null && audioSink.audio !== null
    property bool listDevices: true
    
    spacing: 4

    function switchOutput(sink) {
        if (!sink || !sink.isSink || sink.isStream)
            return

        if (!sink.ready) {
            console.warn("Sink is not ready:", sink.name)
            return
        }

        const targetSerial = sink.properties["object.serial"]

        if (targetSerial === undefined) {
            console.warn("Sink has no object.serial:", sink.name)
            return
        }

        Pipewire.preferredDefaultAudioSink = sink

        for (const stream of Pipewire.nodes.values) {
            if (stream.isStream && stream.isSink && stream.audio !== null) {
                Quickshell.execDetached([
                    "pw-metadata",
                    "-n", "default",
                    String(stream.id),
                    "target.object",
                    String(targetSerial),
                    "Spa:Id"
                ])
            }
        }
    }

    PwObjectTracker {
        objects: Pipewire.nodes.values.filter(node =>
            node.audio !== null && node.isSink
        )
    }

    IconImage {
        source: root.hasAudio && root.audioSink.audio.muted
            ? Qt.resolvedUrl("../icons/volume-disabled.svg")
            : Qt.resolvedUrl("../icons/volume-enabled.svg")
        implicitHeight: 24
        implicitWidth: 24

        MouseArea {
            anchors.fill: parent
            onClicked: audioPopup.visible = !audioPopup.visible
        }
    }

    Slider {
        implicitWidth: 200
        value: root.hasAudio ? root.audioSink.audio.volume : 0

        onMoved: {
            if (root.hasAudio)
                root.audioSink.audio.volume = value
        }
    }

    Text {
        text: root.hasAudio
            ? Math.round(root.audioSink.audio.volume * 100)
            : "--"
    }

    PopupWindow {
        id: audioPopup

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

                Button {
                    Layout.fillWidth: true

                    onClicked: root.listDevices = !root.listDevices

                    text: root.listDevices 
                        ? "Show Applications"
                        : "Show Devices"
                }
                ListView {
                    visible: !root.listDevices
                    Layout.fillHeight:true
                    Layout.fillWidth:true
                    anchors.margins: 12
                    clip: true
                    spacing: 6

                    model: ScriptModel {
                        values: Pipewire.nodes.values.filter(node =>
                            node.audio !== null
                            && node.isSink
                            && node.isStream
                        )
                    }

                    delegate: Rectangle {
                        id: applicationsSound

                        required property var modelData

                        height: 52
                        width: ListView.view.width
                        color: "#3c3836"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8

                            Label {
                                text: applicationsSound.modelData.name
                                color: "white"
                                font.pixelSize: 12
                            }

                            Slider {
                                Layout.fillWidth: true
                                value: applicationsSound.modelData.audio.volume

                                onMoved: {
                                    applicationsSound.modelData.audio.volume = value
                                }
                            }
                            Text {
                                text: Math.round(applicationsSound.modelData.audio.volume * 100)
                                color: "white"
                                font.pixelSize: 12
                            }
                        }
                    }
                }
                ListView {
                    visible: root.listDevices
                    Layout.fillHeight:true
                    Layout.fillWidth:true
                    anchors.margins: 12
                    clip: true
                    spacing: 6

                    model: ScriptModel {
                        values: Pipewire.nodes.values.filter(node =>
                            node.audio !== null
                            && node.isSink
                            && !node.isStream
                        )
                    }

                    delegate: Rectangle {
                        id: sinkDelegate

                        required property var modelData

                        height: 52
                        width: ListView.view.width
                        color: "#3c3836"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8

                            ColumnLayout {
                                Layout.fillWidth: true

                                Label {
                                    text: sinkDelegate.modelData.nickname
                                    color: "white"
                                    font.pixelSize: 12
                                }

                                Label {
                                    text: sinkDelegate.modelData.description
                                    color: "#bdae93"
                                    font.pixelSize: 10
                                }
                            }

                            Button {
                                text: "Make Default"
                                onClicked: root.switchOutput(sinkDelegate.modelData)
                            }
                        }
                    }
                }

            }
        }
    }
}
