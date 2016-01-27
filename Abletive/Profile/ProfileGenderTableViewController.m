//
//  ProfileGenderTableViewController.m
//  Abletive
//
//  Created by Cali on 10/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "ProfileGenderTableViewController.h"
#import "STPopup.h"
#import "AppColor.h"

#define ROW_HEIGHT 44

@interface ProfileGenderTableViewController ()

@end

@implementation ProfileGenderTableViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.title = NSLocalizedString(@"选择性别", nil);
    self.contentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width, ROW_HEIGHT * 3);
    self.landscapeContentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.height, ROW_HEIGHT * 3);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setTableFooterView:[UIView new]];
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileGenderCell" forIndexPath:indexPath];
    
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            cell.imageView.image = [[UIImage imageNamed:@"profile-male"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.textLabel.text = @"男";
            cell.accessoryType = self.gender == UserGenderMale ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case 1:
            cell.imageView.image = [[UIImage imageNamed:@"profile-female"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.textLabel.text = @"女";
            cell.accessoryType = self.gender == UserGenderFemale ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case 2:
            cell.imageView.image = [[UIImage imageNamed:@"unknown-gender"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.textLabel.text = @"保密";
            cell.accessoryType = self.gender == UserGenderOther ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        default:
            break;
    }
    cell.imageView.tintColor = [UIColor whiteColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            self.gender = UserGenderMale;
            break;
        case 1:
            self.gender = UserGenderFemale;
            break;
        default:
            self.gender = UserGenderOther;
            break;
    }
    [self.delegate genderChanged:self.gender];
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
