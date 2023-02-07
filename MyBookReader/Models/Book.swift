//
//  Book.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 01/02/2023.
//

import Foundation
import SwiftyJSON

class Book {
    var id: String = ""
    var title: String = ""              // ten sach
    var author: Chapter = Chapter()     // tac gia
    var category: Chapter = Chapter()   // the loai
    var totalChapter: Int = 0           // so chuong
    var view: Int = 0                   // luot xem
    var desc: String = ""               // description
    var imageUrl : String = ""          // url image
    var url: String = ""                // url book detail
    var listChapter: [Chapter] = []     // Muc luc sach
    var rating: Double = 0
    var status: String = ""
    var isFavorite: Bool = false
    var fontSize: CGFloat = 20
    var chapterIndex = 0
    var chapterOffSet: CGFloat = 0
    
    init() {
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
    var name: String = ""           // ten chuong
    var url: String = ""             // url chuong
    
    init() {
    }
    
    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}
