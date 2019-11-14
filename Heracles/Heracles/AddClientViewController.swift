//
//  AddClientViewController.swift
//  Heracles
//
//  Created by Shivam Desai on 11/12/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit

class AddClientViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cameraView: UIView!
    var imagePickers: UIImagePickerController?
    
    @IBOutlet weak var codeText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        addImagePickerToContainerView()
        cameraView.backgroundColor = UIColor.black
    }
    
    func addImagePickerToContainerView(){
        
        imagePickers = UIImagePickerController()
        if UIImagePickerController.isCameraDeviceAvailable( UIImagePickerController.CameraDevice.front) {
            imagePickers?.delegate = self
            imagePickers?.sourceType = UIImagePickerController.SourceType.camera
            
            //add as a childviewcontroller
            addChild(imagePickers!)
            
            // Add the child's View as a subview
            self.cameraView.addSubview((imagePickers?.view)!)
            imagePickers?.view.frame = cameraView.bounds
            imagePickers?.allowsEditing = false
            imagePickers?.showsCameraControls = false
            imagePickers?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
        }
    }


}
