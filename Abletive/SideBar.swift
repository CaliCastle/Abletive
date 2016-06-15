//
//  SideBar.swift
//  Abletive
//
//  Created by Cali on 11/21/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit

@objc protocol SideBarDelegate : NSObjectProtocol {
    func sideBarDidSelectOnIndex(_ index:Int)
    @objc optional func sideBarWillClose()
    @objc optional func sideBarWillOpen()
}

public class SideBar: NSObject,SideBarTableViewDelegate {
    
    let barWidth : CGFloat = 150.0
    let sideBarTableViewTopInset : CGFloat = 60.0
    let sideBarContainerView : UIView = UIView()
    let sideBarTableViewController : SideBarTableViewController = SideBarTableViewController()
    var originView : UIView = UIView()
    var animator : UIDynamicAnimator!
    weak var delegate : SideBarDelegate?
    var isSideBarOpen : Bool = false
    
    override init() {
        super.init()
    }
    
    init(sourceView:UIView, menuItems:Array<String>) {
        super.init()
        
        originView = sourceView
        sideBarTableViewController.tableData = menuItems
        
        setupSideBar()
        
        animator = UIDynamicAnimator(referenceView: originView)
        
//        let showGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector(handleSwipe(_:)))
//        showGestureRecognizer.direction = .Right
//        originView.addGestureRecognizer(showGestureRecognizer)
        
//        let hideGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SideBar.handleSwipe(_:)))
//        hideGestureRecognizer.direction = .Left
//        originView.addGestureRecognizer(hideGestureRecognizer)
    }
    
    func setupSideBar() {
        sideBarContainerView.frame = CGRect(x: -barWidth - 1, y: originView.frame.origin.y, width: barWidth, height: originView.frame.size.height)
        sideBarContainerView.backgroundColor = AppColor.transparent()
        sideBarContainerView.clipsToBounds = false
        
        originView.addSubview(sideBarContainerView)
        
//        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
//        blurView.frame = sideBarContainerView.frame
//        sideBarContainerView.addSubview(blurView)
        
        sideBarTableViewController.delegate = self
        sideBarTableViewController.tableView.frame = sideBarContainerView.bounds
        sideBarTableViewController.tableView.clipsToBounds = false
        sideBarTableViewController.tableView.separatorStyle = .none
        sideBarTableViewController.tableView.backgroundColor = AppColor.transparent()
        sideBarTableViewController.tableView.scrollsToTop = false
        sideBarTableViewController.tableView.contentInset = UIEdgeInsetsMake(sideBarTableViewTopInset, 0, 0, 0)
        
        sideBarTableViewController.tableView.reloadData()
        
        sideBarContainerView.addSubview(sideBarTableViewController.tableView)
    }
    
    func handleSwipe(_ gestureRecognizer:UISwipeGestureRecognizer) {
        if gestureRecognizer.direction == .left {
            showSideBar(false)
            delegate?.sideBarWillClose?()
        } else {
            showSideBar(true)
            delegate?.sideBarWillOpen?()
        }
    }
    
    func showSideBar(_ shouldOpen:Bool) {
        animator.removeAllBehaviors()
        isSideBarOpen = shouldOpen
        
        let gravityX : CGFloat = (shouldOpen) ? 0.5 : -0.5
        let magnitude : CGFloat = (shouldOpen) ? 20 : -20
        let boundaryX : CGFloat = (shouldOpen) ? barWidth : -barWidth - 1
        
        let gravityBehavior : UIGravityBehavior = UIGravityBehavior(items: [sideBarContainerView])
        gravityBehavior.gravityDirection = CGVector(dx: gravityX, dy: 0)
        animator.addBehavior(gravityBehavior)
        
        let collisionBehavior : UICollisionBehavior = UICollisionBehavior(items: [sideBarContainerView])
        collisionBehavior.addBoundary(withIdentifier: "sideBarBoundary", from: CGPoint(x: boundaryX, y: 20), to: CGPoint(x: boundaryX, y: originView.frame.size.height))
        animator.addBehavior(collisionBehavior)
        
        let pushBehavior : UIPushBehavior = UIPushBehavior(items: [sideBarContainerView], mode: .instantaneous)
        pushBehavior.magnitude = magnitude
        animator.addBehavior(pushBehavior)
        
        let sideBarBehavior : UIDynamicItemBehavior = UIDynamicItemBehavior(items: [sideBarContainerView])
        sideBarBehavior.elasticity = 0.3
        animator.addBehavior(sideBarBehavior)
        
    }
    
    func sideBarDidSelectOnRow(_ indexPath: IndexPath) {
        delegate?.sideBarDidSelectOnIndex((indexPath as NSIndexPath).row)
    }
}
