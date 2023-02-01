//
//  HttpRequest.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 01/02/2023.
//

import Foundation
import Alamofire
import SwiftSoup
//
//var urlRequest = "https://docsach24.co/?q=tu+duy&type_search=book";
//
//// request
//AF.request(urlRequest).responseString { response in
//    //debugPrint("Response: \(response)")
//
//    guard let html = response.value else { return }
//
//    do {
//        let doc: Document = try SwiftSoup.parse(html)
//
//        let link: Element = try doc.select("img")[5]
//
//        let linkHref: String = try link.attr("data-src")
//
//        //self.imageView.setBookImage(urlImage: linkHref)
//
//        /*
//        let link: Element = try doc.select("a").first()!
//
//        let text: String = try doc.body()!.text() // "An example link."
//
//        let linkHref: String = try link.attr("href") // "http://example.com/"
//
//        let linkText: String = try link.text() // "example"
//
//        let linkOuterH: String = try link.outerHtml() // "<a href="http://example.com/"><b>example</b></a>"
//
//        let linkInnerH: String = try link.html() // "<b>example</b>"
//
//        */
//
//    } catch Exception.Error(let type, let message) {
//        print(type)
//        print(message)
//    } catch {
//        print("error")
//    }
//}
