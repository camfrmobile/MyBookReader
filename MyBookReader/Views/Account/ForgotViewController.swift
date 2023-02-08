//
//  ForgotViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 08/02/2023.
//

import UIKit
import FirebaseAuth

class ForgotViewController: UIViewController {
    
    // MARK: IBOutlet
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var forgotButton: UIButton!
    
    // MARK: Variables
    var email: String = ""
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        forgotButton.layer.cornerRadius = 20
        emailTextField.becomeFirstResponder()
        
        emailTextField.delegate = self
        emailTextField.text = email
        
        // tap view end edit keyboard
        containerView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapView))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    @objc func onTapView() {
        view.endEditing(true)
    }

    
    @IBAction func actionForgot(_ sender: UIButton) {
        
        let email = emailTextField.text ?? ""
        
        if !isValidEmail(email: email) {
            AlertHelper.sorry(message: "Vui lòng nhập đúng email", viewController: self)
            emailTextField.becomeFirstResponder()
            return
        }
        
        loadingView.isHidden = false
        
        Auth.auth().sendPasswordReset(withEmail: email) {[weak self] error in
            
            guard let self = self else { return }
            
            self.loadingView.isHidden  = true
            
            if let error = error {
                AlertHelper.sorry(message: error.localizedDescription, viewController: self)
                return
            }
            
            AlertHelper.sorry(message: "Vui lòng kiểm tra hộp thư để đặt lại mật khẩu truy cập", viewController: self)
            
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

extension ForgotViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
}
