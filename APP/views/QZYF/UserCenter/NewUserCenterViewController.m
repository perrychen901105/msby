//
//  NewUserCenterViewController.m
//  APP
//  新我的页面
//  NW_queryMemberDetail 用户资料
//  GetServiceTelLists 客服电话
//  GetInviteInfo 获取邀请好友资料
//  Created by qw_imac on 16/6/13.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "NewUserCenterViewController.h"
#import "NewUserCenterCell.h"
#import "LoginViewController.h"
#import "MessageBoxListViewController.h"
#import "QZNewSettingViewController.h"
#import "MKNumberBadgeView.h"
#import "MyIndentViewController.h"
#import "NewPersonInformationViewController.h"
#import "QZStoreCollectViewController.h"
#import "NewUserCenterFooterView.h"
#import "Mbr.h"
#import "LevelUpAlertView.h"
#import "SVProgressHUD.h"
#import "Credit.h"
#import "QWProgressHUD.h"
#import "MyCouponQuanViewController.h"
#import "WinDetialViewController.h"
#import "ReceiverAddressTableViewController.h"
#import "MineCareCircleViewController.h"
#import "MineCareExpertViewController.h"
#import "SendPostHistoryViewController.h"
#import "ReplyPostHistoryViewController.h"
#import "MyPostDraftViewController.h"
#import "MyCreditViewController.h"
#import "WebDirectViewController.h"
#import "NewMyCollectViewController.h"
#import "FeedbackViewController.h"
#import "CommendSuccessViewController.h"
#import "AddRecommenderViewController.h"
#import "MyCouponDrugViewController.h"
#import "PostSearchViewController.h"
#import "DetialLevelViewController.h"
#import "ExpertInfoViewController.h"

@interface NewUserCenterViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView   *collectionView;
@property (strong, nonatomic) UIImageView               *redPoint;
@property (nonatomic,assign) ShowLvlAlert               showLvlAlert;
@property (nonatomic,strong) mbrMemberInfo              *info;
@property (nonatomic,strong) LevelUpAlertView           *alertView;
@property (nonatomic, strong) InviterInfoModel          *modelInviterInfo;
@property (nonatomic,assign) BOOL                       hasUnreadMessage;
@end

@implementation NewUserCenterViewController
{
    NSMutableArray          *titleDataSource;
    NSMutableArray          *imgDataSource;
    NSMutableArray          *telNumbers;           //客服电话
    NSString                *score;               //积分
    NSString                *level;               //等级
}
static  NSString *const cellIdentifier = @"NewUserCenterCell";
static  NSString *const headerIdentifier = @"UserCenterHeaderView";
static  NSString *const footerIdentifier = @"UserCenterFooterView";
#pragma mark ----
#pragma mark LifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    //注册collectionView
    [self initializeCollectionView];
    //初始化数据
    [self initializeDataSource];
    //设置导航栏
    [self setNaviItem];
    //获取客服电话
    [self getServiceTel];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarColor:RGBHex(qwColor1) Shadow:NO];
    self.showLvlAlert = ShowLvlAlertYes;
    [self queryUserInfo];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //立刻刷新小红点
    [QWGLOBALMANAGER updateRedPoint];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setNavigationBarColor:nil Shadow:YES];
    self.showLvlAlert = ShowLvlAlertNo;
}
#pragma mark ----
#pragma mark Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return titleDataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *array = titleDataSource[section];
    return array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NewUserCenterCell *cell = (NewUserCenterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSArray *titleArray = titleDataSource[indexPath.section];
    NSString *title = titleArray[indexPath.row];
    NSArray *imgArray = imgDataSource[indexPath.section];
    NSString *img = imgArray[indexPath.row];
    [cell setCellWith:title And:img];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NewUserCenterHeaderView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
        [reusableView setHeaderView:_status];
        [reusableView setView:_info];
        
        //headerview添加手势
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loginClick)];
        [reusableView.loginBeforeView addGestureRecognizer:tap1];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(personHeadImageClick)];
        [reusableView.loginAfterView addGestureRecognizer:tap];
        //headerView添加按钮事件
        switch (_status) {
            case CurrentCityStatusOpenWeChatBussness:
                [reusableView.allOrdersBtn addTarget:self action:@selector(enterOrders:) forControlEvents:UIControlEventTouchUpInside];
                [reusableView.unDoneOrdersBtn addTarget:self action:@selector(enterOrders:) forControlEvents:UIControlEventTouchUpInside];
                [reusableView.unEvaOrdersBtn addTarget:self action:@selector(enterOrders:) forControlEvents:UIControlEventTouchUpInside];
                break;
            case CurrentCityStatusUnopenWechatBussness:
                [reusableView.allOrdersBtn addTarget:self action:@selector(unopenWechatBussnessAction:) forControlEvents:UIControlEventTouchUpInside];
                [reusableView.unDoneOrdersBtn addTarget:self action:@selector(unopenWechatBussnessAction:) forControlEvents:UIControlEventTouchUpInside];
                [reusableView.unEvaOrdersBtn addTarget:self action:@selector(unopenWechatBussnessAction:) forControlEvents:UIControlEventTouchUpInside];
                break;
        }
        [reusableView.levelBtn addTarget:self action:@selector(enterMyLevel) forControlEvents:UIControlEventTouchUpInside];
        [reusableView.signBtn addTarget:self action:@selector(signAction) forControlEvents:UIControlEventTouchUpInside];
