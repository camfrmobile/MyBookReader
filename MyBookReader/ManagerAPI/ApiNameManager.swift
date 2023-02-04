import Foundation

class ApiNameManager {
    // singleton
    
    static let shared = ApiNameManager()
    init() {
    }
    
    let domain = "https://docsach24.co/" // Ex: https://abc.com
    
    let home = ""
    let searchBook = "?type_search=book&q="
    let login = "login"
    let register = "register"
    let getProfile = "profile"
    let upload = "upload-file"
    let updateProfile = "update-profile"
    let getIssues = "issues?status=-1&keyword="
    let getIssueById = "issues/"
    let createIssue = "create-issue"
    let searchIssue = "issues?"
    
    func returnUrl(_ nameRequest: String) -> String{
        return domain + nameRequest
    }
    
    func getUrlLibrary() -> String{
        return domain + home
    }
    
    func getUrlSearch(_ keyword: String) -> String{
        return domain + searchBook + (keyword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? keyword)
    }
}
