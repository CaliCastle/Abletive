//
//  SideBarTableViewController.swift
//  Abletive
//
//  Created by Cali on 11/21/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit

protocol SideBarTableViewDelegate : NSObjectProtocol {
    func sideBarDidSelectOnRow(indexPath:NSIndexPath)
}

class SideBarTableViewController: UITableViewController {

    weak var delegate : SideBarTableViewDelegate?
    var tableData : Array<String> = []

    // MARK: - Table view data source
    
    override func viewDidLoad() {
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "SideBarCell")
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        tableView.backgroundView = blurView
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("SideBarCell")! as UITableViewCell

        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "SideBarCell")
            // Configure the cell...
            cell?.backgroundColor = AppColor.transparent()
            cell?.textLabel?.textColor = UIColor.darkTextColor()
            
            let selectedView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedView.backgroundColor = AppColor.mainBlack().colorWithAlphaComponent(0.3)
            
            cell?.selectedBackgroundView = selectedView
            
        }
        
        cell?.textLabel?.text = tableData[indexPath.row]

        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.sideBarDidSelectOnRow(indexPath)
    }

}
