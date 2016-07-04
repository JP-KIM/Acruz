//
//  ChatTableCell.swift
//  Acruz
//
//  Created by 김정표 on 2016. 6. 28..
//  Copyright © 2016년 Acruz corp. All rights reserved.
//

import UIKit


protocol OnCellButtonClickListener : class {
    
    func onCellButtonClick(chatItem: ChatList, itemIndex: Int)
}


class ChatListTableCell : UITableViewCell {
    
    
    var listener : OnCellButtonClickListener!
    
    
    @IBAction func onCellButtonClick(sender: AnyObject) {
        if let eventListener = listener {
            eventListener.onCellButtonClick(self.dataItem, itemIndex: self.itemIndex)
        }
        
    }
    
    var dataItem : ChatList!
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
        
        /*if let item = self.dataItem {
            print("\(item.nickname) --> \(selected)")
        }*/
    }
    
    func setData(chatItem :ChatList, index: Int) {
        self.dataItem = chatItem
        self.itemIndex = index
        
        //self.chatThumbnail?.image = UIImage(named: chatItem.thumbnail)!
        self.lblNickname?.text = chatItem.nickname
        self.lblLastcomment?.text = chatItem.lastcomment
        self.lblTime?.text = chatItem.time
        self.chatThumbnail.image = UIImage(named: "ic_star-128")
    }
    
}