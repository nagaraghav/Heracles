//
//  Settings.swift
//  Heracles
//
//  Created by Kishan Patel on 11/19/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class Settings: UIViewController {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var height: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var firstName_input: String?
    var lastName_input: String?
    var height_: String?
    var gymName_: String?
    var account_type: String?
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        activityIndicator.hidesWhenStopped = true
        
        firstName.text = firstName_input
        lastName.text = lastName_input
        
        guard let id = currentUser?.uid else {
            return
        }
        
        activityIndicator.startAnimating()
        
        ref.child("user").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            self.account_type = value?["account_type"] as? String ?? ""
            self.gymName_ = value?["gymName"] as? String ?? ""
            self.height_ = value?["height"] as? String ?? ""
            
            
            let firstName = value?["firstName"] as? String ?? ""
            let lastName = value?["lastName"] as? String ?? ""
            self.firstName.text = firstName
            self.lastName.text = lastName
            
            if self.account_type == "client" {
                self.height.placeholder = "Height (Inches)"
                self.height.text = self.height_
            } else {
                self.height.placeholder = "Gym Name"
                self.height.text = self.gymName_
            }
            
            self.activityIndicator.stopAnimating()
        }){ (error) in
            self.activityIndicator.stopAnimating()
            self.showNetworkError()
            print(error.localizedDescription)
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
                
        guard let id = currentUser?.uid else {
            return
        }
        
        let newFirstName = self.firstName.text
        let newLastName = self.lastName.text
        let height_or_gym = self.height.text
        
        activityIndicator.startAnimating()
        
        if newFirstName != self.firstName_input {
            ref.child("user").child(id).child("firstName").setValue(newFirstName)
        }
        
        if newLastName != self.lastName_input {
            ref.child("user").child(id).child("lastName").setValue(newLastName)
        }
        
        if self.account_type == "client" {
            if height_or_gym != self.height_ {
                ref.child("user").child(id).child("height").setValue(height_or_gym)
            }
        } else {
            if height_or_gym != self.gymName_ {
                ref.child("user").child(id).child("gymName").setValue(height_or_gym)
            }
        }
        
        activityIndicator.stopAnimating()
        
        self.dismiss(animated: true) {
            return
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        
        self.dismiss(animated: true) {
            return
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
    
    //added UITapGestureRecognizer to View through interface builder
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        hideKeyboard()
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
}
