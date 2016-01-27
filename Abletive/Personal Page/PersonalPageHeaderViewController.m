//
//  PersonalPageHeaderViewController.m
//  Abletive
//
//  Created by Cali on 10/10/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PersonalPageHeaderViewController.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Rounded.h"
#import "CCGradientView.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define COUNT_PER_PAGE 20

static NSString * followButtonText = @"+关注";
static NSString * unfollowButtonText = @"已关注";
static NSString * followedEachOtherText = @"≒相互关注";

@interface PersonalPageHeaderViewController ()

@property (nonatomic,assign) NSUInteger currentFollowingPageIndex;
@property (nonatomic,assign) NSUInteger currentFollowerPageIndex;

@property (nonatomic,assign) NSUInteger currentFollowingCount;
@property (nonatomic,assign) NSUInteger currentFollowerCount;


@end

@implementation PersonalPageHeaderViewController{
    UIImageView *_backgroundImageView;
    BOOL _isRequestingFollowing;
    BOOL _isRequestingFollower;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentFollowingPageIndex = 1;
    self.currentFollowerPageIndex = 1;
    // Do any additional setup after loading the view from its nib.
    _backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -240, ScreenWidth, 335)];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:self.blurStyle];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    blurEffectView.frame = _backgroundImageView.frame;
    
    CCGradientView *gradientView = [[CCGradientView alloc]initWithFrame:CGRectMake(0, -240, ScreenWidth, 335) andMainColor:self.dominantColor];
    
    [self.view insertSubview:gradientView atIndex:0];
    
    [self.view insertSubview:blurEffectView atIndex:0];
    
    [self.view insertSubview:_backgroundImageView atIndex:0];
    
    self.view.frame = CGRectMake(0, 0, ScreenWidth, 200);
    
    self.nameLabel.textColor = self.secondHighlight;
    self.aboutMeLabel.textColor = self.firstHighlight;
    if (!self.isMyself) {
        self.aboutMeLabel.text = self.currentUser.aboutMe;
        self.nameLabel.text = self.currentUser.name;
    } else {
        self.aboutMeLabel.text = [[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"public_info"][@"description"];
        self.nameLabel.text = [[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"public_info"][@"display_name"];
    }
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarDidTap)];
    
    self.avatarImageView.userInteractionEnabled = YES;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 35.0f;
    self.avatarImageView.layer.borderWidth = 2.0f;
    self.avatarImageView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.2].CGColor;
    
    [self.avatarImageView addGestureRecognizer:tapper];
    
    self.profileSegmentedControl.tintColor = self.firstHighlight;
    [self.profileSegmentedControl setTitle:NSLocalizedString(@"资料", nil) forSegmentAtIndex:0];
    [self.profileSegmentedControl setTitle:NSLocalizedString(@"关注", nil) forSegmentAtIndex:1];
    [self.profileSegmentedControl setTitle:NSLocalizedString(@"粉丝", nil) forSegmentAtIndex:2];
    
    NSString *avatarString = [[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]unsignedIntegerValue] == self.currentUser.userID ? [[NSUserDefaults standardUserDefaults]stringForKey:@"user_avatar_path"] : self.currentUser.avatarPath;
    self.isMyself = [[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]unsignedIntegerValue] == self.currentUser.userID;
    
    [self.avatarImageView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:avatarString] andPlaceholderImage:[UIImage imageNamed:@"default-avatar"] options:SDWebImageContinueInBackground progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.avatarImageView.image = image;
        _backgroundImageView.image = image;
    }];
    if ([[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]integerValue] == self.currentUser.userID){
        // Myself viewing this
        [self.followButton setTitle:NSLocalizedString(@"自己", nil) forState:UIControlStateNormal];
    }
    [self loadPageData];
    self.followButton.enabled = NO;
    self.profileSegmentedControl.enabled = NO;
}


