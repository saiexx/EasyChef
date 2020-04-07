//
//  Comment.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 7/4/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import Foundation

class Comment {
    var name: String?
    var commentId: String?
    var imageUrl: URL?
    var createdTime: Double?
    var commentText: String?
    var score: Int?
    var ownerId: String?
    
    init(name: String, commentId: String, imageUrl: String, createdTime: Double, commentText: String, score: Int, ownerId: String) {
        
        self.name = name
        
        self.commentId = commentId
        
        let stringImageUrl = imageUrl
        self.imageUrl = URL(string: stringImageUrl)
        
        self.createdTime = createdTime
        
        self.commentText = commentText
        
        self.score = score
        
        self.ownerId = ownerId
    }
}
