//
//  MedicineSearchResultViewController.h
//  APP
//  
//  Created by 李坚 on 16/1/7.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "QWBaseVC.h"
#import "ConsultStore.h"

@interface MedicineSearchResultViewController : QWBaseVC

@property (nonatomic, assign) BOOL IMPushed;
@property (nonatomic, strong) NSString *productCode;
@property (nonatomic, strong) NSString *lastPageName;
@property (nonatomic, strong) NSString *couponId;//1 从优惠券的适用商品进来的

@end


@interface MedicineSearchHeaderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *proName;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerHeight;
+ (MedicineSearchHeaderView *)getView;
@end