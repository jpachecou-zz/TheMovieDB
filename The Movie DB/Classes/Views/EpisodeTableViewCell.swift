//
//  EpisodeTableViewCell.swift
//  The Movie DB
//
//  Created by Jonathan Pacheco on 7/05/15.
//  Copyright (c) 2015 ArandaSoft. All rights reserved.
//

import UIKit

class EpisodeTableViewCell: UITableViewCell {

    @IBOutlet weak private var nameLabel:       UILabel!
    @IBOutlet weak private var numberLabel:     UILabel!
    @IBOutlet weak private var overviewLabel:   UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCellWithEpisode(episode: Episode) {
        nameLabel.text      = validateString(episode.name)
        numberLabel.text    = episode.episodeNumber == nil ? "" : episode.episodeNumber!.description
        overviewLabel.text  = validateString(episode.overview)
    }
    
}
