//
//  LibraryViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 01/02/2023.
//

import UIKit
import Alamofire
import SwiftSoup

class LibraryViewController: UIViewController {
    
    // MARK: IBOutlet
    @IBOutlet weak var libraryTableView: UITableView!
    
    // MARK: Variables
    var headers = ["Sách mới cập nhật", "Sách xem nhiều"]
    var newBooks = [BookItem]()
    var topBooks = [BookItem]()
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        
        AF.request(ApiNameManager.shared.getUrlHome()).responseString {[weak self] response in
            //debugPrint("Response: \(response)")
            
            guard let self = self else { return }
        
            guard let html = response.value else { return }
        
            do {
                let doc: Document = try SwiftSoup.parse(html)
                
                let listBooks: Elements = try doc.select("div.list-post-show")
                //print(listBooks.count)
                if listBooks.count < 2 {
                    return
                }
                // list new book
                let listNewBookItems: Elements = try doc.select("div.list-post-show").first()!.select("div.item-box a")
                
                for item in listNewBookItems {
                    let title = try item.attr("title")
                    let url = try item.attr("href")
                    let imageUrl = try item.select("img").attr("data-src")
                    
                    let itemBook: BookItem = BookItem(title: title, url: url, desc: "", imageUrl: imageUrl)
                    
                    self.newBooks.append(itemBook)
                }
                
                // list top book
                let listTopBooksItems: Elements = try doc.select("div.list-post-show.by-view").first()!.select("div.item-box a")
                
                for item in listTopBooksItems {
                    let title = try item.attr("title")
                    let url = try item.attr("href")
                    let view = try item.select("div.slide-caption").text()
                    let imageUrl = try item.select("img").attr("data-src")
                    
                    let itemBook: BookItem = BookItem(title: title, url: url, desc: view, imageUrl: imageUrl)
                    
                    self.topBooks.append(itemBook)
                }
                
                // reload table view
                self.libraryTableView.reloadData()
        
            } catch Exception.Error(let type, let message) {
                print(type)
                print(message)
            } catch {
                print("error")
            }
        }

    }
    
    func setupTableView() {
        libraryTableView.delegate = self
        libraryTableView.dataSource = self
        libraryTableView.separatorStyle = .none
        libraryTableView.register(UINib(nibName: "BookTableViewCell", bundle: nil), forCellReuseIdentifier: "BookTableViewCell")
        libraryTableView.register(UINib(nibName: "BookCollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "BookCollectionTableViewCell")
    }
    
}

// MARK: Extension Table View
extension LibraryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1 // New book
        case 1:
            return topBooks.count // Top book
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0: // new book
            
            let bookCell = libraryTableView.dequeueReusableCell(withIdentifier: "BookCollectionTableViewCell", for: indexPath) as! BookCollectionTableViewCell
            
            bookCell.bookItems = newBooks
            
            return bookCell
            
        case 1: // top book
            
            let bookCell = libraryTableView.dequeueReusableCell(withIdentifier: "BookTableViewCell", for: indexPath) as! BookTableViewCell
            
            bookCell.bookItem = topBooks[indexPath.row]
            
            return bookCell
            
        default:
            let bookCell = UITableViewCell()
            return bookCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 300 // new book
        case 1:
            return 105 // too book
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
}

// MARK: Extension Table View
extension LibraryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }
    
    // dat height cho header cua section
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        viewHeader.backgroundColor = .white

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: viewHeader.bounds.width, height: viewHeader.bounds.height))
        label.text = headers[section]
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 32)
        
        viewHeader.addSubview(label)
        return viewHeader
    }
    
}
