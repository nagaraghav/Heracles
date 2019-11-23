//
//  TrainerHomeViewController.swift
//  Heracles
//
//  Created by Ethan Chiang on 11/15/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit
import ScrollableGraphView

class TrainerHomeViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var ClientListTableView: UITableView!
    @IBOutlet weak var ClientCounterLabel: UILabel!
    
    
    // MARK: fake data
    private var data: [String] = []
    
    private var curIndexPath : IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 1...10 {
            data.append("Client #\(i)")
        }
        
        ClientListTableView.dataSource = self
        
        
        self.ClientCounterLabel.text = "\(self.data.count)";
    }
    
    @IBAction func addClientButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "trainerHometoAddClient", sender: self)
    }
    
    // MARK: table view protocol
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "client") ?? UITableViewCell(style: .default, reuseIdentifier: "client")
               
            let text = data[indexPath.row]
               
            cell.textLabel?.text = text
               
            return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.ClientListTableView.deselectRow(at: indexPath, animated: true)
        
        // index of client selected
        self.curIndexPath = indexPath
        
        
        // Segue to the second view controller
        //self.performSegue(withIdentifier: "TrainerHomeToClient", sender: self)
    }
    
    
}
