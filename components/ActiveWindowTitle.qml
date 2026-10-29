import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland

Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true

    Text {
        anchors.centerIn: parent
        width: parent.width - 20
        text: ToplevelManager.activeToplevel?.title ?? ""
        color: "#000"
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 14
    }
}
