//
//  SearchViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 01/02/2023.
//

import UIKit
import Alamofire
import SwiftSoup

class SearchViewController: UIViewController {

    // MARK: IBOutlet
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    
    // MARK: Variables
    let searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Tìm kiếm"
        textField.backgroundColor = .white
        textField.clipsToBounds = true
        return textField
    } ()
    
    var searchBooks = [Book]()
    var histories: [String] = ["sách", "truyện"]
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTextField()
        setupHistory()
        setupTabelView()
        setupStart()
    }
    
    func setupUI() {
        searchView.addSubview(searchTextField)
        
        searchTextField.leadingAnchor.constraint(equalTo: searchView.leadingAnchor, constant: 20).isActive = true
        searchTextField.trailingAnchor.constraint(equalTo: searchView.trailingAnchor, constant: -20).isActive = true
        searchTextField.centerYAnchor.constraint(equalTo: searchView.centerYAnchor).isActive = true
        searchTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        // prefix
        let prefix = UIImage(systemName: "magnifyingglass")
        searchTextField.addPaddingLeftIcon(prefix!, padding: 40)
        //suffix
        let suffix = UIImage(systemName: "mic.fill")
        searchTextField.addPaddingRightIcon(suffix!, padding: 40)
        // radius
        searchTextField.layer.cornerRadius = 10
        
        self.loadingView.isHidden = true
    }
    
    func setupTabelView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.separatorStyle = .none
        searchTableView.register(UINib(nibName: "BookTableViewCell", bundle: nil), forCellReuseIdentifier: "BookTableViewCell")
        searchTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
    }
    
    func setupTextField() {
        searchTextField.delegate = self
    }
    
    func setupStart() {
        //searchTextField.becomeFirstResponder()
    }
    
    func setupHistory() {
        histories = device["searchs"] as? [String] ?? []
    }
    
    func saveHistory(_ keyword: String) {
        histories.insert(keyword, at: 0)
        if histories.count > 12 {
            histories.removeLast()
        }
        saveSearchToFirebase(histories)
    }

    // MARK: Search Book
    func searchBook(_ keyword: String) {
        
        AF.request(ApiNameManager.shared.getUrlSearch(keyword)).responseString {[weak self] response in
            //debugPrint("Response: \(response)")
            
            guard let self = self else { return }
        
            guard let html = response.value else { return }
        
            do {
                let doc: Document = try SwiftSoup.parse(html)
                
                // list item
                let listBooks: Elements = try doc.select("div.form-group div.b-grid__img")
                
                for item in listBooks {
                    let title = try item.select("a").attr("title")
                    let url = try item.select("a").attr("href")
                    let imageUrl = try item.select("img").attr("data-src")
                    
                    var rating = Double.random(in: 3...5)
                    rating = Double(String(format: "%.1f", rating)) ?? 3
                    
                    let iBook: Book = Book()
                    iBook.title = title
                    iBook.url = url
                    iBook.imageUrl = imageUrl
                    iBook.rating = rating
                    
                    self.searchBooks.append(iBook)
                }
                
                // reload table view
                self.searchTableView.reloadData()
        
            } catch Exception.Error(let type, let message) {
                print("ERROR: ", type, message)
            } catch {
                print("error")
            }
        }
        //end
    }
    
    func searchBookAction() {
        // khi nhấn return
        searchTextField.resignFirstResponder() // Dừng nhập liệu, hạ bàn phím
        // empty data
        searchBooks.removeAll()
        
        
        let keyword = searchTextField.text

        guard let keyword = keyword else { return }
        
        // empty
        if keyword.isEmpty { return }
        
        loadingView.isHidden = false // start loading
        
        searchBook(keyword)
        
        // save history
        saveHistory(keyword)
        
        loadingView.isHidden = true // end loading
    }
}

// MARK: Extension Textfield
extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // Hàm được gọi khi textField đã được xoá sạch text
        print("Search did clear all")
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // Hàm này được họi khi nội dung cửa textField có sự thay đổi
        let keyword = searchTextField.text ?? ""
        if keyword.isEmpty {
            searchBooks.removeAll()
            searchTableView.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.searchBookAction()
        
        //view.endEditing(true) // dùng khi k xác định được đối tưong đang được nhập
        return true
    }
}

// MARK: Extension TableView
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // search history
            if searchBooks.count > 0 {
                return 0
            }
            return histories.count
        case 1: // search result
            return searchBooks.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0: // search history
            
            let bookCell = searchTableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
            bookCell.titleLabel.text =  histories[indexPath.row]
            return bookCell
            
        case 1: // search result
            
            let bookCell = searchTableView.dequeueReusableCell(withIdentifier: "BookTableViewCell", for: indexPath) as! BookTableViewCell
            bookCell.iBook = searchBooks[indexPath.row]
            return bookCell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: // search history
            return 50
        case 1: // search result
            return 110
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: // search history
            searchTextField.text = histories[indexPath.row]
            searchBookAction()
        case 1: // search result
            let iBook = searchBooks[indexPath.row]
            routeToBookInfo(iBook)
        default:
            print(indexPath)
        }
    }
}

// MARK: Extension TableView
extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return ""
//    }

//    // dat height cho header cua section
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
//        viewHeader.backgroundColor = .white
//
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: viewHeader.bounds.width, height: viewHeader.bounds.height))
//        label.text = headers[section]
//        label.textColor = .black
//        label.font = UIFont.boldSystemFont(ofSize: 32)
//
//        viewHeader.addSubview(label)
//        return viewHeader
//    }
    
}

// MARK: Route
extension SearchViewController: RouteBook {
    
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
