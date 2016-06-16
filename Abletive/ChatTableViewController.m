//
//  ChatTableViewController.m
//  Abletive
//
//  Created by Cali on 6/13/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "ChatTableViewController.h"
#import "NotificationTableViewCell.h"
#import "CCNotification.h"
#import "TAOverlay.h"
#import "CBStoreHouseRefreshControl.h"
#import "MozTopAlertView.h"
#import "ChatMessageTableViewController.h"
#import "UIBarButtonItem+Badge.h"
#import "Abletive-Swift.h"

#define COUNT_PER_PAGE 45
#define INBOX_BADGE_KEY @"Inbox_Badge_Key"

static NSString * const identifier = @"NotificationReuse";

static NSString * const saveFilename = @"LoadedMessages.plist";

@interface ChatTableViewController ()

@property (nonatomic,assign) NSUInteger currentPageIndex;

@property (nonatomic,strong) CBStoreHouseRefreshControl *headerRefreshControl;

@end

@implementation ChatTableViewController {
    BOOL _isLoading;
    BOOL _noMore;
    UIImageView *noResultImageView;
    UILabel *notLoggedLabel;
}

- (NSMutableArray *)allNotifications {
    if (!_allNotifications) {
        _allNotifications = [NSMutableArray arrayWithArray:[self loadMessageCache]];
    }
    return _allNotifications;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        if ([[AppConfiguration buildNumber] intValue] >= 2000 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"chat_cache_cleared"]) {
            self.allNotifications = [NSMutableArray array];
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"chat_cache_cleared"];
        } else {
            self.allNotifications = [NSMutableArray arrayWithArray:[self loadMessageCache]];
        }
        
        [self resetHeaderControl];
    
        if (!self.allNotifications.count) {
            [self loadPageData];
        }
        [self setupInboxButton];
    }
    
    self.currentPageIndex = 1;
    
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.tableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"NotificationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:identifier];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userHasLoggedIn) name:@"User_Login" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userHasLoggedOut) name:@"User_Logout" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newInbox) name:@"New_Comment" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        self.navigationItem.leftBarButtonItem = nil;
    } else {
        [self setupInboxButton];
    }
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"Tabbar_Message_Badge_Key"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"user_is_logged"]) {
        self.currentPageIndex = 1;
        [self loadPageData];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        [self saveMessageCache];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.allNotifications removeAllObjects];
}

- (void)setupInboxButton {
    UIImage *buttonImage = [[UIImage imageNamed:@"alert"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [leftButton addTarget:self action:@selector(inboxDidClick) forControlEvents:UIControlEventTouchUpInside];
    leftButton.tintColor = [AppColor mainYellow];
    [leftButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem.badgeValue = [[NSUserDefaults standardUserDefaults] stringForKey:INBOX_BADGE_KEY] ? [[NSUserDefaults standardUserDefaults] stringForKey:INBOX_BADGE_KEY] : nil;
}

- (void)inboxDidClick {
    // Push inbox notifications
    self.navigationItem.leftBarButtonItem.badgeValue = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:INBOX_BADGE_KEY];
    
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Inbox"] animated:YES];
}

- (void)newInbox {
    NSInteger badgeNumber = self.navigationItem.leftBarButtonItem.badgeValue ? ([self.navigationItem.leftBarButtonItem.badgeValue intValue] + 1) : 1;
    self.navigationItem.leftBarButtonItem.badgeValue = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:badgeNumber]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:badgeNumber]] forKey:INBOX_BADGE_KEY];
}

- (void)resetHeaderControl {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        self.headerRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.tableView target:self refreshAction:@selector(headerRefreshTriggered:) plist:@"abletive-logo" color:[UIColor colorWithWhite:1 alpha:0.9f] lineWidth:1.2f dropHeight:100 scale:0.7f horizontalRandomness:350 reverseLoadingAnimation:NO internalAnimationFactor:0.8f];
    } else {
        self.headerRefreshControl = nil;
    }
}

