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
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var readingBookCollectionView: UICollectionView!
    @IBOutlet weak var doneBookCollectionView: UICollectionView!
    @IBOutlet weak var scheduleBookCollectionView: UICollectionView!
    
    // MARK: Variables
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupUI()
    }
    
    func setupUI() {
        accountButton.clipsToBounds = true
        accountButton.layer.cornerRadius = accountButton.bounds.width / 2
    }
    
    func setupCollectionView() {
        readingBookCollectionView.delegate = self
        readingBookCollectionView.dataSource = self
        readingBookCollectionView.register(UINib(nibName: "BookCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BookCollectionViewCell")
        
        doneBookCollectionView.delegate = self
        doneBookCollectionView.dataSource = self
        doneBookCollectionView.register(UINib(nibName: "BookCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BookCollectionViewCell")
        
        scheduleBookCollectionView.delegate = self
        scheduleBookCollectionView.dataSource = self
        scheduleBookCollectionView.register(UINib(nibName: "BookCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BookCollectionViewCell")
    }

    // MARK: IBAction
    @IBAction func accountButtonAction(_ sender: UIButton) {
        tabBarController?.selectedIndex = 3
    }
    
}

// MARK: Extension
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberItems = 0
        if collectionView == self.readingBookCollectionView {
            numberItems = 11
        }
        
        if collectionView == self.doneBookCollectionView {
            numberItems = 5
        }
        
        if collectionView == self.scheduleBookCollectionView {
            numberItems = 3
        }
        
        return numberItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.readingBookCollectionView {
            let bookCell = readingBookCollectionView.dequeueReusableCell(withReuseIdentifier: "BookCollectionViewCell", for: indexPath) as! BookCollectionViewCell
            
            let imageUrl = "https://docsach24.co/filemanager/data-images/Truy%E1%BB%87n%20Ng%E1%BA%AFn%20-%20Ng%C3%B4n%20T%C3%ACnh/Tam-sinh-tam-the--thap-ly-dao-hoa.jpg";
            
//            let url = URL(string: imageUrl)
//            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//            bookCell.imageView?.image = UIImage(data: data!)
            
            bookCell.imageView.setBookImage(urlImage: imageUrl)
            
            return bookCell
        }
        
        if collectionView == self.doneBookCollectionView {
            let bookCell = readingBookCollectionView.dequeueReusableCell(withReuseIdentifier: "BookCollectionViewCell", for: indexPath) as! BookCollectionViewCell

            return bookCell
        }
        
        if collectionView == self.scheduleBookCollectionView {
            let bookCell = readingBookCollectionView.dequeueReusableCell(withReuseIdentifier: "BookCollectionViewCell", for: indexPath) as! BookCollectionViewCell

            return bookCell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let heightCell = readingBookCollectionView.bounds.height
        //let widthCell = heightCell * 250 / 355
        return CGSize(width: 180, height: heightCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    
    
}
