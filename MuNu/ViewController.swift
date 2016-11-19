//
//  ViewController.swift
//  MuNu
//
//  Created by Rafael M Mudafort on 11/19/16.
//  Copyright © 2016 Rafael M Mudafort. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit
import Photos
import AssetsLibrary

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UITextFieldDelegate {
    
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
    
    var glContext: EAGLContext!
    var glView: GLKView!
    var ciContext: CIContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: .UIDeviceOrientationDidChange, object: nil)
        
        let devices = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera],
                                                      mediaType: AVMediaTypeVideo,
                                                      position: .back)
        for device in devices!.devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if (device.position == AVCaptureDevicePosition.back) {
                    captureDevice = device
                }
            }
        }
        
        if captureDevice != nil {
            beginSession()
        }
        
        glContext = EAGLContext(api: .openGLES2)
        glView = GLKView(frame: view.frame, context: glContext!)
        ciContext = CIContext(eaglContext: glContext!)
    }
    
    func rotated() {
        let connection = output.connection(withMediaType: AVFoundation.AVMediaTypeVideo)!
        connection.videoOrientation = self.AVOrientationFromDeviceOrientation(deviceOrientation: UIDevice.current.orientation)
    }
    
    func AVOrientationFromDeviceOrientation(deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        if (deviceOrientation == UIDeviceOrientation.landscapeLeft) { return AVCaptureVideoOrientation.landscapeRight }
        else if (deviceOrientation == UIDeviceOrientation.landscapeRight) { return AVCaptureVideoOrientation.landscapeLeft }
        else if (deviceOrientation == UIDeviceOrientation.portrait) { return AVCaptureVideoOrientation.portrait }
        else if (deviceOrientation == UIDeviceOrientation.portraitUpsideDown) { return AVCaptureVideoOrientation.portraitUpsideDown }
        else { return AVCaptureVideoOrientation.portrait}
    }
    
    func beginSession() {
        do {
            configureDevice()
            
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            
            // although we don't use this, it's required to get captureOutput invoked
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            view.layer.addSublayer(previewLayer!)
            
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate"))
            captureSession.addOutput(output)
            
            captureSession.startRunning()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.focusMode = .locked
                device.unlockForConfiguration()
            } catch let error as NSError {
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)
        let uiimage = UIImage(ciImage: cameraImage)
        
        updateUIView(image: uiimage)
    }
    
    func updateUIView(image: UIImage) {
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
    
    @IBAction func saveButtonTouchUp(_ sender: Any) {
        saveImage()
    }
    
    @IBAction func startButtonTouchUp(_ sender: Any) {
        if !capturing {
            if let freq = Double(textfieldFrequency.text!) {
                timer = Timer.scheduledTimer(timeInterval: freq, target: self, selector: #selector(saveImage), userInfo: nil, repeats: true)
                buttonStartCapturing.setTitle("Stop Capturing", for: .normal)
                capturing = true
            }
        } else {
            timer.invalidate()
            buttonStartCapturing.setTitle("Start Capturing", for: .normal)
            capturing = false
        }
    }
    
    func saveImage() {
        let imageToSave = imageView.image?.ciImage
        let softwareContext = CIContext(options:[kCIContextUseSoftwareRenderer: true])
        let cgimg = softwareContext.createCGImage(imageToSave!, from: (imageToSave?.extent)!)
        let library = ALAssetsLibrary()
        library.writeImage(toSavedPhotosAlbum: cgimg, metadata:imageToSave!.properties, completionBlock:nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}