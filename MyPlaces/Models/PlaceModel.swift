//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Alexey Efimov on 15/11/2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import RealmSwift
import CloudKit

class Place: Object {
    
    @objc dynamic var placeID = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date()
    @objc dynamic var rating = 0.0
    
    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Double) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
    }
    
    convenience init(record: CKRecord) {
        self.init()
        
        guard let possibleImage = record.value(forKey: "imageData") else { return }
        let imageAsset = possibleImage as! CKAsset
        guard let imageData = try? Data.init(contentsOf: imageAsset.fileURL!) else { return }
        
        self.placeID = record.value(forKey: "placeID") as! String
        self.name = record.value(forKey: "name") as! String
        self.location = record.value(forKey: "location") as? String
        self.type = record.value(forKey: "type") as? String
        self.imageData = imageData
        self.rating = record.value(forKey: "rating") as! Double
    }
    
    static override func primaryKey() -> String? {
        "placeID"
    }
}
