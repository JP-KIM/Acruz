//
//  RoomItem.swift
//  Acruz
//
//  Created by 김정표 on 2016. 7. 5..
//  Copyright © 2016년 Acruz corp. All rights reserved.
//

import Foundation

class RoomItem {
    var myId: String!
    var roomId: String!
    var roomName: String!
    var lastcomment: MessageItem!
    var users: [User]!
    
    init(myId: String, roomId: String) {
        self.myId = myId
        self.roomId = roomId
        self.users = []
    }
    
    class MessageItem {
        var messageId: String!
        var senderId: String!
        var type: String!
        var content: String!
        var read: Bool!
        var timestamp: NSTimeInterval!
        
        init(messageId: String, senderId: String, type: String, content: String, read: Bool, timestamp: NSTimeInterval) {
            self.messageId = messageId
            self.senderId = senderId
            self.type = type
            self.content = content
            self.read = read
            self.timestamp = timestamp
        }
    }
}