#include "scanengine.h"
#include <QDir>
#include <QFileInfo>
#include <QCoreApplication>
#include <QThread>
#include <QProcess>
#include <QFile>
#include <QUrl>
#include <QDesktopServices>
#include <functional>

#ifdef Q_OS_WIN
#include <windows.h>
#include <shlobj.h>
#include <objbase.h>
#endif

ScanTask::ScanTask(ScanEngine *engine, const QString &path, int generation)
    : QObject(nullptr)
    , m_engine(engine)
    , m_path(path)
    , m_generation(generation)
{
    setAutoDelete(false);
}

void ScanTask::run()
{
    if (m_engine->m_stopFlag.loadRelaxed() != 0) {
        emit taskComplete(m_generation);
        return;
    }

    emit scanStarted(m_path, m_generation);

    QDir dir(m_path);
    if (!dir.exists() || !dir.isReadable()) {
        emit taskComplete(m_generation);
        return;
    }

    const auto filters = QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot | QDir::Hidden;
    QFileInfoList entries = dir.entryInfoList(filters, QDir::DirsFirst | QDir::Name);

    DirScanResult result;
    result.dirPath = m_path;
    for (const QFileInfo &info : entries) {
        if (m_engine->m_stopFlag.loadRelaxed() != 0) break;

        const QString fileName = info.fileName();
        if (fileName.isEmpty()) continue;
        if (info.isSymLink()) continue;
        if (fileName.endsWith(".lnk", Qt::CaseInsensitive)) continue;

        if (info.isDir()) {
            if (m_engine->isSystemDirectory(fileName)) continue;
            result.subdirNames.append(fileName);
            result.subdirPaths.append(info.absoluteFilePath());
        } else {
            qint64 sz = info.size();
            if (sz >= 0) {
                FileEntry fe;
                fe.path = info.absoluteFilePath();
                fe.name = fileName;
                fe.size = static_cast<quint64>(sz);
                result.files.append(fe);
            }
        }
    }

    emit dirScanned(result, m_generation);
    emit taskComplete(m_generation);
}

ScanEngine::ScanEngine(QObject *parent)
    : QObject(parent)
    , m_stopFlag(0)
    , m_scanRootItem(nullptr)
    , m_displayedItem(nullptr)
{
    qRegisterMetaType<DirScanResult>("DirScanResult");
    qRegisterMetaType<FileEntry>("FileEntry");

    int threadCount = QThread::idealThreadCount();
    if (threadCount < 2) threadCount = 2;
    if (threadCount > 8) threadCount = 8;
    m_threadPool.setMaxThreadCount(threadCount);
}

ScanEngine::~ScanEngine()
{
    m_stopFlag.storeRelaxed(1);
    m_threadPool.waitForDone();
    delete m_scanRootItem;
}

bool ScanEngine::isSystemDirectory(const QString &fileName)
{
    static const QStringList skippedNames = {
        QStringLiteral("$recycle.bin"),
        QStringLiteral("system volume information"),
        QStringLiteral("$windows.~bt"),
        QStringLiteral("$windows.~ws"),
        QStringLiteral("config.msi"),
        QStringLiteral("msocache"),
        QStringLiteral("recovery"),
        QStringLiteral("perflogs"),
    };
    return skippedNames.contains(fileName.toLower());
}

bool ScanEngine::isSameDrive(const QString &path1, const QString &path2)
{
    if (path1.length() < 2 || path2.length() < 2) return false;
    return path1[0].toLower() == path2[0].toLower();
}

QString ScanEngine::getDriveRoot(const QString &path)
{
    if (path.length() < 2) return path;
    return path.left(1).toUpper() + ":\\";
}

QString ScanEngine::normalizePathKey(const QString &path)
{
    QString p = QDir::cleanPath(path);
    p = QDir::toNativeSeparators(p);
    if (p.length() == 2 && p[1] == ':') {
        p += "\\";
    }
    return p.toLower();
}

TreeItem* ScanEngine::findItemByPath(const QString &path)
{
    return m_pathToItem.value(normalizePathKey(path), nullptr);
}

void ScanEngine::removeItemByPath(const QString &path)
{
    m_pathToItem.remove(normalizePathKey(path));
}

void ScanEngine::clearDisplayedData()
{
    m_pathToItem.clear();
    m_visitedPaths.clear();
}

