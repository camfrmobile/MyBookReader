//
//  BookTableViewCell.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 03/02/2023.
//

import UIKit
import Cosmos

class BookTableViewCell: UITableViewCell {

    // MARK: IBOutlet
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var starCosmosView: CosmosView!
    
    // MARK: Variables
    var iBook: Book? {
        didSet {
            if let iBook = iBook {
                titleLabel.text = iBook.title
                descLabel.text = iBook.desc
                starCosmosView.rating = iBook.rating
                bookImageView.setBookImage(urlImage: iBook.imageUrl)
                
            }
        }
    }
    
    // MARK: Setup
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        starCosmosView.settings.updateOnTouch = false
    }
    
}
