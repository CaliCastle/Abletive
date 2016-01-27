//
//  MembershipRenewTableViewController.swift
//  Abletive
//
//  Created by Cali Castle on 12/19/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit
import Contacts
import PassKit

class PaymentTableViewController: UITableViewController, PKPaymentAuthorizationViewControllerDelegate {
    var isApplePayAvailable = false
    var totalAmount : String?
    var paymentToken : PKPaymentToken!
    var vipType : UInt = 0
    
    var success : Bool = false
    
    @available(iOS 9.2, *)
    static let supportedNetworks = [
        PKPaymentNetworkChinaUnionPay,
        PKPaymentNetworkMasterCard,
        PKPaymentNetworkVisa
    ]
    
    override func viewWillAppear(animated: Bool) {
        if #available(iOS 9.2, *) {
            if PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(PaymentTableViewController.supportedNetworks) {
                isApplePayAvailable = true
                
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "支付方式"
        contentSizeInPopup = CGSize(width: UIScreen.mainScreen().bounds.size.width, height: 160)
        
        tableView.backgroundColor = AppColor.secondaryBlack()
        tableView.separatorColor = AppColor.transparent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return isApplePayAvailable ? 2 : 1
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 130
        default:
            return 40
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("PaymentPrice") as! PaymentOrderPriceTableViewCell
            cell.priceLabel.text = "￥\(totalAmount!)"
            
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("RenewPayment", forIndexPath: indexPath)
            // Configure the cell...
            if indexPath.row == 1 {
                var button = UIButton()
                if #available(iOS 8.3, *) {
                    button = PKPaymentButton(type: .Buy, style: .White)
                } else {
                    // Fallback on earlier versions
                    button = UIButton()
                }
                button.addTarget(self, action: "applePayButtonPressed", forControlEvents: .TouchUpInside)
                
                button.center = cell.contentView.center
                button.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
                cell.contentView.addSubview(button)
            } else {
                let button = UIButton()
                button.frame = CGRect(origin: CGPointZero, size: CGSize(width: 142, height: 32))
                button.setTitle("支付方式 支付宝", forState: UIControlState.Normal)
                button.titleLabel?.font = UIFont.systemFontOfSize(11)
                
                button.addTarget(self, action: "alipayButtonPressed", forControlEvents: .TouchUpInside)
                
                button.backgroundColor = AppColor.registerButtonColor()
                button.tintColor = AppColor.mainWhite()
                button.layer.masksToBounds = true
                button.layer.cornerRadius = 8.5
                
                button.center = cell.contentView.center
                button.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
                cell.contentView.addSubview(button)
            }
            
            return cell
        }
    }

    func applePayButtonPressed() {
        // Set up our payment request.
        let paymentRequest = PKPaymentRequest()
        
        /*
        Our merchant identifier needs to match what we previously set up in
        the Capabilities window (or the developer portal).
        */
        paymentRequest.merchantIdentifier = AppConfiguration.Merchant.identifier
        
        /*
        Both country code and currency code are standard ISO formats. Country
        should be the region you will process the payment in. Currency should
        be the currency you would like to charge in.
        */
        paymentRequest.countryCode = "CN"
        paymentRequest.currencyCode = "CNY"
        
        // The networks we are able to accept.
        if #available(iOS 9.2, *) {
            paymentRequest.supportedNetworks = PaymentTableViewController.supportedNetworks
        } else {
            // Fallback on earlier versions
        }
        
        /*
        Ask your payment processor what settings are right for your app. In
        most cases you will want to leave this set to .Capability3DS.
        */
        paymentRequest.merchantCapabilities = .Capability3DS
        
        /*
        An array of `PKPaymentSummaryItems` that we'd like to display on the
        sheet (see the summaryItems function).
        */
        paymentRequest.paymentSummaryItems = makeSummaryItems()
        
        // Display the view controller.
        let viewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        viewController.delegate = self
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    func alipayButtonPressed() {
        let alertController = UIAlertController(title: "正在申请中...", message: "功能开发中，敬请期待", preferredStyle: .Alert)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func makeSummaryItems() -> [PKPaymentSummaryItem] {
        var items = [PKPaymentSummaryItem]()
        
        /*
        Product items have a label (a string) and an amount (NSDecimalNumber).
        NSDecimalNumber is a Cocoa class that can express floating point numbers
        in Base 10, which ensures precision. It can be initialized with a
        double, or in this case, a string.
        */
        let productSummaryItem = PKPaymentSummaryItem(label: "小计", amount: NSDecimalNumber(string: totalAmount))
        items += [productSummaryItem]
        
        let totalSummaryItem = PKPaymentSummaryItem(label: "Abletive VIP", amount: productSummaryItem.amount)
        
        items += [totalSummaryItem]
        
        return items
    }
    
    // MARK: - PKPaymentAuthorizationViewControllerDelegate
    
    /*
    This is where you would send your payment to be processed - here we will
    simply present a confirmation screen. If your payment processor failed the
    payment you would return `completion(.Failure)` instead. Remember to never
    attempt to decrypt the payment token on device.
    */
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {
        paymentToken = payment.token
        
        completion(.Success)
        
        TAOverlay.showOverlayWithLogoAndLabel("正在处理中...请稍候")
        
        Membership.payMembershipWithType(vipType) { (newMembership) -> Void in
            
            if newMembership != nil {
                TAOverlay.hideOverlay()
                
                NSNotificationCenter.defaultCenter().postNotificationName("PaymentSuccess", object: nil)
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                    TAOverlay.showOverlayWithSuccessText("充值成功！感谢支持")
                })
                
                self.success = true
            } else {
                TAOverlay.hideOverlay()
                TAOverlay.showOverlayWithError()
            }
            
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController){
        // We always need to dismiss our payment view controller when done.
        dismissViewControllerAnimated(true, completion: {
            if self.success {
                self.navigationController?.popViewControllerAnimated(true)
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
