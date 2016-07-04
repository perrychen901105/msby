//
//  CollectBranchListViewController.m
//  APP
//  切换药房-我的药房
//  Created by 李坚 on 16/6/13.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "CollectBranchListViewController.h"
#import "CollectBranchTableViewCell.h"
#import "LoginViewController.h"

#import "ConsultStore.h"

#define NotLoginMessage @"请先登录才可查看"
#define NoBranchList    @"您当前暂无关注药房"

static NSString *const ChooseBranchCellIdentifier = @"CollectBranchTableViewCell";

@interface CollectBranchListViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
    int currentPage;
    
}

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation CollectBranchListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataArr = [NSMutableArray new];
    currentPage = 1;
    _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H - NAV_H - 35.0f)];
    [_mainTableView registerNib:[UINib nibWithNibName:ChooseBranchCellIdentifier bundle:nil] forCellReuseIdentifier:ChooseBranchCellIdentifier];
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_mainTableView addFooterWithTarget:self action:@selector(loadMoreData)];
    [self.view addSubview:_mainTableView];
    
    if(QWGLOBALMANAGER.loginStatus){
        [self requestMyCollectBranchList];
    }else{
        [self showLoginView:NotLoginMessage image:@"icon_notlogin_default"action:@selector(pushLoginView)];
    }
}

- (void)loadMoreData{
    
    currentPage ++;
    [self requestMyCollectBranchList];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestMyCollectBranchList
{
    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        
        FavoriteModelR *modelR = [[FavoriteModelR alloc] init];
        modelR.token = QWGLOBALMANAGER.configure.userToken;
        modelR.page =[NSString stringWithFormat:@"%@",@(currentPage)];
        modelR.pageSize =[NSString stringWithFormat:@"%@",@(PAGE_ROW_NUM)];
        modelR.lng = [NSString stringWithFormat:@"%f",mapInfoModel.location.coordinate.longitude];
        modelR.lat = [NSString stringWithFormat:@"%f",mapInfoModel.location.coordinate.latitude];
    
        [ConsultStore CollectedBranchList:modelR success:^(id obj) {
            
            
            MicroMallBranchListVo *model=(MicroMallBranchListVo *)obj;
            if (model.branchs.count > 0) {
                if(currentPage==1){
                    [self removeInfoView];
                    [self.dataArr removeAllObjects];
                }
                [self.dataArr addObjectsFromArray:model.branchs];
                [self.mainTableView reloadData];
                
            }else if(currentPage == 1){
                
                [self showInfoView:NoBranchList image:@"icon_nopharmacy_default"];
            }else{
                [self.mainTableView footerEndRefreshing];
                self.mainTableView.footer.canLoadMore = NO;
            }
            [self.mainTableView footerEndRefreshing];
        }failure:^(HttpException *e){
            if (e.errorCode != -999) {
                if(e.errorCode == -1001){
                    [self showInfoView:kWarning215N26 image:@"icon_no result_search"];
                }else{
                    [self showInfoView:kWarning39 image:@"icon_no result_search"];
                }
            }
            [self.mainTableView footerEndRefreshing];
        }];
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CollectBranchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChooseBranchCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    MicroMallBranchVo *model = _dataArr[indexPath.row];
    
    [cell setCollectCell:model];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [CollectBranchTableViewCell getCellHeight:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [QWGLOBALMANAGER statisticsEventId:@"切换药房_点击药房列表" withLable:nil withParams:nil];

    [self.navigation popToRootViewControllerAnimated:NO];
    MicroMallBranchVo *model = _dataArr[indexPath.row];
    [self.navigation popToRootViewControllerAnimated:NO];
    [QWGLOBALMANAGER setMapBranchId:model.branchId branchName:model.branchName];
    
    //    self.pageType，1.来自首页 2.来自分类
    if(self.pageType == 1){
        [QWGLOBALMANAGER postNotif:NotifChangeBranchFromHomePage data:model.branchName object:nil];
    }
    if(self.pageType == 2){
        [QWGLOBALMANAGER postNotif:NotifChangeBranchFromGoodList data:model.branchName object:nil];
    }
}

- (void)pushLoginView{
    
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginViewController.hidesBottomBarWhenPushed = YES;
    __weak typeof (self) weakSelf = self;
    loginViewController.loginSuccessBlock = ^(void){
        currentPage = 1;
        self.mainTableView.footer.canLoadMore = YES;
        [weakSelf requestMyCollectBranchList];
    };
    [self.navigation pushViewController:loginViewController animated:YES];
}

@end
