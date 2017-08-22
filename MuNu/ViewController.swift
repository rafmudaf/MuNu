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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
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
            guard let frequency = frequency else {
                return
            }
            
            timer = Timer.scheduledTimer(timeInterval: Double(frequency), target: self, selector: #selector(saveCurrentImage), userInfo: nil, repeats: true)
            buttonStartCapturing.setTitle("Stop Capturing", for: .normal)
            capturing = true
            
        } else {
            timer.invalidate()
            buttonStartCapturing.setTitle("Start Capturing", for: .normal)
            capturing = false

//            var images = [UIImage]()
//            for url in imageURLs {
//                print(url.absoluteString)
//                let filemanager = FileManager.default
//                print(filemanager.fileExists(atPath: url.absoluteString))
//                if let image = UIImage(contentsOfFile: url.absoluteString) {
//                    images.append(image)
//                }
//            }

//            print(images.count)
//            gifManager.createGIF(with: images, loopCount: 1, frameDelay: 1.0) { data, error in
//                print(data)
//                print(error)
//            }
        }
    }
    
    func saveCurrentImage() {
        guard let image = imageView.image else {
            return
        }
        assetManager.addAsset(image: image)
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
        imageView.image = image
    }
}
