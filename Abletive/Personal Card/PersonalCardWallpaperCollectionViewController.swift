//
//  PersonalCardWallpaperCollectionViewController.swift
//  Abletive
//
//  Created by Cali on 11/16/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PersonalCardWallpaper"
private let paddingX : CGFloat = 5
private var cellSize : CGFloat = 0

public protocol PersonalCardWallpaperDelegate : NSObjectProtocol {
    func didSelectWallpaperAtIndex(index:Int)
}

class PersonalCardWallpaperCollectionViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout {

    weak var delegate : PersonalCardWallpaperDelegate?
    
    let wallpapers : NSArray = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("PersonalCardWallpaper", ofType: "plist")!)!
    
    var backgroundIndex : Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentSizeInPopup = CGSize(width: UIScreen.mainScreen().bounds.size.width - 50, height: UIScreen.mainScreen().bounds.height - 120)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "选择背景"
        collectionView?.indicatorStyle = .White
        
        cellSize = contentSizeInPopup.width / 2 - paddingX
        backgroundIndex = NSUserDefaults.standardUserDefaults().integerForKey("card-backgroundIndex")
        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.scrollToItemAtIndexPath(NSIndexPath(forRow: NSUserDefaults.standardUserDefaults().integerForKey("card-backgroundIndex"), inSection: 0), atScrollPosition: .Top, animated: true)
        // Do any additional setup after loading the view.
        view.backgroundColor = AppColor.secondaryBlack()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.wallpapers.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        // Configure the cell
        cell.backgroundColor = AppColor.lightTranslucent()
        
        let imageView = UIImageView(frame: CGRect(origin: CGPointZero, size: cell.frame.size))
        imageView.sd_setImageWithURL(NSURL(string: self.wallpapers.objectAtIndex(indexPath.row) as! String), placeholderImage: UIImage(named: "LaunchLOGO.png"))
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true

        cell.addSubview(imageView)
        
        if indexPath.row == backgroundIndex {
            cell.layer.borderColor = AppColor.mainYellow().CGColor
            cell.layer.borderWidth = 3
        } else {
            cell.layer.borderWidth = 0
            cell.layer.borderColor = AppColor.transparent().CGColor
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectWallpaperAtIndex(indexPath.row)
        popupController?.popViewControllerAnimated(true)
    }

    // MARK: UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: cellSize, height: cellSize)
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
