//
//  PersonalPageTableViewController.m
//  Abletive
//
//  Created by Cali on 10/9/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "UINavigationBar+Awesome.h"
#import "PersonalPageTableViewController.h"
#import "PersonalPageFollowTableViewCell.h"
#import "PersonalPageCommentTableViewController.h"
#import "PersonalPageCollectionTableViewController.h"
#import "PersonalPageOrderTableViewController.h"
#import "PersonalPageCreditTableViewController.h"
#import "SortPostTableViewController.h"
#import "UIImageView+WebCache.h"
#import "SOZOChromoplast.h"
#import "KINWebBrowserViewController.h"
#import "ZFModalTransitionAnimator.h"
#import "CBStoreHouseRefreshControl.h"
#import "TAOverlay.h"
#import "AppColor.h"
#import "MLPhotoBrowserAssets.h"
#import "MLPhotoBrowserViewController.h"
#import "ChatMessageTableViewController.h"

#import "CCDeviceDetecter.h"

#define NAVBAR_CHANGE_POINT 110
#define BLUR_EFFECT_CHANGE_POINT -85
#define SCROLL_EVENT_POINT -210
#define PROGRESS_SIZE 50
#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define USERS_PER_PAGE 20
#define USER_TABLE_CELL_HEIGHT 70
#define HEADER_MARGIN 20

static NSString * const profileReuseIdentifier = @"ProfileReuse";
static NSString * const followingReuseIdentifier = @"FollowingReuse";
static NSString * const followerReuseIdentifier = @"FollowerReuse";
static NSString * const followReuseIdentifier = @"FollowReuse";

@interface PersonalPageTableViewController () <PersonalPageHeaderDelegate,UIViewControllerPreviewingDelegate>

@property (nonatomic,strong) SOZOChromoplast *chromoplast;

@property (nonatomic, strong) CBStoreHouseRefreshControl *headerRefreshControl;

@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic,assign) BOOL isLightTheme;

@property (nonatomic,strong) UIColor *fadedTextColor;

@property (nonatomic,assign) BOOL isMyself;

@property (nonatomic,strong) ZFModalTransitionAnimator *animator;

@property (nonatomic,strong) MLPhotoBrowserPhoto *avatar;

@end

@implementation PersonalPageTableViewController {
    BOOL _isLoading;
}

- (User *)currentUser {
    if (!_currentUser) {
        _currentUser = [User userWithAttributes:[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"]];
    }
    return _currentUser;
}

- (SOZOChromoplast *)chromoplast {
    if (!_chromoplast) {
        _chromoplast = [[SOZOChromoplast alloc]initWithImage:[UIImage imageNamed:@"default-avatar"]];
    }
//    [self.view setNeedsDisplay];
    return _chromoplast;
}

- (PersonalPageHeaderViewController *)headerViewController {
    if (!_headerViewController) {
        _headerViewController = [[PersonalPageHeaderViewController alloc]initWithNibName:@"PersonalPageHeaderViewController" bundle:[NSBundle mainBundle]];
    }
    return _headerViewController;
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, PROGRESS_SIZE, PROGRESS_SIZE)];
        _activityIndicator.center = CGPointMake(ScreenWidth/2, ScreenHeight/2);
        _activityIndicator.activityIndicatorViewStyle = self.isLightTheme?UIActivityIndicatorViewStyleGray:UIActivityIndicatorViewStyleWhite;
    }
    return _activityIndicator;
}

- (UIColor *)fadedTextColor {
    if (!_fadedTextColor) {
        CGColorRef colorRef = self.chromoplast.firstHighlight.CGColor;
        _fadedTextColor = [UIColor colorWithRed:CGColorGetComponents(colorRef)[0] green:CGColorGetComponents(colorRef)[1] blue:CGColorGetComponents(colorRef)[2] alpha:0.55];
    }
    return _fadedTextColor;
}

- (MLPhotoBrowserPhoto *)avatar {
    if (!_avatar) {
        _avatar = [[MLPhotoBrowserPhoto alloc]init];
        _avatar.toView = self.headerViewController.avatarImageView;
//        _avatar.photoURL = [NSURL URLWithString:self.currentUser.avatarPath];
        _avatar.photoImage = self.headerViewController.avatarImageView.image;
    }
    return _avatar;
}

