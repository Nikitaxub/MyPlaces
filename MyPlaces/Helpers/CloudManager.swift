//
//  CloudManager.swift
//  MyPlaces
//
//  Created by nik on 14.02.2024.
//  Copyright © 2024 Alexey Efimov. All rights reserved.
//

import UIKit
import CloudKit

class CloudManager {
    
    private static let privateCloudDatabase = CKContainer(identifier: "iCloud.com.nikitaxub.MyPlaces").privateCloudDatabase
    
    static func saveDataToCloud(place: Place, with image: UIImage) {
        
        let (image, url) = prepareImageToSaveToCloud(place: place, image: image)
        
        guard let imageAsset = image, let imageURL = url else { return }
        
        let record = CKRecord(recordType: "Place")
        record.setValue(place.name, forKey: "name")
        record.setValue(place.location, forKey: "location")
        record.setValue(place.type, forKey: "type")
        record.setValue(place.rating, forKey: "rating")
        record.setValue(imageAsset, forKey: "imageData")
        
        privateCloudDatabase.save(record) { (_, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            deleteTempImage(imageURL: imageURL)
        }
    }
    
    static func fetchDataFromCloud(closure: @escaping (Place) -> ()) {
        
        let query = CKQuery(recordType: "Place", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        privateCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let records = records else { return }
            
            records.forEach { record in
                let newPlace = Place(record: record)
                
                DispatchQueue.main.async {
                    closure(newPlace)
                }
            }
        }
    }
    
    // MARK: Private Methods
    private static func prepareImageToSaveToCloud(place: Place, image: UIImage) -> (CKAsset?, URL?) {
        
        let scale = image.size.width > 1080 ? 1080 / image.size.width : 1
        let scaleImage = UIImage(data: image.pngData()!, scale: scale)
        let imageFilePath = NSTemporaryDirectory() + place.name
        let imageURL = URL(fileURLWithPath: imageFilePath)
        
        guard let dataToPath = scaleImage?.jpegData(compressionQuality: 1) else { return (nil, nil) }
        
        do {
            try dataToPath.write(to: imageURL, options: .atomic)
        } catch {
            print(error.localizedDescription)
        }
        
        let imageAsset = CKAsset(fileURL: imageURL)
        
        return (imageAsset, imageURL)
    }
    
    private static func deleteTempImage(imageURL: URL) {
        do {
            try FileManager.default.removeItem(at: imageURL)
        } catch {
            print(error.localizedDescription)
        }
    }
}