//
//  ExpertPageViewController.m
//  wenYao-store
//
//  Created by Yang Yuexia on 16/1/15.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "ExpertPageViewController.h"
#import "NSString+WPAttributedMarkup.h"
#import "CircleDetailCell.h"
#import "CircleDetailNextViewController.h"
#import "CircleModel.h"
#import "Circle.h"
#import "TaReplyViewController.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"
#import "QWProgressHUD.h"
#import "GUITabScrollView.h"
#import "PrivateChatViewController.h"

@interface ExpertPageViewController ()<GUITabPagerDataSource, GUITabPagerDelegate,CircleDetailNextViewControllerDelegaet,TaReplyViewControllerDelegaet>
{
    CGFloat rowHeight;
    int tabNum;
    CircleDetailNextViewController *currentViewController;
    BOOL isHeaderRefresh;
}

@property (strong, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UIImageView *headerIcon;       //头像
@property (weak, nonatomic) IBOutlet UILabel *expertName;           //姓名
@property (weak, nonatomic) IBOutlet UILabel *expertBrandLabel;     //品牌
@property (weak, nonatomic) IBOutlet UILabel *goodFieldLabel;       //擅长领域
@property (weak, nonatomic) IBOutlet UILabel *funsLabel;            //粉丝
@property (weak, nonatomic) IBOutlet UILabel *flowerLabel;          //鲜花
@property (weak, nonatomic) IBOutlet UILabel *attentionLabel;       //关注
@property (weak, nonatomic) IBOutlet UILabel *cancelAttentionLabel; //取消关注
@property (weak, nonatomic) IBOutlet UIButton *attentionButton;     //关注按钮
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onLineStatu_layout_left;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *expertBrand_layout_width;

@property (strong, nonatomic) CircleMaserlistModel *expertInfoModel;
@property (strong, nonatomic) NSMutableArray * sliderTabLists;
@property (strong, nonatomic) NSMutableArray *viewControllerssss;
@property (weak, nonatomic) IBOutlet UIView *offlineView;
@property (weak, nonatomic) IBOutlet UIView *onlineView;

@property (strong, nonatomic) CircleDetailNextViewController *lookViewController;
@property (strong, nonatomic) TaReplyViewController *replyViewController;

@property (weak, nonatomic) IBOutlet UIButton *privateChatBtn;

- (IBAction)payAttentionExpertAction:(id)sender;

- (IBAction)privateChatAction:(id)sender;
@end

@implementation ExpertPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setDataSource:self];
    [self setDelegate:self];
    
    if (self.expertType == 3) {
        self.title = @"药师专栏";
    }else{
        self.title = @"营养师专栏";
    }
    
    self.viewControllerssss = [NSMutableArray array];
    self.sliderTabLists = [NSMutableArray array];
    self.expertInfoModel = [CircleMaserlistModel new];
    
    [self queryCircleInfo];
    [self setUpTableHeaderView];
    [self setupSliderViewControllers];

    [self.view bringSubviewToFront:self.onlineView];
    [self.view bringSubviewToFront:self.privateChatBtn];
        
    if (self.fromPrivateChat) {
        self.onlineView.hidden = YES;
        self.privateChatBtn.hidden = YES;
        self.privateChatBtn.enabled = NO;
    }else{
        
        if (QWGLOBALMANAGER.weChatBusiness){
            self.onlineView.hidden = NO;
            self.privateChatBtn.hidden = NO;
            self.privateChatBtn.enabled = YES;
        }else{
            self.onlineView.hidden = YES;
            self.privateChatBtn.hidden = YES;
            self.privateChatBtn.enabled = NO;
        }
    }
    
    
    //下拉刷新
    __weak ExpertPageViewController *weakSelf = self;
    [self enableSimpleRefresh:self.tableView block:^(SRRefreshView *sender) {
        if (QWGLOBALMANAGER.currentNetWork != kNotReachable) {
            HttpClientMgr.progressEnabled = NO;
            [weakSelf queryCircleInfo];
            weakSelf.tableView.footerNoDataText = @"已显示全部内容";
            [weakSelf.tableView.footer setDiseaseCanLoadMore:YES];
            [self selectTabbarIndex:tabNum];
            currentViewController.expertId = self.posterId;
            [currentViewController currentViewSelected:^(CGFloat height) {
                
            }];
        }else{
            [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试！" duration:0.8];
        }
    }];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self reloadData];
    
    [self refreshPostListWithTabIndex:0];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((QWBaseNavigationController *)self.navigationController).canDragBack = NO;
    
    if (self.expertType == PosterType_YaoShi) {
        [QWGLOBALMANAGER statisticsEventId:@"x_yszl_cx" withLable:@"药师专栏-出现" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"药师名":StrDFString(self.nickName, @"药师名"),@"上级页面":StrDFString(self.preVCNameStr, @"上级页面")}]];
    }
    else if (self.expertType == PosterType_YingYangShi)
    {
        [QWGLOBALMANAGER statisticsEventId:@"x_yyszl_cx" withLable:@"营养师专栏-出现" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"上级页面":StrDFString(self.preVCNameStr, @"上级页面"),@"营养师名字":StrDFString(self.nickName, @"")}]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ((QWBaseNavigationController *)self.navigationController).canDragBack = YES;
}

