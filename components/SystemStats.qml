import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Widgets

RowLayout {
    id: root

    property real memoryPercent: 0
    property real cpuPercentage: 0
    property double previousCpuTotal: 0
    property double previousCpuIdle: 0
    property real gpuUsagePercent: 0

    Layout.rightMargin: 3
    Layout.leftMargin: 3
    spacing: 3

    function updateCpuUsage() {
        const firstLine = cpuFile.text().split("\n")[0]
        const fields = firstLine.trim().split(/\s+/)

        if (fields[0] !== "cpu")
            return

        const values = fields.slice(1).map(Number)
        const idle = values[3] + (values[4] ?? 0)
        const total = values.slice(0, 8).reduce(
            (sum, value) => sum + value,
            0
        )

        if (previousCpuTotal > 0) {
            const totalDifference = total - previousCpuTotal
            const idleDifference = idle - previousCpuIdle

            if (totalDifference > 0) {
                cpuPercentage = (
                    totalDifference - idleDifference
                ) / totalDifference * 100
            }
        }

        previousCpuTotal = total
        previousCpuIdle = idle
    }

    function memoryValue(name) {
        const expression = new RegExp("^" + name + ":\\s+(\\d+)", "m")
        const match = memoryFile.text().match(expression)
        return match ? Number(match[1]) : 0
    }

    function updateMemoryUsage() {
        const total = memoryValue("MemTotal")
        const available = memoryValue("MemAvailable")
        const used = total - available

        memoryPercent = total > 0 ? used / total * 100 : 0
    }

    Process {
        running: true

        command:[
            "nvidia-smi",
            "--query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu",
            "--format=csv,noheader,nounits",
            "--loop=2"
        ] 

        stdout: SplitParser {
            onRead: line => {
                const values = line.trim().split(",")
                let gpuUsage = Number(values[0].trim()) 

                root.gpuUsagePercent = gpuUsage
            }
        }
    }

    FileView {
        id: cpuFile

        path: "/proc/stat"
        blockLoading: true
        onTextChanged: root.updateCpuUsage()
    }

    FileView {
        id: memoryFile

        path: "/proc/meminfo"
        blockLoading: true
        onTextChanged: root.updateMemoryUsage()
    }

    Timer {
        interval: 2000
        running: true
        repeat: true

        onTriggered: {
            cpuFile.reload()
            memoryFile.reload()
        }
    }

    IconImage {
        source: Qt.resolvedUrl("../icons/cpu.svg")
        implicitHeight: 20
        implicitWidth: 20
    }
    Text {
        text: `${root.cpuPercentage.toFixed(0)}%`
    }

    IconImage {
        source: Qt.resolvedUrl("../icons/ram.svg")
        implicitHeight: 24
        implicitWidth: 24
    }
    Text {
        text: `${root.memoryPercent.toFixed(0)}%`
    }

    IconImage {
        source: Qt.resolvedUrl("../icons/gpu.svg")
        implicitHeight: 24
        implicitWidth: 24
    }
    Text {
        text: `${root.gpuUsagePercent.toFixed(0)}%`
    }
}
