//
//  QZLikeShopViewController.m
//  wenyao
//  我关注的药房 fixed by lijian at V4.0
//  4.0版本开始药房不再区分是否开通微商，我关注药房的接口替换
//  API(GET): h5/mbr/favorite/queryMyBranchs
//  支持分页加载，每页10条数据

//  Created by Meng on 15/1/16.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "QZStoreCollectViewController.h"
#import "CollectBranchTableViewCell.h"
#import "SVProgressHUD.h"
#import "ReturnIndexView.h"
#import "ConsultStore.h"
#import "MessageBoxListViewController.h"
#import "LoginViewController.h"
#import "PharmacySotreViewController.h"

//#import "ZhPMethod.h"

@interface QZStoreCollectViewController()<ReturnIndexViewDelegate>

{
    NSInteger currentPage;
    UIView *_nodataView;
}
@property (strong, nonatomic) ReturnIndexView *indexView;
@property (nonatomic ,strong) NSMutableArray  *dataSource;
@property (nonatomic, strong) UILabel *numLabel;   //数字角标
@property (nonatomic, strong) UILabel *redLabel;   //小红点
@property (assign, nonatomic) int passNumber;
@property (strong, nonatomic) UITableView *mainTable;

@end

@implementation QZStoreCollectViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"我的药房";
        currentPage = 1;
        self.dataSource = [NSMutableArray array];
        self.mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H) style:UITableViewStylePlain];
        self.mainTable.backgroundColor = RGBHex(qwColor11);
        self.mainTable.delegate=self;
        self.mainTable.dataSource=self;
        self.mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:self.mainTable];
        [self.mainTable addFooterWithTarget:self action:@selector(footerRereshing)];
        self.mainTable.footerPullToRefreshText = kWarning6;
        self.mainTable.footerReleaseToRefreshText = kWarning7;
        self.mainTable.footerRefreshingText = kWarning9;
        self.mainTable.footerNoDataText = kWarning44;
        UIView *footView = [[UIView alloc]init];
        footView.backgroundColor = RGBHex(qwColor11);
        self.mainTable.tableFooterView = footView;

    }
    return self;
}


- (void)refreshData{
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.passNumber = [QWGLOBALMANAGER updateRedPoint];
//    [self setUpRightItem];
    
    currentPage = 1;
    self.mainTable.footer.canLoadMore = YES;
    [self loadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

#pragma mark---------------------------------------------跳转到首页-----------------------------------------------

- (void)setUpRightItem
{
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -15;
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    
    //三个点button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(5, -2, 50, 40);
    [button setImage:[UIImage imageNamed:@"icon-unfold.PNG"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(returnIndex) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:button];
    
    //数字角标
    self.numLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 1, 18, 18)];
    self.numLabel.backgroundColor = RGBHex(qwColor3);
    self.numLabel.layer.cornerRadius = 9.0;
    self.numLabel.textColor = [UIColor whiteColor];
    self.numLabel.font = [UIFont systemFontOfSize:11];
    self.numLabel.textAlignment = NSTextAlignmentCenter;
    self.numLabel.layer.masksToBounds = YES;
    self.numLabel.text = @"10";
    self.numLabel.hidden = YES;
    [rightView addSubview:self.numLabel];
    
    //小红点
    self.redLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 10, 8, 8)];
    self.redLabel.backgroundColor = RGBHex(qwColor3);
    self.redLabel.layer.cornerRadius = 4.0;
    self.redLabel.layer.masksToBounds = YES;
    self.redLabel.hidden = YES;
    [rightView addSubview:self.redLabel];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItems = @[fixed,rightItem];
    
    if (self.passNumber > 0)
    {
        //显示数字
        self.numLabel.hidden = NO;
        self.redLabel.hidden = YES;
        if (self.passNumber > 99) {
            self.passNumber = 99;
        }
        self.numLabel.text = [NSString stringWithFormat:@"%d",self.passNumber];
        
    }else if (self.passNumber == 0)
    {
        //显示小红点
        self.numLabel.hidden = YES;
        self.redLabel.hidden = NO;
        
    }else if (self.passNumber < 0)
    {
        //全部隐藏
        self.numLabel.hidden = YES;
        self.redLabel.hidden = YES;
    }

}
- (void)returnIndex
{
    self.indexView = [ReturnIndexView sharedManagerWithImage:@[@"ic_img_notice",@"icon home.PNG"] title:@[@"消息",@"首页"] passValue:self.passNumber];
    self.indexView.delegate = self;
    [self.indexView show];
}
- (void)RetunIndexView:(ReturnIndexView *)ReturnIndexView didSelectedIndex:(NSIndexPath *)indexPath
{
    [self.indexView hide];
    
    if (indexPath.row == 0)
    {
        if(!QWGLOBALMANAGER.loginStatus) {
            LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
            loginViewController.isPresentType = YES;
            [self presentViewController:navgationController animated:YES completion:NULL];
            return;
        }
        
        MessageBoxListViewController *vcMsgBoxList = [[UIStoryboard storyboardWithName:@"MessageBoxListViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MessageBoxListViewController"];
        
        vcMsgBoxList.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vcMsgBoxList animated:YES];
        
    }else if (indexPath.row == 1)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self performSelector:@selector(delayPopToHome) withObject:nil afterDelay:0.01];
    }

}
- (void)delayPopToHome
{
    [[QWGlobalManager sharedInstance].tabBar setSelectedIndex:0];
}
#pragma mark---------------------------------------------跳转到首页-----------------------------------------------


