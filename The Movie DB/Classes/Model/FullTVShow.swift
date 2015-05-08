//
//  FullTVShow.swift
//  The Movie DB
//
//  Created by Jonathan Pacheco on 6/05/15.
//  Copyright (c) 2015 ArandaSoft. All rights reserved.
//

import UIKit
import Mantle

class FullTVShow: MTLModel, MTLJSONSerializing {
    
    var actors:             Array<Actor>?
    var backdropPath:       String?
    var createdBy:          String?
    var genres:             String?
    var showId:             NSNumber?
    var name:               String?
    var posterPath:         String?
    var seasons:            Array<Season>?
    
    static func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["backdropPath":    "backdrop_path",
                "createdBy":        "created_by",
                "genres":           "genres",
                "showId":           "id",
                "name":             "name",
                "posterPath":       "poster_path",
                "seasons":          "seasons"]
    }
    
    static func genresJSONTransformer() -> NSValueTransformer! {
        return joinNamesFromArrayJSONTransformer()
    }
    
    static func createdByJSONTransformer() -> NSValueTransformer! {
        return joinNamesFromArrayJSONTransformer()
    }
    
    static func joinNamesFromArrayJSONTransformer() -> NSValueTransformer {
        return MTLValueTransformer(usingForwardBlock: { (value, _, _) in
            var genresString = ""
            if let genres = value as? Array<Dictionary<NSObject, AnyObject>> {
                for genre in genres {
                    let string = genre["name"] as! String
                    genresString += genresString.isEmpty ? string : ", \(string)"
                }
            }
            return genresString
        })
    }
    
    static func seasonsJSONTransformer() -> NSValueTransformer! {
        return MTLValueTransformer(usingForwardBlock: { (value, _, _) in
            let season = MTLJSONAdapter.modelsOfClass(Season.classForCoder(), fromJSONArray: value as! [AnyObject]!, error: nil)
            return season
        })
    }
    
    static func backdropPathJSONTransformer() -> NSValueTransformer! {
        return imageBaseTransformer()
    }
    
    static func posterPathJSONTransformer() -> NSValueTransformer! {
        return imageBaseTransformer()
    }
    
    func actorsNames() -> String {
        var actorsNames = ""
        if let _actors = actors {
            for actor in _actors {
                actorsNames += actorsNames.isEmpty ? validateString(actor.name) : ", \(validateString(actor.name))"
            }
        }
        return actorsNames
    }
    
}

/*

{
"backdrop_path": "/eSzpy96DwBujGFj0xMbXBcGcfxX.jpg",
"created_by": [
{
"id": 66633,
"name": "Vince Gilligan",
"profile_path": "/rLSUjr725ez1cK7SKVxC9udO03Y.jpg"
}
],
"episode_run_time": [
45,
47
],
"first_air_date": "2008-01-19",
"genres": [
{
"id": 18,
"name": "Drama"
}
],
"homepage": "http://www.amctv.com/shows/breaking-bad",
"id": 1396,
"in_production": false,
"languages": [
"en",
"de",
"ro",
"es",
"fa"
],
"last_air_date": "2013-09-29",
"name": "Breaking Bad",
"networks": [
{
"id": 174,
"name": "AMC"
}
],
"number_of_episodes": 62,
"number_of_seasons": 5,
"origin_country": [
"US"
],
"original_language": "en",
"original_name": "Breaking Bad",
"overview": "Breaking Bad is an American crime drama television series created and produced by Vince Gilligan. Set and produced in Albuquerque, New Mexico, Breaking Bad is the story of Walter White, a struggling high school chemistry teacher who is diagnosed with inoperable lung cancer at the beginning of the series. He turns to a life of crime, producing and selling methamphetamine, in order to secure his family's financial future before he dies, teaming with his former student, Jesse Pinkman. Heavily serialized, the series is known for positioning its characters in seemingly inextricable corners and has been labeled a contemporary western by its creator.",
"popularity": 10.297517149256,
"poster_path": "/4yMXf3DW6oCL0lVPZaZM2GypgwE.jpg",
"production_companies": [
{
"name": "Gran Via Productions",
"id": 2605
},
{
"name": "Sony Pictures Television",
"id": 11073
},
{
"name": "High Bridge Entertainment",
"id": 33742
}
],
"seasons": [
{
"air_date": "2009-02-17",
"episode_count": 6,
"id": 3577,
"poster_path": "/spPmYZAq2xLKQOEIdBPkhiRxrb9.jpg",
"season_number": 0
},
{
"air_date": "2008-01-19",
"episode_count": 7,
"id": 3572,
"poster_path": "/o5131POxv9xFl3wBmdg0YWc9Iz4.jpg",
"season_number": 1
},
{
"air_date": "2009-03-08",
"episode_count": 13,
"id": 3573,
"poster_path": "/7FwD7IuyHy6xl18LDIRxjl7vDbo.jpg",
"season_number": 2
},
{
"air_date": "2010-03-21",
"episode_count": 13,
"id": 3575,
"poster_path": "/1HVSSlEAOILiR4BskS1zV04kTjx.jpg",
"season_number": 3
},
{
"air_date": "2011-07-17",
"episode_count": 13,
"id": 3576,
"poster_path": "/5p7WduYlIIFjVYUIsqRZLFYWjMc.jpg",
"season_number": 4
},
{
"air_date": "2012-07-15",
"episode_count": 16,
"id": 3578,
"poster_path": "/r3z70vunihrAkjILQKWHX0G2xzO.jpg",
"season_number": 5
}
],
"status": "Ended",
"type": "Scripted",
"vote_average": 9,
"vote_count": 217
}

*/