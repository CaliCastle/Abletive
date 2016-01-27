//
//  PostTableViewController.m
//  Abletive
//
//  Created by Cali on 6/13/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PostTableViewController.h"
#import "PostTableViewCell.h"
#import "Post.h"
#import "PostDetail.h"
#import "PostCategory.h"
#import "PostTag.h"
#import "SortPostTableViewController.h"
#import "SinglePostTableViewController.h"
#import "AppColor.h"
#import "TWRefreshTableView.h"
#import "TAOverlay.h"
#import "DOPNavbarMenu.h"
#import "AFNetworkReachabilityManager.h"
#import "SDCycleScrollView.h"
#import "UIImage+Circle.h"
#import "CBStoreHouseRefreshControl.h"

#import <AVFoundation/AVFoundation.h>

#import "CCDeviceDetecter.h"

#define SCROLL_HEADER_HEIGHT 200
#define POST_TABLE_CELL_HEIGHT 115

#define PULL_DOWN_CANCEL_HEIGHT -64.0
#define PULL_UP_BEGIN_HEIGHT -107.0
#define PULL_UP_END_HEIGHT -162.0

typedef NS_ENUM(NSUInteger,PostViewType) {
    PostViewTypeNormalOrderInNew,
    PostViewTypeOrderInCategories,
    PostViewTypeOrderInTags,
    PostViewTypeOrderInAuthor,
    PostViewTypeOrderInCalendar
};

@interface PostTableViewController () <TWTableViewRefreshingDelegate,DOPNavbarMenuDelegate,SDCycleScrollViewDelegate,UIViewControllerPreviewingDelegate>
/**
 Current view type
 */
@property (nonatomic,assign) PostViewType currentPostViewType;
/**
 The blur effect covers on background when choosing the menu
 */
@property (nonatomic,strong) UIVisualEffectView *blurEffectView;
/**
 All the posts loaded
 */
@property (nonatomic,strong) NSMutableArray *allPosts;
/**
 Recent posts for banner
 */
@property (nonatomic,strong) NSMutableArray *recentPosts;
/**
 Calendar indexes for sorting in date
 */
@property (nonatomic,strong) NSMutableDictionary *calendarIndexes;
/**
 All the categories for sorting in category
 */
@property (nonatomic,strong) NSMutableArray *allCategories;
/**
 All the tags for sorting in tag
 */
@property (nonatomic,strong) NSMutableArray *allTags;
/**
 All the authors for sorting in author
 */
@property (nonatomic,strong) NSArray *allAuthors;
/**
 Scroll header for normal order
 */
@property (nonatomic,strong) SDCycleScrollView *scrollHeader;
/**
 Current page loaded
 */
@property (nonatomic,assign) NSUInteger pageIndex;
/**
 How many posts to be loaded at once
 */
@property (nonatomic,assign) NSUInteger countsPerPage;
/**
 Menu dropdown, how many items in a row
 */
@property (assign, nonatomic) NSInteger numberOfItemsInRow;
/**
 Menu object
 */
@property (strong, nonatomic) DOPNavbarMenu *menu;
/**
 Header Refresh Control Object
 */
@property (strong, nonatomic) CBStoreHouseRefreshControl *headerRefreshControl;

@property (nonatomic,assign) SystemSoundID refreshBeginSoundID;
@property (nonatomic,assign) SystemSoundID refreshEndSoundID;
@property (nonatomic,assign) SystemSoundID refreshCancelSoundID;
@property (nonatomic,assign) SystemSoundID refreshSuccessSoundID;

@property (nonatomic,assign) BOOL isPulling;

@property (nonatomic,assign) BOOL isLightTheme;

@end

static NSString * const saveFilename = @"LoadedPost.plist";

static NSString * const headerDefaultImageUrl = @"http://abletive.com/wp-content/uploads/2015/02/Abletiveliti.jpg";
static NSString * const reuseIdentifier = @"PostViewCell";
static NSString * const categoryReuseIdentifier = @"CategoryCell";
static NSString * const tagReuseIdentifier = @"TagCell";
static NSString * const normalReuseIdentifier = @"NormalCell";
static NSString * const authorReuseIdentifier = @"AuthorCell";

