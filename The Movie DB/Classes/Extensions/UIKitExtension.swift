//
//  UIKitExtension.swift
//  The Movie DB
//
//  Created by Jonathan Pacheco on 5/05/15.
//  Copyright (c) 2015 ArandaSoft. All rights reserved.
//

import UIKit
import Alamofire

extension UICollectionView {
    
    var isEmpty: Bool {
        get {
            if let _dataSource = dataSource {
                return _dataSource.collectionView(self, numberOfItemsInSection: 0) == 0
            }
            return true
        }
    }
    
}

extension UITableViewCell {
    
    class func registerFromNibInCollectionView(tableView: UITableView) {
        let identifier = cellIdentifier()
        let nib = UINib(nibName: identifier, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: identifier)
    }
    
    class func cellIdentifier() -> String {
        return NSStringFromClass(classForCoder()).pathExtension
    }
    
}

extension UICollectionViewCell {
    
    override class func registerFromNibInCollectionView(collectionView: UICollectionView) {
        let identifier = cellIdentifier()
        let nib = UINib(nibName: identifier, bundle: nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: identifier)
    }
    
    override class func cellIdentifier() -> String {
        return NSStringFromClass(classForCoder()).pathExtension
    }
    
}

extension UICollectionReusableView {
    
    class func registerFromNibInCollectionView(collectionView: UICollectionView) {
        let identifier = cellIdentifier()
        let nib = UINib(nibName: identifier, bundle: nil)
        collectionView.registerNib(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                               withReuseIdentifier: cellIdentifier())
    }
    
    class func cellIdentifier() -> String {
        return NSStringFromClass(classForCoder()).pathExtension
    }
    
}

extension UILabel {
    
    public func sizeToFitWithConstraints() {
        let size = self.text!.boundingRectWithSize(
            CGSizeMake(self.frame.size.width, CGFloat.infinity),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: self.font],
            context: nil).size
        for constraint in (constraints() as! Array<NSLayoutConstraint>) {
            if constraint.firstAttribute == .Height {
                constraint.constant = size.height + 4
            }
        }
    }
    
}

private let imageCache = NSCache()
extension UIImageView {

    func imageWithUrlPath(path: String?, inout request: Request?, originalSize original: Bool = false, success: (()->())? = nil) {
        if let urlPath = path {
            let size = original ? "Original" : "w342"
            let imageURL = urlPath.stringByReplacingOccurrencesOfString(TMDBImageSizeReplacingKey, withString: size)
            if let image = imageCache.objectForKey(imageURL) as? UIImage {
                self.image = image
                if success != nil {
                    success!()
                }
            } else {
                self.image = nil
                request = Alamofire.request(.GET, imageURL)
                    .validate(contentType: ["image/*"])
                    .response() { (request, _, data, error) in
                        if let _data = data as? NSData where error == nil {
                            let image = UIImage(data: _data)
                            imageCache.setObject(image!, forKey: request.URLString)
                            self.image = image
                            if success != nil {
                                success!()
                            }
                        }
                }
            }
        }
    }
    
}