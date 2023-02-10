//
//  AccountViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 01/02/2023.
//

import UIKit
import Photos
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    // MARK: IBOutlet
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var photoChoseButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: Variables
    let libraryPicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.modalPresentationStyle = .popover
        return picker
    } ()
    
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupStart()
    }
    
    func setupUI() {
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        
        libraryPicker.delegate = self
    }
    
    func setupStart() {
        if Auth.auth().currentUser != nil {
            if let name = Auth.auth().currentUser?.displayName {
                nameLabel.text = name
            }
        }
        loadPhotoFromFirebase(avatarImageView)
    }
    
    func imageFromLibrary() {
        func choosePhoto() {
            DispatchQueue.main.async {[weak self] in
                guard let `self` = self else {
                    return
                }
                self.present(self.libraryPicker, animated: true)
            }
        }
        PHPhotoLibrary.requestAuthorization(for: .readWrite) {[weak self] status in
            guard let `self` = self else {
                return
            }
             
            print(status.rawValue)
            if status == PHAuthorizationStatus.authorized {
                choosePhoto()
            } else if status == PHAuthorizationStatus.limited {
                choosePhoto()
            } else {
                print("App không có quyền truy cập thư viện ảnh.")
                
                DispatchQueue.main.async {
                    self.setting()
                }
            }
        }
    }
    // mở setting của điện thoại
    func setting() {
        let message = "App cần quyền truy cập camera và thư viện ảnh"
        AlertHelper.confirmOrCancel(message: message, viewController: self) {
            guard let settingUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingUrl) {
                UIApplication.shared.open(settingUrl)
            }
        }
    }
    
    // MARK: IBAction
    @IBAction func myAccountAction(_ sender: Any) {
        // check login
//        if Auth.auth().currentUser == nil {
//            AlertHelper.confirmOrCancel(message: "Bạn chưa đăng nhập.\nVui lòng đăng nhập hoặc tạo tài khoản.", viewController: self) {
//                self.routeToLoginNavigation()
//            }
//        } else {
//        }
        routeToAccountNavigation()
    }
    
    @IBAction func actionChosePhoto(_ sender: UIButton) {
        // check internet
        if !isConnectedToNetwork() {
            AlertHelper.sorry(message: "Không có Internet", viewController: self)
            return
        }
        
        imageFromLibrary() // chon hinh anh
    }
    
    @IBAction func appInfoAction(_ sender: UIButton) {
        AlertHelper.sorry(message: "Ứng dụng tổng hợp và sửa lỗi chính tả các tác phẩm sách, truyện hiện có trên mạng Internet. Chúng tôi không sở hữu hay chịu trách nhiệm bất kỳ thông tin nào trên web này. Nếu làm ảnh hưởng đến cá nhân hay tổ chức nào, khi được yêu cầu, chúng tôi sẽ xem xét và gỡ bỏ ngay lập tức.\n\nBản quyền sách, truyện thuộc về Tác giả & Nhà xuất bản. Ứng dụng khuyến khích các bạn nếu có khả năng hãy mua sách, truyện để ủng hộ Tác giả và Nhà xuất bản.\n\nNhà phát triển: TVCam", viewController: self)
    }
    
    @IBAction func logOutAction(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
//            GIDSignIn.sharedInstance().signOut()
//            GIDSignIn.sharedInstance().disconnect()

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
        //keyWindow?.makeKeyAndVisible()
    }
    
}


extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // xu ly sau khi chup anh
        if let selectedImage = info[.originalImage] as? UIImage {
            
            saveImageToFirebase(selectedImage)
        }
        dismiss(animated: true)
    }
    
    func saveImageToFirebase(_ image: UIImage) {

        guard let imageData = image.pngData() else { return }
        
        avatarImageView.image = UIImage(systemName: "icloud.and.arrow.up")

        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("images/\(identification).jpg")

        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = riversRef.putData(imageData, metadata: nil) {[weak self] (metadata, error) in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            return
          }
          // Metadata contains file metadata such as size, content-type.
          let size = metadata.size
          // You can also access to download URL after upload.
          riversRef.downloadURL {[weak self] (url, error) in
            guard let downloadURL = url, let self = self else {
              // Uh-oh, an error occurred!
              return
            }
            self.avatarImageView.setImage(urlString: downloadURL.absoluteString)
          }
        }
    }
    
}
