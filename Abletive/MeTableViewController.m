//
//  MeTableViewController.m
//  Abletive
//
//  Created by Cali on 6/13/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#define TABLE_HEADER_HEIGHT 170

#import "MeTableViewController.h"
#import "MeLoggedHeaderViewController.h"
#import "MeGuestHeaderViewController.h"
#import "LoginViewController.h"
#import "AbletiveAPIClient.h"
#import "VLDContextSheetItem.h"
#import "UIView+MJAlertView.h"
#import "Personal Page/PersonalPageTableViewController.h"
#import "UINavigationBar+Awesome.h"
#import "ZFModalTransitionAnimator.h"
#import "CheckInViewController.h"
#import "CCDeviceDetecter.h"
#import "Profile/ProfileTableViewController.h"
#import "Personal Page/PersonalPageCollectionTableViewController.h"
#import "CBStoreHouseRefreshControl.h"
#import "MozTopAlertView.h"
#import "SDWebImageManager.h"
#import "PushNotification.h"
#import "UIImageView+WebCache.h"

#import "AppColor.h"

#import "KINWebBrowser/KINWebBrowserViewController.h"
#import "PICoachmark.h"

@interface MeTableViewController () <MeGuestHeaderViewDelegate,MeLoggedHeaderViewDelegate,VLDContextSheetDelegate,CheckInDelegate,ProfileDelegate,UIViewControllerPreviewingDelegate>

@property (nonatomic,strong) MeGuestHeaderViewController *guestHeaderViewController;
@property (nonatomic,strong) MeLoggedHeaderViewController *userHeaderViewController;

@property (nonatomic,strong) ZFModalTransitionAnimator *animator;

@property (nonatomic,strong) VLDContextSheet * _Nullable contextSheet;

@property (nonatomic,assign) BOOL isAvatarReady;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *checkInButton;

@property (nonatomic,strong) CBStoreHouseRefreshControl *headerRefreshControl;

@end

@implementation MeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.checkInButton.enabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (IOS_VERSION_9_OR_ABOVE) {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        self.guestHeaderViewController = [[MeGuestHeaderViewController alloc]initWithNibName:@"MeGuestHeaderViewController" bundle:[NSBundle mainBundle]];
        self.guestHeaderViewController.delegate = self;
        self.tableView.tableHeaderView = self.guestHeaderViewController.view;
        [self.tableView reloadData];
    }
    else {
        //[self animateSwitchFromGuest];
        if (![[NSUserDefaults standardUserDefaults]boolForKey:@"TappedMe"]) {
            // First time entered
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"TappedMe"];
            
            NSDictionary *coachMarkDict = [NSDictionary
                                           dictionaryWithObjects:@[
                                                                   @"me-menu-guide.png",
                                                                   [NSString stringWithFormat:@"{{0,%f},{%f,%f}}",self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height,[UIScreen mainScreen].bounds.size.width,220.f],
                                                                   [NSString stringWithFormat:@"{{%f,%f},{%f,%f}}",self.view.center.x - (500.f/5),190.f + [UIApplication sharedApplication].statusBarFrame.size.height,500.f/5 * 2,361.f/5 * 2],
                                                                   [NSNumber numberWithInteger:5],
                                                                   [NSNumber numberWithInteger:0]]
                                           forKeys:@[@"imageName",
                                                     @"maskRect",
                                                     @"viewRect",
                                                     @"maskRectCornerRadius",
                                                     @"duration"]];
            
            PIImageCoachmark* coachmark = [[PIImageCoachmark alloc] initWithDictionary:coachMarkDict];
            PICoachmarkScreen* screen = [[PICoachmarkScreen alloc] initWithCoachMarks:@[coachmark]];
            
            UIWindow* window = [[UIApplication sharedApplication] keyWindow];
            PICoachmarkView *coachMarksView = [[PICoachmarkView alloc]
                                               initWithFrame:window.bounds];
            [window addSubview:coachMarksView];
            [coachMarksView setScreens:@[screen]];
            [coachMarksView start];
        }
//        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"TappedMe"];
        if (!self.headerRefreshControl) {
            self.headerRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.tableView target:self refreshAction:@selector(headerRefreshTriggered:) plist:@"abletive-logo" color:[UIColor whiteColor] lineWidth:1.2f dropHeight:100 scale:0.75f horizontalRandomness:300 reverseLoadingAnimation:YES internalAnimationFactor:0.8f];
        }
        [self createContextSheet];
        UIGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                                                               action: @selector(longPressed:)];
        [self.view addGestureRecognizer: gestureRecognizer];

        self.userHeaderViewController = [[MeLoggedHeaderViewController alloc]initWithNibName:@"MeLoggedHeaderViewController" bundle:[NSBundle mainBundle]];
        self.userHeaderViewController.delegate = self;
        self.tableView.tableHeaderView = self.userHeaderViewController.view;
        [self.tableView reloadData];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.headerRefreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.headerRefreshControl scrollViewDidEndDragging];
}

