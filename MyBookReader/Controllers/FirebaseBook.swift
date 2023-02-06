//
//  FirebaseBook.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 06/02/2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftyJSON

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
            print("USER add successfully")
        }
    }
    
}


func convertBookToDoc(_ iBook: Book) -> [String: Any] {
    
    var listChapter: [String: Any] = [:]
    let updatedAt = Date().timeIntervalSince1970
    
    for (index, value) in iBook.listChapter.enumerated() {
        listChapter["\(index)"] = [
            "name": value.name,
            "url": value.url
        ]
    }
    
    let data: [String : Any] = [
        "id": iBook.id,
        "title": iBook.title,
        "author": [
            "name": iBook.author.name,
            "url": iBook.author.url
        ],
        "category": [
            "name": iBook.category.name,
            "url": iBook.category.url
        ],
        "totalChapter": iBook.totalChapter,
        "view": iBook.view,
        "desc": "",//book.desc,
        "imageUrl": iBook.imageUrl,
        "url": iBook.url,
        "listChapter": listChapter,
        "status": iBook.status,
        "isFavorite": iBook.isFavorite,
        "updatedAt": updatedAt,
        "fontSize": iBook.fontSize
    ]
    
    return data
}


func convertDocToBook(_ docData: [String: Any]) -> Book {
    
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
    iBook.isFavorite = docData["isFavorite"] as? Bool ?? false
    iBook.fontSize = docData["fontSize"] as? CGFloat ?? 20
    
    let author = JSON(docData["author"] ?? "")
    iBook.author = Chapter(name: author["name"].stringValue, url: author["url"].stringValue)
    
    let category = JSON(docData["category"] ?? "")
    iBook.category = Chapter(name: category["name"].stringValue, url: category["url"].stringValue)
    
    let data = JSON(docData["listChapter"] ?? "")
    for (_, value) in data {
        let name: String = value["name"].stringValue
        let url: String = value["url"].stringValue
        //print(key, name, url)
        
        let chapter = Chapter(name: name, url: url)

        iBook.listChapter.append(chapter)
    }
    
    return iBook
}


func saveBookToFirebase(_ iBook: Book) {
    
    let book = convertBookToDoc(iBook)
    
    fsdb.collection("users").document(identification).getDocument { (document, error) in
        if let document = document, document.exists {
            // start
            document.reference.collection("books").document(iBook.id).setData(book) { err in
                if let err = err {
                    print("ERROR writing document: \(err)")
                } else {
                    print("SAVE book successfully")
                }
            }
            // end
        } else {
            print("Document does not exist", 1)
        }
    }
    //end
}


func saveBookToFirebase(docId: String, data: [String: Any]) {
    
    fsdb.collection("users").document(identification).getDocument { (document, error) in
        if let document = document, document.exists {
            // start
            document.reference.collection("books").document(docId).updateData(data) { err in
                if let err = err {
                    print("ERROR update \(err)")
                } else {
                    print("UPDATE value successfully")
                }
            }
            // end
        } else {
            print("Document does not exist", 2)
        }
    }
    //end
}


func saveUserToFirebase(data: [String: Any]) {
    
    fsdb.collection("users").document(identification).updateData(data) { err in
        if let err = err {
            print("ERROR update \(err)")
        } else {
            print("UPDATE value successfully")
        }
    }
}