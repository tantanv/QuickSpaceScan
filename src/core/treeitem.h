#ifndef TREEITEM_H
#define TREEITEM_H

#include <QObject>
#include <QList>
#include <QString>
#include <qqml.h>

class TreeItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(quint64 size READ size WRITE setSize NOTIFY sizeChanged)
    Q_PROPERTY(bool isDir READ isDir WRITE setIsDir NOTIFY isDirChanged)
    Q_PROPERTY(bool expanded READ expanded WRITE setExpanded NOTIFY expandedChanged)
    Q_PROPERTY(bool calculating READ isCalculating WRITE setCalculating NOTIFY calculatingChanged)
    Q_PROPERTY(int childCount READ childCount NOTIFY childrenChanged)
    Q_PROPERTY(QString formattedSize READ formattedSize NOTIFY sizeChanged)
    Q_PROPERTY(double percentage READ percentage NOTIFY percentageChanged)

public:
    explicit TreeItem(TreeItem *parent = nullptr);
    ~TreeItem();

    QString name() const { return m_name; }
    void setName(const QString &name);

    QString path() const { return m_path; }
    void setPath(const QString &path);

    quint64 size() const { return m_size; }
    void setSize(quint64 size);

    bool isDir() const { return m_isDir; }
    void setIsDir(bool isDir);

    bool expanded() const { return m_expanded; }
    void setExpanded(bool expanded);

    bool isCalculating() const { return m_calculating; }
    void setCalculating(bool calculating);

    int childCount() const { return m_children.size(); }

    QString formattedSize() const;
    double percentage() const { return m_percentage; }
    void setPercentage(double pct) { m_percentage = pct; emit percentageChanged(); }

    TreeItem *parent() const { return m_parent; }
    void setParent(TreeItem *parent);

    Q_INVOKABLE TreeItem *child(int index) const;
    Q_INVOKABLE int indexOfChild(TreeItem *child) const;
    Q_INVOKABLE TreeItem *findChild(const QString &name) const;
    Q_INVOKABLE void appendChild(TreeItem *item);
    Q_INVOKABLE void removeChild(TreeItem *item);
    Q_INVOKABLE void clearChildren();
    Q_INVOKABLE void addSize(quint64 delta);
    Q_INVOKABLE void subtractSize(quint64 delta) { if (m_size >= delta) m_size -= delta; else m_size = 0; emit sizeChanged(); if (m_parent) m_parent->subtractSize(delta); }

    Q_INVOKABLE QString extension() const;
    Q_INVOKABLE bool hasChildren() const { return !m_children.isEmpty(); }

signals:
    void nameChanged();
    void pathChanged();
    void sizeChanged();
    void isDirChanged();
    void expandedChanged();
    void calculatingChanged();
    void percentageChanged();
    void childrenChanged();

private:
    QString m_name;
    QString m_path;
    quint64 m_size = 0;
    bool m_isDir = false;
    bool m_expanded = false;
    bool m_calculating = false;
    double m_percentage = 0.0;

    TreeItem *m_parent = nullptr;
    QList<TreeItem*> m_children;
};

#endif // TREEITEM_H
