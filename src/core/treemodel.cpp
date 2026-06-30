#include "treemodel.h"
#include "treeitem.h"

TreeModel::TreeModel(QObject *parent)
    : QAbstractItemModel(parent)
    , m_rootItem(new TreeItem(nullptr))
{
}

TreeModel::~TreeModel()
{
    if (m_rootItem) {
        m_rootItem->deleteLater();
    }
}

void TreeModel::setRootItem(TreeItem *item)
{
    beginResetModel();
    if (m_rootItem) {
        m_rootItem->deleteLater();
    }
    m_rootItem = item;
    endResetModel();
}

void TreeModel::clear()
{
    beginResetModel();
    if (m_rootItem) {
        m_rootItem->clearChildren();
    }
    m_totalSize = 0;
    endResetModel();
}

TreeItem *TreeModel::itemFromIndex(const QModelIndex &index) const
{
    return itemAtIndex(index);
}

TreeItem *TreeModel::itemAtIndex(const QModelIndex &index) const
{
    if (!index.isValid()) {
        return m_rootItem;
    }
    return static_cast<TreeItem*>(index.internalPointer());
}

void TreeModel::expandItem(TreeItem *item)
{
    if (!item) return;
    item->setExpanded(true);
    emit itemExpanded(item);
}

void TreeModel::collapseItem(TreeItem *item)
{
    if (!item) return;
    item->setExpanded(false);
    emit itemCollapsed(item);
}

void TreeModel::setTotalSize(quint64 size)
{
    m_totalSize = size;
}

QString TreeModel::formatSize(quint64 bytes) const
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

QModelIndex TreeModel::index(int row, int column, const QModelIndex &parent) const
{
    if (!hasIndex(row, column, parent)) {
        return QModelIndex();
    }

    TreeItem *parentItem = itemAtIndex(parent);
    if (!parentItem) {
        return QModelIndex();
    }

    TreeItem *childItem = parentItem->child(row);
    if (childItem) {
        return createIndex(row, column, childItem);
    }

    return QModelIndex();
}

QModelIndex TreeModel::parent(const QModelIndex &index) const
{
    if (!index.isValid()) {
        return QModelIndex();
    }

    TreeItem *childItem = itemAtIndex(index);
    if (!childItem) {
        return QModelIndex();
    }

    TreeItem *parentItem = childItem->parent();
    if (!parentItem || parentItem == m_rootItem) {
        return QModelIndex();
    }

    return createIndex(parentItem->indexOfChild(childItem), 0, childItem);
}

int TreeModel::rowCount(const QModelIndex &parent) const
{
    TreeItem *parentItem = itemAtIndex(parent);
    if (!parentItem) {
        return 0;
    }
    return parentItem->childCount();
}

int TreeModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return 1;
}

QVariant TreeModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    TreeItem *item = itemAtIndex(index);
    if (!item) {
        return QVariant();
    }

    switch (role) {
    case NameRole:
        return item->name();
    case PathRole:
        return item->path();
    case SizeRole:
        return static_cast<quint64>(item->size());
    case FormattedSizeRole:
        return item->formattedSize();
    case IsDirRole:
        return item->isDir();
    case ExpandedRole:
        return item->expanded();
    case ChildCountRole:
        return item->childCount();
    case PercentageRole:
        return item->percentage();
    case ExtensionRole:
        return item->extension();
    case CalculatingRole:
        return item->isCalculating();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> TreeModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[PathRole] = "path";
    roles[SizeRole] = "size";
    roles[FormattedSizeRole] = "formattedSize";
    roles[IsDirRole] = "isDir";
    roles[ExpandedRole] = "expanded";
    roles[ChildCountRole] = "childCount";
    roles[PercentageRole] = "percentage";
    roles[ExtensionRole] = "extension";
    roles[CalculatingRole] = "calculating";
    return roles;
}

bool TreeModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid()) {
        return false;
    }

    TreeItem *item = itemAtIndex(index);
    if (!item) {
        return false;
    }

    switch (role) {
    case ExpandedRole:
        item->setExpanded(value.toBool());
        emit dataChanged(index, index, {ExpandedRole});
        return true;
    default:
        return false;
    }
}
