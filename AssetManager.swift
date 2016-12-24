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
    
    var assetCollection: PHAssetCollection!
    var albumFound: Bool = false
    var assetThumbnailSize: CGSize!
    
//    var photosAsset: PHFetchResult<PHAsset>!
    var collection: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    
    init() {
        //Make sure we have custom album for this app if haven't already
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "MY_APP_ALBUM_NAME")
        collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject

        //if we don't have a special album for this app yet then make one
        if collection == nil {
            createAlbum()
        }
    }
    
    func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest: PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "MY_APP_ALBUM_NAME")
            self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
            if success {
                let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [self.assetCollectionPlaceholder.localIdentifier], options: nil)
                self.collection = collectionFetchResult.firstObject
            }
        })
    }
    
    func saveImage(image: UIImage, completion: @escaping (URL?, Error?) -> Void) {
        let ciimage = image.ciImage!
        let softwareContext = CIContext(options:[kCIContextUseSoftwareRenderer: true])
        let cgimage = softwareContext.createCGImage(ciimage, from: (ciimage.extent))
        let library = ALAssetsLibrary()
        library.writeImage(toSavedPhotosAlbum: cgimage, metadata: ciimage.properties) {url, error in
            completion(url, error)
        }
    }
    
//    func saveImage(image: UIImage) {
//        
//        let data = UIImagePNGRepresentation(UIImage(cgImage: image.cgImage!))!
//        let filename = getDocumentsDirectory().appendingPathComponent("copy.png")
//        do {
//            try data.write(to: filename)
//            
//            //save the image to Photos
//            PHPhotoLibrary.shared().performChanges({
//                //            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
//                let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: filename)!
//                let assetPlaceholder = assetRequest.placeholderForCreatedAsset!
//                
//                //            self.photosAsset = PHAsset.fetchAssets(in: self.collection, options: nil)
//                let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.collection)
//                print(image)
//                print(self.collection.canPerform(PHCollectionEditOperation.addContent))
//                
//                albumChangeRequest?.addAssets([assetPlaceholder] as NSArray)
//                
//            }, completionHandler: { success, error in
//                
//                if success {
//                    print("added video to album")
//                } else if error != nil {
//                    print("handle error since couldn't save video\n\(error)")
//                }
//                
//            })
//        } catch {
//            
//        }
//    }
//    
//    func getDocumentsDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentsDirectory = paths[0]
//        return documentsDirectory
//    }
}
