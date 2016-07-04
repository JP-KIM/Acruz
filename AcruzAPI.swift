//
//  AcruzAPI.swift
//  Acruz
//
//  Created by 김정표 on 2016. 7. 4..
//  Copyright © 2016년 Acruz corp. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class AcruzAPI {
    
    var storageReferenceURL: String!
    var ref: FIRDatabaseReference!
    
    init(storageReferenceURL: String) {
        self.storageReferenceURL = storageReferenceURL
        ref = FIRDatabase.database().reference()
    }
    
    
    func uploadPhoto(path: String, image: UIImage, completion: (String?, NSError?) -> Void) {
        // Making reference
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL(storageReferenceURL)
        let fileRef = storageRef.child(path)
        
        // Initialize metadata
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Making NSData
        let imageData: NSData = UIImageJPEGRepresentation(image, 1)!
        let rate: CGFloat = 100000/(CGFloat)(imageData.length*4)
        print("length:\(imageData.length), rate:\(rate)")
        let uploadData: NSData = UIImageJPEGRepresentation(image, rate)!
        
        fileRef.putData(uploadData, metadata: metadata) { metadata, error in
            if (error != nil) {
                completion(nil, error)
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                completion(path, nil)
            }
        }
    }
    
    func downloadPhoto(path: String, completion: (UIImage?, NSError?) -> Void) {
        // TODO:: image cache for doubly download the photo
        
        // Making reference
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL(storageReferenceURL)
        let fileRef = storageRef.child(path)
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        fileRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                // Data for "images/island.jpg" is returned
                // ... let islandImage: UIImage! = UIImage(data: data!)
                completion(UIImage(data: data!), nil)
            }
        }
    }
}