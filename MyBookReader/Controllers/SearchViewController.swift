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
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    // MARK: Variables
//    let searchTextField: UITextField = {
//        let textField = UITextField()
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.placeholder = "Tìm kiếm"
//        textField.backgroundColor = .white
//        textField.clipsToBounds = true
//        return textField
//    } ()
    
    let clearAllButton: UIButton = {
        let button = UIButton()
        button.tintColor = .gray
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        return button
    } ()
    
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
    
    var searchBooks = [Book]()
    var histories: [String] = []
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLoadingView()
        setupHistory()
        setupTabelView()
        hideLoadingView()
    }
    
    func setupUI() {
//        searchView.addSubview(searchTextField)
//
//        searchTextField.leadingAnchor.constraint(equalTo: searchView.leadingAnchor, constant: 20).isActive = true
//        searchTextField.trailingAnchor.constraint(equalTo: searchView.trailingAnchor, constant: -20).isActive = true
//        searchTextField.centerYAnchor.constraint(equalTo: searchView.centerYAnchor).isActive = true
//        searchTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // prefix
        let prefix = UIImage(systemName: "magnifyingglass") ?? UIImage()
        searchTextField.addPaddingLeftIcon(prefix, padding: 40)
        
        //suffix
//        let right = UIImage(systemName: "person") ?? UIImage()
//        searchTextField.addPaddingRightIcon(right, padding: 40)
        
        let clearAllView: UIView = {
            let uiview = UIView()
            uiview.frame = CGRect(x: 0, y: 0, width: searchTextField.bounds.height, height: searchTextField.bounds.height)
            uiview.addSubview(clearAllButton)
            clearAllButton.frame = CGRect(x: 0, y: 0, width: searchTextField.bounds.height, height: searchTextField.bounds.height)
            return uiview
        } ()
        clearAllButton.addTarget(self, action: #selector(onClearAll), for: .touchDown)
        searchTextField.rightView = clearAllView
        searchTextField.rightViewMode = .always
        
        // radius
        searchTextField.layer.cornerRadius = 10
        searchTextField.delegate = self
        
    }
    
    func setupTabelView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.separatorStyle = .none
        searchTableView.register(UINib(nibName: "BookTableViewCell", bundle: nil), forCellReuseIdentifier: "BookTableViewCell")
        searchTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
        
        // kéo table để làm mới
        refreshControl.attributedTitle = NSAttributedString(string: "Kéo để làm mới")
        refreshControl.addTarget(self, action: #selector(self.refreshData(_:)), for: .valueChanged)
        searchTableView.addSubview(refreshControl) // not required when using UITableViewController
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
    
    func setupHistory() {
        histories = device["searchs"] as? [String] ?? []
    }
    
    func saveHistory(_ keyword: String) {
        histories = histories.filter {$0 != keyword}
        
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
        
        // check internet
        if !isConnectedToNetwork() {
            AlertHelper.sorry(message: "Không có Internet!", viewController: self)
            return
        }
        
        
        setupLoadingView() // start loading
        
        searchBook(keyword)
        
        // save history
        saveHistory(keyword)
        
        hideLoadingView()// end loading
    }
    
    // MARK: Action
    @objc func refreshData(_ sender: AnyObject) {
       // Code to refresh table view
        searchBookAction()
        endRefresh()
    }
    
    func endRefresh() {
        refreshControl.endRefreshing()
    }
    
    @objc func onClearAll() {
        searchTextField.text?.removeAll()
        searchTextField.becomeFirstResponder()
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
            if searchBooks.count > 0 || searchTextField.text != "" {
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
