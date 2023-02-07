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
    var readingBooks = [Book]()
    var doneBooks = [Book]()
    var scheduleBooks = [Book]()
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUser()
        
        setupUI()
        
        setupTableView()
        
        loadBookFromFirebase()
    }
    
    func setupUI() {
        accountButton.clipsToBounds = true
        accountButton.layer.cornerRadius = accountButton.bounds.width / 2
        
        // lắng nghe notification
        NotificationCenter.default.addObserver(self, selector: #selector(onDeleteBook(notification:)), name: Notification.Name("DeleteBook"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReadAfterBook(notification:)), name: Notification.Name("ReadAfter"), object: nil)

//        NotificationCenter.default.addObserver(self, selector: #selector(onReadBook(notification:)), name: Notification.Name("ReadBook"), object: nil)
        
        if authUser != nil {
            if let name = authUser?.displayName {
                helloLabel.text = "Hi, \(name)"
            }
            accountButton.tintColor = .blue
        } else {
            helloLabel.text = "Xin chào!"
        }
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
            let iBook = Book()
            readingBooks.insert(iBook, at: 0)
            
            homeTableView.reloadData()
        }
    }
    
    func loadBookFromFirebase() {
        readingBooks.removeAll()
        doneBooks.removeAll()
        scheduleBooks.removeAll()
        
        loadReadingBooks(identification)
        loadDoneBooks(identification)
        loadScheduleBooks(identification)
        
        // new user
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.setupNew()
        }
    }
    
    func loadReadingBooks(_ identification: String) {
        
        fsdb.collection("users").document(identification).getDocument {[weak self] (document, error) in
            if let document = document, document.exists {
                // start
                document.reference.collection("books").whereField("status", isEqualTo: "READING").order(by: "updatedAt", descending: true)
                    .getDocuments() {[weak self] (querySnapshot, err) in
                        
                        guard let self = self else { return }
                        
                        if let err = err {
                            print("ERROR1: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                //let docID = document.documentID
                                let docData = document.data()
                                
                                let iBook = convertDocToBook(docData)
                                
                                self.readingBooks.append(iBook)
                            }
                            self.homeTableView.reloadData()
                        }
                }
                // end
            } else {
                print("ERROR1 Document does not exist")
            }
        }
        //end
    }

    
    func loadDoneBooks(_ identification: String) {
        
        fsdb.collection("users").document(identification).getDocument {[weak self] (document, error) in
            if let document = document, document.exists {
                // start
                document.reference.collection("books").whereField("status", isEqualTo: "READ_DONE").order(by: "updatedAt", descending: true)
                    .getDocuments() {[weak self] (querySnapshot, err) in
                        
                        guard let self = self else { return }
                        
                        if let err = err {
                            print("ERROR2: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                //let docID = document.documentID
                                let docData = document.data()
                                
                                let iBook = convertDocToBook(docData)
                                
                                self.doneBooks.append(iBook)
                            }
                            self.homeTableView.reloadData()
                        }
                }
                // end
            } else {
                print("ERROR2 Document does not exist")
            }
        }
        //end
    }
    
    
    func loadScheduleBooks(_ identification: String) {
        
        fsdb.collection("users").document(identification).getDocument {[weak self] (document, error) in
            if let document = document, document.exists {
                // start
                document.reference.collection("books").whereField("status", isEqualTo: "READ_AFTER").order(by: "updatedAt", descending: true)
                    .getDocuments() {[weak self] (querySnapshot, err) in
                        
                        guard let self = self else { return }
                        
                        if let err = err {
                            print("ERROR3: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                //let docID = document.documentID
                                let docData = document.data()
                                
                                let iBook = convertDocToBook(docData)
                                
                                self.scheduleBooks.append(iBook)
                            }
                            
                            self.homeTableView.reloadData()
                        }
                }
                // end
            } else {
                print("ERROR3 Document does not exist")
            }
        }
        //end
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
    


    // MARK: IBAction
    @IBAction func accountButtonAction(_ sender: UIButton) {
        switchToTabAccount()
    }
    
    @objc func onDeleteBook(notification: Foundation.Notification) {

        let iBook: Book = notification.userInfo?["iBook"] as? Book ?? Book()
        
        deleteBook(iBook)
    }
    
    @objc func onReadAfterBook(notification: Foundation.Notification) {
        
        let iBook: Book = notification.userInfo?["iBook"] as? Book ?? Book()
        
        iBook.status = "READ_AFTER"
        saveBookToFirebase(iBook)
        
        reloadTableAfterRemove(iBook)
        
        scheduleBooks.insert(iBook, at: 0)
        
        homeTableView.reloadData()
    }

//    @objc func onReadBook(notification: Foundation.Notification) {
//
//        let iBook: Book = notification.userInfo?["iBook"] as? Book ?? Book()
//
//        routeToReaderNavigation(iBook)
//    }
    
    func deleteBook(_ iBook: Book) {

        AlertHelper.confirmOrCancel(message: "Xoá \(iBook.title)?", viewController: self) {
            
            // start fs
            fsdb.collection("users").document(identification).getDocument {[weak self] (document, error) in
                if let document = document, document.exists {
                    // start
                    document.reference.collection("books").document(iBook.id).delete() {[weak self] err in
                        
                        guard let self = self else { return }
                        
                        if let err = err {
                            print("Error delete: \(err)")
                        } else {
                            self.reloadTableAfterRemove(iBook)
                            self.homeTableView.reloadData()
                            print("DELETE successfully")
                        }
                        
                    }
                    // end
                } else {
                    print("Document does not exist", 4)
                }
            }
            //end fs
        }
    }

    func reloadTableAfterRemove(_ iBook: Book) {
        for (index, item) in readingBooks.enumerated() {
            if item.id == iBook.id {
                readingBooks.remove(at: index)
            }
        }
        for (index, item) in doneBooks.enumerated() {
            if item.id == iBook.id {
                doneBooks.remove(at: index)
            }
        }
        for (index, item) in scheduleBooks.enumerated() {
            if item.id == iBook.id {
                scheduleBooks.remove(at: index)
            }
        }
    }
    
}

