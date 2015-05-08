//
//  DetailShowViewController.swift
//  The Movie DB
//
//  Created by Jonathan Pacheco on 6/05/15.
//  Copyright (c) 2015 ArandaSoft. All rights reserved.
//

import UIKit
import Alamofire

class DetailShowViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak private var topCoverConstraint:          NSLayoutConstraint!
    @IBOutlet weak private var heightCoverConstraint:       NSLayoutConstraint!
    @IBOutlet weak private var heightContainerConstraint:   NSLayoutConstraint!
    
    @IBOutlet weak private var collectionView:  UICollectionView!
    @IBOutlet weak private var tableView:       UITableView!
    @IBOutlet weak private var coverImageView:  UIImageView!
    @IBOutlet weak private var avatarImageView: UIImageView!
    @IBOutlet weak private var titleLabel:      UILabel!
    @IBOutlet weak private var genreLabel:      UILabel!
    @IBOutlet weak private var actorsLabel:     UILabel!
    
    private var selectedSeasonIndex:    Int! {
        didSet {
            if let fullTvShow = currentFullDetailShow {
                if let season = fullTvShow.seasons {
                    if let seasonNumber = season[self.selectedSeasonIndex].seasonNumber?.integerValue where !season.isEmpty {
                        TheMovieDBManager.loadEpisodesWithShow(showId: self.currentShowId, seasonNumber: seasonNumber, success: {
                            (response, moreItems, error) -> () in
                            if let episodes = response as? Array<Episode> {
                                season[self.selectedSeasonIndex].episodes = nil
                                self.tableView.reloadData()
                                season[self.selectedSeasonIndex].episodes = episodes
                                var indexPaths = Array<NSIndexPath>()
                                for var i = 0; i < episodes.count; i++ {
                                    indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
                                }
                                self.tableView.beginUpdates()
                                self.selectedEpisodeIndex = 0
                                self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
                                self.tableView.endUpdates()
                            }
                        })
                    }
                }
            }
        }
    }
    private var selectedEpisodeIndex:   Int!
    var currentShowId:                  Int!
    var currentFullDetailShow:          FullTVShow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        loadShowData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        heightContainerConstraint.constant = CGRectGetMaxY(tableView.frame)
    }
    
    private func loadShowData() {
        TheMovieDBManager.fullDetailsTVShow(showId: currentShowId) { (response, error) in
            if let fullTvShow = response as? FullTVShow {
                TheMovieDBManager.creditsTvShow(showId: self.currentShowId, success: { (response, moreItems, error) -> () in
                    if let actors = response as? Array<Actor> {
                        if self.currentFullDetailShow != nil {
                            self.currentFullDetailShow!.actors = actors
                            self.actorsLabel.text = self.currentFullDetailShow!.actorsNames()
                            self.actorsLabel.sizeToFitWithConstraints()
                        }
                    }
                })
                self.currentFullDetailShow      = fullTvShow
                self.titleLabel.text            = validateString(fullTvShow.name)
                self.genreLabel.text            = validateString(fullTvShow.genres)
                self.selectedSeasonIndex        = 0
                var request: Request?           = nil
                self.coverImageView.imageWithUrlPath(fullTvShow.posterPath, request: &request) {
                    self.avatarImageView.image = self.coverImageView.image
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    func loadEpisodesInSeasion(seasonNumber: Int) {
        TheMovieDBManager.loadEpisodesWithShow(showId: currentShowId, seasonNumber: seasonNumber) { (response, moreItems, error) in
            self.currentFullDetailShow!.seasons![seasonNumber].episodes = response as? Array<Episode>
            self.tableView.reloadData()
        }
    }
    
    private func registerCells() {
        
        selectedSeasonIndex     = 0
        selectedEpisodeIndex    = -1
        
        tableView.tableFooterView = UIView()
        
        SeasonCollectionViewCell.registerFromNibInCollectionView(collectionView)
        EpisodeTableViewCell.registerFromNibInCollectionView(tableView)

    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ (UIViewControllerTransitionCoordinatorContext) -> Void in
            self.actorsLabel.sizeToFitWithConstraints()
            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
        })
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func backToPreviousViewController(sender: AnyObject!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - Collection view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if currentFullDetailShow != nil, let seasons = currentFullDetailShow!.seasons {
            return seasons.count
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SeasonCollectionViewCell.cellIdentifier(), forIndexPath: indexPath) as! SeasonCollectionViewCell
        cell.numberSeason = indexPath.row + 1
        cell.backgroundColor = indexPath.row == selectedSeasonIndex ? UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1) : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        return cell
    }
    
    //MARK: Collection view delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedSeasonIndex = indexPath.row
        collectionView.reloadData()
    }
    
    //MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedSeasonIndex >= 0 && currentFullDetailShow != nil {
            if let seasons = currentFullDetailShow!.seasons {
                if let episodes = seasons[selectedSeasonIndex].episodes {
                    
                    let height = CGFloat(((episodes.count - 1) * 36) + 94)
                    for constraint in (tableView.constraints() as! Array<NSLayoutConstraint>) {
                        if constraint.firstAttribute == .Height {
                            constraint.constant = height
                        }
                    }
                    view.layoutIfNeeded()
                    return episodes.count
                }
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(EpisodeTableViewCell.cellIdentifier()) as! EpisodeTableViewCell
        
        cell.configureCellWithEpisode(currentFullDetailShow!.seasons![selectedSeasonIndex].episodes![indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.beginUpdates()
        selectedEpisodeIndex = indexPath.row
        tableView.endUpdates()
    }
    
    //MARK: Table view delegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row == selectedEpisodeIndex ? 94 : 36
    }
    
    //MARK: - Scroll view delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollOffset = -scrollView.contentOffset.y
        self.topCoverConstraint.constant    = scrollOffset < 0 ? 0 : -scrollOffset
        self.heightCoverConstraint.constant = scrollOffset < 0 ? 146 : 146 + scrollOffset
    }
    
}
