//
//  ChainBranchListViewController.m
//  APP
//  切换药房-连锁药房
//  Created by 李坚 on 16/6/13.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "ChainBranchListViewController.h"
#import "ChooseBranchTableViewCell.h"
#import "ConsultStore.h"

static NSString *const ChooseBranchCellIdentifier = @"ChooseBranchTableViewCell";

@interface ChainBranchListViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
    int currPage;
}

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation ChainBranchListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataArr = [NSMutableArray new];
    currPage = 1;
    _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H - NAV_H - 35.0f)];
    [_mainTableView registerNib:[UINib nibWithNibName:ChooseBranchCellIdentifier bundle:nil] forCellReuseIdentifier:ChooseBranchCellIdentifier];
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_mainTableView];
    [_mainTableView addFooterWithTarget:self action:@selector(loadMoreData)];
    
    [self loadChainBranchList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMoreData{
    
    currPage ++;
    [self loadChainBranchList];
}

- (void)loadChainBranchList{
    
    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        
        NearByStoreModelR *modelR = [NearByStoreModelR new];
        
        modelR.page = @(currPage);
        modelR.pageSize = @(10);
        modelR.type = @(0);
        modelR.nearest = 1;
        modelR.branchId = [QWGLOBALMANAGER getMapBranchId];
        modelR.city = mapInfoModel.city;
        modelR.longitude = @([QWGLOBALMANAGER QWGetLocation].location.coordinate.longitude);
        modelR.latitude = @([QWGLOBALMANAGER QWGetLocation].location.coordinate.latitude);
        
        [ConsultStore ChainBranchs:modelR success:^(MicroMallBranchListVo *model) {
            
            if([model.apiStatus intValue] == 0){
                
                if(model.branchs.count > 0){
                    
                    [self removeInfoView];
                    if(currPage == 1){
                        [_dataArr removeAllObjects];
                    }else{
                        [_mainTableView.footer endRefreshing];
                    }
                    [_dataArr addObjectsFromArray:model.branchs];
                    [_mainTableView reloadData];
                }else{
                    if(currPage == 1){
                        [self showInfoView:@"没有查到您想要的结果" image:@"icon_no result_search"];
                    }else{
                        [_mainTableView.footer setCanLoadMore:NO];
                    }
                }
                
            }else{
                [self showInfoView:@"没有查到您想要的结果" image:@"icon_no result_search"];
            }
            
            [_mainTableView.footer endRefreshing];
            
        } failure:^(HttpException *e) {
            [self showInfoView:@"没有查到您想要的结果" image:@"icon_no result_search"];
        }];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChooseBranchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChooseBranchCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    MicroMallBranchVo *model = _dataArr[indexPath.row];
    
    [cell setCell:model];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [ChooseBranchTableViewCell getCellHeight:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [QWGLOBALMANAGER statisticsEventId:@"切换药房_点击药房列表" withLable:nil withParams:nil];

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

@end
