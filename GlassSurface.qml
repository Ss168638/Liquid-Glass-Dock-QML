import QtQuick

// Reusable Liquid Glass panel.
//
//   backdrop ──► capture (mipmapped ShaderEffectSource, region under the glass + margin)
//                  └──► ShaderEffect(liquidglass.frag)
//                         sharp  = base mip level
//                         frost  = high mip level + 9-tap tent (blur in-shader)
//
// Only QtQuick is needed: no QtQuick.Effects plugin.
//
// `backdrop` must not contain this item, or the glass would sample itself.
Item {
    id: root

    required property Item backdrop

    property real radius: height / 2
    property real bezel: 16
    property real refraction: 26
    property real dispersion: 0.3
    property real frost: 0.55
    property real blurRadius: 12      // px
    property real saturation: 1.35
    property real specular: 0.8
    property real shadow: 0.22
    property vector2d lightDir: Qt.vector2d(-0.45, -0.9)
    property point pointer: Qt.point(-1, -1)
    property color tint: Qt.rgba(1, 1, 1, 0.10)

    // Room around the shape for rim refraction and the drop shadow.
    readonly property real margin: Math.ceil(refraction * (1 + dispersion)) + 28

    default property alias content: contentLayer.data

    // Backdrop pixels under the glass, including the margin.
    ShaderEffectSource {
        id: capture
        visible: false
        width: glass.width
        height: glass.height
        sourceItem: root.backdrop
        hideSource: true  // <-- ADD THIS LINE: Hides the raw wallpaper from the transparent window, so it ONLY appears inside the glass!
        live: true
        mipmap: true      // pre-averaged levels feed the in-shader blur
        textureSize: Qt.size(width * Screen.devicePixelRatio, height * Screen.devicePixelRatio)
        sourceRect: {
            // Re-evaluate when this item or its parent moves/resizes.
            void (root.x + root.y + root.width + root.height + root.margin);
            if (root.parent)
                void (root.parent.x + root.parent.y + root.parent.width + root.parent.height);
            const p = root.mapToItem(root.backdrop, 0, 0);
            return Qt.rect(p.x - root.margin, p.y - root.margin, glass.width, glass.height);
        }
    }

    ShaderEffect {
        id: glass
        x: -root.margin
        y: -root.margin
        width: root.width + 2 * root.margin
        height: root.height + 2 * root.margin

        property variant source: capture
        property real blurRadius: root.blurRadius
        property real blurLod: Math.log2(Math.max(root.blurRadius, 1) * Screen.devicePixelRatio) - 1
        property size canvasSize: Qt.size(width, height)
        property size shapeSize: Qt.size(root.width, root.height)
        property real radius: root.radius
        property real bezel: root.bezel
        property real refraction: root.refraction
        property real dispersion: root.dispersion
        property real frost: root.frost
        property real saturation: root.saturation
        property real specular: root.specular
        property real shadow: root.shadow
        property vector2d lightDir: root.lightDir
        property point pointer: root.pointer
        property vector4d tint: Qt.vector4d(root.tint.r, root.tint.g, root.tint.b, root.tint.a)

        // fragmentShader: Qt.resolvedUrl("../shaders/liquidglass.frag.qsb") //Uncomment when using CMAKE
        fragmentShader: Qt.resolvedUrl("shaders/liquidglass.frag.qsb")  //Uncomment when using Python
    }

    Item {
        id: contentLayer
        anchors.fill: parent
    }
}
