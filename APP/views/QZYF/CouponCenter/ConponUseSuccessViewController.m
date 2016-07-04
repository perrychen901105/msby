//
//  ConponUseSuccessViewController.m
//  APP
//
//  Created by garfield on 15/8/20.
//  Copyright (c) 2015年 carret. All rights reserved.
//

#import "ConponUseSuccessViewController.h"
#import "swiftModule-swift.h"
#import "PromotionCustomAlertView.h"
#import "RatingView.h"
#import "GiftVoucherAlertView.h"
#import "MyCouponQuanViewController.h"
#import "MyCouponDrugViewController.h"

@interface ConponUseSuccessViewController ()<UIAlertViewDelegate>

//@property (weak, nonatomic) IBOutlet UIButton *btn;
//@property (weak, nonatomic) IBOutlet UILabel *savePriceLabel;
//@property (weak, nonatomic) IBOutlet RatingView *ratingView;
//@property (weak, nonatomic) IBOutlet UILabel *giftLabel;
//@property (weak, nonatomic) IBOutlet UILabel *saveTitle;

@end

@implementation ConponUseSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [QWGLOBALMANAGER appUseCoupon];//成功使用过一次优惠券
    
    self.title = @"使用成功";
    self.view.backgroundColor=[UIColor whiteColor];


//    _savePriceLabel.text = [NSString stringWithFormat:@"%.2f元",[_checkModel.discount floatValue]];
//    [self.ratingView setImagesDeselected:@"star_none_big" partlySelected:@"star_half_big" fullSelected:@"star_full_big" andDelegate:self];
//    
//    //如果是礼品券,并且是第一次赠送礼品,需要显示特殊的弹框提示礼品
//    if(_checkModel.gifts && _checkModel.gifts.count > 0) {
//        
//        CouponGiftVoModel *giftModel = _checkModel.gifts[0];
//        [GiftVoucherAlertView showAlertViewAtView:self.view withVoucher:giftModel.name andCount:[giftModel.quantity integerValue] andImageName:giftModel.imgUrl callBack:^(id obj) {
//            
////            [self showCustomAlertView];
//        }];
//        self.giftLabel.text = [NSString stringWithFormat:@"获得礼品: %@",_checkModel.gift];
//        self.savePriceLabel.hidden = YES;
//        self.saveTitle.hidden = YES;
//        self.giftLabel.hidden = NO;
//    }
//    else{
//        //弹框分享
////        [self showCustomAlertView];
//        //礼品券和分礼品券区别,UI显示不同
//        if([_checkModel.scope integerValue]== 4)
//        {
//            self.giftLabel.text = [NSString stringWithFormat:@"获得礼品: %@",_checkModel.gift];
//            self.savePriceLabel.hidden = YES;
//            self.saveTitle.hidden = YES;
//            self.giftLabel.hidden = NO;
//        }else{
//    
//            self.giftLabel.hidden = YES;
//        }
//    }
//    //设置赠送Button的UI
//    [self.btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
//    if(self.checkModel && self.checkModel.presentType && ![self.checkModel.presentType isEqualToString:@""]){
//        
//        if([self.checkModel.presentType isEqualToString:@"Q"]){
//            //送优惠券
//            self.btn.hidden = NO;
//            [self.btn setTitle:@"问药君送您一张优惠券哟，快来查看吧" forState:UIControlStateNormal];
//        }
//        if([self.checkModel.presentType isEqualToString:@"P"]){
//            //送优惠商品
//            self.btn.hidden = NO;
//            [self.btn setTitle:@"问药君送您一份优惠商品哟，快来查看吧" forState:UIControlStateNormal];
//        }
//    }else{
//        self.btn.hidden = YES;
//    }
//    self.savePriceLabel.hidden = YES;
//    self.saveTitle.hidden = YES;
}

#pragma mark - 赠送券Btn点击事件
- (void)btnClick{
    
    if([self.checkModel.presentType isEqualToString:@"Q"] && self.checkModel.presentCoupons.count >0){
        
        //跳转我的优惠券
        MyCouponQuanViewController *VC = [[MyCouponQuanViewController alloc]init];
        [self.navigationController pushViewController:VC animated:YES];
    }
    if([self.checkModel.presentType isEqualToString:@"P"] && self.checkModel.presentPromotions.count >0){
        
        //跳转我的优惠商品
        MyCouponDrugViewController *VC = [[MyCouponDrugViewController alloc]init];
        [self.navigationController pushViewController:VC animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((QWBaseNavigationController *)self.navigationController).canDragBack = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ((QWBaseNavigationController *)self.navigationController).canDragBack = YES;
}

- (void)showCustomAlertView
{
    [PromotionCustomAlertView showCustomAlertViewAtView:self.view withTitle:@"分享给小伙伴们,赢取更多优惠大礼包噢!" andCancelButton:@"挥泪放弃" andConfirmButton:@"分享" highLight:YES showImage:YES andCallback:^(NSInteger obj) {
        //如果选择分享则跳出分享的UI
        if(obj == 1) {
            
            //点击分享  由原来的使用后的分享大礼包更改为使用前的分享优惠券  cj
            
            ShareContentModel *modelShare = [[ShareContentModel alloc] init];
            modelShare.typeShare    = ShareTypeMyCoupon;
            //self.checkModel.groupId没有传空
            NSArray *arrParams      = @[self.checkModel.couponId,@""];
            if([self.checkModel.scope intValue] == 4){
                modelShare.imgURL   = self.checkModel.giftImgUrl;
            }
            modelShare.shareID      = modelShare.shareID = [arrParams componentsJoinedByString:SeparateStr];
            modelShare.title        = self.checkModel.couponTitle;
            modelShare.content      = self.checkModel.desc;
            
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
            modelR.shareObjId = self.checkModel.couponId;
            modelShare.modelSavelog = modelR;
            [self popUpShareView:modelShare];

        }else{
          
        }
    }];
}

//选择星级评价后,立马跳入评价界面
-(void)ratingChangeEnded:(float)newRating
{
    EvaluateCouponViewController *evaluationViewController = [[EvaluateCouponViewController alloc] initWithNibName:@"EvaluateCouponViewController" bundle:nil];
    evaluationViewController.stars = newRating;
    evaluationViewController.orderCheckModel = _checkModel;
    [self.navigationController pushViewController:evaluationViewController animated:YES];
   }


//特殊逻辑,需要之前导航栈中是否存在我的优惠券界面,如果有则跳入,否则推入新的 我的优惠券界面
- (IBAction)popVCAction:(id)sender
{
    __block UIViewController *popViewController = nil;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *viewController = (UIViewController *)obj;
        if([viewController isKindOfClass:[MyCouponQuanViewController class]]){
            popViewController = viewController;
        }
    }];
    if(popViewController) {
        ((MyCouponQuanViewController *)popViewController).shouldJump = YES;
        [self.navigationController popToViewController:popViewController animated:YES];
    }else{
        MyCouponQuanViewController *myCouponQuanViewController = [MyCouponQuanViewController new];
        myCouponQuanViewController.shouldJump = YES;
        [self.navigationController pushViewController:myCouponQuanViewController animated:YES];
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 888) {
        if(buttonIndex == 0) {
            
        }
    }else{
        
        
        
    }
}

- (void)didSelectedAtIndex:(NSInteger)index
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"分享给小伙伴们，赢取更多优惠大礼包噢！" delegate:self cancelButtonTitle:@"我要抢优惠" otherButtonTitles:@"挥泪放弃", nil];
    alertView.tag = 888;
    [alertView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
