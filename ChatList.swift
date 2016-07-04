//
//  ChatList.swift
//  Acruz
//
//  Created by 김정표 on 2016. 6. 29..
//  Copyright © 2016년 Acruz corp. All rights reserved.
//

import Foundation

class ChatList {
    var uid : String!
    var nickname : String!
    var lastcomment : String!
    var time : String!
    var thumbnail : String!
    
    init(uid: String, nickname: String, lastcomment: String, time: String, thumbnail: String) {
        self.uid = uid
        self.nickname = nickname
        self.lastcomment = lastcomment
        self.time = time
        self.thumbnail = thumbnail
    }
}