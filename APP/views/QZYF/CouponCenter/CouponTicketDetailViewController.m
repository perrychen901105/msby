//
//  CouponTicketDetailViewController.m
//  APP
//  优惠券详情  领券中心
//  Created by PerryChen on 11/10/15.
//  Copyright © 2015 carret. All rights reserved.
//

#import "CouponTicketDetailViewController.h"
#import "WebDirectModel.h"
#import "VFourCouponQuanTableViewCell.h"
#import "myConsultTableViewCell.h"
#import "ChatViewController.h"
#import "MoreConsultViewController.h"
#import "MyEvaluationViewController.h"
#import "EvaluatingPromotionViewController.h"
#import "SVProgressHUD.h"
#import "WebDirectViewController.h"
#import "SuitableDrugViewController.h"
#import "swiftModule-swift.h"
#import "Promotion.h"
#import "CouponSuccessViewController.h"
#import "PromotionCustomAlertView.h"
#import "CouponTicketDetailPlaceholderCell.h"
#import "CouponDetailCell.h"
#import "CouponConditionLabel.h"
#import "MallCouponSuccessViewController.h"

static NSString * const BranchIdentifier = @"myConsultTableViewCell";
static NSString * const CouponQuanTableViewCellIdentifier = @"VFourCouponQuanTableViewCell";
static CGFloat heightPlaceHolder = 45.0f;

@interface CouponTicketDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate,myConsultTableViewCellDelegate>
{
    BOOL firstPushed;
}
@property (weak, nonatomic) IBOutlet UITableView *tbViewContent;
@property (strong, nonatomic) IBOutlet UIView *couponTicketInfo;
@property (nonatomic, strong) NSMutableArray *arrPharmacies;
@property (nonatomic, strong) NSMutableArray *arrCouponDetails;
@property (nonatomic, assign) NSInteger curPharmacyPage;
@property (weak, nonatomic) IBOutlet UIView *viewFooter;
@property (nonatomic, strong) MyCouponDetailVoListModel *couponDetail;
@property (strong, nonatomic) NSString *couponId;
@property (nonatomic, assign) BOOL isShowPhars;
@property (nonatomic, assign) BOOL isShowDrugs;
@property (weak, nonatomic) IBOutlet UIButton *btnGetCoupon;
@property (weak, nonatomic) IBOutlet UILabel *lblRemainCount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightFooter;

- (IBAction)pickTicket:(UIButton *)sender;

@end

