//
//  ScreenCastIndexTableViewController.swift
//  Abletive
//
//  Created by Cali Castle on 3/1/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class ScreenCastIndexTableViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    let seriesReuseIdentifier = "IndexSeriesReuse"
    let tutorReuseIdentifier = "IndexTutorReuse"
    let testimonialReuseIdentifier = "IndexTestimonialReuse"
    
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    
    @IBOutlet weak var tutorCollectionView: UICollectionView!
    
    @IBOutlet weak var testimonialCollectionView: UICollectionView!
    
    var seriesCollectionIndicator : UIActivityIndicatorView?
    var tutorCollectionIndicator : UIActivityIndicatorView?
    var testimonialCollectionIndicator : UIActivityIndicatorView?
    
    private var allSeries = [Series]()
    private var allTutors = [CCUser]()
    private var allTestimonials = [Testimonial]()
    
    override func viewWillAppear(animated: Bool) {
        tabBarController?.navigationItem.title = "系列教程"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSetup()
        customizeViews()
        setupBackground()
        fetchData()
    
    }
    
    func initSetup() {
        // Delegate init
        seriesCollectionView.delegate = self
        seriesCollectionView.dataSource = self
        
        tutorCollectionView.delegate = self
        tutorCollectionView.dataSource = self
        
        testimonialCollectionView.delegate = self
        testimonialCollectionView.dataSource = self
        
        // Display loading indicator for each collection view
        seriesCollectionIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        seriesCollectionIndicator!.center = CGPoint(x: view.center.x, y: seriesCollectionView.center.y)
        seriesCollectionView.addSubview(seriesCollectionIndicator!)
        seriesCollectionIndicator!.startAnimating()
        
        tutorCollectionIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        tutorCollectionIndicator!.center = CGPoint(x: view.center.x, y: tutorCollectionView.center.y)
        tutorCollectionView.addSubview(tutorCollectionIndicator!)
        tutorCollectionIndicator!.startAnimating()
        
        testimonialCollectionIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        testimonialCollectionIndicator!.center = CGPoint(x: view.center.x, y: testimonialCollectionView.center.y)
        testimonialCollectionView.addSubview(testimonialCollectionIndicator!)
        testimonialCollectionIndicator!.startAnimating()
    }
    
    func refreshData() {
        fetchData()
    }
    
    func fetchData() {
        // Fetch data from server
        AbletiveAPIClient.sharedScreenCastClient().GET("index", parameters: ["_passphrase" : AbletivePassphrase], success: { (dataTask, response) -> Void in
            self.removeIndicators()
            let JSON = response as! NSDictionary
            
            self.allSeries = [Series]()
            for seriesAttr in JSON["series"]!["list"] as! NSArray {
                let series = Series(attributes: seriesAttr as! NSDictionary)
                self.allSeries.append(series)
            }
            
            self.allTutors = [CCUser]()
            for tutorAttr in JSON["tutors"]!["list"] as! NSArray {
                let tutor = CCUser(attributes: tutorAttr as! NSDictionary)
                self.allTutors.append(tutor)
            }
            
            self.allTestimonials = [Testimonial]()
            for testimonialAttr in JSON["testimonials"] as! NSArray {
                let testimonial = Testimonial(attributes: testimonialAttr as! NSDictionary)
                self.allTestimonials.append(testimonial)
            }
            
            self.reloadData()
            
            }) { (dataTask, error) -> Void in
                TAOverlay.showOverlayWithError()
        }
    }
    
    func customizeViews() {
        // Customize the look
        tableView.separatorColor = AppColor.transparent()
        tableView.tableFooterView = UIView()
        seriesCollectionView.backgroundColor = AppColor.transparent()
        tutorCollectionView.backgroundColor = AppColor.transparent()
        testimonialCollectionView.backgroundColor = AppColor.transparent()
    }
    
    func setupBackground() {
        // Change the proper background and apply blur filter
        let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        backgroundView.bounds = view.bounds
        
        let backgroundImageView = UIImageView(frame: backgroundView.bounds)
        backgroundImageView.image = UIImage(named: "photo-perform.jpg")
        backgroundImageView.contentMode = .ScaleAspectFill
        
        backgroundView.insertSubview(backgroundImageView, atIndex: 0)
        
        tableView.backgroundView = backgroundView
    }
    
    func removeIndicators() {
        self.seriesCollectionIndicator!.removeFromSuperview()
        self.tutorCollectionIndicator?.removeFromSuperview()
        self.testimonialCollectionIndicator?.removeFromSuperview()
    }
    
    func reloadData() {
        self.seriesCollectionView.reloadData()
        self.tutorCollectionView.reloadData()
        self.testimonialCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ScrollViewDelegate methods
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {

    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    // MARK: UICollectionViewDelegate & DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            return allSeries.count
        case 1:
            return allTutors.count
        case 2:
            return allTestimonials.count
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 0:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(seriesReuseIdentifier, forIndexPath: indexPath) as! ScreenCastSeriesCollectionViewCell
            
            cell.series = allSeries[indexPath.item]
            
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(tutorReuseIdentifier, forIndexPath: indexPath) as! ScreenCastTutorCollectionViewCell
            
            cell.tutor = allTutors[indexPath.item]
            
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(testimonialReuseIdentifier, forIndexPath: indexPath) as! ScreenCastTestimonialCollectionViewCell
            
            cell.testimonial = allTestimonials[indexPath.item]
            
            return cell
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch collectionView.tag {
        case 0:
            let series = allSeries[indexPath.item]
            
            let seriesController = storyboard?.instantiateViewControllerWithIdentifier("Series") as! ScreenCastSeriesTableViewController
            seriesController.series = series
            tabBarController?.navigationController?.pushViewController(seriesController, animated: true)
            break
        case 1:
            break
        case 2:
            break
        default:
            break
        }
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

}
