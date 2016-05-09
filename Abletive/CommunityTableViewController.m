//
//  CommunityTableViewController.m
//  Abletive
//
//  Created by Cali on 6/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "CommunityTableViewController.h"
#import "CommunityTableViewCell.h"
#import "AppColor.h"
#import "PostDetail.h"
#import "TAOverlay.h"
#import "SinglePostTableViewController.h"
#import "MozTopAlertView.h"
#import "Abletive-Swift.h"
#import "SDCycleScrollView.h"
#import "KINWebBrowser/KINWebBrowserViewController.h"

#define SCROLL_HEADER_HEIGHT 200

@interface CommunityTableViewController () <SideBarDelegate,SDCycleScrollViewDelegate>

@property (nonatomic,strong) SideBar *sideBar;

@property (nonatomic,strong) SDCycleScrollView *scrollHeader;

@property (nonatomic,strong) NSArray *imageURLStrings;

@property (nonatomic,strong) NSArray *titles;

@end

@implementation CommunityTableViewController

- (SideBar *)sideBar {
    if (!_sideBar) {
        _sideBar = [[SideBar alloc]init];
    }
    return _sideBar;
}

- (SDCycleScrollView *)scrollHeader {
    if (!_scrollHeader) {
        _scrollHeader = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SCROLL_HEADER_HEIGHT) imageURLStringsGroup:nil];
    }
    return _scrollHeader;
}

- (NSArray *)imageURLStrings {
    if (!_imageURLStrings) {
        _imageURLStrings = @[@"https://dn-abletive.qbox.me/v%2Fimages%2Ftopshelfbanner.jpg", @"http://abletive.com/wp-content/uploads/2016/01/shuangyizhibo.jpg", @"http://abletive.com/wp-content/uploads/2016/01/xiaomingzhibo.jpg",@"http://abletive.com/wp-content/uploads/2016/01/zbreaklive.jpg",@"http://abletive.com/wp-content/uploads/2016/01/66F6D572E01CF171A46E6494A5764283.jpg"];
    }
    return _imageURLStrings;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"Abletive教学视频站", @"雙一PandaTV直播", @"小明斗鱼Launchpad直播",@"赵总Zbreak PandaTV直播",@"锅哥Launchpad斗鱼直播"];
    }
    return _titles;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [AppColor secondaryBlack];
    [self.tableView setSeparatorColor:[AppColor transparent]];
    [self setUpHeader];
    
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
//    self.sideBar = [[SideBar alloc]initWithSourceView:self.view menuItems:@[@"First",@"Second",@"Third"]];
//    self.sideBar.delegate = self;
}

- (void)setUpHeader {
    self.scrollHeader.imageURLStringsGroup = self.imageURLStrings;
    self.scrollHeader.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    self.scrollHeader.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
    self.scrollHeader.titlesGroup = [NSArray arrayWithArray:self.titles];
    self.scrollHeader.dotColor = [AppColor mainYellow];
    self.scrollHeader.placeholderImage = [UIImage imageNamed:@"banner_placeholder"];
    self.scrollHeader.delegate = self;
    
    self.tableView.tableHeaderView = self.scrollHeader;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Header Delegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    UINavigationController *webBrowser = [KINWebBrowserViewController navigationControllerWithWebBrowser];
    
    NSMutableString *URLString = [NSMutableString stringWithString:@"<h1>直播网页地址：（长按复制）"];
    switch (index) {
        case 0:
//            [self pushTutorialViewController];
            return;
        case 1:
            [URLString appendString:@"http://www.panda.tv/24935"];
            break;
        case 2:
            [URLString appendString:@"http://www.douyutv.com/ZoZen"];
            break;
        case 3:
            [URLString appendString:@"http://www.panda.tv/22271"];
            break;
        default:
            [URLString appendString:@"http://www.douyutv.com/69007"];
            break;
    }
    [URLString appendString:@"</h1>"];
    [self presentViewController:webBrowser animated:YES completion:nil];
//    [webBrowser.rootWebBrowser loadURLString:URLString];
    [webBrowser.rootWebBrowser loadHTMLString:URLString];
}

