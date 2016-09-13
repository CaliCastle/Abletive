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
    
    let cache = NSCache<NSString, UIImage>()
    
    class var sharedLoader : ImageLoader {
        struct Static {
            static let instance : ImageLoader = ImageLoader()
        }
        return Static.instance
    }
    
    func imageForUrl(_ urlString: String, completionHandler:@escaping (_ image: UIImage?, _ url: String) -> ()) {
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
            let data = self.cache.object(forKey: NSString(string: urlString))
            
            if data != nil {
                
                DispatchQueue.main.async(execute: {() in
                    completionHandler(data, urlString)
                })
                return
            }
            
            let downloadTask : URLSessionDataTask = URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) in
                if (error != nil) {
                    completionHandler(nil, urlString)
                    return
                }
                
                if let data = data {
                    let image = UIImage(data: data)
                    self.cache.setObject(image!, forKey: urlString as NSString)
                    DispatchQueue.main.async(execute: {() in
                        completionHandler(image, urlString)
                    })
                    return
                }
            })
            downloadTask.resume()
        }
    }
}