@implementation PostTableViewController
{
    TWRefreshTableView *_tableView;
}

#pragma mark - Lazy loading

- (UIVisualEffectView *)blurEffectView {
    if (!_blurEffectView) {
        UIBlurEffect *blurEffect = [[NSUserDefaults standardUserDefaults]integerForKey:@"theme"] == 1 ? [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight] : [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    }
    return _blurEffectView;
}

- (NSMutableArray *)allPosts {
    if (!_allPosts) {
        _allPosts = [NSMutableArray array];
    }
    return _allPosts;
}

- (NSMutableArray *)allRawPosts {
    if (!_allRawPosts) {
        _allRawPosts = [NSMutableArray array];
    }
    return _allRawPosts;
}

- (NSMutableArray *)recentPosts {
    if (!_recentPosts) {
        _recentPosts = [NSMutableArray array];
    }
    return _recentPosts;
}

- (NSMutableDictionary *)calendarIndexes {
    if (!_calendarIndexes) {
        _calendarIndexes = [NSMutableDictionary dictionary];
    }
    return _calendarIndexes;
}

- (NSMutableArray *)allCategories {
    if (!_allCategories) {
        _allCategories = [NSMutableArray array];
    }
    return _allCategories;
}

- (NSMutableArray *)allTags {
    if (!_allTags) {
        _allTags = [NSMutableArray array];
    }
    return _allTags;
}

- (NSArray *)allAuthors {
    if (!_allAuthors) {
        _allAuthors = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Authors" ofType:@"plist"]];
    }
    return _allAuthors;
}

- (SDCycleScrollView *)scrollHeader {
    if (!_scrollHeader) {
        _scrollHeader = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SCROLL_HEADER_HEIGHT) imageURLStringsGroup:nil];
    }
    return _scrollHeader;
}

#pragma mark - Menu Related Methods

- (DOPNavbarMenu *)menu {
    if (_menu == nil) {
        // Instanstiate
        DOPNavbarMenuItem *itemTimeLine = [DOPNavbarMenuItem ItemWithTitle:NSLocalizedString(@"按新旧顺序", nil) icon:[UIImage imageNamed:@"timeline-item"]];
        DOPNavbarMenuItem *itemCategories = [DOPNavbarMenuItem ItemWithTitle:NSLocalizedString(@"按分类查看", nil) icon:[UIImage imageNamed:@"categories-item"]];
        DOPNavbarMenuItem *itemTags = [DOPNavbarMenuItem ItemWithTitle:NSLocalizedString(@"按标签查看", nil) icon:[UIImage imageNamed:@"tags-item"]];
        DOPNavbarMenuItem *itemAuthor = [DOPNavbarMenuItem ItemWithTitle:NSLocalizedString(@"按作者查看", nil) icon:[UIImage imageNamed:@"author-item"]];
        DOPNavbarMenuItem *itemCalendar = [DOPNavbarMenuItem ItemWithTitle:NSLocalizedString(@"按日期查看", nil) icon:[UIImage imageNamed:@"calendar-item"]];
        _menu = [[DOPNavbarMenu alloc] initWithItems:@[itemTimeLine,itemCategories,itemTags,itemAuthor,itemCalendar] width:self.view.dop_width maximumNumberInRow:_numberOfItemsInRow];
        _menu.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.4];
        _menu.separatarColor = [UIColor colorWithWhite:0.9 alpha:0.5];
        _menu.delegate = self;
    }
    return _menu;
}

- (void)didShowMenu:(DOPNavbarMenu *)menu {
    self.blurEffectView.frame = self.tableView.bounds;
    self.blurEffectView.alpha = 0.1;
    [self.view insertSubview:self.blurEffectView aboveSubview:self.tableView];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.blurEffectView.alpha = 1;
    }];
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    switch (index) {
        case 0:
            self.currentPostViewType = PostViewTypeNormalOrderInNew;
            break;
        case 1:
            self.currentPostViewType = PostViewTypeOrderInCategories;
            break;
        case 2:
            self.currentPostViewType = PostViewTypeOrderInTags;
            break;
        case 3:
            self.currentPostViewType = PostViewTypeOrderInAuthor;
            break;
        case 4:
            self.currentPostViewType = PostViewTypeOrderInCalendar;
            break;
        default:
            break;
    }
}

