//
//  ViewController.swift
//  AAImagePicker
//
//  Created by Engr. Ahsan Ali on 01/04/2017.
//  Copyright (c) 2017 AA-Creations. All rights reserved.
//

import UIKit
import AAImagePicker

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = AAImagePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showVideoPickerAction(_ sender: Any) {
        let options = AAImagePickerOptions()
        options.allowsVideo = true
        options.allowsPhoto = false
        imagePicker.didGetVideo = { (image, path) in
            self.imageView.image = image
            self.imagePicker.setPlayer(path)
            self.imagePicker.playVideo()
        }
        imagePicker.present(with: options)
    }
    
    @IBAction func showPickerAction(_ sender: Any) {
        
        let options = AAImagePickerOptions()
        options.allowsVideo = false
        options.allowsPhoto = true
        imagePicker.viewImageCallback = {
            
            guard let image = self.imageView.image else { return }
            
            let options = AAImageViewOptions.init(image: image, imageMode: .aspectFill, imageHD: nil, fromView: self.imageView)

            let imageViewer = AAImageViewController(imageInfo: options)
            self.present(imageViewer, animated: true, completion: nil)
            
        }
        imagePicker.didGetPhoto = { (image, path) in
            self.imageView.image = image
            print(path)
        }
        imagePicker.present(with: options)
    }
}

