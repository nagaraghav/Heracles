//
//  AddClientViewController.swift
//  Heracles
//
//  Created by Shivam Desai on 11/12/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseDatabase
import FirebaseAuth

class AddClientViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate {

    @IBOutlet weak var cameraView: UIView!
    
    var video = AVCaptureVideoPreviewLayer()
    var scannedQR = false
    @IBOutlet weak var codeText: UITextField!
    var ref: DatabaseReference!
    var trainer: NSDictionary?
    var clientCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeText.delegate = self
        codeText.setUnderLine()
        ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        guard let userId = userID else {
            return
        }
        
        
        ref.child("user").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            self.trainer = snapshot.value as? NSDictionary
            
            guard let list = self.trainer?["clientList"] as? NSDictionary else { return }
            
            self.clientCount = list.count
        }) {(error) in
            print(error)
            self.showNetworkError()
        }
    }
    
    func addClient(clientUID: String){
        
        let userID = Auth.auth().currentUser?.uid
        guard let trainerID = userID else {
            return
        }
        
        ref.child("user/" + trainerID + "/clientList/" + "client" + String(clientCount + 1)).setValue(clientUID)

        clientCount += 1
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else {
            return false
        }
        
        let scanned_client = text + string
                
        if scanned_client.count == 5 {
            
           textField.text = scanned_client
           
            var found = false
    
           for user in allUsers {
               
               let currentKey = String(describing: user.key)
               
               let value = user.value as? NSDictionary
               
               if let id = value?["clientID"] as? String, let firstName = value?["firstName"] as? String, let lastName = value?["lastName"] as? String {
                   if id == scanned_client {
                       print("found client \(currentKey)")
                       found = true
                       let alert = UIAlertController(title: "New Client Added", message: firstName + " " + lastName + " added to your clients list!", preferredStyle: .alert)
                       
                       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                           alert.dismiss(animated: true, completion: nil)
                           self.codeText.text = ""
                       }))
                       
                       self.present(alert, animated: true, completion: nil)
                   
                       //TODO: Actually add client to client list
                        addClient(clientUID: currentKey)
                   }
               }
               
           }
       
           
           if !found {
               let notFoundAlert = UIAlertController(title: "Client Not Found", message: "Client with ID " + scanned_client + " not found", preferredStyle: .alert)
               
               notFoundAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                   notFoundAlert.dismiss(animated: true, completion: nil)
                   self.codeText.text = ""
               }))
               self.present(notFoundAlert, animated: true, completion: nil)
           }
        }
        
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let session = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        } catch {
            print("error")
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = cameraView.layer.bounds
        cameraView.layer.addSublayer(video)
        
        self.view.bringSubviewToFront(cameraView)
        
        session.startRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if !scannedQR {
            if metadataObjects.count != 0 {
                if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                    if object.type == AVMetadataObject.ObjectType.qr {
                        
                        guard let scanned_client = object.stringValue else {
                            return
                        }
            
                        for user in allUsers {
                              
                            let currentKey = String(describing: user.key)
                            
                            let value = user.value as? NSDictionary
                            
                            if let id = value?["clientID"] as? String, let firstName = value?["firstName"] as? String, let lastName = value?["lastName"] as? String {
                                if id == scanned_client {
                                    print("found client \(currentKey)")
                                    scannedQR = true
                                    let alert = UIAlertController(title: "New Client Added", message: firstName + " " + lastName + " added to your clients list!", preferredStyle: .alert)
                                    
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                        alert.dismiss(animated: true, completion: nil)
                                        self.codeText.text = ""
                                        self.scannedQR = false
                                    }))
                                    
                                    self.present(alert, animated: true, completion: nil)
                                
                                    //TODO: Actually add client to client list
                                    addClient(clientUID: currentKey)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
        
    //added UITapGestureRecognizer to View through interface builder
    @IBAction func handleTap(recognizer: UITapGestureRecognizer){
        hideKeyboard()
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
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


    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            return
        }
    }
    
}
