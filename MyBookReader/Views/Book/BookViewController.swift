//
//  BookViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 05/02/2023.
//

import UIKit
import Cosmos
import Alamofire
import SwiftSoup

class BookViewController: UIViewController {
    
    // MARK: IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var starCosmosView: CosmosView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet weak var afterReadButton: UIButton!
    @IBOutlet weak var nowReadButton: UIButton!
    
    // MARK: Variables
    var bookItem: BookItem = BookItem(title: "", url: "", desc: "", imageUrl: "", rating: 0)
    
    var readBook: Book = Book()
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        SetupUI()
        LoadAllInfoBook()
    }

    func SetupUI() {
        afterReadButton.layer.cornerRadius = 20
        afterReadButton.layer.borderWidth = 1
        afterReadButton.layer.borderColor = UIColor.black.cgColor
        
        nowReadButton.layer.cornerRadius = 20
        nowReadButton.layer.borderWidth = 1
        nowReadButton.layer.borderColor = UIColor.black.cgColor
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(onTapBack))
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "imageName"), for: .normal)
        button.addTarget(self, action: #selector(onTapBack), for: .touchUpInside)
        let leftButtonBar = UIBarButtonItem(customView: button)
        tabBarController?.navigationItem.rightBarButtonItems = [leftButtonBar]
        
        titleLabel.text = bookItem.title
        infoLabel.text = bookItem.desc
        descLabel.text = ""
        
        starCosmosView.rating = bookItem.rating
        starLabel.text = "\(bookItem.rating) / 5.0"
        imageView.setBookImage(urlImage: bookItem.imageUrl)
    }
    
    func LoadAllInfoBook() {
        
        AF.request(bookItem.url).responseString {[weak self] response in
            //debugPrint("Response: \(response)")
            
            guard let self = self else { return }
        
            guard let html = response.value else { return }
        
            do {
                let doc: Document = try SwiftSoup.parse(html)
                
                // get full info book
                // title
                self.readBook.title = try doc.select("div.introduce h1").text()
                // image
                self.readBook.imageUrl = try doc.select("div.introduce div.book img").attr("src")

                // author
                self.readBook.author.name = try doc.select("div.introduce div.author a").text()
                self.readBook.author.url = try doc.select("div.introduce div.author a").attr("href")
                // cat
                self.readBook.category.name = try doc.select("div.introduce div.cat a").text()
                self.readBook.category.url = try doc.select("div.introduce div.cat a").attr("href")
                // total-chapter
                let totalChaper = try doc.select("div.introduce div.total-chapter").text().replacingOccurrences(of: "Số chương:", with: "")
                self.readBook.totalChapter = Int(totalChaper) ?? 0
                
                let view = try doc.select("div.introduce div.view").text().replacingOccurrences(of: "Lượt xem:", with: "")
                self.readBook.view = Int(view) ?? 0
                
                self.readBook.desc = try doc.select("div.description").text()
                
                // muc luc
                let listChapter: Elements = try doc.select("#viewchapter ul.list li a")
                
                for item in listChapter {
                    
                    let chapName = try item.select("div.introduce div.author a").text()
                    let chapUrl = try item.select("div.introduce div.author a").attr("href")
                    
                    let chapter: Chapter = Chapter(name: chapName, url: chapUrl)
                    
                    self.readBook.listChapter.append(chapter)
                }
                // muc luc page 2
                
                // refill data
                self.reFillDataBook()
                
            } catch Exception.Error(let type, let message) {
                print(type)
                print(message)
            } catch {
                print("error")
            }
        }
        //end
    }
    
    func reFillDataBook() {
        infoLabel.text = readBook.author.name
        descLabel.text = readBook.desc
    }
    
    // MARK: IBAction
    @objc func onTapBack() {
        routeToMain()
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func actionAfterRead(_ sender: UIButton) {
    }
    
    @IBAction func actionNowRead(_ sender: UIButton) {
        
        
        routeToReaderNavigation(readBook)
        
        
        
        
    }
    
}

extension BookViewController: RouteApp {
    func routeToMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homePageVC = storyboard.instantiateViewController(withIdentifier: "MainTabbarController")
        
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        keyWindow?.rootViewController = homePageVC
        //keyWindow?.makeKeyAndVisible()
    }
    
    func routeToReaderNavigation(_ readBook: Book) {
        let readerVC = ReaderViewController()
        readerVC.readBook = readBook
        let navigation = UINavigationController(rootViewController: readerVC)

        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first

        keyWindow?.rootViewController = navigation
    }
}
