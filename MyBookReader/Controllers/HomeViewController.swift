//
//  HomeViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 01/02/2023.
//

import UIKit
import Alamofire
import SwiftSoup

class HomeViewController: UIViewController {

    // MARK: IBOutlet
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var helloLabel: UILabel!
    
    // MARK: Variables
    var headers = ["Đang đọc", "Đọc xong", "Đọc sau"]
    var readingBooks = [BookItem]()
    var doneBooks = [BookItem]()
    var scheduleBooks = [BookItem]()
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupNew()
    }
    
    func setupUI() {
        accountButton.clipsToBounds = true
        accountButton.layer.cornerRadius = accountButton.bounds.width / 2
    }
    
    func setupTableView() {
        homeTableView.delegate = self
        homeTableView.dataSource = self
        homeTableView.separatorStyle = .none
        homeTableView.register(UINib(nibName: "BookTableViewCell", bundle: nil), forCellReuseIdentifier: "BookTableViewCell")
        homeTableView.register(UINib(nibName: "BookCollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "BookCollectionTableViewCell")
    }
    
    func setupNew() {
        if readingBooks.count == 0 && doneBooks.count == 0 && scheduleBooks.count == 0 {
            let item = BookItem(title: "", url: "", desc: "", imageUrl: "", rating: 0)
            readingBooks.append(item)
        }
    }

    // MARK: IBAction
    @IBAction func accountButtonAction(_ sender: UIButton) {
        switchToTabAccount()
    }
    
    
    // MARK: Switch
    func switchToTabHome() {
        tabBarController?.selectedIndex = 0
    }
    func switchToTabLibrary() {
        tabBarController?.selectedIndex = 1
    }
    func switchToTabSearch() {
        tabBarController?.selectedIndex = 2
    }
    func switchToTabAccount() {
        tabBarController?.selectedIndex = 3
    }
    
}

// MARK: Extension Table View
extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return readingBooks.count // reading book
        case 1:
            return doneBooks.count // done book
        case 2:
            return scheduleBooks.count // schedule book
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let bookCell = homeTableView.dequeueReusableCell(withIdentifier: "BookCollectionTableViewCell", for: indexPath) as! BookCollectionTableViewCell
        
        bookCell.handleBook = {[weak self] bookItem in
            guard let self = self else { return }
            
            if bookItem.title.isEmpty && bookItem.url.isEmpty && bookItem.desc.isEmpty && bookItem.desc.isEmpty {
                self.switchToTabLibrary()
                return
            }
            
            // go to book
            self.routeToBookNavigation(bookItem)
        }
        
        switch indexPath.section {
        case 0: // reading book
            
            bookCell.bookItems = readingBooks
            
            return bookCell
            
        case 1: // done book
            
            bookCell.bookItems = doneBooks
            
            return bookCell
            
        case 2: // schedule book
            
            bookCell.bookItems = scheduleBooks
            
            return bookCell
            
        default:
            return bookCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0,1,2:
            return 300 // new book
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        var bookItem: BookItem = BookItem(title: "", url: "", desc: "", imageUrl: "", rating: 0)
        switch indexPath.section {
        case 0: // reading book
            bookItem = readingBooks[indexPath.row]
        case 1: // done book
            bookItem = doneBooks[indexPath.row]
        case 2: // schedule book
            bookItem = scheduleBooks[indexPath.row]
        default:
            print(indexPath)
        }
        routeToBookNavigation(bookItem)
    }
}

// MARK: Extension Table View
extension HomeViewController: UITableViewDataSource {
    
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
extension HomeViewController: RouteApp {
    
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