#pragma mark - Side Bar Delegate

- (void)sideBarDidSelectOnIndex:(NSInteger)index {
//    NSLog(@"Selected: %ld",(long)index);
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
//        case 0:
//            return 1;
        case 0:
            return 3;
        case 1:
            return 2;
        default:
            break;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommunityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommunityReuse" forIndexPath:indexPath];
    
    // Configure the cell...
    
    switch (indexPath.section) {
//        case 0:
//        {
//            // Community Section
//            cell.titleLabel.text = @"视频教学专栏";
//            cell.imgView.image = [[UIImage imageNamed:@"v.abletive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//            cell.descLabel.text = @"专业的电子乐等教学视频";
//            break;
//        }
        case 0:
        {
            // Launchpad Section
            switch (indexPath.row) {
                case 0:
                    cell.imgView.image = [[UIImage imageNamed:@"launchpad-section"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    cell.titleLabel.text = @"Launchpad成长路线";
                    cell.descLabel.text = @"Launchpad 玩家的导航路线，助你一臂之力";
                    break;
                case 1:
                    cell.imgView.image = [UIImage imageNamed:@"vip-only"];
                    cell.titleLabel.text = @"会员专属";
                    cell.descLabel.text = @"会员快捷下载工程&视频😄";
                    break;
                default:
                    cell.imgView.image = [UIImage imageNamed:@"message-board"];
                    cell.titleLabel.text = @"留言板";
                    cell.descLabel.text = @"随意吐槽，留言";
                    break;
            }
            break;
        }
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    cell.imgView.image = [[UIImage imageNamed:@"my-credits"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    cell.imgView.tintColor = [AppColor mainYellow];
                    cell.titleLabel.text = @"积分排行榜";
                    cell.descLabel.text = @"看看谁是积分老大";
                    break;
                case 1:
                    cell.imgView.image = [[UIImage imageNamed:@"membership-expired"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    cell.imgView.tintColor = [AppColor mainYellow];
                    cell.titleLabel.text = @"社区会员";
                    cell.descLabel.text = @"如何成为会员与特权";
                    break;
                default:
                    break;
            }
        }
        default:
            break;
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
//        case 0:
//        {
//            [self pushTutorialViewController];
//            break;
//        }
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    SinglePostTableViewController *pageTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
                    pageTVC.isPage = YES;
                    pageTVC.postID = 2487;
                    [self.navigationController pushViewController:pageTVC animated:YES];
                    break;
                }
                case 1:
                {
                    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"IsVIP"]) {
                        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"user_is_logged"]) {
                            [MozTopAlertView showWithType:MozAlertTypeWarning text:@"您还未开通会员" parentView:self.view];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.65 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Membership"] animated:YES];
                            });
                        } else {
                            [MozTopAlertView showWithType:MozAlertTypeWarning text:@"您还未登录" parentView:self.view];
                        }
                    
                        return;
                    }
                    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"CommunityVIP"] animated:YES];
                    break;
                }
                case 2:
                {
                    SinglePostTableViewController *pageTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
                    pageTVC.isPage = YES;
                    pageTVC.postID = 70;
                    
                    [self.navigationController pushViewController:pageTVC animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"CreditRank"] animated:YES];
                    break;
                case 1:
                {
                    SinglePostTableViewController *pageTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
                    pageTVC.isPage = YES;
                    pageTVC.postID = 4883;
                    
                    [self.navigationController pushViewController:pageTVC animated:YES];
                    break;
                }
                default:
                    break;
            }
        }
        default:
            break;
    }
}

- (void)pushTutorialViewController {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ScreenCastRoot"] animated:YES];
}

@end
