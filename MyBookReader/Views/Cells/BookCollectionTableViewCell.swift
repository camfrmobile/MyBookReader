//
//  BookCollectionTableViewCell.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 04/02/2023.
//

import UIKit

class BookCollectionTableViewCell: UITableViewCell {

    // MARK: IBOutlet
    @IBOutlet weak var bookCollectionView: UICollectionView!
    
    // MARK: Variables
    var iBooks: [Book] = [] {
        didSet {
            bookCollectionView.reloadData()
        }
    }
    var handleBook: ((_ iBook: Book) -> Void)?
    
    // MARK: Setup
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        setupCollectionView()
    }
    
    func setupCollectionView() {
        bookCollectionView.delegate = self
        bookCollectionView.dataSource = self
        
        //bookCollectionView.bounces = false
        
        bookCollectionView.register(UINib(nibName: "BookCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BookCollectionViewCell")
    }
    
}

// MARK: Collection View
extension BookCollectionTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let bookCell = bookCollectionView.dequeueReusableCell(withReuseIdentifier: "BookCollectionViewCell", for: indexPath) as! BookCollectionViewCell
        
        bookCell.iBook = iBooks[indexPath.row]
        
        return bookCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let heightCell = bookCollectionView.bounds.height
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
        
        handleBook?(iBooks[indexPath.row])
    }

}
