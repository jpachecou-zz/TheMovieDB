//
//  ShowsCollectionViewController.swift
//  The Movie DB
//
//  Created by Jonathan Pacheco on 5/05/15.
//  Copyright (c) 2015 ArandaSoft. All rights reserved.
//

import UIKit

let numberColumnsOniPhonePortrait:          CGFloat = 2.0
let numberColumnsOniPadAndiPhoneLanscape:   CGFloat = 3.0
let aspectRatio:                            CGFloat = 1.5

class ShowsCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchBarDelegate {

    @IBOutlet weak private var collectionView:      UICollectionView!
    @IBOutlet weak private var searchBar:           UISearchBar!
    
    private var selectedShowId:         Int!
    private var currentNumerColumns:    CGFloat!
    private var moreItems:              Bool = true
    private var tvShowsArray = Array<TVShow>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCollectionCells()
        configureNotifications()
        
        let screenWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)
        currentNumerColumns = screenWidth > 414 ? numberColumnsOniPadAndiPhoneLanscape : numberColumnsOniPhonePortrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailsSegue" {
            let destination = segue.destinationViewController as! DetailShowViewController
            destination.currentShowId = selectedShowId
        }
    }
    
    private func configureNotifications() {
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: Selector("loadData"),
                                   name: TheMovieDBLoadConfigurationNotificationkey,
                                 object: false)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter()
            .removeObserver(self, name: TheMovieDBLoadConfigurationNotificationkey,
                                object: nil)
    }
    
    /**
    Register the type cells that will to use
    */
    
    private func registerCollectionCells() {
        ShowCollectionViewCell.registerFromNibInCollectionView(collectionView)
        EmptyCollectionViewCell.registerFromNibInCollectionView(collectionView)
        CollectionReusableViewInfinityScroll.registerFromNibInCollectionView(collectionView)
    }
    
    func loadData() {
        TheMovieDBManager.discoverTVShows(firtsPage: true) { (response, moreItems, error) -> () in
            if error == nil {
                if let shows = response as? Array<TVShow> {
                    self.moreItems = moreItems
                    self.tvShowsArray = shows
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func searchTVShowFromQuery(query: String) {
        TheMovieDBManager.searchTvShows(firtsPage: true, query: query) { (response, moreItems, error) -> () in
            if error == nil {
                if let shows = response as? Array<TVShow> {
                    self.moreItems = moreItems
                    self.tvShowsArray = shows
                    self.collectionView.reloadData()
                }
            }
        }

        self.collectionView.reloadData()
    }
    
    private func loadMoreData(success: (()->Void)? = nil) {
        let completion: TheMovieDBManagerArrayBlock = { (response, moreItems, error) -> () in
            if error == nil {
                if let shows = response as? Array<TVShow> {
                    self.moreItems = moreItems
                    let count = self.tvShowsArray.count
                    var indexPaths = Array<NSIndexPath>()
                    for var i = count; i < count + shows.count; i++ {
                        indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
                        self.tvShowsArray.append(shows[i - count])
                    }
                    self.collectionView.performBatchUpdates({ () -> Void in
                        self.collectionView.insertItemsAtIndexPaths(indexPaths)
                        }) { (succeded: Bool) in
                            if success != nil {
                                success!()
                            }
                    }
                }
            }
        }
        if searchBar.text.isEmpty {
            TheMovieDBManager.discoverTVShows(firtsPage: false, success: completion)
        } else {
            TheMovieDBManager.searchTvShows(firtsPage: false, query: searchBar.text, success: completion)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ (UIViewControllerTransitionCoordinatorContext) -> Void in
            self.collectionView.performBatchUpdates(nil, completion: nil)
            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
        })
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    private func willLoadMoreContendWithIndex(index: Int) {
        if !tvShowsArray.isEmpty && index > (tvShowsArray.count - Int(currentNumerColumns * 2)) {
            struct LoaderFlagAvailable {
                static var available: Bool = true
            }
            if LoaderFlagAvailable.available && moreItems {
                loadMoreData {
                    LoaderFlagAvailable.available = true
                }
                LoaderFlagAvailable.available = false
            }
        }
    }
    
    //MARK: - Collection view data source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if tvShowsArray.isEmpty {
            return 1
        }
        return tvShowsArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // If don't have items in the collection view then shows a message it say empty
        if tvShowsArray.isEmpty {
            return collectionView.dequeueReusableCellWithReuseIdentifier(EmptyCollectionViewCell.cellIdentifier(), forIndexPath: indexPath) as! UICollectionViewCell
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ShowCollectionViewCell.cellIdentifier(), forIndexPath: indexPath) as! ShowCollectionViewCell
        
        cell.configureCellWithShow(tvShowsArray[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: CollectionReusableViewInfinityScroll.cellIdentifier(), forIndexPath: indexPath) as! UICollectionReusableView
    }
    
    //MARK: Collection view delegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        willLoadMoreContendWithIndex(indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let showId = tvShowsArray[indexPath.row].showId?.integerValue {
            selectedShowId = showId
            performSegueWithIdentifier("detailsSegue", sender: self)
        }
    }
    
    //MARK: Collection view delegate flow layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if tvShowsArray.isEmpty {
            return CGSizeMake(CGRectGetWidth(collectionView.frame),
                CGRectGetHeight(collectionView.frame) - topLayoutGuide.length - bottomLayoutGuide.length)
        }
        
        let screenWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)
        currentNumerColumns = screenWidth > 414 ? numberColumnsOniPadAndiPhoneLanscape : numberColumnsOniPhonePortrait
        
        let width = (screenWidth / currentNumerColumns) - 30
        return CGSizeMake(width, width * aspectRatio)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if !moreItems {
            return CGSizeZero
        }
        let screenWidth = CGRectGetWidth(collectionView.frame)
        return CGSizeMake(screenWidth, 64)
    }
    
    //MARK: - Search bar delegate
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if range.length == 1 || text == "\n" || text == " " {
            return true
        }
        let symbolSet = NSCharacterSet.alphanumericCharacterSet().invertedSet
        return (text as NSString).rangeOfCharacterFromSet(symbolSet).location == NSNotFound
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadData()
        } else {
            searchTVShowFromQuery(searchText)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
}
