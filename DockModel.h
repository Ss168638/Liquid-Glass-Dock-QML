#ifndef DOCKMODEL_H
#define DOCKMODEL_H

#include <QAbstractListModel>
#include <QProcess>
#include <QDesktopServices>
#include <QUrl>

struct AppItem {
    QString name;
    QString glyph;
    QString colorA;
    QString colorB;
    bool running;
};

class DockModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum AppRoles {
        NameRole = Qt::UserRole + 1,
        GlyphRole,
        ColorARole,
        ColorBRole,
        RunningRole
    };

    explicit DockModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role) const override;

    QHash<int, QByteArray> roleNames() const override {
        return {
            {NameRole, "name"},
            {GlyphRole, "glyph"},
            {ColorARole, "colorA"},
            {ColorBRole, "colorB"},
            {RunningRole, "running"}
        };
    }

    // Plug-and-play method to add items programmatically from C++
    Q_INVOKABLE void addApp(const QString &name, const QString &glyph, const QString &colorA, const QString &colorB, bool running);

    // Backend click and launch handler
    Q_INVOKABLE void handleAppClicked(int index);

private:
    QVector<AppItem> m_apps;
};

#endif // DOCKMODEL_H
