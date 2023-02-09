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
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: Variables
    
    let switchViewPassButton: UIButton = {
        let button = UIButton()
        button.tintColor = .gray
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        return button
    } ()
    
    let group = DispatchGroup()
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        loadingView.isHidden = true
        registerButton.layer.cornerRadius = 20
        nameTextField.delegate = self
        emailTextField.delegate = self
        passTextField.delegate = self
        nameTextField.becomeFirstResponder()
        
        let suffixName: UIImage = UIImage(systemName: "person") ?? UIImage()
        nameTextField.addPaddingRightIcon(suffixName, padding: 40)
        
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
        
        // tap view end edit keyboard
        containerView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapView))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    func changeUserInfo(name: String) {
        
        self.group.enter()
        
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges { error in
            
            if let error = error {
                
                print("ERROR", error.localizedDescription)
                return
            }
            
            self.group.leave()
        }
    }
    
    func sendEmailVerify() {
        
        self.group.enter()
        
        Auth.auth().currentUser?.sendEmailVerification(completion: { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.group.leave()
            
            print("Email verify send")
        })
    }
    
    // MARK: IBAction
    
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
    
    @IBAction func actionRegister(_ sender: UIButton) {
        
        // check internet
        if !isConnectedToNetwork() {
            AlertHelper.sorry(message: "Không có Internet", viewController: self)
            return
        }
        
        var name = nameTextField.text ?? ""
        var email = emailTextField.text ?? ""
        let password = passTextField.text ?? ""
        
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        //password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // validate
        if name.count < 3 {
            AlertHelper.sorry(message: "Tên tài khoản ít nhất 3 ký tự", viewController: self)
            nameTextField.becomeFirstResponder()
            return
        }
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
        registerButton.isEnabled = false
        registerButton.setTitle("Đang đăng nhập...", for: .normal)
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            
            guard let self = self else { return }
            
            self.loadingView.isHidden = true
            self.registerButton.isEnabled = true
            self.registerButton.setTitle("Đăng Ký", for: .normal)
            
            guard error == nil else {
                
                let alert = UIAlertController(title: "Lỗi đăng ký", message: error?.localizedDescription, preferredStyle: .alert)
                let actionOK = UIAlertAction(title: "OK", style: .default)
                alert.addAction(actionOK)
                
                self.present(alert, animated: true)
                
                return
            }
            self.sendEmailVerify()
            
            self.changeUserInfo(name: name)
            
            self.group.notify(queue: .main) {
                
                AlertHelper.sorry(message: "Kiểm tra hộp thư của bạn và xác thực email", viewController: self)
                
                self.routeToMain()
            }
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