#pragma mark ==== View related methods ====

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.currentUser.name && [[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]unsignedIntegerValue] != self.currentUser.userID) {
        self.title = self.currentUser.name;
        self.isMyself = NO;
    } else {
        self.title = [[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"public_info"][@"display_name"];
        self.currentUser.name = self.title;
        self.isMyself = YES;
    }
    
    // Initialize
    self.currentViewType = PersonalPageViewTypeProfile;
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    UIImageView *profileImageView = [UIImageView new];
    
    NSString *avatarString = self.isMyself ? [[NSUserDefaults standardUserDefaults]stringForKey:@"user_avatar_path"] : self.currentUser.avatarPath;
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:avatarString] placeholderImage:[UIImage imageNamed:@"default-avatar"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            [TAOverlay showOverlayWithErrorText:@"头像加载失败，请重新登录"];
            if (self.navigationController) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        } else {
            self.chromoplast = [[SOZOChromoplast alloc]initWithImage:image];
            [self setUpHeaderView];
            self.navigationController.navigationBar.tintColor = self.chromoplast.secondHighlight;
            [self scrollViewDidScroll:self.tableView];
            [self updateStatusBarColorWithChromoplast:self.chromoplast];
            self.view.backgroundColor = self.chromoplast.dominantColor;
            
            self.headerRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.tableView target:self refreshAction:@selector(headerRefreshTriggered:) plist:@"abletive-logo" color:self.chromoplast.firstHighlight lineWidth:1.2f dropHeight:100 scale:0.95f horizontalRandomness:350 reverseLoadingAnimation:YES internalAnimationFactor:0.8f];
            self.headerRefreshControl.hidden = YES;
        }
    }];

    if (!self.isMyself && [self userLoggedIn]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"private_message"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleDone target:self action:@selector(messageButtonDidTap)];
    }
    
    self.navigationItem.rightBarButtonItem.tintColor = self.chromoplast.firstHighlight;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[AppColor transparent]};
    self.navigationController.navigationBar.backgroundColor = [AppColor transparent];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = self.chromoplast.dominantColor;
    
    self.clearsSelectionOnViewWillAppear = YES;
    
    [self setUpHeaderView];
    
    self.tableView.indicatorStyle = self.isLightTheme ? UIScrollViewIndicatorStyleBlack : UIScrollViewIndicatorStyleWhite;
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:profileReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"PersonalPageFollowTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:followingReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"PersonalPageFollowTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:followerReuseIdentifier];
//    [self.tableView registerNib:[UINib nibWithNibName:@"PersonalPageFollowTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:followReuseIdentifier];
    
    // Reset Navigation Bar Style
    [self.navigationController.navigationBar lt_setBackgroundColor:[AppColor transparent]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[AppColor transparent]};
    
    if (IOS_VERSION_9_OR_ABOVE) {
        [self registerForPreviewingWithDelegate:self sourceView:self.tableView];
    }
    
    [self scrollViewDidScroll:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self updateStatusBarColorWithChromoplast:self.chromoplast];
    [self.navigationController.navigationBar lt_setBackgroundColor:[AppColor transparent]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[AppColor transparent]};
    self.navigationController.navigationBar.tintColor = self.chromoplast.firstHighlight;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    if (self.isMyself || ![self userLoggedIn]) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    
    [self scrollViewDidScroll:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.tintColor = self.chromoplast.firstHighlight;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self scrollViewDidScroll:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar lt_reset];
    self.navigationController.navigationBar.tintColor = [AppColor mainYellow];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[AppColor mainWhite]};
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController.navigationBar lt_reset];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[AppColor mainWhite]};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)userLoggedIn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"user_is_logged"];
}

