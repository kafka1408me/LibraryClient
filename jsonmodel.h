#ifndef JSONMODEL_H
#define JSONMODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
//#include "book.h"
//#include <memory>

struct Book
{
    int book_id;
    int reservation_user_id = 0;
    int year_publication;
    QString photo;
    QString title;
    QString genre;
    QString author;
    QString description;
    QString time_unblocking;
};


class JsonModel : public QAbstractListModel
{
    Q_OBJECT
private:
    Q_PROPERTY(QJsonArray books WRITE setDataFromJsonArray);
public:
    enum Roles {
        Title = Qt::UserRole + 1,
        TitleLower,
        Genre,

    };

    JsonModel();

//    Q_INVOKABLE Book* getBook(int index);

    explicit JsonModel(const QJsonArray& jA, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void setDataFromJsonArray(const QJsonArray& jA);


private:
    mutable QVector<Book> books;
};

#endif // JSONMODEL_H
