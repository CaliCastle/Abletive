//
//  SettingTeamViewController.m
//  Abletive
//
//  Created by Cali Castle on 1/16/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

#import "SettingTeamViewController.h"
#import "SettingTeamCollectionViewCell.h"
#import "Team.h"

@interface SettingTeamViewController ()

@property (nonatomic,strong) NSMutableArray *teamMembers;

@end

@implementation SettingTeamViewController

- (NSArray *)teamMembers {
    if (!_teamMembers) {
        _teamMembers = [NSMutableArray arrayWithArray:[Team allTeamMembers]];
    }
    return _teamMembers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.stackedLayout.fillHeight = YES;
    self.stackedLayout.alwaysBounce = YES;
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionViewDataSource protocol

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.teamMembers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SettingTeamCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TeamReuse" forIndexPath:indexPath];
    cell.team = self.teamMembers[indexPath.item];
    
    return cell;
}

- (void)moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    Team *toTeam = self.teamMembers[fromIndexPath.item];
    
    [self.teamMembers removeObjectAtIndex:fromIndexPath.item];
    [self.teamMembers insertObject:toTeam atIndex:toIndexPath.item];
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
