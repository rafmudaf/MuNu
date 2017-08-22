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
    
    let appName = "MuNu"
    
    var assetCollection: PHAssetCollection!
    var assetThumbnailSize: CGSize!
    
//    var photosAsset: PHFetchResult<PHAsset>!
    var collection: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    
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
    
    func createAlbum() {
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
    
    func addAsset(image: UIImage?) {
        
        guard let image = image else {
            return
        }
        
        PHPhotoLibrary.shared().performChanges(
            {
                // Request creating an asset from the image.
                let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                
                // Request editing the album.
                guard let addAssetRequest = PHAssetCollectionChangeRequest(for: self.collection) else {
                    return
                }
                
                // Get a placeholder for the new asset and add it to the album editing request.
                addAssetRequest.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
            },
            completionHandler: { success, error in
                if !success {
                    NSLog("error creating asset: \(String(describing: error))")
                }
            }
        )
    }
}
