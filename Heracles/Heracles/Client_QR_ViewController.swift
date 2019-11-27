//
//  Client_QR_ViewController.swift
//  Heracles
//
//  Created by Raghav Sreeram on 11/18/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit

class Client_QR_ViewController: UIViewController {

    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var clientCodeLabel: UILabel!
    var clientCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let code = clientCode else {
            return
        }
        
        let image = generateQRCode(from: code)
        
        qrCodeImage.image = image
        clientCodeLabel.text = clientCode ?? ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("client code in qr page: \(String(describing: clientCode))")
    }
    
    @IBAction func backButton(_ sender: Any) {
        
        self.dismiss(animated: true) {
            return
        }
    }
    
    //Source:
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
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
}
