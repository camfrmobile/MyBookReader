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
        if urlImage.isEmpty { return }
        
        var array = urlImage.components(separatedBy: "/")
        
        if urlImage.contains(" ") {
            array[5] = array[5].addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? array[5]
            let escapedLink = array.joined(separator: "/")
            
            let url = URL(string: escapedLink)
            self.kf.indicatorType = .activity
            self.kf.setImage(with: url)
        } else {
            let url = URL(string: urlImage)
            self.kf.indicatorType = .activity
            self.kf.setImage(with: url)
        }
        
    }
}
