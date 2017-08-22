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
        configureView()
    }
    
    private func configureView() {
        frameExtractor.delegate = self
        addDoneButtonOnKeyboard()
    }
    
    private func addDoneButtonOnKeyboard() {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        
        textfieldFrequency.inputAccessoryView = doneToolbar
    }
    
    @objc private func doneButtonAction() {
        textfieldFrequency.resignFirstResponder()
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
