//
//  MembershipTableViewController.swift
//  Abletive
//
//  Created by Cali Castle on 12/19/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit
import StoreKit

class MembershipTableViewController: UITableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var memberBadgeImageView: UIImageView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var membershipTypeLabel: UILabel!
    @IBOutlet weak var membershipStatusLabel: UILabel!
    
    @IBOutlet weak var renewButton: UIButton!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    var currentMembership : Membership?
    var currentMembershipSelection : Int = 0
    var totalPrice : Int = 0
    var canRenew = true
    var vipType : UInt = 0
    
    var request : SKProductsRequest?
    var products : [SKProduct]?
    
    let membershipInfo = [0:"12",1:"30",2:"88",3:"298"]
    let membershipNames = ["月费会员", "季费会员", "年费会员", "终身会员"]
    let productIds = NSArray(contentsOfURL: NSBundle.mainBundle().URLForResource("product_ids", withExtension: "plist")!)
    
    let kInAppPurchaseFailedNotification = "kInAppPurchaseFailedNotification"
    let kInAppPurchaseSucceededNotification = "kInAppPurchaseSucceededNotification"
    
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
        
        fetchData()
        loadFromStore()
    }
    
    func loadFromStore() {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
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
    
    @IBAction func renewDidClick(sender: UIButton) {
        vipType = UInt(currentMembershipSelection + 1)
        
        let alertController = UIAlertController(title: "确认您的购买选择", message: "确定要购买价值￥\(totalPrice)的\(membershipNames[currentMembershipSelection])吗?", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel) { (action) -> Void in
            
        }
        let confirmAction = UIAlertAction(title: "确定", style: .Destructive) { (action) -> Void in
            self.validateProductIdentifiers(self.productIds!)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func updatePrice() {
        totalPrice = Int(membershipInfo[currentMembershipSelection]!)!
        totalPriceLabel.text = "￥\(totalPrice).00"
    }
    
    func displayStoreUI() {
        if products?.count >= 1 {
            var product : SKProduct?
            for p in products! {
                if productIds![currentMembershipSelection] as! String == p.productIdentifier {
                    product = p
                }
            }
            let payment = SKPayment(product: product!)
            SKPaymentQueue.defaultQueue().addPayment(payment)
        }
    }
    
    func paid() {
        TAOverlay.showOverlayWithLogoAndLabel("正在处理中...请稍候")
        
        Membership.payMembershipWithType(vipType) { (newMembership) -> Void in
            
            if newMembership != nil {
                TAOverlay.hideOverlay()
                
                self.currentMembership = newMembership
                self.updateViews()
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                    TAOverlay.showOverlayWithSuccessText("充值成功！感谢支持")
                })
            } else {
                TAOverlay.hideOverlay()
                TAOverlay.showOverlayWithError()
            }
        }
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "IsVIP")
    }
    
    // MARK: Transaction helper methods
    func transactionFinished(transaction : SKPaymentTransaction, wasSuccessful : Bool) {
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        
        let userInfo = NSDictionary(dictionary: ["transaction" : transaction])
        
        if wasSuccessful {
            // Send out a notification that we've finished the transaction
            NSNotificationCenter.defaultCenter().postNotificationName(kInAppPurchaseSucceededNotification, object: self, userInfo: userInfo as [NSObject : AnyObject])
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(kInAppPurchaseFailedNotification, object: self, userInfo: userInfo as [NSObject : AnyObject])
        }
    }
    
    func transactionCompleted(transaction : SKPaymentTransaction) {
        transactionFinished(transaction, wasSuccessful: true)
        paid()
    }
    
    func transactionFailed(transaction : SKPaymentTransaction) {
        transactionFinished(transaction, wasSuccessful: false)
    }
    
    func transactionRestored(transaction : SKPaymentTransaction) {
        transactionFinished(transaction, wasSuccessful: true)
        paid()
    }
    
    // Called when the payment is successful and received response from our server
    func paymentSucceeded() {
        fetchData(true)
    }
    
    /**
     Validate the product identifiers to the App Store
     
     - parameter productIdentifiers: productIdentifiers
     */
    func validateProductIdentifiers(productIdentifiers : NSArray) {
        TAOverlay.showOverlayWithLoading()
        
        if request == nil {
            let productsRequest = SKProductsRequest(productIdentifiers: NSSet(array: productIdentifiers as [AnyObject]) as! Set<String>)
            request = productsRequest
            productsRequest.delegate = self
            productsRequest.start()
        } else {
            TAOverlay.hideOverlay()
            displayStoreUI()
        }
    }
    
    // MARK: SKProductsRequestDelegate methods
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        products = response.products
        
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid identifier: \(invalidIdentifier)")
        }
        TAOverlay.hideOverlay()
        displayStoreUI()
    }
    
    // MARK: SKPaymentTransactionObserver methods
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .Purchased:
                transactionCompleted(transaction)
                break;
            case .Failed:
                transactionFailed(transaction)
                break;
            case .Restored:
                transactionRestored(transaction)
                break;
            default:
                break;
            }
        }
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
