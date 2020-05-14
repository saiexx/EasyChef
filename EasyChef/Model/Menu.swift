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
    var foodId: String?
    var ownerName: String?
    var ownerId: String?
    var imageUrl: URL?
    var estimatedTime: Int?
    var averageRating: Double?
    var sumRating: Int?
    var numberOfUserRated: Int?
    var served: String?
    var ingredients: [String:[String:String]] = [:]
    var method: [String:String] = [:]
    var createdTime: Double?
    var tag: String?
    
    init(forList name:String, id:String, ownerName:String, imageUrl:String, estimatedTime:Int, rating:[String:Int], served:String, createdTime:Double) {
        self.name = name
        self.foodId = id
        self.ownerName = ownerName
        self.estimatedTime = estimatedTime
        self.served = served
        self.createdTime = createdTime
        
        let stringImageUrl = imageUrl
        
        self.imageUrl = URL(string: stringImageUrl)
        
        let rating = rating
        
        self.sumRating = rating["sumRating"]!
        
        self.numberOfUserRated = rating["amount"]!
        if self.numberOfUserRated == 0 {
            self.averageRating = 0
        } else {
            self.averageRating = Double(self.sumRating!) / Double(self.numberOfUserRated!)
        }
    }
    
    init(forView name:String, id:String, ownerName:String, imageUrl:String, estimatedTime:Int, rating:[String:Int], served:String, createdTime:Double, ingredients:[String:[String:String]], method:[String:String], ownerId:String) {
        self.name = name
        self.foodId = id
        self.ownerName = ownerName
        self.estimatedTime = estimatedTime
        self.served = served
        self.createdTime = createdTime
        self.ingredients = ingredients
        self.method = method
        self.ownerId = ownerId
        
        let stringImageUrl = imageUrl
        
        self.imageUrl = URL(string: stringImageUrl)
        
        let rating = rating
        
        self.sumRating = rating["sumRating"]!
        
        self.numberOfUserRated = rating["amount"]!
        if self.numberOfUserRated == 0 {
            self.averageRating = 0
        } else {
            self.averageRating = Double(self.sumRating!) / Double(self.numberOfUserRated!)
        }
    }
    
    init(forSearch name:String, id:String, ownerName:String, imageUrl:String, estimatedTime:Int, rating:[String:Int], served:String, createdTime:Double, tag:String) {
        self.name = name
        self.foodId = id
        self.ownerName = ownerName
        self.estimatedTime = estimatedTime
        self.served = served
        self.createdTime = createdTime
        
        let stringImageUrl = imageUrl
        
        self.imageUrl = URL(string: stringImageUrl)
        
        let rating = rating
        
        self.sumRating = rating["sumRating"]!
        
        self.numberOfUserRated = rating["amount"]!
        if self.numberOfUserRated == 0 {
            self.averageRating = 0
        } else {
            self.averageRating = Double(self.sumRating!) / Double(self.numberOfUserRated!)
        }
        self.tag = tag
    }
}
