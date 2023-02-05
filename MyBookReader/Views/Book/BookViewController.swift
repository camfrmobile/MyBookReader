//
//  BookViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 05/02/2023.
//

import UIKit
import Cosmos

class BookViewController: UIViewController {
    
    // MARK: IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var starCosmosView: CosmosView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet weak var afterReadButton: UIButton!
    @IBOutlet weak var nowReadButton: UIButton!
    
    // MARK: Variables
    var bookItem: BookItem = BookItem(title: "", url: "", desc: "", imageUrl: "")
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        SetupUI()
        LoadAllInfoBook()
    }

    func SetupUI() {
        afterReadButton.layer.cornerRadius = 20
        afterReadButton.layer.borderWidth = 1
        afterReadButton.layer.borderColor = UIColor.black.cgColor
        
        nowReadButton.layer.cornerRadius = 20
        nowReadButton.layer.borderWidth = 1
        nowReadButton.layer.borderColor = UIColor.black.cgColor
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(onTapBack))
        
        titleLabel.text = bookItem.title
        descLabel.text = "Adam Khoo là tác giả luôn được biết đến với các tác phẩm nổi tiếng như Tôi Tài Giỏi, Bạn Cũng Thế, Bí Quyết Tay Trắng Thành Triệu Phú, Chiến Thắng Trò Chơi Cuộc Sống…Và một cuốn sách không thể không kể đến trong đó là cuốn “Làm Chủ Tư Duy, Thay Đổi Vận Mệnh”. Với nhiều độc giả, Adam Khoo đã là một tác giả không quá xa lạ.\nÔng là một doanh nhân thành đạt, là một triệu phú trẻ tuổi nhất ở Singapore. Hiện tại, ông đang làm chủ tịch, chuyên gia đào tạo của tập đoàn giáo dục Adam Khoo Learning Technologies. Nhiều tác phẩm của ông viết đã trở thành cuốn sách best- seller nổi tiếng trên khắp thế giới.\nLàm Chủ Tư Duy, Thay Đổi Vận Mệnh” là những bài học được đúc kết, những tư duy gợi mở cùng những điều khiến chúng ta giật mình vì đến giờ mới nhận ra chân lý như vậy.\nHầu hết những dẫn chứng trong sách của tác giả là của những con người thành công tiêu biểu trên thế giới. Nhưng bên cạnh đó, cuốn sách còn có cả những kĩ năng, hiểu biết của chính tác giả, một con người cũng vô cùng thành công. Cảm hứng trong cuốn sách truyền tải cho người đọc rất rõ ràng và có khả năng khiến con người ta thay đổi để phát triển bản thân ngày càng mạnh mẽ.\nKhi đọc hết cuốn sách, với mỗi tư tưởng của tác giả, ta đã có thể thấm nhuần và khám phá được nhiều điều mới lạ, bổ ích hơn nữa từ con người tác giả. Sau cùng, hành động thực tế sẽ giúp bạn chạm tới và nắm giữ thành công đúng cách."
        var rating = Double.random(in: 3...5)
        rating = Double(String(format: "%.1f", rating)) ?? 3
        
        starCosmosView.rating = rating
        starLabel.text = "\(rating) / 5.0"
        imageView.setBookImage(urlImage: bookItem.imageUrl)
    }
    
    func LoadAllInfoBook() {
        
    }
    
    // MARK: IBAction
    @objc func onTapBack() {
        routeToMain()
    }
    
    @IBAction func actionAfterRead(_ sender: UIButton) {
    }
    
    @IBAction func actionNowRead(_ sender: UIButton) {
    }
    
}

extension BookViewController: RouteApp {
    func routeToMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homePageVC = storyboard.instantiateViewController(withIdentifier: "MainTabbarController")
        
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        keyWindow?.rootViewController = homePageVC
        //keyWindow?.makeKeyAndVisible()
    }
}
