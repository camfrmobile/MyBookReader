//
//  Book.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 01/02/2023.
//

import Foundation

class Book {
    var id: String
    var title: String           // ten sach
    var authorName: String      // ten tac gia
    var authorUrl: String       // url tac gia
    var category: String        // the loai
    var totalChapter: Int       // so chuong
    var view: Int               // luot xem
    var desc: String            // description
    var imageUrl : String       // url image
    var url: String             // url book detail
    var listChapter: [Chapter]   // Muc luc sach
    
    init(id: String, title: String, authorName: String, authorUrl: String, category: String, totalChapter: Int, view: Int, desc: String, imageUrl: String, url: String, listChapter: [Chapter]) {
        self.id = id
        self.title = title
        self.authorName = authorName
        self.authorUrl = authorUrl
        self.category = category
        self.totalChapter = totalChapter
        self.view = view
        self.desc = desc
        self.imageUrl = imageUrl
        self.url = url
        self.listChapter = listChapter
    }
}

class Chapter {
    var title: String           // ten chuong
    var url: String             // url chuong
    
    init(title: String, url: String) {
        self.title = title
        self.url = url
    }
}
