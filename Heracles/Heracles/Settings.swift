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
    
    var firstName_input : String?
    var lastName_input : String?
    var height_input : String?
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        
        firstName.text = firstName_input
        lastName.text = lastName_input
        height.text = height_input
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        let userID = Auth.auth().currentUser?.uid
        guard let userId = userID else{
            return
        }
        
        ref.child("user").child(userId).setValue(["firstName": firstName.text ?? "", "lastName": lastName.text ?? "", "height": height.text ?? ""]) {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
