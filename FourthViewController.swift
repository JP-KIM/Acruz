//
//  FourthViewController.swift
//  Acruz
//
//  Created by 김정표 on 2016. 6. 4..
//  Copyright © 2016년 Acruz corp. All rights reserved.
//

import UIKit
import FirebaseAuth

class FourthViewController: UIViewController {
    
    @IBOutlet weak var lblNickname: UILabel!
    @IBOutlet weak var lblUID: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    @IBAction func onLogout(sender: AnyObject) {
        try! FIRAuth.auth()?.signOut()
        self.performSegueWithIdentifier("onLogout", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = FIRAuth.auth()?.currentUser
        if let uid = user?.uid {
            lblUID.text = "UID: \(uid)"
        }
        if let nickname = user?.displayName {
            lblNickname.text = "Nickname: \(nickname)"
        }
        if let email = user?.email {
            lblEmail.text = "Email: \(email)"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

