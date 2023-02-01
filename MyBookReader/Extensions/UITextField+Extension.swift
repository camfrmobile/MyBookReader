import Foundation
import UIKit

extension UITextField {
    
    func underlined(_ color: UIColor){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1.0)
        bottomLine.backgroundColor = color.cgColor
        self.borderStyle = UITextField.BorderStyle.none
        self.layer.addSublayer(bottomLine)
    }
    
    func underView() {
        let bottomView = UIView()
        bottomView.frame = CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 1.5)
        bottomView.backgroundColor = UIColor.mainBrown()
        self.addSubview(bottomView)
    }
    func borderLine(){
        self.layer.cornerRadius = 5
        self.borderStyle = .none
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func viewMode(){
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        self.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        self.leftViewMode = UITextField.ViewMode.always
        self.rightViewMode = UITextField.ViewMode.always
    }
    
    func addPaddingLeftIcon(_ image: UIImage, padding: CGFloat) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: padding))
        let imageView = UIImageView(image: image)
        imageView.tintColor = #colorLiteral(red: 0.5098040104, green: 0.5098040104, blue: 0.5098040104, alpha: 1)
        view.addSubview(imageView)
        imageView.center.x = view.center.x
        imageView.center.y = view.center.y
        self.leftView = view
        self.leftViewMode = .always
    }
    
    func addPaddingRightIcon(_ image: UIImage, padding: CGFloat) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: padding))
        let imageView = UIImageView(image: image)
        imageView.tintColor = #colorLiteral(red: 0.5098040104, green: 0.5098040104, blue: 0.5098040104, alpha: 1)
        view.addSubview(imageView)
        imageView.center.x = view.center.x
        imageView.center.y = view.center.y
        self.rightView = view
        self.rightViewMode = .always
    }
}