@implementation CouponTicketDetailViewController
- (instancetype)init{
    
    if(self == [super init]){
        firstPushed = YES;
    } 
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"优惠券";
    self.arrPharmacies = [@[] mutableCopy];
    self.arrCouponDetails = [@[] mutableCopy];
    
    [self.tbViewContent registerNib:[UINib nibWithNibName:@"VFourCouponQuanTableViewCell" bundle:nil] forCellReuseIdentifier:CouponQuanTableViewCellIdentifier];
    [self.tbViewContent registerNib:[UINib nibWithNibName:@"myConsultTableViewCell" bundle:nil] forCellReuseIdentifier:BranchIdentifier];
    [self.tbViewContent addFooterWithTarget:self action:@selector(refreshData)];
//    self.tbViewContent.footerPullToRefreshText = kWarning6;
//    self.tbViewContent.footerReleaseToRefreshText = kWarning7;
//    self.tbViewContent.footerRefreshingText = kWarning9;
//    self.tbViewContent.footerNoDataText = kWarning44;
    [self.tbViewContent addStaticImageHeader];
    self.tbViewContent.backgroundColor = RGBHex(qwColor11);
    self.viewFooter.backgroundColor = RGBHex(qwColor11);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //无网判断
    if(QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [self showMyInfoView:kWarning12 image:@"网络信号icon" tag:0];
    }else{
        self.curPharmacyPage = 1;
        [self getOnlineCoupon];
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

- (void)setupCouponTicketDetailWithCouponId:(NSString *)couponID showSuitablePhar:(BOOL)isShowPhars
{
    self.couponId = couponID;
    self.isShowPhars = isShowPhars;
}

#pragma mark - 获取数据
// 获取优惠券信息
- (void)getOnlineCoupon{
    
    GetNewOnlineCouponModelR *modelR = [GetNewOnlineCouponModelR new];
    [[QWGlobalManager sharedInstance]readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        if(mapInfoModel == nil){
            modelR.longitude = @(120.730435);
            modelR.latitude = @(31.273391);
            modelR.city = @"苏州";
        }else{
            modelR.longitude = @(mapInfoModel.location.coordinate.longitude);
            modelR.latitude = @(mapInfoModel.location.coordinate.latitude);
            modelR.city = mapInfoModel.city;
        }
    }];
    
    if(QWGLOBALMANAGER.loginStatus){
        modelR.token = QWGLOBALMANAGER.configure.userToken;
    }
    modelR.couponId = self.couponId;
    
    [Coupon getNewOnlineCoupon:modelR success:^(MyCouponDetailVoListModel *obj) {
        // comment by perry
        self.couponDetail = obj;
        //TODO: cj 3.1
        if([self.couponDetail.suitableProductCount intValue]>0){//有适用商品就显示
            self.isShowDrugs = YES;
        }
        //获取优惠细则的个数
        CouponConditionModelR *modelRCondition = [CouponConditionModelR new];
        modelRCondition.type = @"1";
        modelRCondition.id = self.couponDetail.couponId;
        [Coupon getCouponCondition:modelRCondition success:^(id couponConditions) {
            CouponConditionVoListModel *modelCondition = (CouponConditionVoListModel *)couponConditions;
            [self.arrCouponDetails removeAllObjects];
            
            if (modelCondition.title.length > 0) {
                [self.arrCouponDetails addObject:modelCondition.title];
            }
            [self.arrCouponDetails addObjectsFromArray:modelCondition.conditions];
            
            [self.tbViewContent reloadData];
        } failure:^(HttpException *e) {
            
        }];
        // comment by perry
        if (([self.couponDetail.suitableBranchs count] <= 0)||([self.couponDetail.suitableBranchCount intValue] <= 0)) {
                self.isShowPhars = NO;      // 不展示适用药房
        }
        
//        if ([self.couponDetail.suitableBranchCount intValue] <= 0) {
//            self.isShowPhars = NO;      // 不展示适用药房
//        } else {
//            
//        }
        if (self.isShowPhars) {
            [self getCouponPharmaciesFromMyCoupon:NO];
        } else {
            [self.tbViewContent removeFooter];
            [self setupOnlineCouponView];
        }
        
    } failure:^(HttpException *e) {
        if(e.errorCode!=-999){
            if(e.errorCode == -1001){
                [self showMyInfoView:kWarning215N26 image:@"ic_img_fail" tag:0];
            }else{
                [self showMyInfoView:kWarning39 image:@"ic_img_fail" tag:0];
            }
        }
        
    }];
}
#pragma mark - 分页加载
- (void)refreshData{
    self.curPharmacyPage += 1;
    HttpClientMgr.progressEnabled = NO;
    [self getCouponPharmaciesFromMyCoupon:NO];
}
// 获取适用药房列表
- (void)getCouponPharmaciesFromMyCoupon:(BOOL)fromMyCoupon
{
    [[QWGlobalManager sharedInstance]readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        CouponNewBranchSuitableModelR *modelR = [CouponNewBranchSuitableModelR new];
        modelR.couponId = self.couponDetail.couponId;
        modelR.page = [NSString stringWithFormat:@"%ld",self.curPharmacyPage];
        modelR.pageSize = @"10";
        if(mapInfoModel == nil){
            modelR.lng = @"120.730435";
            modelR.lat = @"31.273391";
            modelR.city = @"苏州";
        }else{
            modelR.lng = [NSString stringWithFormat:@"%f",mapInfoModel.location.coordinate.longitude];
            modelR.lat = [NSString stringWithFormat:@"%f",mapInfoModel.location.coordinate.latitude];
            modelR.city = mapInfoModel.city;
        }
        
        [Coupon getNewCouponPharmacy:modelR success:^(id obj) {
            
            CouponBranchVoListModel *couponPharModel = (CouponBranchVoListModel *)obj;
            [self.tbViewContent.footer endRefreshing];
            if (couponPharModel.suitableBranchs.count <= 0) {
                self.tbViewContent.footer.canLoadMore = NO;
                return ;
            }
            if (self.curPharmacyPage == 1) {
                
                [self.arrPharmacies removeAllObjects];
                self.arrPharmacies = [couponPharModel.suitableBranchs mutableCopy];
                
            } else {
                
                [self.arrPharmacies addObjectsFromArray:couponPharModel.suitableBranchs];
            }
            
            [self setupOnlineCouponView];
        } failure:^(HttpException *e) {
            [self.tbViewContent.footer endRefreshing];
        }];
    }];
}
- (void)setupCouponRemainCount
{
    self.btnGetCoupon.enabled = YES;
    self.btnGetCoupon.hidden = NO;
    self.viewFooter.backgroundColor = RGBHex(qwColor4);
    
    if ([self.couponDetail.empty intValue] == 1) {
        // 该券已经没有了
        self.heightFooter.constant = 0;
        [self.tbViewContent layoutIfNeeded];
        self.lblRemainCount.text = @"";
        [self.btnGetCoupon setTitle:@"" forState:UIControlStateNormal];
        self.btnGetCoupon.hidden = YES;
        self.btnGetCoupon.enabled = NO;
        self.viewFooter.backgroundColor = RGBHex(qwColor11);
    } else {
        // 该券还有
        if ([self.couponDetail.pick intValue] == 0) {
            // 未领取过该券
            self.lblRemainCount.text = [NSString stringWithFormat:@"可领%@次",self.couponDetail.couponNumLimit];
             [self.btnGetCoupon setTitle:@"领取优惠" forState:UIControlStateNormal];
        } else {
            // 已领取过该券
            if ([self.couponDetail.couponNumLimit intValue] == 0) {
                // 已经领过优惠券，并且个数为0
                self.lblRemainCount.text = @"已领完";
                [self.btnGetCoupon setTitle:@"我的优惠券" forState:UIControlStateNormal];
            } else {
                self.lblRemainCount.text = [NSString stringWithFormat:@"还可领%@次",self.couponDetail.couponNumLimit];
                 [self.btnGetCoupon setTitle:@"领取优惠" forState:UIControlStateNormal];
            }
        }
    }
    /*
    if (([self.couponDetail.couponNumLimit intValue] == 0)&&([self.couponDetail.pick intValue] == 1)) {
        // 已经领过优惠券，并且个数为0
        self.lblRemainCount.text = @"已领完";
        [self.btnGetCoupon setTitle:@"我的优惠券" forState:UIControlStateNormal];
    } else {
        // 未领过优惠券或者可领次数大于0
        if ([self.couponDetail.empty intValue] == 1) {
            // 该券已经没有了
            
            self.heightFooter.constant = 0;
            [self.tbViewContent layoutIfNeeded];
            self.lblRemainCount.text = @"";
            [self.btnGetCoupon setTitle:@"" forState:UIControlStateNormal];
            self.btnGetCoupon.hidden = YES;
            self.btnGetCoupon.enabled = NO;
            self.viewFooter.backgroundColor = RGBHex(qwColor11);
        } else {
            // 该券还有
            if ([self.couponDetail.pick intValue] == 0) {
                // 未领取过该券
                self.lblRemainCount.text = [NSString stringWithFormat:@"可领%@次",self.couponDetail.couponNumLimit];
            } else {
                // 已领取过该券
                self.lblRemainCount.text = [NSString stringWithFormat:@"还可领%@次",self.couponDetail.couponNumLimit];
            }
        [self.btnGetCoupon setTitle:@"领取优惠" forState:UIControlStateNormal];
        }
    }
    */
    
    self.lblRemainCount.textAlignment = NSTextAlignmentCenter;
    self.lblRemainCount.font = fontSystem(kFontS5);
}
#pragma mark - 去使用按钮TableFooterView
// 设置页面
- (void)setupView{
    //0.待开始，1.待使用，2.快过期，3.已使用，4.已过期,
    if([self.couponDetail.status intValue] == 0 || [self.couponDetail.status intValue] == 1 || [self.couponDetail.status intValue] == 2 || [self.couponDetail.status intValue] == 3){
        if(self.couponDetail.canUserShare){//是否可以分享
            UIView *ypDetailBarItems=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 55)];
            UIButton * zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [zoomButton setFrame:CGRectMake(23, -2, 55,55)];
            [zoomButton addTarget:self action:@selector(sharClick) forControlEvents:UIControlEventTouchUpInside];
            [zoomButton setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
            [zoomButton setImage:[UIImage imageNamed:@"icon_share_click"] forState:UIControlStateHighlighted];
            [ypDetailBarItems addSubview:zoomButton];
            UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            fixed.width = -15;
            self.navigationItem.rightBarButtonItems=@[fixed,[[UIBarButtonItem alloc]initWithCustomView:ypDetailBarItems]];
        }
    }
    self.btnGetCoupon.layer.masksToBounds = YES;
    self.btnGetCoupon.layer.cornerRadius = 4.5f;
    self.btnGetCoupon.backgroundColor = RGBHex(qwColor2);
    [self setupCouponRemainCount];
}

