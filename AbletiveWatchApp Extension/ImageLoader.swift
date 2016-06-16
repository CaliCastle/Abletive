//
//  ImageLoader.swift
//  extension
//
//  Created by Nate Lyman on 7/5/14.
//  Copyright (c) 2014 NateLyman.com. All rights reserved.
//
import UIKit
import Foundation

class ImageLoader {
    
    let cache = Cache<NSString, UIImage>()
    
    class var sharedLoader : ImageLoader {
        struct Static {
            static let instance : ImageLoader = ImageLoader()
        }
        return Static.instance
    }
    
    func imageForUrl(_ urlString: String, completionHandler:(image: UIImage?, url: String) -> ()) {
        DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosBackground).async(execute: {()in
            let data = self.cache.object(forKey: NSString(string: urlString))
            
            if data != nil {
                
                DispatchQueue.main.async(execute: {() in
                    completionHandler(image: data, url: urlString)
                })
                return
            }
            
            let downloadTask: URLSessionDataTask = URLSession.shared().dataTask(with: URL(string: urlString)!, completionHandler: {(data: Data?, response: URLResponse?, error: NSError?) -> Void in
                if (error != nil) {
                    completionHandler(image: nil, url: urlString)
                    return
                }
                
                if let data = data {
                    let image = UIImage(data: data)
                    self.cache.setObject(image!, forKey: urlString)
                    DispatchQueue.main.async(execute: {() in
                        completionHandler(image: image, url: urlString)
                    })
                    return
                }
                
            })
            downloadTask.resume()
        })
        
    }
}
