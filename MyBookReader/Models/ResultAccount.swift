import Foundation
import SwiftyJSON

class ResultAccount {
    var responseTime: String
    var code: Int
    var message: String
    var data: DataObject?

    required public init?(json: JSON){
        responseTime = json["responseTime"].stringValue
        code = json["code"].intValue
        message = json["message"].stringValue
        data = DataObject(json: JSON(json["data"]))
    }
}

// MARK: - DataClass
class DataObject {
    var userType: Int
    var userProfile: Profile?
    var token: String

    required public init?(json: JSON){
        userType = json["userType"].intValue
        userProfile = Profile(json: JSON(json["userProfile"]))
        token = json["token"].stringValue
    }
}

// MARK: - UserProfile
class Profile {
    var id: String
    var name: String
    var phone: String
    var password: String
    var avatar: String
    var address: String
    var role: Int

    required public init?(json: JSON){
        id = json["id"].stringValue
        name = json["name"].stringValue
        phone = json["phone"].stringValue
        password = json["password"].stringValue
        avatar = json["avatar"].stringValue
        address = json["address"].stringValue
        role = json["role"].intValue
    }
}

