//
//  ScreenCastSeriesTableViewController.swift
//  Abletive
//
//  Created by Cali Castle on 3/2/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class ScreenCastSeriesTableViewController: UITableViewController {

    let toolbarHeight : CGFloat = 44
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var lessonsLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    
    @IBOutlet weak var experienceInfo: UILabel!
    @IBOutlet weak var experienceIcon: UIImageView!
    @IBOutlet weak var experienceLabel: UILabel!
    
    @IBOutlet var toolBar: UIToolbar!
    
    var series : Series?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = series!.title
        
        tableView.backgroundColor = AppColor.transparent()
        
        customizeViews()
        setupBackground()
        setupToolbar()
        bindModelToView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func customizeViews() {
        experienceIcon.image = UIImage(named: "experience")?.imageWithRenderingMode(.AlwaysTemplate)
        experienceIcon.tintColor = AppColor.mainYellow()
    }
    
    func setupBackground() {
        tableView.tableFooterView = UIView()
        // Change the proper background and apply blur filter
        let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        backgroundView.bounds = view.bounds
        
        let backgroundImageView = UIImageView(frame: backgroundView.bounds)
        backgroundImageView.sd_setImageWithURL(NSURL(string: series!.thumbnail)) { (image, error, cacheType, url) -> Void in
            if error == nil {
                backgroundImageView.image = image
            }
        }
        
        backgroundImageView.contentMode = .ScaleAspectFill
        
        backgroundView.insertSubview(backgroundImageView, atIndex: 0)
        
        tableView.backgroundView = backgroundView
    }
    
    func bindModelToView() {
        thumbnailImageView.sd_setImageWithURL(NSURL(string: series!.thumbnail), placeholderImage: UIImage(named: "series_placeholder"))
        thumbnailImageView.userInteractionEnabled = true
        let tapper = UITapGestureRecognizer(target: self, action: Selector(thumbnailDidTap()))
        thumbnailImageView.addGestureRecognizer(tapper)
        
        titleLabel.text = series!.title
        descriptionLabel.text = series!.descrip
    }
    
    func setupToolbar() {
        setToolbarPosition(tableView)
        toolBar.setBackgroundImage(UIImage(named: "toolbar-bg"), forToolbarPosition: .Any, barMetrics: .Default)
        
        view.addSubview(toolBar)
    }
    
    func setToolbarPosition(scrollView : UIScrollView) {
        toolBar.frame = CGRect(origin: CGPoint(x: 0, y: scrollView.contentOffset.y + view.frame.size.height - toolbarHeight), size: CGSize(width: view.frame.size.width, height: toolbarHeight))
        tableView.bringSubviewToFront(toolBar)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        setToolbarPosition(scrollView)
    }
    
    func thumbnailDidTap() {
        let photoVC = MLPhotoBrowserViewController()
        let photo = MLPhotoBrowserPhoto()
        photo.toView = thumbnailImageView
        photo.photoImage = thumbnailImageView.image
        
        photoVC.photos = [photo]
        photoVC.editing = false
        
        photoVC.showPickerVc(self)
    }

    @IBAction func laterDidTap(sender: UIBarButtonItem) {
        print("Tapped later")
    }
    
    @IBAction func favoriteDidTap(sender: UIBarButtonItem) {
        print("Tapped favorite")
    }
    
    @IBAction func notifyDidTap(sender: UIBarButtonItem) {
        print("Tapped notify")
    }
    
    @IBAction func shareDidTap(sender: UIBarButtonItem) {
        print("Tapped share")
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
