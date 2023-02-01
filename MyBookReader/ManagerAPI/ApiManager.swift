import Foundation
import Alamofire
import SwiftyJSON

class ApiManager {
    
    static let shared = ApiManager()
    
    init() {
    }
    
    func getHeaders() -> [String: String] {
        let token = UserDefaults.standard.string(forKey: "token") ?? ""
        return ["Authorization": token]
    }
    
}
