#ifndef DRIVEMANAGER_H
#define DRIVEMANAGER_H

#include <QObject>
#include <QAbstractListModel>
#include <QStringList>

class DriveInfo {
public:
    QString name;
    QString path;
    QString totalSize;
    QString freeSpace;
    quint64 totalBytes = 0;
    quint64 freeBytes = 0;
};

class DriveManager : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        PathRole,
        TotalSizeRole,
        FreeSpaceRole
    };

    explicit DriveManager(QObject *parent = nullptr);
    ~DriveManager();

    Q_INVOKABLE void refreshDrives();
    Q_INVOKABLE DriveInfo driveAt(int index) const;
    Q_INVOKABLE int driveCount() const { return m_drives.size(); }

protected:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    QString formatSize(quint64 bytes) const;

    QList<DriveInfo> m_drives;
};

#endif // DRIVEMANAGER_H
