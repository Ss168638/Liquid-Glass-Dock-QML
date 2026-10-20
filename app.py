import sys
import ctypes
from pathlib import Path
from PySide6.QtCore import Qt, QAbstractListModel, QModelIndex, QByteArray, Slot
from PySide6.QtGui import QGuiApplication, QScreen, QPixmap
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuick import QQuickImageProvider
import subprocess
import webbrowser

# 1. Live Desktop Screenshot Provider for Glass Backdrops
class DesktopImageProvider(QQuickImageProvider):
    def __init__(self):
        super().__init__(QQuickImageProvider.Pixmap)

    def requestPixmap(self, id, size, requestedSize):
        screen = QGuiApplication.primaryScreen()
        if not screen:
            return QPixmap(), QSize()
        px = screen.grabWindow(0)
        if size is not None:
            size.setWidth(px.width())
            size.setHeight(px.height())
        return px

# 2. Python Backend Model for Dock Apps
class DockModel(QAbstractListModel):
    NameRole = Qt.UserRole + 1
    GlyphRole = Qt.UserRole + 2
    ColorARole = Qt.UserRole + 3
    ColorBRole = Qt.UserRole + 4
    RunningRole = Qt.UserRole + 5

    def __init__(self, parent=None):
        super().__init__(parent)
        self._apps = [
            {"name": "Finder",   "glyph": "F", "colorA": "#5ac8fa", "colorB": "#0a6cff", "running": True},
            {"name": "Safari",   "glyph": "S", "colorA": "#64d2ff", "colorB": "#1e7bd6", "running": False},
            {"name": "Mail",     "glyph": "M", "colorA": "#7ab8ff", "colorB": "#2f5bea", "running": True},
            {"name": "Music",    "glyph": "♪", "colorA": "#ff6b81", "colorB": "#e0245e", "running": False},
            {"name": "Photos",   "glyph": "P", "colorA": "#ffd166", "colorB": "#ef476f", "running": False},
            {"name": "Notes",    "glyph": "N", "colorA": "#ffe680", "colorB": "#f7b500", "running": False},
            {"name": "Terminal", "glyph": ">", "colorA": "#4a4a4a", "colorB": "#111111", "running": True},
            {"name": "Settings", "glyph": "⚙", "colorA": "#b0b6bf", "colorB": "#5d6470", "running": False}
        ]

    def rowCount(self, parent=QModelIndex()):
        return len(self._apps)

    def data(self, index, role):
        if not index.isValid() or index.row() >= len(self._apps):
            return None
        app = self._apps[index.row()]
        if role == self.NameRole: return app["name"]
        elif role == self.GlyphRole: return app["glyph"]
        elif role == self.ColorARole: return app["colorA"]
        elif role == self.ColorBRole: return app["colorB"]
        elif role == self.RunningRole: return app["running"]
        return None

    def roleNames(self):
        return {
            self.NameRole: b"name",
            self.GlyphRole: b"glyph",
            self.ColorARole: b"colorA",
            self.ColorBRole: b"colorB",
            self.RunningRole: b"running"
        }

    @Slot(int)
    def handleAppClicked(self, index):
        if 0 <= index < len(self._apps):
            app = self._apps[index]
            app["running"] = not app["running"]
            self.dataChanged.emit(self.index(index, 0), self.index(index, 0), [self.RunningRole])
            
            # Backend process launcher
            name = app["name"]
            if name == "Finder":
                subprocess.Popen("explorer.exe")
            elif name == "Safari":
                webbrowser.open("https://www.google.com")
            elif name == "Notes":
                subprocess.Popen("notepad.exe")
            elif name == "Terminal":
                subprocess.Popen("wt.exe" if sys.platform == "win32" else "powershell.exe")
            elif name == "Settings":
                subprocess.Popen("cmd /c start ms-settings:")

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    
    engine = QQmlApplicationEngine()
    engine.addImageProvider("desktop", DesktopImageProvider())
    
    dockModel = DockModel()
    engine.rootContext().setContextProperty("dockModel", dockModel)
    
    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.load(str(qml_file))
    
    if not engine.rootObjects():
        sys.exit(-1)

    # Exclude the dock window from screen capture on Windows
    # so the glass shader only refracts the background behind the dock
    if sys.platform == "win32":
        root_window = engine.rootObjects()[0]
        hwnd = int(root_window.winId())
        WDA_EXCLUDEFROMCAPTURE = 0x00000011
        ctypes.windll.user32.SetWindowDisplayAffinity(hwnd, WDA_EXCLUDEFROMCAPTURE)
        
    sys.exit(app.exec())