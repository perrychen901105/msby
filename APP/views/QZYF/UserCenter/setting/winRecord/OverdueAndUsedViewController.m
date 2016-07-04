//
//  OverdueAndUsedViewController.m
//  APP
//
//  Created by qw_imac on 15/11/13.
//  Copyright © 2015年 carret. All rights reserved.
//

#import "OverdueAndUsedViewController.h"
#import "winInfoCell.h"
#import "preInfoCell.h"
#import "ActivityModel.h"
#import "MyCouponDrugDetailViewController.h"
#import "MyCouponDetailViewController.h"
#import "NewWinInfoTableViewCell.h"
#import "Activity.h"
#import "WebDirectViewController.h"
#import "SVProgressHUD.h"
@interface OverdueAndUsedViewController ()<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic,strong) UITableView *tableView;
@end

@implementation OverdueAndUsedViewController
static NSString *newWinIdentifier = @"NewWinInfoTableViewCell";
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.useType isEqualToString:@"1"]) {
        self.title = @"已使用";
    }else if ([self.useType isEqualToString:@"2"]){
        self.title = @"已发放";
    }else{
        self.title = @"已过期";
    }
    [self setupUI];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(![_useType isEqualToString:@"2"]){
        if ([self.array count] == 0) {
            [self setBackground];
        }
    }else {//已发放的可以填写地址和电话，要重新请求
        [self queryGrantInfo];
    }
}

-(void)setBackground {
    if ([self.useType isEqualToString:@"1"]) {
        [self showInfoView:@"没有奖品\n快去参与活动，抽取大奖吧~" image:@"ic_img_cry"];
    }else if ([self.useType isEqualToString:@"2"]) {
        [self showInfoView:@"没有奖品\n快去参与活动，抽取大奖吧~" image:@"ic_img_cry"];
    }else{
        [self showInfoView:@"一定要在规定时间内领取使用奖品哦\n千万不要让大奖过期啦~" image:@"ic_img_hi"];
    }
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

#pragma mark - tableViewDelegate and datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.array.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LuckdrWonAwardVo *vo = (LuckdrWonAwardVo *)_array[indexPath.section];
    NewWinInfoTableViewCell *cell = (NewWinInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:newWinIdentifier];
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"NewWinInfoTableViewCell" owner:nil options:nil][0];
    }
    [cell setCell:vo];
    if ([_useType isEqualToString:@"3"]) {//已过期
        [cell.eventBtn setTitleColor:RGBHex(qwColor8) forState:UIControlStateNormal];
        cell.eventBtn.userInteractionEnabled = NO;
        cell.line.backgroundColor = RGBHex(qwColor8);
    }else if ([_useType isEqualToString:@"2"]){//已发放
        if (vo.objType == 3) {//实物
            cell.eventBtn.tag = indexPath.section;
            [cell.eventBtn addTarget:self action:@selector(fillAddress:) forControlEvents:UIControlEventTouchUpInside];
        }else if (vo.objType == 5){//充话费
            cell.eventBtn.tag = indexPath.section;
            [cell.eventBtn addTarget:self action:@selector(fillNo:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
#pragma mark - H5
-(void)fillAddress:(UIButton *)sender {
    WebDirectViewController *vcWebMedicine = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
    LuckdrWonAwardVo *vo = _array[sender.tag];
    WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
    //    modelLocal.typeLocalWeb = WebLocalTypeOther;
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
    LuckdrWonAwardVo *vo = _array[sender.tag];
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
     LuckdrWonAwardVo *vo = self.array[indexPath.section];
    switch (vo.objType) {
        case 1:                         //优惠券
        {
            MyCouponDetailViewController *viewController = [[MyCouponDetailViewController alloc]init];
            viewController.myCouponId = vo.pickedObjId;
            viewController.couponId = vo.pickedObjId;
            
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LuckdrWonAwardVo *vo = self.array[indexPath.section];
    if(vo.objType==3||vo.objType==5){
//        if(vo.objType == 3 && !vo.postAddrEmpty){
//            static dispatch_once_t once;
//            static NewWinInfoTableViewCell *cell = nil;
//            dispatch_once(&once, ^{
//                cell = [self.tableView dequeueReusableCellWithIdentifier:newWinIdentifier];
//            });
//            cell.eventShowInfo.preferredMaxLayoutWidth = APP_W - 30;
//            [cell setCell:vo];
//            cell.bounds = CGRectMake(0, 0, CGRectGetWidth(self.tableMain.bounds), CGRectGetHeight(cell.bounds));
//            [cell setNeedsLayout];
//            [cell layoutIfNeeded];
//            CGSize size = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//            return size.height + 1;
//        }else {
            return 124;
//        }
    }else {
        return 105;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 6.0;
}

-(void)queryGrantInfo {
    QueryWonAwardsR *modelR = [QueryWonAwardsR new];
    modelR.mobile = QWGLOBALMANAGER.configure.mobile;
    modelR.token = QWGLOBALMANAGER.configure.userToken;
    [Activity getWonAwards:modelR success:^(LuckdrawAwardListVo *responModel) {
        if(responModel.grant.count == 0){
            [self setBackground];
        }else {
             self.array =[NSMutableArray arrayWithArray:responModel.grant];
            [self.tableView reloadData];
        }
    } failure:^(HttpException *e) {
        
    }];

}
@end