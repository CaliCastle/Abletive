//
//  PersonalPageHeaderViewController.h
//  Abletive
//
//  Created by Cali on 10/10/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "UserProfile.h"

typedef NS_ENUM(NSUInteger,PersonalPageViewType) {
    PersonalPageViewTypeProfile,
    PersonalPageViewTypeFollowing,
    PersonalPageViewTypeFollower
};

typedef NS_ENUM(NSUInteger,PersonalPageFollowStatus) {
    PersonalPageFollowStatusFollowed,
    PersonalPageFollowStatusFollowedEachOther,
    PersonalPageFollowStatusNotFollowed
};

@protocol PersonalPageHeaderDelegate <NSObject>

- (void)segementChangedAtIndex:(NSUInteger)index;
- (void)followActionSucceededWithStatus:(NSUInteger)status andMessage:(NSString *)message;
- (void)showAvatar;
- (void)reloadRows;
- (void)imDoneLoading;

@end


@interface PersonalPageHeaderViewController : UIViewController

@property (nonatomic,weak) id<PersonalPageHeaderDelegate> delegate;

@property (nonatomic,assign) BOOL isMyself;

@property (nonatomic,weak) User *currentUser;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutMeLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *profileSegmentedControl;

@property (nonatomic,assign) UIBlurEffectStyle blurStyle;

@property (nonatomic,strong) UIColor *dominantColor;
@property (nonatomic,strong) UIColor *firstHighlight;
@property (nonatomic,strong) UIColor *secondHighlight;

@property (nonatomic,strong) UserProfile *userProfile;
@property (nonatomic,strong) NSMutableArray *followingList;
@property (nonatomic,strong) NSMutableArray *followerList;

@property (nonatomic,assign) PersonalPageFollowStatus followStatus;

- (void)loadFollowerUserList;
- (void)loadFollowingUserList;

- (NSUInteger)getFollowingCount;
- (NSUInteger)getFollowerCount;

- (void)reloadProfileWithType:(PersonalPageViewType)type;

- (void)followAction;

@end
