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
    var author: Chapter         // tac gia
    var category: Chapter        // the loai
    var totalChapter: Int       // so chuong
    var view: Int               // luot xem
    var desc: String            // description
    var imageUrl : String       // url image
    var url: String             // url book detail
    var listChapter: [Chapter]   // Muc luc sach
    
    init() {
        self.id = ""
        self.title = ""
        self.author = Chapter()
        self.category = Chapter()
        self.totalChapter = 0
        self.view = 0
        self.desc = ""
        self.imageUrl = ""
        self.url = ""
        self.listChapter = []
    }
    
    init(id: String, title: String, author: Chapter, category: Chapter, totalChapter: Int, view: Int, desc: String, imageUrl: String, url: String, listChapter: [Chapter]) {
        self.id = id
        self.title = title
        self.author = author
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
    var name: String           // ten chuong
    var url: String             // url chuong
    
    init() {
        self.name = ""
        self.url = ""
    }
    
    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}

