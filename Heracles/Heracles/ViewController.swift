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
        initLoginButton(button: loginButton)
        view.addSubview(loginButton)
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
            self.showNetworkError()
            print(error.localizedDescription)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.getAllUsers()
        }
                
        if FBSDKAccessToken.current() != nil {
            print("found token")

            loginButton.removeFromSuperview()
            activityIndicator.startAnimating()
            
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print(error)
                    self.showNetworkError()
                    return
                }
                
                guard let user = authResult?.user else {
                    self.showNetworkError()
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
                        self.showNetworkError()
                    }
                } else {
                    self.activityIndicator.stopAnimating()
                    self.loginButton.isHidden = true
                    self.newUserPopup.isHidden = false
                }
            }
        } else {
            view.addSubview(loginButton)
        }
         
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error as Any)
            self.showNetworkError()
            return
        }
        
        loginButton.removeFromSuperview()
        
        activityIndicator.startAnimating()
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString) 
        
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error)
                self.showNetworkError()
                return
            }
            
            guard let user = authResult?.user else {
                return
            }
            
            currentUser = user
            
            if self.doesUserExist(currentUser: user) {
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

        guard let user = currentUser else {
            return
        }
        
        self.ref.child("user/" + user.uid +  "/account_type").setValue("client")
        let names = self.getFirstandLastName(displayName: user.displayName ?? "")
        setNewUserNames(userID: user.uid, firstName: names[0], lastName: names[1])

        newUserPopup.isHidden = true
        
        print("new client created")
        
        performSegue(withIdentifier: "loginToHome", sender: self)
    }
    
    
    @IBAction func trainerButtonPressed(_ sender: Any) {
        
        guard let user = currentUser else {
            return
        }
        
        self.ref.child("user/" + user.uid +  "/account_type").setValue("trainer")
        let names = self.getFirstandLastName(displayName: user.displayName ?? "")
        setNewUserNames(userID: user.uid, firstName: names[0], lastName: names[1])
        
        newUserPopup.isHidden = true
        
        print("new trainer created")

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
    
    /*
     Function to show generic network error alert
     */
    func showNetworkError() {
        let alert = UIAlertController(title: "Network Error", message: "Unable to establish network connection! Please try again later.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}