- (void)popVCAction:(id)sender
{
    if (self.extCallback != nil) {
        self.extCallback(YES);
    }
    [super popVCAction:sender];
}

- (void)setupOnlineCouponView
{
    if([self.couponDetail.apiStatus intValue] == 0){
        //        [self TrackEvent];
    }
    
    if([self.couponDetail.apiStatus intValue] != 0){
        
        [self showMyInfoView:self.couponDetail.apiMessage image:@"ic_img_cry" tag:0];
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
    if([self.couponDetail.apiStatus intValue] == 4)
    {
        [self showMyInfoView:@"对不起，该优惠已下架" image:@"ic_img_cry" tag:0];
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
    
    [self setupView];
    
    [self.tbViewContent reloadData];
}

#pragma mark - 商品下架/冻结背景提示UI
//背景提示需要自定义增加控件,所有和父类方法混用(例外特殊)
-(void)showMyInfoView:(NSString *)text image:(NSString*)imageName tag:(NSInteger)tag
{
    UIView *vInfo = [super showInfoView:text image:imageName tag:tag];
    UIView *lblInfo = [vInfo viewWithTag:101];
    UIButton *checkButton = [[UIButton alloc]initWithFrame:CGRectMake(APP_W - 120, lblInfo.frame.origin.y + lblInfo.frame.size.height + 52, 100, 21) ];
    checkButton.titleLabel.font = fontSystem(kFontS4);
    [checkButton setTitle:@"查看我的优惠" forState:UIControlStateNormal];
    [checkButton setTitleColor:RGBHex(qwColor5) forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(pushToMyQuan:) forControlEvents:UIControlEventTouchUpInside];
    [vInfo addSubview:checkButton];
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - 分享
- (void)sharClick{
    if([self.couponDetail.status intValue] == 0 || [self.couponDetail.status intValue] == 1 || [self.couponDetail.status intValue] == 2|| [self.couponDetail.status intValue] == 4){//使用前
        
        ShareContentModel *modelShare = [[ShareContentModel alloc] init];
        modelShare.typeShare    = ShareTypeMyCoupon;
        NSArray *arrParams      = @[self.couponDetail.couponId,self.couponDetail.groupId];
        if([self.couponDetail.scope intValue] == 4){
            modelShare.imgURL   = self.couponDetail.giftImgUrl;
        }
        modelShare.shareID      = modelShare.shareID = [arrParams componentsJoinedByString:SeparateStr];
        modelShare.title        = self.couponDetail.couponTitle;
        modelShare.content      = self.couponDetail.desc;
        
        ShareSaveLogModel *modelR = [ShareSaveLogModel new];
        
        MapInfoModel *mapInfoModel = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
        if(mapInfoModel) {
            modelR.city = mapInfoModel.city;
            modelR.province = mapInfoModel.province;
        }else{
            modelR.city = @"苏州市";
            modelR.province = @"江苏省";
        }
        modelR.shareObj = @"1";
        modelR.shareObjId = self.couponDetail.couponId;
        modelShare.modelSavelog = modelR;
        [self popUpShareView:modelShare];
    }
}
#pragma mark - UITableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.couponDetail == nil) {
        return 0;
    }
    NSInteger intSections = 2;
    if(self.isShowDrugs){
        intSections++;
    }
    // 是慢病券或者商品券，显示适用商品
    if (self.isShowPhars) {
        intSections++;
    }
    return intSections;
}

- (CouponTicketDetailPlaceholderCell *)getPlaceHolderCellWithText:(NSString *)str isShowImg:(BOOL)isShow
{
    CouponTicketDetailPlaceholderCell *cell = [self.tbViewContent dequeueReusableCellWithIdentifier:@"CouponTicketDetailPlaceholderCell"];
    cell.lblContent.text = str;
    cell.imgArrow.hidden = !isShow;


    cell.lblContent.font = fontSystem(kFontS4);
    cell.lblContent.textColor = RGBHex(qwColor6);
    return cell;
}

// 适用药房的cell
-(UITableViewCell*)getBranchCell:(UITableView*)tableView withIndexPath:(NSIndexPath *)indexp
{
    myConsultTableViewCell *cell = (myConsultTableViewCell *)[tableView dequeueReusableCellWithIdentifier:BranchIdentifier];
    
    CouponBranchVoModel *model = self.arrPharmacies[indexp.row-1];
    cell.cellDelegate = self;
    [cell setCell:model];
    cell.distance.hidden = NO;
    cell.chatButton.hidden = YES;
    cell.branchImage.hidden = YES;
    cell.viewSeparateLine.hidden = YES;
    return cell;
}

- (CouponDetailCell *)getCouponDetailInfoCell:(NSInteger)row
{
    NSString *strCondition = self.arrCouponDetails[row - 1];
    CouponDetailCell *cell = [self.tbViewContent dequeueReusableCellWithIdentifier:@"CouponDetailCell"];
    CGSize size =[GLOBALMANAGER sizeText:strCondition font:fontSystem(kFontS4) limitWidth:self.tbViewContent.frame.size.width - 100.0f];
    cell.lblContent.frame = CGRectMake(cell.lblContent.frame.origin.x, cell.lblContent.frame.origin.y, self.tbViewContent.frame.size.width - 100.0f, size.height);
    cell.lblContent.text = strCondition;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        VFourCouponQuanTableViewCell *cell = (VFourCouponQuanTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CouponQuanTableViewCellIdentifier];

        [cell setTicketCouponQuan:self.couponDetail];
        
        //预热券不显示
//        if ([self.couponDetail.status intValue] == 0) {
//            cell.dateLabel.text = [NSString stringWithFormat:@"%@ - %@(未到使用期)",self.couponDetail.begin,self.couponDetail.end];
//        }
        cell.statusImage.hidden = YES;
        //已领完 显示已领完的戳
        if([self.couponDetail.empty intValue] == 1){
            cell.statusImage.image = PickOver;
        }
        return cell;
    } else if (indexPath.section == 1) {
        if (self.isShowDrugs) {
            //显示优惠商品
            return [self getPlaceHolderCellWithText:@"适用商品" isShowImg:YES];
        } else {
            //显示优惠细则
            if (indexPath.row == 0) {
                CouponTicketDetailPlaceholderCell *cellCondition = [self getPlaceHolderCellWithText:@"优惠细则" isShowImg:NO];
                cellCondition.lblContent.textColor = RGBHex(qwColor6);
                cellCondition.lblContent.font = fontSystem(kFontS4);
                return cellCondition;
            } else {
                NSString *strCondition = self.arrCouponDetails[indexPath.row - 1];
                CouponDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CouponDetailCell"];
                cell.lblContent.text = strCondition;
                cell.lblContent.font = fontSystem(kFontS5);
                cell.lblContent.textColor = RGBHex(qwColor7);
//                cell.constraintTop.constant = 2.0f;
//                cell.constraintBottom.constant = 2.0f;
//                if (indexPath.row == 1) {
//                    cell.constraintTop.constant = 10.0f;
//                }
//                if (indexPath.row == self.arrCouponDetails.count) {
//                    cell.constraintBottom.constant = 20.0f;
//                }
                return cell;
            }
        }
    } else if (indexPath.section == 2) {
        if (self.isShowDrugs) {
            //显示优惠细则
            if (indexPath.row == 0) {
                CouponTicketDetailPlaceholderCell *cellCondition = [self getPlaceHolderCellWithText:@"优惠细则" isShowImg:NO];
                cellCondition.lblContent.textColor = RGBHex(qwColor6);
                cellCondition.lblContent.font = fontSystem(kFontS4);
                return cellCondition;
            } else {
                NSString *strCondition = self.arrCouponDetails[indexPath.row - 1];
                CouponDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CouponDetailCell"];
                cell.lblContent.text = strCondition;
                cell.lblContent.font = fontSystem(kFontS5);
                cell.lblContent.textColor = RGBHex(qwColor7);
//                cell.constraintTop.constant = 2.0f;
//                cell.constraintBottom.constant = 2.0f;
//                if (indexPath.row == 1) {
//                    cell.constraintTop.constant = 10.0f;
//                }
//                if (indexPath.row == self.arrCouponDetails.count) {
//                    cell.constraintBottom.constant = 20.0f;
//                }
                return cell;
            }
        } else {
            //显示优惠药房
            if (self.isShowPhars) {
                if (indexPath.row == 0) {
                    NSString *strSuitablePhar = @"适用药房";
                    // comment by perry
                    if ([self.couponDetail.suitableBranchCount intValue] > 0) {
                        strSuitablePhar = [NSString stringWithFormat:@"适用药房(%d)",[self.couponDetail.suitableBranchCount intValue]];
                    }
                    return [self getPlaceHolderCellWithText:strSuitablePhar isShowImg:NO];
                } else {
                    return [self getBranchCell:tableView withIndexPath:indexPath];
                }
            } else {
                return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"null"];
            }
        }
    } else if (indexPath.section == 3) {
        //显示优惠药房
        if (self.isShowPhars) {
            if (indexPath.row == 0) {
                NSString *strSuitablePhar = @"适用药房";
                // comment by perry
                if ([self.couponDetail.suitableBranchCount intValue] > 0) {
                    strSuitablePhar = [NSString stringWithFormat:@"适用药房(%d)",[self.couponDetail.suitableBranchCount intValue]];
                }
                return [self getPlaceHolderCellWithText:strSuitablePhar isShowImg:NO];
            } else {
                return [self getBranchCell:tableView withIndexPath:indexPath];
            }
        } else {
            return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"null"];
        }
    }
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"null"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        if (self.isShowDrugs) {
            //显示优惠商品
            return 1;
        } else {
            //显示优惠细则
            if(self.arrCouponDetails.count > 0){
                return 1 + self.arrCouponDetails.count;
            }else{
                return 0;
            }
        }
    } else if (section == 2) {
        if (self.isShowDrugs) {
            //显示优惠细则
            if(self.arrCouponDetails.count > 0){
                return 1 + self.arrCouponDetails.count;
            }else{
                return 0;
            }
        } else {
            //显示优惠药房
            if (self.isShowPhars) {
                return self.arrPharmacies.count+1;
            } else {
                return 0;
            }
        }
    } else if (section == 3) {
        //显示优惠药房
        if (self.isShowPhars) {
            return self.arrPharmacies.count+1;
        } else {
            return 0;
        }
    }
    return 0;
}