- (void)loadPageData {
    [User getPersonalPageDetailWithUserID:self.currentUser.userID andCurrentUserID:[[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]integerValue] andBlock:^(NSDictionary *JSON, NSError *error) {
        if (!error) {
            [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:JSON[@"avatar"]] options:SDWebImageContinueInBackground progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (!error) {
                    [[SDWebImageManager sharedManager]saveImageToCache:image forURL:imageURL];
                    _backgroundImageView.image = image;
                    self.avatarImageView.image = image;
                }
            }];
            self.userProfile = [UserProfile userProfileWithAttributes:[NSDictionary dictionaryWithDictionary:JSON]];
            // Follow button
            if (!self.isMyself){
                NSUInteger status = [JSON[@"follow_status"]integerValue];
                NSString *followText = nil;
                CGFloat cornerRadius = 0;
                UIColor *backgroundColor = [UIColor new];
                UIColor *foregroundColor = [UIColor new];
                SEL selector = nil;
                switch (status) {
                    case 2:
                        followText = NSLocalizedString(unfollowButtonText, nil);
                        cornerRadius = 15.0f;
                        backgroundColor = self.firstHighlight;
                        foregroundColor = self.dominantColor;
                        selector = @selector(unfollowUser);
                        self.followStatus = PersonalPageFollowStatusFollowed;
                        break;
                    case 1:
                        followText = NSLocalizedString(followButtonText, nil);
                        cornerRadius = 13.0f;
                        backgroundColor = self.dominantColor;
                        foregroundColor = self.firstHighlight;
                        self.followButton.layer.borderColor = foregroundColor.CGColor;
                        self.followButton.layer.borderWidth = 0.8f;
                        selector = @selector(followUser);
                        self.followStatus = PersonalPageFollowStatusNotFollowed;
                        break;
                    case 3:
                        followText = NSLocalizedString(followedEachOtherText, nil);
                        cornerRadius = 15.0f;
                        backgroundColor = self.firstHighlight;
                        foregroundColor = self.dominantColor;
                        selector = @selector(unfollowUser);
                        self.followStatus = PersonalPageFollowStatusFollowedEachOther;
                        break;
                    default:
                        followText = @"";
                        break;
                }
                self.followButton.enabled = YES;
                self.followButton.layer.masksToBounds = YES;
                self.followButton.layer.cornerRadius = cornerRadius;
                self.followButton.tintColor = foregroundColor;
                [self.followButton setBackgroundColor:backgroundColor];
                [self.followButton setTitle:followText forState:UIControlStateNormal];
                [self.followButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
            }
            UserGenderType gender = UserGenderOther;
            if ([JSON[@"gender"] isEqualToString:@"male"]) {
                gender = UserGenderMale;
            } else if ([JSON[@"gender"] isEqualToString:@"female"]){
                gender = UserGenderFemale;
            } else {
                gender = UserGenderOther;
            }

            NSString *profileText = @"";
            // Profile segment
            switch (gender) {
                case UserGenderMale:
                    profileText = NSLocalizedString(@"他的资料", nil);
                    break;
                case UserGenderFemale:
                    profileText = NSLocalizedString(@"她的资料", nil);
                    break;
                default:
                    profileText = NSLocalizedString(@"Ta的资料", nil);
                    break;
            }
            [self.profileSegmentedControl setTitle:self.isMyself ? NSLocalizedString(@"我的资料", nil) : profileText forSegmentAtIndex:0];
            // Following segement
            [self.profileSegmentedControl setTitle:[NSString stringWithFormat:@"关注 %@人",JSON[@"following_count"]] forSegmentAtIndex:1];
            self.currentFollowingCount = [JSON[@"following_count"] intValue];
            // Follower segment
            [self.profileSegmentedControl setTitle:[NSString stringWithFormat:@"粉丝 %@人",JSON[@"follower_count"]] forSegmentAtIndex:2];
            self.currentFollowerCount = [JSON[@"follower_count"] intValue];
            // Turn it back on
            self.profileSegmentedControl.enabled = YES;
            // Tell delegate to reload data
            [self.delegate reloadRows];
            [self.delegate imDoneLoading];
        }
    }];
}

- (void)loadFollowingUserList {
    if (!self.currentFollowingCount || _isRequestingFollowing) {
        return;
    }
    _isRequestingFollowing = YES;
    [self loadPageData];
    [User getFollowListByUserID:self.currentUser.userID andType:@"following" withPage:self.currentFollowingPageIndex forCountPerPage:COUNT_PER_PAGE andBlock:^(NSDictionary *JSON, NSError *error) {
        if (!error) {
            if (!self.followingList || self.currentFollowingPageIndex == 1) {
                self.followingList = [NSMutableArray array];
            }
            for (NSDictionary *userInfo in JSON[@"user_lists"]) {
                User *user = [User userWithAttributes:userInfo];
                [self.followingList addObject:user];
            }
            self.currentFollowingPageIndex++;
            [self.delegate reloadRows];
            [self.delegate imDoneLoading];
        }
        _isRequestingFollowing = NO;
        self.profileSegmentedControl.enabled = YES;
    }];
}

