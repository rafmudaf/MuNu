//
//  FrameExtractor.swift
//  MuNu
//
//  Created by Rafael M Mudafort on 8/21/17.
//  Copyright © 2017 Rafael M Mudafort. All rights reserved.
//

// adapted heavily from https://medium.com/ios-os-x-development/ios-camera-frames-extraction-d2c0f80ed05a

import UIKit
import AVFoundation

protocol FrameExtractorDelegate: class {
    func captured(image: UIImage)
}

class FrameExtractor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "session queue")
    private var permissionGranted = false
    
    private let position = AVCaptureDevicePosition.back
    private let quality = AVCaptureSessionPreset1920x1080
    private let context = CIContext()
    
    weak var delegate: FrameExtractorDelegate?
    
    override init() {
        super.init()
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
    }
    
    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }

    private func configureSession() {
        guard permissionGranted else {
            return
        }
        
        captureSession.sessionPreset = quality
        guard let captureDevice = selectCaptureDevice() else {
            return
        }
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.focusMode = .continuousAutoFocus
            captureDevice.whiteBalanceMode = .continuousAutoWhiteBalance
            captureDevice.exposureMode = .continuousAutoExposure
            captureDevice.unlockForConfiguration()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        
        guard captureSession.canAddInput(captureDeviceInput) else {
            return
        }
        
        captureSession.addInput(captureDeviceInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        guard captureSession.canAddOutput(videoOutput) else {
            return
        }
        captureSession.addOutput(videoOutput)
        
        guard let connection = videoOutput.connection(withMediaType: AVFoundation.AVMediaTypeVideo) else {
            return
        }
        guard connection.isVideoOrientationSupported else {
            return
        }
        guard connection.isVideoMirroringSupported else {
            return
        }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = position == .front
    }
    
    private func selectCaptureDevice() -> AVCaptureDevice? {
        let deviceTypes = [AVCaptureDeviceType.builtInWideAngleCamera]
        let mediaType = AVMediaTypeVideo
        guard let devices = AVCaptureDeviceDiscoverySession(deviceTypes: deviceTypes, mediaType: mediaType, position: position) else {
            return nil
        }
        
        return devices.devices.filter { ($0 as AnyObject).hasMediaType(AVMediaTypeVideo) && ($0 as AnyObject).position == position }.first
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else {
            return
        }
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.captured(image: uiImage)
        }
    }
}
