//
//  PersonalPageCreditTableViewController.m
//  Abletive
//
//  Created by Cali on 10/17/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PersonalPageCreditTableViewController.h"
#import "UserCredit.h"
#import "TAOverlay.h"
#import "AppColor.h"

#define COUNT_PER_PAGE 20

static NSString * const identifier = @"CreditLogReuse";

@interface PersonalPageCreditTableViewController ()

@property (nonatomic,strong) NSMutableArray *allCredits;

@property (nonatomic,assign) NSUInteger currentPageIndex;

@end

@implementation PersonalPageCreditTableViewController {
    BOOL _isLoading;
    BOOL _noMore;
}

- (NSMutableArray *)allCredits {
    if (!_allCredits) {
        _allCredits = [NSMutableArray array];
    }
    return _allCredits;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.currentPageIndex = 1;
    
    [self.tableView setTableFooterView:[UIView new]];
    self.tableView.backgroundColor = [AppColor secondaryBlack];
    self.view.backgroundColor = [AppColor secondaryBlack];
    
    [self loadPageData];
    
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPageData {
    _isLoading = YES;
    [TAOverlay showOverlayWithLoading];
    
    [UserCredit getUserCreditWithUserID:self.userID andPage:self.currentPageIndex withCount:20 andBlock:^(NSArray *credits, NSError *error) {
        _isLoading = NO;
        [TAOverlay hideOverlay];
        if (!error) {
            if (!credits.count) {
                _noMore = YES;
                return;
            }
            [self.allCredits addObjectsFromArray:credits];
            [self.tableView reloadData];
            self.currentPageIndex++;
        } else {
            [TAOverlay showOverlayWithError];
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (scrollView.frame.size.height >= scrollView.contentSize.height - offsetY + 35) {
        if (_isLoading || _noMore) {
            return;
        }
        if (self.allCredits.count < COUNT_PER_PAGE) {
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
    return self.allCredits.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    // Configure the cell...
    UserCredit *credit = self.allCredits[indexPath.row];
    
    cell.textLabel.text = credit.content;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.text = credit.date;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    return cell;
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
