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


class NutritionViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var calorieTF: UITextField!
    @IBOutlet weak var foodLabel: UITextField!
    
    @IBOutlet weak var cameraView: UIImageView!
    
    @IBOutlet weak var pictureButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var delegate: AddedCalories?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        foodLabel.delegate = self
    }
    
    /*
     When 'return' is pressed within a textbox, find calories for food
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        findCalories()
        return true
    }
    
    //added UITapGestureRecognizer to View through interface builder
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        hideKeyboard()
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }

    /*
     Use protocal/delegate to add the new calorie amount to current amount
     */
    @IBAction func addButton(_ sender: Any) {
        delegate?.userDidAddCalories(newCalories: calorieTF.text ?? "0")
        self.dismiss(animated: true) {
            print("added Calories and dismissed")
            return
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true) {
            return
        }
    }
    
    /*
     Use image picker controller to take picture
     */
    @IBAction func takePhoto(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .camera
        image.allowsEditing = false
        self.present(image, animated: true)
    }
    
    /*
     Use current value in food text field for Nutrition API and update calorie text field
     */
    func findCalories() {
        let url : String = "https://trackapi.nutritionix.com/v2/natural/nutrients/"
        var request = URLRequest(url: NSURL(string: url)! as URL)
        let appID = "f913256b"
        let appSecret = "584046e88dd7e69a33cdbae0b45a0eb7"
        
        request.addValue(appID, forHTTPHeaderField: "x-app-id")
        request.addValue(appSecret, forHTTPHeaderField: "x-app-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
       
        guard let food = foodLabel.text else {
            self.calorieTF.text = "0"
            return
        }
        
        if food == "" {
            self.calorieTF.text = "0"
            return
        }
        
        let json = ["query": "\(food)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        self.activityIndicator.startAnimating()
        addButton.isEnabled = false
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                DispatchQueue.main.async{
                    self.showNetworkError()
                    self.activityIndicator.stopAnimating()
                    self.addButton.isEnabled = true
                }
                
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {

                let step1 = responseJSON["foods"] as? NSArray
                let step2 = step1?[0] as? NSDictionary
                           
                guard let calories = step2?["nf_calories"] else {
                    print("Couldnt find calories in data")
                    DispatchQueue.main.async {
                        self.calorieTF.text = "Calorie Data not available"
                        self.activityIndicator.stopAnimating()
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.calorieTF.text = "\(calories)"
                    self.activityIndicator.stopAnimating()
                    self.addButton.isEnabled = true
                }
            }
        }
        
        task.resume()
    }

    /*
     Set UIImage view to the picture that was taken
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            cameraView.image = image
            predictFood(image: image)
            print("Processing.....")
        }
        
        self.dismiss(animated: true, completion: nil)
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
    
    /*
     Use the passed in image for the Food prediction api and set the food label to the prediction
     with highest confidence
     */
    func predictFood(image: UIImage) {
        let imageData = image.jpegData(compressionQuality: 1)
        
        guard let base64image = imageData?.base64EncodedString(options: .lineLength64Characters) else {
            return
        }
        
        let request = buildRequest(imageString: base64image)
        self.activityIndicator.startAnimating()
        pictureButton.isEnabled = false
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                DispatchQueue.main.async {
                    self.showNetworkError()
                    self.activityIndicator.stopAnimating()
                    self.pictureButton.isEnabled = true
                }
                
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            let detected = self.getTopFoodFromResponse(responseJSON: responseJSON)
            
            DispatchQueue.main.async {
                self.foodLabel.text = detected
                self.findCalories()
                self.activityIndicator.stopAnimating()
                self.pictureButton.isEnabled = true
            }
        }

        task.resume()
    }
    
    func buildRequest(imageString: String) -> URLRequest {
        let json = ["inputs": [[ "data": [ "image": ["base64": imageString]]]]]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let authorizationKey = "Key 2472d11e8de249fd9268ff3c775ea7e5"
        let endpoint = "https://api.clarifai.com/v2/models/bd367be194cf45149e75f01d59f77ba7/outputs"
        
        let url = URL(string: endpoint)!
        var request = URLRequest(url: url)
        request.addValue(authorizationKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
    
        return request
    }
    
    
    func getTopFoodFromResponse(responseJSON: Any?) -> String {
        if let responseJSON = responseJSON as? [String: Any] {
            //print(responseJSON)
            if let outputs = responseJSON["outputs"] {
                if let value = outputs as? NSArray {
                    if let some_data = value[0] as? NSDictionary {
                        for (key, value) in some_data {
                            if String(describing: key) == "data" {
                                let temp_value = value as? NSDictionary
                                let concepts = temp_value?["concepts"] as? NSArray
                                if let top_food_container = concepts?[0] as? NSDictionary {
                                    if let detected_food = top_food_container["name"] as? String {
                                        return detected_food
                                    }
                                }
                            }
                        }
                    }
                }

            }
        }
        
        return "Detection Failed"
    }
}
