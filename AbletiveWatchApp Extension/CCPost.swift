//
//  CCPost.swift
//  Abletive
//
//  Created by Cali Castle on 1/14/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import Foundation

public class CCPost : NSObject {
    var title : String = ""
    var author : String = ""
    var thumbnailURL : String?
    
    private static var posts : Array<CCPost> = []
    
    static let sharedInstance = CCPost()
    
    override init() {
        
    }
    
    init(attributes : NSDictionary) {
        title = attributes["title"] as! String
        author = attributes["author"]!["nickname"] as! String
        thumbnailURL = attributes["thumbnail"] as? String
    }
    
    class func allPosts() -> Array<CCPost> {
        return posts
    }
    
    class func fetchPosts(page : UInt = 1, count : UInt = 5, callback: (posts : Array<CCPost>) -> Void) {
        let request = NSURLRequest(URL: NSURL(string: "https://abletive.com/api/get_posts?page=\(page)&count=\(count)")!)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
            if error == nil {
                // Request succeeded
                do {
                    let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    let postsJSON = JSON["posts"] as! NSArray
                    for postJSON in postsJSON {
                        let post = CCPost(attributes: postJSON as! NSDictionary)
                        posts.append(post)
                    }
                    
                    callback(posts: posts)
                }
                catch _ {
                    // Error handling
                }
            }
            }.resume()
    }
    
    class func latest(callback: (post : CCPost) -> Void) {
        let request = NSURLRequest(URL: NSURL(string: "https://abletive.com/api/get_posts?page=1&count=1")!)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
            if error == nil {
                do {
                    let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    let postJSON = JSON["posts"] as! NSArray
                    
                    let post = CCPost(attributes: postJSON.firstObject as! NSDictionary)
                    
                    callback(post: post)
                }
                catch _ {
                    // Error handling
                }
            }
        }.resume()
    }
}