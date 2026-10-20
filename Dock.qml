import QtQuick

Item {
    id: dock

    required property Item backdrop

    property real baseSize: 56
    property real maxScale: 1.75
    property real influence: 170
    property real spacing: 12
    property real padding: 12

    // Bound to C++ backend model
    property var apps: dockModel

    // Use rowCount() instead of .count for C++ models
    readonly property real rowCount: apps ? apps.rowCount() : 0
    readonly property real step: baseSize + spacing
    readonly property real baseWidth: rowCount * baseSize + Math.max(0, rowCount - 1) * spacing + 2 * padding

    readonly property bool hovering: hover.hovered
    readonly property real hoverX: hover.point.position.x - hoverZone.extra
    readonly property int hoveredIndex: hovering && apps
        ? Math.max(0, Math.min(rowCount - 1, Math.floor((hoverX - padding + spacing / 2) / step)))
        : -1

    property real magnify: hovering && !mover.dragging ? 1 : 0
    Behavior on magnify { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    function scaleAt(index) {
        const centre = padding + index * step + baseSize / 2;
        const dist = Math.abs(hoverX - centre);
        if (dist >= influence)
            return 1;
        const wave = (Math.cos(Math.PI * dist / influence) + 1) / 2;
        return 1 + (maxScale - 1) * wave * magnify;
    }

    function iconAt(x, y) {
        for (let i = 0; i < repeater.count; ++i) {
            const it = repeater.itemAt(i);
            if (!it) continue;
            const inColumn = x >= it.x - spacing / 2 && x < it.x + it.width + spacing / 2;
            const inTile = y >= baseSize - it.size - it.lift && y <= baseSize + padding;
            if (inColumn && inTile)
                return it;
        }
        return null;
    }

    width: row.width + 2 * padding
    height: baseSize + 2 * padding

    GlassSurface {
        id: glass
        anchors.fill: parent
        backdrop: dock.backdrop
        radius: 26
        bezel: 18
        pointer: dock.hovering
            ? Qt.point(hover.point.position.x + hoverZone.x, hover.point.position.y + hoverZone.y)
            : Qt.point(-1, -1)
    }

    // Hover zone using HoverHandler as originally configured
    Item {
        id: hoverZone
        readonly property real extra: dock.baseSize * (dock.maxScale - 1)
        x: (dock.width - dock.baseWidth) / 2 - extra
        y: -extra
        width: dock.baseWidth + 2 * extra
        height: dock.height + extra
        HoverHandler { id: hover }
    }

    Row {
        id: row
        x: dock.padding
        y: dock.padding
        spacing: dock.spacing

        Repeater {
            id: repeater
            model: dockModel
            delegate: DockIcon {
                required property int index
                baseSize: dock.baseSize
                size: dock.baseSize * dock.scaleAt(index)
            }
        }
    }

    // Dragging and clicking logic
    MouseArea {
        id: mover
        anchors.fill: hoverZone
        acceptedButtons: Qt.LeftButton

        property bool dragging: false
        property point pressGlobal
        property point windowStart

        onPressed: (mouse) => {
            dragging = false;
            pressGlobal = mapToGlobal(mouse.x, mouse.y);
            windowStart = Qt.point(dock.Window.window.x, dock.Window.window.y);
        }
        onPositionChanged: (mouse) => {
            const g = mapToGlobal(mouse.x, mouse.y);
            const dx = g.x - pressGlobal.x;
            const dy = g.y - pressGlobal.y;
            if (!dragging && Math.hypot(dx, dy) < Qt.styleHints.startDragDistance)
                return;
            dragging = true;
            dock.Window.window.x = windowStart.x + dx;
            dock.Window.window.y = windowStart.y + dy;
        }
        onClicked: (mouse) => {
            if (dragging)
                return;
            const p = mapToItem(row, mouse.x, mouse.y);
            const icon = dock.iconAt(p.x, p.y);
            if (icon) {
                icon.launch();
                icon.clicked();
                dockModel.handleAppClicked(icon.index);
            }
        }
        onReleased: dragging = false
    }

    GlassSurface {
        id: tip
        readonly property Item target: repeater.itemAt(Math.max(dock.hoveredIndex, 0))
        backdrop: dock.backdrop
        width: label.implicitWidth + 28
        height: 30
        bezel: 9
        refraction: 12
        shadow: 0.15
        x: target ? row.x + target.x + target.width / 2 - width / 2 : 0
        y: -dock.baseSize * (dock.maxScale - 1) - height - 10
        opacity: dock.hoveredIndex >= 0 && dock.magnify > 0.5 ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Text {
            id: label
            anchors.centerIn: parent
            text: tip.target && tip.target.name ? tip.target.name : ""
            color: "white"
            font.pixelSize: 14
            font.weight: Font.DemiBold
            style: Text.Raised
            styleColor: Qt.rgba(0, 0, 0, 0.35)
        }
    }
}
