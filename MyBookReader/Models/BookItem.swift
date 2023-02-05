//
//  Item.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 04/02/2023.
//

import Foundation

class BookItem {
    var title: String           // ten chuong
    var url: String             // url chuong
    var desc: String            // thong tin
    var imageUrl : String       // url image
    var rating: Double          // danh gia
    
    init() {
        self.title = ""
        self.url = ""
        self.desc = ""
        self.imageUrl = ""
        self.rating = 0
    }
    
    init(title: String, url: String, desc: String, imageUrl: String, rating: Double) {
        self.title = title
        self.url = url
        self.desc = desc
        self.imageUrl = imageUrl
        self.rating = rating
    }
}
