//
//  ViewController.swift
//  Heracles
//
//  Created by Shivam Desai on 11/9/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = FBSDKLoginButton()
        initLoginButton(button: loginButton)
        view.addSubview(loginButton)
        
    }
    
    func initLoginButton(button: FBSDKLoginButton) {
        button.frame = CGRect(x: 20, y: view.frame.height/2, width: view.frame.width - 40, height: 50)
        button.delegate = self
        button.readPermissions = ["email", "public_profile"]
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
        if FBSDKAccessToken.current() != nil {
            print("Found token")
            performSegue(withIdentifier: "loginToHome", sender: self)
        }
         */
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error as Any)
            return
        }
        
        print("Succesfully logged in with Facebook")
        
        performSegue(withIdentifier: "loginToHome", sender: self)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged Out")
    }
    




}

