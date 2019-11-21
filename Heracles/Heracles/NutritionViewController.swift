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

    

    @IBOutlet weak var foodName: UITextField!
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
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true) {
            return
        }
    }
    
    
   
    func findCalories(){
        var url : String = "https://trackapi.nutritionix.com/v2/natural/nutrients/"
        
        var request = URLRequest(url: NSURL(string: url)! as URL)
        var appID = "f913256b"
        var appSecret = "584046e88dd7e69a33cdbae0b45a0eb7"
        
        request.addValue(appID, forHTTPHeaderField: "x-app-id")
        request.addValue(appSecret, forHTTPHeaderField: "x-app-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
       
        let json = ["query":"\(self.foodName.text)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                //print(responseJSON)
                var step1 = responseJSON["foods"] as? NSArray
                var step2 = step1?[0] as? NSDictionary
           
                
                guard let calories = step2?["nf_calories"] else{
                    print("Couldnt find calories in data")
                    return
                }
                
                DispatchQueue.main.async {
                self.calorieTF.text = "\(calories)"
                }
                
                //self.calorieTF.text = "\(responseJSON["nf_calories"])"
            }
        }
        
        task.resume()
        
    }
    
    @IBAction func reloadCalories(_ sender: Any) {
        
        findCalories()
        
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
