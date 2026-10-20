import QtQuick

// Provides the full-window sharp background texture to GlassSurface
// while remaining invisible on the transparent window itself.
Item {
    id: wall
    anchors.fill: parent

    // Keeps the item alive in the GPU scene graph for ShaderEffectSource,
    // while hiding it from direct screen drawing so the window stays transparent!
//    layer.enabled: true
//    layer.effect: ShaderEffect {
//        // Discards direct window drawing while keeping the layer texture intact
//        fragmentShader: ""
//    }

    // 1. Rich macOS-style vibrant fallback canvas (ensures glass always has
    //    deep color refraction & contrast even if OS screen capture is black/empty)
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#ff2a85" }
            GradientStop { position: 0.35; color: "#7928ca" }
            GradientStop { position: 0.7; color: "#0070f3" }
            GradientStop { position: 1.0; color: "#00dfd8" }
        }
    }

    // 2. Live Windows OS Desktop Capture sitting behind the window
    Image {
        id: osScreenImage
        x: -wall.Window.window.x
        y: -wall.Window.window.y
        width: Screen.width
        height: Screen.height
        cache: false
        smooth: true
        source: "image://desktop/frame_0"
    }

    // Refreshes the OS backdrop ~30 times per second
    Timer {
        interval: 33
        running: true
        repeat: true
        property int frameCounter: 0
        onTriggered: {
            frameCounter = (frameCounter + 1) % 1000
            osScreenImage.source = "image://desktop/frame_" + frameCounter
        }
    }
}
