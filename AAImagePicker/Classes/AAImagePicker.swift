//
//  AAImagePicker.swift
//  AAImagePicker
//
//  Created by Engr. Ahsan Ali on 01/04/2017.
//  Copyright (c) 2017 AA-Creations. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

open class AAImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public let imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.modalPresentationStyle = .overCurrentContext
        if #available(iOS 11.0, *) {
            imagePicker.videoExportPreset = AVAssetExportPresetPassthrough
            imagePicker.imageExportPreset = .compatible
        }
        return imagePicker
    }()
    
    public var playerViewController: AVPlayerViewController?
    
    var options: AAImagePickerOptions = AAImagePickerOptions()
    var getImage: ((UIImage?, String?) -> Void)!
    
    var presentController : UIViewController {
        return (options.presentController ?? rootViewController)
    }
    
    var rootViewController: UIViewController {
        guard let root = UIApplication.shared.keyWindow?.rootViewController else {
            fatalError("AAImagePicker - Application key window not found. Please check UIWindow in AppDelegate.")
        }
        
        return root
    }
        
    func setupAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: options.actionSheetTitle, message: options.actionSheetMessage, preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.sourceView = presentController.view

        let camera = UIAlertAction(title: options.optionCamera, style: .default, handler: { _ in
            self.presentPicker(sourceType: .camera)
        })
        
        let photoLibrary = UIAlertAction(title: options.optionLibrary, style: .default, handler: { _ in
            self.presentPicker(sourceType: .photoLibrary)
        })
        
        let cancel = UIAlertAction(title: options.optionCancel, style: .cancel, handler: nil)
        
        alertController.addAction(camera)
        alertController.addAction(photoLibrary)
        alertController.addAction(cancel)
        return alertController
    }
    
    open func setImagePickerSource(_ sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        imagePicker.allowsEditing = options.allowsEditing
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
    }
    
    func presentPicker(sourceType: UIImagePickerController.SourceType) {
        setImagePickerSource(sourceType)
        setMediaTypes()
        presentController.present(imagePicker, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        let info = Dictionary(uniqueKeysWithValues: info.map {key, value in (key.rawValue, value)})
        picker.dismiss(animated: true, completion: nil)
        
        let absoluteString = (info[UIImagePickerController.InfoKey.referenceURL.rawValue] as? NSURL)?.absoluteString
        
        if let img = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            let image = img.fixOrientation()
            editImage(image, path: absoluteString)
        }
            
        else if let img = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage {
            let image = img.fixOrientation()
            editImage(image, path: absoluteString)
        }
            
        else if let url = info[UIImagePickerController.InfoKey.mediaURL.rawValue] as? URL {
            let pathString = url.absoluteString
            let img = getVideoThumbnail(url)
            editImage(img, path: pathString)
        }
    }

    func editImage(_ img: UIImage?, path: String?) {
        var image = img
        if let imgg = image {
            if let value = options.resizeWidth {
                image = imgg.resize(width: value)
            }
            
            if let value = options.resizeScale {
                image = imgg.resize(scale: value)
            }
        }
        getImage(image, path)
    }
    
    open func setMediaTypes() {
        
        switch options.mediaType {
        case .image:
            imagePicker.mediaTypes = ["public.image"]
        case .video:
            imagePicker.mediaTypes = ["public.movie"]
        case .all:
            imagePicker.mediaTypes = ["public.image", "public.movie"]
        }
    }
    
    open func setPlayer(_ url: URL) {
        let player = AVPlayer(url: url)
        playerViewController = AVPlayerViewController()
        playerViewController!.player = player
    }
    
    open func playVideo() {
        guard let vc = playerViewController else {return}
        rootViewController.present(vc, animated: true) {
            vc.player!.play()
        }
    }
    
    open func present(_ options: AAImagePickerOptions? = nil, _ completion: @escaping ((UIImage?, String?) -> Void)) {

        if let pickerOptions = options {
            self.options = pickerOptions
        }
        
        let alertController = setupAlertController()
        presentController.present(alertController, animated: true, completion: nil)
        
        self.getImage = { image, url in
            completion(image, url)
        }
    }
    
    func getVideoThumbnail(_ url: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: url , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch let error {
            print("AAImagePicker - Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}


