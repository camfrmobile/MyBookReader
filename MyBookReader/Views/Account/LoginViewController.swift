//
//  LoginViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 07/02/2023.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    // MARK: IBOutlet
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: Variables

    
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        let suffixEmail: UIImage = UIImage(systemName: "envelope") ?? UIImage()
        emailTextField.addPaddingRightIcon(suffixEmail, padding: 40)
        
        let suffixPass: UIImage = UIImage(systemName: "eye.slash") ?? UIImage()
        passTextField.addPaddingRightIcon(suffixPass, padding: 40)
        
        loginButton.layer.cornerRadius = 20
        emailTextField.delegate = self
        passTextField.delegate = self
        passTextField.isSecureTextEntry = true
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        // left button
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(onTapBack))
    }

    func showMessage(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default)
        alert.addAction(actionOK)
        
        self.present(alert, animated: true)
    }
    

    
    // MARK: IBAction
    @objc func onTapBack() {
        routeToMain()
    }
    
    @IBAction func actionLoginButton(_ sender: UIButton) {
        let email = emailTextField.text ?? ""
        let password = passTextField.text ?? ""
        
        if email.isEmpty || password.count < 6 {
            return
        }
        
        loginButton.isEnabled = false
        loginButton.setTitle("Đang đăng nhập...", for: .normal)
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            
            self.loginButton.isEnabled = true
            self.loginButton.setTitle("Đăng Nhập", for: .normal)
            
            guard error == nil else {
                let alert = UIAlertController(title: "Có lỗi đăng nhập", message: error?.localizedDescription, preferredStyle: .alert)
                let actionOK = UIAlertAction(title: "OK", style: .default)
                alert.addAction(actionOK)
                
                self.present(alert, animated: true)
                
                return
            }
            
            setUserID()
            
            self.routeToMain()
        }
    }
    
    @IBAction func actionForgotButton(_ sender: UIButton) {
        
        let email = emailTextField.text ?? ""
        if email.isEmpty || !email.contains("@") {
            showMessage("Quên mật khẩu", "Vui lòng nhập email")
            emailTextField.becomeFirstResponder()
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.showMessage("Quên mật khẩu", error.localizedDescription)
                return
            }
            self.showMessage("Quên mật khẩu", "Kiểm tra email để đặt lại mật khẩu truy cập")
            
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func actionRegisterButton(_ sender: UIButton) {
        let register = RegisterViewController()
        register.title = "Đăng ký"
        navigationController?.pushViewController(register, animated: true)
    }
}

// MARK: Extension Textfield
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
extension LoginViewController: RouteBook {
    
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
