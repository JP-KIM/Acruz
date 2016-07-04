//
//  SecondViewController.swift
//  Acruz
//
//  Created by 김정표 on 2016. 6. 4..
//  Copyright © 2016년 Acruz corp. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SecondViewController: UITableViewController, OnCellButtonClickListener {

    @IBOutlet var tableview: UITableView!
    
    var chatList : [ChatList]!
    var selectedChat : ChatList!
    
    var ref: FIRDatabaseReference!
    var myUid: String!
    var myName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ref = FIRDatabase.database().reference()
        myUid = FIRAuth.auth()?.currentUser?.uid
        myName = FIRAuth.auth()?.currentUser?.displayName
        
        tableview.dataSource = self
        tableview.delegate = self
        
        chatList = []
        startLoadingDefaultChats()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startLoadingDefaultChats() {
        print("startLoadingDefaultChats")
        ref.child("chats/\(myUid)").observeEventType(.Value, withBlock: { (snapshot) in
            print("value queryed")
            let enumerator = snapshot.children
            while let myValue: AnyObject = enumerator.nextObject() {
                let senderId = myValue.value.objectForKey("senderId") as! String
                var text = myValue.value.objectForKey("text") as? String
                if text == nil {
                    text = "[PHOTO]"
                }
                
                print("senderId:\(senderId), text:\(text)")
                
                let p = ChatList(uid: senderId, nickname: senderId, lastcomment: text!, time: "yesterday", thumbnail: "0")
                self.chatList.append(p)
                
            }
            self.tableView?.reloadData()
        })
    }
    
    // MARK:: TABLE VIEW
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let item : ChatList = chatList[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CHAT_CELL", forIndexPath: indexPath) as! ChatListTableCell
        cell.setData(item, index: indexPath.row)
        
        cell.listener = self
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item : ChatList = chatList[indexPath.row]
        selectedChat = item
        
        self.performSegueWithIdentifier("ChattingView", sender: self)
    }
    
    func onCellButtonClick(chatItem: ChatList, itemIndex: Int) {
        print("\(itemIndex) 위치의 버튼 눌러짐 >> \(chatItem.nickname)")
    }

    // MARK:: for passing data to ChattingViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ChattingView" {
            
            let navVc = segue.destinationViewController as! UINavigationController // 1
            let chatVc = navVc.viewControllers.first as! ChattingViewController // 2
            
            chatVc.messages = makeNormalConversation()
            //chatVc.messages = makeGroupConversation()
            
            chatVc.senderId = myUid //AvatarIdWoz
            chatVc.senderDisplayName = myName
            
            chatVc.chatItem = selectedChat
        }
    }
}

