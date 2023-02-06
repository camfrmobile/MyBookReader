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
    @IBOutlet weak var loadingView: UIView!
    
    // MARK: Variables
    var headers = ["Sách mới cập nhật", "Sách xem nhiều"]
    var newBooks = [Book]()
    var topBooks = [Book]()
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        setupTableView()
        
        loadDataLibrary()
    }
    
    func setupUI() {
        loadingView.isHidden = false
    }
    
    func setupTableView() {
        libraryTableView.delegate = self
        libraryTableView.dataSource = self
        libraryTableView.separatorStyle = .none
        libraryTableView.register(UINib(nibName: "BookTableViewCell", bundle: nil), forCellReuseIdentifier: "BookTableViewCell")
        libraryTableView.register(UINib(nibName: "BookCollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "BookCollectionTableViewCell")
    }
    
    func loadDataLibrary() {
        
        AF.request(ApiNameManager.shared.getUrlLibrary()).responseString {[weak self] response in
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
                let listNewiBooks: Elements = try doc.select("div.list-post-show").first()!.select("div.item-box a")
                
                for item in listNewiBooks {
                    let title = try item.attr("title")
                    let url = try item.attr("href")
                    let imageUrl = try item.select("img").attr("data-src")
                    
                    // get rating
                    var rating = Double.random(in: 3...5)
                    rating = Double(String(format: "%.1f", rating)) ?? 3
                    
                    let iBook: Book = Book()
                    iBook.title = title
                    iBook.url = url
                    iBook.imageUrl = imageUrl
                    iBook.rating = rating
                    
                    self.newBooks.append(iBook)
                }
                
                // list top book
                let listTopBooksItems: Elements = try doc.select("div.list-post-show.by-view").first()!.select("div.item-box a")
                
                for item in listTopBooksItems {
                    let title = try item.attr("title")
                    let url = try item.attr("href")
                    var view = try item.select("div.slide-caption").text()
                    let imageUrl = try item.select("img").attr("data-src")
                    view = "Lượt xem: \(view)"
                    
                    // get rating
                    var rating = Double.random(in: 3...5)
                    rating = Double(String(format: "%.1f", rating)) ?? 3
                    
                    let iBook: Book = Book()
                    iBook.title = title
                    iBook.url = url
                    iBook.imageUrl = imageUrl
                    iBook.rating = rating
                    iBook.desc = view
                    
                    self.topBooks.append(iBook)
                }
                
                // reload table view
                self.libraryTableView.reloadData()
                
            } catch Exception.Error(let type, let message) {
                print("ERROR: ", type, message)
            } catch {
                print("error")
            }
            
            // remove loading
            self.loadingView.isHidden = true
        }
        // end
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
            
            bookCell.handleBook = {[weak self] iBook in
                guard let self = self else { return }
                
                self.routeToBookInfo(iBook)
            }
            
            bookCell.iBooks = newBooks
            
            return bookCell
            
        case 1: // top book
            
            let bookCell = libraryTableView.dequeueReusableCell(withIdentifier: "BookTableViewCell", for: indexPath) as! BookTableViewCell
            
            bookCell.iBook = topBooks[indexPath.row]
            
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
            return 105 // top book
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var iBook: Book = Book()
        switch indexPath.section {
        case 0: // new book
            iBook = newBooks[indexPath.row]
        case 1: // top book
            iBook = topBooks[indexPath.row]
        default:
            print(indexPath)
        }
        routeToBookInfo(iBook)
    }
}

// MARK: Extension Table View
extension LibraryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headers.count
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

// MARK: Route
extension LibraryViewController: RouteBook {
    
    func routeToBookInfo(_ iBook: Book) {
        let bookVC = BookViewController()
        bookVC.iBook = iBook
        bookVC.modalPresentationStyle = .overFullScreen
        
        present(bookVC, animated: false)
    }
    
//    func routeToBookNavigation(_ iBook: iBook) {
//        let bookVC = BookViewController()
//        bookVC.iBook = iBook
//        let navigation = UINavigationController(rootViewController: bookVC)
//        
//        let keyWindow = UIApplication.shared.connectedScenes
//            .filter({$0.activationState == .foregroundActive})
//            .compactMap({$0 as? UIWindowScene})
//            .first?.windows
//            .filter({$0.isKeyWindow}).first
//        
//        keyWindow?.rootViewController = navigation
//    }
    
}