void ScanEngine::clearAllData()
{
    clearDisplayedData();
    if (m_scanRootItem) {
        delete m_scanRootItem;
        m_scanRootItem = nullptr;
    }
    m_displayedItem = nullptr;
    m_currentPath.clear();
    m_scanRootPath.clear();
    m_totalSize = 0;
    m_scannedFiles = 0;
    m_itemCount = 0;
}

void ScanEngine::calculateStats(TreeItem *item, quint64 &totalSize, quint64 &itemCount, quint64 &fileCount)
{
    if (!item) return;
    itemCount++;
    if (!item->isDir()) {
        totalSize += item->size();
        fileCount++;
    }
    for (int i = 0; i < item->childCount(); i++) {
        calculateStats(item->child(i), totalSize, itemCount, fileCount);
    }
}

void ScanEngine::setupDisplayedItem(TreeItem *item, const QString &path)
{
    if (!item) return;

    m_displayedItem = item;
    m_currentPath = path;

    quint64 totalSize = 0;
    quint64 itemCount = 0;
    quint64 fileCount = 0;
    calculateStats(item, totalSize, itemCount, fileCount);

    m_totalSize = item->size();
    m_itemCount = itemCount;
    m_scannedFiles = fileCount;
    m_scanning = false;
    m_activeTasks = 0;

    item->setExpanded(true);

    emit rootItemChanged();
    emit currentPathChanged();
    emit scanningChanged();
    emit totalSizeChanged();
    emit itemCountChanged();
    emit scannedFilesChanged();
    emit batchItemsAdded();
}

bool ScanEngine::navigateToPath(const QString &path)
{
    TreeItem *item = findItemByPath(path);
    if (!item) return false;

    QString displayPath = QDir::toNativeSeparators(QDir::cleanPath(path));
    if (displayPath.length() == 2 && displayPath[1] == ':') {
        displayPath += "\\";
    }

    m_displayedItem = item;
    m_currentPath = displayPath;

    if (!m_scanning) {
        quint64 totalSize = 0;
        quint64 itemCount = 0;
        quint64 fileCount = 0;
        calculateStats(item, totalSize, itemCount, fileCount);
        m_totalSize = item->size();
        m_itemCount = itemCount;
        m_scannedFiles = fileCount;
    }

    item->setExpanded(true);

    emit rootItemChanged();
    emit currentPathChanged();
    emit totalSizeChanged();
    emit itemCountChanged();
    emit scannedFilesChanged();
    emit batchItemsAdded();

    return true;
}

bool ScanEngine::navigateToParent()
{
    if (!m_displayedItem) return false;

    TreeItem *parent = m_displayedItem->parent();
    if (!parent) return false;

    QString parentPath = parent->path();
    return navigateToPath(parentPath);
}

void ScanEngine::startScan(const QString &path, bool forceRefresh)
{
    QString driveRoot = getDriveRoot(path);
    bool sameDrive = m_scanRootItem && isSameDrive(path, m_scanRootPath);

    if (sameDrive && !forceRefresh) {
        TreeItem *rootItem = findItemByPath(driveRoot);
        if (rootItem) {
            navigateToPath(driveRoot);
            return;
        }
    }

    m_stopFlag.storeRelaxed(1);
    m_threadPool.waitForDone();
    m_scanGeneration++;
    m_activeTasks = 0;

    clearAllData();

    m_scanRootPath = driveRoot;

    m_stopFlag.storeRelaxed(0);
    m_totalSize = 0;
    m_scannedFiles = 0;
    m_itemCount = 0;
    m_currentPath = driveRoot;

    m_scanRootItem = new TreeItem(nullptr);
    m_scanRootItem->setName(driveRoot);
    m_scanRootItem->setPath(driveRoot);
    m_scanRootItem->setIsDir(true);
    m_scanRootItem->setSize(0);
    m_scanRootItem->setExpanded(true);

    m_displayedItem = m_scanRootItem;
    m_pathToItem[normalizePathKey(driveRoot)] = m_scanRootItem;
    m_visitedPaths.insert(normalizePathKey(driveRoot));

    m_scanning = true;

    emit rootItemChanged();
    emit currentPathChanged();
    emit scanningChanged();
    emit itemCountChanged();
    emit totalSizeChanged();
    emit scannedFilesChanged();

    submitTask(driveRoot);
}

