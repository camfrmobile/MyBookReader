//
//  FirebaseBook.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 06/02/2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

let deleteBook = Notification.Name("DeleteBook")


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
        iBook.author = Chapter(name: author.name, url: author.url)
    }
    if let category = docData["category"] as? Chapter {
        iBook.category = Chapter(name: category.name, url: category.url)
    }
    
    if let listChapter = docData["listChapter"] as? [Chapter] {
        for chapter in listChapter {
            let chapter = Chapter(name: chapter.name, url: chapter.url)
            iBook.listChapter.append(chapter)
        }
    }
    
    return iBook
}


func saveBookToDatabase(_ iBook: Book) {
    
    let book = formatBookToDoc(iBook)
    
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


func saveBookToDatabase(docId: String, data: [String: Any]) {
    
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
