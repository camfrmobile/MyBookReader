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
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    
    // MARK: Variables
    var iBook: Book = Book()
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupStarCosmos()
        setupBook()
        loadAllInfoBook()
    }

    func setupUI() {
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
        
    }
    
    func setupStarCosmos() {
        
        starCosmosView.settings.updateOnTouch = false

        starCosmosView.didFinishTouchingCosmos = {[weak self] rating in
            guard let self = self else { return }
            
            let VC = RatingViewController()
            
            VC.handleRating = {[weak self] rating in
                guard let self = self else { return }
                self.iBook.rating = rating
                self.starCosmosView.rating = rating
                self.starLabel.text = "\(rating) / 5.0"
            }
            
            self.present(VC, animated: true)
        }
        
    }
    
    func setupBook() {
        
        if !iBook.url.isEmpty {
            iBook.id = iBook.url.components(separatedBy: "-").last?.components(separatedBy: ".").first ?? ""
        }

        titleLabel.text = iBook.title
        infoLabel.text = iBook.desc
        descLabel.text = "Đang tải..."
        
        starCosmosView.rating = iBook.rating
        starLabel.text = "\(iBook.rating) / 5.0"
        imageView.setBookImage(urlImage: iBook.imageUrl)
        
    }
    
    func loadAllInfoBook() {
        
        AF.request(iBook.url).responseString {[weak self] response in
            //debugPrint("Response: \(response)")
            
            guard let self = self else { return }
        
            guard let html = response.value else { return }
        
            do {
                let doc: Document = try SwiftSoup.parse(html)
                
                // get full info book
                // title
                self.iBook.title = try doc.select("div.introduce h1").text()
                
                // image
                self.iBook.imageUrl = try doc.select("div.introduce div.book img").attr("src")

                // author
                self.iBook.author.name = try doc.select("div.introduce div.author a").text()
                self.iBook.author.url = try doc.select("div.introduce div.author a").attr("href")
                
                // category
                self.iBook.category.name = try doc.select("div.introduce div.cat a").text()
                self.iBook.category.url = try doc.select("div.introduce div.cat a").attr("href")
                
                // total-chapter
                let totalChaper = try doc.select("div.introduce div.total-chapter").text().replacingOccurrences(of: "Số chương:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                self.iBook.totalChapter = Int(totalChaper) ?? 0
                
                // view
                let view = try doc.select("div.introduce div.view").text().replacingOccurrences(of: "Lượt xem:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                self.iBook.view = Int(view) ?? 0
                
                self.iBook.desc = try doc.select("div.description").text()
                
                // muc luc
                let listChapter: Elements = try doc.select("#viewchapter ul.list li a")
                
                for item in listChapter {
                    
                    let chapName = try item.text()
                    let chapUrl = try item.attr("href")
                    
                    let chapter: Chapter = Chapter(name: chapName, url: chapUrl)
                    
                    self.iBook.listChapter.append(chapter)
                }
                // muc luc page 2
                
                // refill data
                self.reFillDataBook()
                
            } catch Exception.Error(let type, let message) {
                print("ERROR: ", type, message)
            } catch {
                print("error")
            }
        }
        //end
    }
    
    func reFillDataBook() {
        infoLabel.text = iBook.author.name
        descLabel.text = "Thể loại: \(iBook.category.name)\nSố chương: \(iBook.totalChapter)\n\(iBook.desc)\n"
    }
    
    // MARK: IBAction
    @objc func onTapBack() {
        routeToMain()
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func actionAfterRead(_ sender: UIButton) {
        // Gửi thông báo
        NotificationCenter.default.post(name: Notification.Name("ReadAfter"), object: nil, userInfo:["iBook": iBook])
        
        dismiss(animated: true)
    }
    
    @IBAction func actionNowRead(_ sender: UIButton) {

        routeToReaderNavigation(iBook)

    }
    
}

extension BookViewController: RouteBook {
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