void ScanEngine::rescanPath(const QString &path)
{
    m_stopFlag.storeRelaxed(1);
    m_threadPool.waitForDone();
    m_scanGeneration++;
    m_activeTasks = 0;

    TreeItem *item = findItemByPath(path);
    if (!item) {
        startScan(path, true);
        return;
    }

    QList<TreeItem*> allChildren;
    std::function<void(TreeItem*)> collectChildren = [&](TreeItem *node) {
        for (int i = 0; i < node->childCount(); i++) {
            TreeItem *child = node->child(i);
            allChildren.append(child);
            collectChildren(child);
        }
    };
    collectChildren(item);

    for (TreeItem *child : allChildren) {
        removeItemByPath(child->path());
        m_visitedPaths.remove(normalizePathKey(child->path()));
    }

    quint64 oldSize = item->size();
    TreeItem *parent = item->parent();
    if (parent) {
        parent->subtractSize(oldSize);
    }

    item->clearChildren();

    item->setSize(0);
    item->setCalculating(true);

    m_stopFlag.storeRelaxed(0);
    m_scanning = true;

    QString displayPath = QDir::toNativeSeparators(QDir::cleanPath(path));
    if (displayPath.length() == 2 && displayPath[1] == ':') {
        displayPath += "\\";
    }
    m_currentPath = displayPath;
    m_displayedItem = item;
    m_totalSize = 0;
    m_scannedFiles = 0;
    m_itemCount = 0;

    emit rootItemChanged();
    emit currentPathChanged();
    emit scanningChanged();
    emit totalSizeChanged();
    emit itemCountChanged();
    emit scannedFilesChanged();
    emit batchItemsAdded();

    QString scanPath = QDir::toNativeSeparators(QDir::cleanPath(path));
    if (scanPath.length() == 2 && scanPath[1] == ':') {
        scanPath += "\\";
    }
    submitTask(scanPath);
}

void ScanEngine::submitTask(const QString &path)
{
    if (m_stopFlag.loadRelaxed() != 0) return;

    m_activeTasks++;

    int generation = m_scanGeneration;
    ScanTask *task = new ScanTask(this, path, generation);
    connect(task, &ScanTask::scanStarted,
            this, &ScanEngine::onScanStarted, Qt::QueuedConnection);
    connect(task, &ScanTask::dirScanned,
            this, &ScanEngine::onDirScanned, Qt::QueuedConnection);
    connect(task, &ScanTask::taskComplete,
            this, &ScanEngine::onTaskComplete, Qt::QueuedConnection);
    connect(task, &ScanTask::taskComplete,
            task, &QObject::deleteLater, Qt::QueuedConnection);

    m_threadPool.start(task);
}

void ScanEngine::onScanStarted(const QString &path, int generation)
{
    if (generation != m_scanGeneration) return;
    if (m_stopFlag.loadRelaxed() != 0) return;

    TreeItem *item = findItemByPath(path);
    if (item) {
        item->setCalculating(false);
    }
}

void ScanEngine::onDirScanned(const DirScanResult &result, int generation)
{
    if (generation != m_scanGeneration) return;
    if (m_stopFlag.loadRelaxed() != 0) return;

    TreeItem *parentItem = findItemByPath(result.dirPath);
    if (!parentItem) return;

    quint64 dirFileSize = 0;

    for (const FileEntry &fe : result.files) {
        TreeItem *item = new TreeItem(parentItem);
        item->setName(fe.name);
        item->setPath(fe.path);
        item->setIsDir(false);
        item->setSize(fe.size);
        parentItem->appendChild(item);
        m_pathToItem[normalizePathKey(fe.path)] = item;
        dirFileSize += fe.size;
        m_scannedFiles++;
        m_itemCount++;
    }

    for (int i = 0; i < result.subdirPaths.size(); i++) {
        const QString &subPath = result.subdirPaths[i];
        const QString &subName = result.subdirNames[i];

        QString key = normalizePathKey(subPath);
        if (m_visitedPaths.contains(key)) continue;
        m_visitedPaths.insert(key);

        TreeItem *item = new TreeItem(parentItem);
        item->setName(subName);
        item->setPath(subPath);
        item->setIsDir(true);
        item->setSize(0);
        item->setCalculating(true);
        parentItem->appendChild(item);
        m_pathToItem[normalizePathKey(subPath)] = item;
        m_itemCount++;

        submitTask(subPath);
    }

    parentItem->addSize(dirFileSize);
    m_totalSize += dirFileSize;

    // emit scannedFilesChanged();
    // emit itemCountChanged();
    // emit totalSizeChanged();
    // emit batchItemsAdded();
}

