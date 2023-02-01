//
//  AccountViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 01/02/2023.
//

import UIKit

class AccountViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var photoChoseButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        
    }

    @IBAction func myAccountAction(_ sender: Any) {
    }
    
    @IBAction func appInfoAction(_ sender: UIButton) {
    }
    
    @IBAction func logOutAction(_ sender: UIButton) {
    }
}
