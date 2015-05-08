//
//  Actor.swift
//  The Movie DB
//
//  Created by Jonathan Pacheco on 7/05/15.
//  Copyright (c) 2015 ArandaSoft. All rights reserved.
//

import UIKit
import Mantle

class Actor: MTLModel, MTLJSONSerializing {
   
    var character:      String?
    var creditId:       String?
    var actorId:        NSNumber?
    var name:           String?
    var profilePath:    String?
    var order:          NSNumber?
    
    static func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["character":    "character",
                "creditId":     "credit_id",
                "actorId":      "id",
                "name":         "name",
                "profilePath":  "profile_path",
                "order":        "order"]
    }
    
    static func profilePathJSONTransformer() -> NSValueTransformer {
        return imageBaseTransformer()
    }
    
}
