//
//  MyNewCouponQuanViewController.m
//  APP
//  我的优惠券详情
//  Created by caojing on 15/11/16.
//  Copyright © 2015年 carret. All rights reserved.
//


#import "MyCouponDetailViewController.h"
#import "Coupon.h"
#import "Promotion.h"
#import "CouponUseViewController.h"
#import "SVProgressHUD.h"
#import "MyCouponQuanViewController.h"
#import "LoginViewController.h"
#import "VFourCouponQuanTableViewCell.h"
#import "ChatViewController.h"
#import "swiftModule-swift.h"
#import "CouponSuitableTableViewCell.h"
#import "myConsultTableViewCell.h"
#import "CouponTicketDetailPlaceholderCell.h"
#import "CouponDetailCell.h"
#import "BranchCouponDetailView.h"
#import "APPDelegate.h"
#import "ChangeStoreAlertView.h"
#import "MedicineSearchResultViewController.h"
#import "MedicineDetailViewController.h"
#import "ChangeProductAlertView.h"
#import "PharmacySotreViewController.h"


static NSString * const BranchIdentifier = @"myConsultTableViewCell";
static NSString * const UITableViewIdentifier = @"UITableViewCell";
static NSString * const VFourCouponQuanTableViewCellIdentifier = @"VFourCouponQuanTableViewCell";
static NSString * const CouponTicketDetailPlaceholderCellIdentifier = @"CouponTicketDetailPlaceholderCell";
static NSString * const CouponDetailCellIdentifier = @"CouponDetailCell";
static CGFloat heightPlaceHolder = 54.0f;

@interface MyCouponDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate,UIAlertViewDelegate>{
    MyCouponDetailVo *couponDetail;
    NSArray *item;
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnUse;

@property (weak, nonatomic) IBOutlet UIButton *btnPharmcy;
@property (weak, nonatomic) IBOutlet UILabel *lblNoPharmcy;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;

@property (nonatomic, strong) NSMutableArray *costPharmacies;//消费药房
@property (nonatomic, strong) NSMutableArray *arrCouponDetails;//优惠细则
@property (nonatomic, strong) NSMutableArray *arrProducts;
@property (nonatomic, strong) NSMutableArray *arrPharmcys;
@property (nonatomic, assign) NSInteger curProductPage;

@end

@implementation MyCouponDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"优惠券详情";
    self.costPharmacies = [[NSMutableArray alloc]init];
    self.arrProducts = [[NSMutableArray alloc]init];
    self.arrCouponDetails = [@[] mutableCopy];
    self.arrPharmcys = [@[] mutableCopy];
    
