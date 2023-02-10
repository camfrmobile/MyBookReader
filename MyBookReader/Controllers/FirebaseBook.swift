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
import FirebaseStorage

var identification: String = UUID().uuidString

var device: [String: Any] = getDevice()

let fsdb = Firestore.firestore()
let storageRef = Storage.storage().reference()


func getDevice() -> [String: Any] {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    let createdAt = formatter.string(from: Date())
    
    let device: [String: Any] = [
        "name": UIDevice.current.name,
        "system": UIDevice.current.systemName,
        "searchs": ["sách", "truyện"],
        "createdAt": createdAt
    ]
    return device
}

func setupUser() {
    
    if let user = Auth.auth().currentUser {
        identification = user.uid
    } else {
        identification = UIDevice.current.identifierForVendor?.uuidString ?? identification
    }
    print("ID", identification)
    
    // get user
    fsdb.collection("users").document(identification).getDocument { (document, error) in
        if let document = document, document.exists {
            let docData = document.data()
            
            guard let docData = docData else { return }
            
            device["searchs"] = docData["searchs"] as? [String] ?? []
            
        } else {
            print("USER not exist")
            // add user
            fsdb.collection("users").document(identification).setData(device) { err in
                if let err = err {
                    print("Error0: \(err)")
                } else {
                    print("USER add successfully")
                }
            }
        }
    }
}

func loadPhotoFromFirebase(_ imageView: UIImageView) {
    // Create a reference to the file you want to download
    let starsRef = storageRef.child("images/\(identification).jpg")

    // Fetch the download URL
    starsRef.downloadURL {url, error in
      if let error = error {
          print(error.localizedDescription)
          imageView.image = UIImage(systemName: "person.circle")
      } else {
          guard let url = url else { return }
          imageView.setImage(urlString: url.absoluteString)
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
        "desc": iBook.desc,
        "imageUrl": iBook.imageUrl,
        "url": iBook.url,
        "listChapter": listChapter,
        "rating": iBook.rating,
        "status": iBook.status,
        "isFavorite": iBook.isFavorite,
        "updatedAt": updatedAt,
        "fontSize": iBook.fontSize,
        "chapterIndex": iBook.chapterIndex,
        "chapterOffSet": iBook.chapterOffSet
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
    iBook.chapterOffSet = docData["chapterOffSet"] as? CGFloat ?? 0
    
    let author = JSON(docData["author"] ?? "")
    iBook.author = Chapter(name: author["name"].stringValue, url: author["url"].stringValue)
    
    let category = JSON(docData["category"] ?? "")
    iBook.category = Chapter(name: category["name"].stringValue, url: category["url"].stringValue)
    
    let data = JSON(docData["listChapter"] ?? "")
    var dictionary: [String: Chapter] = [:]

    for (key, value) in data {
//        print(key)
        let name: String = value["name"].stringValue
        let url: String = value["url"].stringValue
        //print(key, name, url)
        
        let chapter = Chapter(name: name, url: url)
        dictionary[key] = chapter
    }
    
    //let sortedKeys = Array(dictionary.keys).sorted(by: <)
    for key in 0..<dictionary.count {
        iBook.listChapter.append(dictionary["\(key)"] ?? Chapter())
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


func saveSearchToFirebase(_ histories: [String]) {
    
    fsdb.collection("users").document(identification).updateData(["searchs" : histories]) { err in
        if let err = err {
            print("ERROR update \(err)")
        } else {
            print("UPDATE value successfully")
        }
    }
    //end
}

func uploadPhotoToFirebase() {
    // Data in memory
    let data = Data()

    // Create a reference to the file you want to upload
    let riversRef = storageRef.child("images/rivers.jpg")

    // Upload the file to the path "images/rivers.jpg"
    let uploadTask = riversRef.putData(data, metadata: nil) { (metadata, error) in
      guard let metadata = metadata else {
        // Uh-oh, an error occurred!
        return
      }
      // Metadata contains file metadata such as size, content-type.
      let size = metadata.size
      // You can also access to download URL after upload.
      riversRef.downloadURL { (url, error) in
        guard let downloadURL = url else {
          // Uh-oh, an error occurred!
          return
        }
      }
    }
}