- (void)popVCAction:(id)sender
{
    [super popVCAction:sender];
    if (self.expertType == PosterType_YaoShi) {
        [QWGLOBALMANAGER statisticsEventId:@"x_yszl_fh" withLable:@"药师专栏-fh" withParams:nil];
    }
    else if (self.expertType == PosterType_YingYangShi)
    {
        [QWGLOBALMANAGER statisticsEventId:@"x_yyszl_fh" withLable:@"营养师专栏-返回" withParams:nil];
    }
}

- (NSInteger)numberOfViewControllers {
    return self.sliderTabLists.count;
}

- (UIViewController<GUITabViewControllerObject> *)viewControllerForIndex:(NSInteger)index
{
    if (index == 0)
    {
        self.lookViewController.delegate = self;
        CGRect rect = self.view.bounds;
        rect.size.height -= 44.f;
        self.lookViewController.view.frame = rect;
        self.lookViewController.delegate = self;
        return self.lookViewController;
    }else
    {
        self.replyViewController.delegate = self;
        CGRect rect = self.view.bounds;
        rect.size.height -= 44.f;
        self.replyViewController.view.frame = rect;
        self.replyViewController.delegate = self;
        return self.replyViewController;
    }
}

- (UIScrollView<GUITabScrollViewObject> *)tabScrollView
{
    NSMutableArray *arrM = [NSMutableArray array];
    for (int i = 0; i < self.sliderTabLists.count; i++) {
        [arrM addObject:[self titleForTabAtIndex:i]];
    }
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    frame.size.height = 44.0f;
    return [[GUITabScrollView alloc] initWithFrame:frame tabTitles:[arrM copy] tabBarHeight:44.0f tabIndicatorHeight:2.0f seperatorHeight:0.5f tabIndicatorColor:RGBHex(qwColor1) seperatorColor:[UIColor lightGrayColor] backgroundColor:[UIColor whiteColor] selectedTabIndex:0 centerSepColor:RGBHex(qwColor20)];
}

- (UIView *)tabPagerHeaderView
{
    return self.tableHeaderView;
}

- (NSString *)titleForTabAtIndex:(NSInteger)index
{
    return self.sliderTabLists[index];
}

/* 代理 */
#pragma mark - Tab Pager Delegate

