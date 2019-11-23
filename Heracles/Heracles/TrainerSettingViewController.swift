//
//  TrainerSettingViewController.swift
//  Heracles
//
//  Created by Ethan Chiang on 11/22/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit
import UIKit
import FirebaseDatabase
import FirebaseAuth


class TrainerSettingViewController: UIViewController {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var gymName: UITextField!

    var firstName_input : String?
    var lastName_input : String?
    var gymName_input : String?
    
    private var ref: DatabaseReference!

    override func viewDidLoad() {
        
        firstName.text = firstName_input
        lastName.text = lastName_input
        gymName.text = gymName_input
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func saveButton(_ sender: Any) {
        
        let userID = Auth.auth().currentUser?.uid
        guard let userId = userID else{
            return
        }
        
        ref.child("user").child(userId).setValue(["firstName": firstName.text ?? "", "lastName": lastName.text ?? "", "gymName": gymName.text ?? ""]) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully!")
            }
        }
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        
        self.dismiss(animated: true) {
            return
        }
    }

}
