//
//  PersonalPageCommentTableViewController.m
//  Abletive
//
//  Created by Cali on 10/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PersonalPageCommentTableViewController.h"
#import "PersonalPageCommentTableViewCell.h"
#import "SinglePostTableViewController.h"
#import "TAOverlay.h"
#import "AppColor.h"
#import "User.h"
#import "CCDeviceDetecter.h"

#define COUNT_PER_PAGE 15
#define POST_TABLE_CELL_HEIGHT 100

@interface PersonalPageCommentTableViewController ()<UIViewControllerPreviewingDelegate>

@property (nonatomic,strong) NSMutableArray *allComments;

@property (nonatomic,assign) NSUInteger currentPageIndex;

@end

static NSString * const identifier = @"CommentReuse";

@implementation PersonalPageCommentTableViewController {
    BOOL _isLoading;
    BOOL _noMore;
}

- (NSMutableArray *)allComments {
    if (!_allComments) {
        _allComments = [NSMutableArray array];
    }
    return _allComments;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    self.currentPageIndex = 1;
    
    [self loadPageData];
    
    self.tableView.backgroundColor = [AppColor secondaryBlack];
    self.view.backgroundColor = [AppColor secondaryBlack];
    
    if (IOS_VERSION_9_OR_ABOVE) {
        [self registerForPreviewingWithDelegate:self sourceView:self.tableView];
    }
    
    [self.tableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    [self.tableView registerNib:[UINib nibWithNibName:@"PersonalPageCommentTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:identifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPageData {
    [TAOverlay showOverlayWithLabel:@"加载中..." Options:TAOverlayOptionOverlaySizeRoundedRect | TAOverlayOptionOverlayTypeActivityDefault];
    [User getCommentListByUserID:self.userID andPage:self.currentPageIndex withCount:COUNT_PER_PAGE andBlock:^(NSArray *comment, NSError *error) {
        [TAOverlay hideOverlay];
        _isLoading = NO;
        if (!comment.count) {
            _noMore = YES;
        }
        if (!error) {
            [self.allComments addObjectsFromArray:comment];
            [self.tableView reloadData];
            self.currentPageIndex++;
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (scrollView.frame.size.height >= scrollView.contentSize.height - offsetY + 35) {
        if (_isLoading || _noMore) {
            return;
        }
        if (self.allComments.count < COUNT_PER_PAGE) {
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
    return self.allComments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return POST_TABLE_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PersonalPageCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    // Configure the cell...
    
    UserComment *comment = self.allComments[indexPath.row];
    cell.postTitleLabel.text = [NSString stringWithFormat:@"在《%@》中发表回复",comment.postTitle];
    cell.postContentLabel.text = comment.content;
    cell.postDateLabel.text = comment.commentDate;
    cell.fromLabel.text = comment.isFromApp?@"来自iOS客户端":@"来自网页版";
    cell.fromImageView.image = comment.isFromApp?[[UIImage imageNamed:@"community"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]:[[UIImage imageNamed:@"safari"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.fromImageView setTintColor:[AppColor mainYellow]];
    cell.tag = indexPath.row;

    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SinglePostTableViewController *singlePostVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
    
    UserComment *comment = self.allComments[indexPath.row];
    singlePostVC.title = comment.postTitle;
    singlePostVC.postID = comment.postID;
    
    [self.navigationController pushViewController:singlePostVC animated:YES];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    SinglePostTableViewController *singlePostTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
    
    singlePostTVC.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    NSUInteger row = location.y /POST_TABLE_CELL_HEIGHT;
    
    UserComment *comment = self.allComments[row];
    
    singlePostTVC.title = comment.postTitle;
    singlePostTVC.postID = comment.postID;
    
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