    //设置右边的分享
    UIView *ypDetailBarItems=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 55)];
    UIButton * zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [zoomButton setFrame:CGRectMake(23, -2, 55,55)];
    [zoomButton addTarget:self action:@selector(sharClick) forControlEvents:UIControlEventTouchUpInside];
    UIImage *image = [[UIImage imageNamed:@"icon_share"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [zoomButton setImage:image forState:UIControlStateNormal];
    [ypDetailBarItems addSubview:zoomButton];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -15;
    item=@[fixed,[[UIBarButtonItem alloc]initWithCustomView:ypDetailBarItems]];
    
    //设置底部的按钮
    self.bottomHeight.constant=0;
    self.footerView.hidden=YES;
    self.lblNoPharmcy.hidden=YES;
    self.btnPharmcy.hidden=YES;
    self.btnUse.hidden=YES;
    self.btnPharmcy.layer.masksToBounds=YES;
    self.btnPharmcy.layer.cornerRadius=4.0f;
    self.btnUse.layer.masksToBounds=YES;
    self.btnUse.layer.cornerRadius=4.0f;
    
    //设置底部的tableview
    [self.mainTableView addStaticImageHeader];
    self.mainTableView.backgroundColor = RGBHex(qwColor21);
    self.mainTableView.tableFooterView = [[UIView alloc]init];
    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    couponDetail = [MyCouponDetailVo new]; //备用全局变量
    //预加载四种Cell
    [self.mainTableView registerNib:[UINib nibWithNibName:@"myConsultTableViewCell" bundle:nil] forCellReuseIdentifier:BranchIdentifier];
    [self.mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:UITableViewIdentifier];
    [self.mainTableView registerNib:[UINib nibWithNibName:@"VFourCouponQuanTableViewCell" bundle:nil] forCellReuseIdentifier:VFourCouponQuanTableViewCellIdentifier];
    [self.mainTableView registerNib:[UINib nibWithNibName:@"CouponTicketDetailPlaceholderCell" bundle:nil] forCellReuseIdentifier:CouponTicketDetailPlaceholderCellIdentifier];
    [self.mainTableView registerNib:[UINib nibWithNibName:@"CouponDetailCell" bundle:nil] forCellReuseIdentifier:CouponDetailCellIdentifier];
    

}


//为弹框获取适用药房
- (void)loadBranchsData{
    
    [[QWGlobalManager sharedInstance]readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        CouponNewBranchSuitableModelR *modelR = [CouponNewBranchSuitableModelR new];
        modelR.couponId = couponDetail.couponId;
        modelR.page = @"1";
        modelR.pageSize = @"10";
        if(mapInfoModel == nil){
            modelR.lng = @"120.730435";
            modelR.lat = @"31.273391";
        }else{
            modelR.lng = [NSString stringWithFormat:@"%f",mapInfoModel.location.coordinate.longitude];
            modelR.lat = [NSString stringWithFormat:@"%f",mapInfoModel.location.coordinate.latitude];
        }
        modelR.branchId=[QWGLOBALMANAGER getMapBranchId];
        
        [Coupon getNewCouponPharmacy:modelR success:^(id obj) {
            
            CouponBranchVoListModel *couponPharModel = (CouponBranchVoListModel *)obj;
            
            [self.arrPharmcys addObjectsFromArray:couponPharModel.suitableBranchs];
            
        } failure:^(HttpException *e) {

        }];
    }];
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //分享按钮设置为不显示
    [self setUpRightItem:NO];
    //无网判断
    if(QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [self showInfoView:kWarning12 image:@"网络信号icon"];
    }else{
        self.curProductPage = 1;
        //请求我的优惠券详情
        [self GetMyCoupon];
    }
    ((QWBaseNavigationController *)self.navigationController).canDragBack = NO;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ((QWBaseNavigationController *)self.navigationController).canDragBack = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 分享
- (void)sharClick{
    //0.待开始，1.待使用，2.快过期，3.已使用，4.已过期,
    [QWGLOBALMANAGER statisticsEventId:@"优惠券详情_分享" withLable:@"我的优惠券详情" withParams:nil];
    //cj---224更改所有的全部分享变成使用前的
    ShareContentModel *modelShare = [[ShareContentModel alloc] init];
    modelShare.typeShare    = ShareTypeMyCoupon;
    NSArray *arrParams      = @[couponDetail.couponId,couponDetail.groupId];
    if([couponDetail.scope intValue] == 4){
        modelShare.imgURL   = couponDetail.giftImgUrl;
    }
    modelShare.shareID      = modelShare.shareID = [arrParams componentsJoinedByString:SeparateStr];
    modelShare.title        = couponDetail.couponTitle;
    modelShare.content      = couponDetail.desc;
    
    ShareSaveLogModel *modelR = [ShareSaveLogModel new];
    modelR.province=[QWGLOBALMANAGER getMapInfoModel].province;
    modelR.city=[QWGLOBALMANAGER getMapInfoModel].branchCityName;
    modelR.shareObj = @"1";
    modelR.shareObjId = couponDetail.couponId;
    modelShare.modelSavelog = modelR;
    [self popUpShareView:modelShare];
    
    
}


#pragma mark - 上拉加载更多数据
- (void)footerRereshing{
    HttpClientMgr.progressEnabled = NO;
    [self loadProductData];
}


#pragma mark - 我的优惠券列表页面进入HTTPRequest
- (void)GetMyCoupon{
    [[QWGlobalManager sharedInstance] readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        
            GetMyCouponDetailModelR *modelR = [GetMyCouponDetailModelR new];
            modelR.token = QWGLOBALMANAGER.configure.userToken;
            modelR.myCouponId = self.myCouponId;
            
            if(mapInfoModel == nil){
                modelR.longitude = @(120.730435);
                modelR.latitude = @(31.273391);
            }else{
                modelR.longitude = @(mapInfoModel.location.coordinate.longitude);
                modelR.latitude = @(mapInfoModel.location.coordinate.latitude);
            }
            modelR.city=[QWGLOBALMANAGER getMapInfoModel].branchCityName;
            modelR.branchId=[QWGLOBALMANAGER getMapBranchId];
            
            [Coupon getMyCouponDetail:modelR success:^(id obj) {
                couponDetail = obj;
                [self setButtomButton];
                [self getCouponSuccess];
            } failure:^(HttpException *e) {
                if(e.errorCode!=-999){
                    if(e.errorCode == -1001){
                        [self showInfoView:kWarning215N26 image:@"ic_img_fail"];
                    }else{
                        [self showInfoView:kWarning39 image:@"ic_img_fail"];
                    }
                }
                [self.mainTableView reloadData];
            }];
        
    }];
}


