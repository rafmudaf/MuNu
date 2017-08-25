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
    var frequency: Int?
    var capturing = false
    var imageURLs = [URL]()
    var images = [UIImage]()
    
    let assetManager = AssetManager()
    let gifManager = GifManager()
    var frameExtractor = FrameExtractor()

    var showGif = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        frequency = 1
        startCapturing()
    }
    
    private func configureView() {
        textfieldFrequency.delegate = self
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
            startCapturing()
        } else {
            stopCapturing()
        }
    }
    
    private func startCapturing() {
        guard let frequency = frequency else {
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: Double(frequency), target: self, selector: #selector(saveCurrentImage), userInfo: nil, repeats: true)
        buttonStartCapturing.setTitle("Stop Capturing", for: .normal)
        
        capturing = true
    }
    
    private func stopCapturing() {
        timer.invalidate()
        buttonStartCapturing.setTitle("Start Capturing", for: .normal)
        capturing = false
        
        postProcess()
    }
    
    @objc private func saveCurrentImage() {
        guard let image = imageView.image else {
            return
        }
        
        if let localurl = assetManager.storeLocally(image: image, basename: "\(imageURLs.count)") {
            imageURLs.append(localurl)
        }
        
        if imageURLs.count == 4 {
            stopCapturing()
        }
    }
    
    private func showAnimatedImage(animatedImage: UIImage) {
        timer = Timer.scheduledTimer(timeInterval: animatedImage.duration, target: self, selector: #selector(showCamera), userInfo: nil, repeats: false)
        showGif = true
        imageView.image = animatedImage
    }
    
    @objc private func showCamera() {
        showGif = false
    }
    
    private func postProcess() {
        
//        assetManager.saveImagesInPhotos(urls: imageURLs)
        
        let images = assetManager.loadImagesFromUrls(urls: imageURLs)
        assetManager.createAnimatedImage(with: images, duration: 1.0) { (image, error) in
            guard let animatedImage = image else {
                print("no image")
                return
            }
            showAnimatedImage(animatedImage: animatedImage)
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        
        if text.characters.count == 0 {
            frequency = nil
            textField.text = "Frequency"
        } else {
            frequency = Int(text)
            textField.text?.append(" s")
        }
    }
}

extension ViewController: FrameExtractorDelegate {
    func captured(image: UIImage) {
        if !showGif {
            imageView.image = image
        }
    }
}
