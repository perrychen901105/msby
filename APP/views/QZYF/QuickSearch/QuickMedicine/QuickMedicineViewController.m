//
//  QuickMedicineViewController.m
//  wenyao
//
//  Created by Meng on 14-9-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "QuickMedicineViewController.h"
#import "QuickMedicineTableViewCell.h"
#import "MedicineSubViewController.h"
#import "Drug.h"
#import "FinderSearchViewController.h"
#import "LoginViewController.h"
#import "PhrmacyMoreDrugsViewController.h"

@interface QuickMedicineViewController ()
{
    NSArray * imageArray;
}
@property (nonatomic ,strong) NSMutableArray * dataScorce;
@property (nonatomic ,strong) __block NSMutableArray * data;

@property (nonatomic ,assign) NSInteger selectedIndex;
@property (nonatomic ,assign) NSString * selectedName;


@end

@implementation QuickMedicineViewController

- (id)init{
    if (self = [super init]) {
        self.tableView=[[UITableView alloc]initWithFrame:self.view.bounds];
        self.tableView.delegate=self;
        self.tableView.dataSource=self;
        
        self.tableView.frame = CGRectMake(0, 0, APP_W, APP_H-NAV_H);
        self.tableView.rowHeight = 70;
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.tableView addStaticImageHeader];
        self.dataScorce = [NSMutableArray array];
        self.data = [NSMutableArray array];
        imageArray = @[@"中西药品.png",@"中成药.png",@"中药饮片.png",@"汤料花茶.png",@"营养保健.png",@"医疗机械及相关.png",@"个人护理.png",@"按人群查找.png",@"热卖商品.png",@"区域畅销商品.png"];
        
        [self.view addSubview:self.tableView];
    }
    return self;
}



#pragma ----index--------------------------------------
-(void)setRightItems{
    UIView *ypBarItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 55)];
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(28, 0, 55, 55)];
    [searchButton setImage:[UIImage imageNamed:@"icon_navigation_search_common"]  forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchDown];
    [ypBarItems addSubview:searchButton];
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    fixed.width = -20;
//    self.navigationItem.rightBarButtonItems = @[fixed,[[UIBarButtonItem alloc] initWithCustomView:ypBarItems]];
    fixed.width = -48;
    self.navigationItem.rightBarButtonItems = @[fixed,[[UIBarButtonItem alloc] initWithCustomView:ypBarItems]];
    

}


- (void)viewDidLoad{
    [super viewDidLoad];
}
-(void)popVCAction:(id)sender {
    [super popVCAction:sender];
    [QWGLOBALMANAGER statisticsEventId:@"x_yp_1_fh" withLable:@"药品" withParams:nil];
}

- (void)getCachedAllMedicineList:(NSString *)key
{
    //本地缓存读取功能
    QueryProductClassModel* page = [QueryProductClassModel getObjFromDBWithKey:key];
    if(page==nil){
        [self showInfoView:kWarning12 image:@"网络信号icon.png"];
        return;
    }
    [self.data  addObjectsFromArray:page.list];
    QueryProductFirstModel *model = [[QueryProductFirstModel alloc] init];
    model.classDesc = @"区域畅销商品";
    model.classId = @"10";
    model.name = @"区域畅销商品";
    [self.data addObject:model];
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [self setRightItems];
    self.navigationItem.title = @"药品";
    if (self.data.count > 0) {
        return;
    }
    [super viewWillAppear:animated];
    
    QueryProductFirstModelR *queryProductFirstR= [QueryProductFirstModelR new];
    queryProductFirstR.currPage = @"1";
    queryProductFirstR.pageSize = @"0";

    
    
    NSString * key = [NSString stringWithFormat:@"medicine_%@",queryProductFirstR.currPage];
    
    if(QWGLOBALMANAGER.currentNetWork==kNotReachable){
        [self getCachedAllMedicineList:key];
        return;
    }else{
    [Drug queryProductFirstWithParam:queryProductFirstR Success:^(id DFUserModel) {
        QueryProductClassModel *queryProductClassModel = DFUserModel;
        self.dataScorce = (NSMutableArray *) queryProductClassModel.list;
        
        if (self.dataScorce.count >= 9) {
            NSRange range = NSMakeRange(0, 9);
            
            [self.data addObjectsFromArray:[self.dataScorce subarrayWithRange:range]];
            queryProductClassModel.medcineId = key;
        
            [QueryProductClassModel updateObjToDB:queryProductClassModel WithKey:queryProductClassModel.medcineId];
        }
        QueryProductFirstModel *model = [[QueryProductFirstModel alloc] init];
        model.classDesc = @"区域畅销商品";
        model.classId = @"10";
        model.name = @"区域畅销商品";
        [self.data addObject:model];
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
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.data.count > 0) {
        self.navigationItem.title = self.selectedName;
    }
}

- (void)rightBarButtonClick{
    FinderSearchViewController * searchViewController = [[FinderSearchViewController alloc] initWithNibName:@"FinderSearchViewController" bundle:nil];
    searchViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

#pragma mark ------UItableViewDelegate------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * cellIdentifier = @"cellIdentifier";
    QuickMedicineTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSBundle * bundle = [NSBundle mainBundle];
        NSArray * cellViews = [bundle loadNibNamed:@"QuickMedicineTableViewCell" owner:self options:nil];
        cell = [cellViews objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
    }//@"药品默认图片.png"
    QueryProductFirstModel *model = self.data[indexPath.row];
    
    cell.titleLabel.text = model.name;
    cell.subTitleLabel.text = model.classDesc;
    //[cell.headImageView setImageWithURL:[NSURL URLWithString:self.dataScorce[indexPath.row][@"imageUrl"]] placeholderImage:[UIImage imageNamed:imageArray[indexPath.row]]];
    [cell.headImageView setImage:[UIImage imageNamed:imageArray[[model.classId integerValue]-1]]];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(48, 62 - 0.5, APP_W - 48, 0.5)];
    line.backgroundColor = RGBHex(qwColor10);
    [cell addSubview:line];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    if(self.data.count == indexPath.row+1)
    {
        PhrmacyMoreDrugsViewController *moreDrugsView = [[PhrmacyMoreDrugsViewController alloc]init];
        [self.navigationController pushViewController:moreDrugsView animated:YES];
    }
    else
    {
        QueryProductFirstModel *model = self.data[indexPath.row];
        MedicineSubViewController * medicineSubViewController = [[MedicineSubViewController alloc]init];
        medicineSubViewController.title = model.name;
        medicineSubViewController.classId = model.classId;
        medicineSubViewController.requestType = RequestTypeMedicine;
        
        self.selectedName = model.name;
        [self.navigationController pushViewController:medicineSubViewController animated:YES];
        
        NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
        tdParams[@"点击内容"]= model.name;
        [QWGLOBALMANAGER statisticsEventId:@"x_yp_1" withLable:@"药品" withParams:tdParams];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
   
}

@end