#pragma mark - 设置底部的按钮
-(void)setButtomButton{
    if([couponDetail.status intValue] == 3 || [couponDetail.status intValue] == 4){
        self.bottomHeight.constant=0;
        self.footerView.hidden=YES;
    }else{
        self.bottomHeight.constant=50;
        self.footerView.hidden=NO;
        if(couponDetail.suitable){
            self.lblNoPharmcy.hidden=YES;
            self.btnPharmcy.hidden=YES;
            self.btnUse.hidden=NO;
        }else{
            self.lblNoPharmcy.hidden=NO;
            self.btnPharmcy.hidden=NO;
            self.btnUse.hidden=YES;
        }
        
    }
    

}



#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(couponDetail == nil){
        return 0;
    }else{
        return 3;
    }

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //第一个是优惠券  第二个是优惠细则 第三个是消费药房或者券适用商品
    if(indexPath.section == 0){
        return [VFourCouponQuanTableViewCell getCellHeight:nil] + 10;
    }else if(indexPath.section == 1){
        if([couponDetail.status intValue] == 3){
            return 0.0f;
        }else if([couponDetail.status intValue] == 4){
            return heightPlaceHolder;
        }else{
           return [self getCouponDetailHeight:indexPath.row];
        }
    }else if(indexPath.section == 2){
        if([couponDetail.status intValue] == 3){//已使用是消费药房
            if(indexPath.row==0){
                return heightPlaceHolder;
            }else{
                 return [myConsultTableViewCell getCellHeight:nil];
            }
        }else  if([couponDetail.status intValue] == 4){//已过期是什么都不要
            return 0.0f;
        }else{//其他是适用商品
            if([couponDetail.suitableProductCount intValue]>0){
                if(indexPath.row==0){
                    return heightPlaceHolder;
                }else{
                    return [CouponSuitableTableViewCell getCellHeight:nil];
                }
            }else{
                return 0.0f;
            }
            
        }
        
    }else{
        return 0.0f;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }else if(section == 1){
        if([couponDetail.status intValue] == 3){
            return 0;
        }else if([couponDetail.status intValue] == 4){
            return 1;
        }else{
            return self.arrCouponDetails.count+1;
        }
    }else if(section == 2){
        if([couponDetail.status intValue] == 3){
            return self.costPharmacies.count+1;
        }else if([couponDetail.status intValue] == 4){
            return 0;
        }else{
            if([couponDetail.suitableProductCount intValue]>0){
                return self.arrProducts.count+1;
            }else{
                return 0;
            }
            
        }
    }else{
        return 0;
    }
}

