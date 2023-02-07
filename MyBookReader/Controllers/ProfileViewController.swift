//
//  AccountViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 01/02/2023.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    // MARK: IBOutlet
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var photoChoseButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: Variables
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupStart()
    }
    
    func setupUI() {
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        
        if authUser != nil {
            if let name = authUser?.displayName {
                nameLabel.text = name
            }
        }
    }
    
    func setupStart() {
        if authUser == nil {
            
        }
        
        
    }

    // MARK: IBAction
    @IBAction func myAccountAction(_ sender: Any) {
        // check login
        if authUser == nil {
            AlertHelper.confirmOrCancel(message: "Bạn chưa đăng nhập.\nVui lòng đăng nhập hoặc tạo tài khoản.", viewController: self) {
                self.routeToLoginNavigation()
            }
        } else {
            routeToAccountNavigation()
        }
    }
    
    @IBAction func actionChosePhoto(_ sender: UIButton) {
        // check login
        if authUser == nil {
            AlertHelper.confirmOrCancel(message: "Bạn chưa đăng nhập.\nVui lòng đăng nhập hoặc tạo tài khoản.", viewController: self) {
                self.routeToLoginNavigation()
            }
            return
        }
        // chon hinh anh
    }
    
    @IBAction func appInfoAction(_ sender: UIButton) {
        AlertHelper.sorry(message: "Ứng dụng tổng hợp và sửa lỗi chính tả các tác phẩm sách, truyện hiện có trên mạng Internet. Chúng tôi không sở hữu hay chịu trách nhiệm bất kỳ thông tin nào trên web này. Nếu làm ảnh hưởng đến cá nhân hay tổ chức nào, khi được yêu cầu, chúng tôi sẽ xem xét và gỡ bỏ ngay lập tức.\n\nBản quyền sách, truyện thuộc về Tác giả & Nhà xuất bản. Ứng dụng khuyến khích các bạn nếu có khả năng hãy mua sách, truyện để ủng hộ Tác giả và Nhà xuất bản.\n\nNhà phát triển: Trần Văn Cam", viewController: self)
    }
    
    @IBAction func logOutAction(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
//            GIDSignIn.sharedInstance().signOut()
//            GIDSignIn.sharedInstance().disconnect()
            setDeviceID()
            print(identification)

            routeToLoginNavigation()
        } catch let error {
            AlertHelper.sorry(message: "Có lỗi đăng xuất: \(error.localizedDescription)", viewController: self)
        }
    }
    
}

// MARK: Extension




// MARK: Route
extension ProfileViewController: RouteBook {
    
    func routeToLoginNavigation() {
        let viewController = LoginViewController()

        let navigation = UINavigationController(rootViewController: viewController)

        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first

        keyWindow?.rootViewController = navigation
        keyWindow?.makeKeyAndVisible()
    }
    
    func routeToAccountNavigation() {
        let viewController = AccountViewController()
        
        let navigation = UINavigationController(rootViewController: viewController)

        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first

        keyWindow?.rootViewController = navigation
        keyWindow?.makeKeyAndVisible()
    }
    
}

