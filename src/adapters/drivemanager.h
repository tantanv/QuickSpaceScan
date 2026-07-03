#ifndef DRIVEMANAGER_H
#define DRIVEMANAGER_H

#include <QObject>
#include <QAbstractListModel>
#include <QStringList>

class DriveInfo {
    Q_GADGET
    Q_PROPERTY(QString name MEMBER name)
    Q_PROPERTY(QString path MEMBER path)
    Q_PROPERTY(QString totalSize MEMBER totalSize)
    Q_PROPERTY(QString freeSpace MEMBER freeSpace)
    Q_PROPERTY(quint64 totalBytes MEMBER totalBytes)
    Q_PROPERTY(quint64 freeBytes MEMBER freeBytes)
public:
    QString name;
    QString path;
    QString totalSize;
    QString freeSpace;
    quint64 totalBytes = 0;
    quint64 freeBytes = 0;
};
Q_DECLARE_METATYPE(DriveInfo)

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
