import QtQuick 2.6
import QtQuick.Controls 2.6  // для ApplicationWindow
import QtWebSockets 1.1      // вебсокет

import codes.namespace 1.0   // коды сообщений, которыми обмениваются сервер и клиент
//import "qrc:/model.js" as Books


ApplicationWindow{
    visible:true
    id: mainWindow

    width: 300
    height: 400

    property string status: "tryConnect"                        // текущее состояние клиента
    readonly property string btnDownColor:        "#4fade3"
    readonly property string btnOrdinaryColor:    "#84c6ec"
    readonly property string borderDownColor:     "#17a81a"
    readonly property string borderOrdinaryColor: "#21be2b"
    readonly property string backgroundColor: "#40cbd11e"

    readonly property int headerH: 50

    readonly property bool test: false
    property int idUser: test ? 1: 0

// START -----> Компонент: шаблон отображения книги в представлении
    Component{
        id: delegate

        Rectangle{
            id: rectDelegate
            color: "#f2f3c8"
            border.color: "black"
            border.width: 1

            objectName: 'book_id:'+ modelData.book_id

            width: mainWindow.width
            height: visible ? imgBook.height + 10 : 0
            Row{
                x: 5
                anchors.verticalCenter: parent.verticalCenter
                spacing: 7

                Image{
                    id: imgBook
                    width: mainWindow.width < mainWindow.height ?  mainWindow.width* 0.25 : mainWindow.height*0.25
                    height:  mainWindow.height*0.25
                    //      source: "qrc:/eLibrary"
                    source:
                    {
                        if(!modelData.photo) return "qrc:/noBook"
                        return 'data:image/png;base64,' + modelData.photo
                    }
                    smooth: true

                }
                Column{
                    spacing: 4
                    Text{
                        color: "black"

                        text: {

                            var bestWidth = mainWindow.width - imgBook.width - imgBook.x - 10 - btnSelectBook.width

                            if(contentWidth > bestWidth)
                            {
                                var chLength = contentWidth / modelData.title.length
                                var maxCh = bestWidth / chLength
                                //    console.log(modelData.title, bestWidth, chLength, maxCh)
                                return getLimitStr(modelData.title, maxCh - 3)
                            }

                            return modelData.title
                        }
                        font.pointSize: 11
                    }
                    Text{
                        color: btnDownColor
                        text: {
                            var bestWidth = mainWindow.width - imgBook.width - imgBook.x - 10 - btnSelectBook.width

                            if(contentWidth > bestWidth)
                            {
                                var chLength = contentWidth / modelData.author.length
                                var maxCh = bestWidth / chLength
                                //    console.log(modelData.title, bestWidth, chLength, maxCh)
                                return getLimitStr(modelData.author, maxCh - 3)
                            }

                            return modelData.author
                        }

                        font.pointSize: 11
                    }
                    Text{
                        id: textGenre
                        color: "#b646ea"
                        text: modelData.genre ? modelData.genre : " "
                        font.pointSize: 10
                    }
                    Text{
                        id: textYear
                        text: modelData.year_publication
                        font.pointSize: 10
                    }
                }
            }
            Rectangle{
                id: rectBron
                visible: modelData.reservation_user_id > 0
                width: textBron.width + 4
                height: textBron.height + 4
                x : parent.width - 5 - width - btnSelectBook.width
                y: rectDelegate.height - height - rectDelegate.height*0.2
                radius: 5
                color: modelData.reservation_user_id == idUser ? "#33d338" : "#fb5252"
                Text{
                    id: textBron
                    anchors.centerIn: parent
                    text:  "Забронировано"
                    color: "white"
                    font.pixelSize: 13
                }
            }
            Button{
                id: btnSelectBook
                width: parent.width * 0.13
                height: parent.height - 2
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                text: "<h3>></h3>"
                background: Rectangle{
                    color: parent.down ? "#adadad" :"#cacaca"
                }
                onClicked: {
                    itemBooks.visible = false
                    rectBookInfo.book = modelData
                    setReserveStatus()
                    mainWindow.status = "bookInfo"
                    rectBookInfo.visible = true
                }
            }

        }
    }
    // Компонент: шаблон отображения книги в представлении <----- END


    // ИНФОРМАЦИЯ О КНИГЕ


    Rectangle{
        id: rectBookInfo
        property var book: {book_id:1}
        anchors.fill: parent
        visible: false
        color: backgroundColor

        Flickable{
            width: parent.width
            anchors.top: parent.top

            anchors.bottom: rectBackListBooks.top
            contentWidth: parent.width
            contentHeight:{

                var textBronYH = btnReserveBook.y + btnReserveBook.height
                var textDescriptionYH = columnTitleAndOthers.height + columnTitleAndOthers.y

                if(textBronYH > textDescriptionYH)
                {
                    return textBronYH  + 30
                }
                console.log("descr", textDescriptionYH)
                return textDescriptionYH + 30
            }

            Rectangle{
                id: rectTextBookInfo
                width: parent.width
                height: headerH

                gradient: Gradient{
                    GradientStop{position: 0; color: btnOrdinaryColor}
                    GradientStop{position: 0.7; color: btnDownColor}
                }
                Text {
                    anchors.centerIn: parent
                    text: "Информация о книге"
                    color: "grey"
                    font.bold: true
                    font.pointSize: 18
                }
            }


            Image{
                id: imgBookInfo
                source: {
             //       console.log("book_id",rectBookInfo.book.book_id)
                    if(!rectBookInfo.book.photo) return "qrc:/noBook"
                    return 'data:image/png;base64,' + rectBookInfo.book.photo
                }
                width: mainWindow.width < mainWindow.height ? mainWindow.width * 0.45 : mainWindow.height*0.45
                height: mainWindow.height * 0.5
                x: parent.width * 0.05
                y: rectTextBookInfo.height + parent.height * 0.009
            }

            Text{
                id: textBronStatus
                width: imgBookInfo.width
                x: imgBookInfo.x
                y: imgBookInfo.y + imgBookInfo.height + 10

                wrapMode: Text.WordWrap
                text:{
                    if(rectBookInfo.book.reservation_user_id > 0)
                    {
                        if(rectBookInfo.book.reservation_user_id == idUser)
                        {
                            return 'Книга забронирована вами'
                        }
                        return 'Книга недоступна для бронирования'
                    }
                    return 'Книга доступна для бронирования'
                }
                font.pixelSize: 14
                color:{
                    if(rectBookInfo.book.reservation_user_id > 0)
                    {
                        if(rectBookInfo.book.reservation_user_id == idUser)
                        {
                            return "green"//"#33d338"
                        }
                        return "#fb5252"
                    }
                    return '#555555'
                }
            }

            Button{
                id: btnReserveBook
                visible: !(rectBookInfo.book.reservation_user_id > 0)

                anchors.horizontalCenter: imgBookInfo.horizontalCenter
                y: textBronStatus.y + textBronStatus.height + 15

                width: textReserveBook.width + 15
                height: textReserveBook.height  + 15

                //      text: "<h3>Забронировать книгу</h3>"

                background: Rectangle{
                    color: parent.down ? btnDownColor : btnOrdinaryColor
                    border.color: parent.down ? borderDownColor: borderOrdinaryColor
                    radius: 5
                    Text{
                        id: textReserveBook
                        anchors.centerIn: parent
                        text: "Забронировать книгу"
                        font.pixelSize: 15
                    }
                }

                onClicked: {
                    var msg = '{"type":'+ Codes.ReserveBook+ ',"main":{"book_id":'+ rectBookInfo.book.book_id +'
                          ,"reservation_user_id":'+ idUser +'}}'
                    ws.sendTextMessage(msg)
                }
            }

            Column{
                id: columnTitleAndOthers
                spacing: 10
                x: imgBookInfo.x + imgBookInfo.width + 10
                y: imgBookInfo.y
                width: parent.width - imgBookInfo.x - imgBookInfo.width - 8
                Column{
                    spacing: 5

                    Text{
                        width: columnTitleAndOthers.width
                        wrapMode: Text.WordWrap

                        text: rectBookInfo.book.title
                        font.pixelSize: 14
                        color: "#1c61c2"

                    }
                    Text{
                        width: columnTitleAndOthers.width
                        wrapMode: Text.WordWrap

                        text: 'автор: ' + getStrOrDash(rectBookInfo.book.author)
                        font.pixelSize: 13
                    }
                    Text{
                        width: columnTitleAndOthers.width
                        wrapMode: Text.WordWrap

                        text: 'жанр: ' + getStrOrDash(rectBookInfo.book.genre)
                        font.pixelSize: 13
                    }
                    Text{
                        text: 'год: ' + getStrOrDash(rectBookInfo.book.year_publication)
                        font.pixelSize: 13
                    }

                }
                Column{
                    width: parent.width
                    spacing: 5
                    Text {
                        text: 'Краткое описание'
                        color: "magenta"
                        font.pixelSize: 14
                    }
                    Text{
                        id: textDescription
                        width: parent.width - 3
                        //  width: 100
                        text: rectBookInfo.book.description
                        wrapMode: Text.Wrap
                        font.pixelSize: 13
                        maximumLineCount: 100
                    }
                }
            }

        }
        // START-----> Серый прямоугольник с кнопкой "Вернуться к списку книг"
        Rectangle{
            id: rectBackListBooks
            width: parent.width
            anchors.bottom: parent.bottom

            height: btnBackListBooks.height + 20
            color: "grey"

            Button{
                id: btnBackListBooks
                width: textBackListBooks.width + 15
                height: textBackListBooks.height + 15


                onClicked: {
                    // sendRequestGetAllBooks()
                    rectBookInfo.visible = false
                    mainWindow.status = "listBooks"
                    itemBooks.visible = true
                }

                anchors.centerIn: parent
                background: Rectangle {
                    anchors.centerIn: parent
                    color: btnBackListBooks.down ? "#adadad" :"#cacaca"
                    radius: 5
                    Text{
                        id: textBackListBooks
                        anchors.centerIn: parent
                        text:"Вернуться к списку книг"
                        font.pixelSize: 15
                    }
                }

            }
        }
        // Серый прямоугольник с кнопкой "Вернуться к списку книг" <-----END
    }

    // START-----> Окно со списком всех книг
    Item{
        id: itemBooks
        anchors.fill: parent
        visible: test // !!

        Rectangle{
            width: parent.width
            height: parent.height - rectUpdateBtn.height
            color: backgroundColor

            // START-----> Представление - список
            ListView{
                id: listView
                focus: true

                // Индикатор ожидания загрузки информации о книгах
                BusyIndicator{
                    id: busyGetAllBooks
                    visible: true
                    anchors.centerIn: parent
                    width: parent.width > parent.height ? parent.height*0.4 : parent.width*0.4
                    height: width
                }

                // Сигнал для представления, чтобы отображать только те книги, cоответствующие
                // критериям поиска: будет искаться подстрока text в названии/авторе/жанре - это уже определяет category
                signal filteredItems(string text, int category)

                onFilteredItems: {
                    var childrenLength = listView.children[0].children.length

                    if(text.length == 0) // сделать все книги видимыми
                    {
                        for(var i = 0; i < childrenLength;++i)
                        {
                            // Только у компонентов книг objectName - непустая строка
                            if(!listView.children[0].children[i].objectName)
                            {
                                continue
                            }
                           listView.children[0].children[i].visible = true
                        }
                    }
                    else{
                        var currentEl = 0
                        for(i = 0; i < childrenLength;++i)
                        {
                         //   console.log("objectName",listView.children[0].children[i].objectName)
                            // Только у компонентов книг objectName - непустая строка
                            if(!listView.children[0].children[i].objectName)
                            {
                                continue
                            }

                            var isVisible = false

                            var myTxt = ''
                            var searchTxt = text.toLowerCase()

                            switch(category)
                            {
                            case 0:  // название
                                myTxt = listView.model[currentEl].title
                                break
                            case 1:  // автор
                                if(listView.model[currentEl].hasOwnProperty("author"))
                                    myTxt = listView.model[currentEl].author
                                break
                            case 2:  // жанр
                                if(listView.model[currentEl].hasOwnProperty("genre"))
                                    myTxt = listView.model[currentEl].genre
                                break
                            }
                            if(myTxt.length > 0)
                            {
                                isVisible = (myTxt.toLowerCase().indexOf(searchTxt) !== -1)
                            }
                            listView.children[0].children[i].visible = isVisible
                            ++currentEl
                        }
                    }
                    return

                    // Замена модели (не используется)


//                    if(text.length == 0)
//                    {
//                        for(var i = 0; i < newModel.length;++i)
//                        {
//                            newModel[i].visible = true
//                        }
//                    }
//                    return
//                    var newModel = listView.model

//                    if(text.length == 0)
//                    {
//                        for(var i = 0; i < newModel.length;++i)
//                        {
//                            newModel[i].visible = true
//                        }
//                    }
//                    else{
//                        for(i = 0; i < newModel.length;++i)
//                        {
//                            var isVisible = false

//                            var myTxt = ''
//                            var searchTxt = text.toLowerCase()

//                            switch(category)
//                            {
//                            case 0:  // название
//                                myTxt = newModel[i].title
//                                break
//                            case 1:  // автор
//                                if(newModel[i].hasOwnProperty("author"))
//                                    myTxt = newModel[i].author
//                                break
//                            case 2:  // жанр
//                                if(newModel[i].hasOwnProperty("genre"))
//                                    myTxt = newModel[i].genre
//                                break
//                            }
//                            if(myTxt.length > 0)
//                            {
//                                isVisible = (myTxt.toLowerCase().indexOf(searchTxt) !== -1)
//                                //      console.log("text = ", myTxt, isVisible, curI)
//                            }
//                            newModel[i].visible = isVisible
//                        }
//                    }
//                    listView.model = newModel

//                    return
                }


                // Верхняя часть окна при отображении списка книг
                header: Rectangle{
                    id: listHeader
                    width: parent.width
                    height: headerH
                    // Заполнение синим цветом
                    gradient: Gradient{
                        GradientStop{position: 0; color: btnOrdinaryColor}
                        GradientStop{position: 0.7; color: btnDownColor}
                    }
                    Text {
                        id: textBooks
                        anchors.horizontalCenter: parent.horizontalCenter

                        y: btnActiveSearch.y + btnActiveSearch.height*0.06
                        text: "Книги"
                        color: "grey"
                        font.bold: true
                        font.pointSize: 25
                    }
                    // START -----> Кнопка с лупой - активация поиска
                    Button{
                        id: btnActiveSearch
                        property bool isDown: false  // Кнопка может находиться а нажатом и ненажатом состоянии

                        height: headerH*0.85
                        y: headerH * 0.1

                        width: height

                        x: parent.width - width - 5 // отсуп 5 пикселей от правого края

                        onIsDownChanged: {
                            if(isDown)
                            {
                                parent.height = headerH + 10 + rectSearch.height
                                textInputSearch.cursorVisible =  true
                                if(textInputSearch.text.length > 0)
                                {
                                    listView.filteredItems(textInputSearch.text, rectCategorySearch.category)
                                }
                            }
                            else{
                                listView.filteredItems('',0)
                                parent.height = headerH
                            }
                            listView.positionViewAtBeginning ()  // Сделать так, чтобы был виден полностью header списка
                        }

                        background: Rectangle{
                            width: parent.width
                            height: parent.height
                            radius: 4
                            color: parent.isDown ? btnDownColor  :btnOrdinaryColor
                            border.width: parent.isDown ? 2 : 0
                            border.color: "#1350bb"

                            Image{
                                anchors.centerIn: parent
                                width: textBooks.height - 6
                                height: textBooks.height - 6
                                source: "qrc:/search.png"
                            }
                        }
                        // По щелчку изменить состояние кнокпи на противоположное
                        onClicked: {
                            isDown = !isDown
                        }
                    }
                    // Кнопка с лупой - активация поиска <----- END

                    // START -----> Кнопка: Оценить приложение
                    Button{
                        id: btnStar
                        //  anchors.verticalCenter: textBooks.verticalCenter
                        y: btnActiveSearch.y
                        height: btnActiveSearch.height
                        width: height
                        x: 5
                        background: Rectangle{
                            width: parent.width
                            height: parent.height
                            radius: 4
                            color: parent.down ? btnDownColor  :btnOrdinaryColor
                            Image{
                                anchors.centerIn: parent
                                width: parent.height - 6
                                height: parent.height - 6
                                source: "qrc:/yellowStar"
                            }
                        }
                        onClicked: {
                            mainWindow.status = "rateApp"
                            itemBooks.visible = false
                            rectStars.visible = true
                        }
                    }
                    // Кнопка: Оценить приложение <----- END

                    // START-----> Прямоугольная область поиска
                    Rectangle{
                        id: rectSearch
                        visible: btnActiveSearch.isDown
                        width: parent.width
                        height: 45
                        color: "white"
                        anchors.bottom: parent.bottom
                        border.width: 1
                        border.color: "#1350bb"

                        Text{
                            id: textSearch
                            text: "Поиск: "
                            x: 3
                            font.pointSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        TextInput{
                            anchors.verticalCenter: parent.verticalCenter
                            id: textInputSearch
                            anchors.left: textSearch.right
                            font.pixelSize: 15
                            //    anchors.right: rectCategorySearch.left
                            anchors.right: rectCategorySearch.left
                            maximumLength: 12

                            onActiveFocusChanged: {
                                if(btnActiveSearch.isDown)
                                {
                                    focus = true
                                }
                            }

                            onTextChanged: {
                                listView.filteredItems(textInputSearch.text, rectCategorySearch.category)
                            }
                        }


                        Rectangle{
                            id: rectCategorySearch
                            anchors.right: btnChangeCategory.left
                            width: 60
                            height: parent.height
                            border.width: 1

                            property int category: 0

                            onCategoryChanged: {
                                if(category > 2) category = 0
                                textCategorySearch.text = setCategory(category)
                                listView.filteredItems(textInputSearch.text, rectCategorySearch.category)
                            }

                            Text{
                                anchors.centerIn: parent
                                id: textCategorySearch
                                text: 'название'
                                font.pixelSize: 12
                            }
                        }

                        Button{
                            id: btnChangeCategory
                            width: parent.width * 0.10
                            height: parent.height - 2
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            text: "<h2>></h3>"
                            background: Rectangle{
                                color: parent.down ? btnDownColor : btnOrdinaryColor
                            }

                            onClicked: {
                                ++rectCategorySearch.category
                            }
                        }

                    }
                    // Прямоугольная область поиска <----- END
                }
                anchors.fill: parent
                //   model: test ? Books.jsonModel: []
             //   model:[]


                delegate: delegate  // id шаблона для отображение книг

            }
            // Представление - список <----- END
        }
        // START-----> Серый прямоугольник с кнопкой "Обновить"
        Rectangle{
            id: rectUpdateBtn
            width: parent.width
            anchors.bottom: parent.bottom

            height: btnUpdate.height + 20
            color: "grey"

            Button{
                id: btnUpdate
                //     width: textUpdate.width + 15
                width: btnBackListBooks.width
                height: btnBackListBooks.height

                // По клику отправить запрос серверу на получение информации о всех книгах
                onClicked: {
                    sendRequestGetAllBooks()
                }

                anchors.centerIn: parent
                background: Rectangle {
                    anchors.centerIn: parent
                    color: btnUpdate.down ? "#adadad" :"#cacaca"
                    radius: 5
                    Text{
                        id: textUpdate
                        anchors.centerIn: parent
                        text:"Обновить"
                        font.pixelSize: 15
                    }
                }

            }
        }
        // Серый прямоугольник с кнопкой "Обновить" <----- END
    }
    // Окно со списком всех книг <------ END




    // START -----> Окно: Оценить приложение
    Rectangle{
        id: rectStars
        anchors.fill: parent
   //     color: "white"
        visible: false

        Rectangle{
            id: rectRateApp
            anchors.top: parent.top
            width: parent.width
            height: headerH
            gradient: Gradient{
                GradientStop{position: 0; color: btnOrdinaryColor}
                GradientStop{position: 0.7; color: btnDownColor}
            }
            Text {
                id: textRateApp
                anchors.centerIn: parent
                text: "Оцените приложение"
                color: "grey"
                font.bold: true
                font.pointSize: 18
            }
        }
        // START-----> Прямоугольник с пятью звездами
        Rectangle{
            id: rect5Stars
            anchors.top: rectRateApp.bottom
            anchors.bottom: rectOk.top
            anchors.left: parent.left
            anchors.right: parent.right
            color: backgroundColor

            Row{
                id: rowStars
                property int previousCountYellowStar: 0
                property int countYellowStar: 0

                onCountYellowStarChanged: {
                    if(previousCountYellowStar == countYellowStar)
                    {
                        return
                    }
                    else if(countYellowStar < previousCountYellowStar)
                    {
                        for(var i = countYellowStar; i < previousCountYellowStar; ++i)
                        {
                            rowStars.children[i].source = "qrc:/emptyStar"
                        }
                    }
                    else
                    {
                        for(i = previousCountYellowStar; i < countYellowStar; ++i)
                        {
                            rowStars.children[i].source = "qrc:/yellowStar"
                        }
                    }

                    previousCountYellowStar = countYellowStar
                }

                width: parent.width * 0.85
                anchors.centerIn: parent
                spacing: parent.width * 0.02
                Repeater{
                    model: 5
                    Image{
                        width: parent.width * 0.18
                        height: width
                        source: "qrc:/emptyStar"
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                rowStars.countYellowStar = index + 1
                            }
                        }
                    }

                }
            }

        }
        // Прямоугольник с пятью звездами <-----END

        // START-----> Серый прямоугльник с кнопкой "Ok"
        Rectangle{
            id: rectOk
            width: parent.width
            anchors.bottom: parent.bottom

            height: rectBackListBooks.height
            color: "grey"

            Button{
                id: btnRateOk
                width: btnBackListBooks.width
                height: btnBackListBooks.height

                onClicked: {  // Обновляем рейтинг приложения
                    var msg = '{"type":'+Codes.RateAppSet+',"main":{"user_id":'+idUser+',"rate_app":' + rowStars.countYellowStar + '}}'
                    ws.sendTextMessage(msg)

                    rectStars.visible = false
                    mainWindow.status = "listBooks"
                    itemBooks.visible = true
                }

                anchors.centerIn: parent
                background: Rectangle {
                    anchors.centerIn: parent
                    color: btnRateOk.down ? "#adadad" :"#cacaca"
                    radius: 5
                    Text{
                        id: textOk
                        anchors.centerIn: parent
                        text:"Ok"
                        font.pixelSize: 15
                    }
                }

            }
        }
        // Серый прямоугльник с кнопкой "Ok" <-----END
    }
    // Окно: Оценить приложение <-----END




    ///////////  Функции
    function sendRequestGetAllBooks()
    {
        var msg = '{"type":'+Codes.GetAllBooks + '}'
        ws.sendTextMessage(msg)
        busyGetAllBooks.visible = true
    }

    // Обрезать часть строки и добавить многоточие
    function getLimitStr(str, endIndx)
    {
        return str.slice(0,endIndx) + '...'
    }

    // Вернуть строку или тире
    function getStrOrDash(str)
    {
        if(str) return str
        return '-'
    }

    // Забронирована ли книга, информацию о которой просматривают
    function isBron()
    {
        if(rectBookInfo.book.reservation_user_id > 0)
        {
            if(rectBookInfo.book.reservation_user_id == idUser) // книга забронирована этим пользователем
            {
                return 2
            }
            return 1  // Книга забронирована другим пользователем
        }
        return 0 // Книга доступна для бронирования
    }

    // Вернуть строку, отражающую статус бронирования книги
    function getReserveStatus(bron)
    {
        switch(bron)
        {
        case 0:
            return 'Книга доступна для бронирования'
        case 1:
            return 'Книга недоступна для бронирования до ' + rectBookInfo.book.time_unblocking
        case 2:
            return 'Книга забронирована вами до ' + rectBookInfo.book.time_unblocking
        }
    }

    // Функция возвращает цвет, согласно состоянию бронирования книги
    function getReserveColor(bron)
    {
        switch(bron)
        {
        case 0:
            return '#555555'  // серый
        case 1:
            return "#fb5252"  // красный
        case 2:
            return "green"
        }
    }

    function setReserveStatus()
    {
        var bron = isBron()
        textBronStatus.text = getReserveStatus(bron)
        textBronStatus.color = getReserveColor(bron)
        if(bron == 0)
        {
            btnReserveBook.visible = true
        }
        else
        {
            btnReserveBook.visible = false
        }
    }
    function setCategory(indx)
    {
        if(indx == 0) return 'название'
        if(indx == 1) return 'автор'
        return 'жанр'

    }


    WebSocket{
        id: ws
        property int isChecked: 0
        url: "ws://192.168.1.64:4735"
        active: !test //true

        onStatusChanged: {
        //    console.log("ws status = ", status)

            if(status == WebSocket.Open)
            {
                var msg = '{"type":'+ Codes.Check + ',"main":{"check":"mobileclient"}}'
                sendTextMessage(msg)
            }
            else if(status == WebSocket.Closed )
            {
                if(mainWindow.status == "selectVar")
                {
                    rectSelectVar.visible = false
                }
                else if(mainWindow.status == "auth" || mainWindow.status == "createUser")
                {
                    rectAuth.visible = false
                }
                else if(mainWindow.status == "tryConnect"  && timerTryConnect.isWaitingAnswer)
                {
                    timerTryConnect.running = false
                    startRect.visible = false
                }
                else if(mainWindow.status == "listBooks")
                {
                    itemBooks.visible = false
                }
                else if(mainWindow.status == "bookInfo")
                {
                    rectBookInfo.visible = false
                }
                else if(mainWindow.status == "rateApp")
                {
                    rectStars.visible = false
                }

                rectNoConnect.visible = true
            }
        }

        onTextMessageReceived: {
            var object = JSON.parse(message)
            var type = object.type
            var main = object.main
            var result = main.result

       //     console.log("ws: type = ",type)
            switch(type)
            {
            case Codes.Authorization:
                if(result == "yes")
                {
                    rectAuth.visible = false
                    mainWindow.status = "listBooks"
                    itemBooks.visible = true
                    idUser = main.user_id

                    if(main.rate_app)
                    {
                        rowStars.countYellowStar = main.rate_app
                    }
                    else
                    {
                        rowStars.countYellowStar = 5
                    }

              //      console.log("idUser =",idUser)
                    sendRequestGetAllBooks()
                }
                else
                {
                    textLogAuth.visible = true
                    textLogAuth.text = "Неверное имя пользователя или пароль"
                    textLogAuth.color = "red"
                }
                break
            case Codes.CreateUser:
                var login = main.login
                if(result == "yes")
                {
                    textLogAuth.text = 'Пользователь "' + login + '" успешно создан'
                    textLogAuth.color = "green"
                }
                else{
                    textLogAuth.text = 'Не удалось создать пользователя: "' + login + '"'
                    textLogAuth.color = "red"
                }
                textLogAuth.visible = true
                break

            case Codes.GetAllBooks:

                if(result == "yes")
                {
                    if(mainWindow.status == "bookInfo")
                    {
                        for(var i = 0; i < main.books.length; ++i)
                        {
                            if(main.books[i].book_id == rectBookInfo.book.book_id)
                            {
                                rectBookInfo.book = main.books[i]
                                break
                            }
                        }
                        setReserveStatus()
                    }

//                    for(i = 0; i < main.books.length; ++i)
//                    {
//                        main.books[i]["visible"] = true
//                    }
                    busyGetAllBooks.visible = false

                    listView.model = main.books

                }
                break
            case Codes.ReserveBook:
                if(result == "yes")
                {
                    sendRequestGetAllBooks()

                    rectBookInfo.book.reservation_user_id = idUser
                    // setReserveStatus()
                }

                break
            case Codes.Check:
                var check = main.check

         //       console.log("check = ", check)

                if(check == "server")
                {
                    isChecked = 2
                }
                else
                {
                    isChecked = 1
                }

                break
            }
        }
    }



    Rectangle{
        id: rectNoConnect
        color: backgroundColor
        anchors.fill: parent
        visible: false

        onVisibleChanged: {
            //  parent.chil
        }

        Text{
            text: "<h3>Ошибка подключения</h3>"
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height / 300 * 40
            color: "blue"
        }

        Image{
            id: imgClient
            source: "qrc:/eLibrary"
            scale: parent.width  / 1050
            //     anchors.verticalCenter: parent.verticalCenter
            transformOrigin: Item.Left

            x: 5
            anchors.verticalCenter: parent.verticalCenter

        }

        Text{
            text: "<h3>Client</h3>"
            x: 5 + 313*imgClient.scale / 2 - width / 2
            y: parent.height / 2 + 313*imgClient.scale / 2 + 20
        }

        Image {
            id: imgCrossedLine
            source: "qrc:/crossedLine"
            scale: parent.width / 600
            anchors.centerIn: parent
        }
        Text{
            id: textServer
            text: "<h3>Server</h3>"
            x: parent.width - 5 - 313*imgClient.scale / 2 - width / 2
            y: parent.height / 2 + 313*imgClient.scale / 2 + 20
        }

        Image{
            id: imgServer
            source: "qrc:/eLibrary"
            scale: parent.width / 1050
            //     anchors.verticalCenter: parent.verticalCenter
            transformOrigin: Item.Right

            x: parent.width - 5 - width
            anchors.verticalCenter: parent.verticalCenter
        }

        Button{
            id: btnExitNoConnect
            text: "<h4>ВЫЙТИ</h4>"
            //y: rectPassword.y + rectPassword.height + 20
            y:   {
                var myY = textServer.y + textServer.height + parent.height*0.05
                var myYplusH = myY + height
                return myYplusH > parent.height ? parent.height - 10 - height: myY
            }
            anchors.horizontalCenter : parent.horizontalCenter
            width: imgCrossedLine.width + 10
            height: 37

            background: Rectangle {
                color: btnExitNoConnect.down ? btnDownColor : btnOrdinaryColor
                border.width: 1
                border.color: btnExitNoConnect.down ? borderDownColor : borderOrdinaryColor
                radius: 17
            }
            onClicked: {
                Qt.quit()
            }
        }
    }


    Rectangle{
        id: startRect
        color: backgroundColor
        anchors.fill: parent

        visible: !test//true

        Image{
            id: eLibraryImg
            anchors.centerIn: parent
            scale: startRect.width > startRect.height ?  startRect.height/ 600 : startRect.width / 600

            source: "qrc:/eLibrary"
        }
        Text{
            text: "<h1>Library Client<h1>"
            anchors.horizontalCenter: parent.horizontalCenter
            y: eLibraryImg.y + eLibraryImg.height - 35
        }

        BusyIndicator{
            id: busyConnect
            visible: false
            anchors.centerIn: parent
            width: eLibraryImg.width * 0.35
            height: eLibraryImg.width * 0.35
        }

        Timer{
            id: timerTryConnect
            interval: 1500
            repeat: false
            property bool isWaitingAnswer: false
            running: !test//true
            onTriggered: {
                if(ws.isChecked == 0)
                {
                    if(!isWaitingAnswer)
                    {
                        busyConnect.visible = true
                        isWaitingAnswer = true
                        interval = 5000
                        running = true
                        return
                    }
                    else{
                        rectNoConnect.visible = true
                    }
                }
                else if(ws.isChecked == 1)
                {
                    rectNoConnect.visible = true
                }
                else // if(ws.isChecked == 2)
                {
                    mainWindow.status = "selectVar"
                    rectSelectVar.visible = true
                }
                startRect.visible = false

            }
        }
    }

    // Выбрать вариант
    Rectangle{
        id: rectSelectVar
        color: backgroundColor
        visible: false
        anchors.fill: parent
        Text{
            id: textSelectVar
            text: "<h2>Выберите вариант</h2>"
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.36

        }
        Button{
            id: btnSelectCreateAcc
            text: "<h4>СОЗДАТЬ НОВЫЙ АККАУНТ</h4>"
            //y: rectPassword.y + rectPassword.height + 20
            //      y: textSelectVar.y + textSelectVar.height + 1 + 3*parent.height/20
            y: btnBacktoSelect.y
            anchors.horizontalCenter : parent.horizontalCenter
            width: btnSelectEnter.width
            height: 37

            background: Rectangle {
                color: btnSelectCreateAcc.down ? btnDownColor : btnOrdinaryColor
                border.width: btnSelectCreateAcc.activeFocus ? 2 : 1
                border.color: btnSelectCreateAcc.down ? borderDownColor : borderOrdinaryColor
                radius: 17
            }
            onClicked: {
                rectSelectVar.visible = false
                mainWindow.status = "createUser"
                textLogAuth.visible = false
                rectAuth.visible = true
                //  rectNoConnect.visible = true
            }
        }

        Button{
            id: btnSelectEnter
            text: "<h4>ВОЙТИ В СУЩЕСТВУЮЩИЙ АККАУНТ</h4>"
            //  y: btnSelectCreateAcc.y + btnSelectCreateAcc.height + 3*parent.height/25
            y: btnCreateAcc.y
            anchors.horizontalCenter : parent.horizontalCenter
            //     width: btnCreateAcc.width
            height: 37
            background: Rectangle {
                color: btnSelectEnter.down ? btnDownColor : btnOrdinaryColor
                border.width: btnSelectEnter.activeFocus ? 2 : 1
                border.color: btnSelectEnter.down ? borderDownColor : borderOrdinaryColor
                radius: 17
            }

            onClicked: {
                rectSelectVar.visible = false
                mainWindow.status = "auth"
                textLogAuth.visible = false
                rectAuth.visible = true
            }
        }
    }



    // Авторизация или создание нового пользователя
    Rectangle{
        id: rectAuth
        color: backgroundColor
        anchors.fill: parent
        visible: false

        Text{
            id: textLogAuth
            color: "green"
            text: "Пользователь создан"
            font.pixelSize: 15
            visible: false
            x: 15
            y: 30
        }


        Text{
            id: textAuth
            text: mainWindow.status == "auth"?  "<h2>Авторизация</h2>": "<h2>Создание нового аккаунта</h2>"
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.25
        }

        Text{
            id: textLogin
            text: "<h3>логин</h3>"
            x: rectLogin.x - width - 10
            y: rectLogin.y + 3
        }
        Rectangle{
            y: textAuth.y + textAuth.height + 10
            id: rectLogin
            width: rectAuth.width / 2
            height: 24
            border.width: 1
            anchors.horizontalCenter: parent.horizontalCenter
            TextInput{
                id: inputLogin
                anchors.fill: parent
            //    text: "test"
                //     focus: true
                font.pixelSize: 16
                maximumLength: 19
            }
        }

        Text{
            id: textPassword
            text: "<h3>пароль</h3>"
            x: rectPassword.x - width - 10
            y: rectPassword.y + 3
        }
        Rectangle{
            id: rectPassword
            y: rectLogin.y + rectLogin.height + 10


            width: rectAuth.width / 2
            height: 24
            border.width: 1
            anchors.horizontalCenter: parent.horizontalCenter
            TextInput{
                id: inputPassword

                anchors.fill: parent
       //         text: "1234"
                focus: false
                font.pixelSize: 16
                maximumLength: 19
            }
        }

        Button{
            id: btnBacktoSelect
            text: "<h4>НАЗАД</h4>"

            y: rectPassword.y + rectPassword.height + 1 + 3*parent.height/30
            anchors.horizontalCenter : rectPassword.horizontalCenter
            height: 37
            width: btnCreateAcc.width

            background: Rectangle {
                color: btnBacktoSelect.down ? btnDownColor : btnOrdinaryColor
                border.width: btnBacktoSelect.activeFocus ? 2 : 1
                border.color: btnBacktoSelect.down ? borderDownColor : borderOrdinaryColor
                radius: 17
            }
            onClicked: {
                mainWindow.status = "selectVar"
                rectAuth.visible = false
                rectSelectVar.visible = true
            }
        }

        Button{
            id: btnCreateAcc
            implicitWidth: 160
            text: mainWindow.status == "createUser" ? "<h4>СОЗДАТЬ АККАУНТ</h4>": "<h4>ВОЙТИ</h4>"

            y: btnBacktoSelect.y + btnBacktoSelect.height + 1 + 3*parent.height/60
            anchors.horizontalCenter : rectPassword.horizontalCenter
            height: 37


            background: Rectangle {
                color: btnCreateAcc.down ? btnDownColor : btnOrdinaryColor
                border.width: btnCreateAcc.activeFocus ? 2 : 1
                border.color: btnCreateAcc.down ? borderDownColor : borderOrdinaryColor
                radius: 17
            }
            onClicked: {
                var type = mainWindow.status == "createUser" ? Codes.CreateUser : Codes.Authorization
                var msg = '{"type":'+ type +',"main":{"login":"'+inputLogin.text+'","pass":"'+inputPassword.text+'"}}'
                ws.sendTextMessage(msg)
            }
        }
    }
}

