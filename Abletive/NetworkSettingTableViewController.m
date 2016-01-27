//
//  NetworkSettingTableViewController.m
//  Abletive
//
//  Created by Cali on 6/27/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "NetworkSettingTableViewController.h"
#import "TAOverlay.h"
#import "HHAlertView.h"
#import "SDImageCache.h"
#import "SDCycleScrollView.h"

@interface NetworkSettingTableViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *wifiSwitch;
@property (weak, nonatomic) IBOutlet UILabel *imageCacheSizeLabel;

@end

static NSString * const reuseIdentifier = @"SwitchReuse";

@implementation NetworkSettingTableViewController

- (void)viewDidLoad {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.wifiSwitch.on = [[NSUserDefaults standardUserDefaults]boolForKey:@"load_wifi_only"];
    
    CGFloat cacheSize = [[SDImageCache sharedImageCache]getSize] / 1024.0 / 1024.0;
    
    self.imageCacheSizeLabel.text = cacheSize >= 1 ? [NSString stringWithFormat:@"%.2fM",cacheSize] : [NSString stringWithFormat:@"%.2fKB",cacheSize * 1024];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)wifiSwitchDidChange:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults]setBool:sender.on forKey:@"load_wifi_only"];
}

#pragma mark - Table view data source

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1:
            if (indexPath.row == 0) {
                [HHAlertView showAlertWithStyle:HHAlertStyleWarning inView:self.view Title:@"确定要清理缓存吗？" detail:@"所有加载过的图片都会被清除" cancelButton:@"取消" Okbutton:@"确定" block:^(HHAlertButton buttonindex) {
                    if (buttonindex == HHAlertButtonOk) {
                        CGFloat cacheSize = [[SDImageCache sharedImageCache]getSize] / 1024.0 / 1024.0;
                        [[SDImageCache sharedImageCache] clearDisk];
                        [SDCycleScrollView clearCache];
                        
                        NSString *clearCacheTitle = cacheSize >= 1 ? [NSString stringWithFormat:@"清理了%.2fM的缓存",cacheSize] : [NSString stringWithFormat:@"清理了%.2fKB的缓存",cacheSize * 1024];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [TAOverlay showOverlayWithLabel:clearCacheTitle Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlayShadow | TAOverlayOptionOverlayTypeSuccess];
                            self.imageCacheSizeLabel.text = @"0.00KB";
                        });
                    }
                }];
            }
            break;
            
        default:
            break;
    }
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 1;
//}


/*- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NetworkSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}*/


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
