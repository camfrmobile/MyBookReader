import Foundation

class ApiNameManager {
    // singleton
    
    static let shared = ApiNameManager()
    init() {
    }
    
    let domain = "https://docsach24.co/" // Ex: https://abc.com
    
    let home = ""
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
    
    func getUrlHome() -> String{
        return domain + home
    }
}
