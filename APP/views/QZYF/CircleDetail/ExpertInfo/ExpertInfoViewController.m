//
//  ExpertInfoViewController.m
//  wenYao-store
//
//  Created by Yang Yuexia on 16/1/7.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "ExpertInfoViewController.h"
#import "QCSlideSwitchView.h"
#import "ExpertCommentViewController.h"
#import "ExpertFlowerViewController.h"
#import "ExpertSystemInfoViewController.h"
#import "CustomPopListView.h"
#import "Circle.h"
#import "SVProgressHUD.H"
#import "ReturnIndexView.h"
#import "Constant.h"
#import "AppDelegate.h"

@interface ExpertInfoViewController ()<QCSlideSwitchViewDelegate,CustomPopListViewDelegate>
{
    __weak QWBaseVC  *currentViewController;
}
@property (nonatomic, strong) NSMutableArray *viewControllerArray;
@property (nonatomic ,strong) QCSlideSwitchView * slideSwitchView;
@property (strong, nonatomic) CustomPopListView *customPopListView;

@property (strong, nonatomic) UIImageView *redPointOne;
@property (strong, nonatomic) UIImageView *redPointTwo;
@property (strong, nonatomic) UIImageView *redPointThree;

@property (strong, nonatomic) ExpertCommentViewController *comment;
@property (strong, nonatomic) ReturnIndexView *indexView;

@end

@implementation ExpertInfoViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"圈子";
    self.viewControllerArray = [NSMutableArray array];
    
    
    //3.1 change
//    if (QWGLOBALMANAGER.configure.flagSilenced) {
//        [self showInfoView:@"您已被禁言" image:@"ic_img_cry"];
//        return;
//    }
    
    [self setupViewController];
    [self setupSliderView];

    [self setUpRightItem];
    [self setupRedPoint];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.selectedTab == 1){
        [self.slideSwitchView jumpToTabAtIndex:0];
    }else if (self.selectedTab == 2){
        [self.slideSwitchView jumpToTabAtIndex:1];
    }else if (self.selectedTab == 99){
        [self.slideSwitchView jumpToTabAtIndex:2];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.comment) {
        [self.comment viewWillAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.selectedTab = -1;
}


- (void)setUpRightItem
{
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -15;
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    
    //三个点button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(5, -2, 50, 40);
    
    [button setImage:[[UIImage imageNamed:@"icon_more_slide_details"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:button];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItems = @[fixed,rightItem];
}

- (void)rightAction
{
    self.indexView = [[ReturnIndexView alloc] initWithImage:@[@"icon_check all_news",@"icon_homepage_news"] title:@[@"全部已读",@"首页"]];
    self.indexView.delegate = self;
    [self.indexView show];
}

- (void)RetunIndexView:(ReturnIndexView *)ReturnIndexView didSelectedIndex:(NSIndexPath *)indexPath
{
    [self.indexView hide];
    
    if (indexPath.row == 0)
    {
        //全部已读
        [self setReadAllMsg];
    }else if (indexPath.row == 1)
    {
        //首页
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self performSelector:@selector(delayPopToHome) withObject:nil afterDelay:0.01];
    }
}

- (void)setReadAllMsg
{
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:kWarning12];
        return;
    }
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = StrFromObj(QWGLOBALMANAGER.configure.userToken);
    setting[@"readFlag"] = @"N";
    [Circle TeamChangeAllMessageReadFlagWithParams:setting success:^(id obj) {
        BaseAPIModel *model = [BaseAPIModel parse:obj];
        if ([model.apiStatus integerValue] == 0) {
            self.redPointOne.hidden = YES;
            self.redPointTwo.hidden = YES;
            self.redPointThree.hidden = YES;
            QWGLOBALMANAGER.configure.expertCommentRed = NO;
            QWGLOBALMANAGER.configure.expertFlowerRed = NO;
            QWGLOBALMANAGER.configure.expertSystemInfoRed = NO;
            [QWGLOBALMANAGER saveAppConfigure];
            // 抛出通知，其余页面重新计算圈子小红点
            [QWGLOBALMANAGER postNotif:NotifCircleMsgRedPoint data:nil object:nil];
            [QWGLOBALMANAGER noticeUnreadLocalWithType:MsgBoxListMsgTypeCircle sessionID:nil isRead:YES];
        }
    } failure:^(HttpException *e) {
    }];

    // TODO: 需要?
    MsgBoxListSetReadTypeModelR *modelR = [MsgBoxListSetReadTypeModelR new];
    modelR.token = QWGLOBALMANAGER.configure.userToken;
    modelR.type = @(MsgBoxListMsgTypeCircle).stringValue;
    [Consult setReadMsgBoxListByTypeWithParam:modelR success:^(BaseAPIModel *responModel) {
        if ([responModel.apiStatus integerValue] == 0) {
            self.redPointOne.hidden = YES;
            self.redPointTwo.hidden = YES;
            self.redPointThree.hidden = YES;
            QWGLOBALMANAGER.configure.expertCommentRed = NO;
            QWGLOBALMANAGER.configure.expertFlowerRed = NO;
            QWGLOBALMANAGER.configure.expertSystemInfoRed = NO;
            [QWGLOBALMANAGER saveAppConfigure];
            // 抛出通知，其余页面重新计算圈子小红点
            [QWGLOBALMANAGER postNotif:NotifCircleMsgRedPoint data:nil object:nil];
            [QWGLOBALMANAGER noticeUnreadLocalWithType:MsgBoxListMsgTypeCircle sessionID:nil isRead:YES];
        }
        
    } failure:^(HttpException *e) {
        
    }];
}

