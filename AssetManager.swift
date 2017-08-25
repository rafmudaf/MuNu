//
//  AssetManager.swift
//  MuNu
//
//  Created by Rafael M Mudafort on 12/23/16.
//  Copyright © 2016 Rafael M Mudafort. All rights reserved.
//

import Foundation
import Photos
import AssetsLibrary

class AssetManager {
    
    private let appName = "MuNu"
    
    private var collection: PHAssetCollection!
    private var assetCollectionPlaceholder: PHObjectPlaceholder!
    
    init() {
        // Make sure we have custom album for this app if haven't already made it
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", appName)
        collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject

        //if we don't have a special album for this app yet then make one
        if collection == nil {
            createAlbum()
        }
    }
    
    private func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest: PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.appName)
            self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
            if success {
                let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [self.assetCollectionPlaceholder.localIdentifier], options: nil)
                self.collection = collectionFetchResult.firstObject
            }
        })
    }
    
    public func addAsset(image: UIImage?, completion: @escaping (Error?) -> Void) {
        
        guard let image = image else {
            return
        }
        
        PHPhotoLibrary.shared().performChanges(
            {
                // Request creating an asset from the image.
                let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                
                // Request editing the album.
                guard let addAssetRequest = PHAssetCollectionChangeRequest(for: self.collection) else {
                    completion(nil)
                    return
                }
                
                // Get a placeholder for the new asset and add it to the album editing request.
                addAssetRequest.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
            },
            completionHandler: { success, error in
                if !success {
                    NSLog("error creating asset: \(String(describing: error))")
                    completion(error)
                }
                completion(nil)
            }
        )
    }
    
    public func addAsset(url: URL?, completion: @escaping (Error?) -> Void) {
        
        guard let url = url else {
            return
        }
        
        PHPhotoLibrary.shared().performChanges(
            {
                // Request creating an asset from the image.
                guard let creationRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url) else {
                    completion(nil)
                    return
                }
                
                // Request editing the album.
                guard let addAssetRequest = PHAssetCollectionChangeRequest(for: self.collection) else {
                    completion(nil)
                    return
                }
                
                // Get a placeholder for the new asset and add it to the album editing request.
                addAssetRequest.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
            },
            completionHandler: { success, error in
                if !success {
                    NSLog("error creating asset: \(String(describing: error))")
                    completion(error)
                }
                completion(nil)
            }
        )
    }
    
    public func locallyStore(image: UIImage?, named basename: String) -> URL? {
        guard let image = image else {
            return nil
        }
        
        guard let data = UIImageJPEGRepresentation(image, 1.0) else {
            return nil
        }
        
        let filepath = getDocumentsDirectory().appendingPathComponent("\(basename).jpg")
        guard (try? data.write(to: filepath)) != nil else {
            return nil
        }
        
        return filepath
    }
    
    public func saveImagesInPhotos(urls: [URL]?) {
        guard let urls = urls else {
            return
        }
        for url in urls {
            addAsset(url: url) { _ in }
        }
    }
    
    public func getImagesFrom(urls: [URL]) -> [UIImage] {
        var images = [UIImage]()
        for url in urls {
            if let image = UIImage(contentsOfFile: url.path) {
                images.append(image)
            }
        }
        return images
    }
    
    public func createAnimatedImage(with images: [UIImage], duration: Double, completion: (_ animatedImage: UIImage?, _ error: NSError?) -> ()) {
        guard let animatedImage = UIImage.animatedImage(with: images, duration: duration) else {
            completion(nil, NSError())
            return
        }
        completion(animatedImage, nil)
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