//        [reusableView.messageBtn addTarget:self action:@selector(pushIntoMessageBox:) forControlEvents:UIControlEventTouchUpInside];
//        [reusableView.setBtn addTarget:self action:@selector(newSetting) forControlEvents:UIControlEventTouchUpInside];
        return reusableView;
    }else {
        NewUserCenterFooterView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footerIdentifier forIndexPath:indexPath];
        if (telNumbers.count > 0) {
            [reusableView setView:[telNumbers firstObject]];
        }else {
            [reusableView setView:@""];
        }
        [reusableView.telBtn addTarget:self action:@selector(callTel:) forControlEvents:UIControlEventTouchUpInside];
        return reusableView;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((APP_W - 3)/4, 98.0f);
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0f;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0f;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 0, 0, 0);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize size;
    if (section == 0) {
        size = CGSizeMake(APP_W, 238);
    }else {
        size = CGSizeZero;
    }
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize size;
    if (section == titleDataSource.count - 1) {
        size = CGSizeMake(APP_W, 90);
    }else {
        size = CGSizeZero;
    }
    return size;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSArray *array = titleDataSource[indexPath.section];
    NSString *event = array[indexPath.row];
    [self matchActionWith:event];
}
#pragma mark ----
#pragma mark Private Method
-(void)initializeDataSource {
    //我的页面未出现时不显示升级提示框
    self.showLvlAlert = ShowLvlAlertNo;
    
    _hasUnreadMessage = NO;
    telNumbers = @[].mutableCopy;
    
    if (_status == CurrentCityStatusOpenWeChatBussness) {
        NSArray *sectionOneTitle = @[@"优惠券",@"优惠商品",@"中奖记录",@"收货地址"];
        NSArray *sectionTwoTitle = @[@"我的药房",@"关注的圈子",@"关注的专家",@"收藏",@"我的发帖",@"我的回帖",@"草稿箱",@"我的积分",@"积分商城",@"意见反馈",@"邀请好友",@"我的推荐人"];
        titleDataSource = @[sectionOneTitle,sectionTwoTitle].mutableCopy;
        
        NSArray *sectionOneImg = @[@"icon_coupons_personal",@"icon_goods_personal",@"icon_winning_personal",@"ic_my_address"];
        NSArray *sectionTwoImg = @[@"icon_pharmacy_personal",@"icon_attention_personal",@"icon_professor_personal",@"icon_collect_personal",@"icon_post_personal",@"icon_return_personal",@"icon_rubbish_personal",@"icon_integral_personal",@"icon_mall_personal",@"icon_idea_personal",@"icon_friend_personal",@"icon_referrer_personal"];
        imgDataSource = @[sectionOneImg,sectionTwoImg].mutableCopy;
    }else {
        NSArray *sectionOneTitle = @[@"我的发帖",@"我的回帖",@"草稿箱",@"我的积分",@"积分商城",@"收货地址",@"意见反馈",@"邀请好友"];
        titleDataSource = @[sectionOneTitle].mutableCopy;
        
        NSArray *sectionOneImg = @[@"ic_my_mypost",@"ic_my_back",@"ic_my_drafts",@"ic_my_integral",@"ic_my_integralshop",@"ic_my_address",@"ic_my_suggest",@"ic_my_invite"];
        imgDataSource = @[sectionOneImg].mutableCopy;
    }
}

