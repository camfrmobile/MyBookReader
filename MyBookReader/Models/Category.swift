//
//  Category.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 09/02/2023.
//

import Foundation

class Category {
    var name: String = ""
    var url: String = ""
    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}

let categories = [
["https://docsach24.co/the-loai/truyen-ngan-ngon-tinh.html", "Truyện Ngắn - Ngôn Tình"],
["https://docsach24.co/the-loai/kiem-hiep-tien-hiep.html", "Kiếm Hiệp - Tiên Hiệp"],
["https://docsach24.co/the-loai/tieu-thuyet-phuong-tay.html", "Tiểu Thuyết Phương Tây"],
["https://docsach24.co/the-loai/trinh-tham-hinh-su.html", "Trinh Thám - Hình Sự"],
["https://docsach24.co/the-loai/tam-ly-ky-nang-song.html", "Tâm Lý - Kỹ Năng Sống"],
["https://docsach24.co/the-loai/huyen-bi-gia-tuong.html", "Huyền bí - Giả Tưởng"],
["https://docsach24.co/the-loai/truyen-ma-truyen-kinh-di.html", "Truyện Ma - Truyện Kinh Dị"],
["https://docsach24.co/the-loai/y-hoc-suc-khoe.html", "Y Học - Sức Khỏe"],
["https://docsach24.co/the-loai/thieu-nhi-tuoi-moi-lon.html", "Thiếu Nhi- Tuổi Mới Lớn"],
["https://docsach24.co/the-loai/tieu-thuyet-trung-quoc.html", "Tiểu Thuyết Trung Quốc"],
["https://docsach24.co/the-loai/tai-lieu-hoc-tap.html", "Tài Liệu Học Tập"],
["https://docsach24.co/the-loai/phieu-luu-mao-hiem.html", "Phiêu Lưu - Mạo Hiểm"],
["https://docsach24.co/the-loai/kinh-te-quan-ly.html", "Kinh Tế - Quản Lý"],
["https://docsach24.co/the-loai/co-tich-than-thoai.html", "Cổ Tích - Thần Thoại"],
["https://docsach24.co/the-loai/lich-su-chinh-tri.html", "Lịch Sử - Chính Trị"],
["https://docsach24.co/the-loai/triet-hoc.html", "Triết Học"],
["https://docsach24.co/the-loai/hoi-ky-tuy-but.html", "Hồi Ký - Tuỳ Bút"],
["https://docsach24.co/the-loai/van-hoc-viet-nam.html", "Văn Học Việt Nam"],
["https://docsach24.co/the-loai/marketing-ban-hang.html", "Marketing - Bán hàng"],
["https://docsach24.co/the-loai/khoa-hoc-ky-thuat.html", "Khoa Học - Kỹ Thuật"],
["https://docsach24.co/the-loai/hoc-ngoai-ngu.html", "Học Ngoại Ngữ"],
["https://docsach24.co/the-loai/thu-vien-phap-luat.html", "Thư Viện Pháp Luật"],
["https://docsach24.co/the-loai/truyen-cuoi-tieu-lam.html", "Truyện Cười - Tiếu Lâm"],
["https://docsach24.co/the-loai/van-hoa-ton-giao.html", "Văn Hóa - Tôn Giáo"],
["https://docsach24.co/the-loai/tu-vi-phong-thuy.html", "Tử Vi - Phong Thủy"],
["https://docsach24.co/the-loai/the-thao-nghe-thuat.html", "Thể Thao - Nghệ Thuật"],
["https://docsach24.co/the-loai/cong-nghe-thong-tin.html", "Công Nghệ Thông Tin"],

["https://docsach24.co/the-loai/hien-dai.html", "Hiện đại"],
["https://docsach24.co/the-loai/sung.html", "Sủng"],
["https://docsach24.co/the-loai/xuyen-khong.html", "Xuyên không"],
["https://docsach24.co/the-loai/co-dai-ngon-tinh.html", "Cổ đại Ngôn tình"],
["https://docsach24.co/the-loai/he-happy-ending.html", "HE - Happy Ending"],
["https://docsach24.co/the-loai/tong-tai.html", "Tổng tài"],
["https://docsach24.co/the-loai/nguoc-tam.html", "Ngược tâm"],
["https://docsach24.co/the-loai/sac.html", "Sắc"],
["https://docsach24.co/the-loai/do-thi-tinh-duyen.html", "Đô thị tình duyên"],
["https://docsach24.co/the-loai/trong-sinh-ngon-tinh.html", "Trọng sinh ngôn tình"],
["https://docsach24.co/the-loai/nu-cuong.html", "Nữ cường"],
["https://docsach24.co/the-loai/cung-dau.html", "Cung đấu"],
["https://docsach24.co/the-loai/hai-huoc.html", "Hài hước"],
["https://docsach24.co/the-loai/di-gioi-ngon-tinh.html", "Dị giới ngôn tình"],
["https://docsach24.co/the-loai/dam-my.html", "Đam Mỹ"],
["https://docsach24.co/the-loai/huyen-huyen.html", "Huyền huyễn"],
["https://docsach24.co/the-loai/thanh-mai-truc-maoan-gia.html", "Thanh mai trúc mã/Oan gia"],
["https://docsach24.co/the-loai/hao-mon-the-gia.html", "Hào môn thế gia"],
["https://docsach24.co/the-loai/di-gioi.html", "Dị giới"],
["https://docsach24.co/the-loai/vong-du.html", "Võng du"],
["https://docsach24.co/the-loai/co-dai.html", "Cổ đại"],
["https://docsach24.co/the-loai/di-nang.html", "Dị năng"],
["https://docsach24.co/the-loai/hac-banghac-dao.html", "Hắc bang/hắc đạo"],
["https://docsach24.co/the-loai/thanh-xuan-vuon-truong.html", "Thanh xuân vườn trường"],
["https://docsach24.co/the-loai/trong-sinh.html", "Trọng sinh"],
["https://docsach24.co/the-loai/bach-hop.html", "Bách hợp"],
["https://docsach24.co/the-loai/tu-tien.html", "Tu tiên"],
["https://docsach24.co/the-loai/thuong-truong.html", "Thương trường"],
["https://docsach24.co/the-loai/quan-nhan.html", "Quân nhân"],
["https://docsach24.co/the-loai/sach-ngoai-van.html", "Sách ngoại văn"],

]

func listCategories() -> [Category]{
    var array: [Category] = []
    for item in categories {
        let cate = Category(name: item[1], url: item[0])
        array.append(cate)
    }
    return array
}
