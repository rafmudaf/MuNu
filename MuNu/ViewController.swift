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
    var frequency: Double?
    var capturing = false
    var imageURLs = [URL]()
    
    var frameExtractor = FrameExtractor()
    let assetManager = AssetManager()
    
    var showGif = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        startCapturing()
    }
    
    private func configureView() {
        textfieldFrequency.delegate = self
        frameExtractor.delegate = self
        addDoneButtonOnKeyboard()
    }
    
    private func addDoneButtonOnKeyboard() {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = .blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(keyboardDone))
        
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        
        textfieldFrequency.inputAccessoryView = doneToolbar
    }
    
    @objc private func keyboardDone() {
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
        
        timer = Timer.scheduledTimer(timeInterval: frequency, target: self, selector: #selector(saveCurrentImage), userInfo: nil, repeats: true)
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
        DispatchQueue.global(qos: .background).async {
            guard let image = self.imageView.image else {
                return
            }
            
            if let localurl = self.assetManager.locallyStore(image: image, named: "\(self.imageURLs.count)") {
                self.imageURLs.append(localurl)
            }
        }
    }
    
    private func deleteLocallyStoredImages() {
        for url in imageURLs {
            assetManager.locallyRemove(itemAt: url)
        }
        imageURLs = [URL]()
    }
    
    private func showAnimatedImage(animatedImage: UIImage) {
        timer = Timer.scheduledTimer(timeInterval: 2*animatedImage.duration, target: self, selector: #selector(showCamera), userInfo: nil, repeats: false)
        showGif = true
        imageView.image = animatedImage
    }
    
    @objc private func showCamera() {
        deleteLocallyStoredImages()
        showGif = false
    }
    
    private func postProcess() {
        
        // TODO: give users the option to save all images
        // assetManager.saveImagesInPhotos(urls: imageURLs)
        
        let images = assetManager.getImagesFrom(urls: imageURLs)
        
        assetManager.createVideo(with: images, framerate: 5) { (url, error) in
            guard let videoURL = url else {
                print(error as Any)
                return
            }
            
            self.assetManager.addVideoAsset(url: videoURL) { (error) in
                print(error as Any)
            }
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
            frequency = Double(text)
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
