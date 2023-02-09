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
    @IBOutlet weak var containerView: UIView!
    
    // MARK: Variables
    let switchViewPassButton1: UIButton = {
        let button = UIButton()
        button.tintColor = .gray
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        return button
    } ()
    let switchViewPassButton2: UIButton = {
        let button = UIButton()
        button.tintColor = .gray
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        return button
    } ()
    
    let activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.style = .large
        return activity
    } ()
    let loadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Đang tải..."
        return label
    } ()
    let loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    } ()
    
    let group = DispatchGroup()
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupLoadingView()
        setupAccount()
        hideLoadingView()
    }
    
    func setupUI() {
        updateButton.layer.cornerRadius = 20
        nameTextField.delegate = self
        emailTextField.delegate = self
        passTextField.delegate = self
        rePassTextField.delegate = self
        passTextField.isSecureTextEntry = true
        rePassTextField.isSecureTextEntry = true
        
        let suffixName: UIImage = UIImage(systemName: "person") ?? UIImage()
        nameTextField.addPaddingRightIcon(suffixName, padding: 40)
        
        let suffixEmail: UIImage = UIImage(systemName: "envelope") ?? UIImage()
        emailTextField.addPaddingRightIcon(suffixEmail, padding: 40)
            
//        let suffixPass: UIImage = UIImage(systemName: "eye.slash") ?? UIImage()
//        passTextField.addPaddingRightIcon(suffixPass, padding: 40)
//        rePassTextField.addPaddingRightIcon(suffixPass, padding: 40)
        switchViewPassButton1.addTarget(self, action: #selector(switchViewPass1), for: .touchDown)
        switchViewPassButton2.addTarget(self, action: #selector(switchViewPass2), for: .touchDown)
        let switchView1: UIView = {
            let uiview = UIView()
            uiview.frame = CGRect(x: 0, y: 0, width: passTextField.bounds.height, height: passTextField.bounds.height)
            uiview.addSubview(switchViewPassButton1)
            switchViewPassButton1.frame = CGRect(x: 5, y: 2, width: 40, height: 40)
            return uiview
        } ()
        let switchView2: UIView = {
            let uiview = UIView()
            uiview.frame = CGRect(x: 0, y: 0, width: passTextField.bounds.height, height: passTextField.bounds.height)
            uiview.addSubview(switchViewPassButton2)
            switchViewPassButton2.frame = CGRect(x: 5, y: 2, width: 40, height: 40)
            return uiview
        } ()
        passTextField.rightView = switchView1
        passTextField.rightViewMode = .always
        rePassTextField.rightView = switchView2
        rePassTextField.rightViewMode = .always
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        // left button
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(onTapBack))
        
        // tap view end edit keyboard
        containerView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapView))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    func setupLoadingView() {
        view.addSubview(loadingView)
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(loadingLabel)
        
        loadingView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor).isActive = true
        
        loadingLabel.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor).isActive = true
        loadingLabel.leadingAnchor.constraint(equalTo: activityIndicator.trailingAnchor, constant: 10).isActive = true
        
        activityIndicator.startAnimating()
    }
    func hideLoadingView() {
        loadingView.removeFromSuperview()
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
        self.group.enter()
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges { error in
            if let error = error {
                AlertHelper.sorry(message: error.localizedDescription, viewController: self)
                return
            }
            self.group.leave()
            print("EDIT name ok")
        }
    }
    
    func changeUserEmail(email: String) {
        self.group.enter()
        Auth.auth().currentUser?.updateEmail(to: email) { error in
            if let error = error {
                AlertHelper.sorry(message: error.localizedDescription, viewController: self)
                return
            }
            self.group.leave()
            print("EDIT email ok")
        }
    }
    
    func changePass(newPass: String) {
        self.group.enter()
        Auth.auth().currentUser?.updatePassword(to: newPass) { error in
            if let error = error {
                AlertHelper.sorry(message: error.localizedDescription, viewController: self)
                return
            }
            self.group.leave()
            print("EDIT pass ok")
        }
    }

    // MARK: IBAction
    @objc func onTapBack() {
        routeToMain()
    }
    
    @objc func onTapView() {
        view.endEditing(true)
    }
    
    @objc func switchViewPass1() {
        passTextField.isSecureTextEntry = !passTextField.isSecureTextEntry
        if passTextField.isSecureTextEntry {
            switchViewPassButton1.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            switchViewPassButton1.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
    @objc func switchViewPass2() {
        rePassTextField.isSecureTextEntry = !rePassTextField.isSecureTextEntry
        if rePassTextField.isSecureTextEntry {
            switchViewPassButton2.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            switchViewPassButton2.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
    @IBAction func actionUpdate(_ sender: UIButton) {
        
        // check internet
        if !isConnectedToNetwork() {
            AlertHelper.sorry(message: "Không có Internet", viewController: self)
            return
        }
        
        var name = nameTextField.text ?? ""
        var email = emailTextField.text ?? ""
        let password = passTextField.text ?? ""
        let repass = rePassTextField.text ?? ""
        
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
        if password != repass {
            AlertHelper.sorry(message: "Mật khẩu không khớp", viewController: self)
            rePassTextField.becomeFirstResponder()
            return
        }
        
        if let user = Auth.auth().currentUser {
            
            setupLoadingView()
            
            if !email.isEmpty && email != user.email {
                changeUserEmail(email: email)
            }
            if !name.isEmpty && name != user.displayName {
                changeUserName(name: name)
            }
            if password.count >= 6 && password == repass {
                changePass(newPass: password)
            }
            
            group.notify(queue: .main) {
                self.hideLoadingView()
                AlertHelper.sorry(message: "", viewController: self)
                print("Cả 3 task đã hoàn thành")
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
