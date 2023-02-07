//
//  RouteBook.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 06/02/2023.
//

import Foundation
import UIKit

protocol RouteBook {
    
    func routeToMain()
    
    func routeToBookInfo(_ iBook: Book)
    
    func routeToBookNavigation(_ iBook: Book)
    
    func routeToReaderNavigation(_ iBook: Book)
    
    func routeToLoginNavigation()
    
    func routeToAccountNavigation()
}

extension RouteBook {
    func routeToMain() {
        
    }
    
    func routeToBookInfo(_ iBook: Book) {
        
    }
    
    func routeToBookNavigation(_ iBook: Book) {
        
    }
    
    func routeToReaderNavigation(_ iBook: Book) {
        
    }
    
    func routeToLoginNavigation() {
        
    }
    
    func routeToAccountNavigation() {
        
    }
}