- (void)didDismissMenu:(DOPNavbarMenu *)menu {
    [UIView animateWithDuration:0.2 animations:^{
        self.blurEffectView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.blurEffectView removeFromSuperview];
    }];
}

#pragma mark - Refresh/Reload Action

- (void)reloadWithType:(PostViewType)type {
    switch (type) {
        case PostViewTypeNormalOrderInNew:
        {
            [self.tableView setRefreshEnabled:YES];
            [self.tableView reloadData];
            break;
        }
        case PostViewTypeOrderInCategories:
        {
            [self.tableView setRefreshEnabled:NO];
            if (self.allCategories.count != 0) {
                [self.tableView reloadData];
                return;
            }
            [TAOverlay showOverlayWithLogo];
            [self reloadWithCategories];
            break;
        }
        case PostViewTypeOrderInTags:
        {
            [self.tableView setRefreshEnabled:NO];
            if (self.allTags.count != 0) {
                [self.tableView reloadData];
                return;
            }
            [TAOverlay showOverlayWithLogo];
            [self reloadWithTags];
            break;
        }
        case PostViewTypeOrderInAuthor:
        {
            [self.tableView setRefreshEnabled:NO];
            [self.tableView reloadData];
            break;
        }
        case PostViewTypeOrderInCalendar:
        {
            if (self.calendarIndexes.count != 0) {
                [TAOverlay hideOverlay];
                [self.tableView reloadData];
                return;
            }
            [TAOverlay showOverlayWithLogo];
            [self reloadWithCalendar];
            break;
        }
        default:
            break;
    }
}

- (void)reloadWithCategories {
    if (![self checkReachability]) {
        [self showOverlayForNetworkError];
        return;
    }
    [PostCategory postCategoriesWithBlock:^(NSArray *categories, NSError *error) {
        [TAOverlay hideOverlay];
        if (!error) {
            self.allCategories = [NSMutableArray arrayWithArray:categories];
            [self.tableView reloadData];
        }
    }];
}

- (void)reloadWithTags {
    if (![self checkReachability]) {
        [self showOverlayForNetworkError];
        return;
    }
    [PostTag postTagWithBlock:^(NSArray *tags, NSError *error) {
        [TAOverlay hideOverlay];
        if (!error) {
            self.allTags = [NSMutableArray arrayWithArray:tags];
            [self.tableView reloadData];
        }
    }];
}

