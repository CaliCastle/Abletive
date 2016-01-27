//
//  MembershipTableViewController.swift
//  Abletive
//
//  Created by Cali Castle on 12/19/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit

class MembershipTableViewController: UITableViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var memberBadgeImageView: UIImageView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var membershipTypeLabel: UILabel!
    @IBOutlet weak var membershipStatusLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var renewButton: UIButton!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    var currentMembership : Membership?
    var currentMembershipSelection : Int = 0
    var currentAmount : Int = 1
    var totalPrice : Int = 0
    var canRenew = true
    
    let membershipInfo = [0:"9",1:"25",2:"90",3:"300"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "我的会员"
        
        setupViews()

        avatarImageView.sd_setImageWithURL(NSURL(string: NSUserDefaults.standardUserDefaults().stringForKey("user_avatar_path")!), placeholderImage: UIImage(named: "default-avatar")) { (image, error, type, url) -> Void in
            let backgroundImageView = UIImageView(frame: self.view.frame)
            backgroundImageView.contentMode = .ScaleAspectFill
            backgroundImageView.image = (error == nil) ? self.avatarImageView.image : UIImage(named: "default-avatar")
            
            let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
            blurEffectView.frame = backgroundImageView.frame
            backgroundImageView.addSubview(blurEffectView)
            self.tableView.backgroundView = backgroundImageView
        }
        view.backgroundColor = AppColor.transparent()
        tableView.backgroundColor = AppColor.darkTranslucent()
        tableView.separatorColor = AppColor.transparent()
        tableView.indicatorStyle = .White
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "paymentSucceeded", name: "PaymentSuccess", object: nil)
        
        fetchData()
    }
    
    func fetchData(fromNotification:Bool = false) {
        if !fromNotification {
            TAOverlay.showOverlayWithLogo()
        }
        Membership.getCurrentMembership { (membership) -> Void in
            if !fromNotification {
                TAOverlay.hideOverlay()
            }
            if membership != nil {
                self.currentMembership = membership!
                self.updateViews()
                self.updatePrice()
            } else {
                TAOverlay.showOverlayWithError()
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    func setupViews(){
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 8
        avatarImageView.layer.borderColor = AppColor.lightSeparator().CGColor
        avatarImageView.layer.borderWidth = 1
    }

    func updateViews(){
        startTimeLabel.text = currentMembership?.startTime == "N/A" ? currentMembership?.startTime : CCDateToString.getStringFromDate(currentMembership?.startTime)
        startTimeLabel.textColor = AppColor.lightTranslucent()
        endTimeLabel.text = currentMembership?.endTime == "N/A" ? currentMembership?.endTime : CCDateToString.getStringFromDate(currentMembership?.endTime)
        endTimeLabel.textColor = AppColor.lightTranslucent()
        membershipTypeLabel.text = currentMembership?.type
        membershipTypeLabel.textColor = AppColor.mainYellow()
        membershipStatusLabel.text = currentMembership?.status
        membershipStatusLabel.textColor = AppColor.lightTranslucent()
        
        switch currentMembership?.type {
            case "过期会员"?:
                memberBadgeImageView.image = UIImage(named: "membership-expired")?.imageWithRenderingMode(.AlwaysTemplate)
                break;
            case "月费会员"?:
                memberBadgeImageView.image = UIImage(named: "monthly-membership")?.imageWithRenderingMode(.AlwaysTemplate)
                break;
            case "季费会员"?:
                memberBadgeImageView.image = UIImage(named: "seasonly-membership")?.imageWithRenderingMode(.AlwaysTemplate)
                break;
            case "年费会员"?:
                memberBadgeImageView.image = UIImage(named: "yearly-membership")?.imageWithRenderingMode(.AlwaysTemplate)
                break;
            case "终身会员"?:
                canRenew = false
                memberBadgeImageView.image = UIImage(named: "eternal-membership")?.imageWithRenderingMode(.AlwaysTemplate)
                break;
            default:
                break;
        }
        memberBadgeImageView.tintColor = AppColor.mainWhite()
        
        renewButton.layer.masksToBounds = true
        renewButton.layer.cornerRadius = 8
        renewButton.backgroundColor = AppColor.loginButtonColor()
        renewButton.tintColor = AppColor.mainWhite()
        renewButton.layer.shadowColor = AppColor.darkOverlay().CGColor
        renewButton.layer.shadowRadius = 5
        renewButton.enabled = canRenew
    }
    
    @IBAction func membershipSelectionDidChange(sender: UISegmentedControl) {
        currentMembershipSelection = sender.selectedSegmentIndex
        updatePrice()
    }
    
    @IBAction func amountStepperDidChange(sender: UIStepper) {
        amountLabel.text = "x \(Int(sender.value))"
        currentAmount = Int(sender.value)
        updatePrice()
    }
    
    @IBAction func renewDidClick(sender: UIButton) {
        let paymentVC = storyboard?.instantiateViewControllerWithIdentifier("Payment") as! PaymentTableViewController
        paymentVC.totalAmount = "\(totalPrice).00"
        paymentVC.vipType = UInt(currentMembershipSelection + 1)
        navigationController?.pushViewController(paymentVC, animated: true)
    }
    
    func updatePrice() {
        totalPrice = currentAmount * Int(membershipInfo[currentMembershipSelection]!)!
        totalPriceLabel.text = "￥\(totalPrice).00"

    }
    
    func paymentSucceeded() {
        fetchData(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

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
