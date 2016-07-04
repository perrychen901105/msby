//
//  BodyParterTableViewController.m
//  APP
//
//  Created by qwfy0006 on 15/3/12.
//  Copyright (c) 2015年 carret. All rights reserved.
//

#import "BodyParterTableViewController.h"
#import "Constant.h"
#import "SymptomViewController.h"
#import "SVProgressHUD.h"

#import "SpmApi.h"
#import "SpmModel.h"
#import "SpmModelR.h"
#import "BodyPartCell.h"

@interface BodyParterTableViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIView * _nodataView;
}
@property (nonatomic, strong) NSMutableArray        *partList;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation BodyParterTableViewController


- (void)dealloc
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTableView];
    [self secondViewDidLoad];
    
}

- (void)setupTableView
{
    CGRect rect = self.view.frame;
    rect.size.height -=  64 ;
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.allowsSelection = YES;
    [self.tableView setBackgroundColor:RGBHex(qwColor11)];
    [self.view addSubview:self.tableView];
}
- (void)secondViewDidLoad{
    
    self.partList = [NSMutableArray arrayWithCapacity:15];
    
    if([self.partList count] == 0)
    {
        [self getDataFromServer];
    }
}


- (void)backToPreviousController:(id)sender
{
    if(self.containerViewController) {
        [self.containerViewController.navigationController popViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.partList.count == 0) {
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.partList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *bodyTabelIdentifier = @"BodyPartCell";
    BodyPartCell *cell = [tableView dequeueReusableCellWithIdentifier:bodyTabelIdentifier];
    if(cell == nil) {
        cell = [[BodyPartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bodyTabelIdentifier];
    }
    
    SpmBodyHeadModel *model = self.partList[indexPath.row];
    [cell setCell:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [QWGLOBALMANAGER statisticsEventId:@"x_zz_1" withLable:@"部位查找" withParams:nil];
    SpmBodyHeadModel *model = self.partList[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SymptomViewController * svc = [[SymptomViewController alloc]init];
    svc.spmCode = model.bodyCode;
    svc.requestType = bodySym;
    svc.requsetDic = self.soureDict;
    svc.title = model.name;
    
    svc.containerViewController = self.containerViewController;
    
    if(self.containerViewController) {
        [self.containerViewController.navigationController pushViewController:svc animated:YES];
    }else{
        [self.navigationController pushViewController:svc animated:YES];
    }
}


- (void)getDataFromServer
{
    
    //设置主键
    NSString * key = [NSString stringWithFormat:@"%@",@"TophealthNorm"];
    
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        
        NSArray *arr = [SpmBodyHeadModel getArrayFromDBWithWhere:nil];
        if(arr.count>0){
            [self.partList removeAllObjects];
            [self.partList addObjectsFromArray:arr];
        }else{
            [self showInfoView:kWarning12 image:@"网络信号icon"];
            return;
        }

    }else
    {
        [self removeInfoView];
        SpmBodyHeadModelR *model = [SpmBodyHeadModelR new];
        model.sex = self.soureDict[@"sex"];
        model.population = self.soureDict[@"population"];
        model.position = self.soureDict[@"position"];
        model.bodyCode = self.soureDict[@"bodyCode"];
        
        
        [SpmApi QuerySpmBodyWithParams:model success:^(id obj) {
            
            [self.partList removeAllObjects];
            SpmListByBodyPage *array = (SpmListByBodyPage *)obj;
            if([array.list count] > 0) {
                [self removeInfoView];
                for(SpmBodyHeadModel *model in array.list){
                    model.topKey=[NSString stringWithFormat:@"%@_%@",key,model.bodyCode];
                    [SpmBodyHeadModel saveObjToDB:model];
                }
                [self.partList addObjectsFromArray:array.list];
            }else{
                [self showInfoView:kWarning12 image:@"网络信号icon"];
            }
            [self.tableView reloadData];
            
            
        } failure:^(HttpException *e) {
            if(e.errorCode!=-999){
                if(e.errorCode == -1001){
                    [self showInfoView:kWarning215N26 image:@"ic_img_fail"];
                }else{
                    [self showInfoView:kWarning39 image:@"ic_img_fail"];
                }
                
            }
            return;
        }];

    }
    
}

- (void)viewInfoClickAction:(id)sender
{
    if (QWGLOBALMANAGER.currentNetWork != kNotReachable) {
        [self removeInfoView];
        [self getDataFromServer];
    }
}

@end