-(void)initializeCollectionView {
    [_collectionView registerNib:[UINib nibWithNibName:@"NewUserCenterCell" bundle:nil] forCellWithReuseIdentifier:cellIdentifier];
    [_collectionView registerNib:[UINib nibWithNibName:@"NewUserCenterFooterView" bundle:nil]forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerIdentifier];
    [_collectionView registerNib:[UINib nibWithNibName:@"NewUserCenterHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier];
}

-(void)setNaviItem {
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -15;
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
    bg.backgroundColor = [UIColor clearColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(2, -1, 60, 44);
    [btn setImage:[UIImage imageNamed:@"ic_my_havesign"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(pushIntoMessageBox:) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:btn];
    self.redPoint = [[UIImageView alloc] initWithFrame:CGRectMake(40, 8, 8, 8)];
    self.redPoint.image = [UIImage imageNamed:@"ic_my_havesignpoint"];
    self.redPoint.hidden = YES;
    [bg addSubview:self.redPoint];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:bg];
    UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [leftBtn setTitleColor:RGBHex(qwColor4) forState:UIControlStateNormal];
    [leftBtn setTitle:@"设置" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(newSetting) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *naviBtn = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.rightBarButtonItems = @[fixed,item,naviBtn];
}
//升级
-(void)levelUpWith:(NSString *)currentLevel {
    LevelUpModel *model = [[LevelUpModel alloc]init];
    model.level = [currentLevel integerValue];
    model.integral = [QWGLOBALMANAGER rewardScoreWithTaskKey:[NSString stringWithFormat:@"VIP%d",model.level]];
    self.alertView = [LevelUpAlertView levelUpAlertViewWith:model];
    self.alertView.frame =  CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.alertView.bkView.alpha = 0.0;
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    [win addSubview:self.alertView];
    [UIView animateWithDuration:0.25 animations:^{
        self.alertView.bkView.alpha =0.4;
        self.alertView.alertView.hidden = NO;
    }];
}

-(void)queryUserInfo {
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable ) {
        return;
    }
    if (!QWGLOBALMANAGER.loginStatus) {
        [_collectionView reloadData];
    }else {
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[@"token"] = QWGLOBALMANAGER.configure.userToken?QWGLOBALMANAGER.configure.userToken:@"";
        HttpClientMgr.progressEnabled = NO;
        [Mbr queryMemberDetailWithParams:param success:^(id DFUserModel) {
            mbrMemberInfo *info = DFUserModel;
            self.info = info;
            if (info.apiStatus.integerValue == 0) {
                
            }else if (info.apiStatus.integerValue == 1){
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:ALERT_MESSAGE delegate:  self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }else{
                [SVProgressHUD showErrorWithStatus:info.apiMessage duration:DURATION_SHORT];
            }
        } failure:^(HttpException *e) {
            
        }];
    }
}

-(void)getServiceTel {
    [Mbr queryServiceTelSuccess:^(ServiceTelModel *obj) {
        if ([obj.apiStatus integerValue] == 0) {
            [telNumbers removeAllObjects];
            [telNumbers addObjectsFromArray:obj.list];
            [_collectionView reloadData];
        }
    } failure:^(HttpException *e) {
        
    }];
}

// 获取邀请好友的信息
- (void)getInviterInfo {
    [Mbr getInviteInfo:[MbrInviterInfoModelR new] success:^(id obj) {
        if (obj != nil) {
            self.modelInviterInfo = (InviterInfoModel *) obj;
            [self inviteFriend];
        }
    } failure:^(HttpException *e) {
        
    }];
}
-(void)inviteFriend {
    NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
    tdParams[@"页面类型"]=@"营销";
    [QWGLOBALMANAGER statisticsEventId:@"x_wd_yqhy" withLable:@"我的" withParams:tdParams];
    ShareContentModel *modelShare = [[ShareContentModel alloc] init];
    modelShare.typeShare = ShareTypeRecommendFriends;
    modelShare.typeCome=@"1";//从我的个人中心进来
    if (self.modelInviterInfo != nil) {
        modelShare.title = self.modelInviterInfo.title;
        modelShare.content = self.modelInviterInfo.desc;
        modelShare.imgURL = self.modelInviterInfo.imgUrl;
    }
    if (!QWGLOBALMANAGER.loginStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        __weak typeof(self) weakSelf = self;
        loginViewController.loginSuccessBlock = ^(){
            [weakSelf popUpShareView:modelShare];
        };
    }else {
        if (QWGLOBALMANAGER.configure.inviteCode == nil) {
            QWGLOBALMANAGER.configure.inviteCode = @"";
        }
        modelShare.shareLink = [NSString stringWithFormat:@"%@html5/v224/downLoad.html?inviteCode=%@",BASE_URL_V2,QWGLOBALMANAGER.configure.inviteCode];
        [self popUpShareView:modelShare];
    }
}

-(void)matchActionWith:(NSString *)event {
    if ([event isEqualToString:@"优惠券"]) {
        [self enterMyCoupon];
    }else if ([event isEqualToString:@"优惠商品"]) {
        [self enterMyCouponDrug];
    }else if ([event isEqualToString:@"中奖记录"]) {
        [self enterWinList];
    }else if ([event isEqualToString:@"我的药房"]) {
        [self collectBranch];
    }else if ([event isEqualToString:@"收货地址"]) {
        [self enterAddressList];
    }else if ([event isEqualToString:@"关注的圈子"]) {
        [self enterCareCircle];
    }else if ([event isEqualToString:@"关注的专家"]) {
        [self enterCareExpert];
    }else if ([event isEqualToString:@"我的发帖"]) {
        [self enterMyFatie];
    }else if ([event isEqualToString:@"我的回帖"]) {
        [self enterMyHuitie];
    }else if ([event isEqualToString:@"草稿箱"]) {
        [self enterDraftbox];
    }else if ([event isEqualToString:@"我的积分"]) {
        [self enterMyCredit];
    }else if ([event isEqualToString:@"积分商城"]) {
        [self enterIntegral];
    }else if ([event isEqualToString:@"收藏"]) {
        [self enterCollect];
    }else if ([event isEqualToString:@"意见反馈"]) {
        [self enterFeedBack];
    }else if ([event isEqualToString:@"邀请好友"]) {
        [self invateFriends];
    }else if ([event isEqualToString:@"我的推荐人"]) {
        [self MyRecommender];
    }
}
//登陆后跳转
-(void)doActionAfterLogin:(SEL)selector {
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
    loginViewController.isPresentType = YES;
    [self presentViewController:navgationController animated:YES completion:NULL];
    __weak typeof(self) weakSelf = self;
    loginViewController.loginSuccessBlock = ^(){
        [weakSelf performSelector:selector withObject:nil afterDelay:0.0];
    };
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        if (scrollView.contentOffset.y < 0) {
            [scrollView setContentOffset:CGPointZero];
        }
    }
}
#pragma mark ----
#pragma mark Business Method
//登录
-(void)loginClick {
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginViewController.hidesBottomBarWhenPushed = YES;
    loginViewController.needVerifyFullInfo = YES;
    [self.navigationController pushViewController:loginViewController animated:YES];
}
//消息
- (void)pushIntoMessageBox:(id)sender {
    [QWGLOBALMANAGER statisticsEventId:@"我的_消息" withLable:nil withParams:nil];
    if(!QWGLOBALMANAGER.loginStatus) {
        [self doActionAfterLogin:NSSelectorFromString(@"enterMessageBox")];
    }else {
        [self enterMessageBox];
    }
}
-(void)enterMessageBox {
    NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
    tdParams[@"页面类型"]=@"营销";
    tdParams[@"事件"]=@"消息";
    [QWGLOBALMANAGER statisticsEventId:@"x_wd_xx" withLable:@"消息" withParams:tdParams];
    if (_status == CurrentCityStatusOpenWeChatBussness) {
        // 开通微商
        MessageBoxListViewController *vcMsgBoxList = [[UIStoryboard storyboardWithName:@"MessageBoxListViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MessageBoxListViewController"];
        vcMsgBoxList.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vcMsgBoxList animated:YES];
    } else {
        ExpertInfoViewController *vc = [[ExpertInfoViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
//设置
-(void)newSetting {
    [QWGLOBALMANAGER statisticsEventId:@"我的_设置" withLable:nil withParams:nil];

    NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
    tdParams[@"页面类型"]=@"营销";
    [QWGLOBALMANAGER statisticsEventId:@"x_wd_sz" withLable:@"我的" withParams:tdParams];
    QZNewSettingViewController* setting = [[UIStoryboard storyboardWithName:@"QZSetting" bundle:nil] instantiateViewControllerWithIdentifier:@"QZNewSettingViewController"];
    setting.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:setting animated:YES];
}
//签到
-(void)signAction {
    if (self.info.sign) {
        return;
    }
    [QWGLOBALMANAGER statisticsEventId:@"我的_签到" withLable:nil withParams:nil];
    SignR *modelR = [SignR new];
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [self showInfoInView:self.tableMain offsetSize:0 text:@"网络未连通，请重试" image:@"网络信号icon"];
    }else {
        if (QWGLOBALMANAGER.configure.userToken) {
            modelR.token = QWGLOBALMANAGER.configure.userToken;
        }
        [Credit sign:modelR success:^(SignModel *responModel) {
            if ([responModel.apiStatus integerValue] == 0) {
                [QWProgressHUD showSuccessWithStatus:@"签到成功!" hintString:[NSString stringWithFormat:@"+%@",responModel.rewardScore] duration:2.0];
                [self queryUserInfo];
                NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
                tdParams[@"页面类型"]=@"营销";
                tdParams[@"积分"] = [NSString stringWithFormat:@"%@",score];
                [QWGLOBALMANAGER statisticsEventId:@"x_wd_qd" withLable:@"我的" withParams:tdParams];
            }else {
                [QWProgressHUD showSuccessWithStatus:responModel.apiMessage hintString:nil duration:2.0];
            }
        } failure:^(HttpException *e) {
            [QWProgressHUD showSuccessWithStatus:@"签到失败!" hintString:nil duration:2.0];
        }];
    }
}
-(void)enterMyLevel {
    [QWGLOBALMANAGER statisticsEventId:@"我的_等级" withLable:nil withParams:nil];
    if(!QWGLOBALMANAGER.loginStatus) {
        [self doActionAfterLogin:NSSelectorFromString(@"_enterMyLevel")];
    }else {
        [self _enterMyLevel];
    }
}

-(void)_enterMyLevel {
    NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
    tdParams[@"页面类型"]=@"营销";
    [QWGLOBALMANAGER statisticsEventId:@"x_wd_dj" withLable:@"我的" withParams:tdParams];
    //等级页面
    DetialLevelViewController *viewController = [DetialLevelViewController new];
    viewController.isComeFromIntegralVC = NO;
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}
//个人资料
- (void)personHeadImageClick {
    [QWGLOBALMANAGER statisticsEventId:@"我的_个人资料" withLable:nil withParams:nil];
    NewPersonInformationViewController *personInfoViewController = [[NewPersonInformationViewController alloc]  init];
    personInfoViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personInfoViewController animated:YES];
}
//未开通微商情况下业务处理
-(void)unopenWechatBussnessAction:(UIButton *)sender {
    switch (sender.tag) {
        case 1: //关注的圈子
            [self enterCareCircle];
            break;
        case 2: //关注的专家
            [self enterCareExpert];
            break;
        case 3: //我的收藏
            [self enterCollect];
            break;
    }
}

//进入我的药房
- (void)collectBranch{
    [QWGLOBALMANAGER statisticsEventId:@"我的_我的药房" withLable:nil withParams:nil];
    if(!QWGLOBALMANAGER.loginStatus){
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        __weak typeof(self) weakSelf = self;
        loginViewController.loginSuccessBlock = ^(){
            QZStoreCollectViewController *careConsultView = [[QZStoreCollectViewController alloc]init];
            careConsultView.hidesBottomBarWhenPushed = YES;
            [weakSelf.navigationController pushViewController:careConsultView animated:YES];
        };
    }else{
        QZStoreCollectViewController *careConsultView = [[QZStoreCollectViewController alloc]init];
        careConsultView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:careConsultView animated:YES];
    }
}

//进入订单
- (void)enterOrders:(UIButton *)sender {
    if(QWGLOBALMANAGER.loginStatus){
        [self enterIndentWith:sender.tag];
    }else{
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        __weak typeof(self) weakSelf = self;
        loginViewController.loginSuccessBlock = ^(){
            [weakSelf enterIndentWith:sender.tag];
        };
    }
}
-(void)enterIndentWith:(NSInteger)tag {
    NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
    tdParams[@"等级"]=level;
    NSString *event;
    switch (tag) {
        case 1:
            [QWGLOBALMANAGER statisticsEventId:@"我的_全部订单" withLable:nil withParams:nil];
            event = @"x_sywddd_ckqb";
            break;
        case 2:
            [QWGLOBALMANAGER statisticsEventId:@"我的_未完成" withLable:nil withParams:nil];
            event = @"x_sywddd_wwc";
            break;
        case 3:
            [QWGLOBALMANAGER statisticsEventId:@"我的_待评价" withLable:nil withParams:nil];
            event = @"x_sywddd_dpj";
            break;
    }
    [QWGLOBALMANAGER statisticsEventId:event withLable:@"我的" withParams:tdParams];
    MyIndentViewController *myIndent = [MyIndentViewController new];
    myIndent.hidesBottomBarWhenPushed = YES;
    myIndent.index = tag;
    [self.navigationController pushViewController:myIndent animated:YES];
}
//进入优惠券
-(void)enterMyCoupon{
    [QWGLOBALMANAGER statisticsEventId:@"我的_优惠券" withLable:nil withParams:nil];
    if(QWGLOBALMANAGER.loginStatus){
        [self _enterMyCoupon];
    }else{
        [self doActionAfterLogin:NSSelectorFromString(@"_enterMyCoupon")];
    }
}
-(void)_enterMyCoupon {
    MyCouponQuanViewController *myCouponQuan = [[MyCouponQuanViewController alloc]init];
    myCouponQuan.hidesBottomBarWhenPushed = YES;
    myCouponQuan.popToRootView = NO;
    [self.navigationController pushViewController:myCouponQuan animated:YES];
}
//进入优惠商品
-(void)enterMyCouponDrug {
    [QWGLOBALMANAGER statisticsEventId:@"我的_优惠商品" withLable:nil withParams:nil];
    if(QWGLOBALMANAGER.loginStatus){
        [self _enterMyCouponDrug];
    }else{
        [self doActionAfterLogin:NSSelectorFromString(@"_enterMyCouponDrug")];
    }
}
-(void)_enterMyCouponDrug {
    MyCouponDrugViewController * myCouponDrug = [[MyCouponDrugViewController alloc]init];
    myCouponDrug.hidesBottomBarWhenPushed = YES;
    myCouponDrug.popToRootView = NO;
    [self.navigationController pushViewController:myCouponDrug animated:YES];
}
//进入中奖纪录
-(void)enterWinList {
    [QWGLOBALMANAGER statisticsEventId:@"我的_中奖记录" withLable:nil withParams:nil];
    if(QWGLOBALMANAGER.loginStatus){
        [self _enterWinList];
    }else{
        [self doActionAfterLogin:NSSelectorFromString(@"_enterWinList")];
    }
}
-(void)_enterWinList {
    NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
    tdParams[@"事件"]=@"中奖纪录";
    [QWGLOBALMANAGER statisticsEventId:@"x_wd_zjjl_dj" withLable:@"我的" withParams:tdParams];
    WinDetialViewController *viewController = [WinDetialViewController new];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}


//进入收货地址
- (void)enterAddressList {
    [QWGLOBALMANAGER statisticsEventId:@"我的_收货地址" withLable:nil withParams:nil];
    if(QWGLOBALMANAGER.loginStatus){
        [self _enterAddressList];
    }else{
        [self doActionAfterLogin:NSSelectorFromString(@"_enterAddressList")];
    }
}
- (void)_enterAddressList {
    NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
    tdParams[@"等级"]=level;
    [QWGLOBALMANAGER statisticsEventId:@"x_sywddd_shdz" withLable:@"我的订单" withParams:tdParams];
    ReceiverAddressTableViewController *vc = [ReceiverAddressTableViewController new];
    vc.pageType = PageComeFromReceiveAddress;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
//关注的圈子
-(void)enterCareCircle {
    [QWGLOBALMANAGER statisticsEventId:@"我的_关注的圈子" withLable:nil withParams:nil];
    if (!QWGLOBALMANAGER.loginStatus) {
        [self doActionAfterLogin:NSSelectorFromString(@"_enterCareCircle")];
    }else{
        [self _enterCareCircle];
    }
}
-(void)_enterCareCircle {
    if (QWGLOBALMANAGER.configure.flagSilenced) {
        [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
        return;
    }else {
        [QWGLOBALMANAGER statisticsEventId:@"x_wd_gzdqz" withLable:@"我的-关注的圈子" withParams:nil];
        MineCareCircleViewController* careCircleVC = [[MineCareCircleViewController alloc] init];
        careCircleVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:careCircleVC animated:YES];
    }
}
//关注的专家
-(void)enterCareExpert {
    [QWGLOBALMANAGER statisticsEventId:@"我的_关注的专家" withLable:nil withParams:nil];
    if (!QWGLOBALMANAGER.loginStatus) {
        [self doActionAfterLogin:NSSelectorFromString(@"_enterCareExpert")];
    }else{
        [self _enterCareExpert];
    }
}
-(void)_enterCareExpert{
    if (QWGLOBALMANAGER.configure.flagSilenced) {
        [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
        return;
    }else {
        [QWGLOBALMANAGER statisticsEventId:@"x_wd_gzdzj" withLable:@"我的-关注的专家" withParams:nil];
        MineCareExpertViewController* careExpertVC = [[MineCareExpertViewController alloc] init];
        careExpertVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:careExpertVC animated:YES];
    }
}
//我的发帖
-(void)enterMyFatie {
    [QWGLOBALMANAGER statisticsEventId:@"我的_我的发帖" withLable:nil withParams:nil];
    if (!QWGLOBALMANAGER.loginStatus) {
        [self doActionAfterLogin:NSSelectorFromString(@"_enterMyFatie")];
    }else {
        [self _enterMyFatie];
    }
}
-(void)_enterMyFatie{
    if (QWGLOBALMANAGER.configure.flagSilenced) {
        [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
        return;
    }
    [QWGLOBALMANAGER statisticsEventId:@"x_wd_wdft" withLable:@"我的-我的发帖" withParams:nil];
    SendPostHistoryViewController* sendPostHistory = [[SendPostHistoryViewController alloc] init];
    sendPostHistory.hidesBottomBarWhenPushed = YES;
    sendPostHistory.token = QWGLOBALMANAGER.configure.userToken;
    [self.navigationController pushViewController:sendPostHistory animated:YES];
}
//我的回帖
-(void)enterMyHuitie {
    [QWGLOBALMANAGER statisticsEventId:@"我的_我的回帖" withLable:nil withParams:nil];
    if (!QWGLOBALMANAGER.loginStatus) {
        [self doActionAfterLogin:NSSelectorFromString(@"_enterMyHuitie")];
    }else{
        [self _enterMyHuitie];
    }
}
-(void)_enterMyHuitie {
    if (QWGLOBALMANAGER.configure.flagSilenced) {
        [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
        return;
    }
    [QWGLOBALMANAGER statisticsEventId:@"x_wd_wdht" withLable:@"我的-我的回帖" withParams:nil];
    ReplyPostHistoryViewController* replyPostHistoryVC = [[ReplyPostHistoryViewController alloc] init];
    replyPostHistoryVC.token = QWGLOBALMANAGER.configure.userToken;
    replyPostHistoryVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:replyPostHistoryVC animated:YES];
}
//草稿箱
-(void)enterDraftbox{
    [QWGLOBALMANAGER statisticsEventId:@"我的_草稿箱" withLable:nil withParams:nil];
    if(QWGLOBALMANAGER.loginStatus){
        [self _enterDraftbox];
    }else{
        [self doActionAfterLogin:NSSelectorFromString(@"_enterDraftbox")];
    }
}
-(void)_enterDraftbox {
    if (QWGLOBALMANAGER.configure.flagSilenced) {
        [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
        return;
    }
    [QWGLOBALMANAGER statisticsEventId:@"x_wd_cgx" withLable:@"我的-草稿箱" withParams:nil];
    MyPostDraftViewController* myPostDraft = [[MyPostDraftViewController alloc] init];
    myPostDraft.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myPostDraft animated:YES];
}
//积分
-(void)enterMyCredit {
    [QWGLOBALMANAGER statisticsEventId:@"我的_我的积分" withLable:nil withParams:nil];
    if(QWGLOBALMANAGER.loginStatus){
        [self _enterMyCredit];
    }else{
        [self doActionAfterLogin:NSSelectorFromString(@"_enterMyCredit")];
    }
}
-(void)_enterMyCredit {
    NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
    tdParams[@"页面类型"]=@"营销";
    [QWGLOBALMANAGER statisticsEventId:@"x_wd_jf" withLable:@"我的" withParams:tdParams];
    MyCreditViewController* creditVC = [[UIStoryboard storyboardWithName:@"Credit" bundle:nil] instantiateViewControllerWithIdentifier:@"MyCreditViewController"];
    creditVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:creditVC animated:YES];
}
//积分商城
-(void)enterIntegral {
    [QWGLOBALMANAGER statisticsEventId:@"我的_积分商城" withLable:nil withParams:nil];
    NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
    tdParams[@"等级"]=level;
    [QWGLOBALMANAGER statisticsEventId:@"x_sywddd_jfsc" withLable:@"我的" withParams:tdParams];
    WebDirectViewController *vcWebMedicine = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
    WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
    modelLocal.typeLocalWeb = WebPageTypeIntegralIndex;
    modelLocal.title = @"积分商城";
    [vcWebMedicine setWVWithLocalModel:modelLocal];
    [self.navigationController pushViewController:vcWebMedicine animated:YES];
}
//我的收藏
-(void)enterCollect {
    [QWGLOBALMANAGER statisticsEventId:@"我的_我的收藏" withLable:nil withParams:nil];
    if(QWGLOBALMANAGER.loginStatus){
        [self _enterCollect];
    }else{
        [self doActionAfterLogin:NSSelectorFromString(@"_enterCollect")];
    }
}
-(void)_enterCollect {
    [QWGLOBALMANAGER statisticsEventId:@"x_wd_wdsc" withLable:@"我的-我的收藏" withParams:nil];
    NewMyCollectViewController *myCollectView = [[NewMyCollectViewController alloc]init];
    myCollectView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myCollectView animated:YES];
}
//意见反馈
-(void)enterFeedBack {
    [QWGLOBALMANAGER statisticsEventId:@"我的_意见反馈" withLable:nil withParams:nil];
    NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
    tdParams[@"等级"]=level;
    [QWGLOBALMANAGER statisticsEventId:@"x_sywddd_yjfk" withLable:@"我的" withParams:tdParams];
    FeedbackViewController * feedback = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
    feedback.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:feedback animated:YES];
}
//邀请好友
-(void)invateFriends {
    [QWGLOBALMANAGER statisticsEventId:@"我的_邀请好友" withLable:nil withParams:nil];
    if(QWGLOBALMANAGER.loginStatus){
        [self getInviterInfo];
    }else{
        [self doActionAfterLogin:NSSelectorFromString(@"getInviterInfo")];
    }
}
//我的推荐人
- (void)MyRecommender{
    if (QWGLOBALMANAGER.loginStatus) {
        [self _MyRecommender];
    }else{
        [self doActionAfterLogin:NSSelectorFromString(@"_MyRecommender")];
    }
}
- (void)_MyRecommender{
    MbrInviterCheckR *model = [MbrInviterCheckR new];
    model.token = QWGLOBALMANAGER.configure.userToken;
    [Mbr InviterCheckWithParams:model success:^(id obj) {
        if (![obj[@"mobile"] isEqualToString:@""]){
            //提交成功
            CommendSuccessViewController *successVC = [[UIStoryboard storyboardWithName:@"CommendPerson" bundle:nil] instantiateViewControllerWithIdentifier:@"CommendSuccessViewController"];
            successVC.phoneStr = obj[@"mobile"];
            successVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:successVC animated:YES];
        }else{
            //尚未提交
            AddRecommenderViewController *addVC = [[AddRecommenderViewController alloc]initWithNibName:@"AddRecommenderViewController" bundle:nil];
            addVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:addVC animated:YES];
        }
    } failure:^(HttpException *e) {
        
    }];
}
//拨打客服电话
- (void)callTel:(UIButton *)sender {
    [QWGLOBALMANAGER statisticsEventId:@"我的_联系客服" withLable:nil withParams:nil];
    UIActionSheet *telphone = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: nil];
    for (NSInteger index = 0; index < telNumbers.count ; index ++) {
        [telphone addButtonWithTitle:telNumbers[index]];
    }
    [telphone showInView:self.view];
}
//action回调
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
        tdParams[@"等级"]=level;
        [QWGLOBALMANAGER statisticsEventId:@"x_sywddd_lxkf" withLable:@"我的" withParams:tdParams];
        [self callNumber:telNumbers[buttonIndex - 1]];
    }
}
-(void)callNumber:(NSString *)tel {
    NSString *number = [NSString stringWithFormat:@"tel://%@",tel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:number]];
}
#pragma mark ----
#pragma mark Notif
-(void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj {
    if (NotifLoginSuccess == type || NotifQuitOut == type) {
        [self queryUserInfo];
        QWGLOBALMANAGER.needShowBadge = NO;
        [QWGLOBALMANAGER setBadgeNumStatus:NO];
        self.hasUnreadMessage = NO;
        QWGLOBALMANAGER.sellerMineRedPoint.hidden = YES;
    } else if (NotiWhetherHaveNewMessage == type) {
        NSString *countStr = data;
        if ([countStr intValue] > 0) {
            self.hasUnreadMessage = YES;
            QWGLOBALMANAGER.sellerMineRedPoint.hidden = NO;
        } else {
            self.hasUnreadMessage = NO;
            QWGLOBALMANAGER.sellerMineRedPoint.hidden = YES;
        }
    }else if(NotifTabsWillTransition == type) {
        [self queryUserInfo];
    }
}
#pragma mark ----
#pragma mark Setter And Getter
-(void)setInfo:(mbrMemberInfo *)info {
    //存储数据
    [mbrMemberInfo saveObjToDB:info];
    _info = info;
    if (_info.upgrade && _showLvlAlert == ShowLvlAlertYes) {
        [self levelUpWith:_info.level];
    }
    [_collectionView reloadData];
}

-(void)setHasUnreadMessage:(BOOL)hasUnreadMessage {
    _hasUnreadMessage = hasUnreadMessage;
    if (hasUnreadMessage) {
        _redPoint.hidden = NO;
    }else {
        _redPoint.hidden = YES;
    }
}
@end
