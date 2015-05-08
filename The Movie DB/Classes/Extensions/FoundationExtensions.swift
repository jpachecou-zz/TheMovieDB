//
//  FoundationExtensions.swift
//  The Movie DB
//
//  Created by Jonathan Pacheco on 5/05/15.
//  Copyright (c) 2015 ArandaSoft. All rights reserved.
//

import Foundation

/**
*
*/
extension String {
    
    /// Gets the number of characters in string
    var length: Int {
        get {
            return count(self)
        }
    }
    
}

extension Array {
    
    func arrayWithElementValidForType<T>() -> Array<T> {
        return self.map { $0 as! T }
    }
    
}

/**
Validates that a string is not null

:param: string String to validate

:returns: If the string is null, returns an empty string
*/
func validateString(string: String?) -> String! {
    return string == nil ? "" : string!
}