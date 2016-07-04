//
//  WinDetialViewController.m
//  APP
//
//  Created by qw_imac on 15/11/11.
//  Copyright © 2015年 carret. All rights reserved.
//

#import "WinDetialViewController.h"
#import "winInfoCell.h"
#import "preInfoCell.h"
#import "OverdueAndUsedViewController.h"
#import "Activity.h"
#import "ActivityModel.h"
#import "ActivityModelR.h"
#import "LoginViewController.h"
#import "MyCouponDrugDetailViewController.h"
#import "MyCouponDetailViewController.h"
#import "winTableViewCell.h"
#import "NewWinInfoTableViewCell.h"
#import "WebDirectViewController.h"
#import "SVProgressHUD.h"
@interface WinDetialViewController ()
{
    NSMutableArray *winArray;
    NSMutableArray *usedArray;
    NSMutableArray *overdueArray;
    NSMutableArray *grantArray;
}
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation WinDetialViewController
static NSString *newWinIdentifier = @"NewWinInfoTableViewCell";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"中奖记录";
    winArray = [NSMutableArray array];
    usedArray = [NSMutableArray array];
    overdueArray =[NSMutableArray array];
    grantArray =[NSMutableArray array];
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryWinInfo];
}

-(void)popVCAction:(id)sender {
    [super popVCAction:sender];
    
    [QWGLOBALMANAGER statisticsEventId:@"x_wd_zjjl_fh" withLable:@"中奖纪录" withParams:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setupUI {
    self.tableView =[[UITableView alloc] initWithFrame:CGRectMake(0, 0 , APP_W, [[UIScreen mainScreen] bounds].size.height - 64) style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.scrollEnabled = YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"NewWinInfoTableViewCell" bundle:nil] forCellReuseIdentifier:newWinIdentifier];
    [self.view addSubview:self.tableView];
}

#pragma mark - tableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return winArray.count + 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
//    static NSString *winIdentifier = @"WinCell";
//    static NSString *preIdentifier = @"PreCell";
    if (indexPath.section == winArray.count) {
        NSArray *cells = [[NSBundle mainBundle]loadNibNamed:@"winTableViewCell" owner:nil options:nil];
        winTableViewCell *cell = [cells objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tLabel.text = @"已使用";
        return cell;
    }else if (indexPath.section == winArray.count +1 ) {
        NSArray *cells = [[NSBundle mainBundle]loadNibNamed:@"winTableViewCell" owner:nil options:nil];
        winTableViewCell *cell = [cells objectAtIndex:0];
         cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tLabel.text = @"已发放";
        return cell;
    }else if (indexPath.section == winArray.count + 2){
        NSArray *cells = [[NSBundle mainBundle]loadNibNamed:@"winTableViewCell" owner:nil options:nil];
        winTableViewCell *cell = [cells objectAtIndex:0];
         cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tLabel.text = @"已过期";
        return cell;
    }else {
        if (winArray.count > 0) {
            LuckdrWonAwardVo *vo = (LuckdrWonAwardVo *)winArray[indexPath.section];
//            winInfoCell *cellWin = (winInfoCell *)[tableView dequeueReusableCellWithIdentifier:winIdentifier];
//            preInfoCell *cellPre = (preInfoCell *)[tableView dequeueReusableCellWithIdentifier:preIdentifier];
//            if(vo.objType==1||vo.objType==2){
//                if (!cellWin) {
//                    NSArray *cellsWin = [[NSBundle mainBundle]loadNibNamed:@"winInfoCell" owner:nil options:nil];
//                    cellWin = [cellsWin objectAtIndex:0];
//                }
//                cellWin.selectionStyle = UITableViewCellSelectionStyleNone;
//                [cellWin setCell:winArray[indexPath.section]];
//                return cellWin;
//            }else{
//                if (!cellPre) {
//                    NSArray *cellsPre = [[NSBundle mainBundle]loadNibNamed:@"preInfoCell" owner:nil options:nil];
//                    cellPre = [cellsPre objectAtIndex:0];
//                }
//                cellPre.selectionStyle = UITableViewCellSelectionStyleNone;
//                [cellPre setCell:winArray[indexPath.section]];
//                return cellPre;
//            }
            NewWinInfoTableViewCell *cell = (NewWinInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:newWinIdentifier];
            [cell setCell:vo];
            if (!cell) {
                cell = [[NSBundle mainBundle]loadNibNamed:@"NewWinInfoTableViewCell" owner:nil options:nil][0];
            }
            if (vo.objType == 3) {//实物
                cell.eventBtn.tag = indexPath.section;
                [cell.eventBtn addTarget:self action:@selector(fillAddress:) forControlEvents:UIControlEventTouchUpInside];
            }else if (vo.objType == 5){//充话费
                cell.eventBtn.tag = indexPath.section;
                [cell.eventBtn addTarget:self action:@selector(fillNo:) forControlEvents:UIControlEventTouchUpInside];
            }
             cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else {
            return nil;
        }
        
    }
}
#pragma mark - H5
-(void)fillAddress:(UIButton *)sender {
//http://192.168.5.191:8184/QWWEB/activity/html/addAddress.html?id=13123&sourceType=0
    WebDirectViewController *vcWebMedicine = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
    LuckdrWonAwardVo *vo = winArray[sender.tag];
    WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
    modelLocal.title = @"添加地址";
    modelLocal.typeTitle = WebTitleTypeNone;
    modelLocal.url = [NSString stringWithFormat:@"%@/QWWEB/activity/html/addAddress.html?id=%@&sourceType=0",DE_H5_DOMAIN_URL,vo.id];
    vcWebMedicine.winAlert = ^{
        [SVProgressHUD showSuccessWithStatus:@"奖品收货地址填写成功！请保持电话畅通，方便快递联系您哦。" duration:2.0];
    };
    [vcWebMedicine setWVWithLocalModel:modelLocal];
    [self.navigationController pushViewController:vcWebMedicine animated:YES];

}

-(void)fillNo:(UIButton *)sender {
    WebDirectViewController *vcWebMedicine = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
    LuckdrWonAwardVo *vo = winArray[sender.tag];
    WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
    modelLocal.title = @"填写充值手机";
    modelLocal.typeTitle = WebTitleTypeNone;
    modelLocal.url = [NSString stringWithFormat:@"%@/QWWEB/activity/html/addTel.html?id=%@&sourceType=0",DE_H5_DOMAIN_URL,vo.id];
    vcWebMedicine.winAlert = ^{
        [SVProgressHUD showSuccessWithStatus:@"手机填写成功！活动结束后统一充值话费。" duration:2.0];
    };
    [vcWebMedicine setWVWithLocalModel:modelLocal];
    [self.navigationController pushViewController:vcWebMedicine animated:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 6)];
    view.backgroundColor = RGBHex(qwColor11);
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
    [QWGLOBALMANAGER statisticsEventId:@"x_we_zjjl_dj" withLable:@"中奖纪录" withParams:nil];
    if (indexPath.section == winArray.count ) {  //已使用
        OverdueAndUsedViewController *viewController = [OverdueAndUsedViewController new];
        viewController.useType=@"1";
        viewController.array = usedArray;
        [self.navigationController pushViewController:viewController animated:YES];
        return;
    }else if (indexPath.section == winArray.count + 1 ) {  //已发放
        OverdueAndUsedViewController *viewController = [OverdueAndUsedViewController new];
        viewController.useType=@"2";
        //已发放的重新请求一下
//        viewController.array = grantArray;
        [self.navigationController pushViewController:viewController animated:YES];
        return;
    }else  if (indexPath.section == winArray.count + 2) {  //已过期
        OverdueAndUsedViewController *viewController = [OverdueAndUsedViewController new];
        viewController.useType=@"3";
        viewController.array = overdueArray;
        [self.navigationController pushViewController:viewController animated:YES];
        return;
    }else {
        LuckdrWonAwardVo *vo = winArray[indexPath.section];
        
        switch (vo.objType) {
            case 1:                         //优惠券
            {
                MyCouponDetailViewController *viewController = [MyCouponDetailViewController new];
                viewController.myCouponId = vo.pickedObjId;
                viewController.couponId=vo.pickedObjId;
                [self.navigationController pushViewController:viewController animated:YES];
            }
                
                break;
                
            case 2:                         //优惠商品
            {
                
                MyCouponDrugDetailViewController *viewController = [MyCouponDrugDetailViewController new];
                viewController.proDrugId = vo.pickedObjId;
                
                [self.navigationController pushViewController:viewController animated:YES];
            }
                break;
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    if (section < winArray.count ) {
        LuckdrWonAwardVo *vo = (LuckdrWonAwardVo *)winArray[section];
        if(vo.objType==3||vo.objType==5){
//            if(vo.objType == 3 && !vo.postAddrEmpty){
//                static dispatch_once_t once;
//                static NewWinInfoTableViewCell *cell = nil;
//                dispatch_once(&once, ^{
//                    cell = [self.tableView dequeueReusableCellWithIdentifier:newWinIdentifier];
//                });
//                cell.eventShowInfo.preferredMaxLayoutWidth = APP_W - 30;
//                [cell setCell:vo];
//                cell.bounds = CGRectMake(0, 0, CGRectGetWidth(self.tableMain.bounds), CGRectGetHeight(cell.bounds));
//                [cell setNeedsLayout];
//                [cell layoutIfNeeded];
//                CGSize size = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//                return size.height + 1;
//            }else {
                return 124;
//            }
        }else {
            return 105;
        }
    }else {
        return 44.0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 6.0;
}
#pragma mark - networking

-(void)login {
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [self showInfoInView:self.tableView offsetSize:0 text:@"网络未连通，请重试" image:@"网络信号icon"];
    }else {
        if (!QWGLOBALMANAGER.loginStatus) {
            LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            login.isPresentType = YES;
            login.parentNavgationController = self.navigationController;
            UINavigationController * nav = [[QWBaseNavigationController alloc] initWithRootViewController:login];
            [self presentViewController:nav animated:YES completion:nil];
            return;
        }
    }
}

-(void)queryWinInfo {
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [self showInfoInView:self.tableView offsetSize:0 text:@"网络未连通，请重试" image:@"网络信号icon"];
    }else {
        if (!QWGLOBALMANAGER.loginStatus) {
            return;
        }else {
            QueryWonAwardsR *modelR = [QueryWonAwardsR new];
            modelR.mobile = QWGLOBALMANAGER.configure.mobile;
            modelR.token = QWGLOBALMANAGER.configure.userToken;
            [Activity getWonAwards:modelR success:^(LuckdrawAwardListVo *responModel) {
                if (responModel.awards && responModel.awards.count){
                    winArray = [NSMutableArray arrayWithArray:responModel.awards];
                }
                if (responModel.used && responModel.used.count){
                    usedArray = [NSMutableArray arrayWithArray:responModel.used];
                }
                if(responModel.overdue && responModel.overdue.count){
                    overdueArray = [NSMutableArray arrayWithArray:responModel.overdue];
                }
                if(responModel.grant && responModel.grant.count){
                    grantArray =[NSMutableArray arrayWithArray:responModel.grant];
                }
                [self.tableView reloadData];
                NSString *hasContent;
                if(winArray>0||usedArray>0||overdueArray>0||grantArray>0) {
                    hasContent = @"有内容";
                }else {
                    hasContent = @"无内容";
                }
                NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
                tdParams[@"有无内容"]=hasContent;
                [QWGLOBALMANAGER statisticsEventId:@"x_wd_zjjl" withLable:@"中奖纪录" withParams:tdParams];
            } failure:^(HttpException *e) {
                
            }];
        }
    }
//    LuckdrWonAwardVo *vo = [LuckdrWonAwardVo new];
//    vo.title = @"ceshi";
//    vo.objType = 3;vo.objId = @"13123";
//    vo.postAddrEmpty = YES;
//    
//    LuckdrWonAwardVo *vo1 = [LuckdrWonAwardVo new];
//    vo1.title = @"ceshi";
//    vo1.objType = 3;
//    vo1.objId = @"13123";
//    vo1.postAddrEmpty = NO;
//    vo1.postNick = @"1";
//    vo1.postMobile = @"123";
//    vo1.postAddr = @"这是什么情况呀这是什么情况呀这是什么情况呀这是什么情况呀";
//    
//    LuckdrWonAwardVo *vo2 = [LuckdrWonAwardVo new];
//    vo2.title = @"ceshi";
//    vo2.objType = 5;
//    vo2.chargeNoEmpty = YES;
//    
//    LuckdrWonAwardVo *vo3 = [LuckdrWonAwardVo new];
//    vo3.title = @"ceshi";
//    vo3.objType = 5;
//    vo3.chargeNoEmpty = NO;
//    vo3.chargeNo = @"123456";
//    
//    LuckdrWonAwardVo *vo4 = [LuckdrWonAwardVo new];
//    vo4.title = @"ceshi";
//    vo4.objType = 4;
// 
//
//    winArray = [@[vo,vo1,vo2,vo3,vo4] mutableCopy];
//    [self.tableView reloadData];
}


@end