- (void)setUpHeaderView {
    self.headerViewController.delegate = self;
    self.headerViewController.dominantColor = self.chromoplast.dominantColor;
    self.headerViewController.firstHighlight = self.chromoplast.firstHighlight;
    self.headerViewController.secondHighlight = self.chromoplast.secondHighlight;
    self.headerViewController.isMyself = self.isMyself;
    if ([[UIColor whiteColor] sozo_isCompatibleWithColor:[self.chromoplast dominantColor]]) {
        self.headerViewController.blurStyle = UIBlurEffectStyleDark;
    } else {
        self.headerViewController.blurStyle = UIBlurEffectStyleLight;
    }
    self.headerViewController.currentUser = self.currentUser;
    self.tableView.tableHeaderView = self.headerViewController.view;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.headerRefreshControl.hidden = NO;
    [self.headerRefreshControl scrollViewDidScroll];
    
    UIColor *mainColor = self.chromoplast.dominantColor;
    UIColor *secondaryColor = self.chromoplast.firstHighlight;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > NAVBAR_CHANGE_POINT) {
        CGFloat alpha = MIN(1, 1 - ((NAVBAR_CHANGE_POINT + 64 - offsetY) / 64));
        [self.navigationController.navigationBar lt_setBackgroundColor:[mainColor colorWithAlphaComponent:alpha]];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[secondaryColor colorWithAlphaComponent:alpha]};
    } else if (offsetY <= BLUR_EFFECT_CHANGE_POINT) {
        CGFloat alpha = MAX(0, MIN(1, ABS(ABS(offsetY / BLUR_EFFECT_CHANGE_POINT) - ABS(offsetY + BLUR_EFFECT_CHANGE_POINT) / 81.5) - ABS(offsetY/85 - BLUR_EFFECT_CHANGE_POINT/85)));
        [self.headerViewController changeBlurEffectWithAlpha:alpha];

    } else {
        [self.navigationController.navigationBar lt_setBackgroundColor:[mainColor colorWithAlphaComponent:0]];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor clearColor]};
    }
    
    if (self.currentViewType == PersonalPageViewTypeFollowing || self.currentViewType == PersonalPageViewTypeFollower) {
        if (scrollView.frame.size.height >= scrollView.contentSize.height - offsetY) {
            if (_isLoading) {
                return;
            }
            if (self.currentViewType == PersonalPageViewTypeFollowing) {
                if ([self.headerViewController getFollowingCount] < USERS_PER_PAGE) {
                    return;
                }
                _isLoading = YES;
                [self.headerViewController loadFollowingUserList];
            } else {
                if ([self.headerViewController getFollowerCount] < USERS_PER_PAGE) {
                    return;
                }
                _isLoading = YES;
                [self.headerViewController loadFollowerUserList];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.headerRefreshControl scrollViewDidEndDragging];
}

- (void)updateStatusBarColorWithChromoplast:(SOZOChromoplast *)chromoplast {
    if ([[UIColor whiteColor] sozo_isCompatibleWithColor:[chromoplast dominantColor]]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        self.isLightTheme = NO;
    } else {
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        self.isLightTheme = YES;
    }
}

- (void)showModalPresentation:(UIViewController *)vc andBlock:(void (^ __nullable)(void))block{
    vc.modalPresentationStyle = UIModalPresentationCustom;
    self.animator = [[ZFModalTransitionAnimator alloc]initWithModalViewController:vc];
    self.animator.dragable = YES;
    self.animator.bounces = YES;
    self.animator.behindViewAlpha = 0.5f;
    self.animator.behindViewScale = 0.65f;
    self.animator.transitionDuration = 0.7f;
    self.animator.direction = ZFModalTransitonDirectionRight;
    
    [self presentViewController:vc animated:YES completion:nil];
    
    if (block) {
        block();
    }
}

- (UIView *)setHeaderForSectionWithTitle:(NSString *)title {
    // create the parent view that will hold header Label
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, ScreenWidth, 44.0)];
    
    // create the button object
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = self.fadedTextColor;
    headerLabel.highlightedTextColor = self.isLightTheme?[AppColor darkTranslucent]:[AppColor lightTranslucent];
    headerLabel.font = [UIFont boldSystemFontOfSize:15];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortraitUpsideDown || orientation == UIInterfaceOrientationPortrait) {
        headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
    }
    else {
        headerLabel.frame = CGRectMake(30.0, -10.0, 300.0, 44.0);
    }
    
    headerLabel.text = NSLocalizedString(title, nil);
    [customView addSubview:headerLabel];
    
    return customView;
}
                                 
- (void)headerRefreshTriggered:(id)sender {
    [self.headerViewController reloadProfileWithType:self.currentViewType];
}

#pragma mark - Delegate Events

- (void)messageButtonDidTap {
    ChatMessageTableViewController *chatMessageTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatMessage"];
    chatMessageTVC.currentUser = self.currentUser;
    
    [self.navigationController pushViewController:chatMessageTVC animated:YES];
}

