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
        cameraView.backgroundColor = UIColor.black
        let session = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return
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
        video.frame = cameraView.bounds
        cameraView.layer.addSublayer(video)
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
                            self.ref.child("user").child(currentKey).child("clientID").observeSingleEvent(of: .value, with: { (snapshot) in
                                              
                                    if snapshot.value as? String == scanned_client {
                                        print("found client \(currentKey)")
                                        
                                        let alert = UIAlertController(title: "New Client Added", message: currentKey + " added to your clients list!", preferredStyle: .alert)
                                        
                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                            alert.dismiss(animated: true, completion: nil)
                                        }))
                                        
                                        self.present(alert, animated: true, completion: nil)
                                        //TODO: Actually add client to client list
                                    }
                                          
                            })
                              
                        }
                        
                        
                        scannedQR = true
                    }
                }
            }
        }
    }
    



}
