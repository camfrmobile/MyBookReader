//
//  RouteApp.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 04/02/2023.
//

import Foundation
import UIKit

protocol RouteApp {
    
    func routeToMain()
    
    func routeToBookInfo(_ bookItem: BookItem)
    
    func routeToBookNavigation(_ bookItem: BookItem)
    
    func routeToReaderNavigation(_ readBook: Book)
}

extension RouteApp {
    func routeToMain() {
        
    }
    
    func routeToBookInfo(_ bookItem: BookItem) {
        
    }
    
    func routeToBookNavigation(_ bookItem: BookItem) {
        
    }
    
    func routeToReaderNavigation(_ readBook: Book) {
        
    }
}
