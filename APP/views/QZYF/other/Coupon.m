//
//  Coupon.m
//  APP
//
//  Created by 李坚 on 15/3/9.
//  Copyright (c) 2015年 carret. All rights reserved.
//

#import "Coupon.h"
#import "Activity.h"

@implementation Coupon


//适用分店仅限于当前商家当前城市的门店
+(void)couponBranchSuitable:(CouponBranchSuitableModelR *)mode success:(void (^)(CouponBranchVoListModel *))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:CouponBranchSuitable params:[mode dictionaryModel] success:^(id responseObj) {
        
        CouponBranchVoListModel *coupon = [CouponBranchVoListModel parse:responseObj Elements:[CouponBranchVoModel class] forAttribute:@"suitableBranchs"];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

//获取我的优惠券详情2.2.0 add by lijian
+(void)couponGetMyCoupon:(CouponGetModelR *)mode success:(void (^)(id))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:CouponGetMyCoupon params:[mode dictionaryModel] success:^(id responseObj) {
        
        MyCouponDetailVoListModel *coupon = [MyCouponDetailVoListModel parse:responseObj Elements:[CouponBranchVoModel class] forAttribute:@"suitableBranchs"];
        
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}
/**
 *  优惠券领取成功页面优惠券适用门店列表 add by lijian At 3.0.0
 */
+ (void)PickSuccessSuitableBranchs:(GetOnlineCouponModelR *)mode success:(void (^)(SuitableMicroMallBranchListVo *))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:Coupon300BranchSuitable params:[mode dictionaryModel] success:^(id responseObj) {
        SuitableMicroMallBranchListVo *coupon = [MyCouponDetailVoListModel parse:responseObj Elements:[SuitableMicroMallBranchVo class] forAttribute:@"suitableBranchs"];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+ (void)getOnlineCoupon:(GetOnlineCouponModelR *)mode success:(void (^)(MyCouponDetailVoListModel *))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:CouponGetOnlineCoupon params:[mode dictionaryModel] success:^(id responseObj) {
        MyCouponDetailVoListModel *coupon = [MyCouponDetailVoListModel parse:responseObj Elements:[CouponBranchVoModel class] forAttribute:@"suitableBranchs"];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}


+ (void)getNewOnlineCoupon:(GetNewOnlineCouponModelR *)mode success:(void (^)(MyCouponDetailVoListModel *))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:CouponNewGetOnlineCoupon params:[mode dictionaryModel] success:^(id responseObj) {
        MyCouponDetailVoListModel *coupon = [MyCouponDetailVoListModel parse:responseObj Elements:[CouponBranchVoModel class] forAttribute:@"suitableBranchs"];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}


//400版本的新接口
+(void)couponCenterShow:(CouponShowModelR *)mode success:(void (^)(UseMyCouponVoModel *))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:GetShowCode params:[mode dictionaryModel] success:^(id responseObj) {
        UseMyCouponVoModel *model = [UseMyCouponVoModel parse:responseObj];
        if (success) {
            success(model);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}



+(void)couponSuitableDrug:(GetCouponDetailProductModelR *)modelR success:(void (^)(id))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:GetCouponDetailProduct params:[modelR dictionaryModel] success:^(id responseObj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([CouponProductVoModel class])];
        
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"suitableProducts"];
        
        CouponProductVoListModel *couponList = [CouponProductVoListModel parse:responseObj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(couponList);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
    
}



+ (void)getCenterCouponDetail:(GetCenterCouponDetailModelR *)mode success:(void (^)(OnlineCouponDetailVo *))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:GetCouponCenterDetail params:[mode dictionaryModel] success:^(id responseObj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([CouponBranchVoModel class])];
        
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"suitableBranchs"];
        
        OnlineCouponDetailVo *coupon = [OnlineCouponDetailVo parse:responseObj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}


+(void)getMyCouponDetail:(GetMyCouponDetailModelR *)mode success:(void (^)(id))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:GetCouponMyDetail params:[mode dictionaryModel] success:^(id responseObj) {
        
        MyCouponDetailVo *coupon = [MyCouponDetailVo parse:responseObj Elements:[CouponBranchVoModel class] forAttribute:@"suitableBranchs"];
        
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}



+(void)couponGetOnlineCoupon:(GetOnlineCouponModelR *)mode success:(void (^)(OnlineCouponDetailVoListModel *))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:CouponGetOnlineCoupon params:[mode dictionaryModel] success:^(id responseObj) {
        OnlineCouponDetailVoListModel *coupon = [OnlineCouponDetailVoListModel parse:responseObj Elements:[CouponBranchVoModel class] forAttribute:@"suitableBranchs"];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}


+(void)couponProductSuitable:(CouponProductSuitableModelR *)mode success:(void (^)(CouponProductVoListModel *))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:CouponProductSuitable params:[mode dictionaryModel] success:^(CouponProductVoListModel * responseObj) {
        CouponProductVoListModel *coupon = [CouponProductVoListModel parse:responseObj Elements:[CouponProductVoModel class] forAttribute:@"suitableProducts"];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}


+(void)couponAssess:(PromotionBranchModelR *)mode success:(void (^)(id))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] put:CouponAssess params:[mode dictionaryModel] success:^(id responseObj) {
        if (success) {
            success(responseObj);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+(void)couponAssessQuery:(PromotionBranchModelR *)mode success:(void (^)(id))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:CouponAssessQuery params:[mode dictionaryModel] success:^(id responseObj) {
        if (success) {
            success(responseObj);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+(void)couponBranchBuy:(PromotionBranchModelR *)mode success:(void (^)(id))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:CouponBranchBuy params:[mode dictionaryModel] success:^(id responseObj) {
        CouponBranchVoListModel *coupon = [CouponBranchVoListModel parse:responseObj Elements:[CouponBranchVoModel class] forAttribute:@"suitableBranchs"];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+(void)couponCheck:(PromotionBranchModelR *)mode success:(void (^)(id))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:CouponCheck params:[mode dictionaryModel] success:^(id responseObj) {
        if (success) {
            success(responseObj);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+(void)couponPick:(CouponPickModelR *)mode success:(void (^)(CouponPickVoModel *))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:CouponPick params:[mode dictionaryModel] success:^(id responseObj) {
        CouponPickVoModel *coupon = [CouponPickVoModel parse:responseObj];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+(void)actCouponPick:(ActCouponPickModelR *)mode success:(void (^)(CouponPickVoModel *))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:GetCouponPick params:[mode dictionaryModel] success:^(id responseObj) {
        CouponPickVoModel *coupon = [CouponPickVoModel parse:responseObj];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+(void)couponPickByMobile:(PromotionBranchModelR *)mode success:(void (^)(id))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:CouponPickByMobile params:[mode dictionaryModel] success:^(id responseObj) {
        MyCouponVoModel *coupon = [MyCouponVoModel parse:responseObj];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+(void)couponConditions:(BaseAPIModel *)mode success:(void (^)(ConditionAmountVoListModel *model))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:CouponCondition params:[mode dictionaryModel] success:^(id responseObj) {
        ConditionAmountVoListModel *coupon = [ConditionAmountVoListModel parse:responseObj Elements:[ConditionAmountVoModel class] forAttribute:@"conditions"];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}


+(void)couponProductBuy:(PromotionBranchModelR *)mode success:(void (^)(id))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:CouponProductBuy params:[mode dictionaryModel] success:^(id responseObj) {
        CouponProductVoListModel *coupon = [CouponProductVoListModel parse:responseObj Elements:[CouponProductVoModel class] forAttribute:@"suitableProducts"];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+ (void)couponQueryInCity:(CouponQueryInCityModelR *)mode success:(void (^)(OnlineCouponVoListModel *model))success failure:(void (^)(HttpException *))failure
{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] get:CouponInCity params:[mode dictionaryModel] success:^(id responseObj) {
        OnlineCouponVoListModel *couponList1 = [OnlineCouponVoListModel parse:responseObj Elements:[OnlineCouponVoModel class] forAttribute:@"topCoupons"];
        OnlineCouponVoListModel *couponList2 = [OnlineCouponVoListModel parse:responseObj Elements:[OnlineCouponVoModel class] forAttribute:@"coupons"];
        couponList1.coupons = couponList2.coupons;
        couponList1.apiStatus = [NSNumber numberWithLong:[couponList1.apiStatus longValue]];
        if(couponList1.topCoupons.count > 0 && [couponList1.page integerValue] == 1) {
            for(OnlineCouponVoModel *model in couponList1.topCoupons) {
                model.top = YES;
            }
            NSMutableArray *array = [NSMutableArray arrayWithArray:couponList1.topCoupons];
            if(couponList1.coupons.count > 0) {
                [array addObjectsFromArray:couponList1.coupons];
            }
            couponList1.coupons = array;
            couponList1.topCoupons = [NSMutableArray arrayWithCapacity:1];
        }
        if (success) {
            success(couponList1);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}


+ (void)couponQueryOnlineByCustomer:(CouponQueryOnlineByCustomerModelR *)mode success:(void (^)(OnlineCouponVoListModel *model))success failure:(void (^)(HttpException *))failure
{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] get:CouponQueryNewOnlineByCustomer params:[mode dictionaryModel] success:^(id responseObj) {
        OnlineCouponVoListModel *couponList1 = [OnlineCouponVoListModel parse:responseObj Elements:[OnlineCouponVoModel class] forAttribute:@"topCoupons"];
        OnlineCouponVoListModel *couponList2 = [OnlineCouponVoListModel parse:responseObj Elements:[OnlineCouponVoModel class] forAttribute:@"coupons"];
        couponList1.coupons = couponList2.coupons;
        couponList1.apiStatus = [NSNumber numberWithLong:[couponList1.apiStatus longValue]];
        if(couponList1.topCoupons.count > 0) {
            for(OnlineCouponVoModel *model in couponList1.topCoupons) {
                model.top = YES;
            }
            NSMutableArray *array = [NSMutableArray arrayWithArray:couponList1.topCoupons];
            if(couponList1.coupons.count > 0) {
                [array addObjectsFromArray:couponList1.coupons];
            }
            couponList1.coupons = array;
            couponList1.topCoupons = [NSMutableArray arrayWithCapacity:1];
        }
        if (success) {
            success(couponList1);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+(void)couponQueryBranchFournNew:(BranchFournNewModelR *)mode success:(void (^)(BranchCouponListVoModel *model))success failure:(void (^)(HttpException *))failure
{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] get:CouponByBranch4New params:[mode dictionaryModel] success:^(id responseObj) {
        BranchCouponListVoModel *couponList = [BranchCouponListVoModel parse:responseObj Elements:[OnlineCouponVoModel class] forAttribute:@"coupons"];
        couponList.apiStatus = [NSNumber numberWithLong:[couponList.apiStatus longValue]];
        
        if (success) {
            success(couponList);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+ (void)couponOrderCheck:(CouponOrderCheckVoModelR *)mode success:(void (^)(CouponOrderCheckVo *))success failure:(void (^)(HttpException *))failure
{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] getWithoutProgress:CouponOrderCheck params:[mode dictionaryModel] success:^(id responseObj) {
        //2.2.4分享大礼包更改为分享优惠券和优惠商品
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([CouponGiftVoModel class])];
        [keyArray addObject:NSStringFromClass([PresentPromotionVo class])];
        [keyArray addObject:NSStringFromClass([PresentCouponVo class])];
        
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"gifts"];
        [valueArray addObject:@"presentPromotions"];
        [valueArray addObject:@"presentCoupons"];
        
        CouponOrderCheckVo *checkModel = [CouponOrderCheckVo parse:responseObj ClassArr:keyArray Elements:valueArray];

        if (success) {
            success(checkModel);
        }
        
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+(void)couponQueryOverdueByCustomer:(PromotionBranchModelR *)mode success:(void (^)(id))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:CouponQueryOverdueByCustomer params:[mode dictionaryModel] success:^(id responseObj) {
        MyOverdueCouponVoListModel *coupon = [MyOverdueCouponVoListModel parse:responseObj Elements:[MyCouponVoModel class] forAttribute:@"coupons"];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+(void)couponQueryUnusedByCustomer:(PromotionBranchModelR *)mode success:(void (^)(id))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:CouponQueryUnusedByCustomer params:[mode dictionaryModel] success:^(id responseObj) {
        MyCouponVoListModel *coupon = [MyCouponVoListModel parse:responseObj Elements:[MyCouponVoModel class] forAttribute:@"coupons"];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+(void)couponQueryUsedByCustomer:(PromotionBranchModelR *)mode success:(void (^)(id))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:CouponQueryUsedByCustomer params:[mode dictionaryModel] success:^(id responseObj) {
        MyUsedCouponVoListModel *coupon = [MyUsedCouponVoListModel parse:responseObj Elements:[MyCouponVoModel class] forAttribute:@"coupons"];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+(void)couponUse:(PromotionBranchModelR *)mode success:(void (^)(id))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:CouponUse params:[mode dictionaryModel] success:^(id responseObj) {
        if (success) {
            success(responseObj);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+(void)couponShow:(CouponShowModelR *)mode success:(void (^)(UseMyCouponVoModel *))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:CouponShow params:[mode dictionaryModel] success:^(id responseObj) {
        UseMyCouponVoModel *model = [UseMyCouponVoModel parse:responseObj];
        if (success) {
            success(model);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

//药房详情获取优惠券 add by lijian 2.2.0
+(void)pharmacyCouponQuan:(pharmacyCouponModelR *)model success:(void (^)(id))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:ConsultDetailCouponQuan params:[model dictionaryModel] success:^(id responseObj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([pharmacyCouponQuan class])];
        
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"list"];
        
        pharmacyCouponQuanList *bannerList = [pharmacyCouponQuanList parse:responseObj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(bannerList);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];

}

//药房详情获取优惠券 add by lijian V3.1.1
+ (void)mallBranchCouponQuan:(pharmacyCouponModelR *)model success:(void (^)(OnlineCouponVoListModel *))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:MallBranchDetailCouponQuan params:[model dictionaryModel] success:^(id responseObj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([OnlineCouponVoModel class])];
        
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"coupons"];
        
        OnlineCouponVoListModel *couponQuanList = [OnlineCouponVoListModel parse:responseObj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(couponQuanList);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
    
}

//药房详情获取优惠商品 add by lijian 2.2.0
+(void)pharmacyCouponDrug:(pharmacyCouponModelR *)model success:(void (^)(id))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:ConsultDetailCouponDrug params:[model dictionaryModel] success:^(id responseObj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([pharmacyCouponDrug class])];
        
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"list"];
        
        pharmacyCouponQuanList *bannerList = [pharmacyCouponQuanList parse:responseObj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(bannerList);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}


//药房详情获取优惠商品 add by cj 2.2.3
+(void)pharmacyCouponDrugNew:(pharmacyProductModelR *)model success:(void (^)(id))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:storeProduct params:[model dictionaryModel] success:^(id responseObj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([ChannelProductVo class])];
        [keyArray addObject:NSStringFromClass([ActivityCategoryVo class])];
        
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"pros"];
        [valueArray addObject:@"promotionList"];
        
        BranchPromotionProListVo *productList = [BranchPromotionProListVo parse:responseObj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(productList);
        }
        
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

//跑马灯进入详情获取优惠券数据 add by lijian 2.2.0
+(void)getAvtivityDetail:(activityDetailModelR *)model success:(void (^)(id))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:ActivityDetail params:[model dictionaryModel] success:^(id responseObj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([pharmacyCouponQuan class])];
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"coupons"];
        
        activityDetailModel *couponList = [activityDetailModel parse:responseObj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(couponList);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

//跑马灯进入详情获取活动商品数据 add by lijian 2.2.0
+(void)getAvtivityDetailPromotion:(activityDetailModelR *)model success:(void (^)(id))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:ActivityDetailPromotion params:[model dictionaryModel] success:^(id responseObj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([pharmacyCouponDrug class])];
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"list"];
        
        PromotionListModel *couponList = [PromotionListModel parse:responseObj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(couponList);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

//我的优惠券（已领取） add by lijian 2.2.0
+(void)myCouponQuanPicked:(myCouponQuanModelR *)modelR success:(void (^)(id))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:CouponQuanPicked params:[modelR dictionaryModel] success:^(id responseObj) {

        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([MyCouponVoModel class])];
        
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"coupons"];
        
        MyOverdueCouponVoListModel *couponList = [MyOverdueCouponVoListModel parse:responseObj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(couponList);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}
//我的优惠券（已使用） add by lijian 2.2.0
+(void)myCouponQuanUsed:(myCouponQuanModelR *)modelR success:(void (^)(id))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:CouponQuanUsed params:[modelR dictionaryModel] success:^(id responseObj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([MyCouponVoModel class])];
        
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"coupons"];
        
        MyOverdueCouponVoListModel *couponList = [MyOverdueCouponVoListModel parse:responseObj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(couponList);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}
//我的优惠券（已过期） add by lijian 2.2.0
+(void)myCouponQuanDated:(myCouponQuanModelR *)modelR success:(void (^)(id))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:CouponQuanDated params:[modelR dictionaryModel] success:^(id responseObj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([MyCouponVoModel class])];
        
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"coupons"];
        
        MyOverdueCouponVoListModel *couponList = [MyOverdueCouponVoListModel parse:responseObj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(couponList);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

//我的优惠商品（包括已领取、已使用、已过期,status区分） add by lijian 2.2.0
+(void)myCouponDrug:(myCouponDrugModelR *)modelR success:(void (^)(id))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:CouponDrug params:[modelR dictionaryModel] success:^(id responseObj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([MyDrugVo class])];
        
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"list"];
        
        MyDrugVoList *couponList = [MyDrugVoList parse:responseObj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(couponList);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

//我的优惠商品详情 add by lijian 2.2.0
+(void)myCouponDrugDetail:(myCouponDrugDetailModelR *)modelR success:(void (^)(id))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:CouponDrugDetail params:[modelR dictionaryModel] success:^(id responseObj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([BranchVo class])];
        
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"branchVoList"];
        
        BranchListVo *couponList = [BranchListVo parse:responseObj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(couponList);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
    
}

//我的活动商品适用药房 add by lijian 2.2.0
+(void)promotionDrugBranch:(drugBranchModelR *)modelR success:(void (^)(id))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:DrugBranch params:[modelR dictionaryModel] success:^(id responseObj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([BranchVo class])];
        
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"branchVoList"];
        
        BranchListVo *couponList = [BranchListVo parse:responseObj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(couponList);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
    
}

//慢病优惠券适用商品 add by lijian 2.2.0
+(void)suitableDrug:(onlineCouponModelR *)modelR success:(void (^)(id))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:SuitableProducts params:[modelR dictionaryModel] success:^(id responseObj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([CouponProductVoModel class])];
        
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"suitableProducts"];
        
        CouponProductVoListModel *couponList = [CouponProductVoListModel parse:responseObj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(couponList);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
    
}

//冻结优惠券移除方法 add by lijian 2.2.0
+(void)removeQuan:(removeQuanModelR *)model success:(void (^)(id))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] post:RemoveByCusomer params:[model dictionaryModel] success:^(id responseObj) {
        
        BaseAPIModel *model = [BaseAPIModel parse:responseObj];
        
        if (success) {
            success(model);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

//冻结优惠商品移除方法 add by lijian 2.2.0
+(void)removeDrug:(DeleteDrugModelR *)modelR success:(void (^)(id))success failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] post:DeleteDrug params:[modelR dictionaryModel] success:^(id responseObj) {
        
        BaseAPIModel *model = [BaseAPIModel parse:responseObj];
        
        if (success) {
            success(model);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+(void)getCouponPharmacy:(CouponBranchSuitableModelR *)modelR success:(void (^)(id))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:Coupon223BranchSuitable params:[modelR dictionaryModel] success:^(id responseObj) {
        
        CouponBranchVoListModel *coupon = [CouponBranchVoListModel parse:responseObj Elements:[CouponBranchVoModel class] forAttribute:@"suitableBranchs"];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}
+(void)getCouponCondition:(CouponConditionModelR *)modelR success:(void (^)(id))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:GetCouponCondition params:[modelR dictionaryModel] success:^(id responseObj) {
        
        CouponConditionVoListModel *coupon = [CouponConditionVoListModel parse:responseObj Elements:[NSString class] forAttribute:@"conditions"];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

/**
 *  优惠券适用药房列表接口，用于领券中心优惠券详情
 *  fixed by lijian at V3.2.0
 *  @param modelR  CouponNewBranchSuitableModelR
 *  @param success CouponBranchVoListModel
 *  @param failure HttpException
 */
+(void)getNewCouponPharmacy:(CouponNewBranchSuitableModelR *)modelR success:(void (^)(id))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:GetCouponDetailPharmcy params:[modelR dictionaryModel] success:^(id responseObj) {
        
        CouponBranchVoListModel *coupon = [CouponBranchVoListModel parse:responseObj Elements:[CouponBranchVoModel class] forAttribute:@"suitableBranchs"];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

/**
 *  优惠券适用药房列表接口，用于我的优惠券详情
 *
 *  @param modelR  CouponNewBranchSuitableModelR
 *  @param success CouponBranchVoListModel
 *  @param failure HttpException
 */
+(void)getMyCouponPharmacy:(CouponNewBranchSuitableModelR *)modelR success:(void (^)(id))success failure:(void (^)(HttpException *))failure
{
    [[HttpClient sharedInstance] get:Coupon300BranchSuitableForMy params:[modelR dictionaryModel] success:^(id responseObj) {
        
        CouponBranchVoListModel *coupon = [CouponBranchVoListModel parse:responseObj Elements:[CouponBranchVoModel class] forAttribute:@"suitableBranchs"];
        if (success) {
            success(coupon);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

//领券中心筛选条件:药房 add by lijian 2.2.4
+(void)couponCityConditions:(CouponListModelR *)mode success:(void (^)(GroupFilterListVo *model))success failure:(void (^)(HttpException *))failure{
    
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] get:CouponFilterGroup params:[mode dictionaryModel] success:^(id responseObj) {
        
        GroupFilterListVo *ListVo = [GroupFilterListVo parse:responseObj Elements:[GroupFilterVo class] forAttribute:@"groups"];
        
        if (success) {
            success(ListVo);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

@end