- (CGFloat)getCouponDetailHeight:(NSInteger)row
{
    if (row == 0) {
        return heightPlaceHolder;
    } else if (row >= 1) {
        static CouponDetailCell *sizingCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sizingCell = [self.tbViewContent dequeueReusableCellWithIdentifier:@"CouponDetailCell"];
        });
        sizingCell.lblContent.font = fontSystem(kFontS5);
        NSString *strContent = [self.arrCouponDetails objectAtIndex:row-1];
        sizingCell.lblContent.text = strContent;
//        sizingCell.constraintTop.constant = 5.0f;
//        sizingCell.constraintBottom.constant = 2.0f;
//        if (row == 1) {
//            sizingCell.constraintTop.constant = 10.0f;
//        }
        if (row == self.arrCouponDetails.count) {
//            sizingCell.constraintBottom.constant = 20.0f;
        }
        sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbViewContent.bounds), CGRectGetHeight(sizingCell.bounds));

        [sizingCell setNeedsLayout];
        [sizingCell layoutIfNeeded];
        CGSize sizeFinal = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return sizeFinal.height+1.0f;
    } else {
        return 0;
    }
}

- (CGFloat)getCouponPharmacyHeight:(NSInteger)row
{
    if (row == 0) {
        return heightPlaceHolder;
    } else {
        return [myConsultTableViewCell getCellHeight:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [VFourCouponQuanTableViewCell getCellHeight:nil] ;
    } else if (indexPath.section == 1) {
        if (self.isShowDrugs) {
            //显示优惠商品
            return heightPlaceHolder;
        } else {
            //显示优惠细则
            return [self getCouponDetailHeight:indexPath.row];
        }
    } else if (indexPath.section == 2) {
        if (self.isShowDrugs) {
            //显示优惠细则
            return [self getCouponDetailHeight:indexPath.row];
        } else {
            //显示优惠药房
            if (self.isShowPhars) {
                return [self getCouponPharmacyHeight:indexPath.row];
            } else {
                return 0;
            }
        }
    } else if (indexPath.section == 3) {
        //显示优惠药房
        if (self.isShowPhars) {
            return [self getCouponPharmacyHeight:indexPath.row];
        } else {
            return 0;
        }
    }
    return 120.0f;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section != 0) {
//        return 10.0f;
//    }
//    return 0.0f;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *viewPlaceholder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
//    viewPlaceholder.backgroundColor = RGBHex(qwColor11);
//    return viewPlaceholder;
//}

#pragma mark - 进入适用商品
-(void)jumpSuitableDrug
{
    SuitableDrugViewController *vc = [[SuitableDrugViewController alloc]init];
    vc.couponId = self.couponDetail.couponId;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 进入药房详情
-(void)jumpStoreDetail:(NSIndexPath*)indexP
{
    CouponBranchVoModel *model = self.arrPharmacies[indexP.row-1];
    
    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) { //add by jxb
        //优先判断城市是否开通微商
        if(mapInfoModel.status == 3){//城市开通微商
            //进入药房详情
            [QWGLOBALMANAGER pushBranchDetail:model.branchId withType:model.type navigation:self.navigationController];
        }
        if(mapInfoModel.status == 2){//城市未开通微商
            if([model.type intValue] == 1){//未开通微商服务的药房
                
                [QWGLOBALMANAGER pushBranchDetail:model.branchId withType:@"5" navigation:self.navigationController];
            }
            if([model.type intValue] == 2){//社会药房

                [QWGLOBALMANAGER pushBranchDetail:model.branchId withType:@"4" navigation:self.navigationController];
            }
        }
    }];
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (indexPath.section == 1) {
        if (self.isShowDrugs) {
            //显示优惠商品
            [self jumpSuitableDrug];
        } else {
        }
    } else if (indexPath.section == 2) {
        if (self.isShowDrugs) {

        } else {
            //显示优惠药房
            if (self.isShowPhars) {
                if (indexPath.row > 0) {
                    [self jumpStoreDetail:indexPath];
                }
            }
        }
    } else if (indexPath.section == 3) {
        //显示优惠药房
        if (self.isShowPhars) {
            if (indexPath.row > 0) {
                [self jumpStoreDetail:indexPath];
            }
        }
    }
}

#pragma mark - 进入我的优惠券，从药房详情/IM/推送进入领取成功后进入我的优惠券
- (void)pushToMyQuan:(id)sender{
    if(QWGLOBALMANAGER.loginStatus){
        for(UIViewController *view in self.navigationController.viewControllers){
            if([view isKindOfClass:[MyCouponQuanViewController class]]){
                [self.navigationController popToViewController:view animated:YES];
                return;
            }
        }
        MyCouponQuanViewController *myCouponQuan = [[MyCouponQuanViewController alloc]init];
        myCouponQuan.popToRootView = NO;
        [self.navigationController pushViewController:myCouponQuan animated:YES];
        
    }else{
        LoginViewController *loginView = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginView animated:YES];
    }
}

