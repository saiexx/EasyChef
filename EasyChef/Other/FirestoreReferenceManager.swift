//
//  FirestoreReferenceManager.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 27/1/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import Firebase

struct FirestoreReferenceManager {
    static let db = Firestore.firestore()
    static let usersDB = db.collection("Users")
    static let menusDB = db.collection("Menus")
}
