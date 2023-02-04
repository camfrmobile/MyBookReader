//
//  ApiManager+RegisterAPI.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 04/02/2023.
//

import Foundation
import Alamofire
import SwiftyJSON
//
//extension ApiManager {
//    
//    func register(name: String, phone: String, password: String, success: @escaping () -> Void, failure: @escaping (String) -> Void) {
//        let params = [
//            "name": name,
//            "phone": phone,
//            "password": password
//        ]
//        
//        Alamofire.request(ApiNameManager.shared.returnUrl(ApiNameManager.shared.register), method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
//            switch response.result{
//            case .success(let value):
//                let json = JSON(value)
//                let code = json["code"].intValue
//                
//                if code == 0{
//                    if let data = json["data"].dictionary, let token = data["token"]?.stringValue{
//                        let userDefault = UserDefaults.standard
//                        userDefault.set(token, forKey: "token")
//                        success()
//                    }
//                }else{
//                    let message = json["message"].stringValue
//                    failure(message)
//                }
//            case .failure(let error):
//                failure(error.localizedDescription)
//            }
//        }
//    }
//}