#pragma mark - 聊天按钮点击事件
- (void)takeTalk:(NSString *)branchId name:(NSString *)branchName{
    if(!QWGLOBALMANAGER.loginStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        return;
    }
    ChatViewController *consultViewController = [[UIStoryboard storyboardWithName:@"ChatViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    consultViewController.sendConsultType = Enum_SendConsult_Common;
    consultViewController.branchId = branchId;
    consultViewController.branchName = branchName;
    [self.navigationController pushViewController:consultViewController animated:YES];
}

#pragma mark - 打电话按钮点击事件
- (void)takePhone:(NSString *)telNumber{
    if(!StrIsEmpty(telNumber)){
        [[[UIAlertView alloc]initWithTitle:@"呼叫" message:telNumber delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
    }
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",alertView.message]]];
    }
}

#pragma mark - 领取HTTPRequest认证慢病
- (void)pickQuan{
    if(!QWGLOBALMANAGER.loginStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        return;
    }
    
    
    if([self.couponDetail.chronic boolValue]) {
        
        QueryFamilyMembersR *modelR = [QueryFamilyMembersR new];
        modelR.token = QWGLOBALMANAGER.configure.userToken;
        
        [FamilyMedicine checkChronicDiseaseUser:modelR success:^(ChronicDiseaseUserVoModel *model) {
            if([model.isChronicDiseaseUser isEqualToString:@"Y"])
            { 
                [self pickCoupon];
            }else{
                [PromotionCustomAlertView showCustomAlertViewAtView:self.view withTitle:@"只有慢病用户才能享受该优惠哦" andCancelButton:@"我是慢病用户" andConfirmButton:@"不领了" highLight:NO showImage:NO andCallback:^(NSInteger obj) {
                    if(obj == 0){
                        
                        if([QWUserDefault getBoolBy:CHRONIC_DISEASE])
                        {
                            FamilyMedicineListViewController *VC = [[UIStoryboard storyboardWithName:@"FamilyMedicineListViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FamilyMedicineListViewController"];
                            [self.navigationController pushViewController:VC animated:YES];
                        }else{
                            
                            [QWUserDefault setBool:YES key:CHRONIC_DISEASE];
                            
                            //进入帮助H5
                            WebDirectViewController *vcWebMedicine = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
                            WebDirectLocalModel *modelLocal = [[WebDirectLocalModel alloc] init];
                            modelLocal.typeLocalWeb = WebLocalTypeJumpChronicGuidePage;
                            [vcWebMedicine setWVWithLocalModel:modelLocal];
                            [self.navigationController pushViewController:vcWebMedicine animated:YES];
                        }
                    }
                }];
            }
        } failure:^(HttpException *e) {
            
        }];
    }else{
        [self pickCoupon];
    }
}

#pragma mark - 领取HTTPRequest
- (void)pickCoupon
{
    //comment by perry, 新的优惠券逻辑，领取后可以接着领
    ActCouponPickModelR *modelR = [ActCouponPickModelR new];
    MapInfoModel *mapInfoModel = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
    if(mapInfoModel) {
        modelR.city = mapInfoModel.city;
    }else{
        modelR.city = @"苏州市";
    }
    modelR.token = QWGLOBALMANAGER.configure.userToken;
    modelR.couponId = self.couponDetail.couponId;
    modelR.platform = @"2";
    modelR.version = APP_VERSION;
    if (self.mktgId.length > 0) {
        modelR.marketingCaseId = self.mktgId;
    } else {
        modelR.marketingCaseId = @"";
    }
    
    [Coupon actCouponPick:modelR success:^(CouponPickVoModel *myCouponVoModel) {
        if([myCouponVoModel.apiStatus integerValue] == 0) {
            //comment by perry 需要换成新的领券逻辑。
            [self setupCouponRemainCount];
            
            self.couponVoModel.myCouponId = myCouponVoModel.myCouponId;
            self.couponVoModel.pick = YES;
            self.couponVoModel.limitLeftCounts --;
            
            if (self.couponVoModel.limitLeftCounts <= 0) {
                self.couponVoModel.limitLeftCounts = 0;
            }
            [QWGLOBALMANAGER postNotif:NOtifCouponStatusChanged data:nil object:nil];
            
            //isComefrom 类型1.领券中心  2.药房详情
            if ([self.isComefrom isEqualToString:@"2"]) {
                // 药房详情
                //typeMall 类型1.未开通微商 2.社会药房 3.微商药房
                if([self.typeMall isEqualToString:@"3"]){
                    [self showSuccess:@"恭喜您，领取成功！" completion:^(BOOL finished) {
                        [self popVCAction:nil];
                    }];
                }else{
                    //2.2.4 优惠券领取成功页面 去使用(到店消费)
                    CouponSuccessViewController *successViewController = [[CouponSuccessViewController alloc] initWithNibName:@"CouponSuccessViewController" bundle:nil];
                    myCouponVoModel.status = self.couponDetail.status;
                    myCouponVoModel.begin = self.couponDetail.begin;
                    myCouponVoModel.end = self.couponDetail.end;
                    successViewController.myCouponModel = myCouponVoModel;
                    [self.navigationController pushViewController:successViewController animated:YES];
                }
            } else {
                //3.0.0 优惠券领取成功页面 立即使用
                MallCouponSuccessViewController *VC = [[MallCouponSuccessViewController alloc]initWithNibName:@"MallCouponSuccessViewController" bundle:nil];
                VC.couponId = myCouponVoModel.couponId;
                VC.myCouponId = myCouponVoModel.myCouponId;
                VC.CouponScope = self.couponDetail.scope;
                [self.navigationController pushViewController:VC animated:YES];
            }
            

        }else{
            [SVProgressHUD showErrorWithStatus:myCouponVoModel.apiMessage duration:0.8f];
        }
    } failure:^(HttpException *e) {
        
    }];
    
}


- (IBAction)pickTicket:(UIButton *)sender {
    NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
    tdParams[@"优惠券内容"]=self.couponDetail.couponRemark;
    tdParams[@"是否开通微商"] = QWGLOBALMANAGER.weChatBusiness ? @"是" : @"否";
    if (([self.couponDetail.couponNumLimit intValue] == 0)&&([self.couponDetail.pick intValue] == 1)) {
        tdParams[@"是否领完"] = @"是";
        [self pushToMyQuan:nil];
    } else {
        tdParams[@"是否领完"] = @"否";
        [self pickQuan];
    }
    [QWGLOBALMANAGER statisticsEventId:@"x_yhq_lq" withLable:@"优惠券详情" withParams:tdParams];
}

- (void)TrackEvent{
    
    if(firstPushed){
        NSString *type;
        switch([self.couponDetail.scope intValue]){
            case 1:
                type = @"通用";
                break;
            case 2:
                type = @"慢病";
                break;
            case 4:
                type = @"礼品";
                break;
            default:
                type = @"";
                break;
        }
        firstPushed = NO;
    }
}
@end