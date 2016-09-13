//
//  SideBarTableViewController.swift
//  Abletive
//
//  Created by Cali on 11/21/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit

protocol SideBarTableViewDelegate : NSObjectProtocol {
    func sideBarDidSelectOnRow(_ indexPath:IndexPath)
}

class SideBarTableViewController: UITableViewController {

    weak var delegate : SideBarTableViewDelegate?
    var tableData : Array<String> = []

    // MARK: - Table view data source
    
    override func viewDidLoad() {
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "SideBarCell")
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        tableView.backgroundView = blurView
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "SideBarCell")! as UITableViewCell

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "SideBarCell")
            // Configure the cell...
            cell?.backgroundColor = AppColor.transparent()
            cell?.textLabel?.textColor = UIColor.darkText
            
            let selectedView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedView.backgroundColor = AppColor.mainBlack().withAlphaComponent(0.3)
            
            cell?.selectedBackgroundView = selectedView
            
        }
        
        cell?.textLabel?.text = tableData[(indexPath as NSIndexPath).row]

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.sideBarDidSelectOnRow(indexPath)
    }

}
