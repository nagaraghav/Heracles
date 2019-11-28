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
import FBSDKLoginKit

class ClientHomeViewController: UIViewController, AddedCalories {
   
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var weightTF: UITextField!
    @IBOutlet weak var caloriesTF: UITextField!
    @IBOutlet weak var workoutTF: UITextField!
    @IBOutlet weak var sleepTF: UITextField!
    
    var ref: DatabaseReference!
    var user: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        let formattedDate = getDate()
        setDateLabel(date: formattedDate)
        
        ref = Database.database().reference()
        
        let userID = Auth.auth().currentUser?.uid
        guard let userId = userID else{
            return
        }
        
        activityIndicator.startAnimating()
        
        ref.child("user").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.user = value

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
            self.activityIndicator.stopAnimating()
        }) { (error) in
            print(error.localizedDescription)
            self.activityIndicator.stopAnimating()
            self.showNetworkError()
        }
    }
    
    
    func getDate() -> String {
        let date = Date()
        let format = DateFormatter()
        
        format.dateFormat = "dd-MM-yyyy"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
    
    func setDateLabel(date: String) {
        
        self.dateLabel.text = "\(date)"
    }
    
    //Pass in firstName, lastName, height, accountType
    @IBAction func settingsPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Settings")
        
        let qrVC = vc as! Settings
        guard let user_ = self.user else{
            print("no user")
            return
        }
        
        qrVC.firstName_input = user_["firstName"] as? String ?? ""
        qrVC.lastName_input = user_["lastName"] as? String ?? ""
        qrVC.height_ = user_["height"] as? String ?? ""
        
        qrVC.modalPresentationStyle = .fullScreen
        self.present(qrVC, animated: true)
    }
    
    @IBAction func signOutButton(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            FBSDKLoginManager().logOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            showNetworkError()
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
    
    @IBAction func cameraButton(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "nutriVC")
        
        let nutriVC = vc as! NutritionViewController
        nutriVC.delegate = self
        
        nutriVC.modalPresentationStyle = .overFullScreen
        self.present(nutriVC, animated: true)
        
    }
    
    func userDidAddCalories(newCalories: String) {
        let curCalories = caloriesTF.text ?? "0"
        let cur = Double(curCalories) ?? 0
        let new = Double(newCalories) ?? 0
        let total = cur + new
        
        caloriesTF.text = "\(total)"
    }
       

    @IBAction func saveButton(_ sender: Any) {
        
        let userID = Auth.auth().currentUser?.uid
        guard let userId = userID else{
            return
        }
        
        activityIndicator.startAnimating()
        ref.child("user").child(userId).child("logs").child(dateLabel.text ?? "").setValue(["calorie": caloriesTF.text ?? "", "weight": weightTF.text ?? "", "sleep": sleepTF.text ?? "", "workout": workoutTF.text ?? ""]) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
                self.activityIndicator.stopAnimating()
                self.showNetworkError()
            } else {
                print("Data saved successfully!")
                self.activityIndicator.stopAnimating()
            }
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
