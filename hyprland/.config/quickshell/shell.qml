import Quickshell
import QtQuick
import "./"

ShellRoot {
    PanelWindow {
        anchors {
            left: true
            right: true
        }
        height: 650
        color: "transparent"
        
        // THE MAGIC FLAG:
        focusable: true

        WallpaperPicker { anchors.fill: parent }
    }
}