//优惠细则的高度
- (CGFloat)getCouponDetailHeight:(NSInteger)row
{
    if (row == 0) {
        return heightPlaceHolder;
    } else if (row >= 1) {
        static CouponDetailCell *sizingCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sizingCell = [self.mainTableView dequeueReusableCellWithIdentifier:@"CouponDetailCell"];
        });
        sizingCell.lblContent.font = fontSystem(kFontS5);
        NSString *strContent = [self.arrCouponDetails objectAtIndex:row-1];
        sizingCell.lblContent.text = strContent;
        if (row == self.arrCouponDetails.count) {
            sizingCell.constraintTop.constant=14.0f;
            sizingCell.constraintBottom.constant = 14.0f;
        }else{
            sizingCell.constraintTop.constant=14.0f;
            sizingCell.constraintBottom.constant = 0.0f;
        }
        sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.mainTableView.bounds), CGRectGetHeight(sizingCell.bounds));
        
        [sizingCell setNeedsLayout];
        [sizingCell layoutIfNeeded];
        CGSize sizeFinal = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return sizeFinal.height+1.0f;
    } else {
        return 0;
    }
}
//cell中优惠细则的标题
- (CouponTicketDetailPlaceholderCell *)getPlaceHolderCellWithText:(NSString *)str isShowImg:(BOOL)isShow isStatus:(NSString*)isStatus
{
    //  1正常的title  2居中的描述
    
    CouponTicketDetailPlaceholderCell *cell = (CouponTicketDetailPlaceholderCell *)[self.mainTableView dequeueReusableCellWithIdentifier:CouponTicketDetailPlaceholderCellIdentifier];
    
    
    if([isStatus isEqualToString:@"1"]){
        cell.imgArrow.hidden = !isShow;
        cell.lblContent.text = str;
        cell.lblContent.font = fontSystem(kFontS3);
        cell.lblContent.textColor = RGBHex(qwColor6);
        cell.centerLable.hidden = YES;
        cell.lblContent.hidden=NO;
        cell.line1.hidden=NO;
        cell.line2.hidden=NO;
    }else if ([isStatus isEqualToString:@"2"]){
        cell.imgArrow.hidden = !isShow;
        cell.centerLable.text = str;
        cell.centerLable.textAlignment=NSTextAlignmentCenter;
        cell.centerLable.font = fontSystem(kFontS5);
        cell.centerLable.textColor = RGBHex(qwColor6);
        cell.backView.backgroundColor=RGBHex(qwColor21);
        cell.lblContent.hidden=YES;
        cell.centerLable.hidden = NO;
        cell.line1.hidden=YES;
        cell.line2.hidden=YES;
    }
    
    return cell;
}

