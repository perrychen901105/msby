//
//  CircleDetailViewController.m
//  wenYao-store
//
//  Created by Yang Yuexia on 15/12/31.
//  Copyright © 2015年 carret. All rights reserved.
//

#import "CircleDetailViewController.h"
#import "NSString+WPAttributedMarkup.h"
#import "CircleDetailCell.h"
#import "LookMasterViewController.h"
#import "CircleDetailNextViewController.h"
#import "CircleModel.h"
#import "Circle.h"
#import "SendPostViewController.h"
#import "ForumModel.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"
#import "QWProgressHUD.h"
#import "GUITabScrollView.h"
#import "EnterExpertViewController.h"
#import "PostSearchViewController.h"

@interface CircleDetailViewController ()<UITableViewDataSource,UITableViewDelegate,GUITabPagerDataSource, GUITabPagerDelegate>
{
    CGFloat rowHeight;  //tableview cell高度
    int tabIndex;         //选中的tab索引
    CircleDetailNextViewController *currentViewController;
}

@property (strong, nonatomic) IBOutlet UIView *storeHeaderView;
@property (weak, nonatomic) IBOutlet UIImageView *circleIcon;                      //圈子icon
@property (weak, nonatomic) IBOutlet UILabel *circleName;                          //圈子名称
@property (weak, nonatomic) IBOutlet UILabel *attentionNum;                        //帖子关注数
@property (weak, nonatomic) IBOutlet UILabel *isMasterLabel;                       //我是圈主
@property (weak, nonatomic) IBOutlet UILabel *attentionLabel;                      //关注
@property (weak, nonatomic) IBOutlet UILabel *cancelAttentionLabel;                //取消关注
@property (weak, nonatomic) IBOutlet UIButton *attentionButton;                    //关注按钮
@property (weak, nonatomic) IBOutlet UILabel *circleDesc;                          //圈子简介
@property (weak, nonatomic) IBOutlet UIImageView *circleDescTransformImage;        //简介翻转图片
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleDesc_layout_height; //圈子简介高度约束

@property (strong, nonatomic) IBOutlet UIView *imagesContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *circleMasterOneImage;
@property (weak, nonatomic) IBOutlet UIImageView *circleMasterTwoImage;
@property (weak, nonatomic) IBOutlet UIImageView *circleMasterThreeImage;
@property (weak, nonatomic) IBOutlet UIImageView *circleMasterFourImage;
@property (weak, nonatomic) IBOutlet UIImageView *circleMasterFiveImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *expertImageTwo_layout_space;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *expertImageThree_layout_space;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *expertImageFour_layout_space;
@property (weak, nonatomic) IBOutlet UIView *noCircleMasterTipView;
@property (weak, nonatomic) IBOutlet UIButton *postCircleButton;

@property (strong, nonatomic) IBOutlet UIView *commonHeaderView;
@property (weak, nonatomic) IBOutlet UIImageView *storeCircleIcon;                      //圈子icon
@property (weak, nonatomic) IBOutlet UILabel *storeCircleName;                          //圈子名称
@property (weak, nonatomic) IBOutlet UILabel *storeAttentionNum;                        //帖子关注数
@property (weak, nonatomic) IBOutlet UILabel *storeIsMasterLabel;                       //我是圈主
@property (weak, nonatomic) IBOutlet UILabel *storeAttentionLabel;                      //关注
@property (weak, nonatomic) IBOutlet UILabel *storeCancelAttentionLabel;                //取消关注
@property (weak, nonatomic) IBOutlet UIButton *StoreAttentionButton;                    //关注按钮
@property (weak, nonatomic) IBOutlet UIImageView *storeCircleMasterOneImage;
@property (weak, nonatomic) IBOutlet UIImageView *storeCircleMasterTwoImage;
@property (weak, nonatomic) IBOutlet UIImageView *storeCircleMasterThreeImage;
@property (weak, nonatomic) IBOutlet UIImageView *storeCircleMasterFourImage;
@property (weak, nonatomic) IBOutlet UIImageView *storeCircleMasterFiveImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeExpertImageTwo_layout_space;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeExpertImageThree_layout_space;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeExpertImageFour_layout_space;
@property (weak, nonatomic) IBOutlet UIView *storeNoCircleMasterTipView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *expertBg_layout_left;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *expertBg_layout_right;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterLogo_layout_left;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeExpertBg_layout_right;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeExpertBg_layout_left;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeExpertLogo_layout_left;

@property (assign, nonatomic) BOOL isSpreadDesc;                                   //圈子简介是否展开
@property (strong, nonatomic) NSMutableArray * sliderTabLists;
@property (strong, nonatomic) CircleListModel *circleDetailModel;                  //圈子详情model
@property (strong, nonatomic) NSMutableArray *viewControllerssss;


//看圈子简介
- (IBAction)headerSpreadAction:(id)sender;
//查看圈主
- (IBAction)lookCircleMasterAction:(id)sender;
//发帖
- (IBAction)postTopicAction:(id)sender;
//关注
- (IBAction)attentionAction:(id)sender;

@end

