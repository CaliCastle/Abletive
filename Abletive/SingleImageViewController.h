//
//  SingleImageViewController.h
//  Abletive
//
//  Created by Cali on 10/21/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SingleImageDelegate <NSObject>

- (void)imageSaved:(BOOL)success;

@end

@interface SingleImageViewController : UIViewController

@property (nonatomic,strong) UIImage *displayImage;
@property (nonatomic,strong) NSString *imageURL;

@property (nonatomic,weak) id <SingleImageDelegate> delegate;

@end
