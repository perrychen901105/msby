//
//  AddNewDiseaseSubscriptionViewController.m
//  wenyao
//
//  Created by Pan@QW on 14-9-25.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "AddNewDiseaseSubscriptionViewController.h"
#import "AddNewDiseaseSubscriptionTableViewCell.h"
#import "SVProgressHUD.h"
//#import "MBProgressHUD+Add.h"

#import "css.h"
#import "QWGlobalManager.h"

@interface AddNewDiseaseSubscriptionViewController ()
{
    NSMutableArray              *dataSource;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrAddedDisease;
@end

@implementation AddNewDiseaseSubscriptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    dataSource = [NSMutableArray arrayWithCapacity:20];
    self.arrAddedDisease = [[NSMutableArray alloc] initWithCapacity:10];
    self.title = @"添加慢病订阅";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self setupTableView];
}

- (void)loadDiseaseListFromLocal
{
    //jxb
    //dataSource = [APPDelegate.dataBase queryDiseaseList];
    [self.tableView reloadData];
}

- (void)cacheDiseaseList
{
//jxb
//    [APPDelegate.dataBase deleteAllDiseaseList];
//    for (NSDictionary *dicDisease in dataSource) {
//        [APPDelegate.dataBase updateDiseaseListWithAttentionId:dicDisease[@"attentionId"] name:dicDisease[@"name"] selected:[dicDisease[@"selected"] boolValue]];
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [dataSource removeAllObjects];
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [self loadDiseaseListFromLocal];
    } else {
        [self queryAddList];
    }
    
}

- (void)queryAddList
{
    if([dataSource count] == 0)
    {
//        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
//        [[HTTPRequestManager sharedInstance] queryAttentionList:setting completion:^(id resultObj) {
//            if([resultObj[@"result"] isEqualToString:@"OK"]){
//                NSArray *array = resultObj[@"body"][@"data"];
//                for(NSDictionary *dict in array)
//                {
//                    NSArray *childList = dict[@"childList"];
//                    for(NSDictionary *dict in childList) {
//                        NSMutableDictionary *mutableDict = [dict mutableCopy];
//                        mutableDict[@"selected"] = @"0";
//                        [dataSource addObject:mutableDict];
//                    }
//                }
//                NSMutableDictionary *setting = [NSMutableDictionary dictionary];
//                setting[@"token"] = APPDelegate.configureList[APP_USER_TOKEN];
//                setting[@"status"] = @"3";
//                setting[@"currPage"] = @"1";
//                setting[@"pageSize"] = @"100";
//                [[HTTPRequestManager sharedInstance] getChronicDiseaseItemList:setting completion:^(id resultObj) {
//                    if([resultObj[@"result"] isEqualToString:@"OK"]) {
//                        NSArray *array = resultObj[@"body"][@"data"];
//                        self.arrAddedDisease = [array mutableCopy];
//                        for(NSDictionary *dict in array)
//                        {
//                            NSString *diseaseId = dict[@"diseaseId"];
//                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"attentionId == %@",diseaseId];
//                            NSArray *array = [dataSource filteredArrayUsingPredicate:predicate];
//                            if(array.count) {
//                                array[0][@"selected"] = @"1";
//                            }
//                        }
//                        [self cacheDiseaseList];
//                        [self.tableView reloadData];
//                    }
//                } failure:NULL];
//            }
//        } failure:NULL];
    }
}

//- (void)setupTableView
//{
//    CGRect rect = self.view.frame;
//    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    self.tableView.separatorColor = APP_SEPARATE_COLOR;
//    [self.tableView setBackgroundColor:[UIColor clearColor]];
//    self.tableView.rowHeight = 50.0f;
//    [self.view addSubview:self.tableView];
//}

#pragma mark -
#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *AddNewDiseaseSubscriptionTableViewCellIdentifier = @"addDiseaseSubscriptionIdentifier";
    AddNewDiseaseSubscriptionTableViewCell *cell = (AddNewDiseaseSubscriptionTableViewCell *)[atableView dequeueReusableCellWithIdentifier:AddNewDiseaseSubscriptionTableViewCellIdentifier];
    if(cell == nil)
    {
        UINib *nib = [UINib nibWithNibName:@"AddNewDiseaseSubscriptionTableViewCell" bundle:nil];
        [atableView registerNib:nib forCellReuseIdentifier:AddNewDiseaseSubscriptionTableViewCellIdentifier];
        cell = (AddNewDiseaseSubscriptionTableViewCell *)[atableView dequeueReusableCellWithIdentifier:AddNewDiseaseSubscriptionTableViewCellIdentifier];
        
    }
    
    NSDictionary *dict = dataSource[indexPath.row];
    cell.titleLabel.text = dict[@"name"];
    if([dict[@"selected"] isEqualToString:@"1"]) {
        //选中
        cell.selectedIcon.image = [UIImage imageNamed:@"健康资讯_慢病订阅icon_已订阅.png"];
    }else{
        //未选中
        cell.selectedIcon.image = [UIImage imageNamed:@"健康资讯_慢病订阅icon.png"];
    }
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(cell.titleLabel.frame.origin.x, 49.5, APP_W - cell.titleLabel.frame.origin.x, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:line];
    
    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    