- (void)reloadWithCalendar {
    if (![self checkReachability]) {
        [self showOverlayForNetworkError];
        return;
    }
    
    [[AbletiveAPIClient sharedClient]GET:@"get_date_index" parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        [TAOverlay hideOverlay];
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            self.calendarIndexes = [NSMutableDictionary dictionaryWithDictionary:JSON[@"tree"]];
            [self.tableView setRefreshEnabled:NO];
            [self.tableView reloadData];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)reloadWithHeader:(__unused id)sender {
    if (![self checkReachability]) {
        [self showOverlayForNetworkError];
        [self.headerRefreshControl finishingLoading];
        return;
    }
    self.pageIndex = 1;
    [Post globalTimelinePostsWithCookie:[[NSUserDefaults standardUserDefaults]stringForKey:@"user_cookie"] andPage:self.pageIndex andCount:self.countsPerPage andBlock:^(NSArray *posts, NSArray *postsAttribute, NSError *error) {
        if (!error) {
            AudioServicesPlaySystemSound(self.refreshSuccessSoundID);
            [TAOverlay hideOverlay];
            
            [self.allPosts removeAllObjects];
            [self.allRawPosts removeAllObjects];
            // Display (Post object)
            [self.allPosts addObjectsFromArray:posts];
            // Cache the post
            [self.allRawPosts addObjectsFromArray:postsAttribute];
            
            [self.headerRefreshControl finishingLoading];
            [self.tableView reloadData];
        }
    }];
    [self setTableViewHeader];
}

- (void)reloadWithFooter:(__unused id)sender {
    if (![self checkReachability]) {
        [self showOverlayForNetworkError];
        return;
    }
    self.pageIndex++;
    dispatch_async(dispatch_get_main_queue(), ^{
        [Post globalTimelinePostsWithCookie:[[NSUserDefaults standardUserDefaults]stringForKey:@"user_cookie"] andPage:self.pageIndex andCount:self.countsPerPage andBlock:^(NSArray *posts, NSArray *postsAttribute, NSError *error) {
            [self.tableView stopFooterRefreshing];
            if (!error) {
                if (posts.count == 0) {
                    [TAOverlay showOverlayWithLabel:@"抱歉已经没有内容了%>_<%" Options:TAOverlayOptionOverlaySizeRoundedRect | TAOverlayOptionOverlayTypeWarning | TAOverlayOptionAutoHide];
                    [self.tableView setRefreshEnabled:NO];
                }
                // Put it up to the view
                [self.allPosts addObjectsFromArray:posts];
                // Cache the post
                [self.allRawPosts addObjectsFromArray:postsAttribute];
                [self.tableView stopFooterRefreshing];
                [self.tableView reloadData];
            }
        }];
    });
}

- (BOOL) checkReachability {
    switch ([AbletiveAPIClient sharedClient].reachabilityManager.networkReachabilityStatus) {
        case AFNetworkReachabilityStatusReachableViaWiFi: {
            return YES;
        }
        case AFNetworkReachabilityStatusReachableViaWWAN: {
            if (![[NSUserDefaults standardUserDefaults]boolForKey:@"load_wifi_only"]) {
                return YES;
            }
            break;
        }
        case AFNetworkReachabilityStatusNotReachable: {
            break;
        }
        case AFNetworkReachabilityStatusUnknown: {
            return YES;
        }
        default:
            break;
    }
    return NO;
}

- (void)savePostsCache {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:saveFilename];
    [self.allRawPosts writeToFile:filePath atomically:YES];
}

- (void) stopFooter {
    [self reloadWithFooter:nil];
}

- (void) stopHeader {
    [self reloadWithHeader:nil];
}

- (void)beginRefreshFooter:(TWRefreshTableView *)tableView {
    [self stopFooter];
}

- (void)beginRefreshHeader:(TWRefreshTableView *)tableView {
    if (self.allPosts.count) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![self.allPosts count]) {
            [TAOverlay showOverlayWithLabel:NSLocalizedString(@"正在更新中...", nil) Options:TAOverlayOptionOpaqueBackground | TAOverlayOptionOverlaySizeRoundedRect | TAOverlayOptionOverlayTypeActivityBlur | TAOverlayOptionOverlayDismissTap];
        }
    });
    [self stopHeader];
}

- (void)setCurrentPostViewType:(PostViewType)currentPostViewType {
    _currentPostViewType = currentPostViewType;
    [self reloadWithType:currentPostViewType];
}

- (void)setTableViewHeader {
    // Set the scrollable table header view
    [Post recentPostsWithCookie:[[NSUserDefaults standardUserDefaults]stringForKey:@"user_cookie"] andBlock:^(NSArray *posts, NSArray *postsAttribute, NSError *error) {
        if (!error) {
            self.recentPosts = [NSMutableArray arrayWithArray:posts];
            NSMutableArray *titles = [NSMutableArray array];
            NSMutableArray *imageURLStrings = [NSMutableArray array];
            for (Post *post in self.recentPosts) {
                [titles addObject:post.title.length > 30 ? [[post.title substringToIndex:30] stringByAppendingString:@"..."] : post.title];
                [imageURLStrings addObject:post.imageLargePath?post.imageLargePath:headerDefaultImageUrl];
            }
            self.scrollHeader.imageURLStringsGroup = [NSArray arrayWithArray:imageURLStrings];
            self.scrollHeader.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
            self.scrollHeader.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
            self.scrollHeader.titlesGroup = [NSArray arrayWithArray:titles];
            self.scrollHeader.dotColor = [AppColor mainYellow];
            self.scrollHeader.placeholderImage = [UIImage imageNamed:@"banner_placeholder"];
            self.scrollHeader.delegate = self;
            
            self.tableView.tableHeaderView = self.scrollHeader;
        }
    }];
    
}

