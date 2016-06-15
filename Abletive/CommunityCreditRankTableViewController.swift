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
        tableView.indicatorStyle = .white
        
        fetchData()
    }

    func fetchData() {
        TAOverlay.showWithLogo()
        
        CreditRank.getWithLimit(50) { (rankList : Array?) -> Void in
            TAOverlay.hide()
            
            if rankList != nil {
                self.rankList = rankList as! Array<CreditRank>
                self.tableView.reloadData()
            } else {
                TAOverlay.showWithError()
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreditRankReuse", for: indexPath) as! CommunityCreditTableViewCell

        // Configure the cell...
        cell.rankLabel.text = "#\((indexPath as NSIndexPath).row+1)"
        cell.creditRank = rankList[(indexPath as NSIndexPath).row]
        
        switch (indexPath as NSIndexPath).row {
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let creditRank = rankList[(indexPath as NSIndexPath).row]
        let user : User = User()
        
        user.name = creditRank.name
        user.avatarPath = creditRank.avatarURL
        user.userID = creditRank.userID
        
        let personalPageTVC = storyboard?.instantiateViewController(withIdentifier: "PersonalPage") as! PersonalPageTableViewController
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
