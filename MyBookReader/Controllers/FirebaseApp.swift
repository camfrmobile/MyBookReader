//
//  FirebaseApp.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 05/02/2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

let authUser = Auth.auth().currentUser

var identification: String = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString

let device: [String: Any] = [
    "name": UIDevice.current.name,
    "system": UIDevice.current.systemName
]

let fsdb = Firestore.firestore()

func setupUser() {
    if let authUser = authUser {
        identification = authUser.uid
    }
    
    fsdb.collection("users").document(identification).setData(device) { err in
        if let err = err {
            print("Error0: \(err)")
        } else {
            print("OK0 successfully")
        }
    }
    
}


func docToBook(_ docData: [String: Any]) -> Book {
    
    let iBook = Book()
    iBook.id = docData["id"] as? String ?? ""
    iBook.title = docData["title"] as? String ?? ""
    iBook.totalChapter = docData["totalChapter"]  as? Int ?? 0
    iBook.view = docData["view"]  as? Int ?? 0
    iBook.desc = docData["desc"]  as? String ?? ""
    iBook.imageUrl = docData["imageUrl"]  as? String ?? ""
    iBook.url = docData["url"]  as? String ?? ""
    
    iBook.chapterIndex = docData["chapterIndex"]  as? Int ?? 0
    iBook.rating = docData["rating"] as? Double ?? 0
    iBook.status = docData["status"]  as? String ?? ""
    iBook.isFavorite = docData["isFavorite"]  as? Bool ?? false
    
    if let author = docData["author"] as? Chapter {
        iBook.author.name = author.name
        iBook.author.url = author.url
    }
    if let category = docData["category"] as? Chapter {
        iBook.category.name = category.name
        iBook.category.url = category.url
    }
    
    if let listChapter = docData["listChapter"] as? [Chapter] {
        print(listChapter[0].name)
        print(listChapter[0].url)
        for (index, value) in listChapter.enumerated() {
            iBook.listChapter[index].name = value.name
            iBook.listChapter[index].url = value.url
        }
    }
    
    return iBook
}
