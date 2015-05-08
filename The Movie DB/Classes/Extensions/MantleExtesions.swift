//
//  MantleExtesions.swift
//  The Movie DB
//
//  Created by Jonathan Pacheco on 5/05/15.
//  Copyright (c) 2015 ArandaSoft. All rights reserved.
//

import Foundation
import Mantle

public let TMDBImageSizeReplacingKey = "[\\-sizeKey-\\]"

extension MTLModel {
    
    class func imageBaseTransformer() -> NSValueTransformer {
        return MTLValueTransformer(usingForwardBlock: { (value, success, error) in
            return "\(TheMovieDBManager.imageBase)\(TMDBImageSizeReplacingKey)\((value as! String!))"
            }
        )
    }
    
}