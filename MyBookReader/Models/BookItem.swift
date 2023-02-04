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
    var desc: String               // so view
    var imageUrl : String       // url image
    
    init(title: String, url: String, desc: String, imageUrl: String) {
        self.title = title
        self.url = url
        self.desc = desc
        self.imageUrl = imageUrl
    }
}
