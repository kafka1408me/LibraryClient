#include "jsonmodel.h"
#include <QJsonObject>
#include <QDebug>

JsonModel::JsonModel()
{

}

//Book *JsonModel::getBook(int index)
//{
//    return books[index].get();
//}

JsonModel::JsonModel(const QJsonArray &jA, QObject *parent) :
    QAbstractListModel(parent)
{
    qDebug() << "Hello!";
    setDataFromJsonArray(jA);
}


int JsonModel::rowCount(const QModelIndex &parent) const
{
    if(parent.isValid())
    {
        return 0;
    }
    return books.size();
}


QVariant JsonModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid())
    {
        return QVariant();
    }

    switch (role) {
    case Title:
        return QVariant(books.at(index.row()).title);
    case TitleLower:
        return QVariant(books.at(index.row()).title.toLower());
    case Genre:
        return QVariant(books.at(index.row()).genre);
    default:
        return QVariant();//QVariant::fromValue(books[index.row()].get());
    }
}

QHash<int, QByteArray> JsonModel::roleNames() const
{
    QHash<int, QByteArray> roles = QAbstractListModel::roleNames();
    roles[Title] = "title";
    roles[TitleLower] = "titleLower";
    roles[Genre] = "genre";


    return roles;
}

void JsonModel::setDataFromJsonArray(const QJsonArray &jA)
{
    int oldSize = books.size();

    bool removeRows = !books.isEmpty();

    if(removeRows){
        beginRemoveRows(QModelIndex(),0,oldSize-1);
    }

    books.clear();

    if(removeRows){
        endRemoveRows();
    }

    QJsonObject jObject;

    books.reserve(jA.size());
    beginInsertRows(QModelIndex(), 0, jA.size()-1);
    Book book;
    for(auto j: jA)
    {
        jObject = j.toObject();
        book.book_id = jObject.value("book_id").toInt();
        book.title = jObject.value("title").toString();
        book.genre = jObject.value("genre").toString();

        books.push_back(book);
    }
    endInsertRows();

    qDebug() << "size of books = " << books.size();
}




