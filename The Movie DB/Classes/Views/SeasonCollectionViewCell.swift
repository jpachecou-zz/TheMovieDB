//
//  SeasonCollectionViewCell.swift
//  The Movie DB
//
//  Created by Jonathan Pacheco on 7/05/15.
//  Copyright (c) 2015 ArandaSoft. All rights reserved.
//

import UIKit

class SeasonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var numberSeasonLabel:   UILabel!
    
    var numberSeason: Int! {
        didSet {
            numberSeasonLabel.text = numberSeason.description
        }
    }
    
}
