#ifndef FEEDHELPER_H
#define FEEDHELPER_H

#include <QObject>
#include <QVariant>

class FeedHelper: public QObject
{
    Q_OBJECT
public:
    explicit FeedHelper(QObject *parent = 0);

    Q_INVOKABLE QVariant parseString(const QString &xmlString);

signals:

public slots:

    // QString parseString(const QString &xmlString);
};

#endif // FEEDHELPER_H