// MARK: Extension Table View
extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1 // reading book
        case 1:
            return 1 // done book
        case 2:
            return 1 // schedule book
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let bookCell = homeTableView.dequeueReusableCell(withIdentifier: "BookCollectionTableViewCell", for: indexPath) as! BookCollectionTableViewCell
        
        bookCell.handleBook = {[weak self] iBook in
            guard let self = self else { return }
            
            if iBook.title.isEmpty && iBook.url.isEmpty && iBook.desc.isEmpty && iBook.desc.isEmpty {
                self.switchToTabLibrary()
                return
            }
            
            // go to read book
            self.routeToReaderNavigation(iBook)
        }
        
        switch indexPath.section {
        case 0: // reading book
            
            bookCell.iBooks = readingBooks
            
            return bookCell
            
        case 1: // done book
            
            bookCell.iBooks = doneBooks
            
            return bookCell
            
        case 2: // schedule book
            
            bookCell.iBooks = scheduleBooks
            
            return bookCell
            
        default:
            return bookCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: // new book
            if readingBooks.count > 0 {
                return 300
            }
            return 0
        case 1:// done book
            if doneBooks.count > 0 {
                return 300
            }
            return 0
        case 2:// after book
            if scheduleBooks.count > 0 {
                return 300
            }
            return 0
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var iBook: Book = Book()
        switch indexPath.section {
        case 0: // reading book
            iBook = readingBooks[indexPath.row]
        case 1: // done book
            iBook = doneBooks[indexPath.row]
        case 2: // schedule book
            iBook = scheduleBooks[indexPath.row]
        default:
            print("indexPath", indexPath)
        }
        print("33", iBook.title)
        routeToReaderNavigation(iBook)
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

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: viewHeader.bounds.width, height: viewHeader.bounds.height))
        
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 32)

        switch section {
        case 0: // reading book
            viewHeader.backgroundColor = .white
            label.text = headers[section]
        case 1: // done book
            if doneBooks.count > 0 {
                viewHeader.backgroundColor = .white
                label.text = headers[section]
            }
        case 2: // schedule book
            if scheduleBooks.count > 0 {
                viewHeader.backgroundColor = .white
                label.text = headers[section]
            }
        default:
            viewHeader.backgroundColor = .white
            label.text = headers[section]
        }
        viewHeader.addSubview(label)
        return viewHeader
    }
    
}

// MARK: Route
extension HomeViewController: RouteBook {
    
    func routeToReaderNavigation(_ iBook: Book) {
        let readerVC = ReaderViewController()
        readerVC.iBook = iBook
        let navigation = UINavigationController(rootViewController: readerVC)

        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first

        keyWindow?.rootViewController = navigation
    }
    
}

