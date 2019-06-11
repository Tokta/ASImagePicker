//
//  ASImagePicker.swift
//  ASImagePicker
//
//  Created by Alessio Sardella on 11/06/2019.
//  Copyright © 2019 Alessio Sardella. All rights reserved.
//

import UIKit

protocol ASImagePickerDelegate: AnyObject {
    
    ///Get picked image
    func selectedImage(_ pickedImage: UIImage, _ picker: ASImagePicker)
    
    ///Configure URLRequest to upload image
    func configureURLRequestWith(_ imageData: Data) -> URLRequest?
}

extension ASImagePickerDelegate{
    
    func configureURLRequestWith(_ imageData: Data) -> URLRequest?{
        return nil
    }
}

class ASImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var allowsEditing: Bool = false
    var deviceCamera: UIImagePickerController.CameraDevice = .rear
    
    var mediaTypes: [String] = []
    var presenter: UIViewController!
    weak var delegate: ASImagePickerDelegate?
    private var pickedImage: UIImage?
    private var imagePicker: UIImagePickerController!
    
    ///Start a new ASImagePicker, specify from which UIViewController
    convenience init(presenter: UIViewController) {
        self.init()
        self.presenter = presenter
    }
    
    ///Open UIImagePickerController, specify type
    final func open(_ sourceType: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            self.pickedImage = nil
            self.imagePicker = nil
            
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = self.allowsEditing
            imagePicker.allowsEditing = allowsEditing
            
            if !self.mediaTypes.isEmpty {
                imagePicker.mediaTypes = self.mediaTypes
            }
            if sourceType == .camera {
                
                imagePicker.cameraDevice = self.deviceCamera
            }
            
            self.presenter.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    final internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        let parameter = self.allowsEditing ? UIImagePickerController.InfoKey.editedImage : UIImagePickerController.InfoKey.originalImage
        self.pickedImage = info[parameter] as? UIImage
        
        self.presenter.dismiss(animated: true) {
            
            if let picked = self.pickedImage {
                
                self.delegate?.selectedImage(picked, self)
            }
        }
    }
    
    ///Get picked image
    func image() -> UIImage? {
        return self.pickedImage
    }
}

private typealias ASImagePickerSaver = ASImagePicker
extension ASImagePicker{
    
    ///Save image locally
    final func savePickedImageAtLocalPath(_ path: String, completion:@escaping (Bool) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            do {
                
                let url = URL(fileURLWithPath: path)
                try self.pickedImage?.jpegData(compressionQuality: 1.0)?.write(to: url)
                
                completion(true)
                
            } catch {
                
                
                completion(false)
                
            }
        }
    }
    
    ///Save image remotely
    final func savePickedImageWithRequest(completion:@escaping (Bool) -> Void) {
        
        if let imageData = self.pickedImage?.jpegData(compressionQuality: 1.0),
            let request = self.delegate?.configureURLRequestWith(imageData) {
            
            let session = URLSession(configuration: .default)
            session.dataTask(with: request) { (_, response, error) in
                
                guard (response as? HTTPURLResponse) != nil else {
                    completion(false)
                    return
                }
                
                completion(error == nil)
                
                }.resume()
            
        } else {
            
            completion(false)
            
        }
    }
    
    ///Save image locally and remotely
    final func saveImage(localPath: String, completion:@escaping (Bool) -> Void) {
        
        let group = DispatchGroup()
        var localSuccess: Bool = false
        var remoteSuccess: Bool = false
        
        group.enter()
        self.savePickedImageAtLocalPath(localPath) { (success) in
            localSuccess = success
            group.leave()
        }
        
        group.enter()
        self.savePickedImageWithRequest() { (success) in
            remoteSuccess = success
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(localSuccess && remoteSuccess)
        }
    }
}