#pragma mark - Listening for the user to trigger a refresh

- (void)setupRefreshSound {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SystemSoundID beginSoundID;
        NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"Pull" ofType:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundFile], &beginSoundID);
        self.refreshBeginSoundID = beginSoundID;
        
        SystemSoundID endSoundID;
        soundFile = [[NSBundle mainBundle] pathForResource:@"Pull Success" ofType:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundFile], &endSoundID);
        self.refreshEndSoundID = endSoundID;
        
        SystemSoundID cancelSoundID;
        soundFile = [[NSBundle mainBundle] pathForResource:@"Pull Cancelled" ofType:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundFile], &cancelSoundID);
        self.refreshCancelSoundID = cancelSoundID;
        
        SystemSoundID successSoundID;
        soundFile = [[NSBundle mainBundle]pathForResource:@"Finish Loading" ofType:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundFile], &successSoundID);
        self.refreshSuccessSoundID = successSoundID;
    });
}

- (void)headerRefreshTriggered:(id)sender {
    if (self.currentPostViewType == PostViewTypeNormalOrderInNew) {
        [self reloadWithHeader:nil];
    } else {
        [self.headerRefreshControl finishingLoading];
    }
}


#pragma mark - Notifying refresh control of scrolling

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.headerRefreshControl scrollViewDidScroll];
    
    if (self.tableView.contentOffset.y <= PULL_UP_END_HEIGHT && self.isPulling) {
        self.isPulling = NO;
        AudioServicesPlaySystemSound(self.refreshEndSoundID);
        return;
    }
    
    if (self.tableView.contentOffset.y <= PULL_UP_BEGIN_HEIGHT && self.tableView.contentOffset.y > PULL_UP_END_HEIGHT && !self.isPulling) {
        self.isPulling = YES;
        AudioServicesPlaySystemSound(self.refreshBeginSoundID);
        return;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.headerRefreshControl scrollViewDidEndDragging];
    
    if (self.tableView.contentOffset.y <= PULL_DOWN_CANCEL_HEIGHT && self.isPulling) {
        self.isPulling = NO;
        AudioServicesPlaySystemSound(self.refreshCancelSoundID);
    }
}

#pragma mark - Overlay loading animation

- (void)showOverlayForNetworkError {
    [TAOverlay hideOverlay];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [TAOverlay showOverlayWithLabel:NSLocalizedString(@"网络错误，请检查是否设置了只通过Wi-Fi加载", nil) Options:TAOverlayOptionAutoHide | TAOverlayOptionOpaqueBackground | TAOverlayOptionOverlayShadow | TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeError];
    });
    [self.tableView stopFooterRefreshing];
}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    NSUInteger selectedPostID = [self.recentPosts[index] postID];
    Post *selectedPost = self.recentPosts[index];
    SinglePostTableViewController *singlePostVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
    
    singlePostVC.title = selectedPost.title;
    singlePostVC.postID = selectedPostID;
    
    [self.navigationController pushViewController:singlePostVC animated:YES];
}

#pragma mark - View Related Methods