//    __block NSMutableDictionary *dict = dataSource[indexPath.row];
//    if([dict[@"selected"] isEqualToString:@"0"])
//    {
//        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
//        setting[@"token"] = APPDelegate.configureList[APP_USER_TOKEN];
//        setting[@"attentionId"] = dict[@"attentionId"];
//        
////        [MBProgressHUD showMessag:@"正在添加中..." toView:nil];
//        [SVProgressHUD showSuccessWithStatus:@"添加成功!" duration:0.8f];
//        dict[@"selected"] = @"1";
//        [self.tableView reloadData];
//        __weak AddNewDiseaseSubscriptionViewController *weakSelf = self;
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [[HTTPRequestManager sharedInstance] saveDrugGuideItem:setting completion:^(id resultObj) {
//                if([resultObj[@"result"] isEqualToString:@"OK"]) {
//                    
//                    NSMutableDictionary *dicDisease = [@{@"diseaseId":dict[@"attentionId"],
//                                                         @"diseaseName":dict[@"name"],
//                                                         @"diseaseParentName":@"",
//                                                         @"id":resultObj[@"body"][@"msgDrugGuideId"]
//                                                         } mutableCopy];
//                    [weakSelf.arrAddedDisease addObject:dicDisease];
////                    [MBProgressHUD hideHUDForView:nil animated:NO];
//                    
//                    //jxb
//                    //[APPDelegate.dataBase updateDiseaseItemWithAttentionId:dict[@"attentionId"] isSelected:1];
//                    
//                    //                NSMutableDictionary *setting = [NSMutableDictionary dictionary];
//                    //                setting[@"token"] = app.configureList[APP_USER_TOKEN];
//                    //                setting[@"status"] = @"3";
//                    //                setting[@"currPage"] = @"1";
//                    //                setting[@"pageSize"] = @"100";
//                    //                [[HTTPRequestManager sharedInstance] getChronicDiseaseItemList:setting completion:^(id resultObj) {
//                    //                    if([resultObj[@"result"] isEqualToString:@"OK"]) {
//                    //                        NSArray *array = resultObj[@"body"][@"data"];
//                    //                        self.arrAddedDisease = [array mutableCopy];
//                    //                        for(NSDictionary *dict in array)
//                    //                        {
//                    //                            NSString *diseaseId = dict[@"diseaseId"];
//                    //                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"attentionId == %@",diseaseId];
//                    //                            NSArray *array = [dataSource filteredArrayUsingPredicate:predicate];
//                    //                            if(array.count) {
//                    //                                array[0][@"selected"] = @"1";
//                    //                            }
//                    //                        }
//                    //                        [self.tableView reloadData];
//                    //                    }
//                    //                } failure:NULL];
//                
//                    [weakSelf.diseaseSubscriptionViewController queryDrugGuideList:YES];
//                }else{
//                    dict[@"selected"] = @"0";
//                    [MBProgressHUD hideHUDForView:nil animated:NO];
//                    [SVProgressHUD showErrorWithStatus:@"添加失败!" duration:0.8f];
//                }
//                [self.tableView reloadData];
//            } failure:^(NSError *error) {
//                [MBProgressHUD hideHUDForView:nil animated:NO];
//            }];
//        });
//    } else {
//        // 取消订阅
//        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
//        setting[@"token"] = APPDelegate.configureList[APP_USER_TOKEN];
//        NSDictionary *dicDelete = @{};
//        for (NSDictionary *dicDisease in self.arrAddedDisease) {
//            NSString *strAttention = dict[@"attentionId"];
//            if ([strAttention isEqualToString:dicDisease[@"diseaseId"]]) {
//                dicDelete = dicDisease;
//                break;
//            }
//        }
//        if (dicDelete[@"id"]) {
//            setting[@"drugGuideId"] = dicDelete[@"id"];
//        } else {
//            setting[@"drugGuideId"] = dict[@"attentionId"];
//        }
//        
//        [MBProgressHUD showMessag:@"取消订阅中..." toView:nil];
////jxb
////        __weak AddNewDiseaseSubscriptionViewController *weakSelf = self;
////        [[HTTPRequestManager sharedInstance] deleteMsgDrugGuide:setting completion:^(id resultObj) {
////            if([resultObj[@"result"] isEqualToString:@"OK"]){
////                dict[@"selected"] = @"0";
////                [weakSelf.arrAddedDisease removeObject:dicDelete];
////                [APPDelegate.dataBase updateDiseaseItemWithAttentionId:dict[@"attentionId"] isSelected:0];
////                [MBProgressHUD hideHUDForView:nil animated:NO];
////                [SVProgressHUD showSuccessWithStatus:@"取消成功!" duration:0.8f];
////                [APPDelegate.dataBase deleteDiseaseSubWithGuideId:setting[@"drugGuideId"]];
////                [weakSelf.tableView reloadData];
//////                [weakSelf.diseaseSubscriptionViewController queryDrugGuideList:YES];
////            } else {
////                [MBProgressHUD hideHUDForView:nil animated:NO];
////                [SVProgressHUD showErrorWithStatus:@"取消失败!" duration:0.8f];
////            }
////        } failure:^(NSError *error) {
////            [MBProgressHUD hideHUDForView:nil animated:NO];
////        }];
//    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