@implementation CircleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view bringSubviewToFront:self.postCircleButton];
    
    self.viewControllerssss = [NSMutableArray array];
    self.sliderTabLists = [NSMutableArray arrayWithObjects:@"全部",@"专家帖",@"热门帖",@"用户帖", nil];
    self.circleDetailModel = [CircleListModel new];
    self.isSpreadDesc = NO;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    [self setDataSource:self];
    [self setDelegate:self];
    
    //获取圈子数据
    [self queryCircleInfo];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"ic_nav_magnifier-1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(searchCircleAction)];
    


    //下拉刷新
    __weak CircleDetailViewController *weakSelf = self;
    [self enableSimpleRefresh:self.tableView block:^(SRRefreshView *sender) {
        if (QWGLOBALMANAGER.currentNetWork != kNotReachable) {
            HttpClientMgr.progressEnabled = NO;
            [self queryCircleInfo];
            [self selectTabbarIndex:tabIndex];
            [weakSelf refreshPostListWithIndex:tabIndex];
        }else{
            [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试！" duration:0.8];
        }
    }];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMaterImageContier:)];
    [self.imagesContainerView addGestureRecognizer:tapGesture];
}

- (void)tapMaterImageContier:(UITapGestureRecognizer*)tapGestuer
{
    if (self.circleDetailModel.expertUrlList.count > 0)
    {
        BOOL haveClickMoreImage = NO;
        if (self.circleDetailModel.expertUrlList.count > 5) {
            CGPoint point = [tapGestuer locationInView:tapGestuer.view];
            if (CGRectContainsPoint(self.circleMasterFiveImage.frame, point)) {
                haveClickMoreImage = YES;
                if (self.circleDetailModel.flagGroup)
                {
                    [QWGLOBALMANAGER statisticsEventId:@"商家圈_更多按键" withLable:@"圈子" withParams:nil];
                }
                else
                {
                    [QWGLOBALMANAGER statisticsEventId:@"公共圈_更多按键" withLable:@"圈子" withParams:nil];
                }
            }
        }
        
        if (!haveClickMoreImage) {
            if (self.circleDetailModel.flagGroup)
            {
                [QWGLOBALMANAGER statisticsEventId:@"商家圈_入驻专家头像" withLable:@"圈子" withParams:nil];
            }
            else
            {
                [QWGLOBALMANAGER statisticsEventId:@"公共圈_入驻专家头像" withLable:@"圈子" withParams:nil];
            }
        }
    }
    
    [self lookCircleMasterAction:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (CIRCLE_DETAIL_BYSEND)
    {
        //通过发帖返回圈子列表  在看帖列表里加入 新发布的帖子 刷新看帖tab
        [QWUserDefault setObject:@"KO" key:@"sendPostToCircleDetail"];
        [self queryCircleInfo];
        [self selectTabbarIndex:0];
        [self refreshPostListWithIndex:0];
    }
    
    if (DELETE_POSTTOPIC_SUCCESS)
    {
        //从圈子进入帖子详情，删除该帖之后，返回圈子详情，刷新当前tab
        [QWUserDefault setObject:@"KO" key:@"deletePostTopicSuccess"];
        [self queryCircleInfo];
        [self selectTabbarIndex:tabIndex];
        [self refreshPostListWithIndex:tabIndex];
    }
}


- (void)popVCAction:(id)sender
{
    [QWGLOBALMANAGER statisticsEventId:@"x_qzxq_fh" withLable:@"圈子详情-返回" withParams:nil];
    [super popVCAction:sender];
}

- (NSInteger)numberOfViewControllers {
    return self.sliderTabLists.count;
}

- (UIViewController<GUITabViewControllerObject> *)viewControllerForIndex:(NSInteger)index
{
    CircleDetailNextViewController *vc = self.viewControllerssss[index];
    vc.delegate = self;
    
    
    CGRect rect = self.view.bounds;
    rect.size.height -= 44.f;
    vc.view.frame = rect;
    return vc;
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
    return [[GUITabScrollView alloc] initWithFrame:frame tabTitles:[arrM copy] tabBarHeight:44.0f tabIndicatorHeight:2.0f seperatorHeight:0.5f tabIndicatorColor:RGBHex(qwColor1) seperatorColor:[UIColor lightGrayColor] backgroundColor:[UIColor whiteColor] selectedTabIndex:0 centerSepColor:[UIColor clearColor] scrollable:NO];
}

- (UIView *)tabPagerHeaderView
{
    if (self.circleDetailModel.flagGroup)
    {
        return self.storeHeaderView;
    }else
    {
        return self.commonHeaderView;
    }
}

- (NSString *)titleForTabAtIndex:(NSInteger)index
{
    return self.sliderTabLists[index];
}

/* 代理 */
#pragma mark - Tab Pager Delegate

- (void)tabPager:(GUITabPagerViewController *)tabPager willTransitionToTabAtIndex:(NSInteger)index
{
    tabIndex = index;
    [self refreshPostListWithIndex:tabIndex];
    
    NSString* eventId = @"x_qzxq_kt";
    switch (index) {
        case 0:
            eventId = @"x_qzxq_qu";
            break;
        case 1:
            eventId = @"x_qzxq_zj";
            break;
        case 2:
            eventId = @"x_qzxq_rm";
        case 3:
            eventId = @"x_qzxq_kt";
    }
    [QWGLOBALMANAGER statisticsEventId:eventId withLable:@"热议" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl),@"点击时间":[QWGLOBALMANAGER timeStrNow],@"圈子名":StrDFString(self.circleDetailModel.teamName, @"圈子名")}]];
    
    
    if (index == 0)
    {
        if (self.circleDetailModel.flagGroup){
            [QWGLOBALMANAGER statisticsEventId:@"商家圈_全部_出现" withLable:@"圈子" withParams:nil];
        }else{
            [QWGLOBALMANAGER statisticsEventId:@"公共圈_全部_出现" withLable:@"圈子" withParams:nil];
        }
    }else if (index == 1)
    {
        if (self.circleDetailModel.flagGroup){
            [QWGLOBALMANAGER statisticsEventId:@"商家圈_专家帖_出现" withLable:@"圈子" withParams:nil];
        }else{
            [QWGLOBALMANAGER statisticsEventId:@"公共圈_专家帖_出现" withLable:@"圈子" withParams:nil];
        }
    }else if (index == 2)
    {
        if (self.circleDetailModel.flagGroup){
            [QWGLOBALMANAGER statisticsEventId:@"商家圈_热门帖_出现" withLable:@"圈子" withParams:nil];
        }else{
            [QWGLOBALMANAGER statisticsEventId:@"公共圈_热门帖_出现" withLable:@"圈子" withParams:nil];
        }
    }else if (index == 3)
    {
        if (self.circleDetailModel.flagGroup){
            [QWGLOBALMANAGER statisticsEventId:@"商家圈_粉丝帖_出现" withLable:@"圈子" withParams:nil];
        }else{
            [QWGLOBALMANAGER statisticsEventId:@"公共圈_粉丝帖_出现" withLable:@"圈子" withParams:nil];
        }
    }
}

