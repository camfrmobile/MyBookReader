//
//  GlobalFunction.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 08/02/2023.
//

import Foundation


func isValidEmail(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)
}
