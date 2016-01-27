//
//  PersonalPageCollectionTableViewController.m
//  Abletive
//
//  Created by Cali on 10/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PersonalPageCollectionTableViewController.h"
#import "PostTableViewCell.h"
#import "SinglePostTableViewController.h"
#import "TAOverlay.h"
#import "AppColor.h"
#import "UserCollection.h"
#import "CCDeviceDetecter.h"

#define COUNT_PER_PAGE 15
#define POST_TABLE_CELL_HEIGHT 115

static NSString * const identifier = @"PostViewCell";

@interface PersonalPageCollectionTableViewController ()<UIViewControllerPreviewingDelegate>

@property (nonatomic,strong) NSMutableArray *allCollections;
@property (nonatomic,assign) NSUInteger currentPageIndex;

@end

@implementation PersonalPageCollectionTableViewController {
    BOOL _isLoading;
    BOOL _noMore;
}

- (NSMutableArray *)allCollections {
    if (!_allCollections) {
        _allCollections = [NSMutableArray array];
    }
    return _allCollections;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    self.currentPageIndex = 1;
    
    self.tableView.backgroundColor = [AppColor secondaryBlack];
    self.view.backgroundColor = [AppColor secondaryBlack];
    
    [self loadPageData];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        if (self.userID == [[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]integerValue]) {
            self.navigationItem.rightBarButtonItem = self.editButtonItem;
        }
    }
    if (IOS_VERSION_9_OR_ABOVE) {
        [self registerForPreviewingWithDelegate:self sourceView:self.tableView];
    }
    [self.tableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:identifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPageData {
    _isLoading = YES;
    [TAOverlay showOverlayWithLabel:@"加载中..." Options:TAOverlayOptionOpaqueBackground | TAOverlayOptionOverlaySizeRoundedRect | TAOverlayOptionOverlayTypeActivityDefault | TAOverlayOptionOverlayDismissTap];
    [UserCollection getCollectionListByUserID:self.userID andPage:self.currentPageIndex andCount:COUNT_PER_PAGE andBlock:^(NSArray *collections, NSError *error) {
        _isLoading = NO;
        [TAOverlay hideOverlay];
        if (!error) {
            if (!collections.count) {
                _noMore = YES;
                return;
            }
            [self.allCollections addObjectsFromArray:collections];
            [self.tableView reloadData];
            self.currentPageIndex++;
        } else {
            [TAOverlay showOverlayWithLabel:@"加载错误" Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlayTypeError | TAOverlayOptionOverlaySizeRoundedRect];
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (scrollView.frame.size.height >= scrollView.contentSize.height - offsetY + 35) {
        if (_isLoading || _noMore) {
            return;
        }
        if (self.allCollections.count < COUNT_PER_PAGE) {
            return;
        }
        _isLoading = YES;
        [self loadPageData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allCollections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return POST_TABLE_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.userCollection = self.allCollections[indexPath.row];
    cell.authorLabel.textColor = [AppColor mainYellow];
    cell.shortDescLabel.textColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:0.6];
    
    cell.tag = indexPath.row;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCollection *userCollection = self.allCollections[indexPath.row];
    SinglePostTableViewController *singlePostVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
    
    singlePostVC.title = userCollection.title;
    singlePostVC.postID = userCollection.postID;
    
    [self.navigationController pushViewController:singlePostVC animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        if (self.userID == [[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]integerValue]) {
            return YES;
        }
    }
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self uncollectPostAtPath:indexPath.row];
        [self.allCollections removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)uncollectPostAtPath:(NSUInteger)index {
    UserCollection *collection = self.allCollections[index];
    [User collectPostByPostID:collection.postID forRemove:YES andBlock:^(BOOL success,BOOL collected) {
        if (!success) {
            [TAOverlay showOverlayWithLabel:@"取消收藏失败，请刷新重试" Options:TAOverlayOptionOverlaySizeRoundedRect | TAOverlayOptionOverlayTypeError | TAOverlayOptionAutoHide];
        }
    }];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    SinglePostTableViewController *singlePostTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
    
    singlePostTVC.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    NSUInteger row = location.y /POST_TABLE_CELL_HEIGHT;
    
    UserCollection *collection = self.allCollections[row];
    
    singlePostTVC.title = collection.title;
    singlePostTVC.postID = collection.postID;
    
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