- (void)viewWillAppear:(BOOL)animated {
    self.scrollHeader.autoScroll = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.menu.isOpen) {
        [self.menu dismissWithAnimation:NO];
    }
    self.scrollHeader.autoScroll = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [self savePostsCache];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Start monitoring for network status changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkWWAN) name:@"NetworkWWAN" object:nil];
    
    [self setupRefreshSound];
    
    // First time show the welcome message
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunched"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Welcome"] animated:NO completion:^{
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunched"];
            }];
        });
    }
    
    self.pageIndex = 1;
    self.countsPerPage = 15;
    self.numberOfItemsInRow = 3;
    self.currentPostViewType = PostViewTypeNormalOrderInNew;
    
    // If we cached, load it right from the disk
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:saveFilename];
    NSArray *cachedPosts = [NSMutableArray arrayWithContentsOfFile:filePath];
    if (cachedPosts) {
        // Cache exists
        self.pageIndex = (int)(cachedPosts.count / self.countsPerPage);
        for (NSDictionary *cache in cachedPosts) {
            Post *post = [[Post alloc]initWithCache:cache];
            [self.allPosts addObject:post];
            [self.allRawPosts addObject:cache];
        }
    }
    
    [self.tableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    
    _tableView = [[TWRefreshTableView alloc] initWithFrame:self.view.bounds refreshType:TWRefreshTypeBottom];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.refreshDelegate = self;
    self.tableView = _tableView;
    
    self.clearsSelectionOnViewWillAppear = YES;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:normalReuseIdentifier];
    
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.1];
    
    [self setTableViewHeader];
    [self beginRefreshHeader:_tableView];
    
    [self themeChanged];
    
    // Disable the header scrollsToTop property !IMPORTANT
    self.scrollHeader.mainView.scrollsToTop = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resendRequestForLoggedInUser) name:@"User_Login" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(themeChanged) name:@"themeChanged" object:nil];
    
    if (IOS_VERSION_9_OR_ABOVE) {
        [self registerForPreviewingWithDelegate:self sourceView:self.tableView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.allPosts removeAllObjects];
    [self.allRawPosts removeAllObjects];
    [self.recentPosts removeAllObjects];
}

#pragma mark - Listen Event:

- (void)themeChanged {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"theme"]) {
        switch ([[NSUserDefaults standardUserDefaults]integerForKey:@"theme"]) {
            case 1:
            {
                self.isLightTheme = YES;
                UIBlurEffect *blurEffect =  [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                _blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
                
                self.tableView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
                self.headerRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.tableView target:self refreshAction:@selector(headerRefreshTriggered:) plist:@"abletive-logo" color:[AppColor mainBlack] lineWidth:1.5 dropHeight:100 scale:0.75 horizontalRandomness:400 reverseLoadingAnimation:YES internalAnimationFactor:0.7];
                break;
            }
            default:
            {
                self.isLightTheme = NO;
                UIBlurEffect *blurEffect =  [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                _blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
                
                self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
                
                self.headerRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.tableView target:self refreshAction:@selector(headerRefreshTriggered:) plist:@"abletive-logo" color:[AppColor mainWhite] lineWidth:1.5 dropHeight:100 scale:0.75 horizontalRandomness:400 reverseLoadingAnimation:YES internalAnimationFactor:0.7];
                break;
            }
        }
        [self.tableView reloadData];
    }
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.headerRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.tableView target:self refreshAction:@selector(headerRefreshTriggered:) plist:@"abletive-logo" color:[AppColor mainWhite] lineWidth:1.5 dropHeight:100 scale:0.75 horizontalRandomness:400 reverseLoadingAnimation:YES internalAnimationFactor:0.7];
    self.isLightTheme = NO;
}

- (void)resendRequestForLoggedInUser {
    [self reloadWithHeader:nil];
}

- (void)networkWWAN {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"WWAN_ignore"]) {
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"你现在正在使用流量查看", nil) message:NSLocalizedString(@"如有需要可前往设置-网络设置里打开『只在Wi-Fi下加载』", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAlertAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"知道了", nil) style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"不再提醒", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"WWAN_ignore"];
    }];
    [alertController addAction:cancelAlertAction];
    [alertController addAction:confirmAlertAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)viewPostWithRow:(NSUInteger)row {
    Post *selectedPost = self.allPosts[row];
    SinglePostTableViewController *singlePostVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
    
    singlePostVC.postID = selectedPost.postID;
    
    [self.navigationController pushViewController:singlePostVC animated:YES];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    switch (self.currentPostViewType) {
        case PostViewTypeNormalOrderInNew:
            return 1;
        case PostViewTypeOrderInCategories:
            return 1;
        case PostViewTypeOrderInCalendar:
            return self.calendarIndexes.count;
        default:
            break;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.currentPostViewType) {
        case PostViewTypeNormalOrderInNew:
            return self.allPosts.count;
        case PostViewTypeOrderInAuthor:
            return self.allAuthors.count;
        case PostViewTypeOrderInCategories:
            return self.allCategories.count;
        case PostViewTypeOrderInTags:
            return self.allTags.count;
        case PostViewTypeOrderInCalendar:
        {
            NSEnumerator *keyEnumerator = [self.calendarIndexes keyEnumerator];
            NSMutableArray *keys = [NSMutableArray array];
            for (NSString *key in keyEnumerator) {
                [keys addObject:key];
            }
            NSDictionary *dict = self.calendarIndexes[keys[section]];
            return dict.count;
        }
        default:
            break;
    }
    return 1;
}