- (void)loadPageData {
    _isLoading = YES;
    if (self.currentPageIndex != 0) {
        [TAOverlay showOverlayWithLabel:@"加载中..." Options:TAOverlayOptionOpaqueBackground | TAOverlayOptionOverlaySizeRoundedRect | TAOverlayOptionOverlayTypeActivityDefault | TAOverlayOptionOverlayDismissTap];
    } else {
        self.currentPageIndex = 1;
    }
    [CCNotification getNotificationsWithPage:self.currentPageIndex andCount:COUNT_PER_PAGE andBlock:^(NSArray * _Nullable notifs, NSError * _Nullable error) {
        [TAOverlay hideOverlay];
        [self.headerRefreshControl finishingLoading];
        _isLoading = NO;
        if (!error) {
            if (!notifs.count || notifs.count < COUNT_PER_PAGE) {
                _noMore = YES;
                return;
            }
            if (self.currentPageIndex == 1) {
                self.allNotifications = [NSMutableArray array];
            }
            for (CCNotification *notif in notifs) {
                if (![self containsNotification:notif]) {
                    [self.allNotifications addObject:notif];
                }
            }
            
            self.currentPageIndex++;
            [self.tableView reloadData];
            [self removeTabbarBadge];
        } else {
            [TAOverlay showOverlayWithLabel:@"加载错误" Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlayTypeError | TAOverlayOptionOverlaySizeRoundedRect];
        }
    }];
}

- (BOOL)containsNotification:(CCNotification *)notif {
    for (CCNotification *n in self.allNotifications) {
        if (n.fromUserID == notif.fromUserID) {
            return YES;
        }
    }
    return NO;
}

- (void)removeTabbarBadge {
    [self.tabBarController.tabBar.items[1] setBadgeValue:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Tabbar_Message_Badge_Key"];
}

- (void)headerRefreshTriggered:(id)sender {
    if (_isLoading) {
        [MozTopAlertView showWithType:MozAlertTypeError text:@"正在加载中" parentView:self.view];
        return;
    }
    self.currentPageIndex = 0;
    [self loadPageData];
}

- (void)userHasLoggedOut {
    [self.allNotifications removeAllObjects];
    
    [self resetHeaderControl];
    [self.tableView reloadData];
    
    [self saveMessageCache];
}

- (void)userHasLoggedIn {
    [notLoggedLabel removeFromSuperview];
    [self resetHeaderControl];
    [self loadPageData];
}

- (void)saveMessageCache {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:saveFilename];
    NSData *cacheData = [NSKeyedArchiver archivedDataWithRootObject:self.allNotifications];
    [cacheData writeToFile:filePath atomically:NO];
}

- (NSArray *)loadMessageCache {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:saveFilename];
    NSData *cacheData = [NSData dataWithContentsOfFile:filePath];
    if (!cacheData) {
        return [NSArray array];
    }
    return [NSArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:cacheData]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"user_is_logged"]) {
        [self.headerRefreshControl scrollViewDidScroll];
        
        CGFloat offsetY = scrollView.contentOffset.y;
        if (scrollView.frame.size.height >= scrollView.contentSize.height - offsetY + 50) {
            if (_isLoading || _noMore) {
                return;
            }
            //        if (self.allNotifications.count < COUNT_PER_PAGE) {
            //            return;
            //        }
            _isLoading = YES;
            [self loadPageData];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.headerRefreshControl scrollViewDidEndDragging];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        return 1;
    }
    return self.allNotifications.count == 0 ? 1 : self.allNotifications.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        return 0;
    }
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.allNotifications.count == 0 && [[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        noResultImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Search_No_Result"]];
        noResultImageView.backgroundColor = [UIColor clearColor];
        noResultImageView.frame = CGRectMake(0, 0, 100, 100);
        noResultImageView.center = CGPointMake(self.view.center.x, self.view.center.y - 50);
        [self.view addSubview:noResultImageView];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NonLogged"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NonLogged"];
        }
        
        return cell;
    }
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NonLogged"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NonLogged"];
        }
        notLoggedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        notLoggedLabel.text = @"请先登录";
        notLoggedLabel.textColor = [UIColor whiteColor];
        notLoggedLabel.font = [UIFont systemFontOfSize:35];
        notLoggedLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 50);
        notLoggedLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:notLoggedLabel];
        
        return cell;
    } else {
        [notLoggedLabel removeFromSuperview];
        [noResultImageView removeFromSuperview];
        NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        CCNotification *currentNotification = self.allNotifications[indexPath.row];
        // Configure the cell...
        cell.notifcation = currentNotification;
        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.allNotifications.count && [[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        ChatMessageTableViewController *chatMessageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatMessage"];
        CCNotification *currentNotif = self.allNotifications[indexPath.row];
        chatMessageVC.userID = currentNotif.user.userID;
        
        [self.navigationController pushViewController:chatMessageVC animated:YES];
        [self removeTabbarBadge];
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
