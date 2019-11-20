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

class AddClientViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var cameraView: UIView!
    
    var video = AVCaptureVideoPreviewLayer()
    var scannedQR = false
    @IBOutlet weak var codeText: UITextField!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
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
            if metadataObjects != nil && metadataObjects.count != 0 {
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
                                    }))
                                    
                                    self.present(alert, animated: true, completion: nil)
                                
                                    //TODO: Actually add client to client list
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func addClientButtonPressed(_ sender: Any) {
    
        guard let scanned_client = codeText.text else {
            return
        }

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
    



}
