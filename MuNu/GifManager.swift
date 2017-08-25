//
//  GifManager.swift
//  MuNu
//
//  Created by Rafael M Mudafort on 12/24/16.
//  Copyright © 2016 Rafael M Mudafort. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices

class GifManager {
    
    init() {
    }
    
    func createGIF(with images: [UIImage], loopCount: Int = 0, frameDelay: Double, completion: (_ url: URL?, _ error: NSError?) -> ()) {
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: loopCount]]
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: frameDelay]]
        
        let documentsDirectory = NSTemporaryDirectory()
        let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("animated.gif")

        let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeGIF, images.count, nil)
        CGImageDestinationSetProperties(destination!, fileProperties as CFDictionary?)
            
        for i in 0..<images.count {
            CGImageDestinationAddImage(destination!, images[i].cgImage!, frameProperties as CFDictionary?)
        }
        
        if CGImageDestinationFinalize(destination!) {
            completion(url, nil)
        } else {
            completion(nil, NSError())
        }
    }
}