void ScanEngine::onTaskComplete(int generation)
{
    if (generation != m_scanGeneration) return;

    if (m_activeTasks > 0) {
        m_activeTasks--;
    }

    if (m_activeTasks <= 0) {
        m_activeTasks = 0;
        if (m_scanning && m_stopFlag.loadRelaxed() == 0) {
            m_scanning = false;
            if (m_displayedItem) {
                m_displayedItem->setCalculating(false);

                quint64 totalSize = 0;
                quint64 itemCount = 0;
                quint64 fileCount = 0;
                calculateStats(m_displayedItem, totalSize, itemCount, fileCount);

                m_totalSize = m_displayedItem->size();
                m_itemCount = itemCount;
                m_scannedFiles = fileCount;
            }

            emit scanningChanged();
            emit totalSizeChanged();
            emit itemCountChanged();
            emit scannedFilesChanged();
            emit scanFinished();
            emit batchItemsAdded();
        }
    }
}

bool ScanEngine::openInExplorer(const QString &path)
{
    QFileInfo fi(path);
    if (!fi.exists()) return false;

#ifdef Q_OS_WIN
    QString nativePath = QDir::toNativeSeparators(fi.absoluteFilePath());
    QString params = QString("/select,\"%1\"").arg(nativePath);
    HINSTANCE result = ShellExecuteW(nullptr, L"open", L"explorer.exe",
                                     reinterpret_cast<LPCWSTR>(params.utf16()),
                                     nullptr, SW_SHOWNORMAL);
    return reinterpret_cast<quintptr>(result) > 32;
#else
    QString parentPath = fi.absolutePath();
    QDesktopServices::openUrl(QUrl::fromLocalFile(parentPath));
    return true;
#endif
}

bool ScanEngine::deletePath(const QString &path)
{
    QFileInfo fi(path);
    if (!fi.exists()) return false;

    m_stopFlag.storeRelaxed(1);
    m_threadPool.waitForDone();
    m_scanGeneration++;
    m_activeTasks = 0;

    bool ok = false;
    if (fi.isFile()) {
        ok = QFile::remove(path);
    } else if (fi.isDir()) {
        QDir dir(path);
        ok = dir.removeRecursively();
    }

    if (ok) {
        TreeItem *item = findItemByPath(path);
        if (item) {
            TreeItem *parent = item->parent();
            quint64 itemSize = item->size();

            QList<TreeItem*> toDelete;
            std::function<void(TreeItem*)> collectAll = [&](TreeItem *node) {
                toDelete.append(node);
                for (int i = 0; i < node->childCount(); i++) {
                    collectAll(node->child(i));
                }
            };
            collectAll(item);

            for (TreeItem *node : toDelete) {
                removeItemByPath(node->path());
                m_visitedPaths.remove(normalizePathKey(node->path()));
            }

            bool isDisplayed = (item == m_displayedItem);

            if (parent) {
                parent->removeChild(item);
                parent->subtractSize(itemSize);
            } else if (m_scanRootItem == item) {
                m_scanRootItem = nullptr;
                m_displayedItem = nullptr;
                emit rootItemChanged();
            }

            if (isDisplayed && parent) {
                setupDisplayedItem(parent, parent->path());
            } else if (!isDisplayed && m_displayedItem) {
                quint64 totalSize = 0;
                quint64 itemCount = 0;
                quint64 fileCount = 0;
                calculateStats(m_displayedItem, totalSize, itemCount, fileCount);
                m_totalSize = m_displayedItem->size();
                m_itemCount = itemCount;
                m_scannedFiles = fileCount;
            } else {
                m_totalSize = m_totalSize > itemSize ? m_totalSize - itemSize : 0;
                quint64 itemsToRemove = static_cast<quint64>(toDelete.size());
                m_itemCount = m_itemCount > itemsToRemove ? m_itemCount - itemsToRemove : 0;
            }

            emit totalSizeChanged();
            emit itemCountChanged();
            emit scannedFilesChanged();
            emit batchItemsAdded();

            delete item;
            toDelete.clear();
        }
        emit pathDeleted(path);
    }

    return ok;
}
