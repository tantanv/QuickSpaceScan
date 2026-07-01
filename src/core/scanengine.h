#ifndef SCANENGINE_H
#define SCANENGINE_H

#include <QObject>
#include <QThreadPool>
#include <QRunnable>
#include <QMutex>
#include <QAtomicInt>
#include <QMap>
#include <QSet>
#include <QVector>

#include "treeitem.h"

struct FileEntry {
    QString path;
    QString name;
    quint64 size;
};

struct DirScanResult {
    QString dirPath;
    QVector<FileEntry> files;
    QStringList subdirNames;
    QStringList subdirPaths;
};

class ScanEngine;

class ScanTask : public QObject, public QRunnable
{
    Q_OBJECT
public:
    ScanTask(ScanEngine *engine, const QString &path, int generation);
    void run() override;

signals:
    void scanStarted(const QString &path, int generation);
    void dirScanned(const DirScanResult &result, int generation);
    void taskComplete(int generation);

private:
    ScanEngine *m_engine;
    QString m_path;
    int m_generation;
};

class ScanEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool scanning READ isScanning NOTIFY scanningChanged)
    Q_PROPERTY(quint64 totalSize READ totalSize NOTIFY totalSizeChanged)
    Q_PROPERTY(quint64 scannedFiles READ scannedFiles NOTIFY scannedFilesChanged)
    Q_PROPERTY(quint64 itemCount READ itemCount NOTIFY itemCountChanged)
    Q_PROPERTY(QString currentPath READ currentPath NOTIFY currentPathChanged)
    Q_PROPERTY(TreeItem* rootItem READ rootItem NOTIFY rootItemChanged)

public:
    explicit ScanEngine(QObject *parent = nullptr);
    ~ScanEngine();

    bool isScanning() const { return m_scanning; }
    quint64 totalSize() const { return m_displayedItem ? m_displayedItem->size() : m_totalSize; }
    quint64 scannedFiles() const { return m_scannedFiles; }
    quint64 itemCount() const { return m_itemCount; }
    QString currentPath() const { return m_currentPath; }
    TreeItem *rootItem() const { return m_displayedItem; }

    Q_INVOKABLE void startScan(const QString &path, bool forceRefresh = false);
    Q_INVOKABLE void rescanPath(const QString &path);
    Q_INVOKABLE bool navigateToPath(const QString &path);
    Q_INVOKABLE bool navigateToParent();
    Q_INVOKABLE bool openInExplorer(const QString &path);
    Q_INVOKABLE bool deletePath(const QString &path);

signals:
    void scanningChanged();
    void totalSizeChanged();
    void scannedFilesChanged();
    void itemCountChanged();
    void currentPathChanged();
    void rootItemChanged();
    void scanFinished();
    void batchItemsAdded();
    void errorOccurred(const QString &error);
    void pathDeleted(const QString &path);

private slots:
    void onScanStarted(const QString &path, int generation);
    void onDirScanned(const DirScanResult &result, int generation);
    void onTaskComplete(int generation);

private:
    void submitTask(const QString &path);
    bool isSystemDirectory(const QString &fileName);
    void clearDisplayedData();
    void clearAllData();
    void setupDisplayedItem(TreeItem *item, const QString &path);
    void calculateStats(TreeItem *item, quint64 &totalSize, quint64 &itemCount, quint64 &fileCount);
    bool isSameDrive(const QString &path1, const QString &path2);
    QString getDriveRoot(const QString &path);
    TreeItem* findItemByPath(const QString &path);
    void removeItemByPath(const QString &path);
    QString normalizePathKey(const QString &path);

    bool m_scanning = false;
    QAtomicInt m_stopFlag;
    int m_activeTasks = 0;
    int m_scanGeneration = 0;

    QThreadPool m_threadPool;

    QString m_scanRootPath;
    TreeItem *m_scanRootItem = nullptr;

    TreeItem *m_displayedItem = nullptr;
    QString m_currentPath;
    quint64 m_totalSize = 0;
    quint64 m_scannedFiles = 0;
    quint64 m_itemCount = 0;

    QMap<QString, TreeItem*> m_pathToItem;
    QSet<QString> m_visitedPaths;

    friend class ScanTask;
};

Q_DECLARE_METATYPE(DirScanResult)
Q_DECLARE_METATYPE(FileEntry)

#endif // SCANENGINE_H
