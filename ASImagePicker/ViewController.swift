//
//  ViewController.swift
//  ASImagePicker
//
//  Created by Alessio Sardella on 11/06/2019.
//  Copyright © 2019 Alessio Sardella. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var imagePicker = ASImagePicker(presenter: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    private func showAlertSheetForCameraOrLibrary() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionCamera = UIAlertAction(title: "camera", style: .default) { (_) in
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            self.imagePicker.deviceCamera = .front
            self.imagePicker.open(.camera)
            
        }
        alert.addAction(actionCamera)
        
        let actionLibrary = UIAlertAction(title: "library", style: .default) { (_) in
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            self.imagePicker.open(.photoLibrary)
        }
        alert.addAction(actionLibrary)
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: ASImagePickerDelegate{
    
    func selectedImage(_ pickedImage: UIImage, _ picker: ASImagePicker) {
        
        imagePicker.saveImage(localPath: "myLocalPath...") { (success) in
            
            if success {
                
            }else{
                
                //manage failure...
            }
        }
    }
    
    func configureURLRequestWith(_ imageData: Data) -> URLRequest? {
        
        var request = URLRequest(url: URL(string: "http://url.myurl.put.image/")!)
        request.httpMethod = "PUT"
        request.httpBody = imageData
        return request
    }
}
