# <center> Liquid-Glass-Dock-QML </center>
<center> <img width="2182" height="1044" alt="LiquidGlassDock" src="https://github.com/user-attachments/assets/0c8ce7d7-ce24-48f7-8127-f4858d90f473" /> </center>

Liquid-Glass-Dock-QML is a high-performance, GPU-accelerated desktop dock that brings macOS-style liquid glass vibrancy, real-time background refraction, and smooth icon magnification physics to Windows and Linux using Qt Quick (QML) with dual C++ (Qt 6) and Python (PySide6) backend support.

✨ Key Features

True Glass Refraction & Blur: Uses custom shaders and live desktop capture to simulate real macOS frosted glass.

Fluid Magnification Wave: Smooth zoom effect and tooltips as you hover across icons.

Plug & Play Backend: Clean separation where QML handles the rendering UI while C++ or Python manage app models and system process execution.

Click-Through Window: Stays pinned on top of your desktop while allowing clicks to pass through empty spaces.

🐍 Python Setup & Running

Install Dependencies:

pip install PySide6


Clone the Repository & Navigate:

git clone https://github.com/YOUR_USERNAME/Liquid-Glass-Dock-QML.git
cd Liquid-Glass-Dock-QML


Run the Application:

python app.py


⚡ C++ Setup & Running (Qt 6 & CMake)

Open the Project:

Open Qt Creator and select File > Open File or Project...

Choose the CMakeLists.txt file in the project root.

Configure Kit:

Select your desktop Qt 6 Kit (e.g., MinGW or MSVC).

Ensure your CMake binary is correctly linked in Qt Creator preferences.

Build & Run:

Switch to Release mode in the bottom-left corner of Qt Creator.

Press Ctrl + R to compile and run.

🛠️ Project Structure

main.qml / main.cpp - C++ entry point, window setup, and native desktop image provider.

app.py - Python equivalent entry point and PySide6 model runner.

Dock.qml - Main dock container, mouse interaction, and backend model integration.

GlassSurface.qml - Custom liquid glass refraction shader handler.

DockIcon.qml - App tile, bounce animation, and indicator dot.

Wallpaper.qml - Full-window background capture canvas.

📄 License

Distributed under the MIT License. See LICENSE for more information.
