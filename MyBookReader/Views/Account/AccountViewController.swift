//
//  AccountViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 07/02/2023.
//

import UIKit
import FirebaseAuth

class AccountViewController: UIViewController {
    
    // MARK: IBOutlet
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var rePassTextField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    
    // MARK: Variables

    
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupAccount()
    }
    
    func setupUI() {
        let suffixName: UIImage = UIImage(systemName: "person") ?? UIImage()
        nameTextField.addPaddingRightIcon(suffixName, padding: 40)
        
        let suffixEmail: UIImage = UIImage(systemName: "envelope") ?? UIImage()
        emailTextField.addPaddingRightIcon(suffixEmail, padding: 40)
            
        let suffixPass: UIImage = UIImage(systemName: "eye.slash") ?? UIImage()
        passTextField.addPaddingRightIcon(suffixPass, padding: 40)
        rePassTextField.addPaddingRightIcon(suffixPass, padding: 40)
        
        updateButton.layer.cornerRadius = 20
        nameTextField.delegate = self
        emailTextField.delegate = self
        passTextField.delegate = self
        rePassTextField.delegate = self
        passTextField.isSecureTextEntry = true
        rePassTextField.isSecureTextEntry = true
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        // left button
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(onTapBack))
    }
    
    func setupAccount() {
        if Auth.auth().currentUser != nil {
            if let user = Auth.auth().currentUser {
                emailTextField.text = user.email
                nameTextField.text = user.displayName
            }
        }
    }
    
    func changeUserName(name: String) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges { error in
            if let error = error {
                AlertHelper.sorry(message: error.localizedDescription, viewController: self)
                return
            }
            print("EDIT name ok")
        }
    }
    
    func changeUserEmail(email: String) {
        Auth.auth().currentUser?.updateEmail(to: email) { error in
            if let error = error {
                AlertHelper.sorry(message: error.localizedDescription, viewController: self)
                return
            }
            print("EDIT email ok")
        }
    }
    
    func changePass(newPass: String) {
        Auth.auth().currentUser?.updatePassword(to: newPass) { error in
            if let error = error {
                AlertHelper.sorry(message: error.localizedDescription, viewController: self)
                return
            }
            print("EDIT pass ok")
        }
    }

    // MARK: IBAction
    @objc func onTapBack() {
        routeToMain()
    }
    
    @IBAction func actionUpdate(_ sender: UIButton) {
        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passTextField.text ?? ""
        let repass = rePassTextField.text ?? ""
        
        if let user = Auth.auth().currentUser {
            if !email.isEmpty && email != user.email {
                changeUserEmail(email: email)
            }
            if !name.isEmpty && name != user.displayName {
                changeUserName(name: name)
            }
            if password.count >= 6 && password == repass {
                changePass(newPass: password)
            }
        }
    }
    
}

// MARK: Extension Textfield
extension AccountViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true) // dùng khi k xác định được đối tưong đang được nhập
        return true
    }
}


// MARK: route
extension AccountViewController: RouteBook {
    
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