- (void)followActionSucceededWithStatus:(NSUInteger)status andMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate followActionSucceeded:self.headerViewController.followStatus];
    });
    switch (status) {
        case 1:
            [TAOverlay showOverlayWithLabel:message Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlaySizeRoundedRect | TAOverlayOptionOverlayTypeSuccess | TAOverlayOptionOverlayShadow];
            break;
        case 2:
            [TAOverlay showOverlayWithLabel:message Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlaySizeRoundedRect | TAOverlayOptionOverlayTypeError | TAOverlayOptionOverlayShadow];
            break;
        default:
            break;
    }
}

- (void)segementChangedAtIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            self.currentViewType = PersonalPageViewTypeProfile;
            break;
        case 1:
            self.currentViewType = PersonalPageViewTypeFollowing;
            break;
        case 2:
            self.currentViewType = PersonalPageViewTypeFollower;
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

- (void)showAvatar {
    MLPhotoBrowserViewController *photoBrowser = [[MLPhotoBrowserViewController alloc]init];
    photoBrowser.photos = @[self.avatar];
    photoBrowser.editing = NO;
    
    [photoBrowser showPickerVc:self];
}

- (void)reloadRows {
    [self.tableView reloadData];
}

- (void)imDoneLoading {
    if (!_isLoading) {
        [self.headerRefreshControl finishingLoading];
    }
    _isLoading = NO;
    [self.headerViewController changeBlurEffectWithAlpha:1];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.headerViewController.userProfile) {
        return 1;
    }
    switch (self.currentViewType) {
        case PersonalPageViewTypeProfile:
            return 3;
        case PersonalPageViewTypeFollowing:
            if ([self.headerViewController getFollowingCount]) {
                return 1;
            }
        case PersonalPageViewTypeFollower:
            if ([self.headerViewController getFollowerCount]) {
                return 1;
            }
        default:
            break;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.currentViewType == PersonalPageViewTypeProfile) {
        if (!self.headerViewController.userProfile) {
            return 1;
        }
        switch (section) {
            case 0:
                return 4;
            case 1:
                return 2;
            case 2:
                return 6;
            default:
                break;
        }
    } else if (self.currentViewType == PersonalPageViewTypeFollowing){
        if (!self.headerViewController.followingList) {
            return 1;
        }
        return self.headerViewController.followingList.count;
    } else {
        if (!self.headerViewController.followerList) {
            return 1;
        }
        return self.headerViewController.followerList.count;
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.currentViewType == PersonalPageViewTypeProfile) {
        switch (section) {
            case 1:
            {
                return [self setHeaderForSectionWithTitle:@"会员信息"];
            }
            case 2:
            {
                return [self setHeaderForSectionWithTitle:@"基本信息"];
            }
            default:
                break;
        }
    }
    return [UIView new];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentViewType == PersonalPageViewTypeProfile) {
        if (!self.headerViewController.userProfile) {
            [self.view addSubview:self.activityIndicator];
            [self.activityIndicator startAnimating];
            NSString *identifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.textLabel.text = @"";
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        } else {
            [self.activityIndicator removeFromSuperview];
        }

        NSString *identifier = @"ProfileCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        // Configure the cell...
        
        cell.textLabel.textColor = self.chromoplast.secondHighlight;
        cell.backgroundColor = [UIColor clearColor];
        
        switch (indexPath.section) {
            case 0:
            {
                switch (indexPath.row) {
                    case 0:
                        cell.imageView.image = [[UIImage imageNamed:@"my-posts"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        cell.textLabel.text = NSLocalizedString(@"文章作品", nil);
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"共%@篇",self.headerViewController.userProfile.postsCount];
                        break;
                    case 1:
                        cell.imageView.image = [[UIImage imageNamed:@"my-comments"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        cell.textLabel.text = NSLocalizedString(@"文章评论", nil);
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"共%@次",self.headerViewController.userProfile.commentsCount];
                        break;
                    case 2:
                        cell.imageView.image = [[UIImage imageNamed:@"my-credits"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        cell.textLabel.text = NSLocalizedString(@"社区积分", nil);
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.headerViewController.userProfile.credit];
                        break;
                    case 3:
                        cell.imageView.image = [[UIImage imageNamed:@"my-collects"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        cell.textLabel.text = NSLocalizedString(@"文章收藏", nil);
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"共%@个",self.headerViewController.userProfile.collectionCount];
                        break;
                    default:
                        break;
                }
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
            case 1:
            {
                switch (indexPath.row) {
                    case 0:
                    {
                        NSString *userType = self.headerViewController.userProfile.membership[@"user_type"];
                        if ([userType containsString:@"过期"]) {
                            cell.imageView.image = [[UIImage imageNamed:@"membership-expired"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                            cell.textLabel.text = NSLocalizedString(@"过期会员", nil);
                        } else if ([userType containsString:@"月费"]) {
                            cell.imageView.image = [[UIImage imageNamed:@"monthly-membership"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                            cell.textLabel.text = NSLocalizedString(@"月费会员", nil);
                        } else if ([userType containsString:@"季费"]) {
                            cell.imageView.image = [[UIImage imageNamed:@"seasonly-membership"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                            cell.textLabel.text = NSLocalizedString(@"季费会员", nil);
                        } else if ([userType containsString:@"年费"]) {
                            cell.imageView.image = [[UIImage imageNamed:@"yearly-membership"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                            cell.textLabel.text = NSLocalizedString(@"年费会员", nil);
                        } else if ([userType containsString:@"终身"]) {
                            cell.imageView.image = [[UIImage imageNamed:@"eternal-membership"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                            cell.textLabel.text = NSLocalizedString(@"终身会员", nil);
                        } else {
                            cell.imageView.image = [[UIImage imageNamed:@"membership-expired"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                            cell.textLabel.text = NSLocalizedString(@"非会员", nil);
                        }
                        break;
                    }
                    case 1:
                    {
                        cell.textLabel.text = NSLocalizedString(@"到期时间", nil);
                        cell.detailTextLabel.text = self.headerViewController.userProfile.membership[@"user_status"];
                        cell.imageView.image = [[UIImage imageNamed:@"membership-date"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        cell.accessoryType = self.headerViewController.isMyself ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
                        break;
                    }
                    default:
                        break;
                }
                break;
            }
            case 2:
            {
                switch (indexPath.row) {
                    case 0:
                        // User ID
                        cell.imageView.image = [[UIImage imageNamed:@"me"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        cell.textLabel.text = NSLocalizedString(@"社区 ID", nil);
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.headerViewController.userProfile.userID];
                        break;
                    case 1:
                        // User Community Page
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
                        cell.textLabel.textColor = self.chromoplast.secondHighlight;
                        cell.backgroundColor = [UIColor clearColor];
                        cell.imageView.image = [[UIImage imageNamed:@"community"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        cell.textLabel.text = NSLocalizedString(@"社区个人主页网址", nil);
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"http://abletive.com/author/%lu",(unsigned long)self.headerViewController.userProfile.userID];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        break;
                    case 2:
                        // User gender
                        if (self.headerViewController.userProfile.gender == UserGenderMale) {
                            cell.imageView.image = [[UIImage imageNamed:@"profile-male"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                            cell.textLabel.text = NSLocalizedString(@"男生", nil);
                        } else if (self.headerViewController.userProfile.gender == UserGenderFemale) {
                            cell.imageView.image = [[UIImage imageNamed:@"profile-female"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                            cell.textLabel.text = NSLocalizedString(@"女生", nil);
                        } else {
                            cell.imageView.image = [[UIImage imageNamed:@"unknown-gender"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                            cell.textLabel.text = NSLocalizedString(@"未知性别", nil);
                        }
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        break;
                    case 3:
                        // User registered days
                        cell.imageView.image = [[UIImage imageNamed:@"profile-date"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        cell.textLabel.text = [NSString stringWithFormat:@"成为社区一员已经%@天了",self.headerViewController.userProfile.registeredDays];
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        break;
                    case 4:
                        // User URL
                        cell.imageView.image = [[UIImage imageNamed:@"profile-url"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        cell.textLabel.text = NSLocalizedString(@"个人网站", nil);
                        cell.detailTextLabel.text = self.headerViewController.userProfile.url ? self.headerViewController.userProfile.url : NSLocalizedString(@"无", nil);
                        cell.accessoryType = [self.headerViewController.userProfile.url isEqualToString:@""] ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
                        break;
                    case 5:
                        // User orders
                        cell.imageView.image = [[UIImage imageNamed:@"profile-orders"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        cell.textLabel.text = NSLocalizedString(@"商城订单", nil);
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"共%@单",self.headerViewController.userProfile.ordersCount];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        break;
                    default:
                        break;
                }
                break;
            }
            default:
                break;
        }
        cell.imageView.tintColor = self.chromoplast.firstHighlight;
        cell.detailTextLabel.textColor = self.fadedTextColor;
        cell.tintColor = self.chromoplast.secondHighlight;
        return cell;
    } else if (self.currentViewType == PersonalPageViewTypeFollowing){
        if (!self.headerViewController.followingList && [self.headerViewController getFollowingCount]) {
            [self.view addSubview:self.activityIndicator];
            [self.activityIndicator startAnimating];
            NSString *identifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.textLabel.text = @"";
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        } else {
            [self.activityIndicator removeFromSuperview];
        }
        
        PersonalPageFollowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:followingReuseIdentifier];
        User *user = self.headerViewController.followingList[indexPath.row];
        cell.firstHighlight = self.chromoplast.secondHighlight;
        cell.fadedTextColor = self.fadedTextColor;
        cell.membership = user.membership;
        cell.currentUser = user;
        
        return cell;
    } else {
        if (!self.headerViewController.followerList && [self.headerViewController getFollowerCount]) {
            [self.view addSubview:self.activityIndicator];
            [self.activityIndicator startAnimating];
            NSString *identifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.textLabel.text = @"";
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        } else {
            [self.activityIndicator removeFromSuperview];
        }
        
        PersonalPageFollowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:followerReuseIdentifier];
        
        User *user = self.headerViewController.followerList[indexPath.row];
        cell.firstHighlight = self.chromoplast.secondHighlight;
        cell.fadedTextColor = self.fadedTextColor;
        cell.membership = user.membership;
        cell.currentUser = user;
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.currentViewType == PersonalPageViewTypeProfile) {
        switch (section) {
            case 1:
            case 2:
                return 55;
            default:
                break;
        }
    }
    return HEADER_MARGIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return HEADER_MARGIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentViewType == PersonalPageViewTypeProfile) {
        if (!self.headerViewController.userProfile) {
            return 0;
        }
        switch (indexPath.section) {
            case 0:
                return 75;
            case 1:
                return 55;
            default:
                break;
        }
    } else if (self.currentViewType == PersonalPageViewTypeFollowing) {
        if (!self.headerViewController.followingList) {
            return ScreenHeight;
        }
        return USER_TABLE_CELL_HEIGHT;
    } else {
        if (!self.headerViewController.followerList) {
            return ScreenHeight;
        }
        return USER_TABLE_CELL_HEIGHT;
    }
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.currentViewType) {
        case PersonalPageViewTypeProfile:
        {
            switch (indexPath.section) {
                case 0:
                {
                    switch (indexPath.row) {
                        case 0:
                        {
                            // Posts
                            if ([self.headerViewController.userProfile.postsCount intValue] == 0) {
                                [TAOverlay showOverlayWithLabel:@"无任何文章" Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeWarning];
                                return;
                            }
                            SortPostTableViewController *sortPostVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SortPostTVC"];
                            sortPostVC.identification = self.currentUser.userID;
                            sortPostVC.sortType = PostSortTypeAuthor;
                            sortPostVC.title = [NSString stringWithFormat:@"%@的文章",self.currentUser.name];
                            
                            [self.navigationController pushViewController:sortPostVC animated:YES];
                            return;
                        }
                        case 1:
                        {
                            // Comments
                            if ([self.headerViewController.userProfile.commentsCount intValue] == 0) {
                                [TAOverlay showOverlayWithLabel:@"无任何评论" Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeWarning];
                                return;
                            }
                            PersonalPageCommentTableViewController *commentTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPageComment"];
                            commentTVC.userID = self.currentUser.userID;
                            commentTVC.title = [NSString stringWithFormat:@"%@的评论",self.currentUser.name];
                            [self.navigationController pushViewController:commentTVC animated:YES];
                            break;
                        }
                        case 2:
                        {
                            // Credits
                            if (self.headerViewController.userProfile.credit == 0) {
                                [TAOverlay showOverlayWithLabel:@"无任何积分" Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeWarning];
                            }
                            PersonalPageCreditTableViewController *creditTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPageCredit"];
                            creditTVC.userID = self.currentUser.userID;
                            creditTVC.title = [NSString stringWithFormat:@"%@的积分",self.currentUser.name];
                            [self.navigationController pushViewController:creditTVC animated:YES];
                            break;
                        }
                        case 3:
                        {
                            // Collections
                            if ([self.headerViewController.userProfile.collectionCount intValue] == 0) {
                                [TAOverlay showOverlayWithLabel:@"无任何收藏" Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeWarning];
                                return;
                            }
                            PersonalPageCollectionTableViewController *collectionTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPageCollection"];
                            collectionTVC.userID = self.currentUser.userID;
                            collectionTVC.title = [NSString stringWithFormat:@"%@的收藏",self.currentUser.name];
                            [self.navigationController pushViewController:collectionTVC animated:YES];
                            break;
                        }
                        default:
                            return;
                    }
                    break;
                }
                case 1:
                {
                    if (indexPath.row == 1 && self.isMyself) {
                        // Membership page
                        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Membership"] animated:YES];
                    }
                    break;
                }
                case 2:
                {
                    switch (indexPath.row) {
                        case 1:
                        {
                            // Community web page
                            KINWebBrowserViewController *browser = [KINWebBrowserViewController webBrowser];
                            browser.barTintColor = [AppColor mainBlack];
                            browser.tintColor = [AppColor mainYellow];
                            [self.navigationController pushViewController:browser animated:YES];
                            [browser loadURLString:[NSString stringWithFormat:@"http://abletive.com/author/%lu",(unsigned long)self.currentUser.userID]];
                            
                            break;
                        }
                        case 4:
                        {
                            // Personal website
                            KINWebBrowserViewController *browser = [KINWebBrowserViewController webBrowser];
                            browser.barTintColor = [AppColor mainBlack];
                            browser.tintColor = [AppColor mainYellow];
                            [self.navigationController pushViewController:browser animated:YES];
                            [browser loadURLString:self.headerViewController.userProfile.url];
                            break;
                        }
                        case 5:
                        {
                            // Shop Orders
                            if ([self.headerViewController.userProfile.ordersCount intValue]) {
                                PersonalPageOrderTableViewController *orderTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPageOrder"];
                                orderTVC.userID = self.currentUser.userID;
                                orderTVC.title = [NSString stringWithFormat:@"%@的订单",self.currentUser.name];
                                [self.navigationController pushViewController:orderTVC animated:YES];
                            } else {
                                [TAOverlay showOverlayWithLabel:@"无任何订单" Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeWarning];
                            }
                            break;
                        }
                        default:
                            break;
                    }
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case PersonalPageViewTypeFollowing:
        {
            if (![self.headerViewController getFollowingCount]) {
                return;
            }
            User *selectedUser = self.headerViewController.followingList[indexPath.row];
            [self presentPersonalPageWithUser:selectedUser];
            break;
        }
        case PersonalPageViewTypeFollower:
        {
            if (![self.headerViewController getFollowerCount]) {
                return;
            }
            User *selectedUser = self.headerViewController.followerList[indexPath.row];
            [self presentPersonalPageWithUser:selectedUser];
            break;
        }
        default:
            break;
    }
}

- (void)presentPersonalPageWithUser:(User *)user {
    PersonalPageTableViewController *personalPage = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPage"];
    personalPage.currentUser = user;
    [self.navigationController pushViewController:personalPage animated:YES];
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    if (self.isMyself) {
        return nil;
    }
    return @[[UIPreviewAction actionWithTitle:@"关注/取消关注" style: UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self.headerViewController followAction];
    }]];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    if (self.currentViewType == PersonalPageViewTypeProfile) {
        return nil;
    }
    PersonalPageTableViewController *personalPage = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPage"];
    personalPage.preferredContentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    
    NSUInteger row = (location.y - self.headerViewController.view.frame.size.height - HEADER_MARGIN) / USER_TABLE_CELL_HEIGHT;
    
    switch (self.currentViewType) {
        case PersonalPageViewTypeFollower:
        {
            User *user = self.headerViewController.followerList[row];
            personalPage.currentUser = user;
            break;
        }
        default:
        {
            User *user = self.headerViewController.followingList[row];
            personalPage.currentUser = user;
            break;
        }
    }
    previewingContext.sourceRect = CGRectMake(0, [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]].frame.origin.y, ScreenWidth, USER_TABLE_CELL_HEIGHT);
    return personalPage;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self.navigationController pushViewController:viewControllerToCommit animated:YES];
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