- (void)tabPager:(GUITabPagerViewController *)tabPager didTransitionToTabAtIndex:(NSInteger)index
{
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

#pragma mark ---- 设置界面数组 ----
- (void)setupSliderViewControllers
{
    //请求参数类型：  1看帖  2热门  3专家  4咨询
    
    CircleDetailNextViewController *all = [[UIStoryboard storyboardWithName:@"Circle" bundle:nil] instantiateViewControllerWithIdentifier:@"CircleDetailNextViewController"];
    all.navigationController = self.navigationController;
    all.flagGroup = self.circleDetailModel.flagGroup;
    all.title = @"全部";
    all.requestType = @"1";
    all.jumpType = @"1";
    all.sliderTabIndex = @"1";
    
    
    CircleDetailNextViewController *expert = [[UIStoryboard storyboardWithName:@"Circle" bundle:nil] instantiateViewControllerWithIdentifier:@"CircleDetailNextViewController"];
    expert.navigationController = self.navigationController;
    expert.flagGroup = self.circleDetailModel.flagGroup;
    expert.title = @"专家帖";
    expert.requestType = @"3";
    expert.jumpType = @"1";
    expert.sliderTabIndex = @"2";
    
    
    CircleDetailNextViewController *hot = [[UIStoryboard storyboardWithName:@"Circle" bundle:nil] instantiateViewControllerWithIdentifier:@"CircleDetailNextViewController"];
    hot.navigationController = self.navigationController;
    hot.flagGroup = self.circleDetailModel.flagGroup;
    hot.title = @"热门帖";
    hot.requestType = @"2";
    hot.jumpType = @"1";
    hot.sliderTabIndex = @"3";
    
    
    CircleDetailNextViewController *other = [[UIStoryboard storyboardWithName:@"Circle" bundle:nil] instantiateViewControllerWithIdentifier:@"CircleDetailNextViewController"];
    other.navigationController = self.navigationController;
    other.flagGroup = self.circleDetailModel.flagGroup;
    other.title = @"用户帖";
    other.requestType = @"4";
    other.jumpType = @"1";
    other.sliderTabIndex = @"4";
    
    
    currentViewController = all;
    [self.viewControllerssss addObject:all];
    [self.viewControllerssss addObject:expert];
    [self.viewControllerssss addObject:hot];
    [self.viewControllerssss addObject:other];
    
}

#pragma mark ---- 请求圈子数据 ----
- (void)queryCircleInfo
{
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:kWarning12];
        return;
    }
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"teamId"] = StrFromObj(self.teamId);
    setting[@"token"] = StrFromObj(QWGLOBALMANAGER.configure.userToken);
    [Circle TeamGetTeamDetailsInfoWithParams:setting success:^(id obj) {
        
        self.circleDetailModel = [CircleListModel parse:obj];
        if ([self.circleDetailModel.apiStatus integerValue] == 0) {
            
            if (StrIsEmpty(self.title)){
                self.title = [NSString stringWithFormat:@"%@圈",self.circleDetailModel.teamName];
            }
            
            [self setUpTableHeaderView];
            [self setupSliderViewControllers];
            [self reloadData];
            [self refreshPostListWithIndex:0];
            
        }else{
            [SVProgressHUD showErrorWithStatus:self.circleDetailModel.apiMessage];
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

#pragma mark ---- 无数据点击事件 ----
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
    if (self.circleDetailModel.flagGroup)
    {
        [self setUpStoreHederView];
    }else
    {
        [self setUpCommonHederView];
    }
}

#pragma mark ----- 商家圈 ----
- (void)setUpStoreHederView
{
    //头像
    self.storeCircleIcon.layer.borderWidth = 0.5;
    self.storeCircleIcon.layer.borderColor = RGBHex(qwColor20).CGColor;
    self.storeCircleIcon.layer.cornerRadius = 2.0;
    self.storeCircleIcon.layer.masksToBounds = YES;
    [self.storeCircleIcon setImageWithURL:[NSURL URLWithString:self.circleDetailModel.teamLogo] placeholderImage:[UIImage imageNamed:@"bg_tx_circletouxiang"]];
    
    //圈子名称
    self.storeCircleName.text = self.circleDetailModel.teamName;;
    
    //圈子关注数
    self.storeAttentionNum.text = [NSString stringWithFormat:@"%d人关注    %d个帖子",self.circleDetailModel.attnCount,self.circleDetailModel.postCount];
    
    //关注按钮
    if (self.circleDetailModel.flagMaster)
    {
        //我是圈主
        self.storeAttentionLabel.hidden = YES;
        self.storeCancelAttentionLabel.hidden = YES;
        self.storeIsMasterLabel.hidden = NO;
        self.storeIsMasterLabel.layer.cornerRadius = 4.0;
        self.storeIsMasterLabel.layer.masksToBounds = YES;
        self.StoreAttentionButton.enabled = NO;
    }else
    {
        if (self.circleDetailModel.flagAttn)
        {
            //已经关注，显示取消关注
            self.storeCancelAttentionLabel.layer.cornerRadius = 4.0;
            self.storeCancelAttentionLabel.layer.masksToBounds = YES;
            self.storeCancelAttentionLabel.hidden = NO;
            self.storeAttentionLabel.hidden = YES;
            self.storeIsMasterLabel.hidden = YES;
        }else
        {
            //未关注，显示关注
            self.storeAttentionLabel.layer.cornerRadius = 4.0;
            self.storeAttentionLabel.layer.masksToBounds = YES;
            self.storeAttentionLabel.hidden = NO;
            self.storeCancelAttentionLabel.hidden = YES;
            self.storeIsMasterLabel.hidden = YES;
        }
    }
    
    //入驻专家
    self.storeCircleMasterOneImage.layer.cornerRadius = 23.5;
    self.storeCircleMasterOneImage.layer.masksToBounds = YES;
    self.storeCircleMasterTwoImage.layer.cornerRadius = 23.5;
    self.storeCircleMasterTwoImage.layer.masksToBounds = YES;
    self.storeCircleMasterThreeImage.layer.cornerRadius = 23.5;
    self.storeCircleMasterThreeImage.layer.masksToBounds = YES;
    self.storeCircleMasterFourImage.layer.cornerRadius = 23.5;
    self.storeCircleMasterFourImage.layer.masksToBounds = YES;
    self.storeCircleMasterFiveImage.layer.cornerRadius = 23.5;
    self.storeCircleMasterFiveImage.layer.masksToBounds = YES;
    
    
    
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
        self.storeExpertImageTwo_layout_space.constant = (APP_W-299)/4;
        self.storeExpertImageThree_layout_space.constant = (APP_W-299)/4;
        self.storeExpertImageFour_layout_space.constant = (APP_W-299)/4;
        self.storeExpertBg_layout_left.constant = 4;
        self.storeExpertBg_layout_right.constant = 10;
        self.storeExpertLogo_layout_left.constant = 10;
    }else
    {
        self.storeExpertImageTwo_layout_space.constant = (APP_W-319)/4;
        self.storeExpertImageThree_layout_space.constant = (APP_W-319)/4;
        self.storeExpertImageFour_layout_space.constant = (APP_W-319)/4;
        self.storeExpertBg_layout_left.constant = 14;
        self.storeExpertBg_layout_right.constant = 15;
        self.storeExpertLogo_layout_left.constant = 15;
    }
    
    
    NSArray *arr = self.circleDetailModel.expertUrlList;
    
    if (arr)
    {
        if (arr.count == 0)
        {
            self.storeCircleMasterOneImage.hidden = YES;
            self.storeCircleMasterTwoImage.hidden = YES;
            self.storeCircleMasterThreeImage.hidden = YES;
            self.storeCircleMasterFourImage.hidden = YES;
            self.storeCircleMasterFiveImage.hidden = YES;
            self.storeNoCircleMasterTipView.hidden = NO;
            
        }else if (arr.count == 1)
        {
            self.storeCircleMasterOneImage.hidden = NO;
            [self.storeCircleMasterOneImage setImageWithURL:[NSURL URLWithString:arr[0]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            self.storeCircleMasterTwoImage.hidden = YES;
            self.storeCircleMasterThreeImage.hidden = YES;
            self.storeCircleMasterFourImage.hidden = YES;
            self.storeCircleMasterFiveImage.hidden = YES;
            self.storeNoCircleMasterTipView.hidden = YES;
            
        }else if (arr.count == 2)
        {
            
            self.storeCircleMasterOneImage.hidden = NO;
            self.storeCircleMasterTwoImage.hidden = NO;
            [self.storeCircleMasterOneImage setImageWithURL:[NSURL URLWithString:arr[0]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.storeCircleMasterTwoImage setImageWithURL:[NSURL URLWithString:arr[1]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            self.storeCircleMasterThreeImage.hidden = YES;
            self.storeCircleMasterFourImage.hidden = YES;
            self.storeCircleMasterFiveImage.hidden = YES;
            self.storeNoCircleMasterTipView.hidden = YES;
            
        }else if (arr.count == 3)
        {
            self.storeCircleMasterOneImage.hidden = NO;
            self.storeCircleMasterTwoImage.hidden = NO;
            self.storeCircleMasterThreeImage.hidden = NO;
            [self.storeCircleMasterOneImage setImageWithURL:[NSURL URLWithString:arr[0]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.storeCircleMasterTwoImage setImageWithURL:[NSURL URLWithString:arr[1]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.storeCircleMasterThreeImage setImageWithURL:[NSURL URLWithString:arr[2]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            self.storeCircleMasterFourImage.hidden = YES;
            self.storeCircleMasterFiveImage.hidden = YES;
            self.storeNoCircleMasterTipView.hidden = YES;
            
        }else if (arr.count == 4)
        {
            self.storeCircleMasterOneImage.hidden = NO;
            self.storeCircleMasterTwoImage.hidden = NO;
            self.storeCircleMasterThreeImage.hidden = NO;
            self.storeCircleMasterFourImage.hidden = NO;
            [self.storeCircleMasterOneImage setImageWithURL:[NSURL URLWithString:arr[0]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.storeCircleMasterTwoImage setImageWithURL:[NSURL URLWithString:arr[1]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.storeCircleMasterThreeImage setImageWithURL:[NSURL URLWithString:arr[2]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.storeCircleMasterFourImage setImageWithURL:[NSURL URLWithString:arr[3]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            self.storeCircleMasterFiveImage.hidden = YES;
            self.storeNoCircleMasterTipView.hidden = YES;
            
        }else if (arr.count == 5)
        {
            self.storeCircleMasterOneImage.hidden = NO;
            self.storeCircleMasterTwoImage.hidden = NO;
            self.storeCircleMasterThreeImage.hidden = NO;
            self.storeCircleMasterFourImage.hidden = NO;
            self.storeCircleMasterFiveImage.hidden = NO;
            
            [self.storeCircleMasterOneImage setImageWithURL:[NSURL URLWithString:arr[0]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.storeCircleMasterTwoImage setImageWithURL:[NSURL URLWithString:arr[1]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.storeCircleMasterThreeImage setImageWithURL:[NSURL URLWithString:arr[2]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.storeCircleMasterFourImage setImageWithURL:[NSURL URLWithString:arr[3]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.storeCircleMasterFiveImage setImageWithURL:[NSURL URLWithString:arr[4]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            self.storeNoCircleMasterTipView.hidden = YES;
            
        }else if (arr.count > 5)
        {
            self.storeCircleMasterOneImage.hidden = NO;
            self.storeCircleMasterTwoImage.hidden = NO;
            self.storeCircleMasterThreeImage.hidden = NO;
            self.storeCircleMasterFourImage.hidden = NO;
            self.storeCircleMasterFiveImage.hidden = NO;
            [self.storeCircleMasterOneImage setImageWithURL:[NSURL URLWithString:arr[0]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.storeCircleMasterTwoImage setImageWithURL:[NSURL URLWithString:arr[1]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.storeCircleMasterThreeImage setImageWithURL:[NSURL URLWithString:arr[2]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.storeCircleMasterFourImage setImageWithURL:[NSURL URLWithString:arr[3]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.storeCircleMasterFiveImage setImage:[UIImage imageNamed:@"ic_quqnzixq_more"]];
            self.storeNoCircleMasterTipView.hidden = YES;
        }
    }
}

#pragma mark ----- 公共圈 ----
- (void)setUpCommonHederView
{
    //头像
    self.circleIcon.layer.borderWidth = 0.5;
    self.circleIcon.layer.borderColor = RGBHex(qwColor20).CGColor;
    self.circleIcon.layer.cornerRadius = 2.0;
    self.circleIcon.layer.masksToBounds = YES;
    [self.circleIcon setImageWithURL:[NSURL URLWithString:self.circleDetailModel.teamLogo] placeholderImage:[UIImage imageNamed:@"bg_tx_circletouxiang"]];
    
    //圈子名称
    self.circleName.text = self.circleDetailModel.teamName;;
    
    //圈子关注数
    self.attentionNum.text = [NSString stringWithFormat:@"%d人关注    %d个帖子",self.circleDetailModel.attnCount,self.circleDetailModel.postCount];
    
    //关注按钮
    if (self.circleDetailModel.flagMaster)
    {
        //我是圈主
        self.attentionLabel.hidden = YES;
        self.cancelAttentionLabel.hidden = YES;
        self.isMasterLabel.hidden = NO;
        self.isMasterLabel.layer.cornerRadius = 4.0;
        self.isMasterLabel.layer.masksToBounds = YES;
        self.attentionButton.enabled = NO;
    }else
    {
        if (self.circleDetailModel.flagAttn)
        {
            //已经关注，显示取消关注
            self.cancelAttentionLabel.layer.cornerRadius = 4.0;
            self.cancelAttentionLabel.layer.masksToBounds = YES;
            self.cancelAttentionLabel.hidden = NO;
            self.attentionLabel.hidden = YES;
            self.isMasterLabel.hidden = YES;
        }else
        {
            //未关注，显示关注
            self.attentionLabel.layer.cornerRadius = 4.0;
            self.attentionLabel.layer.masksToBounds = YES;
            self.attentionLabel.hidden = NO;
            self.cancelAttentionLabel.hidden = YES;
            self.isMasterLabel.hidden = YES;
        }
    }
    
    //圈子简介
    if (!self.circleDetailModel.flagGroup)
    {
        if (self.circleDetailModel.teamDesc.length > 0) {
            if(!self.isSpreadDesc)
            {
                //图片旋转
                self.circleDescTransformImage.transform=CGAffineTransformMakeRotation(0);
                
                //简介hidden
                self.circleDesc.hidden = YES;
                self.circleDesc_layout_height.constant = 1;
                
                self.commonHeaderView.frame = CGRectMake(0, 0, APP_W, 200);
                self.tableView.tableHeaderView = self.commonHeaderView;
                
            }else
            {
                //图片旋转
                self.circleDescTransformImage.transform=CGAffineTransformMakeRotation(M_PI);
                
                //设置行间距 赋值
                NSString *desc = self.circleDetailModel.teamDesc;
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineSpacing = 4;
                paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
                NSDictionary *attributes = @{NSFontAttributeName:fontSystem(14),NSParagraphStyleAttributeName:paragraphStyle};
                self.circleDesc.attributedText = [[NSAttributedString alloc] initWithString:desc attributes:attributes];
                self.circleDesc.hidden = NO;
                CGSize descSize = [QWGLOBALMANAGER sizeText:desc font:fontSystem(14) limitWidth:APP_W-30];
                float singleLabelHeight = 15.5;
                int line = descSize.height/singleLabelHeight;
                self.circleDesc_layout_height.constant = descSize.height + (line-1)*4 +5;
                
                self.commonHeaderView.frame = CGRectMake(0, 0, APP_W, 200 + descSize.height+ (line-1)*4 + 5);
                self.tableView.tableHeaderView = self.commonHeaderView;
            }
        }
    }
    
    //入驻专家
    self.circleMasterOneImage.layer.cornerRadius = 23.5;
    self.circleMasterOneImage.layer.masksToBounds = YES;
    self.circleMasterTwoImage.layer.cornerRadius = 23.5;
    self.circleMasterTwoImage.layer.masksToBounds = YES;
    self.circleMasterThreeImage.layer.cornerRadius = 23.5;
    self.circleMasterThreeImage.layer.masksToBounds = YES;
    self.circleMasterFourImage.layer.cornerRadius = 23.5;
    self.circleMasterFourImage.layer.masksToBounds = YES;
    self.circleMasterFiveImage.layer.cornerRadius = 23.5;
    self.circleMasterFiveImage.layer.masksToBounds = YES;
    
    
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
        self.expertImageTwo_layout_space.constant = (APP_W-299)/4;
        self.expertImageThree_layout_space.constant = (APP_W-299)/4;
        self.expertImageFour_layout_space.constant = (APP_W-299)/4;
        self.expertBg_layout_left.constant = 4;
        self.expertBg_layout_right.constant = 10;
        self.enterLogo_layout_left.constant = 10;
    }else
    {
        self.expertImageTwo_layout_space.constant = (APP_W-319)/4;
        self.expertImageThree_layout_space.constant = (APP_W-319)/4;
        self.expertImageFour_layout_space.constant = (APP_W-319)/4;
        self.expertBg_layout_left.constant = 14;
        self.expertBg_layout_right.constant = 15;
        self.enterLogo_layout_left.constant = 15;
    }
    
    
    NSArray *arr = self.circleDetailModel.expertUrlList;
    
    if (arr)
    {
        if (arr.count == 0)
        {
            self.circleMasterOneImage.hidden = YES;
            self.circleMasterTwoImage.hidden = YES;
            self.circleMasterThreeImage.hidden = YES;
            self.circleMasterFourImage.hidden = YES;
            self.circleMasterFiveImage.hidden = YES;
            self.noCircleMasterTipView.hidden = NO;
            
        }else if (arr.count == 1)
        {
            self.circleMasterOneImage.hidden = NO;
            [self.circleMasterOneImage setImageWithURL:[NSURL URLWithString:arr[0]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            self.circleMasterTwoImage.hidden = YES;
            self.circleMasterThreeImage.hidden = YES;
            self.circleMasterFourImage.hidden = YES;
            self.circleMasterFiveImage.hidden = YES;
            self.noCircleMasterTipView.hidden = YES;
            
        }else if (arr.count == 2)
        {
            
            self.circleMasterOneImage.hidden = NO;
            self.circleMasterTwoImage.hidden = NO;
            [self.circleMasterOneImage setImageWithURL:[NSURL URLWithString:arr[0]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.circleMasterTwoImage setImageWithURL:[NSURL URLWithString:arr[1]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            self.circleMasterThreeImage.hidden = YES;
            self.circleMasterFourImage.hidden = YES;
            self.circleMasterFiveImage.hidden = YES;
            self.noCircleMasterTipView.hidden = YES;
            
        }else if (arr.count == 3)
        {
            self.circleMasterOneImage.hidden = NO;
            self.circleMasterTwoImage.hidden = NO;
            self.circleMasterThreeImage.hidden = NO;
            [self.circleMasterOneImage setImageWithURL:[NSURL URLWithString:arr[0]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.circleMasterTwoImage setImageWithURL:[NSURL URLWithString:arr[1]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.circleMasterThreeImage setImageWithURL:[NSURL URLWithString:arr[2]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            self.circleMasterFourImage.hidden = YES;
            self.circleMasterFiveImage.hidden = YES;
            self.noCircleMasterTipView.hidden = YES;
            
        }else if (arr.count == 4)
        {
            self.circleMasterOneImage.hidden = NO;
            self.circleMasterTwoImage.hidden = NO;
            self.circleMasterThreeImage.hidden = NO;
            self.circleMasterFourImage.hidden = NO;
            [self.circleMasterOneImage setImageWithURL:[NSURL URLWithString:arr[0]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.circleMasterTwoImage setImageWithURL:[NSURL URLWithString:arr[1]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.circleMasterThreeImage setImageWithURL:[NSURL URLWithString:arr[2]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.circleMasterFourImage setImageWithURL:[NSURL URLWithString:arr[3]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            self.circleMasterFiveImage.hidden = YES;
            self.noCircleMasterTipView.hidden = YES;
            
        }else if (arr.count == 5)
        {
            self.circleMasterOneImage.hidden = NO;
            self.circleMasterTwoImage.hidden = NO;
            self.circleMasterThreeImage.hidden = NO;
            self.circleMasterFourImage.hidden = NO;
            self.circleMasterFiveImage.hidden = NO;
            
            [self.circleMasterOneImage setImageWithURL:[NSURL URLWithString:arr[0]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.circleMasterTwoImage setImageWithURL:[NSURL URLWithString:arr[1]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.circleMasterThreeImage setImageWithURL:[NSURL URLWithString:arr[2]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.circleMasterFourImage setImageWithURL:[NSURL URLWithString:arr[3]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.circleMasterFiveImage setImageWithURL:[NSURL URLWithString:arr[4]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            self.noCircleMasterTipView.hidden = YES;
            
        }else if (arr.count > 5)
        {
            self.circleMasterOneImage.hidden = NO;
            self.circleMasterTwoImage.hidden = NO;
            self.circleMasterThreeImage.hidden = NO;
            self.circleMasterFourImage.hidden = NO;
            self.circleMasterFiveImage.hidden = NO;
            [self.circleMasterOneImage setImageWithURL:[NSURL URLWithString:arr[0]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.circleMasterTwoImage setImageWithURL:[NSURL URLWithString:arr[1]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.circleMasterThreeImage setImageWithURL:[NSURL URLWithString:arr[2]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.circleMasterFourImage setImageWithURL:[NSURL URLWithString:arr[3]] placeholderImage:[UIImage imageNamed:@"expert_ic_people"]];
            [self.circleMasterFiveImage setImage:[UIImage imageNamed:@"ic_quqnzixq_more"]];
            self.noCircleMasterTipView.hidden = YES;
        }
    }
}

#pragma mark ---- 关注／取消关注 ----
- (IBAction)attentionAction:(id)sender
{
    [QWGLOBALMANAGER statisticsEventId:@"x_qzxq_gz" withLable:@"圈子详情-关注" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl),@"点击时间":[QWGLOBALMANAGER timeStrNow],@"圈子名":StrDFString(self.circleDetailModel.teamName, @"圈子名"),@"类型":self.circleDetailModel.flagAttn ? @"取消关注" : @"关注"}]];
    
    
    if (self.circleDetailModel.flagGroup)
    {
        [QWGLOBALMANAGER statisticsEventId:@"商家圈_关注圈子按键" withLable:@"圈子" withParams:nil];
    }else
    {
        [QWGLOBALMANAGER statisticsEventId:@"公共圈_关注圈子按键" withLable:@"圈子" withParams:nil];
    }
    
    
    
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:kWarning12];
        return;
    }
    
    if(!QWGLOBALMANAGER.loginStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        loginViewController.loginSuccessBlock = ^{
            [self queryCircleInfo];
        };
        [self presentViewController:navgationController animated:YES completion:NULL];
        return;
    }
    
    if (QWGLOBALMANAGER.configure.flagSilenced) {
        [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
        return;
    }
    
    NSString *type;
    if (self.circleDetailModel.flagAttn) {
        //取消关注
        type = @"1";
    }else{
        //关注
        type = @"0";
    }
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"teamId"] = StrFromObj(self.circleDetailModel.teamId);
    setting[@"isAttentionTeam"] = StrFromObj(type);
    setting[@"token"] = StrFromObj(QWGLOBALMANAGER.configure.userToken);
    [Circle teamAttentionTeamWithParams:setting success:^(id obj) {
        if ([obj[@"apiStatus"] integerValue] == 0) {
            
            if ([obj[@"rewardScore"] integerValue] > 0) {
                 [QWProgressHUD showSuccessWithStatus:@"关注成功" hintString:[NSString stringWithFormat:@"+%ld", [obj[@"rewardScore"] integerValue]] duration:DURATION_CREDITREWORD];
            }else{
                [SVProgressHUD showSuccessWithStatus:obj[@"apiMessage"]];
            }
            
            self.circleDetailModel.flagAttn = !self.circleDetailModel.flagAttn;
            [self setUpTableHeaderView];
        }else{
            [SVProgressHUD showErrorWithStatus:obj[@"apiMessage"]];
        }
    } failure:^(HttpException *e) {
        
    }];
}

#pragma mark ---- 展开圈子简介 ----
- (IBAction)headerSpreadAction:(id)sender
{
    if (self.isSpreadDesc)
    {
        //圈子简介收起
        self.isSpreadDesc = NO;
        
        //图片旋转
        self.circleDescTransformImage.transform=CGAffineTransformMakeRotation(0);
        
        //简介hidden
        self.circleDesc.hidden = YES;
        self.circleDesc_layout_height.constant = 1;
        
        self.commonHeaderView.frame = CGRectMake(0, 0, APP_W, 200);
        self.tableView.tableHeaderView = self.commonHeaderView;
        [self.tableView reloadData];
    }else
    {
        [QWGLOBALMANAGER statisticsEventId:@"x_qzxq_ckgd" withLable:@"圈子详情-查看更多" withParams:nil];
        //圈子简介展开
        self.isSpreadDesc = YES;
        
        //图片旋转
        self.circleDescTransformImage.transform=CGAffineTransformMakeRotation(M_PI);
        
        //设置行间距 赋值
        NSString *desc = self.circleDetailModel.teamDesc;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 4;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        NSDictionary *attributes = @{NSFontAttributeName:fontSystem(14),NSParagraphStyleAttributeName:paragraphStyle};
        self.circleDesc.attributedText = [[NSAttributedString alloc] initWithString:desc attributes:attributes];
        self.circleDesc.hidden = NO;
        CGSize descSize = [QWGLOBALMANAGER sizeText:desc font:fontSystem(14) limitWidth:APP_W-30];
        float singleLabelHeight = 15.5;
        int line = descSize.height/singleLabelHeight;
        
        self.circleDesc_layout_height.constant = descSize.height + (line-1)*4 +5;
        self.commonHeaderView.frame = CGRectMake(0, 0, APP_W, 200 + descSize.height+ (line-1)*4 + 5);
        self.tableView.tableHeaderView = self.commonHeaderView;
        [self.tableView reloadData];
    }
}

#pragma mark ---- 查看圈主 ----
- (IBAction)lookCircleMasterAction:(id)sender
{
    if (self.circleDetailModel.expertUrlList.count > 0)
    {
        
        if(!QWGLOBALMANAGER.loginStatus) {
            LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
            loginViewController.isPresentType = YES;
            loginViewController.loginSuccessBlock = ^{
                
            };
            [self presentViewController:navgationController animated:YES completion:NULL];
            return;
        }
        
        EnterExpertViewController *vc = [[UIStoryboard storyboardWithName:@"EnterExpert" bundle:nil] instantiateViewControllerWithIdentifier:@"EnterExpertViewController"];
        vc.hidesBottomBarWhenPushed = YES;
        vc.teamId = self.teamId;
        vc.teamName = self.circleDetailModel.teamName;
        vc.flagGroup = self.circleDetailModel.flagGroup;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark ---- 发帖 ----
- (IBAction)postTopicAction:(id)sender
{
    if (self.circleDetailModel.flagGroup){
        [QWGLOBALMANAGER statisticsEventId:@"商家圈_发帖按键" withLable:@"圈子" withParams:nil];
    }else{
        [QWGLOBALMANAGER statisticsEventId:@"公共圈_发帖按键" withLable:@"圈子" withParams:nil];
    }
    
    if (QWGLOBALMANAGER.configure.flagSilenced) {
        [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
        return;
    }
    
    QWCircleModel *model = [QWCircleModel new];
    [model buildWithCircleListModel:self.circleDetailModel];

    SendPostViewController* sendPostVC = [[UIStoryboard storyboardWithName:@"Forum" bundle:nil] instantiateViewControllerWithIdentifier:@"SendPostViewController"];
    sendPostVC.hidesBottomBarWhenPushed = YES;
    sendPostVC.needChooseCircle = NO;
    sendPostVC.sendCircle = model;
    sendPostVC.preVCNameStr = @"圈子详情";
    if (self.circleDetailModel.flagGroup)
    {
        //商家圈
        sendPostVC.isStoreCircle = YES;
    }
    [self.navigationController pushViewController:sendPostVC animated:YES];
}

#pragma mark ---- 搜索 ----
- (void)searchCircleAction
{
    
    if (self.circleDetailModel.flagGroup)
    {
        [QWGLOBALMANAGER statisticsEventId:@"商家圈_搜索按键" withLable:@"圈子" withParams:nil];
    }else
    {
        [QWGLOBALMANAGER statisticsEventId:@"公共圈_搜索按键" withLable:@"圈子" withParams:nil];
    }
    
    PostSearchViewController *vcMsgBoxList = [[PostSearchViewController alloc]initWithNibName:@"PostSearchViewController" bundle:nil];
    vcMsgBoxList.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vcMsgBoxList animated:YES];
}

#pragma mark ---- 刷新帖子列表 ----
- (void)refreshPostListWithIndex:(int)index
{
    self.tableView.footerNoDataText = @"已显示全部内容";
    [self.tableView.footer setDiseaseCanLoadMore:YES];
    
    currentViewController = self.viewControllerssss[index];
    currentViewController.teamId = self.teamId;
    [currentViewController currentViewSelected:^(CGFloat height) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end