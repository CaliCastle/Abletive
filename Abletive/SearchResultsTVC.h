//
//  SearchResultsTVC.h
//  Abletive
//
//  Created by Cali on 6/16/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsTVC : UITableViewController <UISearchResultsUpdating>

@property (nonatomic,weak) UINavigationController *navi;

- (void)searchWithText:(NSString *)text;

@end
