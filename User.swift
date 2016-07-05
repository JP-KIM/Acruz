//
//  User.swift
//  Acruz
//
//  Created by 김정표 on 2016. 7. 5..
//  Copyright © 2016년 Acruz corp. All rights reserved.
//

import Foundation

class User {
    var userId: String!
    var userName: String!
    var userProfile: String!
    
    init(userId: String, userName: String, userProfile: String) {
        self.userId = userId
        self.userName = userName
        self.userProfile = userProfile
    }
}