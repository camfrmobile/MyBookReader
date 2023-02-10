//
//  ReLoginViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 10/02/2023.
//

import UIKit

class ReLoginViewController: UIViewController {
    
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var handleLogin: ((_ password: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.cornerRadius = 20
        passTextField.becomeFirstResponder()
    }

    
    @IBAction func actionLogin(_ sender: Any) {
        
        let password = passTextField.text ?? ""

        if password.count < 6 {
            AlertHelper.sorry(message: "Mật khẩu ít nhất 6 ký tự", viewController: self)
            passTextField.becomeFirstResponder()
            return
        }
        
        handleLogin?(password)
        
        dismiss(animated: true)
    }
}
