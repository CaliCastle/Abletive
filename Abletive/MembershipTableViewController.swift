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
    let productIds = NSArray(contentsOf: Bundle.main().urlForResource("product_ids", withExtension: "plist")!)
    
    let kInAppPurchaseFailedNotification = "kInAppPurchaseFailedNotification"
    let kInAppPurchaseSucceededNotification = "kInAppPurchaseSucceededNotification"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "我的会员"
        
        setupViews()

//        avatarImageView.sd_setImage(with: URL(string: UserDefaults.standard().string(forKey: "user_avatar_path")!), placeholderImage: UIImage(named: "default-avatar")) { (image, error, type, url) -> Void in
//            let backgroundImageView = UIImageView(frame: self.view.frame)
//            backgroundImageView.contentMode = .scaleAspectFill
//            backgroundImageView.image = (error == nil) ? self.avatarImageView.image : UIImage(named: "default-avatar")
//            
//            let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
//            blurEffectView.frame = backgroundImageView.frame
//            backgroundImageView.addSubview(blurEffectView)
//            self.tableView.backgroundView = backgroundImageView
//        }
        avatarImageView.sd_setImage(with: URL(string: UserDefaults.standard().string(forKey: "user_avatar_path")!), placeholderImage: UIImage(named: "default-avatar"))
        let backgroundImageView = UIImageView(frame: self.view.frame)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = self.avatarImageView.image
        
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurEffectView.frame = backgroundImageView.frame
        backgroundImageView.addSubview(blurEffectView)
        self.tableView.backgroundView = backgroundImageView
        
        view.backgroundColor = AppColor.transparent()
        tableView.backgroundColor = AppColor.darkTranslucent()
        tableView.separatorColor = AppColor.transparent()
        tableView.indicatorStyle = .white
        
        fetchData()
        loadFromStore()
    }
    
    func loadFromStore() {
        SKPaymentQueue.default().add(self)
    }
    
    func fetchData(_ fromNotification:Bool = false) {
        if !fromNotification {
            TAOverlay.showWithLogo()
        }
        Membership.getCurrentMembership { (membership) -> Void in
            if !fromNotification {
                TAOverlay.hide()
            }
            if membership != nil {
                self.currentMembership = membership!
                self.updateViews()
                self.updatePrice()
            } else {
                TAOverlay.showWithError()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func setupViews(){
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 8
        avatarImageView.layer.borderColor = AppColor.lightSeparator().cgColor
        avatarImageView.layer.borderWidth = 1
    }

    func updateViews(){
        startTimeLabel.text = currentMembership?.startTime == "N/A" ? currentMembership?.startTime : CCDateToString.getFromDate(currentMembership?.startTime)
        startTimeLabel.textColor = AppColor.lightTranslucent()
        endTimeLabel.text = currentMembership?.endTime == "N/A" ? currentMembership?.endTime : CCDateToString.getFromDate(currentMembership?.endTime)
        endTimeLabel.textColor = AppColor.lightTranslucent()
        membershipTypeLabel.text = currentMembership?.type
        membershipTypeLabel.textColor = AppColor.mainYellow()
        membershipStatusLabel.text = currentMembership?.status
        membershipStatusLabel.textColor = AppColor.lightTranslucent()
        
        switch currentMembership?.type {
            case "过期会员"?:
                memberBadgeImageView.image = UIImage(named: "membership-expired")?.withRenderingMode(.alwaysTemplate)
                break;
            case "月费会员"?:
                memberBadgeImageView.image = UIImage(named: "monthly-membership")?.withRenderingMode(.alwaysTemplate)
                break;
            case "季费会员"?:
                memberBadgeImageView.image = UIImage(named: "seasonly-membership")?.withRenderingMode(.alwaysTemplate)
                break;
            case "年费会员"?:
                memberBadgeImageView.image = UIImage(named: "yearly-membership")?.withRenderingMode(.alwaysTemplate)
                break;
            case "终身会员"?:
                canRenew = false
                memberBadgeImageView.image = UIImage(named: "eternal-membership")?.withRenderingMode(.alwaysTemplate)
                break;
            default:
                break;
        }
        memberBadgeImageView.tintColor = AppColor.mainWhite()
        
        renewButton.layer.masksToBounds = true
        renewButton.layer.cornerRadius = 8
        renewButton.backgroundColor = AppColor.loginButtonColor()
        renewButton.tintColor = AppColor.mainWhite()
        renewButton.layer.shadowColor = AppColor.darkOverlay().cgColor
        renewButton.layer.shadowRadius = 5
        renewButton.isEnabled = canRenew
    }
    
    @IBAction func membershipSelectionDidChange(_ sender: UISegmentedControl) {
        currentMembershipSelection = sender.selectedSegmentIndex
        updatePrice()
    }
    
    @IBAction func renewDidClick(_ sender: UIButton) {
        vipType = UInt(currentMembershipSelection + 1)
        
        let alertController = UIAlertController(title: "确认您的购买选择", message: "确定要购买价值￥\(totalPrice)的\(membershipNames[currentMembershipSelection])吗?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) -> Void in
            
        }
        let confirmAction = UIAlertAction(title: "确定", style: .destructive) { (action) -> Void in
            self.validateProductIdentifiers(self.productIds!)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        present(alertController, animated: true, completion: nil)
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
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func paid() {
        TAOverlay.show(withLogoAndLabel: "正在处理中...请稍候")
        
        Membership.pay(withType: vipType) { (newMembership) -> Void in
            
            if newMembership != nil {
                TAOverlay.hide()
                
                self.currentMembership = newMembership
                self.updateViews()
                
                DispatchQueue.main.after(when: DispatchTime.now() + Double(Int64(3 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                    TAOverlay.show(withSuccessText: "充值成功！感谢支持")
                })
                
            } else {
                TAOverlay.hide()
                TAOverlay.showWithError()
            }
        }
        
        UserDefaults.standard().set(true, forKey: "IsVIP")
    }
    
    // MARK: Transaction helper methods
    func transactionFinished(_ transaction : SKPaymentTransaction, wasSuccessful : Bool) {
        SKPaymentQueue.default().finishTransaction(transaction)
        
        let userInfo = NSDictionary(dictionary: ["transaction" : transaction])
        
        if wasSuccessful {
            // Send out a notification that we've finished the transaction
            NotificationCenter.default().post(name: Notification.Name(rawValue: kInAppPurchaseSucceededNotification), object: self, userInfo: userInfo as [NSObject : AnyObject])
        } else {
            NotificationCenter.default().post(name: Notification.Name(rawValue: kInAppPurchaseFailedNotification), object: self, userInfo: userInfo as [NSObject : AnyObject])
        }
    }
    
    func transactionCompleted(_ transaction : SKPaymentTransaction) {
        transactionFinished(transaction, wasSuccessful: true)
        paid()
    }
    
    func transactionFailed(_ transaction : SKPaymentTransaction) {
        transactionFinished(transaction, wasSuccessful: false)
    }
    
    func transactionRestored(_ transaction : SKPaymentTransaction) {
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
    func validateProductIdentifiers(_ productIdentifiers : NSArray) {
        TAOverlay.showWithLoading()
        
        if request == nil {
            let productsRequest = SKProductsRequest(productIdentifiers: NSSet(array: productIdentifiers as [AnyObject]) as! Set<String>)
            request = productsRequest
            productsRequest.delegate = self
            productsRequest.start()
        } else {
            TAOverlay.hide()
            displayStoreUI()
        }
    }
    
    // MARK: SKProductsRequestDelegate methods
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid identifier: \(invalidIdentifier)")
        }
        TAOverlay.hide()
        displayStoreUI()
    }
    
    // MARK: SKPaymentTransactionObserver methods
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                transactionCompleted(transaction)
                break;
            case .failed:
                transactionFailed(transaction)
                break;
            case .restored:
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
