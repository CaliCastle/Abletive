//
//  CommunityVIPViewController.m
//  Abletive
//
//  Created by Cali on 11/7/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "CommunityVIPViewController.h"
#import "CommunityVIPCollectionViewCell.h"
#import "AppColor.h"
#import "LaunchpadProject.h"
#import "UIImageView+WebCache.h"
#import "KINWebBrowser/KINWebBrowserViewController.h"

@interface CommunityVIPViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UISegmentedControl *starSegmentControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,strong) NSMutableDictionary *allProjects;

@property (nonatomic,assign) NSUInteger currentStar;

@end

@implementation CommunityVIPViewController {
    BOOL _isLoading;
    UIActivityIndicatorView *_activityIndicator;
}

- (NSMutableDictionary *)allProjects {
    if (!_allProjects) {
        _allProjects = [NSMutableDictionary dictionaryWithCapacity:6];
    }
    return _allProjects;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentStar = 1;
    // Do any additional setup after loading the view.
    [self setUpViewsAndProperties];
    [self loadPageData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpViewsAndProperties {
    self.title = @"VIP专属工程";
    self.view.backgroundColor = [AppColor secondaryBlack];
    self.collectionView.backgroundColor = [AppColor transparent];
    self.collectionView.showsVerticalScrollIndicator = NO;
}

- (void)loadPageData {
    if (_isLoading || [self.allProjects objectForKey:[NSNumber numberWithInteger:self.currentStar]]) {
        return;
    }
    _isLoading = YES;
    _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.frame = CGRectMake(0, 0, 50, 50);
    _activityIndicator.center = self.view.center;
    [self.view addSubview:_activityIndicator];
    
    [_activityIndicator startAnimating];
    
    self.starSegmentControl.enabled = NO;
    [LaunchpadProject getLaunchpadProjectsWithStar:self.currentStar andBlock:^(NSArray *projects, NSError *error) {
        [_activityIndicator removeFromSuperview];
        _isLoading = NO;
        self.starSegmentControl.enabled = YES;
        if (!error) {
            [self.allProjects setObject:projects forKey:[NSNumber numberWithInteger:self.currentStar]];
            [self.collectionView reloadData];
        }
    }];
}

- (IBAction)starSegmentDidChange:(UISegmentedControl *)sender {
    self.currentStar = sender.selectedSegmentIndex + 1;
    [self.collectionView reloadData];
    [self loadPageData];
}

#pragma mark Collection view data source/delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *currentProjects = [self.allProjects objectForKey:[NSNumber numberWithInteger:self.currentStar]];
    if (!currentProjects) {
        return 0;
    }
    return currentProjects.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width / 2.2, collectionView.frame.size.width / 2.2);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIdentifier = @"CommunityVIPCell";
    CommunityVIPCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSArray *currentProjects = [self.allProjects objectForKey:[NSNumber numberWithInteger:self.currentStar]];
    LaunchpadProject *project = [currentProjects objectAtIndex:indexPath.row];
    cell.titleLabel.text = project.projectName;
    cell.titleLabel.layer.masksToBounds = YES;
    cell.titleLabel.layer.cornerRadius = 10;
    
    cell.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    if (project.thumbnail) {
        [cell.thumbnail sd_setImageWithURL:[NSURL URLWithString:project.thumbnail] placeholderImage:[UIImage imageNamed:@"LaunchLOGO.png"]];
    } else {
        cell.thumbnail.image = [UIImage imageNamed:@"launchpad-section"];
    }
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 12.f;
    
    cell.backgroundColor = [AppColor secondaryBlack];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *currentProjects = [self.allProjects objectForKey:[NSNumber numberWithInteger:self.currentStar]];
    LaunchpadProject *project = [currentProjects objectAtIndex:indexPath.row];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:project.projectName message:[NSString stringWithFormat:@"工程作者：%@",project.maker] preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"工程下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UINavigationController *webBrowser = [KINWebBrowserViewController navigationControllerWithWebBrowser];
        
        [self presentViewController:webBrowser animated:YES completion:^{
            if (project.baiduLink) {
                [webBrowser.rootWebBrowser loadURLString:project.baiduLink];
            } else {
                [webBrowser.rootWebBrowser loadURLString:project.qiniuLink];
            }
        }];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"观看视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UINavigationController *webBrowser = [KINWebBrowserViewController navigationControllerWithWebBrowser];
        
        [self presentViewController:webBrowser animated:YES completion:^{
            [webBrowser.rootWebBrowser loadURLString:project.videoLink];
        }];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
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
