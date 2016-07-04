//
//  LoginViewController.swift
//  Acruz
//
//  Created by 김정표 on 2016. 6. 30..
//  Copyright © 2016년 Acruz corp. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var tvEmail: UITextField!
    @IBOutlet weak var tvPassword: UITextField!
    @IBAction func onLoginClicked(sender: AnyObject) {
        
        
    }
    @IBAction func onAnonymousLoginClicked(sender: AnyObject) {
        FIRAuth.auth()?.signInAnonymouslyWithCompletion( { (user, error) in
            
            print("Firebase anonymous login succeed")
            self.performSegueWithIdentifier("TabView", sender: self)
        })
    }
    
    @IBOutlet weak var FBLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.FBLoginButton.delegate = self
        
        self.FBLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    // MARK:: FACEBOOK LOGIN BUTTON
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil) {
            // Process error
            print("process error")
        }
        else if result.isCancelled {
            // Handle cancellations
            print("cancelled")
        }
        else {
            // Navigate to other view
            print("succeed, navigate to Main")
            //queryUserData()
            if result.grantedPermissions.contains("email")
            {
                print("couldn't get email")
                // Do work
            }
            
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                // If succeed to add account to Firebase, move to next controller
                print("Firebase facebook login succeed")
                self.performSegueWithIdentifier("TabView", sender: self)
            })
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    // MARK:: FACEBOOK USER QUERY
    func queryUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if error != nil {
                // Process error
                print("Error: \(error)")
            } else {
                print("fetched user: \(result)")
                if let userName = result.valueForKey("name") {
                    print("User Name is: \(userName)")
                }
                if let userEmail = result.valueForKey("email") {
                    print("User Email is: \(userEmail)")
                }
            }
        })
        
    }
}

