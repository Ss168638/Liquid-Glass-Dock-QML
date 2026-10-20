#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QScreen>
#include <QWindow>
#include <QPixmap>
#include <QQuickImageProvider>
#include "DockModel.h"

#ifdef Q_OS_WIN
#include <windows.h>
#ifndef WDA_EXCLUDEFROMCAPTURE
#define WDA_EXCLUDEFROMCAPTURE 0x00000011
#endif
#endif

// Provides live desktop screenshots to QML via "image://desktop/capture"
class DesktopImageProvider : public QQuickImageProvider
{
public:
    DesktopImageProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap) {}

    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override
    {
        Q_UNUSED(id);
        Q_UNUSED(requestedSize);
        QScreen *screen = QGuiApplication::primaryScreen();
        if (!screen)
            return QPixmap();

        // Grabs the full primary screen (our window is automatically excluded via WDA_EXCLUDEFROMCAPTURE)
        QPixmap px = screen->grabWindow(0);
        if (size)
            *size = px.size();
        return px;
    }
};

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.addImageProvider(QLatin1String("desktop"), new DesktopImageProvider);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    DockModel dockModel;
    engine.rootContext()->setContextProperty("dockModel", &dockModel);
    engine.load(url);

    if (engine.rootObjects().isEmpty())
        return -1;

#ifdef Q_OS_WIN
    if (auto *w = qobject_cast<QWindow *>(engine.rootObjects().constFirst())) {
        // Excludes this Qt window from QScreen::grabWindow(0) so it only grabs the OS behind it!
        SetWindowDisplayAffinity(reinterpret_cast<HWND>(w->winId()), WDA_EXCLUDEFROMCAPTURE);
    }
#endif

    return app.exec();
}
