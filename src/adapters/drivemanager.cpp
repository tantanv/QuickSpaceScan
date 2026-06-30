#include "drivemanager.h"
#include <QStorageInfo>
#include <QDir>

DriveManager::DriveManager(QObject *parent)
    : QAbstractListModel(parent)
{
    refreshDrives();
}

DriveManager::~DriveManager()
{
}

void DriveManager::refreshDrives()
{
    beginResetModel();
    m_drives.clear();

    const QList<QStorageInfo> infos = QStorageInfo::mountedVolumes();

    for (const QStorageInfo &info : infos) {
        if (!info.isValid() || !info.isReady()) {
            continue;
        }

        DriveInfo drive;
        QString rootPath = info.rootPath();
        QString driveLetter = rootPath.left(2);
        QString volumeName = info.name();
        if (volumeName.isEmpty()) {
            drive.name = driveLetter;
        } else {
            drive.name = volumeName + " (" + driveLetter + ")";
        }
        drive.path = rootPath;
        drive.totalBytes = info.bytesTotal();
        drive.freeBytes = info.bytesFree();
        drive.totalSize = formatSize(info.bytesTotal());
        drive.freeSpace = formatSize(info.bytesFree());

        m_drives.append(drive);
    }

    endResetModel();
}

DriveInfo DriveManager::driveAt(int index) const
{
    if (index >= 0 && index < m_drives.size()) {
        return m_drives.at(index);
    }
    return DriveInfo();
}

QString DriveManager::formatSize(quint64 bytes) const
{
    const QStringList units = {"B", "KB", "MB", "GB", "TB"};
    int unitIndex = 0;
    double size = bytes;

    while (size >= 1024 && unitIndex < units.size() - 1) {
        size /= 1024;
        ++unitIndex;
    }

    if (unitIndex == 0) {
        return QString::number(static_cast<quint64>(size)) + " " + units[unitIndex];
    }
    return QString::number(size, 'f', 2) + " " + units[unitIndex];
}

int DriveManager::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return m_drives.size();
}

int DriveManager::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return 1;
}

QVariant DriveManager::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_drives.size()) {
        return QVariant();
    }

    const DriveInfo &drive = m_drives.at(index.row());

    switch (role) {
    case NameRole:
        return drive.name;
    case PathRole:
        return drive.path;
    case TotalSizeRole:
        return drive.totalSize;
    case FreeSpaceRole:
        return drive.freeSpace;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> DriveManager::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[PathRole] = "path";
    roles[TotalSizeRole] = "totalSize";
    roles[FreeSpaceRole] = "freeSpace";
    return roles;
}
