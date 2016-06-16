//
//  CCTodayViewController.swift
//  Abletive
//
//  Created by Cali Castle on 6/15/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit
import NotificationCenter

private let reuseIdentifier = "TodayCollectionCell"

class CCTodayViewController: UIViewController, NCWidgetProviding, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    var postCount = 4
    
    var preferredViewHeight : CGFloat = 115
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear()
        collectionView?.backgroundColor = UIColor.clear()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Do any additional setup after loading the view.
        updateSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateSize()
    }
    
    func updateSize() {
        var preferredSize = self.preferredContentSize
        preferredSize.height = preferredViewHeight
        self.preferredContentSize = preferredSize
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postCount
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CCTodayCollectionViewCell
        
        cell.thumbnailImageView.layer.cornerRadius = 23
        cell.thumbnailImageView.layer.masksToBounds = true
        
        // Earlier than iOS 10
        if Double(UIDevice.current().systemVersion)! <= 9 {
            cell.titleLabel.textColor = UIColor.white()
            cell.authorLabel.textColor = UIColor.lightGray()
        } else {
            cell.titleLabel.textColor = UIColor.black()
            cell.authorLabel.textColor = UIColor.darkGray()
        }
        
        Post.globalTimelinePosts(withPage: indexPath.item! + 1) { (post, error) in
            if error == nil {
                cell.currentPost = post
                
                if post?.imageMediumPath != nil && post?.imageMediumPath != "" {
                    self.getDataFromUrl(URL(string: (post?.imageMediumPath)!)!, completion: { (data, response, error) -> Void in
                        if error == nil {
                            DispatchQueue.main.async(execute: { () -> Void in
                                let image = UIImage(data: data!, scale: 1)
                                cell.thumbnailImageView.image = image
                            })
                        }
                    })
                } else {
                    cell.thumbnailImageView.image = UIImage(named: "placeholder")
                }
                cell.titleLabel.text = post?.title
                cell.authorLabel.text = post?.author.name
            }
        }
        
        return cell
    }
    
    func getDataFromUrl(_ url:URL, completion: ((data: Data?, response: URLResponse?, error: NSError? ) -> Void)) {
        URLSession.shared().dataTask(with: url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func widgetPerformUpdate(completionHandler: (NCUpdateResult) -> Void) {
        collectionView?.reloadData()
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 0)
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    
     // Uncomment this method to specify if the specified item should be selected
     func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
     }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CCTodayCollectionViewCell
        
        if cell.currentPost != nil {
            extensionContext?.open(URL(string: "abletive://today_click/\(cell.currentPost.postID)")!, completionHandler: nil)
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
}
