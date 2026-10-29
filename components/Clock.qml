import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property date now: new Date()

    Layout.fillHeight: true
    spacing: 0

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatDate(root.now, "dd/MM/yy")
        font.pixelSize: 14
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatTime(root.now, "HH:mm")
        font.pixelSize: 13
    }
}
