//
//  ReaderViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 05/02/2023.
//

import UIKit

class ReaderViewController: UIViewController {
    
    // MARK: IBOutlet

    
    // MARK: Variables
    
    var readBook: Book = Book()
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(onTapBack))
        
    }

    
    
    
    // MARK: IBAction
    @objc func onTapBack() {
        routeToMain()
    }
    
}

extension ReaderViewController: RouteApp {
    
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
}
