//
//  PersonalCardViewController.swift
//  Abletive
//
//  Created by Cali on 11/15/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit

class PersonalCardViewController: UIViewController,PersonalCardSettingsDelegate,RKCardViewDelegate {

    let wallpapers : NSArray = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("PersonalCardWallpaper", ofType: "plist")!)!
    
    var qrCodeImageView: UIImageView!
    var qrCode : UIImage!
    var cardView : RKCardView!

    private let paddingX : CGFloat = 20
    private let paddingY : CGFloat = 70
    private let qrCodeSize : CGFloat = 220
    
    private var backgroundBlur : Bool = false
    private var qrCodeUrl : Bool = false
    private var backgroundIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "我的名片"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: #selector(PersonalCardViewController.showActionSheet))
        getUserDefaults()
        setupCard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        updateCardStyle()
    }
    
    func showActionSheet() {
        let alertController = UIAlertController(title: "名片操作", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)

        alertController.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "保存到相册", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.saveImageToAlbum()
        }))
        alertController.addAction(UIAlertAction(title: "扫二维码", style: .Default, handler: { (action) -> Void in
            self.navigationController?.pushViewController((self.storyboard?.instantiateViewControllerWithIdentifier("QRCodeScan"))!, animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "更改显示设置", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            self.changeSettings()
        }))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func saveImageToAlbum() {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(screenshot, self, nil, nil)
        MozTopAlertView.showWithType(MozAlertTypeSuccess, text: "保存成功", parentView: navigationController?.navigationBar)
    }
    
    private func changeSettings() {
        let settingTVC = storyboard?.instantiateViewControllerWithIdentifier("PersonalCardSettings") as! PersonalCardSettingsTableViewController
        settingTVC.delegate = self
        let popup = STPopupController(rootViewController: settingTVC)
        popup.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        popup.cornerRadius = 8
        popup.presentInViewController(self)
    }
    
    func settingsChanged(userInfo: NSDictionary) {
        updateCardStyle()
    }
    
    private func getUserDefaults() {
        backgroundIndex = NSUserDefaults.standardUserDefaults().integerForKey("card-backgroundIndex")
        backgroundBlur = NSUserDefaults.standardUserDefaults().boolForKey("card-blur")
        qrCodeUrl = NSUserDefaults.standardUserDefaults().boolForKey("card-qrCodeStyle")
    }
    
    private func setupCard() {
        cardView = RKCardView(frame: CGRect(x: paddingX, y: paddingY, width: view.frame.size.width-2*paddingX, height: view.frame.size.height-2*paddingY))
        cardView.titleLabel.text = NSUserDefaults.standardUserDefaults().objectForKey("user")?.objectForKey("displayname") as? String
        cardView.coverImageView.sd_setImageWithURL(NSURL(string: self.wallpapers.objectAtIndex(backgroundIndex) as! String), placeholderImage: UIImage(named: "LaunchLOGO.png"))
        cardView.profileImageView.sd_setImageWithURL(NSURL(string: NSUserDefaults.standardUserDefaults().stringForKey("user_avatar_path")!), placeholderImage: UIImage(named: "default-avatar"))
        cardView.addShadow()
        cardView.delegate = self
        
        let longPresser = UILongPressGestureRecognizer(target: self, action: #selector(PersonalCardViewController.showActionSheet))
        cardView.addGestureRecognizer(longPresser)
        
        if backgroundBlur {
            cardView.addBlur()
        }
        
        view.addSubview(cardView)
        
        if !qrCodeUrl {
            qrCode = CCQRCodeImage.createNonInterpolatedUIImageFormCIImage(CCQRCodeImage.createQRForString("abletive://user/\(NSUserDefaults.standardUserDefaults().objectForKey("user")?.objectForKey("id") as! Int)"), withSize: qrCodeSize)
        } else {
            qrCode = CCQRCodeImage.createNonInterpolatedUIImageFormCIImage(CCQRCodeImage.createQRForString("http://abletive.com/author/\(NSUserDefaults.standardUserDefaults().objectForKey("user")?.objectForKey("id") as! Int)"), withSize: qrCodeSize)
        }
        let qrCodeImage = CCQRCodeImage.imageBlackToTransparent(qrCode, withRed: 80, andGreen: 70, andBlue: 99)
        qrCodeImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: qrCodeSize * view.frame.size.height/667, height: qrCodeSize * view.frame.size.height/667)))
        qrCodeImageView.center = CGPoint(x: view.center.x, y: view.center.y + qrCodeImageView.frame.size.width/2)
        qrCodeImageView.image = qrCodeImage
        
        qrCodeImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        qrCodeImageView.layer.shadowRadius = 2
        qrCodeImageView.layer.shadowOpacity = 0.5
        qrCodeImageView.layer.shadowColor = AppColor.darkOverlay().CGColor
        
        view.addSubview(qrCodeImageView)
    }
    
    private func updateCardStyle() {
        getUserDefaults()
        if backgroundBlur {
            cardView.addBlur()
        } else {
            cardView.removeBlur()
        }
        
        cardView.coverImageView.sd_setImageWithURL(NSURL(string: self.wallpapers.objectAtIndex(backgroundIndex) as! String), placeholderImage: UIImage(named: "LaunchLOGO.png"))
        
        if !qrCodeUrl {
            qrCode = CCQRCodeImage.createNonInterpolatedUIImageFormCIImage(CCQRCodeImage.createQRForString("abletive://user/\(NSUserDefaults.standardUserDefaults().objectForKey("user")?.objectForKey("id") as! Int)"), withSize: qrCodeSize)
        } else {
            qrCode = CCQRCodeImage.createNonInterpolatedUIImageFormCIImage(CCQRCodeImage.createQRForString("http://abletive.com/author/\(NSUserDefaults.standardUserDefaults().objectForKey("user")?.objectForKey("id") as! Int)"), withSize: qrCodeSize)
        }
        let qrCodeImage = CCQRCodeImage.imageBlackToTransparent(qrCode, withRed: 80, andGreen: 70, andBlue: 99)
        
        qrCodeImageView.image = qrCodeImage
    }
    
    func coverPhotoTap() {
        changeSettings()
    }
    
    func profilePhotoTap() {
        changeSettings()
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