#pragma mark - 药房Cell
// 适用药房的cell
-(UITableViewCell*)getBranchCell:(UITableView*)tableView withIndexPath:(NSIndexPath *)indexp
{
    myConsultTableViewCell *cell = (myConsultTableViewCell *)[tableView dequeueReusableCellWithIdentifier:BranchIdentifier];
    CouponBranchVoModel *model;
    model = self.costPharmacies[indexp.row-1];
    [cell setCell:model];
    if([couponDetail.status intValue] == 3){
        cell.distance.hidden = YES;
    }else{
        cell.distance.hidden = NO;
    }
    cell.chatButton.hidden = YES;
    cell.branchImage.hidden = YES;
    cell.viewSeparateLine.hidden = YES;
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //第一个是优惠券  第二个是优惠细则 第三个是消费药房或者券适用商品
    if(indexPath.section == 0){
        VFourCouponQuanTableViewCell *cell = (VFourCouponQuanTableViewCell *)[tableView dequeueReusableCellWithIdentifier:VFourCouponQuanTableViewCellIdentifier];
        MyCouponDetailVo *model = (MyCouponDetailVo*)couponDetail;
        [cell setMyCouponDetailQuan:model];
        return cell;
    }else if(indexPath.section == 1){
        if([couponDetail.status intValue] == 3){
            return [tableView dequeueReusableCellWithIdentifier:UITableViewIdentifier];
        }else if([couponDetail.status intValue] == 4){
            NSString *strSuitablePhar = @"此优惠券已过期";
            return [self getPlaceHolderCellWithText:strSuitablePhar isShowImg:NO isStatus:@"2"];
        }else{
            //显示优惠细则
            if (indexPath.row == 0) {
                NSString *strSuitablePhar = @"优惠细则";
                return [self getPlaceHolderCellWithText:strSuitablePhar isShowImg:NO isStatus:@"1"];
            } else {
                CouponDetailCell *cell = (CouponDetailCell *)[tableView dequeueReusableCellWithIdentifier:CouponDetailCellIdentifier];
                NSString *strCondition = self.arrCouponDetails[indexPath.row - 1];
                cell.lblContent.text = strCondition;
                cell.lblContent.font = fontSystem(kFontS4);
                cell.lblContent.textColor = RGBHex(qwColor7);
                return cell;
            }
        }
    }else if(indexPath.section == 2){
        if([couponDetail.status intValue] == 3){
            if(indexPath.row==0){
                NSString *strSuitablePhar = @"消费药房";
                return [self getPlaceHolderCellWithText:strSuitablePhar isShowImg:NO isStatus:@"1"];
            }else{
                return [self getBranchCell:tableView withIndexPath:indexPath];
            }
        }else if([couponDetail.status intValue] == 4){
             return [tableView dequeueReusableCellWithIdentifier:UITableViewIdentifier];
        }else{
            if([couponDetail.suitableProductCount intValue]>0){
                if (indexPath.row == 0) {
                    NSString *strSuitablePhar = @"券适用商品";
                    return [self getPlaceHolderCellWithText:strSuitablePhar isShowImg:NO isStatus:@"1"];
                } else {
                    NSString *ConsultSuitableIdentifier = @"CouponSuitableTableViewCell";
                    CouponSuitableTableViewCell *cell = (CouponSuitableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ConsultSuitableIdentifier];
                    if(cell == nil){
                        UINib *nib = [UINib nibWithNibName:@"CouponSuitableTableViewCell" bundle:nil];
                        [tableView registerNib:nib forCellReuseIdentifier:ConsultSuitableIdentifier];
                        cell = (CouponSuitableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ConsultSuitableIdentifier];
                        cell.selectedBackgroundView = [[UIView alloc]init];
                        cell.selectedBackgroundView.backgroundColor = RGBHex(qwColor10);
                    }
                    CouponProductVoModel *drug = self.arrProducts[indexPath.row-1];
                    [cell setCell:drug];
                    return cell;
                }
            }else{
                return [tableView dequeueReusableCellWithIdentifier:UITableViewIdentifier];
            }
            
        }
        
    }else{
       return [tableView dequeueReusableCellWithIdentifier:UITableViewIdentifier];
    }
    
 }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2) {//显示消费药房或者券的适用商品
        if([couponDetail.status intValue] == 3){
            CouponBranchVoModel *model;
            model = self.costPharmacies[indexPath.row-1];
            if([model.type intValue]!=3){
                [SVProgressHUD showErrorWithStatus:@"此药房已关闭服务"];
                return;
            }else{
                //点击进入药房详情
                PharmacySotreViewController *VC = [[PharmacySotreViewController alloc]init];
                VC.branchId = model.branchId;
                VC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:VC animated:YES];
            }
        }else if([couponDetail.suitableProductCount intValue]>0){
            if(indexPath.row!=0){
                CouponProductVoModel *drug = self.arrProducts[indexPath.row-1];
                if(couponDetail.suitable){
                    MedicineDetailViewController *medicintDetail = [[MedicineDetailViewController alloc]initWithNibName:@"MedicineDetailViewController" bundle:nil];
                    medicintDetail.lastPageName = @"我的优惠券适用商品";
                    medicintDetail.proId = drug.branchProId;
                    medicintDetail.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:medicintDetail animated:YES];
                }else{
                    //弹框alert
                    ChangeProductAlertView *alert=[ChangeProductAlertView instance];
                    alert.blockDirect = ^(BOOL success) {
                        MedicineSearchResultViewController *VC = [[MedicineSearchResultViewController alloc]initWithNibName:@"MedicineSearchResultViewController" bundle:nil];
                        VC.productCode = drug.productId;
                        VC.lastPageName = @"我的优惠券适用商品";
                        VC.couponId =couponDetail.couponId;
                        [self.navigationController pushViewController:VC animated:YES];
                    };
                    alert.blockCancel = ^(BOOL cancel) {
                    };
                    [alert show];
                    
                }
            }
        }
    }
}




