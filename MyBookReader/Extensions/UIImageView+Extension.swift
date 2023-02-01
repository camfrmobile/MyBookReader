import Foundation
import UIKit
import Kingfisher

extension UIImageView {
    func setImage(urlString: String){
        var string = ""
        if urlString.starts(with: "http") {
            string = urlString
        }else{
            string = ApiNameManager.shared.domain + urlString
        }
        
        let url = URL(string: string)
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url)
    }
    func setBookImage(urlImage: String) {
        var array = urlImage.components(separatedBy: "/")
        array[5] = array[5].addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? array[5]
        let escapedLink = array.joined(separator: "/")
        
        let url = URL(string: escapedLink)
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url)
    }
}
