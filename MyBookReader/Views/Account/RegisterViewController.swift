//
//  RegisterViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 07/02/2023.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    // MARK: IBOutlet
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    // MARK: Variables

    
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        let suffixName: UIImage = UIImage(systemName: "person") ?? UIImage()
        nameTextField.addPaddingRightIcon(suffixName, padding: 40)
        
            let suffixEmail: UIImage = UIImage(systemName: "envelope") ?? UIImage()
            emailTextField.addPaddingRightIcon(suffixEmail, padding: 40)
            
        let suffixPass: UIImage = UIImage(systemName: "eye.slash") ?? UIImage()
        passTextField.addPaddingRightIcon(suffixPass, padding: 40)
        
        registerButton.layer.cornerRadius = 20
        nameTextField.delegate = self
        emailTextField.delegate = self
        passTextField.delegate = self
        nameTextField.becomeFirstResponder()
    }
    
    func changeUserInfo(name: String) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges { error in
          // Xử lý lỗi.
            guard let error = error else {
                return
            }
            print("ERROR", error.localizedDescription)
        }
    }
    
    func sendEmailVerify() {
        Auth.auth().currentUser?.sendEmailVerification(completion: { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Email verify send")
        })
    }

    @IBAction func actionRegister(_ sender: UIButton) {
        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passTextField.text ?? ""
        
        if email.isEmpty || password.count < 6 {
            return
        }
        
        registerButton.isEnabled = false
        registerButton.setTitle("Đang đăng nhập...", for: .normal)
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            
            guard let self = self else { return }
            
            self.registerButton.isEnabled = true
            self.registerButton.setTitle("Đăng Ký", for: .normal)
            
            guard error == nil else {
                
                let alert = UIAlertController(title: "Có lỗi rồi", message: error?.localizedDescription, preferredStyle: .alert)
                let actionOK = UIAlertAction(title: "OK", style: .default)
                alert.addAction(actionOK)
                
                self.present(alert, animated: true)
                
                return
            }
            self.sendEmailVerify()
            
            setUserID()
            
            self.changeUserInfo(name: name)
            
            AlertHelper.sorry(message: "Kiểm tra hộp thư của bạn và xác thực email", viewController: self)
            
            self.routeToMain()
        }
    }
    
}

// MARK: Extension Textfield
extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            nameTextField.endEditing(true)
            emailTextField.becomeFirstResponder()
        }
        if textField == emailTextField {
            emailTextField.endEditing(true)
            passTextField.becomeFirstResponder()
        }
        if textField == passTextField {
            passTextField.endEditing(true)
        }
        //view.endEditing(true) // dùng khi k xác định được đối tưong đang được nhập
        return true
    }
}

// MARK: route
extension RegisterViewController: RouteBook {
    
    func routeToMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homePageVC = storyboard.instantiateViewController(withIdentifier: "MainTabbarController")
        
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        keyWindow?.rootViewController = homePageVC
        keyWindow?.makeKeyAndVisible()
    }
}