- (void)tabPager:(GUITabPagerViewController *)tabPager willTransitionToTabAtIndex:(NSInteger)index {
    tabNum = index;
    [self refreshPostListWithTabIndex:tabNum];
    if (index == 0) {
        if (self.expertType == PosterType_YaoShi) {
            [QWGLOBALMANAGER statisticsEventId:@"x_yszl_fw" withLable:@"药师专栏-Ta的发文" withParams:nil];
        }
        else if (self.expertType == PosterType_YingYangShi)
        {
            [QWGLOBALMANAGER statisticsEventId:@"x_yyszl_fw" withLable:@"营养师专栏-Ta的发文" withParams:nil];
        }
    }
    else
    {
        if (self.expertType == PosterType_YaoShi) {
            [QWGLOBALMANAGER statisticsEventId:@"x_yszl_ht" withLable:@"药师专栏-Ta的回帖" withParams:nil];
        }
        else if (self.expertType == PosterType_YingYangShi)
        {
            [QWGLOBALMANAGER statisticsEventId:@"x_yyszl_ht" withLable:@"营养师专栏-Ta的回帖" withParams:nil];
        }
    }
    
    if (index == 0){
        [QWGLOBALMANAGER statisticsEventId:@"专栏_Ta的发文_出现" withLable:@"圈子" withParams:nil];
    }else if (index == 1){
        [QWGLOBALMANAGER statisticsEventId:@"专栏_Ta的回帖_出现" withLable:@"圈子" withParams:nil];
    }

}

- (void)tabPager:(GUITabPagerViewController *)tabPager didTransitionToTabAtIndex:(NSInteger)index {
}

#pragma mark - scrollToTop delegate

/* 外部调整scrollToTop的表现 */
- (void)didScrollToTop:(CircleDetailNextViewController *)vc
{
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.contentOffset = CGPointZero;
    }];
    UIScrollView *sc = (UIScrollView *)vc.view;
    //    sc.bounces  = NO;
    self.tableView.bounces = NO;
}

- (void)expertDidScrollToTop:(TaReplyViewController *)vc;
{
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.contentOffset = CGPointZero;
    }];
    UIScrollView *sc = (UIScrollView *)vc.view;
    //        sc.bounces  = NO;
    self.tableView.bounces = NO;
}

#pragma mark ---- 设置界面数组 ----
- (void)setupSliderViewControllers
{
    if (self.lookViewController == nil) {
        self.lookViewController = [[UIStoryboard storyboardWithName:@"Circle" bundle:nil] instantiateViewControllerWithIdentifier:@"CircleDetailNextViewController"];
        self.lookViewController.navigationController = self.navigationController;
        self.lookViewController.requestType = @"1";
        self.lookViewController.jumpType = @"2";
        self.lookViewController.sliderTabIndex = @"1";
        [self.viewControllerssss addObject:self.lookViewController];
        currentViewController = self.lookViewController;
    }
    if (self.replyViewController == nil) {
        self.replyViewController = [[UIStoryboard storyboardWithName:@"ExpertPage" bundle:nil] instantiateViewControllerWithIdentifier:@"TaReplyViewController"];
        self.replyViewController.navigationController = self.navigationController;
        [self.viewControllerssss addObject:self.replyViewController];
    }
    
    self.sliderTabLists = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"Ta的发文（%d）",self.expertInfoModel.postCount],[NSString stringWithFormat:@"Ta的回帖（%d）",self.expertInfoModel.replyCount], nil];
    
    [self reloadData];
}

#pragma mark ---- 请求圈子数据 ----
- (void)queryCircleInfo
{
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:kWarning12];
        return;
    }
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = StrFromObj(QWGLOBALMANAGER.configure.userToken);
    setting[@"expertId"] = StrFromObj(self.posterId);
    [Circle TeamExpertInfoWithParams:setting success:^(id obj) {
        
        CircleMaserlistModel *model = [CircleMaserlistModel parse:obj];
        if ([model.apiStatus integerValue] == 0) {
            if (model.silencedFlag) {
                 [self showInfoView:@"该专家被禁言" image:@"ic_img_cry"];
            }else{
                self.expertInfoModel = model;
                if (QWGLOBALMANAGER.weChatBusiness){
                    self.onlineView.hidden = NO;
                    self.privateChatBtn.hidden = NO;
                    self.privateChatBtn.enabled = YES;
                }else{
                    self.onlineView.hidden = YES;
                    self.privateChatBtn.hidden = YES;
                    self.privateChatBtn.enabled = NO;
                }

                //设置headerView
                [self setUpTableHeaderView];
                
                if (!isHeaderRefresh) {
                    [self setupSliderViewControllers];
                }
            }

        }else{
            [SVProgressHUD showErrorWithStatus:model.apiMessage];
        }
        
    } failure:^(HttpException *e) {
        if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
            [self showInfoView:kWarning12 image:@"网络信号icon"];
        }else
        {
            if(e.errorCode!=-999){
                if(e.errorCode == -1001){
                    [self showInfoView:kWarning215N26 image:@"ic_img_fail"];
                }else{
                    [self showInfoView:kWarning39 image:@"ic_img_fail"];
                }
            }
        }
    }];
}

