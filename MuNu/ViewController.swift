//
//  ViewController.swift
//  MuNu
//
//  Created by Rafael M Mudafort on 11/19/16.
//  Copyright © 2016 Rafael M Mudafort. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonSaveImage: UIButton!
    @IBOutlet weak var textfieldFrequency: UITextField!
    @IBOutlet weak var buttonStartCapturing: UIButton!
    
    let captureSession = AVCaptureSession()
    var captureDevice: AVCaptureDevice?
    let output = AVCaptureVideoDataOutput()
    let stillImageOutput = AVCapturePhotoOutput()

    var timer = Timer()
    var capturing = false
    
    var imageURLs = [URL]()
    var images = [UIImage]()
    
    let assetManager = AssetManager()

    var frameExtractor = FrameExtractor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frameExtractor.delegate = self
    }
        
    }
    
    }
    
    @IBAction func saveButtonTouchUp(_ sender: Any) {
        saveCurrentImage()
    }
    
    @IBAction func startButtonTouchUp(_ sender: Any) {
        if !capturing {
            if let freq = Double(textfieldFrequency.text!) {
                timer = Timer.scheduledTimer(timeInterval: freq, target: self, selector: #selector(saveCurrentImage), userInfo: nil, repeats: true)
                buttonStartCapturing.setTitle("Stop Capturing", for: .normal)
                capturing = true
            }
        } else {
            timer.invalidate()
            buttonStartCapturing.setTitle("Start Capturing", for: .normal)
            capturing = false
        }
    }
    
    func saveCurrentImage() {
        guard let image = imageView.image else {
            return
        }
        assetManager.addAsset(image: image)
    }
}

extension ViewController: FrameExtractorDelegate {
    func captured(image: UIImage) {
        imageView.image = image
    }
}
