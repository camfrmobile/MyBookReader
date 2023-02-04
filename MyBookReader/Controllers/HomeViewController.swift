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
        if readingBooks.count == 0 {
            let item = BookItem(title: "", url: "", desc: "", imageUrl: "")
            readingBooks.append(item)
        }
    }

    // MARK: IBAction
    @IBAction func accountButtonAction(_ sender: UIButton) {
        tabBarController?.selectedIndex = 3
    }
    
    
    
    // MARK: Route
    private func routeToBookNavigation(bookurl: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let bookNavigation = storyboard.instantiateViewController(withIdentifier: "BookNavigation")
        
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        keyWindow?.rootViewController = bookNavigation
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
            
            self.routeToBookNavigation(bookurl: "")
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
        let bookVC = BookViewController()
        //bookVC.modalPresentationStyle = .overFullScreen

//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterViewController")
        navigationController?.pushViewController(bookVC, animated: true)
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
