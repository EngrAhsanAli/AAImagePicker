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
import MobileCoreServices

open class AAImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public lazy var imagePicker: UIImagePickerController = {
        [unowned self] in
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        if #available(iOS 11.0, *) {
            imagePicker.videoExportPreset = AVAssetExportPresetPassthrough
            imagePicker.imageExportPreset = .compatible
        }
        return imagePicker
    }()
    
    private func topViewController(rootViewController: UIViewController) -> UIViewController {
        var rootViewController = UIApplication.keyWindow!.rootViewController!
        repeat {
            guard let presentedViewController = rootViewController.presentedViewController else {
                return rootViewController
            }
            
            if let navigationController = rootViewController.presentedViewController as? UINavigationController {
                rootViewController = navigationController.topViewController ?? navigationController
                
            } else {
                rootViewController = presentedViewController
            }
        } while true
    }
    
    public var playerViewController: AVPlayerViewController?
    private var alertController: UIAlertController? = nil
    
    var options: AAImagePickerOptions = AAImagePickerOptions()
    var getImage: ((UIImage?, String?) -> Void)!
        
    open var didGetPhoto: ((UIImage, URL) -> ())?
    
    open var didGetVideo: ((UIImage?, URL) -> ())?
        
    open var didDeny: (() -> ())?
    
    open var didCancel: (() -> ())?
    
    open var viewImageCallback: (() -> ())?
    
    open var didFail: (() -> ())?
    
    var presentController : UIViewController {
        return (options.presentController ?? rootViewController)
    }
    
    var rootViewController: UIViewController {
        guard let root = UIApplication.keyWindow?.rootViewController else {
            fatalError("AAImagePicker - Application key window not found. Please check UIWindow in AppDelegate.")
        }
        return root
    }
    
    func editImage(_ img: UIImage) -> UIImage {
        var image = img
        if let value = options.resizeWidth {
            image = img.resize(width: value)
        }
        
        if let value = options.resizeScale {
            image = img.resize(scale: value)
        }
        return image
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


extension AAImagePicker {
    
    /// Presents the user with an option to take a photo or choose a photo from the library
    open func present(with pickerOptions: AAImagePickerOptions? = nil) {
        
        if let options = pickerOptions {
            self.options = options
        }
        
        var titleToSource = [(String, UIImagePickerController.SourceType)]()
        
        if options.allowsTake && UIImagePickerController.isSourceTypeAvailable(.camera) {
            if options.allowsPhoto {
                titleToSource.append((options.takePhotoText, .camera))
            }
            if options.allowsVideo {
                titleToSource.append((options.takeVideoText, .camera))
            }
        }
        if options.allowsSelectFromLibrary {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                titleToSource.append((options.chooseFromLibraryText, .photoLibrary))
            } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                titleToSource.append((options.chooseFromPhotoRollText, .savedPhotosAlbum))
            }
        }
        
        guard titleToSource.count > 0 else {
            return
        }
        
        var popOverPresentRect : CGRect = options.presentingRect ?? CGRect(x: 0, y: 0, width: 1, height: 1)
        if popOverPresentRect.size.height == 0 || popOverPresentRect.size.width == 0 {
            popOverPresentRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
        
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        titleToSource.forEach { (title, source) in
            let action = UIAlertAction(title: title, style: .default) {
                (UIAlertAction) -> Void in
                self.imagePicker.sourceType = source
                if source == .camera && self.options.defaultsToFrontCamera && UIImagePickerController.isCameraDeviceAvailable(.front) {
                    self.imagePicker.cameraDevice = .front
                }
                // set the media type: photo or video
                self.imagePicker.allowsEditing = self.options.allowsEditing
                var mediaTypes = [String]()
                if self.options.allowsPhoto {
                    mediaTypes.append(String(kUTTypeImage))
                }
                if self.options.allowsVideo {
                    mediaTypes.append(String(kUTTypeMovie))
                }
                self.imagePicker.mediaTypes = mediaTypes
                
                var popOverPresentRect: CGRect = self.options.presentingRect ?? CGRect(x: 0, y: 0, width: 1, height: 1)
                if popOverPresentRect.size.height == 0 || popOverPresentRect.size.width == 0 {
                    popOverPresentRect = CGRect(x: 0, y: 0, width: 1, height: 1)
                }
                let topVC = self.topViewController(rootViewController: self.presentController)
                
                if UI_USER_INTERFACE_IDIOM() == .phone || (source == .camera && self.options.iPadUsesFullScreenCamera) {
                    topVC.present(self.imagePicker, animated: true, completion: nil)
                } else {
                    self.imagePicker.modalPresentationStyle = .popover
                    self.imagePicker.popoverPresentationController?.sourceRect = popOverPresentRect
                    topVC.present(self.imagePicker, animated: true, completion: nil)
                }
                
            }
            alertController!.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: options.cancelText, style: .cancel) {
            (UIAlertAction) -> Void in
            self.didCancel?()
        }
        alertController!.addAction(cancelAction)
        
        if options.allowView, let viewImage = self.viewImageCallback {
            let viewAction = UIAlertAction(title: options.viewPhotoText, style: .default) {
                (UIAlertAction) -> Void in
                viewImage()
            }
            alertController!.addAction(viewAction)
        }
        
        let topVC = topViewController(rootViewController: presentController)
        
        alertController?.modalPresentationStyle = .popover
        if let presenter = alertController!.popoverPresentationController {
            presenter.sourceView = options.presentingView
            if let presentingRect = options.presentingRect {
                presenter.sourceRect = presentingRect
            }
        }
        topVC.present(alertController!, animated: true, completion: nil)
    }
    
    open func dismiss() {
        alertController?.dismiss(animated: true, completion: nil)
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}

extension AAImagePicker {
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        UIApplication.shared.isStatusBarHidden = true
        let absoluteString = (info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.referenceURL.rawValue)] as? NSURL)?.absoluteString
        
        let _url = URL(string: absoluteString!)!
        
        switch info[.mediaType] as! CFString {
        case kUTTypeImage:
            
            let imageToSave: UIImage
            if let editedImage = info[.editedImage] as? UIImage {
                imageToSave = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                imageToSave = originalImage
            } else {
                self.didCancel?()
                return
            }
            
            let image = self.editImage(imageToSave)
            self.didGetPhoto?(image, _url)
            
            if UI_USER_INTERFACE_IDIOM() == .pad {
                self.imagePicker.dismiss(animated: true)
            }
            
        case kUTTypeMovie:
            
            let url = info[.mediaURL] as! URL

            let img = getVideoThumbnail(_url)
            self.didGetVideo?(img, url)
            
        default: break
            
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    /// Conformance for image picker delegate
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        UIApplication.shared.isStatusBarHidden = true
        picker.dismiss(animated: true, completion: nil)
        self.didDeny?()
    }
}