- (nullable NSString *)tableView:(nonnull UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (self.currentPostViewType) {
        case PostViewTypeOrderInCalendar:
        {
            NSEnumerator *keyEnumerator = [self.calendarIndexes keyEnumerator];
            NSMutableArray *keys = [NSMutableArray array];
            for (NSString *key in keyEnumerator) {
                [keys addObject:key];
            }
            return [NSString stringWithFormat:@"%@年",keys[section]];
        }
        default:
            break;
    }
    return nil;
}
- (CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    switch (self.currentPostViewType) {
        case PostViewTypeNormalOrderInNew:
            return POST_TABLE_CELL_HEIGHT;
        case PostViewTypeOrderInCategories:
            return 55;
        case PostViewTypeOrderInAuthor:
            return 50;
        default:
            break;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (self.currentPostViewType) {
        case PostViewTypeNormalOrderInNew: // Normal sort type cell configuration
        {
            PostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
            Post *post = [self.allPosts objectAtIndex:indexPath.row];
            
            cell.post = post;
            // Set the color
            cell.authorLabel.textColor = self.isLightTheme ? [AppColor mainRed] : [AppColor mainYellow];
            cell.shortDescLabel.textColor = self.isLightTheme ? [AppColor darkOverlay] : [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:0.6];
            cell.tag = indexPath.row;
            
            return cell;
        }
        case PostViewTypeOrderInCategories: // Category sort type cell configuration
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:categoryReuseIdentifier];
            PostCategory *postCategory = self.allCategories[indexPath.row];
            cell.textLabel.text = postCategory.name;
            cell.textLabel.textColor = self.isLightTheme ? [AppColor mainBlack] : [AppColor mainWhite];
            cell.detailTextLabel.text = postCategory.categoryDesc;
            cell.detailTextLabel.textColor = self.isLightTheme ? [AppColor darkOverlay] : [UIColor colorWithWhite:0.6 alpha:1];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
        case PostViewTypeOrderInTags: // Tag sort type cell configuration
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:tagReuseIdentifier];
            PostTag *postTag = self.allTags[indexPath.row];
            cell.textLabel.textColor = self.isLightTheme ? [AppColor darkOverlay] : [UIColor colorWithWhite:0.6 alpha:1];
            cell.textLabel.text = [NSString stringWithFormat:@"共有%ld篇文章",(unsigned long)postTag.postCount];
            cell.detailTextLabel.textColor = self.isLightTheme ? [AppColor mainBlack] : [AppColor mainWhite];
            cell.detailTextLabel.text = postTag.name;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            return cell;
        }
        case PostViewTypeOrderInAuthor: // Author sort type cell configuration
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:authorReuseIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.textColor = self.isLightTheme ? [AppColor mainBlack] : [AppColor mainWhite];
            cell.textLabel.text = self.allAuthors[indexPath.row][@"name"];
            cell.imageView.layer.masksToBounds = YES;
            cell.imageView.layer.cornerRadius = 25;
            [cell.imageView sd_setImageWithURL:self.allAuthors[indexPath.row][@"avatar"] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
            
            return cell;
        }
        case PostViewTypeOrderInCalendar: // Calendar sort type cell configuration
        {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:normalReuseIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            NSEnumerator *keyEnumerator = [self.calendarIndexes keyEnumerator];
            NSMutableArray *keys = [NSMutableArray array];
            for (NSString *key in keyEnumerator) {
                [keys addObject:key];
            }
            NSDictionary *section = self.calendarIndexes[keys[indexPath.section]];
            keyEnumerator = [section keyEnumerator];
            [keys removeAllObjects];
            for (NSString *key in keyEnumerator) {
                [keys addObject:key];
            }
            NSEnumerator *objectEnumerator = [section objectEnumerator];
            NSMutableArray *values = [NSMutableArray array];
            for (NSString *value in objectEnumerator) {
                [values addObject:value];
            }
            cell.textLabel.textColor = self.isLightTheme ? [AppColor mainBlack] : [AppColor mainWhite];
            cell.textLabel.text = [NSString stringWithFormat:@"%@月",keys[indexPath.row]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"共发布了%@篇文章",values[indexPath.row]];
            
            return cell;
        }
        default:
            break;
    }
    // Configure the cell...
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    return cell;
}