- (void)viewInfoClickAction:(id)sender
{
    if (QWGLOBALMANAGER.currentNetWork != kNotReachable){
        
        [self removeInfoView];
        currentPage = 1;
        [self loadData];
    }
}

#pragma mark - 获取我关注的药房列表数据
- (void)loadData
{
    if(QWGLOBALMANAGER.currentNetWork == kNotReachable){

            [self showInfoView:kWarning12 image:@"网络信号icon.png"];
    }else{
        [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
            FavoriteModelR *modelR = [[FavoriteModelR alloc] init];
            modelR.token = QWGLOBALMANAGER.configure.userToken;
            modelR.lng = [NSString stringWithFormat:@"%f",mapInfoModel.location.coordinate.longitude];
            modelR.lat = [NSString stringWithFormat:@"%f",mapInfoModel.location.coordinate.latitude];
            modelR.page =[NSString stringWithFormat:@"%@",@(currentPage)];
            modelR.pageSize =[NSString stringWithFormat:@"%@",@(PAGE_ROW_NUM)];
            
            [ConsultStore CollectedBranchList:modelR success:^(id obj) {
                
                MicroMallBranchListVo *model = obj;
                
                if (model.branchs.count > 0) {
                    if(currentPage==1){
                        [self.dataSource removeAllObjects];
                    }
                    [self.dataSource addObjectsFromArray:model.branchs];
                    [self.mainTable reloadData];
                }else if(currentPage==1){
                    [self showInfoView:@"您当前暂未关注药房" image:@"icon_nopharmacy_default"];
                }else{
                    self.mainTable.footer.canLoadMore = NO;
                }
                [self.mainTable footerEndRefreshing];
                
                NSString *hasContent;
                if (_dataSource.count > 0) {
                    hasContent = @"有内容";
                }else {
                    hasContent = @"无内容";
                }
                NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
                tdParams[@"是否有内容"]=hasContent;
                [QWGLOBALMANAGER statisticsEventId:@"x_wd_gzyf" withLable:@"关注药房" withParams:tdParams];
                
            } failure:^(HttpException *e) {
                if (e.errorCode != -999) {
                    if(e.errorCode == -1001){
                        [self showInfoView:kWarning215N26 image:@"icon_no result_search"];
                    }else{
                        [self showInfoView:kWarning39 image:@"icon_no result_search"];
                    }
                }
                [self.mainTable footerEndRefreshing];
            }];
        }];
    }
}

- (void)footerRereshing
{
    HttpClientMgr.progressEnabled = NO;
    currentPage ++ ;
    [self loadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CollectBranchTableViewCell getCellHeight:nil];
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ConsultPharmacyIdentifier = @"CollectBranchTableViewCell";
    CollectBranchTableViewCell *cell = (CollectBranchTableViewCell *)[atableView dequeueReusableCellWithIdentifier:ConsultPharmacyIdentifier];
    if(cell == nil){
        UINib *nib = [UINib nibWithNibName:@"CollectBranchTableViewCell" bundle:nil];
        [atableView registerNib:nib forCellReuseIdentifier:ConsultPharmacyIdentifier];
        cell = (CollectBranchTableViewCell *)[atableView dequeueReusableCellWithIdentifier:ConsultPharmacyIdentifier];
        
    }
    
    MicroMallBranchVo *model = self.dataSource[indexPath.row];

    [cell setCollectCell:model];
    
    return cell;
}



//////////滑动删除//////////

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"取消关注";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([QWGlobalManager sharedInstance].currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:kWarning12 duration:DURATION_SHORT];
        return;
    }
    
    MicroMallBranchVo *model = self.dataSource[indexPath.row];

    [ConsultStore CancelCollectBranch:model.branchId success:^(BaseAPIModel *model) {
        
        if ([model.apiStatus intValue] == 0) {//收藏成功
            [self showSuccess:kWarning20];
            [self.dataSource removeObject:model];
            [self.mainTable beginUpdates];
            [self.mainTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.mainTable endUpdates];
            
        }else{//收藏当前对象失败
            [SVProgressHUD showErrorWithStatus:@"取消关注失败" duration:DURATION_SHORT];
        }
        
    } failure:^(HttpException *e) {
        
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [QWGLOBALMANAGER statisticsEventId:@"我的_我的药房_点击药房列表" withLable:nil withParams:nil];
    
    MicroMallBranchVo *model = self.dataSource[indexPath.row];
    
    PharmacySotreViewController *VC = [[PharmacySotreViewController alloc]init];
    VC.branchId = model.branchId;
    [self.navigationController pushViewController:VC  animated:YES];
}

//- (void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj{
//    if (NotiWhetherHaveNewMessage == type) {
//        
//        NSString *str = data;
//        self.passNumber = [str integerValue];
//        self.indexView.passValue = self.passNumber;
//        [self.indexView.tableView reloadData];
//        if (self.passNumber > 0)
//        {
//            //显示数字
//            self.numLabel.hidden = NO;
//            self.redLabel.hidden = YES;
//            if (self.passNumber > 99) {
//                self.passNumber = 99;
//            }
//            self.numLabel.text = [NSString stringWithFormat:@"%d",self.passNumber];
//            
//        }else if (self.passNumber == 0)
//        {
//            //显示小红点
//            self.numLabel.hidden = YES;
//            self.redLabel.hidden = NO;
//            
//        }else if (self.passNumber < 0)
//        {
//            //全部隐藏
//            self.numLabel.hidden = YES;
//            self.redLabel.hidden = YES;
//        }
//    }
//}


@end
