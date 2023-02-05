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
    
    func routeToBookInfo(_ iBook: Book)
    
    func routeToBookNavigation(_ iBook: Book)
    
    func routeToReaderNavigation(_ iBook: Book)
}

extension RouteApp {
    func routeToMain() {
        
    }
    
    func routeToBookInfo(_ iBook: Book) {
        
    }
    
    func routeToBookNavigation(_ iBook: Book) {
        
    }
    
    func routeToReaderNavigation(_ iBook: Book) {
        
    }
}