#pragma mark - 分享按钮建立
- (void)setUpRightItem:(BOOL)flag{
    if(flag){
        self.navigationItem.rightBarButtonItems = item;
    }else{
        self.navigationItem.rightBarButtonItems = nil;
    }
}



#pragma mark - getMyCopon请求成功处理
- (void)getCouponSuccess{
    if([couponDetail.apiStatus intValue] == 0){
        if([couponDetail.frozen intValue] == 1 && [couponDetail.status intValue] != 3){
            [self showInfoView:couponDetail.apiMessage image:@"ic_img_cry"];
            return;
        }
        if(couponDetail.open && [couponDetail.status intValue] != 4 && couponDetail.canUserShare){//公开券,该优惠券没有过期,用户端是否能够分享
            [self setUpRightItem:YES];
        }else{
            [self setUpRightItem:NO];
        }
        
        
        
        CouponConditionVoListModel *modelCondition = (CouponConditionVoListModel *)couponDetail.condition;
        [self.arrCouponDetails removeAllObjects];
        if (modelCondition.title.length > 0) {
            [self.arrCouponDetails addObject:modelCondition.title];
        }
        [self.arrCouponDetails addObjectsFromArray:modelCondition.conditions];
        
        
        //如果是已使用的显示消费药房
        if([couponDetail.status intValue] != 3 && [couponDetail.suitableBranchCount intValue] != 0){
            
        }else{
            [self.mainTableView removeFooter];
            [self.costPharmacies removeAllObjects];
            [self.costPharmacies addObjectsFromArray:couponDetail.suitableBranchs];
        }
        [self loadBranchsData];
        [self loadProductData];

    }else{
        [self showInfoView:couponDetail.apiMessage image:@"ic_img_cry"];
        [self.mainTableView reloadData];
    }

}


#pragma mark - 获取券适用商品
- (void)loadProductData{
    GetCouponDetailProductModelR *modelR = [GetCouponDetailProductModelR new];
    modelR.couponId = couponDetail.couponId;
    if(couponDetail.suitable){
        modelR.branchId = [QWGLOBALMANAGER getMapBranchId];
    }
    modelR.page = [NSString stringWithFormat:@"%ld",(long)self.curProductPage];
    modelR.pageSize=@"10";
    
    [Coupon couponSuitableDrug:modelR success:^(id obj) {
        CouponProductVoListModel *couponList = (CouponProductVoListModel *)obj;
        if([couponList.apiStatus intValue]==0){
            if(couponList.suitableProducts.count>0){
                //willAppear有重新获取商品的情况
                if(self.curProductPage==1){
                    [self.mainTableView addFooterWithTarget:self action:@selector(footerRereshing)];
                     self.mainTableView.footer.canLoadMore=YES;
                    [self.arrProducts removeAllObjects];
                }
                [self.arrProducts addObjectsFromArray:couponList.suitableProducts];
                self.curProductPage++;
            }else{
                self.mainTableView.footer.canLoadMore=NO;
            }
        }else{
            [self setUnStatusView];
        }
      [self.mainTableView footerEndRefreshing];
      //最后一次刷新页面
      [self.mainTableView reloadData];
    } failure:^(HttpException *e) {
        if(e.errorCode!=-999){
            if(e.errorCode == -1001){
                [self showInfoView:kWarning215N26 image:@"ic_img_fail" tag:0];
            }else{
                [self showInfoView:kWarning39 image:@"ic_img_fail" tag:0];
            }
        }
        [self.mainTableView footerEndRefreshing];
        [self.mainTableView reloadData];
    }];
}

