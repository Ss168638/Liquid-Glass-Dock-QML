#include "dockmodel.h"

DockModel::DockModel(QObject *parent) : QAbstractListModel(parent) {
    // Default plug-and-play items injected from the backend
    m_apps = {
        {"Finder",   "F", "#5ac8fa", "#0a6cff", true},
        {"Safari",   "S", "#64d2ff", "#1e7bd6", false},
        {"Mail",     "M", "#7ab8ff", "#2f5bea", true},
        {"Music",    "♪", "#ff6b81", "#e0245e", false},
        {"Photos",   "P", "#ffd166", "#ef476f", false},
        {"Notes",    "N", "#ffe680", "#f7b500", false},
        {"Terminal", ">", "#4a4a4a", "#111111", true},
        {"Settings", "⚙", "#b0b6bf", "#5d6470", false}
    };
}

int DockModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid())
        return 0;
    return m_apps.size();
}

QVariant DockModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_apps.size())
        return QVariant();

    const auto &app = m_apps[index.row()];
    switch (role) {
    case NameRole:   return app.name;
    case GlyphRole:  return app.glyph;
    case ColorARole: return app.colorA;
    case ColorBRole: return app.colorB;
    case RunningRole:return app.running;
    }
    return QVariant();
}

void DockModel::addApp(const QString &name, const QString &glyph, const QString &colorA, const QString &colorB, bool running) {
    beginInsertRows(QModelIndex(), m_apps.size(), m_apps.size());
    m_apps.append({name, glyph, colorA, colorB, running});
    endInsertRows();
}

void DockModel::handleAppClicked(int index) {
    if (index < 0 || index >= m_apps.size())
        return;

    auto &app = m_apps[index];
    app.running = !app.running;
    emit dataChanged(createIndex(index, 0), createIndex(index, 0), {RunningRole});

    // Handle real system execution in C++
    if (app.name == "Finder")
        QProcess::startDetached("explorer.exe", QStringList());
    else if (app.name == "Safari")
        QDesktopServices::openUrl(QUrl("https://www.google.com"));
    else if (app.name == "Notes")
        QProcess::startDetached("notepad.exe", QStringList());
    else if (app.name == "Terminal")
        QProcess::startDetached("wt.exe", QStringList());
    else if (app.name == "Settings")
        QProcess::startDetached("cmd.exe", {"/c", "start", "ms-settings:"});
}
