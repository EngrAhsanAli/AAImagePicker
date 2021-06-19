//
//  AAImagePicker+Helper.swift
//  AAImagePicker+Helper
//
//  Created by Engr. Ahsan Ali on 26/03/2019.
//  Copyright (c) 2019 AA-Creations. All rights reserved.
//

import AVFoundation

open class AAImagePickerOptions: NSObject {
    
    open var allowsEditing = false
    open var rotateCameraImage: CGFloat = 0
    open var resizeWidth: CGFloat?
    open var resizeScale: CGFloat?
    open var presentController: UIViewController?
    
    open var cancelText = "Cancel"
    open var chooseFromLibraryText = "Choose From Library"
    open var chooseFromPhotoRollText = "Choose From Photo Roll"
    open var takePhotoText = "Take Photo"
    open var takeVideoText = "Take Video"
    open var viewPhotoText = "View"
    
    open var allowView = true
    open var allowsPhoto = true
    open var allowsVideo = true
    open var allowsTake = true
    open var allowsSelectFromLibrary = true
    open var iPadUsesFullScreenCamera = false
    open var defaultsToFrontCamera = false
    open var presentingBarButtonItem: UIBarButtonItem? = nil
    open var presentingView: UIView? = nil
    open var presentingRect: CGRect? = nil
    open var presentingTabBar: UITabBar? = nil

}

public enum AAResizer {
    case width, scale
}

extension UIImage {
    
    // MARK:- Credits: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
    
    func fixOrientation() -> UIImage {
        
        // No-op if the orientation is already correct
        if ( self.imageOrientation == UIImage.Orientation.up ) {
            return self;
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        if ( self.imageOrientation == UIImage.Orientation.down || self.imageOrientation == UIImage.Orientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        }
        
        if ( self.imageOrientation == UIImage.Orientation.left || self.imageOrientation == UIImage.Orientation.leftMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
        }
        
        if ( self.imageOrientation == UIImage.Orientation.right || self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-Double.pi / 2));
        }
        
        if ( self.imageOrientation == UIImage.Orientation.upMirrored || self.imageOrientation == UIImage.Orientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if ( self.imageOrientation == UIImage.Orientation.leftMirrored || self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
                                       bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                       space: self.cgImage!.colorSpace!,
                                       bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!;
        
        ctx.concatenate(transform)
        
        if ( self.imageOrientation == UIImage.Orientation.left ||
            self.imageOrientation == UIImage.Orientation.leftMirrored ||
            self.imageOrientation == UIImage.Orientation.right ||
            self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.height,height: self.size.width))
        } else {
            ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height))
        }
        
        // And now we just create a new UIImage from the drawing context and return it
        return UIImage(cgImage: ctx.makeImage()!)
    }
    
    func resize(scale: CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width*scale, height: size.height*scale)))
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    func resize(width: CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
}



extension UIApplication {
    static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        } else {
            return UIApplication.shared.delegate?.window ?? nil
        }
    }
}