- (void)loadFollowerUserList {
    if (!self.currentFollowerCount || _isRequestingFollower) {
        return;
    }
    _isRequestingFollower = YES;
    [self loadPageData];
    [User getFollowListByUserID:self.currentUser.userID andType:@"follower" withPage:self.currentFollowerPageIndex forCountPerPage:COUNT_PER_PAGE andBlock:^(NSDictionary *JSON, NSError *error) {
        if (!error) {
            if (!self.followerList || self.currentFollowerPageIndex == 1) {
                self.followerList = [NSMutableArray array];
            }
            for (NSDictionary *userInfo in JSON[@"user_lists"]) {
                User *user = [User userWithAttributes:userInfo];
                [self.followerList addObject:user];
            }
            self.currentFollowerPageIndex++;
            [self.delegate reloadRows];
            [self.delegate imDoneLoading];
        }
        _isRequestingFollower = NO;
        self.profileSegmentedControl.enabled = YES;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentDidChange:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            if (!self.userProfile) {
                [self loadPageData];
            }
            break;
        case 1:
            if (!self.followingList) {
                [self loadFollowingUserList];
            }
            break;
        case 2:
            if (!self.followerList) {
                [self loadFollowerUserList];
            }
            break;
        default:
            break;
    }
    [self.delegate segementChangedAtIndex:sender.selectedSegmentIndex];
}

- (void)followUser {
    self.followButton.enabled = NO;
    if (![[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]integerValue]) {
        [self.delegate followActionSucceededWithStatus:2 andMessage:@"你必须登录才可以关注"];
        return;
    }
    [User followUserToWhom:self.currentUser.userID withCurrentUserID:[[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]integerValue] toFollow:YES andBlock:^(BOOL success, NSDictionary *JSON, NSError *error) {
        if (!error) {
            if (success) {
                // Do something to delegate
                self.followStatus = PersonalPageFollowStatusFollowed;
                [self.delegate followActionSucceededWithStatus:1 andMessage:JSON[@"msg"]];
                if ([JSON[@"type"]integerValue] == 2) {
                    [self.followButton setTitle:NSLocalizedString(followedEachOtherText, nil) forState:UIControlStateNormal];
                } else {
                    [self.followButton setTitle:NSLocalizedString(unfollowButtonText, nil) forState:UIControlStateNormal];
                }
                // Remove its original button action
                [self.followButton removeTarget:self action:@selector(followUser) forControlEvents:UIControlEventTouchUpInside];
                // Add a new one
                [self.followButton addTarget:self action:@selector(unfollowUser) forControlEvents:UIControlEventTouchUpInside];
                // Change the outline
                self.followButton.backgroundColor = self.firstHighlight;
                self.followButton.tintColor = self.dominantColor;
                self.followButton.layer.cornerRadius = 15.0f;
                self.followButton.layer.borderWidth = 0;
                self.followButton.layer.borderColor = [UIColor clearColor].CGColor;
            } else {
                [self.delegate followActionSucceededWithStatus:2 andMessage:JSON[@"msg"]];
            }
            self.followButton.enabled = YES;
        }
    }];
}

- (void)unfollowUser {
    self.followButton.enabled = NO;
    [User followUserToWhom:self.currentUser.userID withCurrentUserID:[[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]integerValue] toFollow:NO andBlock:^(BOOL success, NSDictionary *JSON, NSError *error) {
        if (!error) {
            if (success) {
                // Do something to delegate
                self.followStatus = PersonalPageFollowStatusNotFollowed;
                [self.delegate followActionSucceededWithStatus:1 andMessage:JSON[@"msg"]];
                [self.followButton setTitle:NSLocalizedString(followButtonText, nil) forState:UIControlStateNormal];
                // Remove its original button action
                [self.followButton removeTarget:self action:@selector(unfollowUser) forControlEvents:UIControlEventTouchUpInside];
                // Add a new one
                [self.followButton addTarget:self action:@selector(followUser) forControlEvents:UIControlEventTouchUpInside];
                // Change the outline
                self.followButton.backgroundColor = self.dominantColor;
                self.followButton.tintColor = self.firstHighlight;
                self.followButton.layer.cornerRadius = 13.0f;
                self.followButton.layer.borderColor = self.firstHighlight.CGColor;
                self.followButton.layer.borderWidth = 0.8f;
            } else {
                [self.delegate followActionSucceededWithStatus:2 andMessage:JSON[@"msg"]];
            }
            self.followButton.enabled = YES;
        }
    }];
}

- (void)followAction {
    if (!self.userProfile) {
        return;
    }
    switch (self.followStatus) {
        case PersonalPageFollowStatusFollowed:
        case PersonalPageFollowStatusFollowedEachOther:
            [self unfollowUser];
            break;
        default:
            [self followUser];
            break;
    }
}

- (void)avatarDidTap {
    [self.delegate showAvatar];
}

- (NSUInteger)getFollowingCount {
    if (!self.userProfile) {
        return 0;
    }
    return self.currentFollowingCount;
}

- (NSUInteger)getFollowerCount {
    if (!self.userProfile) {
        return 0;
    }
    return self.currentFollowerCount;
}

- (void)reloadProfileWithType:(PersonalPageViewType)type {
    self.profileSegmentedControl.enabled = NO;
    switch (type) {
        case PersonalPageViewTypeProfile:
        {
            [self loadPageData];
            break;
        }
        case PersonalPageViewTypeFollowing:
        {
            self.currentFollowingPageIndex = 1;
            [self loadFollowingUserList];
            break;
        }
        default:
        {
            self.currentFollowerPageIndex = 1;
            [self loadFollowerUserList];
            break;
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