- (void)viewInfoClickAction:(id)sender
{
    if (QWGLOBALMANAGER.currentNetWork != kNotReachable) {
        [self removeInfoView];
        [self queryCircleInfo];
    }
}

#pragma mark ---- 设置headerView ----
- (void)setUpTableHeaderView
{
    self.tableHeaderView.backgroundColor = [UIColor clearColor];
    
    self.headerIcon.layer.cornerRadius = 58;
    self.headerIcon.layer.masksToBounds = YES;
    
    self.attentionLabel.layer.cornerRadius = 4.0;
    self.attentionLabel.layer.masksToBounds = YES;
    
    self.cancelAttentionLabel.layer.cornerRadius = 4.0;
    self.cancelAttentionLabel.layer.masksToBounds = YES;
    
    self.expertBrandLabel.layer.cornerRadius = 4.0;
    self.expertBrandLabel.layer.masksToBounds = YES;
    self.expertBrandLabel.backgroundColor = RGBAHex(qwColor3, 0.5);
    
    self.statusLabel.layer.masksToBounds = YES;
    self.statusLabel.layer.cornerRadius = 8.0f;
    
    self.onLineStatu_layout_left.constant = APP_W/2+15;
    
    CircleMaserlistModel *model = (CircleMaserlistModel *)self.expertInfoModel;
    
    //头像
    [self.headerIcon setImageWithURL:[NSURL URLWithString:model.headImageUrl] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
    
    //在线离线状态
    if(model.onlineFlag){
        self.statusLabel.text = @"在线";
        self.statusLabel.backgroundColor = RGBHex(qwColor1);
    }else{
        self.statusLabel.text = @"离线";
        self.statusLabel.backgroundColor = RGBHex(qwColor9);
    }
    
    //姓名
    NSString *name = model.nickName;
    NSString *logoName = @"";
    if (model.userType == 3) { //药师
        logoName = @"药师";
    }else if (model.userType == 4){ //营养师
        logoName = @"营养师";
    }
    NSString *str = [NSString stringWithFormat:@"%@ %@",name,logoName];
    NSMutableAttributedString *nameAttributedStr = [[NSMutableAttributedString alloc]initWithString:str];
    NSRange range = [[nameAttributedStr string]rangeOfString:logoName];
    [nameAttributedStr addAttribute:NSFontAttributeName
                              value:fontSystem(kFontS4)
                              range:range];
    [nameAttributedStr addAttribute:NSForegroundColorAttributeName
                              value:RGBHex(qwColor3)
                              range:range];
    self.expertName.attributedText = nameAttributedStr;
    
    //药房品牌
    if (model.userType == 3 || model.userType == 4)
    {
        NSString *store;
        if (model.userType == 3)
        {
            //药师 标识显示药师所属商家
            if (model.groupName && ![model.groupName isEqualToString:@""]) {
                store = model.groupName;
            }else{
                store = @"";
            }
            
        }else if (model.userType == 4)
        {
            store = @"";
        }
        
        if (StrIsEmpty(store))
        {
            self.expertBrandLabel.hidden = YES;
        }else
        {
            self.expertBrandLabel.hidden = NO;
            self.expertBrandLabel.layer.cornerRadius = 4.0;
            self.expertBrandLabel.layer.masksToBounds = YES;
            self.expertBrandLabel.text = store;
            CGSize brandSize = [store sizeWithFont:fontSystem(12) constrainedToSize:CGSizeMake(APP_W-20, CGFLOAT_MAX)];
            self.expertBrand_layout_width.constant = brandSize.width+7;
        }
    }
    
    //粉丝
    NSString *str1 = [NSString stringWithFormat:@"粉丝 %d",model.attnCount];
    NSMutableAttributedString *AttributedStr1 = [[NSMutableAttributedString alloc]initWithString:str1];
    NSRange range1 = [[AttributedStr1 string]rangeOfString:@"粉丝"];
    [AttributedStr1 addAttribute:NSFontAttributeName
                           value:fontSystem(kFontS4)
                           range:range1];
    [AttributedStr1 addAttribute:NSForegroundColorAttributeName
                           value:RGBHex(qwColor8)
                           range:range1];
    self.funsLabel.attributedText = AttributedStr1;
    
    //鲜花
    NSString *str2 = [NSString stringWithFormat:@"鲜花 %d",model.upVoteCount];
    NSMutableAttributedString *AttributedStr2 = [[NSMutableAttributedString alloc]initWithString:str2];
    NSRange range2 = [[AttributedStr2 string]rangeOfString:@"鲜花"];
    [AttributedStr2 addAttribute:NSFontAttributeName
                           value:fontSystem(kFontS4)
                           range:range2];
    [AttributedStr2 addAttribute:NSForegroundColorAttributeName
                           value:RGBHex(qwColor8)
                           range:range2];
    self.flowerLabel.attributedText = AttributedStr2;
    
    //擅长领域
    
    NSString *goodFieldStr = @"";
    if (model.expertise && ![model.expertise isEqualToString:@""])
    {
        NSArray *arr = [model.expertise componentsSeparatedByString:SeparateStr];
        if (arr.count == 0)
        {
            goodFieldStr = @"";
            
        }else if (arr.count == 1)
        {
            goodFieldStr = [NSString stringWithFormat:@"%@",arr[0]];
            
        }else if (arr.count == 2)
        {
            goodFieldStr = [NSString stringWithFormat:@"%@/%@",arr[0],arr[1]];
            
        }else if (arr.count >= 3)
        {
            goodFieldStr = [NSString stringWithFormat:@"%@/%@/%@",arr[0],arr[1],arr[2]];
        }
    }else
    {
        goodFieldStr = @"";
    }
    
    self.goodFieldLabel.text = [NSString stringWithFormat:@"擅长 : %@",goodFieldStr];
    
    //关注
    if (model.isAttnFlag)
    {
        //关注 显示取消关注
        self.attentionLabel.hidden = YES;
        self.cancelAttentionLabel.hidden = NO;
    }else
    {
        //未关注 显示关注
        self.attentionLabel.hidden = NO;
        self.cancelAttentionLabel.hidden = YES;
    }
    
    
    NSString *store;
    if (model.userType == 3)
    {
        //药师 标识显示药师所属商家
        if (model.groupName && ![model.groupName isEqualToString:@""]) {
            store = model.groupName;
        }else{
            store = @"";
        }
        
    }else if (model.userType == 4)
    {
        store = @"";
    }
    
    CGRect frame = self.tableHeaderView.frame;
    if (StrIsEmpty(store))
    {
        frame.size.height = 325-16-20;
    }else
    {
        frame.size.height = 325;
    }
    
    self.tableHeaderView.frame = CGRectMake(0, 0, APP_W, frame.size.height);
    
}

#pragma mark ---- 关注 ----
- (IBAction)payAttentionExpertAction:(id)sender
{
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:kWarning12];
        return;
    }
    
    if(!QWGLOBALMANAGER.loginStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        return;
    }
    
    if (QWGLOBALMANAGER.configure.flagSilenced) {
        [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
        return;
    }
    
    NSString *type;
    if (self.expertInfoModel.isAttnFlag) {
        type = @"1";
    }else{
        type = @"0";
    }
    
    if (self.expertType == PosterType_YaoShi) {
        [QWGLOBALMANAGER statisticsEventId:@"x_yszl_gz" withLable:@"药师专栏-关注" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"类型":self.expertInfoModel.isAttnFlag ? @"取消关注":@"关注", @"药师名字":StrDFString(self.nickName, @""),@"点击时间":[QWGLOBALMANAGER timeStrNow]}]];
    }
    else if (self.expertType == PosterType_YingYangShi)
    {
        [QWGLOBALMANAGER statisticsEventId:@"x_yyszl_gz" withLable:@"营养师专栏-专注" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"类型":self.expertInfoModel.isAttnFlag ? @"取消关注":@"关注", @"营养师名字":StrDFString(self.nickName, @"")}]];
    }
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"objId"] = StrFromObj(self.posterId);
    setting[@"token"] = StrFromObj(QWGLOBALMANAGER.configure.userToken);
    setting[@"reqBizType"] = type;
    [Circle teamAttentionMbrWithParams:setting success:^(id obj) {
        if ([obj[@"apiStatus"] integerValue] == 0) {
            
            if ([obj[@"rewardScore"] integerValue]> 0) {
                [QWProgressHUD showSuccessWithStatus:@"关注成功" hintString:[NSString stringWithFormat:@"+%ld", [obj[@"rewardScore"] integerValue]] duration:DURATION_CREDITREWORD];
                
            }else{
                [SVProgressHUD showSuccessWithStatus:obj[@"apiMessage"]];
                self.expertInfoModel.isAttnFlag = !self.expertInfoModel.isAttnFlag;
                [self setUpTableHeaderView];
            }

        }else{
            [SVProgressHUD showErrorWithStatus:obj[@"apiMessage"]];
        }
    } failure:^(HttpException *e) {
        
    }];
}

