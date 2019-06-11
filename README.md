# ASImagePicker
Manage the classic UIImagePickerController quickly and with extended functionality. Using ASImagePicker let you easily save an image locally and upload it remotely.

Easy to setup:
```
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

```

Delegate implementation:

```
extension ViewController: ASImagePickerDelegate{
    
    //Get the picked image after the user select it.
    func selectedImage(_ pickedImage: UIImage, _ picker: ASImagePicker) {
        
        imagePicker.saveImage(localPath: "myLocalPath...") { (success) in
            
            if success {
                
            }else{
                
                //manage failure...
            }
        }
    }
    
    //Optional method to save image also remotely
    func configureURLRequestWith(_ imageData: Data) -> URLRequest? {
        
        var request = URLRequest(url: URL(string: "http://url.myurl.put.image/")!)
        request.httpMethod = "PUT"
        request.httpBody = imageData
        return request
    }
}
```
