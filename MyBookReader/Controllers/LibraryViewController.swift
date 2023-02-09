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
    var headers = ["Sách mới cập nhật", "Sách xem nhiều", "Danh mục - Thể loại"]
    var newBooks = [Book]()
    var topBooks = [Book]()
    var categories = listCategories()
    var cateBooks = [Book]()
    
    let activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.style = .large
        return activity
    } ()
    let loadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Đang tải..."
        return label
    } ()
    let loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    } ()
    
    let refreshControl = UIRefreshControl()
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        setupLoadingView()
        
        setupTableView()
        
        loadDataLibrary()
    }
    
    func setupUI() {

    }
    
    func setupTableView() {
        libraryTableView.delegate = self
        libraryTableView.dataSource = self
        libraryTableView.separatorStyle = .none
        libraryTableView.register(UINib(nibName: "BookTableViewCell", bundle: nil), forCellReuseIdentifier: "BookTableViewCell")
        libraryTableView.register(UINib(nibName: "BookCollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "BookCollectionTableViewCell")
        
        // kéo table để làm mới
        refreshControl.attributedTitle = NSAttributedString(string: "Kéo để làm mới")
        refreshControl.addTarget(self, action: #selector(self.refreshData(_:)), for: .valueChanged)
        libraryTableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    func setupLoadingView() {
        view.addSubview(loadingView)
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(loadingLabel)
        
        loadingView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor).isActive = true
        
        loadingLabel.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor).isActive = true
        loadingLabel.leadingAnchor.constraint(equalTo: activityIndicator.trailingAnchor, constant: 10).isActive = true
        
        activityIndicator.startAnimating()
    }
    func hideLoadingView() {
        loadingView.removeFromSuperview()
    }
    
    func loadDataLibrary() {
        
        // check internet
        if !isConnectedToNetwork() {
            activityIndicator.stopAnimating()
            loadingLabel.text = "Không có Internet"
            return
        }
        
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
            self.hideLoadingView()
        }
        // end
    }
    
    func loadDataCategory(_ url: String) {
        
        cateBooks.removeAll()
        setupLoadingView()
        
        // check internet
        if !isConnectedToNetwork() {
            activityIndicator.stopAnimating()
            loadingLabel.text = "Không có Internet"
            return
        }
        
        AF.request(url).responseString {[weak self] response in
            //debugPrint("Response: \(response)")
            
            guard let self = self else { return }
        
            guard let html = response.value else { return }
            print("OK")
            do {
                let doc: Document = try SwiftSoup.parse(html)
                
                // list cate book
                let listNewiBooks: Elements = try doc.select("#list-posts div.row div.form-group")
                
                for item in listNewiBooks {
                    let title = try item.select("h3 a").text()
                    let url = try item.select("a").attr("href")
                    let imageUrl = try item.select("img").attr("data-src")
                    
                    // get rating
                    var rating = Double.random(in: 3...5)
                    rating = Double(String(format: "%.1f", rating)) ?? 3
                    
                    let iBook: Book = Book()
                    iBook.title = title
                    iBook.url = url
                    iBook.imageUrl = imageUrl
                    iBook.rating = rating
                    
                    self.cateBooks.append(iBook)
                }
                
                // reload table view
                self.libraryTableView.reloadData()
                
            } catch Exception.Error(let type, let message) {
                print("ERROR: ", type, message)
            } catch {
                print("error")
            }
            
            // remove loading
            self.hideLoadingView()
        }
        // end
    }
    
    // MARK: Action
    @objc func refreshData(_ sender: AnyObject) {
       // Code to refresh table view
        cateBooks.removeAll()
        loadDataLibrary()
        endRefresh()
    }
    
    func endRefresh() {
        refreshControl.endRefreshing()
    }
    
}

// MARK: Extension Table View
extension LibraryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // New book
            return 1
        case 1: // Top book
            return topBooks.count
        case 2: // cate
            if cateBooks.count == 0 {
                return categories.count
            }
            return cateBooks.count
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
            
        case 2: // cate book
            if cateBooks.count == 0 {
                let bookCell = UITableViewCell()
                bookCell.textLabel?.text = categories[indexPath.row].name
                return bookCell
            } else {
                let bookCell = libraryTableView.dequeueReusableCell(withIdentifier: "BookTableViewCell", for: indexPath) as! BookTableViewCell
                bookCell.iBook = cateBooks[indexPath.row]
                return bookCell
            }
            
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
        case 2:
            if cateBooks.count == 0 {
                return UITableView.automaticDimension
            }
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
        case 2: // top book
            if cateBooks.count == 0 {
                let url = categories[indexPath.row].url
                headers[indexPath.section] = categories[indexPath.row].name
                loadDataCategory(url)
                return
            }
            iBook = cateBooks[indexPath.row]
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
