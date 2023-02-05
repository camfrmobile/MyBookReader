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
    
    // MARK: Variables
    var iBook: Book? {
        didSet {
            if let iBook = iBook {
                titleLabel.text = iBook.title
                descLabel.text = iBook.desc
                imageView.setBookImage(urlImage: iBook.imageUrl)
            }
        }
    }
    
    // MARK: Setup
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

}
