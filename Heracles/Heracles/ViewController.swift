//
//  ViewController.swift
//  Heracles
//
//  Created by Shivam Desai on 11/9/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseDatabase
import FirebaseAuth

var currentUser: User? = nil
var allUsers: NSDictionary = [:]

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newUserPopup: UIView!
    let loginButton = FBSDKLoginButton()
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        activityIndicator.hidesWhenStopped = true
    }
    
    func initLoginButton(button: FBSDKLoginButton) {
        button.frame = CGRect(x: 20, y: view.frame.height/2, width: view.frame.width - 40, height: 50)
        button.delegate = self
        button.readPermissions = ["email", "public_profile"]
    }
    
    func getAllUsers(){
        ref.child("user").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let users = snapshot.value as? NSDictionary
            
            guard let tempusers = users else {
                return
            }
            
            allUsers = tempusers

        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAllUsers()
        
        if FBSDKAccessToken.current() != nil {
            
            activityIndicator.startAnimating()
            
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let user = authResult?.user else {
                    return
                }
                
                currentUser = user
                
                
                if self.doesUserExist(currentUser: user) {
                    print("found")
                    self.ref.child("user").child(user.uid).child("account_type").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        let type = snapshot.value as? String
                        
                        self.activityIndicator.stopAnimating()
                        
                        if type == "client" {
                            self.performSegue(withIdentifier: "loginToHome", sender: self)
                            print("client")
                        } else {
                            self.performSegue(withIdentifier: "LoginToTrainerHome", sender: self)
                            print("trainer")
                        }
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                } else {
                    self.activityIndicator.stopAnimating()
                    self.loginButton.isHidden = true
                    self.newUserPopup.isHidden = false
                }
            }
        } else {
            initLoginButton(button: loginButton)
            view.addSubview(loginButton)
        }
         
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error as Any)
            return
        }
        loginButton.isHidden = true
        
        activityIndicator.startAnimating()
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString) 
        
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let user = authResult?.user else {
                return
            }
            
            currentUser = user
            
            if self.doesUserExist(currentUser: user) {
                print("found")
                self.ref.child("user").child(user.uid).child("account_type").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let type = snapshot.value as? String
                    
                    self.activityIndicator.stopAnimating()
                    
                    if type == "client" {
                        self.performSegue(withIdentifier: "loginToHome", sender: self)
                        print("client")
                    } else {
                        self.performSegue(withIdentifier: "LoginToTrainerHome", sender: self)
                        print("trainer")
                    }
                }) { (error) in
                    print(error.localizedDescription)
                }
            } else {
                loginButton.isHidden = true
                self.newUserPopup.isHidden = false
            }
            
            print("Succesfully logged in with Facebook")
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged Out")
    }
    
    @IBAction func clientButtonPressed(_ sender: Any) {
        //TODO: create new entry for user in database with account type = client
        guard let user = currentUser else {
            return
        }
        
        self.ref.child("user/" + user.uid +  "/account_type").setValue("client")
        let names = self.getFirstandLastName(displayName: user.displayName ?? "")
        setNewUserNames(userID: user.uid, firstName: names[0], lastName: names[1])
        
        //hide popup
        newUserPopup.isHidden = true
        
        print("new client created")
        //TODO: segue to client home page
        
        performSegue(withIdentifier: "loginToHome", sender: self)
    }
    
    
    @IBAction func trainerButtonPressed(_ sender: Any) {
        //TODO: create new entry for user in database with account type = trainer
        guard let user = currentUser else {
            return
        }
        
        self.ref.child("user/" + user.uid +  "/account_type").setValue("trainer")
        let names = self.getFirstandLastName(displayName: user.displayName ?? "")
        setNewUserNames(userID: user.uid, firstName: names[0], lastName: names[1])
        
        //hide popup
        newUserPopup.isHidden = true
        
        print("new trainer created")
        //TODO: segue to trainer home page
        performSegue(withIdentifier: "LoginToTrainerHome", sender: self)
    }

    func setNewUserNames(userID: String, firstName: String, lastName: String){
        self.ref.child("user/" + userID + "/firstName").setValue(firstName)
        self.ref.child("user/" + userID + "/lastName").setValue(lastName)
    }
    
    func getFirstandLastName(displayName: String) -> [String] {
        return displayName.split{$0 == " "}.map(String.init)
    }
    
    func doesUserExist(currentUser: User) -> Bool {
        
        for user in allUsers {
            let curKey = String(describing: user.key)
            if curKey == currentUser.uid {
                return true
            }
        }
        
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "LoginToTrainerHome" {
            let segueVC : TrainerHomeViewController = segue.destination as! TrainerHomeViewController
            
            segueVC.allUsers = allUsers
        }
        
    }
}



