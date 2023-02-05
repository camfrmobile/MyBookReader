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
    
    func routeToBookNavigation(_ bookItem: BookItem)
}

extension RouteApp {
    func routeToMain() {
        
    }
    
    func routeToBookNavigation(_ bookItem: BookItem) {
        
    }
}
