//
//  Menu.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 2/2/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import Foundation

class Menu {
    var name: String?
    var ownerName: String?
    var imageUrl: URL?
    var estimatedTime: Int?
    var rating: Double?
    var served: String?
    var ingredients: [Int:[String:String]] = [:]
    var method: [Int:String] = [:]
    
    init(fromDisplayMenuList name:String, ownerName:String, imageUrl:URL, rating:Double, served:String, estimatedTime:Int) {
        self.name = name
        self.ownerName = ownerName
        self.imageUrl = imageUrl
        self.rating = rating
        self.served = served
        self.estimatedTime = estimatedTime
    }
    
    init(displayMenuDescription name:String, ownerName:String, imageUrl:URL, rating:Double, served:String, estimatedTime:Int, ingredients: [Int:[String:String]], method: [Int:String]) {
        self.name = name
        self.ownerName = ownerName
        self.imageUrl = imageUrl
        self.rating = rating
        self.served = served
        self.estimatedTime = estimatedTime
        self.method = method
        self.ingredients = ingredients
    }
}
