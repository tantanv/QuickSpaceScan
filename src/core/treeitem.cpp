#include "treeitem.h"

TreeItem::TreeItem(TreeItem *parent)
    : QObject(parent)
    , m_parent(parent)
{
}

TreeItem::~TreeItem()
{
}

void TreeItem::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

void TreeItem::setPath(const QString &path)
{
    if (m_path != path) {
        m_path = path;
        emit pathChanged();
    }
}

void TreeItem::setSize(quint64 size)
{
    if (m_size != size) {
        m_size = size;
        emit sizeChanged();
    }
}

void TreeItem::setIsDir(bool isDir)
{
    if (m_isDir != isDir) {
        m_isDir = isDir;
        emit isDirChanged();
    }
}

void TreeItem::setExpanded(bool expanded)
{
    if (m_expanded != expanded) {
        m_expanded = expanded;
        emit expandedChanged();
    }
}

void TreeItem::setCalculating(bool calculating)
{
    if (m_calculating != calculating) {
        m_calculating = calculating;
        emit calculatingChanged();
    }
}

void TreeItem::setParent(TreeItem *parent)
{
    m_parent = parent;
    QObject::setParent(parent);
}

TreeItem *TreeItem::child(int index) const
{
    if (index >= 0 && index < m_children.size()) {
        return m_children.at(index);
    }
    return nullptr;
}

TreeItem *TreeItem::findChild(const QString &name) const
{
    for (TreeItem *child : m_children) {
        if (child && child->name() == name) {
            return child;
        }
    }
    return nullptr;
}

int TreeItem::indexOfChild(TreeItem *child) const
{
    return m_children.indexOf(child);
}

void TreeItem::appendChild(TreeItem *item)
{
    if (!item) return;
    if (item->parent() != this) {
        item->setParent(this);
    }
    if (!m_children.contains(item)) {
        m_children.append(item);
        emit childrenChanged();
    }
}

void TreeItem::addSize(quint64 delta)
{
    m_size += delta;
    emit sizeChanged();
    if (m_parent) {
        m_parent->addSize(delta);
    }
}

void TreeItem::removeChild(TreeItem *item)
{
    if (item && m_children.removeOne(item)) {
        item->TreeItem::setParent(nullptr);
        emit childrenChanged();
    }
}

void TreeItem::clearChildren()
{
    if (m_children.isEmpty()) return;
    qDeleteAll(m_children);
    m_children.clear();
    emit childrenChanged();
}

QString TreeItem::formattedSize() const
{
    const QStringList units = {"B", "KB", "MB", "GB", "TB"};
    int unitIndex = 0;
    double size = static_cast<double>(m_size);

    while (size >= 1024.0 && unitIndex < units.size() - 1) {
        size /= 1024.0;
        ++unitIndex;
    }

    if (unitIndex == 0) {
        return QString::number(static_cast<quint64>(size)) + " " + units[unitIndex];
    }
    return QString::number(size, 'f', 2) + " " + units[unitIndex];
}

QString TreeItem::extension() const
{
    if (m_isDir) return "";
    int lastDot = m_name.lastIndexOf('.');
    if (lastDot > 0) {
        return m_name.mid(lastDot + 1).toLower();
    }
    return "";
}
