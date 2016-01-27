//
//  Team.m
//  Abletive
//
//  Created by Cali Castle on 1/16/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

#import "Team.h"

@implementation Team

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (self) {
        self.name = attributes[@"name"];
        self.avatarPath = attributes[@"avatarPath"];
        self.aboutMe = attributes[@"aboutMe"];
        self.position = attributes[@"position"];
    }
    return self;
}

+ (instancetype)teamWithAttributes:(NSDictionary *)attributes {
    return [[Team alloc]initWithAttributes:attributes];
}

+ (NSArray *)allTeamMembers {
    Team *cali = [Team teamWithAttributes:@{@"name":@"Cali",@"avatarPath":@"avatar-cali",@"aboutMe":@"Cali Castle, Abletive创始人、网站、iOS开发者，喜欢做做教学视频帮助大家",@"position":@"站长，创始人"}];
    Team *taioes = [Team teamWithAttributes:@{@"name":@"Taioes",@"avatarPath":@"avatar-taioes",@"aboutMe":@"Now or Never",@"position":@"服务器工程师"}];
    Team *cherry = [Team teamWithAttributes:@{@"name":@"Cher2y",@"avatarPath":@"avatar-cherry",@"aboutMe":@"网瘾少年晚期，正版游戏受害者。Abletive大法好，Cali保平安。",@"position":@"微博小编/字幕组"}];
    Team *pineapple = [Team teamWithAttributes:@{@"name":@"椒盐菠萝",@"avatarPath":@"avatar-pineapple",@"aboutMe":@"中学生，电子音乐爱好者",@"position":@"B站宣传大使"}];
    Team *herny = [Team teamWithAttributes:@{@"name":@"Herny",@"avatarPath":@"avatar-herny",@"aboutMe":@"一个从事着古典音乐却为电子音乐而疯狂的有志青年",@"position":@"核心助理"}];
    Team *urazc = [Team teamWithAttributes:@{@"name":@"Urazc",@"avatarPath":@"avatar-urazc",@"aboutMe":@"原名Color Light，人称彩灯，Live & Launchpad新人一枚，在Cali的洗脑下走入Live深渊无法自拔。",@"position":@"核心助理、编辑"}];
    Team *anne = [Team teamWithAttributes:@{@"name":@"AnneKerO",@"avatarPath":@"avatar-anne",@"aboutMe":@"Hello Everybody!  我是AnneKerO,人称大姐2333。 冰城哈尔滨是我的家乡，鄙人性格直爽，热门豪迈，大义凛然（跑偏）热爱音乐，喜欢玩Launchpad，弹钢琴，跳舞，看电影。作为Abletive.com的核心人员，希望在社区与大家更快乐的交流与分享更丰富的资源。独特是 一种气质！",@"position":@"核心编辑、主管"}];
    Team *mixL = [Team teamWithAttributes:@{@"name":@"MixL",@"avatarPath":@"avatar-mixl",@"aboutMe":@"Hi~I'm Mix L o(*￣▽￣*)ブ 祝Abletive社区越来越强大，祝Cali的人气越来越高！",@"position":@"核心编辑"}];
    Team *azazel = [Team teamWithAttributes:@{@"name":@"Azazel",@"avatarPath":@"avatar-azazel",@"aboutMe":@"本人擅长LIVE、FL、Ae、Pr、PS等软件的安装与卸载，精通CSS、JavaScript、PHP、C＋＋、java等单词的拼写",@"position":@"编辑"}];
    Team *wesley = [Team teamWithAttributes:@{@"name":@"Wesley",@"avatarPath":@"avatar-wesley",@"aboutMe":@"Abletive视觉设计",@"position":@"首席设计师"}];
    Team *axuan = [Team teamWithAttributes:@{@"name":@"绅士瑄",@"avatarPath":@"avatar-axuan",@"aboutMe":@"职业游戏主播",@"position":@"小编"}];
    Team *cardinal = [Team teamWithAttributes:@{@"name":@"Cardinal",@"avatarPath":@"avatar-cardinal",@"aboutMe":@"热爱音乐，热爱美食，热爱骑车，热爱一切美好事物的乐天派！",@"position":@"小编"}];
    Team *mrsun = [Team teamWithAttributes:@{@"name":@"Mr_Sun_",@"avatarPath":@"avatar-mrsun",@"aboutMe":@"正在努力成长中的音乐制作人和B站UP主",@"position":@"宣传、四维电堂导师"}];
    mrsun.backgroundColor = [UIColor whiteColor];
    
    Team *des = [Team teamWithAttributes:@{@"name":@"Des-ZT",@"avatarPath":@"avatar-des",@"aboutMe":@"一个懒癌晚期的老大爷，黑暗的是神经病作曲家（吹牛逼的），发现Abletive之后爱上了这个大家庭的博爱者",@"position":@"小编"}];
    Team *geki = [Team teamWithAttributes:@{@"name":@"GEKI4903",@"avatarPath":@"avatar-geki",@"aboutMe":@"出现率高达0.1%的GEKI",@"position":@"美工"}];
    Team *zbreak = [Team teamWithAttributes:@{@"name":@"Zbreak",@"avatarPath":@"avatar-zbreak",@"aboutMe":@"大家好 我的ID是Zbreak 是一个电子音乐和launchpad爱好者 希望我的作品大家能够喜欢",@"position":@"四维电堂导师、主播"}];
    
    return @[cali,cherry,taioes,pineapple,urazc,anne,wesley,mixL,herny,axuan,azazel,cardinal,mrsun,des,zbreak,geki];
}

@end
