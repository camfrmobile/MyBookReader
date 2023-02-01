import Foundation
import SwiftyJSON

class ListIssue {
    var responseTime: String
    var code: Int
    var message: String
    var data: ResultIssue?
    
    required public init?(json: JSON){
        responseTime = json["responseTime"].stringValue
        code = json["json"].intValue
        message = json["message"].stringValue
        data = ResultIssue(json: json["data"])
    }
}

class ResultIssue {

    let result: [Issue]?
    let resultCount: Int?

    init(json: JSON) {
        result = json["result"].arrayValue.map { Issue(json: $0)! }
        resultCount = json["resultCount"].intValue
    }
    
}

class Issue {
    var id: String = ""
    var title: String = ""
    var content: String = ""
    var address: String = ""
    var time: String = ""
    var date: String = ""
    var status: String = ""
    var media: [String] = []
    
    init(){
    
    }
    required public init?(json: JSON){
        id = json["id"].stringValue
        title = json["title"].stringValue
        content = json["content"].stringValue
        address = json["address"].stringValue
        time = json["time"].stringValue
        date = json["date"].stringValue
        status = json["status"].stringValue
        media = [json["media"].stringValue]
    }
}
