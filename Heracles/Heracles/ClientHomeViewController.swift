//
//  ClientHomeViewController.swift
//  Heracles
//
//  Created by Raghav Sreeram on 11/16/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ClientHomeViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var weightTF: UITextField!
    @IBOutlet weak var caloriesTF: UITextField!
    @IBOutlet weak var workoutTF: UITextField!
    @IBOutlet weak var sleepTF: UITextField!
    
    var ref: DatabaseReference!
    var user: NSDictionary?
    override func viewWillAppear(_ animated: Bool) {
        
        
        let formattedDate = getDate()
        setDateLabel(date: formattedDate)
        
        ref = Database.database().reference()
        
        let userID = Auth.auth().currentUser?.uid
        guard let userId = userID else{
            return
        }
        
        
        ref.child("user").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.user = value
            print(self.user)
            let firstName = value?["firstName"] as? String ?? ""
            let lastName = value?["lastName"] as? String ?? ""
            
            self.userNameLabel.text = "\(firstName) \(lastName)"
            
            let logs_ = value?["logs"] as? NSDictionary
            guard let logs = logs_ else{
                print("no logs available")
                return
            }
            
            guard let log_today = logs[formattedDate] as? NSDictionary else{
                print("no logs for \(formattedDate)date")
                return
            }
            
            let calorie = log_today["calorie"] as? String ?? ""
            let weight = log_today["weight"] as? String ?? ""
            let workout = log_today["workout"] as? String ?? ""
            let sleep = log_today["sleep"] as? String ?? ""
            
            self.caloriesTF.text = calorie
            self.weightTF.text = weight
            self.workoutTF.text = workout
            self.sleepTF.text = sleep
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
    }
    
    
    func getDate() -> String{
        let date = Date()
        let format = DateFormatter()
        
        format.dateFormat = "dd-MM-yyyy"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
    
    func setDateLabel(date: String){
        
        self.dateLabel.text = "\(date)"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func settingsPage(_ sender: Any) {
        
    
    }
    
    @IBAction func signOutButton(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        
        self.dismiss(animated: true) {
            
            return
        }
          
        
    }
    
    @IBAction func qrButton(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "clientQR")

        let qrVC = vc as! Client_QR_ViewController
        guard let user_ = self.user else{
            print("no user")
            return
        }
        
        qrVC.clientCode = user_["clientID"] as? String ?? ""
            qrVC.modalPresentationStyle = .overFullScreen
            self.present(qrVC, animated: true)
        
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        
        var userID = Auth.auth().currentUser?.uid
        guard let userId = userID else{
            return
        }
        
        ref.child("user").child(userId).child("logs").child(dateLabel.text ?? "").setValue(["calorie": caloriesTF.text ?? "", "weight": weightTF.text ?? "", "sleep": sleepTF.text ?? "", "workout": workoutTF.text ?? ""]) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {""
                print("Data saved successfully!")
            }
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