#pragma mark ---不同非正常状态下的背景提示
- (void)setUnStatusView
{
    //访问不正常
    if([couponDetail.apiStatus intValue] == 4)
    {
        [self showInfoView:@"对不起，该优惠已下架" image:@"ic_img_cry"];
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
    if([couponDetail.apiStatus intValue] != 0){
        [self showInfoView:couponDetail.apiMessage image:@"ic_img_cry"];
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
}

- (IBAction)otherPharmcy:(id)sender {
    [QWGLOBALMANAGER statisticsEventId:@"优惠券详情_其它适用药房" withLable:@"我的优惠券详情" withParams:nil];
    if([couponDetail.suitableBranchCount intValue]>0){
        [BranchCouponDetailView showMyInView:APPDelegate.window withTitle:@"其他适用药房" model:couponDetail list:self.arrPharmcys withSelectedIndex:-1 withType:Enum_CouponDetail andCallBack:^(CouponBranchVoModel *obj,NSString *type) {
            if([type isEqualToString:@"0"]){//cell的点击
                //点击弹出是否切换药房
                //兑换券直接进入二维码页面
                if([couponDetail.scope integerValue] == 7||[couponDetail.scope integerValue] == 8){
                    [self GoUseQuanHTTP];
                }else{
                    CouponBranchVoModel *model = obj;
                    //弹框alert
                    ChangeStoreAlertView *alert=[ChangeStoreAlertView instance];
                    alert.alertTitle.text = model.branchName;
                    alert.blockDirect = ^(BOOL success) {
                        //进入切换药房的首页
                        if(!StrIsEmpty(model.branchId)){
                            [QWGLOBALMANAGER setMapBranchId:model.branchId branchName:model.branchName];
                        }
                        [QWGLOBALMANAGER postNotif:NotifChangeBranchFromHomePage data:model.branchName object:nil];
                        QWGLOBALMANAGER.tabBar.selectedIndex = 0;
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    };
                    alert.blockCancel = ^(BOOL cancel) {
                    };
                    [alert show];
                }
            }
        }];
    }else{
        [SVProgressHUD showSuccessWithStatus:@"暂无适用药房"];
    }
}

- (IBAction)useCoupon:(id)sender {
    //优惠商品券和兑换券直接跳转到二维码页面
    
    if([couponDetail.scope integerValue] == 7||[couponDetail.scope integerValue] == 8){
        [self GoUseQuanHTTP];
    }else{
        QWGLOBALMANAGER.tabBar.selectedIndex = 0;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    
}

//到兑换码的页面
- (void)GoUseQuanHTTP{
    
    CouponShowModelR *modelR = [CouponShowModelR new];
    modelR.token = QWGLOBALMANAGER.configure.userToken;
    modelR.myCouponId = couponDetail.myCouponId;
    
    [Coupon couponShow:modelR success:^(UseMyCouponVoModel *model) {
        if([model.apiStatus integerValue] == 0)
        {
            CouponUseViewController *couponUseViewController = [[CouponUseViewController alloc] initWithNibName:@"CouponUseViewController" bundle:nil];
            couponUseViewController.useModel = model;
            [self.navigationController pushViewController:couponUseViewController animated:YES];
        }else{
            [SVProgressHUD showErrorWithStatus:model.apiMessage duration:0.8];
        }
    } failure:^(HttpException *e) {
        
    }];
}

@end
