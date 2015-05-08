//
//  TVShow.swift
//  The Movie DB
//
//  Created by Jonathan Pacheco on 5/05/15.
//  Copyright (c) 2015 ArandaSoft. All rights reserved.
//

import UIKit
import Mantle

class TVShow: MTLModel, MTLJSONSerializing {

    var adult:         NSNumber?
    var backdropPath:  String?
    var showId:        NSNumber?
    var originalTitle: String?
    var releaseDate:   String?
    var posterPath:    String?
    var popularity:    NSNumber?
    var title:         String?
    var name:          String?
    var video:         NSNumber?
    var voteAverage:   NSNumber?
    var voteCount:     NSNumber?
    
    static func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["showId":           "id",
                "backdropPath":     "backdrop_path",
                "originalTitle":    "original_title",
                "releaseDate":      "release_date",
                "posterPath":       "poster_path",
                "popularity":       "popularity",
                "title":            "title",
                "video":            "video",
                "voteAverage":      "vote_average",
                "voteCount":        "vote_count",
                "name":             "name"]
    }
    
    static func backdropPathJSONTransformer() -> NSValueTransformer! {
        return imageBaseTransformer()
    }
    
    static func posterPathJSONTransformer() -> NSValueTransformer! {
        return imageBaseTransformer()
    }

}
