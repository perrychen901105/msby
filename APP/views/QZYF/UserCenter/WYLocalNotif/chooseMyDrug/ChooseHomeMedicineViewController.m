//
//  ChooseHomeMedicineViewController.m
//  wenyao
//
//  Created by garfield on 15/4/9.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "ChooseHomeMedicineViewController.h"
//#import "HTTPRequestManager.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "WYChooseMyDrugCell.h"
#import "AddNewMedicineViewController.h"

@interface ChooseHomeMedicineViewController ()
{
    NSMutableArray *arrData;
//    NSString *chooseID;
//    NSInteger chooseIndex;
    WYChooseMyDrugModel *chooseMode;
}
@end

@implementation ChooseHomeMedicineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self dataInit];
    
    [self queryMyBox];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    ((QWBaseNavigationController *)self.navigationController).canDragBack = NO;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ((QWBaseNavigationController *)self.navigationController).canDragBack = YES;
}

- (void)noData{
    self.tableMain.scrollEnabled=NO;
    [self showInfoView:kWarningN7 image:@"ic_img_fail"];
    [self.view sendSubviewToBack:self.vInfo];
}

- (void)noConnect{
    [self showInfoView:kWarning12 image:@"ic_img_fail"];
    self.tableMain.hidden=YES;
}

- (void)removeInfo{
    [self removeInfoView];
    self.tableMain.scrollEnabled=YES;
}
#pragma mark - 数据初始化
- (void)dataInit{
    self.title=@"选择我的用药";
}

- (void)queryMyBox
{
    QueryMyboxModelR *myBoxModelR = [[QueryMyboxModelR alloc] init];
    myBoxModelR.token = QWGLOBALMANAGER.configure.userToken;
    myBoxModelR.currPage = @"1";
    myBoxModelR.pageSize = @"0";
    
    
    [Box queryMyBoxWithParams:myBoxModelR success:^(id myBoxModelList) {
        NSArray *array = (NSArray *)myBoxModelList;
        if(array.count > 0)
        {
            [QueryMyBoxModel deleteAllObjFromDB];
            [QueryMyBoxModel saveObjToDBWithArray:array];
            
            [self removeInfo];
            
            chooseMode=nil;
            
            arrData=nil;
            arrData=[[NSMutableArray alloc]initWithCapacity:array.count];
            
            for (QueryMyBoxModel *mm in array) {
                WYChooseMyDrugModel *mode=[WYChooseMyDrugModel new];
                mode.productName=mm.productName;//dd[@"productName"];
                mode.productId=mm.proId;//dd[@"productId"];
                mode.intervalDay=mm.intervalDay;//dd[@"intervalDay"];
                mode.drugTag=mm.drugTag;//dd[@"drugTag"];
                mode.createTime=mm.createTime;//dd[@"createTime"];
                mode.boxId=mm.boxId;//dd[@"boxId"];
                
                if (chooseMode && [chooseMode.productId isEqualToString:mode.productId]) {
                    mode.chooseEnabled  = YES;
                }
                
                [arrData addObject:mode];
            }
            
            
            [self.tableMain reloadData];
            
        }else{
            [self noData];
        }
       
        
    } failure:^(HttpException *e) {
        [self loadMyBoxMedicineCache];
    }];
    
}




- (void)loadMyBoxMedicineCache
{
    NSArray *array = [QueryMyBoxModel getArrayFromDBWithWhere:nil];
    if(array.count > 0)
    {
//        [QueryMyBoxModel deleteAllObjFromDB];
//        [QueryMyBoxModel saveObjToDBWithArray:array];
        
        [self removeInfo];
        
        chooseMode=nil;
        
        arrData=nil;
        arrData=[[NSMutableArray alloc]initWithCapacity:array.count];
        
        for (QueryMyBoxModel *mm in array) {
            WYChooseMyDrugModel *mode=[WYChooseMyDrugModel new];
            mode.productName=mm.productName;//dd[@"productName"];
            mode.productId=mm.proId;//dd[@"productId"];
            mode.intervalDay=mm.intervalDay;//dd[@"intervalDay"];
            mode.drugTag=mm.drugTag;//dd[@"drugTag"];
            mode.createTime=mm.createTime;//dd[@"createTime"];
            mode.boxId=mm.boxId;//dd[@"boxId"];
            
            if (chooseMode && [chooseMode.productId isEqualToString:mode.productId]) {
                mode.chooseEnabled  = YES;
            }
            
            [arrData addObject:mode];
        }
        
        
        [self.tableMain reloadData];
        
    }else{

        [self noConnect];
    }
    
    
}

#pragma mark - UI
- (void)UIGlobal{
    [super UIGlobal];
    
//    [self naviRightBotton:@"提交" action:@selector(getDrugAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(getDrugAction:)];
    self.tableMain.backgroundColor=[UIColor clearColor];
    lblAddTTL.text=kAlert3;
    lblAddTTL.textColor=RGBHex(qwColor8);
    lblAddTTL.font=fontSystem(kFontS5);
    
    self.tableMain.footerHidden=YES;
}



#pragma mark - action
- (IBAction)viewInfoClickAction:(id)sender{
    [self queryMyBox];
}

- (IBAction)getDrugAction:(id)sender{
    if (chooseMode && chooseMode.chooseEnabled) {
        if (self.selectBlock){
            self.selectBlock(chooseMode);
        }
        [self popVCAction:nil];
    }
    else
        [self showError:kWarningN16];
}

- (IBAction)addNewAction:(id)sender{
    AddNewMedicineViewController *vc = [[UIStoryboard storyboardWithName:@"FamilyMedicineListViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"AddNewMedicineViewController"];
    vc.InsertNewPharmacy = ^(QueryMyBoxModel *myboxModel)
    {
        WYChooseMyDrugModel *mode=[WYChooseMyDrugModel new];
        mode.productName=myboxModel.productName;//dd[@"productName"];
        mode.productId=myboxModel.proId;//dd[@"productId"];
        mode.intervalDay=myboxModel.intervalDay;//dd[@"intervalDay"];
        mode.drugTag=myboxModel.drugTag;//dd[@"drugTag"];
        mode.createTime=myboxModel.createTime;//dd[@"createTime"];
        mode.boxId=myboxModel.boxId;//dd[@"boxId"];
        
        if (arrData==nil) {
            arrData=[NSMutableArray array];
        }
        
        [arrData insertObject:mode atIndex:0];
        [self.tableMain reloadData];
   
        [self removeInfo];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [WYChooseMyDrugCell getCellHeight:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    static NSString *tableID = @"WYChooseMyDrugCell";
    
    WYChooseMyDrugCell *cell = [tableView dequeueReusableCellWithIdentifier:tableID];
    cell.delegate=self;
    if (row<arrData.count)
    {
        [cell setCell:[arrData objectAtIndex:row]];
        return cell;
    }
    
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    if (row<arrData.count){
//        WYChooseMyDrugCell *cell = (WYChooseMyDrugCell *)[tableView cellForRowAtIndexPath:indexPath];
//        cell.btnChoose.selected=!cell.btnChoose.selected;
        
        WYChooseMyDrugModel *mode=[arrData objectAtIndex:row];
        
        mode.chooseEnabled=!mode.chooseEnabled;
        
        if (mode!=chooseMode && mode.chooseEnabled) {
            chooseMode.chooseEnabled=NO;
            chooseMode=mode;
        }
        [self.tableMain reloadData];
    }
}
@end