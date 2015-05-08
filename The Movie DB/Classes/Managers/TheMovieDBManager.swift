//
//  TheMovieDBManager.swift
//  The Movie DB
//
//  Created by Jonathan Pacheco on 5/05/15.
//  Copyright (c) 2015 ArandaSoft. All rights reserved.
//

import Foundation
import Mantle
import Alamofire

/**
*  Typealias to reduce expression of the Closure
*
*  @param AnyObject! Object returned in the response
*  @param NSError?   If error ocurred at request
*
*  @return Void
*/

typealias TheMovieDBManagerObjectBlock = ((response: AnyObject!, error: NSError?) -> ())
/**
*  Typealias to reduce expression of the Closure
*
*  @param Array<AnyObject>! Array returned in the response
*  @param Bool              Indicate if have more items
*  @param NSError?          If error ocurred at request
*
*  @return Void
*/
typealias TheMovieDBManagerArrayBlock = ((response: Array<AnyObject>!, moreItems: Bool, error: NSError?) -> ())

/// Api Key - Api of api.themoviedb.org
private let apiKey = "38ec46add016ee7cf79a20b366611992"
/// Key for notification when load configuration is completed
public let TheMovieDBLoadConfigurationNotificationkey = "TheMovieDBLoadConfigurationNotificationkey"

/**
*  The Movie DB Manager.
*
*  Manage all  request to getting data
*
*/
class TheMovieDBManager: NSObject {
    
    /// Base to images url
    private(set) static var imageBase: String!
    /// Dictionary with basics parameter for request
    static var defaultParams: Dictionary<String, AnyObject>? {
        get {
            return ["api_key": apiKey]
        }
    }
    
    /**
    Load configuration and get image url base
    */
    class func loadConfiguration() {
        Alamofire.request(.GET, "http://api.themoviedb.org/3/configuration", parameters: defaultParams)
            .responseJSON { (_, _, data, error) in
                self.imageBase = ""
                if let json = data as? Dictionary<NSObject, AnyObject> {
                    if let images: AnyObject = json["images"] as? Dictionary<NSObject, AnyObject> {
                        self.imageBase = images["secure_base_url"] as! String
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(TheMovieDBLoadConfigurationNotificationkey, object: false)
                    }
                }
        }
    }
    
    /**
    Get the main TV series.
    
    :param: reset   If is true,  return the first results of the page, if is false, return the next page
    :param: success Completion handler
    */
    class func discoverTVShows(firtsPage reset: Bool, success: TheMovieDBManagerArrayBlock?) {
        //Static variable indicate the number page of result
        struct InfinityCalls {
            static var page = 1
        }
        if reset {
            InfinityCalls.page = 1
        }
        let parameters: Dictionary<String, AnyObject> = ["api_key" : apiKey, "page" : InfinityCalls.page++]
        Alamofire.request(.GET, "http://api.themoviedb.org/3/discover/tv", parameters: parameters)
            .responseJSON { (_, _, data, error) in
                if let json = (data as? Dictionary<NSObject, AnyObject>) where error == nil {
                    if let array: [AnyObject]! = json["results"] as? [AnyObject] {
                        var castError: NSError?
                        let responseArray = MTLJSONAdapter.modelsOfClass(TVShow.classForCoder(), fromJSONArray: array, error: &castError)
                        if success != nil {
                            let page            = (json["page"] as! NSNumber).integerValue
                            let totalPages      = (json["total_pages"] as! NSNumber).integerValue
                            let moreItems: Bool = page < totalPages
                            success!(response: responseArray, moreItems: moreItems, error: castError)
                        }
                    }
                }
        }
    }
    
    /**
    Search the TV series that match the parameters entered by the user
    
    :param: reset   If is true,  return the first results of the page, if is false, return the next page
    :param: query   Text that will use for find all matches
    :param: success Completion handler
    */
    class func searchTvShows(firtsPage reset: Bool, query: String!, success: TheMovieDBManagerArrayBlock?) {
        struct InfinityCalls {
            static var page = 1
            static var oldQuery: String = ""
        }
        //If the parameter reset is true or the query is equal to old query, force to get first page
        if reset || query != InfinityCalls.oldQuery {
            InfinityCalls.page = 1
        }
        InfinityCalls.oldQuery = query
        let parameters: Dictionary<String, AnyObject> = ["api_key": apiKey, "query": query, "page" : InfinityCalls.page++]

        Alamofire.request(.GET, "http://api.themoviedb.org/3/search/tv", parameters: parameters)
            .responseJSON { (_, _, data, error) in
                println("Error: __\(error) ")
                if let json = (data as? Dictionary<NSObject, AnyObject>) where error == nil {
                    if let array: [AnyObject]! = json["results"] as? [AnyObject] {
                        var castError: NSError?
                        
                        let responseArray = MTLJSONAdapter.modelsOfClass(TVShow.classForCoder(), fromJSONArray: array, error: &castError)
                        if success != nil {
                            let page            = (json["page"] as! NSNumber).integerValue
                            let totalPages      = (json["total_pages"] as! NSNumber).integerValue
                            let moreItems: Bool = page < totalPages
                            println("Query: \(query), Page: \(page), totalPages: \(totalPages), loadMore: \(moreItems)\n")
                            success!(response: responseArray, moreItems: moreItems, error: castError)
                        }
                    }
                }
        }
    }
    
    class func fullDetailsTVShow(#showId: Int, success: TheMovieDBManagerObjectBlock?) {
        Alamofire.request(.GET, "http://api.themoviedb.org/3/tv/\(showId)", parameters: defaultParams)
            .responseJSON { (_, _, object, error) in
                if let responseObject = object as? Dictionary<NSObject, AnyObject> {
                    var castError: NSError?
                    let details: AnyObject! = MTLJSONAdapter.modelOfClass(FullTVShow.classForCoder(), fromJSONDictionary: responseObject, error: &castError)
                    if success != nil {
                        success!(response: details, error: castError)
                    }
                }
        }
    }
    
    class func creditsTvShow(#showId: Int, success: TheMovieDBManagerArrayBlock?) {
        Alamofire.request(.GET, "http://api.themoviedb.org/3/tv/\(showId)/credits", parameters: defaultParams)
            .responseJSON { (_, _, data, error) in
                if let json = (data as? Dictionary<NSObject, AnyObject>) where error == nil {
                    var castError: NSError? = nil
                    if let array = json["cast"] as? Array<Dictionary<NSObject, AnyObject>> {
                        let actors = MTLJSONAdapter.modelsOfClass(Actor.classForCoder(), fromJSONArray: array, error: &castError)
                        if success != nil {
                            success!(response: actors, moreItems: false, error: castError)
                        }
                    }
                }
        }
    }
    
    class func loadEpisodesWithShow(#showId: Int, seasonNumber: Int, success: TheMovieDBManagerArrayBlock?) {
        Alamofire.request(.GET, "http://api.themoviedb.org/3/tv/\(showId)/season/\(seasonNumber)", parameters: defaultParams)
            .responseJSON { (_, _, data, error) in
                if let json = (data as? Dictionary<NSObject, AnyObject>) where error == nil {
                    var castError: NSError? = nil
                    if let array = json["episodes"] as? Array<Dictionary<NSObject, AnyObject>> {
                        let actors = MTLJSONAdapter.modelsOfClass(Episode.classForCoder(), fromJSONArray: array, error: &castError)
                        if success != nil {
                            success!(response: actors, moreItems: false, error: castError)
                        }
                    }
                }
        }
    }
    
}
