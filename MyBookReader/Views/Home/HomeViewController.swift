//
//  HomeViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 01/02/2023.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var readingBookCollectionView: UICollectionView!
    @IBOutlet weak var doneBookCollectionView: UICollectionView!
    @IBOutlet weak var scheduleBookCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        accountButton.clipsToBounds = true
        accountButton.layer.cornerRadius = accountButton.bounds.width / 2
    }

    @IBAction func accountButtonAction(_ sender: UIButton) {
        tabBarController?.selectedIndex = 3
    }
    
}