#pragma mark - Row selection action

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (self.currentPostViewType == PostViewTypeNormalOrderInNew) {
        if (![self checkReachability]) {
            [self showOverlayForNetworkError];
            return;
        }
        [self viewPostWithRow:indexPath.row];
        return;
    }
    SortPostTableViewController *sortPostTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SortPostTVC"];
    switch (self.currentPostViewType) {
        case PostViewTypeOrderInCategories:
        {
            PostCategory *category = self.allCategories[indexPath.row];
            sortPostTVC.identification = category.categoryID;
            sortPostTVC.title = category.name;
            sortPostTVC.sortType = PostSortTypeCategory;
            break;
        }
        case PostViewTypeOrderInTags:
        {
            PostTag *tag = self.allTags[indexPath.row];
            sortPostTVC.identification = tag.tagID;
            sortPostTVC.title = tag.name;
            sortPostTVC.sortType = PostSortTypeTag;
            break;
        }
        case PostViewTypeOrderInAuthor:
        {
            sortPostTVC.identification = [self.allAuthors[indexPath.row][@"id"]unsignedIntegerValue];
            sortPostTVC.title = self.allAuthors[indexPath.row][@"name"];
            sortPostTVC.sortType = PostSortTypeAuthor;
            break;
        }
        case PostViewTypeOrderInCalendar:
        {
            NSEnumerator *keyEnumerator = [self.calendarIndexes keyEnumerator];
            NSMutableArray *years = [NSMutableArray array];
            for (NSString *key in keyEnumerator) {
                [years addObject:key];
            }
            NSDictionary *section = self.calendarIndexes[years[indexPath.section]];
            keyEnumerator = [section keyEnumerator];
            NSMutableArray *month = [NSMutableArray array];
            for (NSString *key in keyEnumerator) {
                [month addObject:key];
            }
            sortPostTVC.date = [NSString stringWithFormat:@"%@-%@",years[indexPath.section],month[indexPath.row]];
            sortPostTVC.title = [NSString stringWithFormat:@"%@年%@月的文章",years[indexPath.section],month[indexPath.row]];
            sortPostTVC.sortType = PostSortTypeCalendar;
            break;
        }
        default:
            break;
    }
    sortPostTVC.hidesBottomBarWhenPushed = NO;
    [self.navigationController pushViewController:sortPostTVC animated:YES];
}

#pragma mark - Button Click Event

- (IBAction)categoryDidClick:(id)sender {
    if (self.menu.isOpen) {
        [self.menu dismissWithAnimation:YES];
    } else {
        [self.menu showInNavigationController:self.navigationController];
    }
}

#pragma mark ==== 3D Touch ====

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    SinglePostTableViewController *singlePostTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
    
    singlePostTVC.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    NSUInteger row = (location.y - (self.scrollHeader.imageURLStringsGroup.count ? SCROLL_HEADER_HEIGHT:0))/POST_TABLE_CELL_HEIGHT;
    
    Post *selectedPost = self.allPosts[row];
    
    singlePostTVC.title = selectedPost.title;
    singlePostTVC.postID = selectedPost.postID;
    
    singlePostTVC.isFromPeek = YES;
    
    previewingContext.sourceRect = CGRectMake(0, [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]].frame.origin.y, previewingContext.sourceView.frame.size.width, POST_TABLE_CELL_HEIGHT);
    
    return singlePostTVC;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
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
