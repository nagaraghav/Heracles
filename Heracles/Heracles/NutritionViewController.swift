//
//  NutritionViewController.swift
//  Heracles
//
//  Created by Raghav Sreeram on 11/19/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit

protocol AddedCalories {
    func userDidAddCalories(newCalories: String)
}


class NutritionViewController: UIViewController {

    
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var calorieTF: UITextField!
    
    var delegate: AddedCalories?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addButton(_ sender: Any) {
        
        delegate?.userDidAddCalories(newCalories: calorieTF.text ?? "0")
        self.dismiss(animated: true) {
            print("add Calories and dismissed")
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
