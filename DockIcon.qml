import QtQuick

// One app tile. The slot keeps the base height so the row stays bottom-aligned;
// the tile itself grows upward when magnified.
Item {
    id: icon

    required property string name
    required property string glyph
    required property color colorA
    required property color colorB
    required property bool running
    property real baseSize: 56
    property real size: baseSize

    signal clicked()

    width: size
    height: baseSize

    property real lift: 0   // bounce offset

    Rectangle {
        id: tile
        width: icon.size
        height: icon.size
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: icon.lift
        radius: width * 0.23
        antialiasing: true
        gradient: Gradient {
            GradientStop { position: 0.0; color: icon.colorA }
            GradientStop { position: 1.0; color: icon.colorB }
        }

        // Top gloss.
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.35) }
                GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.0) }
            }
            border.color: Qt.rgba(1, 1, 1, 0.25)
            border.width: 1
        }

        TapHandler {
            onTapped: {
                icon.launch();
                icon.clicked();
            }
        }

        Text {
            anchors.centerIn: parent
            text: icon.glyph
            color: "white"
            font.pixelSize: icon.size * 0.46
            font.bold: true
            style: Text.Raised
            styleColor: Qt.rgba(0, 0, 0, 0.25)
        }
    }

    Rectangle {
        width: 5
        height: 5
        radius: 2.5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: 4
        color: Qt.rgba(1, 1, 1, 0.9)
        opacity: icon.running ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    SequentialAnimation {
        id: bounce
        loops: 2
        NumberAnimation { target: icon; property: "lift"; to: icon.baseSize * 0.45; duration: 220; easing.type: Easing.OutQuad }
        NumberAnimation { target: icon; property: "lift"; to: 0; duration: 260; easing.type: Easing.OutBounce }
    }

    function launch() {
        if (!running)
            bounce.restart();
        running = !running;
    }
}
