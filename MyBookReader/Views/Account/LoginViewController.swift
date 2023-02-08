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
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var loadingView: UIView!
    
    // MARK: Variables
    
    let switchViewPassButton: UIButton = {
        let button = UIButton()
        button.tintColor = .gray
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        return button
    } ()
    
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        //navigationItem.title = "Đăng nhập"
        let suffixEmail: UIImage = UIImage(systemName: "envelope") ?? UIImage()
        emailTextField.addPaddingRightIcon(suffixEmail, padding: 40)
        
        //let suffixPass: UIImage = UIImage(systemName: "eye.slash") ?? UIImage()
        //passTextField.addPaddingRightIcon(suffixPass, padding: 40)

        let switchView: UIView = {
            let uiview = UIView()
            uiview.frame = CGRect(x: 0, y: 0, width: passTextField.bounds.height, height: passTextField.bounds.height)
            uiview.addSubview(switchViewPassButton)
            switchViewPassButton.frame = CGRect(x: 5, y: 2, width: 40, height: 40)
            return uiview
        } ()
        switchViewPassButton.addTarget(self, action: #selector(switchViewPass), for: .touchDown)
        passTextField.rightView = switchView
        passTextField.rightViewMode = .always
        
        loginButton.layer.cornerRadius = 20
        emailTextField.delegate = self
        passTextField.delegate = self
        passTextField.isSecureTextEntry = true
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        // left button
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(onTapBack))
        
        containerView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapView))
        containerView.addGestureRecognizer(tapGesture)
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
    
    @objc func onTapView() {
        view.endEditing(true)
    }
    
    @objc func switchViewPass() {
        passTextField.isSecureTextEntry = !passTextField.isSecureTextEntry
        if passTextField.isSecureTextEntry {
            switchViewPassButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            switchViewPassButton.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
    @IBAction func actionLoginButton(_ sender: UIButton) {
        let email = emailTextField.text ?? ""
        let password = passTextField.text ?? ""
        
        if !isValidEmail(email: email) {
            AlertHelper.sorry(message: "Vui lòng nhập đúng email", viewController: self)
            emailTextField.becomeFirstResponder()
            return
        }
        if password.count < 6 {
            AlertHelper.sorry(message: "Mật khẩu ít nhất 6 ký tự", viewController: self)
            passTextField.becomeFirstResponder()
            return
        }
        
        loadingView.isHidden = false
        loginButton.isEnabled = false
        loginButton.setTitle("Đang đăng nhập...", for: .normal)
        
        Auth.auth().signIn(withEmail: email, password: password) {[weak self] authResult, error in
            
            guard let self = self else { return }
            
            self.loadingView.isHidden = true
            self.loginButton.isEnabled = true
            self.loginButton.setTitle("Đăng Nhập", for: .normal)
            
            guard error == nil else {
                let alert = UIAlertController(title: "Có lỗi đăng nhập", message: error?.localizedDescription, preferredStyle: .alert)
                let actionOK = UIAlertAction(title: "OK", style: .default)
                alert.addAction(actionOK)
                
                self.present(alert, animated: true)
                
                return
            }
            
            self.routeToMain()
        }
    }
    
    @IBAction func actionForgotButton(_ sender: UIButton) {
        
        let email = emailTextField.text ?? ""
        
        let VC = ForgotViewController()
        VC.email = email
        navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func actionRegisterButton(_ sender: UIButton) {
        let VC = RegisterViewController()
        //register.title = "Đăng ký"
        navigationController?.pushViewController(VC, animated: true)
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
