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
    
    // MARK: Variables
    let searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Tìm kiếm"
        textField.backgroundColor = .white
        textField.clipsToBounds = true
        return textField
    } ()
    
    var searchBooks = [BookItem]()
    var histories: [String] = ["sách", "truyện"]
    
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
        
        setupUI()
        setupTextField()
        setupTabelView()
        setupLoadingScreen()
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
        searchTextField.becomeFirstResponder()
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
                    
                    let itemBook: BookItem = BookItem(title: title, url: url, desc: "", imageUrl: imageUrl, rating: rating)
                    
                    self.searchBooks.append(itemBook)
                }
                
                // reload table view
                self.searchTableView.reloadData()
        
            } catch Exception.Error(let type, let message) {
                print(type)
                print(message)
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
            
        startLoadingScreen() // start loading
        
        searchBook(keyword)
        
        // save history
        histories.append(keyword)
        if histories.count > 10 {
            histories.remove(at: 0)
        }
        
        removeLoadingScreen() // end loading
    }
    
    // Set the activity indicator into the main view
    private func setupLoadingScreen() {
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (searchTableView.bounds.width / 2) - (width / 2)
        let y = (searchTableView.bounds.height / 2) - (height / 2)
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)

        // Sets loading text
        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Đang tìm..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)

        // Sets spinner
        spinner.style = .large
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()

        // Adds text and spinner to the view
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)

        view.addSubview(loadingView)
        removeLoadingScreen()
    }
    
    // Remove the activity indicator from the main view
     private func startLoadingScreen() {
         // Hides and stops the text and the spinner
         spinner.startAnimating()
         spinner.isHidden = false
         loadingLabel.isHidden = false
     }
    
    // Remove the activity indicator from the main view
     private func removeLoadingScreen() {
         // Hides and stops the text and the spinner
         spinner.stopAnimating()
         spinner.isHidden = true
         loadingLabel.isHidden = true
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
            bookCell.titleLabel.text = histories[indexPath.row]
            return bookCell
            
        case 1: // search result
            
            let bookCell = searchTableView.dequeueReusableCell(withIdentifier: "BookTableViewCell", for: indexPath) as! BookTableViewCell
            bookCell.bookItem = searchBooks[indexPath.row]
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
            let bookItem = searchBooks[indexPath.row]
            routeToBookNavigation(bookItem)
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
extension SearchViewController: RouteApp {
    
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