- (void)updateHeaderData {
    [self.userHeaderViewController updateUserData];
}

- (void)headerRefreshTriggered:(id)sender {
    [User getCurrentUserProfileInBlock:^(NSDictionary *profile, NSError *error) {
        [self.headerRefreshControl finishingLoading];
        if (!error) {
            [[NSUserDefaults standardUserDefaults]setObject:profile[@"public"][@"avatar"] forKey:@"user_avatar_path"];
            [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:profile[@"public"][@"avatar"]] options:SDWebImageContinueInBackground progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (!error) {
                    [[SDWebImageManager sharedManager]saveImageToCache:image forURL:imageURL];
                    [self.userHeaderViewController updateUserData];
                }
            }];
            [MozTopAlertView showWithType:MozAlertTypeSuccess text:@"更新成功" parentView:self.view];
        } else {
            [MozTopAlertView showWithType:MozAlertTypeError text:@"更新失败" parentView:self.view];
        }
    }];
}

- (void)openLoginPanel {
    LoginViewController *loginVC = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
    loginVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:loginVC animated:YES completion:nil];
}

- (void)logoutButtonDidClick {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"user_is_logged"]) {
        [HHAlertView showAlertWithStyle:HHAlertStyleWarning inView:self.view Title:@"确定要注销吗?" detail:nil cancelButton:@"取消" Okbutton:@"确定" block:^(HHAlertButton buttonindex) {
            if (buttonindex == HHAlertButtonOk) {
                [self logout];
            }
            else {
                return;
            }
        }];
    }
}

- (void)userDidClickLogout {
    [self logout];
}

- (void)logout {
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"user_is_logged"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"user_cookie"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"user_avatar_path"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"user"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"daily_checkin"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"IsVIP"];
    if ([[NSUserDefaults standardUserDefaults]stringForKey:@"deviceToken"]) {
        [PushNotification removeUserWithToken:[[NSUserDefaults standardUserDefaults]stringForKey:@"deviceToken"]];
    }
    [self animateSwitchFromUser];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"User_Logout" object:nil];
    
    if (IOS_VERSION_9_OR_ABOVE) {
        // Change the Shortcut Item of Me back to original
        UIApplication *application = [UIApplication sharedApplication];
        NSArray *shortcutItems = [application shortcutItems];
        UIMutableApplicationShortcutItem *oldItem = [shortcutItems lastObject];
        UIMutableApplicationShortcutItem *mutableItem = [oldItem mutableCopy];
        [mutableItem setLocalizedSubtitle:@"登录后查看"];
        
        id updatedShortcutItems = [shortcutItems mutableCopy];
        [updatedShortcutItems replaceObjectAtIndex:[shortcutItems count]-1 withObject: mutableItem];
        [application setShortcutItems: updatedShortcutItems];
    }
    
    self.checkInButton.enabled = NO;
}

- (void)createContextSheet {
    VLDContextSheetItem *item1 = [[VLDContextSheetItem alloc] initWithTitle: @"个人资料"
                                                                      image: [UIImage imageNamed: @"profile"]
                                                           highlightedImage: [UIImage imageNamed: @"profile_highlighted"]];
    
    
    VLDContextSheetItem *item2 = [[VLDContextSheetItem alloc] initWithTitle: @"我的收藏"
                                                                      image: [UIImage imageNamed: @"my_bookmark"]
                                                           highlightedImage: [UIImage imageNamed: @"my_bookmark_highlighted"]];
    
    VLDContextSheetItem *item3 = [[VLDContextSheetItem alloc] initWithTitle: @"注销"
                                                                      image: [UIImage imageNamed: @"logout"]
                                                           highlightedImage: [UIImage imageNamed: @"logout_highlighted"]];
    
    self.contextSheet = [[VLDContextSheet alloc] initWithItems: @[ item1, item2, item3 ]];
    self.contextSheet.delegate = self;
}

- (void) longPressed: (UIGestureRecognizer *) gestureRecognizer {
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan && [[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        
        [self.contextSheet startWithGestureRecognizer: gestureRecognizer
                                               inView: self.view];
    }
}

- (void) contextSheet: (VLDContextSheet *) contextSheet didSelectItem: (VLDContextSheetItem *) item {
    if ([item.title isEqualToString:@"注销"]) {
        [self logoutButtonDidClick];
    } else if ([item.title isEqualToString:@"个人资料"]) {
        [self profileDidSelect];
    } else {
        [self collectionDidSelect];
    }
}

- (void)profileDidSelect {
    dispatch_async(dispatch_get_main_queue(), ^{
        ProfileTableViewController *profileTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Profile"];
        profileTVC.delegate = self;
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:profileTVC];
        [self presentViewController:navi animated:YES completion:nil];
    });
}

