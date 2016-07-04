//
//  ChattingViewController.swift
//  Acruz
//
//  Created by 김정표 on 2016. 6. 29..
//  Copyright © 2016년 Acruz corp. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import JSQMessagesViewController

class ChattingViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var chatItem: ChatList!
    
    // FOR JSQMESSAGE
    var messages = [JSQMessage]()
    let defaults = NSUserDefaults.standardUserDefaults()
    // let taillessSettingKey = "taillessSetting"
    // defaults.boolForKey(taillessSettingKey)
    // defaults.setBool(sender.on, forKey: taillessSettingKey)
    
    var conversation: Conversation?
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    // FOR Observing messages
    var ref: FIRDatabaseReference!
    //var userId: String!
    var userId = "FAKEID"
    
    
    var acruzApi = AcruzAPI(storageReferenceURL: "gs://project-3539196792486762214.appspot.com")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize firebase database
        ref = FIRDatabase.database().reference()
        
        setupDefaultUI()
        
        observeMessages()
        observeTyping()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupDefaultUI() {
        // Bubbles with tails
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
        
        // This is how you remove Avatars from the messagesView
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        // This is a beta feature that mostly works but to make things more stable I have diabled it.
        collectionView?.collectionViewLayout.springinessEnabled = false
        
        automaticallyScrollsToMostRecentMessage = true
        
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
        
        // MARK:: BUTTON FOR SIMULATE
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.jsq_defaultTypingIndicatorImage(), style: .Plain, target: self, action: #selector(receiveMessagePressed))
        
        // MARK:: BACK SWIPE GESTURE
        let screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self,
                                                                    action: #selector(ChattingViewController.back(_:)))
        screenEdgeRecognizer.edges = .Left
        view.addGestureRecognizer(screenEdgeRecognizer)
    }
    
    func back(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .Ended {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK:: MSG COPY
    func receiveMessagePressed(sender: UIBarButtonItem) {
        /**
         *  Show the typing indicator to be shown
         */
        self.showTypingIndicator = !self.showTypingIndicator
        
        /**
         *  Scroll to actually view the indicator
         */
        self.scrollToBottomAnimated(true)
        
        /**
         *  Copy last sent message, this will be the new "received" message
         */
        var copyMessage = self.messages.last?.copy()
        
        if (copyMessage == nil) {
            copyMessage = JSQMessage(senderId: AvatarIdJobs, displayName: DisplayNameJobs, text: "First received!")
        }
        
        var newMessage:JSQMessage!
        var newMediaData:JSQMessageMediaData!
        var newMediaAttachmentCopy:AnyObject?
        
        if copyMessage!.isMediaMessage() {
            /**
             *  Last message was a media message
             */
            let copyMediaData = copyMessage!.media
            
            switch copyMediaData {
            case is JSQPhotoMediaItem:
                let photoItemCopy = (copyMediaData as! JSQPhotoMediaItem).copy() as! JSQPhotoMediaItem
                photoItemCopy.appliesMediaViewMaskAsOutgoing = false
                
                newMediaAttachmentCopy = UIImage(CGImage: photoItemCopy.image!.CGImage!)
                
                /**
                 *  Set image to nil to simulate "downloading" the image
                 *  and show the placeholder view5017
                 */
                photoItemCopy.image = nil;
                
                newMediaData = photoItemCopy
            case is JSQLocationMediaItem:
                let locationItemCopy = (copyMediaData as! JSQLocationMediaItem).copy() as! JSQLocationMediaItem
                locationItemCopy.appliesMediaViewMaskAsOutgoing = false
                newMediaAttachmentCopy = locationItemCopy.location!.copy()
                
                /**
                 *  Set location to nil to simulate "downloading" the location data
                 */
                locationItemCopy.location = nil;
                
                newMediaData = locationItemCopy;
            default:
                assertionFailure("Error: This Media type was not recognised")
            }
            
            newMessage = JSQMessage(senderId: AvatarIdJobs, displayName: DisplayNameJobs, media: newMediaData)
        }
        else {
            /**
             *  Last message was a text message
             */
            
            newMessage = JSQMessage(senderId: AvatarIdJobs, displayName: DisplayNameJobs, text: copyMessage!.text)
        }
        
        /**
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new JSQMessageData object to your data source
         *  3. Call `finishReceivingMessage`
         */
        
        self.messages.append(newMessage)
        self.finishReceivingMessageAnimated(true)
        
        if newMessage.isMediaMessage {
            /**
             *  Simulate "downloading" media
             */
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                /**
                 *  Media is "finished downloading", re-display visible cells
                 *
                 *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
                 *
                 *  Reload the specific item, or simply call `reloadData`
                 */
                
                switch newMediaData {
                case is JSQPhotoMediaItem:
                    (newMediaData as! JSQPhotoMediaItem).image = newMediaAttachmentCopy as? UIImage
                    self.collectionView!.reloadData()
                case is JSQLocationMediaItem:
                    (newMediaData as! JSQLocationMediaItem).setLocation(newMediaAttachmentCopy as? CLLocation, withCompletionHandler: {
                        self.collectionView!.reloadData()
                    })
                default:
                    assertionFailure("Error: This Media type was not recognised")
                }
            }
        }
    }
    
    // RECEIVE MESSAGE
    func observeMessages() {
        let myRef = ref.child("chats/\(senderId)")
        let newRef = myRef.queryLimitedToLast(25)
        //let refHandle =
        newRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let postDict = snapshot.value as! [String : AnyObject]
            
            // read, profileUrl
            let id = postDict["senderId"] as? String
            let name = postDict["senderName"] as? String
            let time = postDict["sendTime"] as? NSTimeInterval
            let sendTime: NSDate!
            
            if time != nil {
                // Cast the value to an NSTimeInterval
                // and divide by 1000 to get seconds.
                sendTime = NSDate(timeIntervalSince1970: time!/1000)
            } else {
                sendTime = NSDate()
            }
            
            let mediatype = postDict["mediatype"] as? String
            if mediatype == nil || mediatype == "TEXT" { // default text type
                let text = postDict["text"] as? String
                let message = JSQMessage(senderId: id, senderDisplayName: id, date: sendTime, text: text)
                self.messages.append(message)
            } else if mediatype == "PHOTO" || mediatype == "VIDEO" { // photo, video, imoticon
                let photoPath = postDict["fileUrl"] as? String
                
                self.acruzApi.downloadPhoto(photoPath!, completion: { (image, error) in
                    let photoItem = JSQPhotoMediaItem(image: image)
                    self.addMedia(photoItem)
                })
            } else {
                
            }
            
            self.finishSendingMessageAnimated(true)
        })
    }
    
    // MARK: JSQMessagesViewController method overrides
    // MARK:: SEND BUTTON
    override func didPressSendButton(button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: NSDate) {
        /**
         *  Sending a message. Your implementation of this method should do *at least* the following:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishSendingMessage`
         */
        
        sendAction("TEXT", textOrUrl: text)
    }
    
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(filename: String) -> String {
        
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
        
    }
    
    // Define the specific path, image name
    //let imagePath = fileInDocumentsDirectory(myImageName)
    
    // MARK:: ADDITIONAL FEATURE
    override func didPressAccessoryButton(sender: UIButton) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        
        let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .ActionSheet)
        
        let photoAction = UIAlertAction(title: "Send photo", style: .Default) { (action) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .SavedPhotosAlbum
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
        let protectedPhotoAction = UIAlertAction(title: "Send protected photo", style: .Default) { (action) in
            
            
        }
        
        let locationAction = UIAlertAction(title: "Send location", style: .Default) { (action) in
            //self.sendLocationAction()
            /**
             *  Add fake location
             */
            let locationItem = self.buildLocationItem()
            
            self.addMedia(locationItem)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        sheet.addAction(photoAction)
        sheet.addAction(protectedPhotoAction)
        sheet.addAction(locationAction)
        sheet.addAction(cancelAction)
        
        self.presentViewController(sheet, animated: true, completion: nil)
    }
    
    func sendAction(type: String!, textOrUrl: String!) {
        let userRef = ref.child("chats/\(senderId)") // need to be modified to 'userId'
        let itemRef = userRef.childByAutoId()
        
        var parameter: String!
        if type == "TEXT" {
            parameter = "text"
        } else if type == "PHOTO" {
            parameter = "fileUrl"
        } else if type == "VIDEO" {
            parameter = "fileUrl"
        } else if type == "IMOTICON" {
            parameter = "imoticonUrl"
        } else {
            // TODO:: if not defined? how to control?
        }
        
        let messageItem = [
            "mediatype": type,
            parameter: textOrUrl,
            "senderId": senderId,
            "senderName": senderDisplayName,
            "profileUrl": "http://fakeurl.com",
            "sendTime": [".sv": "timestamp"],
            "read": false
        ]
        itemRef.setValue(messageItem) // 3
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
        
        // TYPING FALSE
        let myTypingRef = ref.child("typing/\(userId)/\(senderId)")
        let typingItem = [
            "isTyping": false
        ]
        myTypingRef.setValue(typingItem)
        
        // TODO:: PUSH?????????
    }
    
    func buildLocationItem() -> JSQLocationMediaItem {
        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)
        
        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(ferryBuildingInSF) {
            self.collectionView!.reloadData()
        }
        
        return locationItem
    }
    
    func addMedia(media:JSQMediaItem) {
        let message = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: media)
        self.messages.append(message)
        
        //Optional: play sent sound
        
        self.finishSendingMessageAnimated(true)
    }
    
    // MARK:: COLLECTIONVIEW OVERRIDE
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, messageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    // MY MSG? OR
    override func collectionView(collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageBubbleImageDataSource {
        return messages[indexPath.item].senderId == self.senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]
        
        //Here we are displaying everyones name above their message except for the "Senders"
        if message.senderId == self.senderId {
            return nil
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    // HIDE SENDER NAME - HEIGHT
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return messages[indexPath.item].senderId == self.senderId ? 0 : kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    // MARK:: MONITORING SENDER TYPING
    func observeTyping() {
        let monitoringRef = ref.child("typing/\(senderId)/\(userId)")
        let senderTypingQuery = monitoringRef.queryOrderedByValue().queryEqualToValue(true)
        senderTypingQuery.observeEventType(.ChildChanged, withBlock: { (snapshot) in
            /*if snapshot.childrenCount == 1 && self.isTyping {
                return
            }*/
            // TODO:: CHILD CHANGED CORRECT??
            print("typing children changed")
            
            self.showTypingIndicator = snapshot.childrenCount > 0
            self.scrollToBottomAnimated(true)
        })
    }
    
    // MARK:: I'M TYPING
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        let isTyping = textView.text != ""
        
        let myTypingRef = ref.child("typing/\(userId)/\(senderId)")
        myTypingRef.onDisconnectRemoveValue()
        
        let typingItem = [
            "isTyping": isTyping
        ]
        myTypingRef.setValue(typingItem)
        
        // TODO : If send button, this func not called
    }
    
    // MARK:: IMAGE PICKER OVERRIDE
    /*func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFit
            imageView.image = pickedImage
        }
        print("image1")
        let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        self.uploadFile(imageURL)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }*/
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        acruzApi.uploadPhoto("images/river.jpg", image: image, completion: { (path, error) in
            if (error != nil) {
                // error occurs
            } else {
                self.sendAction("PHOTO", textOrUrl: path)
            }
        })
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
