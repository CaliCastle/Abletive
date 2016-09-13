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
    func didSelectWallpaperAtIndex(_ index:Int)
}

class PersonalCardWallpaperCollectionViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout {

    weak var delegate : PersonalCardWallpaperDelegate?
    
    let wallpapers : NSArray = NSArray(contentsOfFile: Bundle.main.path(forResource: "PersonalCardWallpaper", ofType: "plist")!)!
    
    var backgroundIndex : Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentSizeInPopup = CGSize(width: UIScreen.main.bounds.size.width - 50, height: UIScreen.main.bounds.height - 120)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "选择背景"
        collectionView?.indicatorStyle = .white
        
        cellSize = contentSizeInPopup.width / 2 - paddingX
        backgroundIndex = UserDefaults.standard.integer(forKey: "card-backgroundIndex")
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.scrollToItem(at: IndexPath(row: UserDefaults.standard.integer(forKey: "card-backgroundIndex"), section: 0), at: .top, animated: true)
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

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.wallpapers.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        cell.backgroundColor = AppColor.lightTranslucent()
        
        let imageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: cell.frame.size))
        imageView.sd_setImage(with: URL(string: self.wallpapers.object(at: (indexPath as NSIndexPath).row) as! String), placeholderImage: UIImage(named: "LaunchLOGO.png"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        cell.addSubview(imageView)
        
        if (indexPath as NSIndexPath).row == backgroundIndex {
            cell.layer.borderColor = AppColor.mainYellow().cgColor
            cell.layer.borderWidth = 3
        } else {
            cell.layer.borderWidth = 0
            cell.layer.borderColor = AppColor.transparent().cgColor
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectWallpaperAtIndex((indexPath as NSIndexPath).row)
        popupController?.popViewController(animated: true)
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
