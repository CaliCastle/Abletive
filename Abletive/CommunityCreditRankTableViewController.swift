//
//  CommunityCreditRankTableViewController.swift
//  Abletive
//
//  Created by Cali Castle on 1/16/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class CommunityCreditRankTableViewController: UITableViewController {

    var rankList : Array<CreditRank> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.indicatorStyle = .White
        
        fetchData()
    }

    func fetchData() {
        TAOverlay.showOverlayWithLogo()
        
        CreditRank.getCreditRankWithLimit(50) { (rankList : Array?) -> Void in
            TAOverlay.hideOverlay()
            
            if rankList != nil {
                self.rankList = rankList as! Array<CreditRank>
                self.tableView.reloadData()
            } else {
                TAOverlay.showOverlayWithError()
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CreditRankReuse", forIndexPath: indexPath) as! CommunityCreditTableViewCell

        // Configure the cell...
        cell.rankLabel.text = "#\(indexPath.row+1)"
        cell.creditRank = rankList[indexPath.row]
        
        switch indexPath.row {
        case 0:
            cell.rankLabel.textColor = AppColor.loginButtonColor()
            break
        case 1:
            cell.rankLabel.textColor = AppColor.mainRed()
            break
        case 2:
            cell.rankLabel.textColor = AppColor.registerButtonColor()
            break
        default:
            cell.rankLabel.textColor = AppColor.lightTranslucent()
            break
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let creditRank = rankList[indexPath.row]
        let user : User = User()
        
        user.name = creditRank.name
        user.avatarPath = creditRank.avatarURL
        user.userID = creditRank.userID
        
        let personalPageTVC = storyboard?.instantiateViewControllerWithIdentifier("PersonalPage") as! PersonalPageTableViewController
        personalPageTVC.currentUser = user
        
        navigationController?.pushViewController(personalPageTVC, animated: true)
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
