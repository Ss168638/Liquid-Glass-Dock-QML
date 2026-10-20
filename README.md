# Liquid Glass Dock

An experimental desktop dock built with **Qt Quick (QML)**. It pairs a frosted-glass look, live background refraction, and a playful icon magnification effect with a backend you can run in either **Python (PySide6)** or **C++ (Qt 6 and CMake)**.

<p align="center">
  <img width="1091" alt="Liquid Glass Dock preview" src="https://github.com/user-attachments/assets/0c8ce7d7-ce24-48f7-8127-f4858d90f473" />
</p>

## What’s inside

- **Liquid-glass rendering** with a custom fragment shader, refraction, blur, tint, and edge highlights.
- **A lively dock** with smooth icon magnification, hover labels, and drag-to-move behavior.
- **One QML interface, two backends**: launch it with Python or build it with C++.
- **Desktop capture** to provide the image behind the glass.

## Choose how to run it

Both launch methods use the same QML files and compiled shader. Before launching, choose the shader URL that matches your method in [`GlassSurface.qml`](./GlassSurface.qml).

### Shader URL: choose one

**For Python / PySide6**, use the path relative to the QML files on disk:

```qml
        // fragmentShader: Qt.resolvedUrl("../shaders/liquidglass.frag.qsb") //Uncomment when using CMAKE
        fragmentShader: Qt.resolvedUrl("shaders/liquidglass.frag.qsb")  //Uncomment when using Python
```

**For CMake / Qt Quick resources**, comment out the Python line and use the resource path:

```qml
        fragmentShader: Qt.resolvedUrl("../shaders/liquidglass.frag.qsb") //Uncomment when using CMAKE
        // fragmentShader: Qt.resolvedUrl("shaders/liquidglass.frag.qsb")  //Uncomment when using Python
```

> **Important:** Keep exactly one `fragmentShader` assignment active. The Python runner loads QML from the project directory; the CMake target embeds QML and the shader through `qml.qrc`. The wrong URL can prevent the glass shader from loading.

### Option A — Python (PySide6)

1. Install Python and Git.
2. Clone the repository and enter the project directory:

   ```sh
   git clone https://github.com/Ss168638/Liquid-Glass-Dock-QML.git
   cd Liquid-Glass-Dock-QML
   ```

3. (Recommended) Create and activate a virtual environment:

   ```sh
   python -m venv .venv
   ```

   On Windows PowerShell:

   ```powershell
   .\.venv\Scripts\Activate.ps1
   ```

   On macOS or Linux:

   ```sh
   source .venv/bin/activate
   ```

4. Select the **Python / PySide6** shader URL above, then install the project dependencies:

   ```sh
   python -m pip install -r requirements.txt
   ```

5. Start the dock:

   ```sh
   python app.py
   ```

### Option B — C++ (Qt 6 and CMake)

You’ll need a C++ compiler, CMake, and a Qt 6 installation with the **Core** and **Quick** components. Qt Creator can use a configured desktop kit for these.

1. Clone the repository and open `CMakeLists.txt` in Qt Creator, or configure from a terminal:

   ```sh
   git clone https://github.com/Ss168638/Liquid-Glass-Dock-QML.git
   cd Liquid-Glass-Dock-QML
   cmake -S . -B build
   cmake --build build
   ```

   If CMake cannot find Qt, set `CMAKE_PREFIX_PATH` to your Qt 6 installation or configure the project with a Qt Creator kit.

2. Select the **CMake / Qt Quick resources** shader URL above.
3. Build and run the `LiquidGlass` target from Qt Creator, or launch the executable produced in the build directory.

## Project map

| File | Purpose |
| --- | --- |
| [`main.qml`](./main.qml) | Shared QML window and dock composition |
| [`Dock.qml`](./Dock.qml) | Dock layout, hover interaction, and drag behavior |
| [`DockIcon.qml`](./DockIcon.qml) | Individual app icon presentation |
| [`GlassSurface.qml`](./GlassSurface.qml) | Reusable glass surface and shader hookup |
| [`Wallpaper.qml`](./Wallpaper.qml) | Backdrop image source |
| [`shaders/liquidglass.frag`](./shaders/liquidglass.frag) | Liquid-glass fragment shader source |
| [`shaders/liquidglass.frag.qsb`](./shaders/liquidglass.frag.qsb) | Compiled shader used at runtime |
| [`app.py`](./app.py) | Python entry point and PySide6 dock model |
| [`main.cpp`](./main.cpp) | C++ entry point and Qt image provider |
| [`DockModel.cpp`](./DockModel.cpp), [`DockModel.h`](./DockModel.h) | C++ dock model |
| [`qml.qrc`](./qml.qrc) | QML and shader resources for the CMake build |
| [`requirements.txt`](./requirements.txt) | Python dependencies |

## Troubleshooting

- **The glass effect is missing:** Confirm the matching shader URL is active and the other one is commented out.
- **Python reports a missing Qt module:** Activate the intended virtual environment and run `python -m pip install -r requirements.txt` again.
- **CMake can’t locate Qt:** Point `CMAKE_PREFIX_PATH` at the Qt 6 installation that matches your compiler, or select the corresponding kit in Qt Creator.

## Known issue

The window in `main.qml` is currently 200 pixels tall. Its transparent area blocks mouse clicks outside the visible dock, preventing them from reaching the desktop. Reduce the window height or constrain its input area to the dock.

## License

Distributed under the [MIT License](./LICENSE).

## AI Assistance

AI tools were used as a development aid for this project. The project author is responsible for its design, implementation, and maintenance.