- (void)collectionDidSelect {
    PersonalPageCollectionTableViewController *collectionTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPageCollection"];
    collectionTVC.userID = [[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]intValue];
    collectionTVC.title = NSLocalizedString(@"我的收藏", nil);
    [self.navigationController pushViewController:collectionTVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)avatarLoadSucceeded {
    self.isAvatarReady = YES;
    self.checkInButton.enabled = YES;
    [self.tableView reloadData];
}

- (void)animateSwitchFromUser {
    CGRect startFrame = self.tableView.tableHeaderView.frame;
    CGRect endFrame = CGRectMake(0, 0 - self.tableView.tableHeaderView.frame.size.height, self.tableView.tableHeaderView.frame.size.width, self.tableView.tableHeaderView.frame.size.height);
    // Animation
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.tableHeaderView.frame = endFrame;
        self.tableView.tableHeaderView.alpha = 0;
    } completion:^(BOOL finished) {
        self.guestHeaderViewController = [[MeGuestHeaderViewController alloc]initWithNibName:@"MeGuestHeaderViewController" bundle:[NSBundle mainBundle]];
        self.guestHeaderViewController.delegate = self;
        self.tableView.tableHeaderView = self.guestHeaderViewController.view;
        self.tableView.tableHeaderView.frame = endFrame;
        self.tableView.tableHeaderView.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            self.tableView.tableHeaderView.frame = startFrame;
            self.tableView.tableHeaderView.alpha = 1;
        }];
        [self.tableView reloadData];
    }];
}

- (void)animateSwitchFromGuest {
    CGRect startFrame = self.tableView.tableHeaderView.frame;
    CGRect endFrame = CGRectMake(0, 0 - self.tableView.tableHeaderView.frame.size.height, self.tableView.tableHeaderView.frame.size.width, self.tableView.tableHeaderView.frame.size.height);
    // Animation
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.tableHeaderView.frame = endFrame;
        self.tableView.tableHeaderView.alpha = 0;
    } completion:^(BOOL finished) {
        self.tableView.tableHeaderView.frame = endFrame;
        self.tableView.tableHeaderView.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            self.tableView.tableHeaderView.frame = startFrame;
            self.tableView.tableHeaderView.alpha = 1;
        }];
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        return 0;
    }
    if (!self.isAvatarReady) {
        return 0;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 2;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeReuse" forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                cell.textLabel.text = @"个人主页";
                cell.imageView.image = [UIImage imageNamed:@"author-item"];
                break;
            }
            case 1:
            {
                cell.textLabel.text = @"我的会员";
                cell.imageView.image = [[UIImage imageNamed:@"membership-expired"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                break;
            }
            default:
                break;
        }
    } else if (indexPath.section == 1){
        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [[UIImage imageNamed:@"scan-qrcode"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.textLabel.text = @"扫二维码";
                break;
            default:
                cell.imageView.image = [[UIImage imageNamed:@"qrcode"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.textLabel.text = @"我的名片";
                break;
        }
    }
    cell.imageView.tintColor = [AppColor mainWhite];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0){
                PersonalPageTableViewController *personalPageTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPage"];
                [self.navigationController pushViewController:personalPageTVC animated:YES];
            } else {
//                [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Membership"] animated:YES];
            }
            break;
        }
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"QRCodeScan"] animated:YES];
                    break;
                }
                default:
                {
                    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"PersonalCard"] animated:YES];
                    break;
                }
            }
            break;
        }
        default:
            break;
    }
}

- (void)userAvatarDidTap:(User *)user {
    PersonalPageTableViewController *personalPageTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPage"];
    personalPageTVC.currentUser = user;
    [self.navigationController pushViewController:personalPageTVC animated:YES];
}

- (IBAction)checkInDidClick:(id)sender {
    CheckInViewController *checkInVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CheckIn"];
    
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:checkInVC];
    navi.modalPresentationStyle = UIModalPresentationCustom;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:navi];
    self.animator.behindViewAlpha = 0.35f;
    self.animator.behindViewScale = 0.45f;
    self.animator.transitionDuration = 0.65f;
    self.animator.direction = ZFModalTransitonDirectionRight;
    
    navi.transitioningDelegate = self.animator;
    
    [self presentViewController:navi animated:YES completion:nil];
}

#pragma mark ==== 3D Touch =====

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    if (self.checkInButton.enabled) {
        CheckInViewController *checkInVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CheckIn"];
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:checkInVC];
        
        checkInVC.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        return navi;
    }
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self presentViewController:viewControllerToCommit animated:YES completion:nil];
}

//- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    switch (section) {
//        case 0:
//            return 170;
//            break;
//        default:
//            break;
//    }
//    return 5;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
