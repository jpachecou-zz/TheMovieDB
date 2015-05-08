//
//  Season.swift
//  The Movie DB
//
//  Created by Jonathan Pacheco on 6/05/15.
//  Copyright (c) 2015 ArandaSoft. All rights reserved.
//

import UIKit
import Mantle

class Season: MTLModel, MTLJSONSerializing {
   
    var airDate:        String?
    var seasonId:       NSNumber?
    var episodeCount:   NSNumber?
    var posterPath:     String?
    var seasonNumber:   NSNumber?
    var episodes:       Array<Episode>?
    
    static func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["airDate":      "air_date",
                "episodeCount": "episode_count",
                "seasonId":     "id",
                "posterPath":   "poster_path",
                "seasonNumber": "season_number"]
    }
    
    static func posterPathJSONTransformer() -> NSValueTransformer! {
        return imageBaseTransformer()
    }
    
    /*
    "air_date": "2012-07-15",
    "episode_count": 16,
    "id": 3578,
    "poster_path": "/r3z70vunihrAkjILQKWHX0G2xzO.jpg",
    "season_number": 5
    */
}
