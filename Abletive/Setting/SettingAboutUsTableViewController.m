//
//  SettingAboutUsTableViewController.m
//  Abletive
//
//  Created by Cali on 10/21/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "SettingAboutUsTableViewController.h"
#import "KINWebBrowserViewController.h"
#import "SettingTeamViewController.h"
#import "AppColor.h"

@interface SettingAboutUsTableViewController ()

@end

@implementation SettingAboutUsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 1) {
                NSString *appID = @"1050395770";
                NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appID];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            } else {
                KINWebBrowserViewController *browser = [KINWebBrowserViewController webBrowser];
                browser.barTintColor = [AppColor mainBlack];
                browser.tintColor = [AppColor mainYellow];
                browser.actionButtonHidden = YES;
                [self.navigationController pushViewController:browser animated:YES];
                [browser loadURLString:@"http://abletive.com/ios/description.html"];
            }
            break;
        }
        case 1:
        {
            SettingTeamViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Team"];
            controller.stackedLayout.layoutMargin = UIEdgeInsetsZero;
            controller.exposedLayoutMargin = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
            controller.edgesForExtendedLayout = UIRectEdgeNone;
            
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 3:
        {
            KINWebBrowserViewController *browser = [KINWebBrowserViewController webBrowser];
            browser.barTintColor = [AppColor mainBlack];
            browser.tintColor = [AppColor mainYellow];
            browser.actionButtonHidden = YES;
            [self.navigationController pushViewController:browser animated:YES];
            [browser loadURLString:@"http://abletive.com/ios/acknowledgements.html"];
            break;
        }
        default:
        {
            switch (indexPath.row) {
                case 0:
                {
                    KINWebBrowserViewController *browser = [KINWebBrowserViewController webBrowser];
                    browser.barTintColor = [AppColor mainBlack];
                    browser.tintColor = [AppColor mainYellow];
                    [self.navigationController pushViewController:browser animated:YES];
                    [browser loadURLString:@"http://abletive.com/"];
                    break;
                }
                case 2:
                {
                    KINWebBrowserViewController *browser = [KINWebBrowserViewController webBrowser];
                    [self.navigationController pushViewController:browser animated:YES];
                    [browser loadURLString:@"http://abletive.com/privacy.html"];
                    break;
                }
                default:
                {
                    NSString *email = @"mailto:cali@calicastle.com";
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
                    break;
                }
            }
            break;
        }
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
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
