//
//  PhrmacyMoreDrugsViewController.m
//  wenyao
//
//  Created by 李坚 on 15/1/22.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "PhrmacyMoreDrugsViewController.h"
#import "Constant.h"
#import "MJRefresh.h"
#import "MedicineSellListCell.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "Drug.h"
#import "DrugModel.h"
#import "DrugModelR.h"
#import "ReturnIndexView.h"
#import "MessageBoxListViewController.h"
#import "LoginViewController.h"
#import "WebDirectViewController.h"

@interface PhrmacyMoreDrugsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    int currentPage;
    NSMutableArray *sellList;
}
@property (nonatomic, strong) UILabel *numLabel;   //数字角标
@property (nonatomic, strong) UILabel *redLabel;   //小红点
@property (nonatomic, strong) ReturnIndexView *indexView;
@property (assign, nonatomic) int passNumber;


@end

@implementation PhrmacyMoreDrugsViewController


- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"区域畅销商品";
    
    [self.tableMain setFrame:CGRectMake(0, 0, APP_W, APP_H - NAV_H)];
    self.tableMain.delegate = self;
    self.tableMain.dataSource = self;
    [self.tableMain addStaticImageHeader];
    [self.view addSubview:self.tableMain];
    currentPage = 1;
    sellList = [NSMutableArray array];
    [self loadData];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.passNumber = [QWGLOBALMANAGER updateRedPoint];
//    [self setUpRightItem];
}

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
    [QWGLOBALMANAGER.tabBar setSelectedIndex:0];
}


- (void)loadData{
    
    SellWellProductsR *modelR = [SellWellProductsR new];
    MapInfoModel *mapInfoModel = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
    if(QWGLOBALMANAGER.currentNetWork==kNotReachable){
        [self showInfoView:kWarning12 image:@"网络信号icon.png"];
        return;
    }
    if(mapInfoModel)
    {
        if(!StrIsEmpty(mapInfoModel.city))
        {
            modelR.city = mapInfoModel.city;
        }
        else
        {
            modelR.city = @"苏州市";
        }
        
    }
    else
    {
        modelR.city = @"苏州市";
    }
    
    modelR.currPage = @(currentPage);
    modelR.pageSize = @(PAGE_ROW_NUM);
    
    [Drug drugSellListWithParam:modelR Success:^(id DFModel) {
        
        [self.tableMain footerEndRefreshing];
        DrugSellWellProductsModel *productsModel = (DrugSellWellProductsModel *)DFModel;
        NSArray *list = productsModel.list;
        NSInteger count = [productsModel.totalRecords integerValue];
        if (list.count > 0) {
            [sellList addObjectsFromArray:productsModel.list];
            [self.tableMain reloadData];
            currentPage ++;
        }
        if(count <= 10){
            [self.tableMain setFooterHidden:YES];
        }else{
            [self.tableMain setFooterHidden:NO];
        }
    } failure:^(HttpException *e) {
        DebugLog(@"%@",e);
        [self.tableMain footerEndRefreshing];
    }];
}

- (void)footerRereshing{
    HttpClientMgr.progressEnabled = NO;
    [self loadData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return sellList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [MedicineSellListCell getCellHeight:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    MedicineSellListCell * cell = (MedicineSellListCell *)[self.tableMain dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MedicineSellListCell" owner:self options:nil][0];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 95 - 0.5, APP_W, 0.5)];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        line.backgroundColor = RGBHex(qwColor10);
        [cell addSubview:line];
    }
    DrugSellWellProductsFactoryModel *factoryModel = sellList[indexPath.row];
    cell.indexPath = indexPath;
    [cell setCell:factoryModel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DrugSellWellProductsFactoryModel *factoryModel = sellList[indexPath.row];

    [self pushToDrugDetailWithDrugID:factoryModel.proId promotionId:@""];
}

- (void)pushToDrugDetailWithDrugID:(NSString *)drugId promotionId:(NSString *)promotionID{
    
    WebDirectViewController *vcWebMedicine = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
    MapInfoModel *modelMap = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
    WebDrugDetailModel *modelDrug = [WebDrugDetailModel new];
    modelDrug.modelMap = modelMap;
    modelDrug.proDrugID = drugId;
    modelDrug.promotionID = promotionID;
//    modelDrug.showDrug = @"0";
    WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
//    modelLocal.title = @"药品详情";
    modelLocal.modelDrug = modelDrug;
    modelLocal.typeLocalWeb = WebPageToWebTypeMedicine;
    [vcWebMedicine setWVWithLocalModel:modelLocal];
    [self.navigationController pushViewController:vcWebMedicine animated:YES];
}



- (void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj{
    if (NotiWhetherHaveNewMessage == type) {
        
        NSString *str = data;
        self.passNumber = [str integerValue];
        self.indexView.passValue = self.passNumber;
        [self.indexView.tableView reloadData];
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
}


@end
