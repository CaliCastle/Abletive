//
//  PostSearchResultsController.m
//  Abletive
//
//  Created by Cali on 6/15/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PostSearchResultsController.h"
#import "SearchResultsTVC.h"
#import "UIImage+Rounded.h"
#import "MJAlertView/UIView+MJAlertView.h"
#import "AppColor.h"

@interface PostSearchResultsController () <UISearchBarDelegate>

@property (nonatomic,strong) UISearchController *searchController;
@property (nonatomic,strong) NSMutableArray *searchedItems;
@property (weak, nonatomic) IBOutlet UIButton *clearHistoryButton;

@end

static NSString * const fileName = @"SearchedItems.plist";

@implementation PostSearchResultsController
{
    SearchResultsTVC *searchResultsTVC;
}

#pragma mark - Initialization

- (NSArray *)searchedItems {
    if (!_searchedItems) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
        NSArray *searchedItems = [NSMutableArray arrayWithContentsOfFile:filePath];
        if (searchedItems) {
            _searchedItems = [NSMutableArray arrayWithArray:searchedItems];
        }
        else {
            _searchedItems = [NSMutableArray array];
        }
    }
    return _searchedItems;
}

#pragma mark - View Related Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![self.searchedItems count]) {
        self.clearHistoryButton.enabled = NO;
    }
    // Instantiate
    searchResultsTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchResults"];
    searchResultsTVC.navi = self.navigationController;
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:searchResultsTVC];
    // Set the search bar to fit
    [self.searchController.searchBar sizeToFit];
    // Apply the search bar to table header
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    // Set up color
    self.searchController.searchBar.barTintColor = [AppColor transparent];
    self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    // Set delegate
    //self.searchController.searchResultsUpdater = searchResultsTVC;
    self.searchController.searchBar.delegate = self;
    
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.15];
    
    self.clearHistoryButton.layer.masksToBounds = YES;
    self.clearHistoryButton.layer.borderColor = [AppColor mainYellow].CGColor;
    self.clearHistoryButton.layer.borderWidth = 1.5f;
    self.clearHistoryButton.layer.cornerRadius = 15.0f;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SearchedCell"];
}

/**
 When the VC disappeared, store the history searched items into plist
 */
- (void)viewDidDisappear:(BOOL)animated {
    // When user leaves, store the items into plist
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    [self.searchedItems writeToFile:filePath atomically:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Clear History

- (IBAction)clearSearchedItems:(id)sender {
    if (self.searchedItems.count == 0) {
        [UIView addMJNotifierWithText:@"已经是空了" andStyle:MJAlertViewError dismissAutomatically:YES];
        return;
    }
    [self.searchedItems removeAllObjects];
    [self.tableView reloadData];
    self.clearHistoryButton.hidden = YES;
}

#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(nonnull UISearchBar *)searchBar {
    // If the already got it searched, no need to add again
    BOOL repeated = NO;
    for (NSString *item in self.searchedItems) {
        NSString *lowercase = [item lowercaseString];
        if ([lowercase isEqualToString:[searchBar.text lowercaseString]]) {
            repeated = YES;
        }
    }
    if (!repeated) {
        [self.searchedItems addObject:searchBar.text];
        self.clearHistoryButton.enabled = YES;
    }
    // Do the search action and send request
    [searchResultsTVC searchWithText:searchBar.text];
    // Display the searched items
    [self.tableView reloadData];
    if (self.clearHistoryButton.hidden) {
        self.clearHistoryButton.hidden = NO;
    }
}

- (void)resetClearButton {
    self.clearHistoryButton.enabled = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchedItems.count;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (NSString *)tableView:(nonnull UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"搜索过%lu项",(unsigned long)self.searchedItems.count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchedCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = self.searchedItems[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self.searchController.searchBar setText:self.searchedItems[indexPath.row]];
    [self.searchController setActive:YES];
    [self.searchController setEditing:YES animated:YES];
    [self searchBarSearchButtonClicked:self.searchController.searchBar];
}

#pragma mark - Table View Edit

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.searchedItems removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
        if (!self.searchedItems.count) {
            [self resetClearButton];
        }
    }
}

@end
