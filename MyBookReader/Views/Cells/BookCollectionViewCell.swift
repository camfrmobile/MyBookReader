//
//  BookCollectionViewCell.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 03/02/2023.
//

import UIKit

class BookCollectionViewCell: UICollectionViewCell {

    // MARK: IBOutlet
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: Variables
    var iBook: Book? {
        didSet {
            if let iBook = iBook {
                titleLabel.text = iBook.title
                descLabel.text = iBook.desc
                imageView.setBookImage(urlImage: iBook.imageUrl)
                
                if iBook.status.isEmpty {
                    favoriteButton.isHidden = true
                    deleteButton.isHidden = true
                }
                
                switchFavorite(iBook)
            }
        }
    }
    
    // MARK: Setup
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
    // MARK: IBAction
    @IBAction func actionFavorite(_ sender: UIButton) {
        
        guard let iBook = iBook else { return }
        
        iBook.isFavorite = !iBook.isFavorite
        
        saveBookToDatabase(docId: iBook.id, data: ["isFavorite": iBook.isFavorite])

        switchFavorite(iBook)
    }
    
    @IBAction func actionDelete(_ sender: UIButton) {
        guard let iBook = iBook else { return }
        
        // Gửi thông báo
        NotificationCenter.default.post(name: Notification.Name("DeleteBook"), object: nil, userInfo:["iBook": iBook])
    }
    
    func switchFavorite(_ iBook: Book) {
        
        if iBook.isFavorite {
            favoriteButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
            favoriteButton.tintColor = .systemPink
        } else {
            favoriteButton.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
            favoriteButton.tintColor = .gray
        }
    }
    
}