- (void)delayPopToHome
{
    if (QWGLOBALMANAGER.weChatBusiness)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:NO];
            [APPDelegate.mainVC selectedViewControllerWithTag:0];
        });
    }else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:NO];
            [APPDelegate.mainVC selectedViewControllerWithTag:5];
        });
    }
}

- (void)popVCAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
    if (self.redPointOne.hidden && self.redPointTwo.hidden && self.redPointThree.hidden) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(hiddenCircleMessageRedPoint)]) {
            [self.delegate hiddenCircleMessageRedPoint];
        }
    }
}

- (void)setupViewController{
    
    self.comment = [[UIStoryboard storyboardWithName:@"ExpertInfo" bundle:nil] instantiateViewControllerWithIdentifier:@"ExpertCommentViewController"];
    self.comment.title=@"评论";
    self.comment.navigationController = self.navigationController;
    self.comment.refreshBlock = ^(BOOL success){
        if (success) {
            QWGLOBALMANAGER.configure.expertCommentRed = NO;
            [QWGLOBALMANAGER saveAppConfigure];
            [QWGLOBALMANAGER postNotif:NotifCircleMsgRedPoint data:nil object:nil];
        }
    };
    
    ExpertFlowerViewController *flower = [[UIStoryboard storyboardWithName:@"ExpertInfo" bundle:nil] instantiateViewControllerWithIdentifier:@"ExpertFlowerViewController"];
    flower.title=@"赞";
    flower.navigationController = self.navigationController;
    flower.refreshBlock = ^(BOOL success){
        if (success) {
            QWGLOBALMANAGER.configure.expertFlowerRed = NO;
            [QWGLOBALMANAGER saveAppConfigure];
            [QWGLOBALMANAGER postNotif:NotifCircleMsgRedPoint data:nil object:nil];
        }
    };
    
    ExpertSystemInfoViewController *system = [[UIStoryboard storyboardWithName:@"ExpertInfo" bundle:nil] instantiateViewControllerWithIdentifier:@"ExpertSystemInfoViewController"];
    system.title=@"系统消息";
    system.navigationController = self.navigationController;
    system.refreshBlock = ^(BOOL success){
        if (success) {
            QWGLOBALMANAGER.configure.expertSystemInfoRed = NO;
            [QWGLOBALMANAGER saveAppConfigure];
            [QWGLOBALMANAGER postNotif:NotifCircleMsgRedPoint data:nil object:nil];
        }
    };
    
    currentViewController = self.comment;
    self.viewControllerArray = [NSMutableArray arrayWithObjects:self.comment,flower,system, nil];
}

