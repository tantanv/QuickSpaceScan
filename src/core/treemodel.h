#ifndef TREEMODEL_H
#define TREEMODEL_H

#include <QAbstractItemModel>
#include <QModelIndex>
#include <QVariant>
#include <QIcon>

class TreeItem;

class TreeModel : public QAbstractItemModel
{
    Q_OBJECT

public:
    explicit TreeModel(QObject *parent = nullptr);
    ~TreeModel();

    Q_INVOKABLE void setRootItem(TreeItem *item);
    Q_INVOKABLE TreeItem *rootItem() const { return m_rootItem; }
    Q_INVOKABLE TreeItem *itemFromIndex(const QModelIndex &index) const;

    Q_INVOKABLE void clear();
    Q_INVOKABLE void expandItem(TreeItem *item);
    Q_INVOKABLE void collapseItem(TreeItem *item);

    Q_INVOKABLE quint64 totalSize() const { return m_totalSize; }
    Q_INVOKABLE void setTotalSize(quint64 size);

    Q_INVOKABLE QString formatSize(quint64 bytes) const;

    enum Roles {
        NameRole = Qt::UserRole + 1,
        PathRole,
        SizeRole,
        FormattedSizeRole,
        IsDirRole,
        ExpandedRole,
        ChildCountRole,
        PercentageRole,
        ExtensionRole,
        CalculatingRole
    };

protected:
    QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &index) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

signals:
    void itemExpanded(TreeItem *item);
    void itemCollapsed(TreeItem *item);

private:
    TreeItem* itemAtIndex(const QModelIndex &index) const;

    TreeItem *m_rootItem = nullptr;
    quint64 m_totalSize = 0;
};

#endif // TREEMODEL_H
