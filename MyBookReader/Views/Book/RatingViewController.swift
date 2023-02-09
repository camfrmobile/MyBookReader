//
//  RatingViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 09/02/2023.
//

import UIKit
import Cosmos

class RatingViewController: UIViewController {

    // MARK: IBOutlet
    
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingButton: UIButton!
    
    // MARK: Variables
    
    var handleRating: ((_ rating: Double) -> Void)?
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cosmosView.rating = 0
        
        // Show only fully filled stars
        cosmosView.settings.fillMode = .full
        // Other fill modes: .half, .precise

        // Change the size of the stars
        cosmosView.settings.starSize = 36

        // Set the distance between stars
        cosmosView.settings.starMargin = 5
        
        cosmosView.didTouchCosmos = {[weak self] rating in
            guard let self = self else { return }
            
            self.ratingLabel.text = "\(self.cosmosView.rating) / 5"
        }

    }


    // MARK: Action
    @IBAction func actionRating(_ sender: UIButton) {
        
        handleRating?(self.cosmosView.rating)
        
        dismiss(animated: true)
    }
}