- (void)setupSliderView
{
    self.slideSwitchView = [[QCSlideSwitchView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H - 44)];
    self.slideSwitchView.tabItemNormalColor = RGBHex(qwColor8);
    [self.slideSwitchView.topScrollView setBackgroundColor:RGBHex(qwColor4)];
    self.slideSwitchView.tabItemSelectedColor = RGBHex(qwColor1);
    self.slideSwitchView.slideSwitchViewDelegate = self;
    self.slideSwitchView.shadowImage = [[UIImage imageNamed:@"blue_line_and_shadow"]
                                        stretchableImageWithLeftCapWidth:96.0f topCapHeight:0.0f];
    
    [self.slideSwitchView buildUI];
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 0.5)];
    line1.backgroundColor = RGBHex(qwColor10);
    [self.slideSwitchView addSubview:line1];
    
    [self.view addSubview:self.slideSwitchView];
    self.slideSwitchView.topScrollView.scrollEnabled = NO;
    self.slideSwitchView.rootScrollView.scrollEnabled = YES;
}

- (void)setupRedPoint
{
    self.redPointOne = [[UIImageView alloc] initWithFrame:CGRectMake(APP_W/3-35, 10, 7, 7)];
    self.redPointOne.image = [UIImage imageNamed:@"img_redDot"];
    self.redPointOne.hidden = !QWGLOBALMANAGER.configure.expertCommentRed;
    [self.slideSwitchView.topScrollView addSubview:self.redPointOne];
    
    self.redPointTwo = [[UIImageView alloc] initWithFrame:CGRectMake(APP_W*2/3-40, 10, 7, 7)];
    self.redPointTwo.image = [UIImage imageNamed:@"img_redDot"];
    self.redPointTwo.hidden = !QWGLOBALMANAGER.configure.expertFlowerRed;
    [self.slideSwitchView.topScrollView addSubview:self.redPointTwo];
    
    self.redPointThree = [[UIImageView alloc] initWithFrame:CGRectMake(APP_W*3/3-25, 10, 7, 7)];
    self.redPointThree.image = [UIImage imageNamed:@"img_redDot"];
    self.redPointThree.hidden = !QWGLOBALMANAGER.configure.expertSystemInfoRed;
    [self.slideSwitchView.topScrollView addSubview:self.redPointThree];
}

#pragma mark ---- QCSlideSwitchView 代理 ----

- (NSUInteger)numberOfTab:(QCSlideSwitchView *)view
{
    return self.viewControllerArray.count;
}

- (UIViewController *)slideSwitchView:(QCSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    return self.viewControllerArray[number];
}

- (void)slideSwitchView:(QCSlideSwitchView *)view didselectTab:(NSUInteger)number
{
    NSString* eventId = @"x_wgzdqz_qz_pl";
    NSString* label = @"我关注的圈子-圈子-点击某个评论";
    if (number == 0) {
        eventId = @"x_wgzdqz_qz_pl";
        label = @"我关注的圈子-圈子-点击某个评论";
    }else if (number == 1){
        eventId = @"x_wgzdqz_qz_z";
        label = @"我关注的圈子-圈子-点击某个赞";
    }else if (number == 2){
        eventId = @"x_wgzdqz_qz_xtxx";
        label = @"我关注的圈子-圈子-点击某个系统消息";
    }
    [QWGLOBALMANAGER statisticsEventId:eventId withLable:label withParams:nil];
    
    [self.viewControllerArray[number] viewDidCurrentView];
}

#pragma mark ---- 接收通知 ----

- (void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj
{
     if (NotifCircleMsgRedPoint == type)
    {
        //圈子消息小红点
        self.redPointOne.hidden = !QWGLOBALMANAGER.configure.expertCommentRed;
        self.redPointTwo.hidden = !QWGLOBALMANAGER.configure.expertFlowerRed;
        self.redPointThree.hidden = !QWGLOBALMANAGER.configure.expertSystemInfoRed;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
