//
//  Episode.swift
//  The Movie DB
//
//  Created by Jonathan Pacheco on 7/05/15.
//  Copyright (c) 2015 ArandaSoft. All rights reserved.
//

import UIKit
import Mantle

class Episode: MTLModel, MTLJSONSerializing {
   
    var airDate:        String?
    var episodeNumber:  NSNumber?
    var name:           String?
    var overview:       String?
    var episodeId:      NSNumber?
    var seasonNumber:   NSNumber?
    
    static func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["airDate":          "air_date",
                "episodeNumber":    "episode_number",
                "name":             "name",
                "overview":         "overview",
                "episodeId":        "id",
                "seasonNumber":     "season_number"]
    }
    
}
