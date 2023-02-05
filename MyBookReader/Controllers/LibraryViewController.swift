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
    
    // for loading
    // View which contains the loading text and the spinner
    let loadingView = UIView()
    // Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    // Text shown during load the TableView
    let loadingLabel = UILabel()
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        setLoadingScreen()
        
        loadDataLibrary()
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
                    var view = try item.select("div.slide-caption").text()
                    let imageUrl = try item.select("img").attr("data-src")
                    view = "Lượt xem: \(view)"
                    
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
            
            // remove loading
            self.removeLoadingScreen()
        }
        // end
    }
    
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (libraryTableView.bounds.width / 2) - (width / 2)
        let y = (libraryTableView.bounds.height / 2) - (height / 2)
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)

        // Sets loading text
        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Đang tải..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)

        // Sets spinner
        spinner.style = .large
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()

        // Adds text and spinner to the view
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)

        view.addSubview(loadingView)
        loadingView.center = libraryTableView.center
    }

   // Remove the activity indicator from the main view
    private func removeLoadingScreen() {
        // Hides and stops the text and the spinner
        spinner.stopAnimating()
        spinner.isHidden = true
        loadingLabel.isHidden = true
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
            
            bookCell.handleBook = {[weak self] bookItem in
                guard let self = self else { return }
                
                let bookVC = BookViewController()
                bookVC.modalPresentationStyle = .overFullScreen
                self.present(bookVC, animated: true)
            }
            
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
            return 105 // top book
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var bookItem: BookItem = BookItem(title: "", url: "", desc: "", imageUrl: "")
        switch indexPath.section {
        case 0: // new book
            bookItem = newBooks[indexPath.row]
        case 1: // top book
            bookItem = topBooks[indexPath.row]
        default:
            print(indexPath)
        }
        routeToBookNavigation(bookItem)
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
extension LibraryViewController: RouteApp {
    
    func routeToBookNavigation(_ bookItem: BookItem) {
        let bookVC = BookViewController()
        bookVC.bookItem = bookItem
        let bookNavigation = UINavigationController(rootViewController: bookVC)
        
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        keyWindow?.rootViewController = bookNavigation
    }
    
}
