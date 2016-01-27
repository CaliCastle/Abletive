//
//  SinglePostHeaderViewController.h
//  Abletive
//
//  Created by Cali on 7/3/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostDetail.h"

@protocol SinglePostHeaderDelegate <NSObject>

- (void)openVideoWithURL:(NSString *)url;
- (void)openLinkWithURL:(NSString *)url;

- (void)showPhotos:(NSArray *)images atIndex:(NSUInteger)index;

@end

@interface SinglePostHeaderViewController : UIViewController

@property (nonatomic,strong) PostDetail *currentPost;
@property (nonatomic,weak) id<SinglePostHeaderDelegate> delegate;

@property (nonatomic,strong) NSMutableArray *imageViews;

@property (nonatomic,strong) NSMutableArray *videoViews;

@property (nonatomic,strong) NSMutableArray *linkLabels;

@property (nonatomic,strong) NSMutableArray *images;
@property (nonatomic,strong) NSMutableArray *videos;
@property (nonatomic,strong) NSMutableArray *links;

@property (nonatomic,strong) NSMutableArray *imagesWithAttribute;

@end
