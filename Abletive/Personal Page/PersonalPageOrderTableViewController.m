//
//  PersonalPageOrderTableViewController.m
//  Abletive
//
//  Created by Cali on 10/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PersonalPageOrderTableViewController.h"
#import "PersonalPageOrderTableViewCell.h"
#import "TAOverlay.h"
#import "UserOrder.h"
#import "AppColor.h"

#define COUNT_PER_PAGE 15

static NSString * const identifier = @"OrderReuse";

@interface PersonalPageOrderTableViewController ()

@property (nonatomic,strong) NSMutableArray *allOrders;

@property (nonatomic,assign) NSUInteger currentPageIndex;

@end

@implementation PersonalPageOrderTableViewController {
    BOOL _isLoading;
    BOOL _noMore;
}

- (NSMutableArray *)allOrders {
    if (!_allOrders) {
        _allOrders = [NSMutableArray array];
    }
    return _allOrders;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.tableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    
    self.tableView.backgroundColor = [AppColor secondaryBlack];
    self.view.backgroundColor = [AppColor secondaryBlack];
    
    self.currentPageIndex = 1;
    
    [self loadPageData];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PersonalPageOrderTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:identifier];
}

- (void)loadPageData {
    _isLoading = YES;
    
    [TAOverlay showOverlayWithLoading];
    [UserOrder getOrdersByUserID:self.userID andPage:self.currentPageIndex withCount:COUNT_PER_PAGE andBlock:^(NSArray *orders, NSError *error) {
        _isLoading = NO;
        [TAOverlay hideOverlay];
        if (!error) {
            if (!orders.count) {
                _noMore = YES;
                return;
            }
            [self.allOrders addObjectsFromArray:orders];
            [self.tableView reloadData];
            self.currentPageIndex++;
        } else {
            [TAOverlay showOverlayWithError];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (scrollView.frame.size.height >= scrollView.contentSize.height - offsetY + 35) {
        if (_isLoading || _noMore) {
            return;
        }
        if (self.allOrders.count < COUNT_PER_PAGE) {
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
    return self.allOrders.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PersonalPageOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    // Configure the cell...
    UserOrder *order = self.allOrders[indexPath.row];
    
    cell.userOrder = order;
    
    return cell;
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
