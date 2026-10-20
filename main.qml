import QtQuick

Window {
    id: window
    width: 820
    height: 200
    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.NoDropShadowWindowHint | Qt.Tool
    title: "LiquidGlass"

    Component.onCompleted: {
        x = (Screen.width - width) / 2
        y = Screen.desktopAvailableHeight - height - 10
    }

    Wallpaper {
        id: wallpaper
    }

    Dock {
        id: dock
        objectName: "dock"
        backdrop: wallpaper
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 28
    }
}
