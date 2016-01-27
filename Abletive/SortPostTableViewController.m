//
//  SortPostTableViewController.m
//  Abletive
//
//  Created by Cali on 6/30/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "SortPostTableViewController.h"
#import "SinglePostTableViewController.h"
#import "PostTableViewCell.h"
#import "AppColor.h"
#import "TAOverlay.h"
#import "TWRefreshTableView.h"
#import "MJAlertView/UIView+MJAlertView.h"
#import "Post.h"
#import "CCDeviceDetecter.h"

#define POST_TABLE_CELL_HEIGHT 115

@interface SortPostTableViewController () <TWTableViewRefreshingDelegate,UIViewControllerPreviewingDelegate>

@property (nonatomic,strong) NSMutableArray *allPosts;
@property (nonatomic,assign) NSUInteger currentPageIndex;

@end

static NSString * const reuseIdentifier = @"PostViewCell";



@implementation SortPostTableViewController
{
    TWRefreshTableView *_tableView;
}

- (NSMutableArray *)allPosts {
    if (!_allPosts) {
        _allPosts = [NSMutableArray array];
    }
    return _allPosts;
}

- (void)loadData {
    [Post postSortedWithSortType:self.sortType andID:self.identification withDate:self.date atPage:self.currentPageIndex inBlock:^(NSArray *posts, NSError *error) {
        [TAOverlay hideOverlay];
        if (posts.count == 0) {
            
        }
        if (!error) {
            self.allPosts = [NSMutableArray arrayWithArray:posts];
            [self.tableView reloadData];
            if (posts.count < 20) {
                [self.tableView setRefreshEnabled:NO];
            }
        }
        else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [TAOverlay showOverlayWithLabel:@"加载失败" Options:TAOverlayOptionOverlayTypeError | TAOverlayOptionOverlaySizeRoundedRect | TAOverlayOptionAutoHide];
            });
        }
    }];
}

#pragma mark - Refresh/Reload Methods

- (void)beginRefreshFooter:(TWRefreshTableView *)tableView {
    [self reloadWithFooter:nil];
}

- (void)reloadWithFooter:(__unused id)sender {
    self.currentPageIndex++;
    dispatch_async(dispatch_get_main_queue(), ^{
        [Post postSortedWithSortType:self.sortType andID:self.identification withDate:self.date atPage:self.currentPageIndex inBlock:^(NSArray *posts, NSError *error) {
            [TAOverlay hideOverlay];
            [self.tableView stopFooterRefreshing];
            if (posts.count == 0) {
                self.currentPageIndex--;
                [self.tableView setRefreshEnabled:NO];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView addMJNotifierWithText:@"已经没有更多了" andStyle:MJAlertViewError dismissAutomatically:YES];
                });
                return;
            }
            if (!error) {
                [self.allPosts addObjectsFromArray:posts];
                [self.tableView reloadData];
                if (posts.count < 20) {
                    [self.tableView setRefreshEnabled:NO];
                }
            }
            else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [TAOverlay showOverlayWithLabel:@"加载失败" Options:TAOverlayOptionOverlayTypeError | TAOverlayOptionOverlaySizeRoundedRect | TAOverlayOptionAutoHide];
                });
            }
        }];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentPageIndex = 1;
    
    _tableView = [[TWRefreshTableView alloc]initWithFrame:self.view.bounds refreshType:TWRefreshTypeBottom];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.refreshDelegate = self;
    self.tableView = _tableView;
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.2 alpha:1];
    
    self.clearsSelectionOnViewWillAppear = YES;
    
    if (IOS_VERSION_9_OR_ABOVE) {
        [self registerForPreviewingWithDelegate:self sourceView:self.tableView];
    }
    
    [TAOverlay showOverlayWithLogo];
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseIdentifier];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allPosts.count;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return POST_TABLE_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    // Configure the cell...
    Post *post = [self.allPosts objectAtIndex:indexPath.row];
    
    cell.post = post;
    // Set the color
    cell.authorLabel.textColor = [AppColor mainYellow];
    cell.shortDescLabel.textColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:0.6];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger selectedPostID = [self.allPosts[indexPath.row] postID];
    Post *selectedPost = self.allPosts[indexPath.row];
    SinglePostTableViewController *singlePostVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
    
    singlePostVC.title = selectedPost.title;
    singlePostVC.postID = selectedPostID;
    
    [self.navigationController pushViewController:singlePostVC animated:YES];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    SinglePostTableViewController *singlePostTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
    
    singlePostTVC.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    NSUInteger row = location.y /POST_TABLE_CELL_HEIGHT;
    
    Post *selectedPost = self.allPosts[row];
    
    singlePostTVC.title = selectedPost.title;
    singlePostTVC.postID = selectedPost.postID;
    
    singlePostTVC.isFromPeek = YES;
    
    previewingContext.sourceRect = CGRectMake(0, [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]].frame.origin.y, previewingContext.sourceView.frame.size.width, POST_TABLE_CELL_HEIGHT);
    return singlePostTVC;
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
