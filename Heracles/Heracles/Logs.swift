//
//  Logs.swift
//  Heracles
//
//  Created by Ethan Chiang on 11/23/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

private var ref: DatabaseReference!

class Logs {
    private var clientID : String
    
    init(clientID: String){
        self.clientID = clientID
        
        ref.child("user").child(self.clientID).child("logs").observeSingleEvent(of: .value, with: { (snapshot) in
            
                let value = snapshot.value as? NSDictionary
            
                let logs = value?["logs"] as? NSDictionary ?? nil
            
                
            
             }) { (error) in print(error.localizedDescription) }
    }
}
