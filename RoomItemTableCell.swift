//
//  RoomItemTableCell.swift
//  Acruz
//
//  Created by 김정표 on 2016. 7. 6..
//  Copyright © 2016년 Acruz corp. All rights reserved.
//

import UIKit

class RoomItemTableCell : UITableViewCell {
    
    var dataItem : RoomItem!
    var itemIndex : Int!
    
    // weak : 일반 변수
    // strong : 이 변수는 하위 클래스가 재정의 할 수 없음.
    @IBOutlet weak var chatThumbnail: UIImageView!
    @IBOutlet weak var lblNickname: UILabel!
    @IBOutlet weak var lblLastcomment: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    // 한 행에 대한 Cell 이 초기화 될 경우 호출된다.
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // 노출되거나,
    // 한 행이 선택된 경우 호출된다
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setData(roomItem :RoomItem, index: Int) {
        self.dataItem = roomItem
        self.itemIndex = index
        
        //self.chatThumbnail?.image = UIImage(named: chatItem.thumbnail)!
        if let userName = roomItem.roomName {
            self.lblNickname?.text = userName
        }
        if let lastcomment = roomItem.lastcomment {
            self.lblLastcomment?.text = lastcomment.content
            self.lblTime?.text = "yesterday"
        }
        self.chatThumbnail.image = UIImage(named: "ic_star-128")
    }
    
}
