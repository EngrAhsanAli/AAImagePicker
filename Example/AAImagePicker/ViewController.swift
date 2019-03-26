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
        options.mediaType = .video
        imagePicker.present (options) { (image, path) in
            self.imageView.image = image
            self.imagePicker.setPlayer(URL(string: path!)!)
            self.imagePicker.playVideo()
        }
    }
    
    @IBAction func showPickerAction(_ sender: Any) {
        
        let options = AAImagePickerOptions()
        options.mediaType = .image
        imagePicker.present (options) { (image, path) in
            self.imageView.image = image
            print(path)
        }
    }
}

