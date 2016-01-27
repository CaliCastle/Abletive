//
//  MeLoggedHeaderViewController.h
//  Abletive
//
//  Created by Cali on 6/21/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHAlertView.h"
#import "VLDContextSheet.h"

@protocol MeLoggedHeaderViewDelegate <NSObject>

- (void)logoutButtonDidClick;
- (void)avatarLoadSucceeded;
- (void)collectionDidSelect;
- (void)profileDidSelect;

@end

@interface MeLoggedHeaderViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView * _Nullable iconView;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable nameLabel;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView * _Nullable backgroundImageView;

@property (weak,nonatomic) id <MeLoggedHeaderViewDelegate> _Nullable delegate;


- (void)setDataWithAttributes:(nonnull NSMutableDictionary *)attributes;
- (void)updateUserData;

@end
