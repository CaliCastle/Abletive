//
//  WelcomeViewController.swift
//  Abletive
//
//  Created by Cali Castle on 1/17/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController,UIScrollViewDelegate {

    var screenWidth : Int = Int(UIScreen.main.bounds.size.width)
    var screenHeight : Int = Int(UIScreen.main.bounds.size.height)
    
    let pageControl = UIPageControl(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 30)))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.setStatusBarHidden(true, with: .slide)
        // Do any additional setup after loading the view.
        let scrollView = UIScrollView(frame: UIScreen.main.bounds)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width * 5, height: UIScreen.main.bounds.size.height)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        
        pageControl.center = CGPoint(x: view.center.x, y: CGFloat(screenHeight) - pageControl.bounds.size.height - 15.0)
        pageControl.numberOfPages = 5
        pageControl.pageIndicatorTintColor = AppColor.darkOverlay()
        pageControl.currentPageIndicatorTintColor = AppColor.mainYellow()
        
        for index in 0..<5 {
            var screenShot = UIImage()
            if screenHeight == 480 {
                screenShot = UIImage(named: "ScreenShot-\(index+1)")!
            } else {
                screenShot = UIImage(named: "\(screenWidth)ScreenShot-\(index+1)")!
            }
            
            let imageView = UIImageView(image: screenShot)
            imageView.frame = CGRect(origin: CGPoint(x:  CGFloat(screenWidth * index), y: 0), size: UIScreen.main.bounds.size)
            
            if index == 4 {
                let tapper = UITapGestureRecognizer(target: self, action: #selector(WelcomeViewController.lastOneTapped))
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(tapper)
            }
            imageView.contentMode = .scaleToFill
            scrollView.addSubview(imageView)
        }
        view.addSubview(scrollView)
        view.addSubview(pageControl)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.setStatusBarHidden(false, with: .slide)
    }
    
    func lastOneTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / screenWidth
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
