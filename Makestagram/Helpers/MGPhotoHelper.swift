//
//  MGPhotoHelper.swift
//  Makestagram
//
//  Created by Hoang Thu Ha on 30/11/17.
//  Copyright © 2017 Hoang Thu Ha. All rights reserved.
//

import UIKit
import Photos

class MGPhotoHelper: NSObject {
    
    var completionHandler : ((UIImage) -> Void)?
    
    //to comuicate with MainTabBarController
    func presentActionSheet ( from viewController : UIViewController) {
        let alertController = UIAlertController(title: nil, message: "Where do you want to get your photo?", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let capturePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
                self.presentImagePickerController(with: .camera, from: viewController)
            })
            alertController.addAction(capturePhotoAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let uploadAction = UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
                self.presentImagePickerController(with: .photoLibrary, from: viewController)
            })
            alertController.addAction(uploadAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        viewController.present(alertController, animated: true)
    }
    
    func presentImagePickerController (with sourceType: UIImagePickerControllerSourceType, from viewController : UIViewController) {
        PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus)in
            switch status{
            case .denied:
                break
            case .authorized:
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = sourceType
                imagePickerController.delegate = self
                //imagePickerController.allowsEditing = true
                
                viewController.present(imagePickerController, animated: true)
            default:
                break
            }
        })
    }
}

extension MGPhotoHelper : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if picker.allowsEditing {
            if let sourceImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                completionHandler?(sourceImage)
            }
        } else {
            if let sourceImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                completionHandler?(sourceImage)
            }
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}







