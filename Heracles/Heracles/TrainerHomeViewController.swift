//
//  TrainerHomeViewController.swift
//  Heracles
//
//  Created by Ethan Chiang on 11/15/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit
import ScrollableGraphView
import FirebaseDatabase
import FirebaseAuth
import FBSDKLoginKit

class TrainerHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var ClientListTableView: UITableView!
    @IBOutlet weak var ClientCounterLabel: UILabel!
    
    
    @IBOutlet weak var TrainerNameLabel: UILabel!
    @IBOutlet weak var GymNameLabel: UILabel!
    @IBOutlet weak var TrainerProfileImageView: UIImageView!
    
    // MARK: data for client list
    var clientNames: [String] = []
    var clientIds: [String] = []
    
    var allUsers: NSDictionary = [:]
    
    
    private var curIndexPath : IndexPath? = nil
    
    private var ref: DatabaseReference!
    private var user: NSDictionary?
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.clientNames.removeAll()
        
        if let _ = FBSDKAccessToken.current()
        {
            fetchUserProfile()
        }
        
        ref = Database.database().reference()
        
        let userID = Auth.auth().currentUser?.uid
        guard let userId = userID else{
            return
        }
        
        // get trainer info
        ref.child("user").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
        
            let value = snapshot.value as? NSDictionary
            
            let firstName = value?["firstName"] as? String ?? ""
            let lastName = value?["lastName"] as? String ?? ""
            let gymName = value?["gymName"] as? String ?? ""
            
            
            self.TrainerNameLabel.text = "\(firstName) \(lastName)"
            self.GymNameLabel.text = gymName
            
        }) { (error) in print(error.localizedDescription) }
        
        // get client list
        ref.child("user").child(userId).child("clientList").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let clientIds = value?.allValues
            
            
            
            clientIds?.forEach {id in
                
                self.clientIds.append(id as! String)
                
                let client = self.allUsers[id] as? NSDictionary ?? nil
                
                let firstName = client?["firstName"] as? String ?? ""
                let lastName = client?["lastName"] as? String ?? ""
        
                self.clientNames.append("\(firstName) \(lastName)")
                self.ClientListTableView.reloadData()
            }
            
        }) { (error) in print(error.localizedDescription) }
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ClientListTableView.dataSource = self
        ClientListTableView.delegate = self
        
        self.ClientCounterLabel.text = "\(self.clientNames.count)";
    }
    
    @IBAction func addClientButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "trainerHometoAddClient", sender: self)
    }
    
    // MARK: table view protocol
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clientNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "client") ?? UITableViewCell(style: .default, reuseIdentifier: "client")
               
            let text = clientNames[indexPath.row]
               
            cell.textLabel?.text = text
               
            return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.ClientListTableView.deselectRow(at: indexPath, animated: true)
        
        // index of client selected
        self.curIndexPath = indexPath
        
        print(self.clientIds[indexPath.row])
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "TrainerHomeToClientLogs", sender: self)
        
    }
    
    
    // MARK: sign out
    @IBAction func signoutPress() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            FBSDKAccessToken.setCurrent(nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }

        self.dismiss(animated: true) {
          return
        }
    }
    
    
    // MARK: settings
    @IBAction func settingsPress() {
        self.performSegue(withIdentifier: "TrainerHomeToSettings", sender: self)
    }
    
    // MARK: segue override
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "TrainerHomeToSettings" {
            let segueVC: Settings = segue.destination as! Settings
            
            
        }
    }
    
    // MARK: fetchUserProfile
    func fetchUserProfile()
    {
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)

        Auth.auth().signIn(with: credential) { (user, error) in
            if let user = Auth.auth().currentUser {
                for profile in user.providerData {
                let photoUrl = profile.photoURL!.absoluteString + "?type=large"
                let url = URL(string: photoUrl)
                self.TrainerProfileImageView.downloadImage(from: url!)
                  }
                }
            }
    }
    
}

// MARK: UIImageView extension
extension UIImageView {
   func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
      URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
   }
   func downloadImage(from url: URL) {
      getData(from: url) {
         data, response, error in
         guard let data = data, error == nil else {
            return
         }
         DispatchQueue.main.async() {
            self.image = UIImage(data: data)
         }
      }
   }
}