#pragma mark ---- 私聊 ----
- (IBAction)privateChatAction:(id)sender
{
    NSMutableDictionary* paramDic = [NSMutableDictionary dictionaryWithDictionary:@{@"专家姓名":self.nickName,@"点击时间":[QWGLOBALMANAGER timeStrNow]}];
    if (self.expertType == PosterType_YaoShi) {
        paramDic[@"专家类型"] = @"药师";
    }
    else if (self.expertType == PosterType_YingYangShi)
    {
        paramDic[@"专家类型"] = @"营养师";
    }
    [QWGLOBALMANAGER statisticsEventId:@"x_zjym_zx" withLable:@"咨询" withParams:paramDic];

    [QWGLOBALMANAGER statisticsEventId:@"专栏_私聊按键" withLable:@"圈子" withParams:nil];
    
    if (QWGLOBALMANAGER.configure.flagSilenced) {
        [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
        return;
    }

    if (!QWGLOBALMANAGER.loginStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        loginViewController.loginSuccessBlock = ^{
            PrivateChatViewController* privateChatVC = [[UIStoryboard storyboardWithName:@"PrivateChatViewController" bundle:nil] instantiateViewControllerWithIdentifier:@"PrivateChatViewController"];
            privateChatVC.hidesBottomBarWhenPushed = YES;
            privateChatVC.userId = self.posterId;
            privateChatVC.nickName = self.expertInfoModel.nickName;
            privateChatVC.fromList = NO;
            privateChatVC.expertType = self.expertType;
            [self.navigationController pushViewController:privateChatVC animated:YES];
        };
        [self presentViewController:navgationController animated:YES completion:NULL];
        return;
    }
    PrivateChatViewController* privateChatVC = [[UIStoryboard storyboardWithName:@"PrivateChatViewController" bundle:nil] instantiateViewControllerWithIdentifier:@"PrivateChatViewController"];
    privateChatVC.userId = self.posterId;
    privateChatVC.fromList = NO;
    privateChatVC.nickName = self.expertInfoModel.nickName;
    [self.navigationController pushViewController:privateChatVC animated:YES];
}

#pragma mark ---- 刷新帖子列表 ----
- (void)refreshPostListWithTabIndex:(int)index
{
    self.tableView.footerNoDataText = @"已显示全部内容";
    [self.tableView.footer setDiseaseCanLoadMore:YES];
    currentViewController = self.viewControllerssss[index];
    currentViewController.expertId = self.posterId;
    [currentViewController currentViewSelected:^(CGFloat height) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
