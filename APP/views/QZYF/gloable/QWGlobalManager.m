
//
//  QWGlobalManager.m
//  APP
//
//  Created by qw on 15/2/27.
//  Copyright (c) 2015年 carret. All rights reserved.
//

#import "QWGlobalManager.h"
#import "QWLocation.h"
//引导页
#import "AppGuide.h"
#import "QWUserDefault.h"
#import "System.h"
#import "Store.h"
#import "ConsultStore.h"
#import "Mbr.h"
#import "Forum.h"
#import "SVProgressHUD.h"
#import "HomePageViewController.h"
#import "SBJson.h"
#import "LoginViewController.h"
#import "DrugGuideModelR.h"
#import "DrugGuideApi.h"
#import "DrugGuideModel.h"
#import "IMApi.h"
#import "XHAudioPlayerHelper.h"
#import "XHMessageBubbleFactory.h"
#import "XHMessage.h"
#import "WebDirectViewController.h"
#import "VersionUpdate.h"
#import "XMPPStream.h"
#import "QWLocalNotif.h"
#import "ConsultPTPR.h"
#import "System.h"
#import "ConsultPTP.h"
#import "AppDelegate.h"
#import "System.h"
#import "CouponPharmacyDeailViewController.h"
#import "FactoryDetailViewController.h"
#import "PharmacySotreViewController.h"
#import "QuickSearchViewController.h"
#import "WebDirectViewController.h"
#import "CenterCouponDetailViewController.h"
#import "HealthInfoPageViewController.h"
#import "OperateLog.h"
#import "PurchaseViewController.h"
// 积分
#import "Credit.h"
#import "ResortItem.h"
#import "InfoMsg.h"
#import "MallCart.h"
#import "ConsultStoreModel.h"
#import "Circle.h"
#import "CircleModel.h"
#import "AppDelegate.h"
#import "NSDate+Category.h"
#import "OrderBaseModelR.h"
#import <AlipaySDK/AlipaySDK.h>
#import "PayInfo.h"
#import "WXApi.h"
#import "QWProgressHUD.h"
#import "SimpleShoppingCartViewController.h"
#import "PostDetailViewController.h"
#import "QWCustomedTabBar.h"


NSString *const APPLOGINTYPE_NORMAL = @"APPLOGINNORMAL";
NSString *const APPLOGINTYPE_VALIDCODE = @"APPLOGINVALIDCODE";
NSString *const APPLOGINTYPE_QQ = @"APPLOGINQQ";
NSString *const APPLOGINTYPE_WEIXIN = @"APPLOGINWEIXIN";

@implementation QWGlobalManager
@synthesize pullMessageTimer;
@synthesize pullMessageBoxTimer;
@synthesize heartBeatTimer;

+ (QWGlobalManager *)sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    self = [super init];
    if (self) {
        self.weChatBusiness = NO;
//        self.deviceToken = [XMPPStream generateUUID];
        self.deviceToken=@"88888888-8888-8888-8888-888888889465";
        [self loadAppConfigure];
        [self loadBranchConfigure];
        _currentNetWork = kReachableViaWiFi;//kNotReachable;//
        //初始化网络监控
        self.reachabilityMonitor = [[ReachabilityMonitor alloc] initWithDelegate:self];
        [self.reachabilityMonitor startMonitoring];
        //初始化高德地图,并定位自己当前点,会提示app要使用当前位置,方便后期直接调用
        [MAMapServices sharedServices].apiKey = AMAP_KEY;
        self.mapView = [[MAMapView alloc] init];
        self.mapView.showsUserLocation = YES;
        self.mapView.delegate = self;
        if ([QWUserDefault getStringBy:APP_VIBRATION_ENABLE] == nil)
        {
            [QWUserDefault setBool:YES key:APP_VIBRATION_ENABLE];
        }
        if ([QWUserDefault getStringBy:APP_SOUND_ENABLE] == nil)
        {
            [QWUserDefault setBool:YES key:APP_SOUND_ENABLE];
        }
        if ([QWUserDefault getStringBy:APP_Alarm_SOUND_ENABLE]==nil)
        {
            [QWUserDefault setBool:YES key:APP_Alarm_SOUND_ENABLE];
        }
        if([QWUserDefault getStringBy:APP_Alarm_VIBRATION_ENABLE] == nil)
        {
            [QWUserDefault setBool:YES key:APP_Alarm_VIBRATION_ENABLE];
        }
        if ([QWUserDefault getStringBy:APP_FIRSTLOCATION_NOTIFICATION] == nil)
        {
            [QWUserDefault setBool:NO key:APP_FIRSTLOCATION_NOTIFICATION];
        }
        if ([QWUserDefault getStringBy:APP_PROVIENCE_NOTIFICATION] == nil)
        {
            [QWUserDefault setObject:@"" key:APP_PROVIENCE_NOTIFICATION];
        }
        if ([QWUserDefault getStringBy:APP_CITY_NOTIFICATION] == nil)
        {
            [QWUserDefault setObject:@"" key:APP_CITY_NOTIFICATION];
        }
        if ([QWUserDefault getStringBy:kCanConsultPharmacists] == nil)
        {
            [QWUserDefault setBool:YES key:kCanConsultPharmacists];
        }
        [self addObserverGlobal];
    }
    return self;
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    
}

- (void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj
{
    if (NotifCircleMsgRedPoint == type)
    {
        //圈子消息小红点
        BOOL hasReadAllCircle = !QWGLOBALMANAGER.configure.expertCommentRed && !QWGLOBALMANAGER.configure.expertFlowerRed && !QWGLOBALMANAGER.configure.expertSystemInfoRed;
        if (hasReadAllCircle) {
            [QWGLOBALMANAGER noticeUnreadLocalWithType:MsgBoxListMsgTypeCircle sessionID:nil isRead:YES];
        } else {
            [QWGLOBALMANAGER noticeUnreadByMsgBoxTypes:@[@(MsgBoxListMsgTypeCircle)] readFlag:NO];
        }
    }
}

- (void)addObserverGlobal{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNotif:) name:kQWGlobalNotification object:nil];
}

- (void)removeObserverGlobal{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kQWGlobalNotification object:nil];
}

- (void)getNotif:(NSNotification *)sender{
    
    NSDictionary *dd=sender.userInfo;
    NSInteger ty=-1;
    id data;
    id obj;
    
    if ([GLOBALMANAGER object:[dd objectForKey:@"type"] isClass:[NSNumber class]]) {
        ty=[[dd objectForKey:@"type"]integerValue];
    }
    data=[dd objectForKey:@"data"];
    obj=[dd objectForKey:@"object"];
    
    [self getNotifType:ty data:data target:obj];
}


#pragma mark - TabBar 主题切换

// TODO: API对接， 何时刷新
// 缓存QWTabbarItem，APP重启动读取缓存/请求API
- (void)renewTabbarStyle
{
    __block NSArray *itemArr;
    QWCustomedTabBar *customTabBar = (QWCustomedTabBar *)APPDelegate.mainVC.currentTabbar.tabBar;
    if ([customTabBar isKindOfClass:[QWCustomedTabBar class]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            static NSInteger swFlag = 0;
            if (swFlag  == 0) {
                itemArr = [customTabBar styleFestival];
                [customTabBar changeStyleWithItemConfig:itemArr];
            } else if (swFlag == 10) {
                itemArr = [customTabBar styleCommon];
                [customTabBar changeStyleWithItemConfig:itemArr];
            }
            swFlag ++;
            swFlag = swFlag % 20;
            
            for (QWTabbarItem *item in itemArr) {
                [item updateToDB];
            }
        });
        
    } else {
        DDLogError(@"[%@ %s]:%d  ERROR: UITabBar is not customed. Cant switch Style.", NSStringFromClass(self.class), __func__, __LINE__);
    }
}

- (void)resetTabbarStyle
{
    [QWTabbarItem deleteAllObjFromDB];
    QWCustomedTabBar *customTabBar = (QWCustomedTabBar *)APPDelegate.mainVC.currentTabbar.tabBar;
    if ([customTabBar isKindOfClass:[QWCustomedTabBar class]]) {
        if (APPDelegate.mainVC.currentTabbar == APPDelegate.mainVC.tabbarOne) {
            [customTabBar changeStyleWithItemConfig:[MainViewController tabbarOneItems]];
        } else {
            [customTabBar changeStyleWithItemConfig:[MainViewController tabbarTwoItems]];
        }
    }
}

#pragma mark - 屏幕亮度变换(当前亮度~80%)
- (void)brightScreenWithAnimated:(BOOL)animated{
    
    originalBrightNess = [UIScreen mainScreen].brightness;
    if(originalBrightNess >= 0.8){
        return;
    }
    
    if(animated){
        screenBright = originalBrightNess;
        brightTime = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(bright) userInfo:nil repeats:YES];
    }else{
        [[UIScreen mainScreen] setBrightness:0.8];
    }
}
- (void)darkScreenwithAnimated:(BOOL)animated{
   
    if(animated){
        darkTime = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(dark) userInfo:nil repeats:YES];
    }else{
        [[UIScreen mainScreen] setBrightness:originalBrightNess];
    }
}

- (void)bright{
    
    if([UIScreen mainScreen].brightness < 0.8f){
        screenBright += 0.01;
        [[UIScreen mainScreen] setBrightness:screenBright];
    }else{
        [brightTime invalidate];
    }
}
- (void)dark{
    
    if([UIScreen mainScreen].brightness > originalBrightNess){
        screenBright -= 0.01;
        [[UIScreen mainScreen] setBrightness:screenBright];
    }else{
        [darkTime invalidate];
    }
}

#pragma mark -
#pragma mark 支付宝微信生成随机订单号
- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

#pragma mark -
#pragma mark 微信支付状态回调
/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
-(void) onReq:(BaseReq*)req
{
    
    
}
/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
-(void)onResp:(BaseResp*)resp
{
    //0	 成功	展示成功页面
    //    -1	错误	可能的原因：签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等。
    //    -2	用户取消	无需处理。发生场景：用户不支付了，点击取消，返回APP。
    if ([resp isKindOfClass:[PayResp class]]){
        PayResp *response=(PayResp*)resp;
        if(response.errCode==-2){
            PayInfoModel *responseModel =[PayInfoModel new];
            responseModel.notiType=@"wx";//微信
            responseModel.notiTypeStatus=@"1";//用户中途取消，失败
            [QWGLOBALMANAGER postNotif:NotifPayStatusUnknown data:responseModel object:nil];
        }else{
            for(int i=0;i<3;i++){//3次请求接口
                BOOL successStatus=[self getWxResult:self.payOrderId index:i];
                if(successStatus)
                {
                    break;
                }else{
                    [NSThread sleepForTimeInterval:1.5f];
                }
            }
        }
    }
}


#pragma mark -
#pragma mark 微信和阿里两种支付方式
//微信支付
- (void)weChatPayOrder:(NSString *)orderString withObjId:(NSString*)objId
{
    NSDictionary *dict = [orderString JSONValue];
    QWGLOBALMANAGER.payOrderId = objId;
    //调起微信支付
    PayReq* req             = [PayReq new];
    req.partnerId           = [dict objectForKey:@"partnerid"];
    req.prepayId            = [dict objectForKey:@"prepayid"];
    req.nonceStr            = [dict objectForKey:@"noncestr"];
    req.timeStamp           = [[dict objectForKey:@"timestamp"] unsignedIntValue];
    req.package             = [dict objectForKey:@"packagevalue"];
    req.sign                = [dict objectForKey:@"sign"];
    [WXApi sendReq:req];
}

//阿里支付
- (void)aliPayOrder:(NSString *)orderString withObjId:(NSString*)objId
{
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"qw37249e2677eb";
    QWGLOBALMANAGER.payOrderId = objId;
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        //客户端返回码9000	订单支付成功8000	正在处理中4000	订单支付失败6001	用户中途取消6002	网络连接出错
        if([resultDic[@"resultStatus"]isEqualToString:@"9000"]){//支付成功
            for(int i=0;i<3;i++){//3次请求接口
                BOOL successStatus=[self getAliResult:objId index:i];
                if(successStatus)
                {
                    break;
                }else{
                    [NSThread sleepForTimeInterval:1.5f];
                }
            }
            [QWGLOBALMANAGER postNotif:NotifPayStatusFinish data:nil object:nil];
        }else if([resultDic[@"resultStatus"]isEqualToString:@"4000"]){//支付中
            for(int i=0;i<3;i++){//3次请求接口
                BOOL successStatus=[self getAliResult:objId index:i];
                if(successStatus)
                {
                    break;
                }else{
                    [NSThread sleepForTimeInterval:0.5f];
                }
            }
        }else{//支付失败
            PayInfoModel *responseModel =[PayInfoModel new];
            responseModel.notiType=@"ali";//支付宝
            responseModel.notiTypeStatus=@"1";//用户中途取消，失败
            [QWGLOBALMANAGER postNotif:NotifPayStatusUnknown data:responseModel object:nil];
        }
       
    }];
}

-(BOOL)getAliResult:(NSString *)objId index:(int)i{
    __block BOOL resultStatus=NO;
    PayInfoModelR *modelR = [PayInfoModelR new];
    modelR.outTradeNo = objId;
    [PayInfo getAliPayResult:modelR success:^(PayInfoModel *responseModel) {
        if(responseModel.result == 2) {//支付中
            responseModel.notiType=@"ali";//支付宝
            responseModel.notiTypeStatus=@"3";//未知
            if(resultStatus==YES||i==2){
                [QWGLOBALMANAGER postNotif:NotifPayStatusUnknown data:responseModel object:nil];
            }
        }else if(responseModel.result == 3){//支付成功
            responseModel.notiType=@"ali";//支付宝
            responseModel.notiTypeStatus=@"2";
            resultStatus=YES;
            if(resultStatus==YES||i==2){
                [QWGLOBALMANAGER postNotif:NotifPayStatusFinish data:responseModel object:nil];
            }
        }else{
            responseModel.notiType=@"ali";//支付宝
            responseModel.notiTypeStatus=@"1";//用户中途取消，失败
            if(resultStatus==YES||i==2){
                [QWGLOBALMANAGER postNotif:NotifPayStatusUnknown data:responseModel object:nil];
            }
        }
    } failure:^(HttpException *e) {

    }];
    return resultStatus;
}

-(BOOL)getWxResult:(NSString *)objId index:(int)i{
    __block BOOL resultStatus=NO;
    PayInfoModelR *modelR = [PayInfoModelR new];
    modelR.outTradeNo = self.payOrderId;
    modelR.tradeSource =@"1";
    [PayInfo getWXPayResult:modelR success:^(PayInfoModel *responseModel) {
        if(responseModel.result == 2) {//支付中
            responseModel.notiType=@"wx";//微信
            responseModel.notiTypeStatus=@"3";//未知
            if(resultStatus==YES||i==2){
                [QWGLOBALMANAGER postNotif:NotifPayStatusUnknown data:responseModel object:nil];
            }
        }else if(responseModel.result == 3){//支付成功
            responseModel.notiType=@"wx";//微信
            responseModel.notiTypeStatus=@"2";
            resultStatus=YES;
            if(resultStatus==YES||i==2){
                [QWGLOBALMANAGER postNotif:NotifPayStatusFinish data:responseModel object:nil];
            }
        }else{
            responseModel.notiType=@"wx";//微信
            responseModel.notiTypeStatus=@"1";//用户中途取消，失败
            if(resultStatus==YES||i==2){
                [QWGLOBALMANAGER postNotif:NotifPayStatusUnknown data:responseModel object:nil];
            }
        }
    } failure:NULL];
    return resultStatus;
}



- (void)jumpH5PayOrderWithOrderId:(NSString *)orderId
                       totalPrice:(NSString *)price
                       isComeFrom:(NSString *)come
                        orderModel:(WebOrderDetailModel *)model
             navigationController:(UINavigationController *)navigationController
{
    WebDirectViewController *vcWebDirect = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
    WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
    modelLocal.title = @"付款";
    modelLocal.url = [NSString stringWithFormat:@"%@QWYH/web/pay/html/pay.html?orderId=%@&orderPrice=%@",H5_BASE_URL,orderId,price];
    modelLocal.typeLocalWeb = WebLocalTypeToPayOrder;
    WebOrderDetailModel *modelOrder=[WebOrderDetailModel new];
    modelOrder.orderId=orderId;
    modelOrder.orderCode=model.orderCode;
    modelOrder.orderIdName=model.orderIdName;
    modelLocal.typeTitle = WebTitleTypeNone;
    modelLocal.modelOrder=modelOrder;
    vcWebDirect.payButton=YES;//禁止右滑事件
    vcWebDirect.isComeFromConfirm=come;
    [vcWebDirect setWVWithLocalModel:modelLocal];
    vcWebDirect.hidesBottomBarWhenPushed = YES;
    [navigationController pushViewController:vcWebDirect animated:YES];
}

- (BOOL)checkLoginStatus:(UIViewController *)viewController
{
    if(!QWGLOBALMANAGER.loginStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [viewController presentViewController:navgationController animated:YES completion:NULL];
        return NO;
    }else{
        return YES;
    }
}
#pragma mark -
#pragma mark  地图定位
//读取地图信息,如果有上一次缓存信息,直接读取返回,其他页面如无重新定位功能,一致使用此函数读取缓存数据
- (void)readLocationWhetherReLocation:(BOOL)relocation block:(ReadLocationBlock)block
{
    [[QWLocation sharedInstance] requetWithCache:LocationCity timeout:10.0f reLocation:relocation block:^(MapInfoModel *mapInfoModel, LocationStatus status) {
        if(status == LocationSuccess)
        {
            block(mapInfoModel);
        }else{
            MapInfoModel *mapInfoModel = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
            if(!mapInfoModel) {
                mapInfoModel = [self buildSuzhouLocatinMapInfo];
                
            }
            block(mapInfoModel);
        }
    }];
}

- (void)pushBranchDetail:(NSString *)branchId withType:(NSString *)type navigation:(UINavigationController *)nav{

    if(StrIsEmpty(branchId)){
        [SVProgressHUD showErrorWithStatus:@"branchId不能为空"];
    }
    
    PharmacySotreViewController *VC = [[PharmacySotreViewController alloc]init];
    VC.branchId = branchId;
    VC.hidesBottomBarWhenPushed = YES;
    [nav pushViewController:VC animated:YES];
}

//所有banner的跳转的逻辑 包含首页bannner 优惠商品 领券中心
- (void)pushIntoDifferentBannerType:(BannerInfoModel *)banner navigation:(UINavigationController *)myNavgationController bannerLocation:(NSString *)bannerLocation selectedIndex:(NSInteger)index
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    switch ([banner.type intValue]) {
        case 1:{ //1外链
            
            WebDirectViewController *vcWebDirect = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
            QWBaseVC *vcLastObj = (QWBaseVC *)[myNavgationController.viewControllers lastObject];
//            vcWebDirect.isOtherLinks = YES;
            
            WebDirectLocalModel *modelLocal = [[WebDirectLocalModel alloc] init];
            if (![banner.content hasPrefix:@"http"]) {
                banner.content = [NSString stringWithFormat:@"%@%@",H5_BASE_URL,banner.content];
            }
            modelLocal.url = banner.content;
            modelLocal.title = banner.name;
            modelLocal.typeLocalWeb = WebLocalTypeOuterLink;
            
            modelLocal.typeTitle = WebTitleTypeNone;
            if ([banner.flagShare boolValue]) {
                vcWebDirect.didSetShare = NO;
            } else {
                modelLocal.typeTitle = WebTitleTypeNone;
                vcWebDirect.didSetShare = YES;
            }
            
            [vcWebDirect setWVWithLocalModel:modelLocal];
            
            vcWebDirect.hidesBottomBarWhenPushed = YES;
            [myNavgationController pushViewController:vcWebDirect animated:YES];
            params[@"分类"] = @"外链";
            params[@"页面名称"] = banner.name;
        }
            break;
        case 2:{//2优惠活动 是药房的促销活动
            
            CouponPharmacyDeailViewController *couponPharmacy = [[CouponPharmacyDeailViewController alloc]initWithNibName:@"CouponPharmacyDeailViewController" bundle:nil];
            couponPharmacy.storeId = banner.branchId;
            couponPharmacy.activityId = banner.content;
            couponPharmacy.title = @"促销活动";
            couponPharmacy.hidesBottomBarWhenPushed = YES;
            [myNavgationController pushViewController:couponPharmacy animated:YES];
            params[@"页面名称"] = @"优惠活动";
            params[@"分类"] = @"促销活动";
        }
            break;
        case 3:{//3资讯
            
            //进入资讯详情
            HealthinfoAdvicel *advicel = [HealthinfoAdvicel new];
            advicel.adviceId = banner.content;
            WebDirectViewController *vcWebDirect = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
            
            WebHealthInfoModel *modelHealth = [[WebHealthInfoModel alloc] init];
            modelHealth.msgID = advicel.adviceId;
            
            WebDirectLocalModel *modelLocal = [[WebDirectLocalModel alloc] init];
            modelLocal.modelHealInfo = modelHealth;
            modelLocal.typeLocalWeb = WebPageToWebTypeInfo;
            [vcWebDirect setWVWithLocalModel:modelLocal];

            vcWebDirect.hidesBottomBarWhenPushed = YES;
            [myNavgationController pushViewController:vcWebDirect animated:YES];
            params[@"页面名称"] = @"资讯";
            params[@"分类"] = @"资讯";
        }
            break;
        case 4:{//4品牌展示
            
            //进入品牌详情
            FactoryDetailViewController *vc = [[FactoryDetailViewController alloc] init];
            vc.factoryId = banner.content;
            vc.hidesBottomBarWhenPushed = YES;
            vc.bannerStatus=1;
            [myNavgationController pushViewController:vc animated:YES];
            params[@"页面名称"] = @"品牌展示";
            params[@"分类"] = @"品牌详情";
        }
            break;
        case 5:{//5附近药房详情
            [self pushBranchDetail:banner.content withType:@"" navigation:myNavgationController];
            
            params[@"页面名称"] = @"附近药房";
            params[@"分类"] = @"药房详情";
        }
            break;
        case 6:{//6专题
            WebDirectViewController *vcWebDirect = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
            WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
            if (banner.name.length > 0) {
                modelLocal.title = banner.name;
            } else {
                modelLocal.title = @"专题";
            }
            
            if ([banner.content hasPrefix:@"http"]) {
                modelLocal.url = banner.content;
            } else {
                modelLocal.url = @"";
                modelLocal.strParams = banner.content;
            }
            
            modelLocal.typeTitle = WebTitleTypeNone;
            if ([banner.flagShare boolValue]) {
                vcWebDirect.didSetShare = NO;
            } else {
                modelLocal.typeTitle = WebTitleTypeNone;
                vcWebDirect.didSetShare = YES;
            }
            
            
            modelLocal.typeLocalWeb = WebPageToWebTypeTopicDetail;
            [vcWebDirect setWVWithLocalModel:modelLocal];
            QWBaseVC *vcLastObj = (QWBaseVC *)[myNavgationController.viewControllers lastObject];
            vcWebDirect.hidesBottomBarWhenPushed = YES;
            [myNavgationController pushViewController:vcWebDirect animated:YES];
            params[@"页面名称"] = @"专题";
            params[@"分类"] = @"专题";
        }
            break;
        case 7: {
            //7优惠券详情

            //banner.groupId            //商家id
            //banner.content            //优惠券id
            CenterCouponDetailViewController *vcDetail =[[CenterCouponDetailViewController alloc] initWithNibName:@"CenterCouponDetailViewController" bundle:nil];
            vcDetail.couponId=banner.content;
            
            [myNavgationController pushViewController:vcDetail animated:YES];
            params[@"页面名称"] = @"优惠券详情";
            params[@"分类"] = @"代金券";
            break;
        }
        case 8: {//8商品 药品详情
            WebDirectViewController *vcWebMedicine = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
            [[QWGlobalManager sharedInstance] readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
                QWBaseVC *vcLastObj = (QWBaseVC *)[myNavgationController.viewControllers lastObject];
                
                WebDrugDetailModel *modelDrug = [WebDrugDetailModel new];
                modelDrug.modelMap = mapInfoModel;
                modelDrug.proDrugID = banner.proId;
                modelDrug.promotionID = banner.content;
//                modelDrug.showDrug = @"0";
                WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
//                modelLocal.title = @"药品详情";
                modelLocal.modelDrug = modelDrug;
                modelLocal.typeLocalWeb = WebPageToWebTypeMedicine;
                
                modelLocal.typeTitle = WebTitleTypeNone;
                if ([banner.flagShare boolValue]) {
                    vcWebMedicine.didSetShare = NO;
                } else {
                    modelLocal.typeTitle = WebTitleTypeNone;
                    vcWebMedicine.didSetShare = YES;
                }
                
                [vcWebMedicine setWVWithLocalModel:modelLocal];
                vcWebMedicine.hidesBottomBarWhenPushed = YES;
                params[@"页面名称"] = @"药品详情";
                params[@"分类"] = @"药品详情";
                [myNavgationController pushViewController:vcWebMedicine animated:YES];
            }];
            
            break;
        }
        case 9: {
            //9常规,不处理
            break;
        }
        case 13: {
            //圈贴
            PostDetailViewController* postDetailVC = (PostDetailViewController*)[[UIStoryboard storyboardWithName:@"Forum" bundle:nil] instantiateViewControllerWithIdentifier:@"PostDetailViewController"];
            postDetailVC.hidesBottomBarWhenPushed = YES;
            postDetailVC.postId = banner.content;
            [myNavgationController pushViewController:postDetailVC animated:YES];
            
            break;
        }
        case 14: {
            //资讯专题
            WebDirectViewController *vcWebDirect = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
            WebHealthInfoModel *modelHealth = [[WebHealthInfoModel alloc] init];
            WebDirectLocalModel *modelLocal = [[WebDirectLocalModel alloc] init];
            modelLocal.url = [NSString stringWithFormat:@"%@QWYH/web/message/html/subject.html?id=%@",H5_BASE_URL,banner.content];
            modelLocal.typeLocalWeb = WebLocalTypeOuterLink;

            modelLocal.typeTitle = WebTitleTypeNone;
            if ([banner.flagShare boolValue]) {
                vcWebDirect.didSetShare = NO;
            } else {
                modelLocal.typeTitle = WebTitleTypeNone;
                vcWebDirect.didSetShare = YES;
            }
            
            vcWebDirect.isOtherLinks = YES;
            [vcWebDirect setWVWithLocalModel:modelLocal];
            vcWebDirect.hidesBottomBarWhenPushed = YES;
            [myNavgationController pushViewController:vcWebDirect animated:YES];
            break;
        }
        case 16: {
            //商品列表
            WebDirectViewController *vcWebDirect = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
            WebHealthInfoModel *modelHealth = [[WebHealthInfoModel alloc] init];
            WebDirectLocalModel *modelLocal = [[WebDirectLocalModel alloc] init];
            modelLocal.url = [NSString stringWithFormat:@"%@QWWEB/activity/html/branchPros/pros.html?channel=1&branchId=%@&templateId=%@",H5_DOMAIN_URL,[QWGLOBALMANAGER getMapBranchId],banner.content];
            modelLocal.typeLocalWeb = WebLocalTypeOuterLink;
            
            modelLocal.typeTitle = WebTitleTypeNone;
            if ([banner.flagShare boolValue]) {
                vcWebDirect.didSetShare = NO;
            } else {
                modelLocal.typeTitle = WebTitleTypeNone;
                vcWebDirect.didSetShare = YES;
            }
            
            vcWebDirect.isOtherLinks = YES;
            [vcWebDirect setWVWithLocalModel:modelLocal];
            vcWebDirect.hidesBottomBarWhenPushed = YES;
            [myNavgationController pushViewController:vcWebDirect animated:YES];
            
            break;
        }
        case 17: {
            //新微商模板
            WebDirectViewController *vcWebDirect = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
            WebHealthInfoModel *modelHealth = [[WebHealthInfoModel alloc] init];
            WebDirectLocalModel *modelLocal = [[WebDirectLocalModel alloc] init];
            modelLocal.url = [NSString stringWithFormat:@"%@QWWEB/activity/html/trendsTemplate.html?channel=1&id=%@",H5_DOMAIN_URL,banner.content];
            modelLocal.typeLocalWeb = WebLocalTypeOuterLink;
            modelLocal.typeTitle = WebTitleTypeNone;
            if ([banner.flagShare boolValue]) {
                vcWebDirect.didSetShare = NO;
            } else {
                modelLocal.typeTitle = WebTitleTypeNone;
                vcWebDirect.didSetShare = YES;
            }
            vcWebDirect.isOtherLinks = YES;
            [vcWebDirect setWVWithLocalModel:modelLocal];
            vcWebDirect.hidesBottomBarWhenPushed = YES;
            [myNavgationController pushViewController:vcWebDirect animated:YES];
            break;
        }
        case 18: {
            //翻页模板
            WebDirectViewController *vcWebDirect = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
            WebHealthInfoModel *modelHealth = [[WebHealthInfoModel alloc] init];
            WebDirectLocalModel *modelLocal = [[WebDirectLocalModel alloc] init];
            modelLocal.url = [NSString stringWithFormat:@"%@QWWEB/activity/html/flipTemplate.html?channel=1&id=%@",H5_DOMAIN_URL,banner.content];
            modelLocal.typeLocalWeb = WebLocalTypeOuterLink;
            modelLocal.typeTitle = WebTitleTypeNone;
            if ([banner.flagShare boolValue]) {
                vcWebDirect.didSetShare = NO;
            } else {
                modelLocal.typeTitle = WebTitleTypeNone;
                vcWebDirect.didSetShare = YES;
            }
            vcWebDirect.isOtherLinks = YES;
            [vcWebDirect setWVWithLocalModel:modelLocal];
            vcWebDirect.hidesBottomBarWhenPushed = YES;
            [myNavgationController pushViewController:vcWebDirect animated:YES];
            break;
        }
        default:
            break;
    }
    
    params[@"页数"] = [NSString stringWithFormat:@"%d",index];
    [QWGLOBALMANAGER statisticsEventId:@"x_sy_banner1" withLable:@"首页-banner" withParams:params];
}



//- (void)statisticsEventId:(NSString *)eventId withParams:(NSMutableDictionary *)params
//{
//    StatisticsModel *model = [StatisticsModel new];
//    model.eventId = eventId;
//    model.params = params;
//    [QWCLICKEVENT qwTrackEventModel:model];
//}

//4.0特殊的事件
- (void)checkEventId:(NSString *)eventId withLable:(NSString*)eventLable withParams:(NSMutableDictionary *)params{
    if(QWGLOBALMANAGER.tdModel.groups&&QWGLOBALMANAGER.tdModel.groups.count>0){
        for(TdGroupSimpleVo *model in QWGLOBALMANAGER.tdModel.groups){
            if([model.groupId isEqualToString:[QWGLOBALMANAGER getMapInfoModel].groupId]){
                eventId=[NSString stringWithFormat:@"%@_%@",model.groupName,eventId];
                [QWGLOBALMANAGER statisticsEventId:eventId withLable:eventLable withParams:params];
                break;
            }
        }
        [QWGLOBALMANAGER statisticsEventId:eventId withLable:eventLable withParams:params];
    }else{
        [QWGLOBALMANAGER statisticsEventId:eventId withLable:eventLable withParams:params];
    }
}


//3.0最新的统计事件
- (void)statisticsEventId:(NSString *)eventId withLable:(NSString*)eventLable withParams:(NSMutableDictionary *)params
{
    StatisticsModel *model = [StatisticsModel new];
    if(!StrIsEmpty(eventId) ){
        model.eventId = eventId;
    }else{
        model.eventId = @"";
    }
    if(!StrIsEmpty(eventLable)){
        model.eventLabel=eventLable;
    }else{
        model.eventLabel=@"";
    }
    if(params&&([params isKindOfClass:[NSMutableDictionary class]])){
        model.params = params;
    }else{
        model.params=[NSMutableDictionary dictionary];
    }
    if(QWGLOBALMANAGER.loginStatus){//登陆
        [model.params setValue:@"是" forKey:@"是否登录状态"];
    }else{
        [model.params setValue:@"否" forKey:@"是否登录状态"];
    }
    [QWCLICKEVENT qwTrackEventWithAllModel:model];
}


//渠道统计
-(void)qwChannel:(ChannerTypeModel *)model{
    ChannerModelR *modelR = [ChannerModelR new];
    modelR.token = QWGLOBALMANAGER.configure.userToken;
    modelR.cKey=model.cKey;
    modelR.objId=model.objId;
    modelR.objRemark=model.objRemark;
    modelR.deviceType=@"2";
    modelR.deviceCode=DEVICE_ID;
    
      [VersionUpdate qwChannel:modelR success:^(ChannerModel *resultObj) {
//          ChannerModel *model=(ChannerModel*)resultObj;
//          if([model.apiStatus intValue]==0){
//
//          }
      } failure:^(HttpException *e) {
          
      }];
}

//审核时,app假数据,status=3 开通服务,开通微商
- (MapInfoModel *)buildSuzhouAuditLocatinMapInfo
{
    MapInfoModel *model = [MapInfoModel new];
    model.location = [[CLLocation alloc] initWithLatitude:DEFAULT_LATITUDE longitude:DEFAULT_LONGITUDE];
    model.branchId = @"f56adf24d083fb12e040a8c022007531";
    model.formattedAddress = @"苏州市生物纳米园";
    model.province = @"江苏省";
    model.city = @"苏州市";
    model.cityCode = @"3205";
    model.status = 3;
    return model;
}

//审核时,app假数据,status=1 未开通服务,未开通微商,不能切换反面
- (MapInfoModel *)buildSuzhouLocatinMapInfo
{
    MapInfoModel *model = [MapInfoModel new];
    model.location = [[CLLocation alloc] initWithLatitude:DEFAULT_LATITUDE longitude:DEFAULT_LONGITUDE];
    model.branchId = @"";
    model.formattedAddress = @"苏州市生物纳米园";
    model.province = @"江苏省";
    model.city = @"苏州市";
    model.cityCode = @"3205";
    model.status = 1;
    return model;
}

- (void)setMapBranchId:(NSString *)branchId branchName:(NSString *)branchName
{
    MapInfoModel *lastMapInfo = [QWUserDefault getObjectBy:kLastLocationSuccessAddressModel];
    if([lastMapInfo.branchId isEqualToString:branchId]){
        return;
    }
    lastMapInfo.branchName = branchName;
    lastMapInfo.branchId = branchId;
    [self saveLastLocationInfo:lastMapInfo];
    [self postNotif:NotifHomepagePharmacyStoreChanged data:lastMapInfo object:nil];
    [QWGLOBALMANAGER postNotif:NotifTransitionToTabbarOne data:nil object:nil];
}

- (NSString *)getMapBranchId{
    //64c451cc0b62387d839be0eab6d1d0bf  eef197ce8dd74c56ac8192674bb89e85
    if(TARGET_IPHONE_SIMULATOR){
        return @"64c451cc0b62387d839be0eab6d1d0bf";
    }else{
        MapInfoModel *mapInfo = [QWUserDefault getModelBy:APP_MAPINFOMODEL];
        return mapInfo.branchId;
    } 
}

- (MapInfoModel *)getMapInfoModel
{
    MapInfoModel *mapInfo = [QWUserDefault getModelBy:APP_MAPINFOMODEL];
    return mapInfo;
}

- (void)updateMapInfoModel:(MicroMallBranchNewIndexVo *)model
{
    MapInfoModel *mapInfo = [QWGLOBALMANAGER getMapInfoModel];
    mapInfo.branchCityName = model.cityName;
    mapInfo.branchLat = model.lat;
    mapInfo.branchLon = model.lng;
    mapInfo.groupId = model.groupId;
    mapInfo.branchName = model.name;
    mapInfo.teamId = model.teamId;
    mapInfo.logo = model.logo;
    [self saveLastLocationInfo:mapInfo];
    [self postNotif:NotifHomepagePharmacyDataReceived data:mapInfo object:nil];
}

- (void)updateMapInfoModelLocation:(MapInfoModel *)model
{
    MapInfoModel *mapInfo = [QWGLOBALMANAGER getMapInfoModel];
    mapInfo.location = model.location;
    mapInfo.city = model.city;
    mapInfo.cityCode = model.cityCode;
    mapInfo.province = model.province;
    mapInfo.formattedAddress = model.formattedAddress;
    [self saveLastLocationInfo:mapInfo];
}

- (void)clearLocationInformation
{
    [QWUserDefault setObject:nil key:APP_PROVIENCE_NOTIFICATION];
    [QWUserDefault setObject:nil key:APP_CITY_NOTIFICATION];
    [QWUserDefault setObject:nil key:APP_MAPINFOMODEL];
    [QWUserDefault setModel:nil key:kLastLocationSuccessAddressModel];
}

//重置定位
- (void)resetLocationInformation:(ReadLocationBlock)block
{
    //首页判断是否在审核中,如果审核中,直接返回苏州生物纳米园位置信息
    [System systemCheckIosAuditParams:[NSDictionary dictionary] success:^(BaseAPIModel *model) {
        
        //审核中,返回苏州假数据
        if([model.apiStatus integerValue] == 1) {
            MapInfoModel *mapInfoModel = mapInfoModel =  [self buildSuzhouAuditLocatinMapInfo];
            [QWUserDefault setObject:[NSNumber numberWithBool:YES] key:APP_FIRSTLOCATION_NOTIFICATION];
            [QWUserDefault setObject:mapInfoModel key:APP_MAPINFOMODEL];
            [QWUserDefault setBool:YES key:kLocationSuccess];
            [QWUserDefault setBool:YES key:kLocationAudition];
            block(mapInfoModel);
        }else{
            //审核之外，定位
            [self __resetLocationInformation:block];
            [QWUserDefault setBool:NO key:kLocationAudition];
        }
    } failure:^(HttpException *e) {
        [self __resetLocationInformation:block];
    }];
}

//真正的重新定位方法
- (void)__resetLocationInformation:(ReadLocationBlock)block
{
    MapInfoModel *GGLocation = [QWGLOBALMANAGER QWGetLocation];
    //定位总次数+1
    //有可能替换的
    [QWGLOBALMANAGER statisticsEventId:@"x_dw" withLable:@"定位" withParams:nil];
    [[QWLocation sharedInstance] requetWithReGoecode:LocationCity
                                             timeout:10.0f
                                               block:^(MapInfoModel *mapInfoModel, LocationStatus status) {
        if(status == LocationSuccess)
        {
            [QWUserDefault setObject:mapInfoModel key:kLastLocationSuccessAddressModel];

            
            mapInfoModel.locationStatus = LocationSuccess;
            //定位成功+1
            //有可能替换的
            NSMutableDictionary *setting = [NSMutableDictionary dictionary];
            setting[@"城市名"] = mapInfoModel.city;
            if(mapInfoModel.status == 3) {
                setting[@"是否开通微商"] = @"是";
            }else{
                setting[@"是否开通微商"] = @"否";
            }
            [QWGLOBALMANAGER statisticsEventId:@"x_dw_dwcg" withLable:@"定位成功" withParams:setting];
            block(mapInfoModel);
            [System rptLocateWithCityName:mapInfoModel.city];
            //定位成功一次后永远为YES
            [QWUserDefault setObject:[NSNumber numberWithBool:YES] key:APP_FIRSTLOCATION_NOTIFICATION];
            [QWUserDefault setBool:YES key:kLocationSuccess];
        }else{
            //定位失败+1
            NSMutableDictionary *setting = [NSMutableDictionary dictionary];
            setting[@"城市名"] = mapInfoModel.city;
            if(mapInfoModel.status == 3) {
                setting[@"是否开通微商"] = @"是";
            }else{
                setting[@"是否开通微商"] = @"否";
            }
            [QWGLOBALMANAGER statisticsEventId:@"x_dwsb" withLable:@"定位失败" withParams:setting];
            MapInfoModel *mapInfoModel = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
            if(!mapInfoModel) {
                mapInfoModel = [self buildSuzhouLocatinMapInfo];
            }
            mapInfoModel.locationStatus = LocationError;
            block(mapInfoModel);
            [QWUserDefault setBool:NO key:kLocationSuccess];
        }
    }];
    
}

- (NSInteger)getUnreadShoppingCart
{
    NSInteger total = 0;
    NSArray *array = [CartBranchVoModel getArrayFromDBWithWhere:nil WithorderBy:@"timestamp desc"];
    for(CartBranchVoModel *branchModel in array) {
        for(CartProductVoModel *model in branchModel.products) {
            total += model.quantity;
        }
        for(CartComboVoModel *comboVoModel in branchModel.combos) {
            total += comboVoModel.quantity;
        }
        for(CartRedemptionVoModel *redemptionModel in branchModel.redemptions) {
            total += 1;
        }
    }

    if(total >= 99) {
        total = 99;
    }
    return total;
}

- (void)mapReGeocodeSearchRequest:(CLLocation *)cllocation
                            block:(ReadLocationBlock)block
{
    
    [[QWLocation sharedInstance] mapReGeocodeSearchRequest:cllocation timeout:10.0f block:^(MapInfoModel *mapInfoModel, LocationStatus status) {
        if(status == LocationRegeocodeSuccess)
        {
            block(mapInfoModel);
        }else{
            block(nil);
        }
    }];
}

//保存上一次地理位置信息
- (void)saveLastLocationInfo:(MapInfoModel *)mapinfo
{
    if([mapinfo.city isEqualToString:@"苏州市"] && mapinfo.status == 1) {
        return;
    }
    [[QWLocation sharedInstance] saveLastMapInfo:mapinfo];
}

#pragma mark
#pragma mark 读取历史定位数据
//读取最后一次城市信息,仅返回城市,省份以及可读化地址
- (void)readLastMapAddress:(AddressBlcok)addressBlock
{
    MapInfoModel *mapInfo = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
    
    if (mapInfo.province) {
        addressBlock(mapInfo.province,mapInfo.city,mapInfo.formattedAddress);
    }else{
        addressBlock(nil,nil,nil);
    }
}

- (void)readLastMapLocation:(LocationBlock)locationBlock
{
    MapInfoModel *mapInfo = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
    if (mapInfo.location) {
        locationBlock(mapInfo.location);
    }else{
        locationBlock(nil);
    }
}

- (MapInfoModel *)__buildMapInfoModelWith:(CLLocation *)location
                 searchResponse:(AMapReGeocodeSearchResponse *)response
{
    MapInfoModel *mapInfoModel = [[MapInfoModel alloc] init];
    mapInfoModel.city = [[[response regeocode] addressComponent] city];
    mapInfoModel.province = [[[response regeocode] addressComponent] province];
    mapInfoModel.formattedAddress = [[response regeocode] formattedAddress];
    mapInfoModel.location = location;
    return mapInfoModel;
}

//检查城市是否在开通城市列表,并且提供已开通的回调和未开通回调
- (void)checkCityOpenInfo:(MapInfoModel *)mapinfo
                openBlock:(void(^)(MapInfoModel *openMapInfo))openBlock
               closeBlock:(void(^)(MapInfoModel *closeMapInfo))closeBlock
             failureBlock:(void(^)(HttpException *))failureBlock
{
    StoreSearchOpenCityCheckModelR *storeSearchOpenCityCheckModelR = [[StoreSearchOpenCityCheckModelR alloc] init];
    storeSearchOpenCityCheckModelR.city = mapinfo.city;
    storeSearchOpenCityCheckModelR.province = mapinfo.province;
    
    HttpClientMgr.progressEnabled=NO;
    [Store storeSearchOpenCityCheckWithPara:storeSearchOpenCityCheckModelR success:^(id DFModel) {
        StoreSearchOpenCityCheckModel *model = (StoreSearchOpenCityCheckModel *)DFModel;
        if([model.open integerValue] == 1) {
            //已经开通
            openBlock(mapinfo);
        }else{
            //未开通
            closeBlock(mapinfo);
        }
        
    } failure:^(HttpException *e) {
        //错误也认为是未开通
        failureBlock(e);
    }];
    
}
- (NSUInteger)valueExists:(NSString *)key withValue:(NSString *)value withArr:(NSMutableArray *)arrOri
{
    NSPredicate *predExists = [NSPredicate predicateWithFormat:
                               @"%K MATCHES[c] %@", key, value];
    NSUInteger index = [arrOri indexOfObjectPassingTest:
                        ^(id obj, NSUInteger idx, BOOL *stop) {
                            return [predExists evaluateWithObject:obj];
                        }];
    return index;
}

- (QWUnreadFlagModel *)getUnreadModel
{
    QWUnreadFlagModel *mm=[QWUnreadFlagModel getObjFromDBWithKey:self.configure.passPort];
    if (mm) {
        return mm;
    }
    else {
        QWUnreadFlagModel *mm = [QWUnreadFlagModel new];
        mm.passport = self.configure.passPort;
        return mm;
    }
}

// TODO: 发通知 刷新VC
- (void)noticeUnreadLocalWithType:(NSInteger)type sessionID:(NSString *)sessionID isRead:(BOOL)isRead
{
    MsgBoxListItemModel *model = nil;
    if (type == MsgBoxListMsgTypeShopConsult) {
        if (!sessionID.length) return;
        model = [MsgBoxListItemModel getObjFromDBWithWhere:[NSString stringWithFormat:@"id = %@", sessionID]];
        if (isRead) {
           NSError *err = [PharMsgModel updateSetToDB:@"unreadCounts = '0', systemUnreadCounts = '0'" WithWhere:[NSString stringWithFormat:@"sessionId = %@", sessionID]];
            if (err) {
                DDLogError(@"[%@ %s]:%d. \n update PharMsgModel readStatus failed. \nERROR:%@",NSStringFromClass(self.class), __func__, __LINE__, err);
            }
        }
    }
    else if (type == MsgBoxListMsgTypeExpertPTP) {
        if (!sessionID.length) return;
        model = [MsgBoxListItemModel getObjFromDBWithWhere:[NSString stringWithFormat:@"id = %@", sessionID]];
        if (isRead) {
            NSError *err = [CircleChatPointModel updateSetToDB:@"readFlag = 1" WithWhere:[NSString stringWithFormat:@"sessionId = %@", sessionID]];
            if (err) {
                DDLogError(@"[%@ %s]:%d. \n update CircleChatPointModel readStatus failed. \nERROR:%@",NSStringFromClass(self.class), __func__, __LINE__, err);
            }
        }
    }
    else if (type == MsgBoxListMsgTypeHealth || type == MsgBoxListMsgTypeNotice || type == MsgBoxListMsgTypeOrder || type == MsgBoxListMsgTypeCircle) {
        model = [MsgBoxListItemModel getObjFromDBWithWhere:[NSString stringWithFormat:@"type = %@", StrFromInt(type)]];
    }
    if (model) {
        model.unread = isRead ? @"0" : @"1";
        [model updateToDB];
    }
    [self noticeUnreadByMsgBoxTypes:@[@(type)] readFlag:isRead];
}

- (void)noticeUnreadByPushType:(NSInteger)type readFlag:(BOOL)isRead newPush:(BOOL)isNewType
{
    if (isNewType) {
        if (type == MsgBoxNoticeTypeHealth) {
            [self noticeUnreadByMsgBoxTypes:@[@(MsgBoxListMsgTypeHealth)] readFlag:isRead];
        } else {
            [self noticeUnreadByMsgBoxTypes:@[@(MsgBoxListMsgTypeNotice)] readFlag:isRead];
        }
    } else {
        if (type == 2 || type == 8) {
            [self noticeUnreadByMsgBoxTypes:@[@(MsgBoxListMsgTypeHealth)] readFlag:isRead];
        }
        else if (type  == 18) {
            [self noticeUnreadByMsgBoxTypes:@[@(MsgBoxListMsgTypeOrder)] readFlag:isRead];
        }
        else if (type == 19) {
            [self noticeUnreadByMsgBoxTypes:@[@(MsgBoxListMsgTypeCircle)] readFlag:isRead];
        }
        else if (type == 25) {
            [self noticeUnreadByMsgBoxTypes:@[@(MsgBoxListMsgTypeExpertPTP)] readFlag:isRead];
        }
        else if (type == 9 || type == 10) {
            [self noticeUnreadByMsgBoxTypes:@[@(MsgBoxListMsgTypeShopConsult)] readFlag:isRead];
        }
        else if ([@[@11,@12,@13,@15,@16,@17,@28,@29,@30] containsObject:@(type)]) {
            [self noticeUnreadByMsgBoxTypes:@[@(MsgBoxListMsgTypeNotice)] readFlag:isRead];
        }
    }
//    @"5"])//第二次扩散
//    @"4"])//问题已过期（待测试）
//    @"3"])//问题已关闭（待测试）
//    @"7"])//聊天详情 // 咨询
    
//    @"2"])//全维药事
//    @"8"])//慢病订阅
    
//    @"9"])//点对点提示扩散
//    @"10"])//点对点聊天
    
//    @"11"])//运营平台代金券推送提
//    @"12"])//运营平台优惠商品推送
//    @"13"])// 资讯
//    @"15"])//外链
//    @"16"])//优惠活动
//    @"17"])//优惠使用情况通知
//    @"28"]) //资讯专题详情
//    @"29"]) //帖子详情
//    @"30"]) //消息通知列表
    
//    @"18"])//订单通知
    
//    @"19"]) //圈子消息
    
//    @"25"]) //圈子私聊列表

}


- (void)noticeUnreadByMsgBoxTypes:(NSArray *)types readFlag:(BOOL)isRead
{
    QWUnreadFlagModel *unreadMode = [self getUnreadModel];
    for (NSNumber *typeN in types) {
        MsgBoxListMsgType type = typeN.integerValue;
        switch (type) {
            case MsgBoxListMsgTypeHealth:
                unreadMode.healthMsgUnread = !isRead;
                break;
            case MsgBoxListMsgTypeNotice:
                unreadMode.noticeMsgUnread = !isRead;
                break;
            case MsgBoxListMsgTypeOrder:
                unreadMode.orderMsgUnread = !isRead;
                break;
            case MsgBoxListMsgTypeCircle:
                unreadMode.circleMsgUnread = !isRead;
                break;
            case MsgBoxListMsgTypeCredit:
                unreadMode.creditUnread = !isRead;
                break;
            case MsgBoxListMsgTypeShopConsult:
            {
                if (!isRead) {
                    unreadMode.shopConsultUnread = YES;
                }
            }
                break;
            case MsgBoxListMsgTypeExpertPTP:
            {
                if (!isRead) {
                    unreadMode.expertPTPMsgUnread = YES;
                }
            }
                break;
            default:
                break;
        }
    }
    [unreadMode updateToDB];
    
    if (isRead) {
        [QWGLOBALMANAGER postNotif:NotiMsgBoxNeedUpdateLocal data:@{@"types" : types} object:nil];
    } else {
        [QWGLOBALMANAGER postNotif:NotiMsgBoxNeedFetchNewData data:@{@"types" : types} object:nil];
    }
    [self updateRedPoint];
}

- (NSInteger)PullAllConsultMsgList:(ConsultCustomerListModel *)listModel
{
    __weak QWGlobalManager *weakSelf = self;
    NSMutableArray *arrLoaded = [NSMutableArray arrayWithArray:listModel.consults];
    NSMutableArray *arrCached = [NSMutableArray arrayWithArray:[HistoryMessages getArrayFromDBWithWhere:nil]];
    NSMutableArray *arrNeedAdded = [@[] mutableCopy];
    NSMutableArray *arrNeedDeleted = [@[] mutableCopy];
    // 删除服务器上没有，本地有的缓存数据
    [arrCached enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HistoryMessages *modelHis = (HistoryMessages *)obj;
        BOOL isExist = NO;
        for (ConsultCustomerModel *modelConsult in arrLoaded) {
            if ([modelConsult.consultId intValue] == [modelHis.relatedid intValue]) {
                isExist = YES;
                break;
            }
        }
        if (!isExist) {
            [arrNeedDeleted addObject:modelHis];
        }
    }];
    for (HistoryMessages *modelHis in arrNeedDeleted) {
        [HistoryMessages deleteObjFromDBWithKey:[NSString stringWithFormat:@"%@",modelHis.relatedid]];
    }
    // 更新数据问题
    arrCached = [NSMutableArray arrayWithArray:[HistoryMessages getArrayFromDBWithWhere:nil WithorderBy:@"timestamp desc"]];
    __block NSInteger count = 0;
    [arrLoaded enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ConsultCustomerModel *modelConsult = (ConsultCustomerModel *)obj;
        NSUInteger indexFound = [weakSelf valueExists:@"relatedid" withValue:[NSString stringWithFormat:@"%@",modelConsult.consultId] withArr:arrCached];
        if (indexFound != NSNotFound) {
            // 更新Model
            HistoryMessages *modelMessage = [arrCached objectAtIndex:indexFound];
            [QWGLOBALMANAGER convertConsultModelToMessages:modelConsult withModelMessage:&modelMessage];
        } else {
            HistoryMessages *modelMessage = [QWGLOBALMANAGER createNewMessage:modelConsult];
            [arrNeedAdded addObject:modelMessage];
        }
    }];
    [arrCached addObjectsFromArray:arrNeedAdded];
    for (int i = 0; i < arrCached.count; i++) {
        HistoryMessages *model = (HistoryMessages *)arrCached[i];
        [HistoryMessages updateObjToDB:model WithKey:model.relatedid];
        if ([model.isOutOfDate intValue] == 0) {
            count += [model.systemUnreadCounts intValue];
            count += [model.unreadCounts intValue];
        }
    }
    return count;
}

/**
 *  同步全量拉取的消息盒子数据到本地数据库
 */
- (void)sycMsgBoxListData:(MessageList *)listModel
{
    __weak QWGlobalManager *weakSelf = self;
    NSMutableArray *arrLoaded = [NSMutableArray arrayWithArray:listModel.messages];
    NSMutableArray *arrCached = [NSMutableArray arrayWithArray:[PharMsgModel getArrayFromDBWithWhere:nil]];
    NSMutableArray *arrNeedAdded = [@[] mutableCopy];
    NSMutableArray *arrNeedDeleted = [@[] mutableCopy];
    // 删除服务器上没有，本地有的缓存数据
    [arrCached enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PharMsgModel *modelHis = (PharMsgModel *)obj;
        
        BOOL isExist = NO;
        // 遍历本地缓存，与服务器上进行过滤筛选
        for (MessageItemVo *modelConsult in arrLoaded) {
            if ([modelConsult.type intValue] == 1) {
                modelConsult.branchId = @"1";
            }
            if ([modelConsult.type intValue] == 2) {
                modelConsult.branchId = @"2";
            }
            //4优惠券通知 5系统通知
            if ([modelConsult.type intValue] == 4) {
                modelConsult.branchId = @"4";
            }
            if ([modelConsult.type intValue] == 5) {
                modelConsult.branchId = @"5";
            }
            if ([modelConsult.type intValue] == 6) {
                modelConsult.branchId = @"6";
            }
            if (([modelHis.type intValue] != 1)||([modelHis.type intValue] != 2)||([modelHis.type intValue] != 3)||([modelHis.type intValue] != 4)||([modelHis.type intValue] != 5)||([modelHis.type intValue] != 6)) {
                isExist = NO;
                break;
            }
            if ([modelConsult.branchId intValue] == [modelHis.branchId intValue]) {
                isExist = YES;
                break;
            }
        }
        if (!isExist) {
            [arrNeedDeleted addObject:modelHis];
        }
    }];
    // 删除数据
    for (PharMsgModel *modelHis in arrNeedDeleted) {
        [PharMsgModel deleteObjFromDBWithKey:[NSString stringWithFormat:@"%@",modelHis.branchId]];
    }
    
    // 获取本地缓存的数据 // latestTime   // sessionLatestTime
    arrCached = [NSMutableArray arrayWithArray:[PharMsgModel getArrayFromDBWithWhere:nil WithorderBy:@" latestTime desc"]];
    [arrLoaded enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MessageItemVo *modelSession = (MessageItemVo *)obj;
        if ([modelSession.type intValue] == 1) {
            modelSession.branchId = @"1";
        }
        if ([modelSession.type intValue] == 2) {
            modelSession.branchId = @"2";
        }
        //4优惠券通知 5系统通知
        if ([modelSession.type intValue] == 4) {
            modelSession.branchId = @"4";
        }
        if ([modelSession.type intValue] == 5) {
            modelSession.branchId = @"5";
        }
        if ([modelSession.type intValue] == 6) {
            modelSession.branchId = @"6";
        }
        NSUInteger indexFound = [weakSelf valueExists:@"branchId" withValue:[NSString stringWithFormat:@"%@",modelSession.branchId] withArr:arrCached];
        // 更新数据
        if (indexFound != NSNotFound) {
            // 更新Model
            PharMsgModel *modelMessage = [arrCached objectAtIndex:indexFound];
            [QWGLOBALMANAGER convertSessionModelToMsg:modelSession withModelMsg:&modelMessage];
        } else {
            PharMsgModel *modelMessage = [QWGLOBALMANAGER createNewMsg:modelSession];
            [arrNeedAdded addObject:modelMessage];
        }
    }];
    [arrCached addObjectsFromArray:arrNeedAdded];
    NSInteger intCountPTP = 0;      //总共的点对点未读数
    NSInteger intCountNotilist = 0;     //总共的咨询历史未读数
    NSInteger intOfficial = 0;
    NSInteger intCouponCount = 0;   //优惠券未读数
    NSInteger intSysCount = 0;      //系统通知未读数
    NSInteger intOrderCount = 0;    // 订单通知未读数
    for (int i = 0; i < arrCached.count; i++) {
        PharMsgModel *model = (PharMsgModel *)arrCached[i];
        [PharMsgModel updateObjToDB:model WithKey:model.branchId];
        if ([model.type intValue] == [MsgBoxListConsultListType intValue]) {       // 消息咨询item
            intCountNotilist+=[model.unreadCounts intValue];        // 统计消息咨询的未读数
        } else if([model.type intValue] == [MsgBoxListPTPType intValue]) {
            intCountPTP += [model.unreadCounts intValue];       // 统计点对点的未读数
            intCountPTP += [model.systemUnreadCounts intValue];
        } else if ([model.type intValue] == [MsgBoxListOfficialType intValue]) {
            //设计的更改
            NSUInteger officialUnread = [OfficialMessages getcountFromDBWithWhere:@"issend = 0"];
            intOfficial += officialUnread;
        } else if ([model.type intValue] == [MsgBoxListCouponList intValue]) {
            intCouponCount += [model.unreadCounts intValue];
        } else if([model.type intValue] == [MsgBoxListSysList intValue]) {
            intSysCount += [model.unreadCounts intValue];
        } else if([model.type intValue] == [MsgBoxListOrderList intValue]) {
            intOrderCount += [model.unreadCounts intValue];
        }
    }
    
//    // 保存未读数到数据库
//    QWUnreadCountModel *modelUnread = [self getUnreadModel];
//    modelUnread.count_PTPUnread = [NSString stringWithFormat:@"%ld",intCountPTP];
//    modelUnread.count_NotifyListUnread = [NSString stringWithFormat:@"%ld",intCountNotilist];
//    modelUnread.count_OfficialUnread = [NSString stringWithFormat:@"%ld",intOfficial];
//    modelUnread.count_CouponUnread = [NSString stringWithFormat:@"%ld",intCouponCount];
//    modelUnread.count_sysUnread = [NSString stringWithFormat:@"%ld",intSysCount];
//    modelUnread.count_orderUnread = [NSString stringWithFormat:@"%ld",intOrderCount];
//    [QWUnreadCountModel updateObjToDB:modelUnread WithKey:QWGLOBALMANAGER.configure.passPort];
}

- (NSInteger)pullAllPTPList:(MessageList *)listModel
{
    [self sycMsgBoxListData:listModel];
    //发消息过去
    [self postNotif:NotiMessageBoxUpdateList data:listModel object:self];
    [self postNotif:NotiMessageUpdateMsgNotiList data:listModel object:self];
    return 0;
}

/**
 *  全量拉取圈子消息接口
 */
- (void)pullAllCircleMsgList
{
    //TODO: Perry V3.1 全量通知
    InfoCircleMsgListModelR *model = [InfoCircleMsgListModelR new];
    model.token = QWGLOBALMANAGER.configure.userToken;
    model.point = @"0";
    model.view = @"999";
    model.viewType = @"-1";
    [[CircleMsgSyncModel sharedInstance] pullAllCicleMsgListWithParams:model Success:^(CircleMsgListModel *model) {
        if (model.teamMsgList.count) {
            for (CircleTeamMsgVoModel *item in model.teamMsgList) {
                if (!item.flagRead) {
                    if (item.msgClass.integerValue == 1) {
                        self.configure.expertCommentRed = YES;
                    } else if (item.msgClass.integerValue == 2) {
                        self.configure.expertFlowerRed = YES;
                    } else if (item.msgClass.integerValue == 99) {
                        self.configure.expertSystemInfoRed = YES;
                    }
                }
            }
            if (self.configure.expertCommentRed || self.configure.expertFlowerRed || self.configure.expertSystemInfoRed) {
                [self saveAppConfigure];
                [self noticeUnreadByMsgBoxTypes:@[@(MsgBoxListMsgTypeCircle)] readFlag:NO];
            }
        }
        if (model.sessionMsglist.count) {
            BOOL hasUnread = NO;
            for (CircleChatPointModel *item in model.sessionMsglist) {
                if (!item.readFlag) {
                    hasUnread = YES;
                    break;
                }
            }
            if (hasUnread) {
                [self noticeUnreadByMsgBoxTypes:@[@(MsgBoxListMsgTypeExpertPTP)] readFlag:NO];
            }
        }
    } failure:^(HttpException *e) {
        
    }];
}

- (void)loginSucessCallBack
{
    //登录成功后，先全量拉取一遍消息盒子
    GetAllSessionModelR *modelSR = [GetAllSessionModelR new];
    modelSR.token = QWGLOBALMANAGER.configure.userToken;
    modelSR.point = @"0";
    modelSR.view = @"10000";
    modelSR.viewType = @"-1";
    [ConsultPTP getAllSessionList:modelSR success:^(MessageList *responModel) {
        self.lastTimestampForptpMsg = responModel.lastTimestamp;
        [self pullAllPTPList:responModel];
        
        
        [self updateRedPoint];
    } failure:^(HttpException *e) {
        
    }];
    [self pullAllCircleMsgList];
    //注册成功开启定时器
    [self createCircleMessageTimer];
    [self createMessageTimer];
    [self createMessageTimer2];

    [self enablePushNotification:NO];
    [self createPrivateDir];
    NSArray *sendingMsgs = [QWMessage getArrayFromDBWithWhere:@"issend = 1"];
    [sendingMsgs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        QWMessage *msg = (QWMessage *)obj;
        msg.issend = @"3";
        [QWMessage updateObjToDB:msg WithKey:msg.UUID];
    }];
    self.isKickOff = NO;
    [self checkLogEnable];
//    [self checkAllNewDisease];
}


- (HistoryMessages *)createNewMessage:(ConsultCustomerModel *)modelCustomer
{
    HistoryMessages *modelMessage = [HistoryMessages new];
    modelMessage.relatedid = [NSString stringWithFormat:@"%@",modelCustomer.consultId];
    if ([modelCustomer.consultStatus intValue] == ConsultOutOfDate) {
        modelMessage.relatedid = [NSString stringWithFormat:@"%d",ConsultOutOfDate];    // 设定特定的id便于更新
    }
    modelMessage.timestamp = modelCustomer.consultLatestTime;
    modelMessage.body = modelCustomer.consultTitle;
    modelMessage.avatarurl = modelCustomer.pharAvatarUrl;
    modelMessage.groupName = modelCustomer.pharShortName;
    modelMessage.pharType = modelCustomer.pharType;
    modelMessage.consultStatus = modelCustomer.consultStatus;
    modelMessage.unreadCounts = modelCustomer.unreadCounts;
    modelMessage.systemUnreadCounts = modelCustomer.systemUnreadCounts;
    modelMessage.consultFormatShowTime = modelCustomer.consultFormatShowTime;
    if ([modelCustomer.consultStatus intValue] == ConsultOutOfDate) {
        modelMessage.isOutOfDate = @"1";
        modelMessage.isShowRedPoint = @"1";
    } else {
        modelMessage.isOutOfDate = @"0";
        if (([modelCustomer.unreadCounts intValue]+[modelCustomer.systemUnreadCounts intValue]) > 0) {
            modelMessage.isShowRedPoint = @"1";
        } else {
            modelMessage.isShowRedPoint = @"0";
        }
    }
    modelMessage.consultMessage = modelCustomer.consultMessage;
    return modelMessage;
}

- (void)convertConsultModelToMessages:(ConsultCustomerModel *)modelCustomer withModelMessage:(HistoryMessages **)modelMessageOri
{
    (*modelMessageOri).relatedid = [NSString stringWithFormat:@"%@",modelCustomer.consultId];
    if ([modelCustomer.consultStatus intValue] == ConsultOutOfDate) {
        (*modelMessageOri).relatedid = [NSString stringWithFormat:@"%d",ConsultOutOfDate];
    }
    (*modelMessageOri).timestamp = modelCustomer.consultLatestTime;
    (*modelMessageOri).body = modelCustomer.consultTitle;
    (*modelMessageOri).avatarurl = modelCustomer.pharAvatarUrl;
    if ([modelCustomer.pharShortName length] > 0) {
        (*modelMessageOri).groupName = modelCustomer.pharShortName;
    }
    (*modelMessageOri).consultFormatShowTime = modelCustomer.consultFormatShowTime;
    (*modelMessageOri).pharType = modelCustomer.pharType;
    (*modelMessageOri).consultStatus = modelCustomer.consultStatus;
    (*modelMessageOri).unreadCounts = modelCustomer.unreadCounts;
    (*modelMessageOri).systemUnreadCounts = modelCustomer.systemUnreadCounts;
    (*modelMessageOri).consultMessage = modelCustomer.consultMessage;
    if ([modelCustomer.consultStatus intValue] == ConsultOutOfDate) {
        (*modelMessageOri).isOutOfDate = @"1";
    } else {
        (*modelMessageOri).isOutOfDate = @"0";
    }
    if (([modelCustomer.unreadCounts intValue]+[modelCustomer.systemUnreadCounts intValue]) > 0) {
        (*modelMessageOri).isShowRedPoint = @"1";
    } else {
        (*modelMessageOri).isShowRedPoint = @"0";
    }
    // 判断过期问题是否已读过
}

- (PharMsgModel *)createNewMsg:(MessageItemVo *)modelSession
{
    PharMsgModel *modelPhar = [PharMsgModel new];
    modelPhar.type = modelSession.type;
    modelPhar.branchId = modelSession.branchId;
    if ([modelSession.type intValue] == [MsgBoxListOfficialType intValue]) {
        modelPhar.branchId = MsgBoxListOfficialType;
    } else if ([modelSession.type intValue] == [MsgBoxListConsultListType intValue]) {
        modelPhar.branchId = MsgBoxListConsultListType;
    }
    modelPhar.sessionId = modelSession.sessionId;
    modelPhar.title = modelSession.title;
    modelPhar.content = modelSession.content;
    modelPhar.createTime = modelSession.createTime;
    modelPhar.formatShowTime = modelSession.formatShowTime;
    modelPhar.latestTime = modelSession.latestTime;
    modelPhar.imgUrl = modelSession.imgUrl;
    
    modelPhar.branchName = modelSession.branchName;
    modelPhar.branchPassport = modelSession.branchPassport;
    modelPhar.pharType = modelSession.pharType;
    modelPhar.unreadCounts = modelSession.unreadCounts;
    modelPhar.systemUnreadCounts = modelSession.systemUnreadCounts;
    modelPhar.isRead = @"0";
    
    return modelPhar;
}

- (void)convertSessionModelToMsg:(MessageItemVo *)modelSession withModelMsg:(PharMsgModel **)modelMsgPhar
{
    (*modelMsgPhar).sessionId = modelSession.sessionId;
    (*modelMsgPhar).type = modelSession.type;
    (*modelMsgPhar).branchId = modelSession.branchId;
    if ([modelSession.type intValue] == [MsgBoxListOfficialType intValue]) {
        (*modelMsgPhar).branchId = MsgBoxListOfficialType;
    } else if ([modelSession.type intValue] == [MsgBoxListConsultListType intValue]) {
        (*modelMsgPhar).branchId = MsgBoxListConsultListType;
    }
    (*modelMsgPhar).title = modelSession.title;
    (*modelMsgPhar).content = modelSession.content;
    (*modelMsgPhar).createTime = modelSession.createTime;
    (*modelMsgPhar).formatShowTime = modelSession.formatShowTime;
    (*modelMsgPhar).latestTime = modelSession.latestTime;
    (*modelMsgPhar).imgUrl = modelSession.imgUrl;
    
    (*modelMsgPhar).branchName = modelSession.branchName;
    (*modelMsgPhar).branchPassport = modelSession.branchPassport;
    (*modelMsgPhar).pharType = modelSession.pharType;
    (*modelMsgPhar).unreadCounts = modelSession.unreadCounts;
    (*modelMsgPhar).systemUnreadCounts = modelSession.systemUnreadCounts;
    //    (*modelMsgPhar).isRead = @"0";

}

- (MsgNotifyListModel *)createNewMsgNotifyList:(CustomerConsultVoModel *)modelCustomer
{
    MsgNotifyListModel *modelMessage = [MsgNotifyListModel new];
    modelMessage.relatedid = [NSString stringWithFormat:@"%@",modelCustomer.consultId];
    modelMessage.title = modelCustomer.consultTitle;
    modelMessage.formatShowTime = modelCustomer.consultFormatShowTime;
    modelMessage.consultLatestTime = modelCustomer.consultLatestTime;
    modelMessage.consultStatus = modelCustomer.consultStatus;
    modelMessage.pharShortName = modelCustomer.pharShortName;
    modelMessage.unreadCounts = modelCustomer.unreadCounts;
    modelMessage.systemUnreadCounts = modelCustomer.systemUnreadCounts;
    modelMessage.consultShowTitle = modelCustomer.consultShowTitle;
    modelMessage.pharAvatarUrl = modelCustomer.pharAvatarUrl;
    modelMessage.showRedPoint = @"0";
    modelMessage.branchId = modelCustomer.branchId;
    modelMessage.branchName = modelCustomer.branchName;
    return modelMessage;
}

- (void)convertConsultModelToNotifyList:(CustomerConsultVoModel *)modelCustomer withModelMessage:(MsgNotifyListModel **)modelMessageOri
{
    (*modelMessageOri).relatedid = [NSString stringWithFormat:@"%@",modelCustomer.consultId];
    (*modelMessageOri).title = modelCustomer.consultTitle;
    (*modelMessageOri).formatShowTime = modelCustomer.consultFormatShowTime;
    (*modelMessageOri).consultLatestTime = modelCustomer.consultLatestTime;
    (*modelMessageOri).consultStatus = modelCustomer.consultStatus;
    (*modelMessageOri).pharShortName = modelCustomer.pharShortName;
    (*modelMessageOri).unreadCounts = modelCustomer.unreadCounts;
    (*modelMessageOri).systemUnreadCounts = modelCustomer.systemUnreadCounts;
    (*modelMessageOri).consultShowTitle = modelCustomer.consultShowTitle;
    (*modelMessageOri).pharAvatarUrl = modelCustomer.pharAvatarUrl;
    (*modelMessageOri).branchId = modelCustomer.branchId;
    (*modelMessageOri).branchName = modelCustomer.branchName;
    // 判断过期问题是否已读过
}

- (SysNotiModel *)createSystemNotiModel:(SystemMessageVo *)modelLoad
{
    SysNotiModel *modelSystem = [SysNotiModel new];
    modelSystem.id = [NSString stringWithFormat:@"%@",modelLoad.id];
    modelSystem.showTitle = [NSString stringWithFormat:@"%@",modelLoad.showTitle];
    modelSystem.createTime = [NSString stringWithFormat:@"%@",modelLoad.createTime];
    modelSystem.formatShowTime = [NSString stringWithFormat:@"%@",modelLoad.formatShowTime];
    modelSystem.unreadCounts = [NSString stringWithFormat:@"%@",modelLoad.unreadCounts];
    modelSystem.showRedPoint = @"0";
    return modelSystem;
}

- (void)convertSystemNotiModel:(SystemMessageVo *)modelSys withModelLocal:(SysNotiModel **)modelLocal
{
    (*modelLocal).id = [NSString stringWithFormat:@"%@",modelSys.id];
    (*modelLocal).showTitle = [NSString stringWithFormat:@"%@",modelSys.showTitle];
    (*modelLocal).createTime = [NSString stringWithFormat:@"%@",modelSys.createTime];
    (*modelLocal).formatShowTime = [NSString stringWithFormat:@"%@",modelSys.formatShowTime];
    (*modelLocal).unreadCounts = [NSString stringWithFormat:@"%@",modelSys.unreadCounts];
}

- (CouponNotiModel *)createCouponNotiModel:(CouponMessageVo *)modelLoad
{
    CouponNotiModel *modelCoupon = [CouponNotiModel new];
    modelCoupon.myCouponId = [NSString stringWithFormat:@"%@",modelLoad.myCouponId];
    modelCoupon.showTitle = [NSString stringWithFormat:@"%@",modelLoad.showTitle];
    modelCoupon.createTime = [NSString stringWithFormat:@"%@",modelLoad.createTime];
    modelCoupon.formatShowTime = [NSString stringWithFormat:@"%@",modelLoad.formatShowTime];
    modelCoupon.unreadCounts = [NSString stringWithFormat:@"%@",modelLoad.unreadCounts];
    modelCoupon.showRedPoint = @"0";
    modelCoupon.status = [NSString stringWithFormat:@"%@",modelLoad.status];
    modelCoupon.type = [NSString stringWithFormat:@"%@",modelLoad.type];
    modelCoupon.messageId = [NSString stringWithFormat:@"%@",modelLoad.messageId];
    modelCoupon.content = [NSString stringWithFormat:@"%@",modelLoad.content];
    modelCoupon.url = [NSString stringWithFormat:@"%@",modelLoad.url];
    modelCoupon.objType = [NSString stringWithFormat:@"%@",modelLoad.objType];
    modelCoupon.objId = [NSString stringWithFormat:@"%@",modelLoad.objId];
    modelCoupon.contentType = [NSString stringWithFormat:@"%@",modelLoad.contentType];
    modelCoupon.branchId = [NSString stringWithFormat:@"%@",modelLoad.branchId];
    modelCoupon.attentionName = [NSString stringWithFormat:@"%@",modelLoad.attentionName];
    modelCoupon.drugGuideId = [NSString stringWithFormat:@"%@",modelLoad.drugGuideId];
    return modelCoupon;
}
// 转换优惠券Model
- (void)convertCouponModel:(CouponMessageVo *)modelCoupon withModelCouponLocal:(CouponNotiModel **)modelLocal
{
    (*modelLocal).myCouponId = [NSString stringWithFormat:@"%@",modelCoupon.myCouponId];
    (*modelLocal).myCouponId = modelCoupon.myCouponId;
    (*modelLocal).showTitle = modelCoupon.showTitle;
    (*modelLocal).createTime = modelCoupon.createTime;
    (*modelLocal).formatShowTime = modelCoupon.formatShowTime;
    (*modelLocal).unreadCounts = modelCoupon.unreadCounts;
    (*modelLocal).status = [NSString stringWithFormat:@"%@",modelCoupon.status];
    (*modelLocal).type = [NSString stringWithFormat:@"%@",modelCoupon.type];
    (*modelLocal).messageId = [NSString stringWithFormat:@"%@",modelCoupon.messageId];
    (*modelLocal).content = [NSString stringWithFormat:@"%@",modelCoupon.content];
    (*modelLocal).url = [NSString stringWithFormat:@"%@",modelCoupon.url];
    (*modelLocal).objType = [NSString stringWithFormat:@"%@",modelCoupon.objType];
    (*modelLocal).objId = [NSString stringWithFormat:@"%@",modelCoupon.objId];
    (*modelLocal).contentType = [NSString stringWithFormat:@"%@",modelCoupon.contentType];
    (*modelLocal).branchId = [NSString stringWithFormat:@"%@",modelCoupon.branchId];
    (*modelLocal).attentionName = [NSString stringWithFormat:@"%@",modelCoupon.attentionName];
    (*modelLocal).drugGuideId = [NSString stringWithFormat:@"%@",modelCoupon.drugGuideId];
}

- (OrderNotiModel *)createOrderNotiModel:(OrderMessageVo *)modelLoad
{
    OrderNotiModel *modelOrder = [OrderNotiModel new];
    modelOrder.orderId = [NSString stringWithFormat:@"%@",modelLoad.orderId];
    modelOrder.title = [NSString stringWithFormat:@"%@",modelLoad.title];
    modelOrder.createTime = [NSString stringWithFormat:@"%@",modelLoad.createTime];
    modelOrder.showTime = [NSString stringWithFormat:@"%@",modelLoad.showTime];
    modelOrder.unreadCounts = [NSString stringWithFormat:@"%@",modelLoad.unreadCounts];
    modelOrder.showRedPoint = @"0";
    modelOrder.messageId = [NSString stringWithFormat:@"%@",modelLoad.messageId];
    modelOrder.content = [NSString stringWithFormat:@"%@",modelLoad.content];
    return modelOrder;
}
- (void)convertOrderModel:(OrderMessageVo *)modelOrder withModelOrderLocal:(OrderNotiModel **)modelLocal
{
    (*modelLocal).orderId = modelOrder.orderId;
    (*modelLocal).title = modelOrder.title;
    (*modelLocal).createTime = modelOrder.createTime;
    (*modelLocal).showTime = modelOrder.showTime;
    (*modelLocal).unreadCounts = modelOrder.unreadCounts;
    (*modelLocal).messageId = [NSString stringWithFormat:@"%@",modelOrder.messageId];
    (*modelLocal).content = [NSString stringWithFormat:@"%@",modelOrder.content];
}

//- (PharMsgModel *)createNewMsg:(CustomerSessionVo *)modelSession
//{
//    PharMsgModel *modelPhar = [PharMsgModel new];
//    modelPhar.sessionId = modelSession.sessionId;
//    modelPhar.content = modelSession.sessionLatestContent;
////    modelPhar.sessionCreateTime = modelSession.sessionCreateTime;
//    modelPhar.formatShowTime = modelSession.sessionFormatShowTime;
//    modelPhar.latestTime = modelSession.sessionLatestTime;
//    modelPhar.imgUrl = modelSession.pharAvatarUrl;
//    modelPhar.branchId = modelSession.branchId;
//    modelPhar.branchName = modelSession.branchShortName;
//    modelPhar.branchPassport = modelSession.branchPassport;
//    modelPhar.pharType = modelSession.pharType;
//    modelPhar.unreadCounts = modelSession.unreadCounts;
//    modelPhar.systemUnreadCounts = modelSession.systemUnreadCounts;
//    modelPhar.isRead = @"0";
//    
//    return modelPhar;
//}
//
//- (void)convertSessionModelToMsg:(CustomerSessionVo *)modelSession withModelMsg:(PharMsgModel **)modelMsgPhar
//{
//    (*modelMsgPhar).sessionId = modelSession.sessionId;
//    (*modelMsgPhar).sessionLatestContent = modelSession.sessionLatestContent;
//    (*modelMsgPhar).sessionCreateTime = modelSession.sessionCreateTime;
//    (*modelMsgPhar).sessionFormatShowTime = modelSession.sessionFormatShowTime;
//    (*modelMsgPhar).sessionLatestTime = modelSession.sessionLatestTime;
//    (*modelMsgPhar).pharAvatarUrl = modelSession.pharAvatarUrl;
//    (*modelMsgPhar).branchId = modelSession.branchId;
//    (*modelMsgPhar).branchShortName = modelSession.branchShortName;
//    (*modelMsgPhar).branchPassport = modelSession.branchPassport;
//    (*modelMsgPhar).pharType = modelSession.pharType;
//    (*modelMsgPhar).unreadCounts = modelSession.unreadCounts;
//    (*modelMsgPhar).systemUnreadCounts = modelSession.systemUnreadCounts;
////    (*modelMsgPhar).isRead = @"0";
//}

- (void)initNavigationBarStyle:(UIColor *)color
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UINavigationBar appearance] setBarTintColor:color];
    [[UINavigationBar appearance] setTintColor:RGBHex(qwColor6)];
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName:RGBHex(qwColor6),NSFontAttributeName:[UIFont systemFontOfSize:kFontS13]}];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBHex(qwColor1),NSFontAttributeName:[UIFont systemFontOfSize:kFontS1]} forState:UIControlStateNormal];
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,[color CGColor]);
    CGContextFillRect(context, rect);
    UIImage * imge = [[UIImage alloc] init];
    imge = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[UINavigationBar appearance] setBackgroundImage:imge forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"img-shaow"]];
}


//登录成功后创建私有目录
- (void)createPrivateDir
{
    NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/%@",self.configure.userName]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:homePath]){
        [fileManager createDirectoryAtPath:homePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    homePath = [homePath stringByAppendingString:@"/Voice"];
    if(![fileManager fileExistsAtPath:homePath]){
        [fileManager createDirectoryAtPath:homePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    homePath = [homePath stringByAppendingString:@"/Log"];
    if(![fileManager fileExistsAtPath:homePath]){
        [fileManager createDirectoryAtPath:homePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)enablePushNotification:(BOOL)enable
{
    if(!self.loginStatus)
        return;
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = self.configure.userToken;
    setting[@"source"] = @"1";
    
    SystemModelR *systemModelR = [SystemModelR new];
    systemModelR.token = self.configure.userToken;
    if(enable) {
        systemModelR.backStatus = @"0";
    }else{
        systemModelR.backStatus = @"1";
    }
    systemModelR.source = @"1";
    
    HttpClientMgr.progressEnabled=NO;
    [System systemBackSetWithParams:systemModelR success:^(id obj) {
        
    } failure:NULL];
}

#pragma mark -
#pragma mark  全局定时器 轮询向服务器拉数据

//官方消息定时轮训
- (void)createMessageTimer
{
    return; // 关闭QWYS轮询
    pullMessageTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(pullMessageTimer, dispatch_time(DISPATCH_TIME_NOW, 3ull*NSEC_PER_SEC), 60ull*NSEC_PER_SEC , DISPATCH_TIME_FOREVER);
    dispatch_source_set_event_handler(pullMessageTimer, ^{
        [self pullOfficialMessage];
    });
    dispatch_source_set_cancel_handler(pullMessageTimer, ^{
        DDLogVerbose(@"has been canceled");
    });
    dispatch_resume(pullMessageTimer);
}

//消息盒子定时轮训  10s一次
- (void)createMessageTimer2
{
    self.lastTimestampfortimer = @"";
    pullMessageBoxTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(pullMessageBoxTimer, dispatch_time(DISPATCH_TIME_NOW, 3ull*NSEC_PER_SEC), 10ull*NSEC_PER_SEC , DISPATCH_TIME_FOREVER);
    dispatch_source_set_event_handler(pullMessageBoxTimer, ^{
        self.pullCount = 0;
//        [self pullNewNotiList]; // 关闭旧的消息盒子
        [self pullNewPTPMsg];
        //圈子消息轮询接口 comment by Perry V3.1
        [self pullNewCircleMsg];
//        [self pullNewCircleSessions];
    });
    dispatch_source_set_cancel_handler(pullMessageBoxTimer, ^{
        DDLogVerbose(@"has been canceled");
    });
    dispatch_resume(pullMessageBoxTimer);
}

//每10秒触发一次心跳包,返回服务器时间
- (void)createHeartBeatTimer
{
    heartBeatTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(heartBeatTimer, dispatch_time(DISPATCH_TIME_NOW, 3ull*NSEC_PER_SEC), 10ull*NSEC_PER_SEC , DISPATCH_TIME_FOREVER);
    dispatch_source_set_event_handler(heartBeatTimer, ^{
        [self checkCurrentSystemTime];
    });
    dispatch_source_set_cancel_handler(heartBeatTimer, ^{
        DDLogVerbose(@"has been canceled");
    });
    dispatch_resume(heartBeatTimer);
}

// 从服务器获取一个全局配置，该值决定无密码登录和注册是否要验证码
- (void)getForceSecuritySwitch
{
    [Mbr getVerifyCodeSwitchSuccess:^(VerifyCodeSwitchModel *model) {
        if (model.status == 2) {
            QWGLOBALMANAGER.configure.forceSecurityVerifyCode = YES;
        }
        else
        {
            QWGLOBALMANAGER.configure.forceSecurityVerifyCode = NO;
        }
    } failure:^(HttpException *e) {
        QWGLOBALMANAGER.configure.forceSecurityVerifyCode = YES;
        DDLogError(@"短信验证码发送开关失败:%@", [e description]);
    }];
}



// 从服务器获取需要统计的商家的信息
- (void)getStatisBranchArray
{
    [Mbr getStatisArraySuccess:^(TdVo *model) {
        if([model.apiStatus intValue]==0){
            if(model.groups.count>0){
                QWGLOBALMANAGER.tdModel.groups=model.groups;
                [QWGLOBALMANAGER saveBranchConfigure];
            }
        }
    } failure:^(HttpException *e) {
    }];
}

- (void)releaseHeartBeatTimer
{
    if(heartBeatTimer) {
        dispatch_source_cancel(self.heartBeatTimer);
        self.heartBeatTimer = NULL;
    }
}

- (void)releaseMessageTimer
{
    if(self.pullCircleMessageTimer)
    {
        dispatch_source_cancel(self.pullCircleMessageTimer);
        self.pullCircleMessageTimer = NULL;
    }
    if (pullMessageTimer) {
        dispatch_source_cancel(pullMessageTimer);
    }
    if (pullMessageBoxTimer) {
        dispatch_source_cancel(pullMessageBoxTimer);
    }
}


#pragma mark -
#pragma mark  拉取官方消息
- (void)pullOfficialMessage
{
    if(!self.loginStatus)
        return;
    
    PollByCustomerR *imSelectQWModelR = [PollByCustomerR new];
   
    imSelectQWModelR.token = self.configure.userToken;
    if (self.lastQWYSTime) {
       imSelectQWModelR.lastTimestamp = self.lastQWYSTime;
    }else
    {
    
    imSelectQWModelR.lastTimestamp = @"0";
   
    }
    
     
    HttpClientMgr.progressEnabled=NO;

    [IMApi pollByCustomer:imSelectQWModelR success:^(id resultObj) {
//        DDLogVerbose(@"##### the objects is %@",resultObj);
        NSArray *array = resultObj[@"records"];
        self.lastQWYSTime  =resultObj[@"lastTimestamp"];
        if([array isKindOfClass:[NSString class]])
        {
            return;
        }
        for(NSDictionary *dict in array)
        {
//            NSUInteger type = [dict[@"type"] integerValue];
            NSDictionary *info = dict[@"info"];
            NSString *content = info[@"content"];
            NSString *fromId = info[@"fromId"];
            NSString *toId = info[@"toId"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            double timeStamp = [[formatter dateFromString:info[@"time"]] timeIntervalSince1970];
            NSString *UUID = info[@"id"];
            NSUInteger fromTag = [info[@"fromTag"] integerValue];
            NSString *fromName = info[@"fromName"];
            NSUInteger msgType = [info[@"source"] integerValue];
            if(msgType == 0)
                msgType = 1;
            
//            NSString *relatedId = @"";
            NSString *where = [NSString stringWithFormat:@"UUID = '%@'",UUID];
            NSArray *tagList = [TagWithMessage getArrayFromDBWithWhere:where];
            for(NSDictionary *tag in info[@"tags"])
            {
                TagWithMessage *tagTemp = [[TagWithMessage alloc] init];
                
                tagTemp.length = tag[@"length"];
                tagTemp.start = tag[@"start"];
                tagTemp.tagType = tag[@"tag"];
                tagTemp.tagId = tag[@"tagId"];
                tagTemp.title = tag[@"title"];
                tagTemp.UUID = UUID;
                [TagWithMessage saveObjToDB:tagTemp];
            }
//            
            OfficialMessages * omsg = [OfficialMessages getObjFromDBWithKey:UUID];
            if (omsg) {
                return;
            }
            
                TagWithMessage * tag = nil;
                if (tagList.count>0) {
                    tag = tagList[0];
                }
                OfficialMessages * msg =  [[OfficialMessages alloc] init];
                msg.fromId = fromId;
                msg.toId = toId;
                msg.timestamp = [NSString stringWithFormat:@"%f",timeStamp];
                msg.body = content;
                msg.direction = [NSString stringWithFormat:@"%.0ld",(long)XHBubbleMessageTypeReceiving];
                msg.messagetype = [NSString stringWithFormat:@"%lu",(unsigned long)msgType];
                msg.UUID = UUID;
                msg.issend = @"0";
                msg.fromTag = fromTag ;
                msg.title = fromName;
                msg.relatedid = fromId;///此处是不是有问题
                msg.subTitle = tag.title;
                [OfficialMessages saveObjToDB:msg];
            }
//        }
//        if(array.count > 0)
//        {
//            NSUInteger officalUnread = [OfficialMessages getcountFromDBWithWhere:@"issend = 0"];
//            QWUnreadCountModel *modelUnread = [self getUnreadModel];
//            modelUnread.count_OfficialUnread = [NSString stringWithFormat:@"%d",officalUnread];
//            [QWUnreadCountModel updateObjToDB:modelUnread WithKey:QWGLOBALMANAGER.configure.passPort];
//            [self updateRedPoint];
//            [self postNotif:NotifMessageOfficial data:nil object:self];
//        }
    } failure:NULL];

    //MARK: 慢病订阅小红点流程 comment by perry
//    [self queryAllDisease];
    //判断当前账号是否失效
}

#pragma mark -
#pragma mark  拉取消息盒子消息，(如果有未关闭和未过期的问题时拉取)

- (void)pullMessageBox
{
    if(!self.loginStatus)
        return;
    
    //只有未关闭和未过期的问题才去拉数据
    
    NSArray *arrNeedUpdate = [HistoryMessages getArrayFromDBWithWhere:[NSString stringWithFormat:@"consultStatus = '%d' or consultStatus = '%d' or consultStatus = '%d'",ConsultWaitResponding,ConsultGrabWithoutAnswer,ConsultRobAndAbandon]];
    if (arrNeedUpdate.count <= 0) {
        return;
    }
    NSMutableArray *arrItems = [@[] mutableCopy];
    for (HistoryMessages *msgModel in arrNeedUpdate) {
        [arrItems addObject:msgModel.relatedid];
    }
    NSString *strItems = [arrItems componentsJoinedByString:SeparateStr];
    
    ConsultCustomerNewModelR *modelR = [ConsultCustomerNewModelR new];
    modelR.token = QWGLOBALMANAGER.configure.userToken;
    modelR.lastTimestamp = self.lastTimestampfortimer;
    modelR.consultIds = strItems;
    //增量轮训
    [Consult getNewConsultCustomerListWithParam:modelR success:^(ConsultCustomerListModel *responModel) {
        ConsultCustomerListModel *listModel = (ConsultCustomerListModel *)responModel;
        
        self.lastTimestampfortimer = listModel.lastTimestamp;
        
        NSMutableArray *arrNeedDelete = [@[] mutableCopy];      //需要删除的过期问题集合
        NSInteger count = 0;
        NSMutableArray *arrLocal = [NSMutableArray arrayWithArray:[HistoryMessages getArrayFromDBWithWhere:nil]];
        for(ConsultCustomerModel* model in listModel.consults)
        {
            //是过期问题，设定特殊的ID，好处理
            if ([model.consultStatus intValue] == ConsultOutOfDate) {
                model.consultId = [NSString stringWithFormat:@"%d",ConsultOutOfDate];
            }
            NSUInteger indexFound = [self valueExists:@"relatedid" withValue:[NSString stringWithFormat:@"%@",model.consultId] withArr:arrLocal];
            
            if (indexFound != NSNotFound) {
                // 更新Model
                HistoryMessages *modelMessage = [arrLocal objectAtIndex:indexFound];
                [self convertConsultModelToMessages:model withModelMessage:&modelMessage];
                if ([modelMessage.consultStatus intValue] == ConsultOutOfDate) {
                    modelMessage.isOutOfDate = @"1";
                    [arrNeedDelete addObject:modelMessage];
                }
                //未读数增量
                HistoryMessages *modelMessageTemp = [HistoryMessages getObjFromDBWithKey:modelMessage.relatedid];
                modelMessage.unreadCounts = [NSString stringWithFormat:@"%d",[model.unreadCounts integerValue]+[modelMessageTemp.unreadCounts integerValue]];
                [HistoryMessages updateObjToDB:modelMessage WithKey:[NSString stringWithFormat:@"%@",modelMessage.relatedid]];
            }
        }
        // 用来存储返回列表中第一个过期的问题
        HistoryMessages *modelQuizClosed = nil;
        if (arrNeedDelete.count > 0) {
            for (int i = 0; i < arrNeedDelete.count; i++) {
                HistoryMessages *modelMsg = (HistoryMessages *)arrNeedDelete[i];
                [HistoryMessages deleteObjFromDBWithKey:modelMsg.relatedid];
            }
            arrNeedDelete = [self sortArrWithKey:@"timestamp" isAscend:NO oriArray:arrNeedDelete];
            modelQuizClosed = arrNeedDelete[0];
        }
        // 获取本地缓存
        arrLocal = [NSMutableArray arrayWithArray:[HistoryMessages getArrayFromDBWithWhere:nil]];
        
        // 找到原有数据库中过期问题
        BOOL findQizOutOfDate = NO;
        HistoryMessages *quizHisNeedUpdate = nil;
        // 遍历本地缓存的
        for (HistoryMessages *modelHis in arrLocal) {
            if ([modelHis.isOutOfDate intValue] == 0) {     // 非过期问题更新未读数
                count+=[modelHis.unreadCounts intValue];
                count+=[modelHis.systemUnreadCounts intValue];
            } else {
                findQizOutOfDate = YES;         //获取原有的过期问题
                quizHisNeedUpdate = modelHis;
            }
        }
        
        if (modelQuizClosed != nil) {
            if (findQizOutOfDate) {
                quizHisNeedUpdate.timestamp = modelQuizClosed.timestamp;
                quizHisNeedUpdate.groupName = modelQuizClosed.groupName;
                quizHisNeedUpdate.body = modelQuizClosed.body;
                quizHisNeedUpdate.isShowRedPoint = @"1";
                [HistoryMessages updateObjToDB:quizHisNeedUpdate WithKey:quizHisNeedUpdate.relatedid];
            } else {
                modelQuizClosed.isShowRedPoint = @"1";
                [HistoryMessages updateObjToDB:modelQuizClosed WithKey:modelQuizClosed.relatedid];
            }
        }
        NSInteger intNewCount = 0;
        for(ConsultCustomerModel* model in listModel.consults) {
            intNewCount+=[model.unreadCounts intValue];
            intNewCount+=[model.systemUnreadCounts intValue];
        }

//        QWUnreadCountModel *modelUnread = [self getUnreadModel];
//        modelUnread.count_CounsultUnread = [NSString stringWithFormat:@"%d",count];
//        [QWUnreadCountModel updateObjToDB:modelUnread WithKey:self.configure.passPort];
//        [self updateRedPoint];
//        //发消息过去
//        [self postNotif:NotiMessageBoxUpdateList data:listModel object:self];
    } failure:^(HttpException *e) {
        self.pullCount++;
    }];
}
- (NSMutableArray *)sortArrWithKey:(NSString *)strKey isAscend:(BOOL)isAscend oriArray:(NSMutableArray *)oriArr
{
    NSMutableArray *arrSorted = [@[] mutableCopy];
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:strKey ascending:isAscend];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
    arrSorted = [[oriArr sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    return arrSorted;
}

// 店长咨询P2P
- (void)pullNewPTPMsg
{
    if (!self.loginStatus) {
        return;
    }
    GetNewSessionModelR *modelR = [GetNewSessionModelR new];
    modelR.token = QWGLOBALMANAGER.configure.userToken;
    modelR.lastTimestamp = self.lastTimestampForptpMsg;
    [ConsultPTP getNewSessionList:modelR success:^(CustomerSessionList *responModel) {
//        DDLogVerbose(@"the func is %s, the respon model is %@",__func__,responModel);
        CustomerSessionList *listModel = (CustomerSessionList *)responModel;
        self.lastTimestampForptpMsg = listModel.lastTimestamp;      //储存最新的访问接口的时间戳
        NSMutableArray *arrLocal = [NSMutableArray arrayWithArray:[PharMsgModel getArrayFromDBWithWhere:@"type = 3"]];
        if (listModel.sessions.count > 0) {
            // 遍历服务器端数组
            for(CustomerSessionVo* model in listModel.sessions)
            {
                if ([StrFromObj(model.sessionId) isEqualToString:self.currentShopConsultBranchID]) {
                    model.unreadCounts = @"0";
                    model.systemUnreadCounts = @"0";
                }
                // 是否在本地数据库中找到相同的Model
                NSUInteger indexFound = [self valueExists:@"branchId" withValue:[NSString stringWithFormat:@"%@",model.branchId] withArr:arrLocal];
                
                if (indexFound != NSNotFound) {
                    // 更新本地数据库
                    PharMsgModel *modelMessage = [arrLocal objectAtIndex:indexFound];
                    if (modelMessage.latestTime.doubleValue < model.sessionLatestTime.doubleValue) {
                        modelMessage.sessionId = model.sessionId;
                        modelMessage.type = MsgBoxListPTPType;
                        modelMessage.title = model.branchShortName;
                        modelMessage.content = model.sessionLatestContent;
                        modelMessage.formatShowTime = model.sessionFormatShowTime;
                        modelMessage.latestTime = model.sessionLatestTime;
                        modelMessage.imgUrl = model.pharAvatarUrl;
                        // 判断是否轮询在聊天页面中，在当前页面不处理未读数
                        if ([[NSString stringWithFormat:@"%@",modelMessage.sessionId] isEqualToString:[NSString stringWithFormat:@"%@",self.strPTPSessionID]]) {
                            modelMessage.unreadCounts = @"0";
                            modelMessage.systemUnreadCounts = @"0";
                        } else {
                            modelMessage.unreadCounts = [NSString stringWithFormat:@"%d",[model.unreadCounts intValue]+[modelMessage.unreadCounts intValue]];
                            
                            modelMessage.systemUnreadCounts = model.systemUnreadCounts;
                        }
                        
                        modelMessage.pharType = model.pharType;
                        modelMessage.branchId = model.branchId;
                        
                        // 将本地的未读数和系统给的新的未读数相加后，更新数据库
                        //                    PharMsgModel *modelMsgTemp = [PharMsgModel getObjFromDBWithKey:modelMessage.branchId];
                        //                    modelMessage.unreadCounts = [NSString stringWithFormat:@"%d",[modelMessage.unreadCounts integerValue]+[modelMsgTemp.unreadCounts integerValue]];
                        
                        [PharMsgModel updateObjToDB:modelMessage WithKey:[NSString stringWithFormat:@"%@",modelMessage.branchId]];
                    }
                } else {
                    DDLogVerbose(@"the model is %@",model);
                    PharMsgModel *modelPhar = [PharMsgModel new];
                    modelPhar.sessionId = model.sessionId;
                    modelPhar.content = model.sessionLatestContent;
                    modelPhar.type = MsgBoxListPTPType;
                    modelPhar.pharType = model.pharType;
                    modelPhar.title = model.branchShortName;
                    //    modelPhar.sessionCreateTime = modelSession.sessionCreateTime;
                    modelPhar.formatShowTime = model.sessionFormatShowTime;
                    modelPhar.latestTime = model.sessionLatestTime;
                    modelPhar.imgUrl = model.pharAvatarUrl;
                    modelPhar.branchId = model.branchId;
//                    modelPhar.branchName = model.branchShortName;
                    modelPhar.branchPassport = model.branchPassport;
                    
                    modelPhar.unreadCounts = model.unreadCounts;
                    modelPhar.systemUnreadCounts = model.systemUnreadCounts;
                    modelPhar.isRead = @"0";
                    [PharMsgModel updateObjToDB:modelPhar WithKey:[NSString stringWithFormat:@"%@",modelPhar.branchId]];
                }
            }
            NSInteger intNewCount = 0;         // 记录轮询到点对点的新的未读数
            for(MessageItemVo* model in listModel.sessions) {
                if ([[NSString stringWithFormat:@"%@",model.sessionId] isEqualToString:[NSString stringWithFormat:@"%@",self.strPTPSessionID]]) {
                } else {
                    intNewCount+=[model.unreadCounts intValue];
                    intNewCount+=[model.systemUnreadCounts intValue];
                }
            }
            
            NSArray *modelArr = [PharMsgModel getArrayFromDBWithWhere:nil];
            NSInteger unreadSum = 0;
            for (PharMsgModel *msg in modelArr) {
                unreadSum += msg.unreadCounts.integerValue;
            }
            
            if (unreadSum > 0) {
                [QWGLOBALMANAGER noticeUnreadByMsgBoxTypes:@[@(MsgBoxListMsgTypeShopConsult)] readFlag:NO];
            }
            
            //发消息过去
            [self postNotif:NotiMessagePTPUpdateList data:listModel object:self];
        }
        
    } failure:^(HttpException *e) {
        self.pullCount++;
    }];
}

/**
 *  轮询拉取通知列表
 */
- (void)pullNewNotiList
{
    if (!self.loginStatus) {
        return;
    }
    //增量拉取消息盒子通知列表数据
    ConsultCustomerModelR *modelR = [ConsultCustomerModelR new];
    modelR.token = QWGLOBALMANAGER.configure.userToken;
    [Consult pollNoticeListByCustomerWithParam:modelR success:^(ConsultCustomerListModel *responModel) {
//        DDLogVerbose(@"the func is %s, the respon model is %@",__func__,responModel);
        ConsultCustomerListModel *listModel = (ConsultCustomerListModel *)responModel;
        NSMutableArray *arrLocal = [NSMutableArray arrayWithArray:[MsgNotifyListModel getArrayFromDBWithWhere:nil]];
        if (listModel.consults.count > 0) {
            // 遍历服务器端数组
            for(CustomerConsultVoModel* model in listModel.consults)
            {
                // 是否在本地数据库中找到相同的Model
                NSUInteger indexFound = [self valueExists:@"relatedid" withValue:[NSString stringWithFormat:@"%@",model.consultId] withArr:arrLocal];
                
                if (indexFound != NSNotFound) {
                    // 更新本地数据库
                    MsgNotifyListModel *modelMessage = [arrLocal objectAtIndex:indexFound];
                    
                    [self convertConsultModelToNotifyList:model withModelMessage:&modelMessage];
                    MsgNotifyListModel *modelMsgTemp = [MsgNotifyListModel getObjFromDBWithKey:modelMessage.relatedid];
                    // 判断是否轮询在聊天页面中，在当前页面不处理未读数
                    if ([[NSString stringWithFormat:@"%@",model.consultId] isEqualToString:[NSString stringWithFormat:@"%@",self.strConsultID]]) {
                        modelMessage.unreadCounts = @"0";
                    } else {
                        modelMessage.unreadCounts = [NSString stringWithFormat:@"%d",[modelMessage.unreadCounts integerValue]+[modelMsgTemp.unreadCounts integerValue]];
                    }
                    [MsgNotifyListModel updateObjToDB:modelMessage WithKey:[NSString stringWithFormat:@"%@",modelMessage.relatedid]];
                }
            }
            // 重新拿取本地的缓存
//            arrLocal = [NSMutableArray arrayWithArray:[MsgNotifyListModel getArrayFromDBWithWhere:nil]];
            
            NSInteger intNewCount = 0;          // 记录轮询到咨询的新的未读数
            for(CustomerConsultVoModel* model in listModel.consults) {
                // 判断是否轮询在当前页面中，在当前页面不处理未读数
                if (![[NSString stringWithFormat:@"%@",model.consultId] isEqualToString:[NSString stringWithFormat:@"%@",self.strConsultID]]) {
                    if (([model.unreadCounts intValue]>=1)||([model.systemUnreadCounts intValue]>=1)) {
                        intNewCount++;      // 增加未读数
                    }
                }
            }
            // 获取服务器上第一个返回的Model
            CustomerConsultVoModel *modelCus = (CustomerConsultVoModel *)listModel.consults[0];
            // 获取消息盒子的免费咨询条目，如果找到，那么更新这个条目，否则新建后储存
            PharMsgModel *modelPhar = [PharMsgModel getObjFromDBWithWhere:[NSString stringWithFormat:@"type = %@",MsgBoxListConsultListType]];

            if (!modelPhar) {
                
                PharMsgModel *modelNoti = [PharMsgModel new];
                modelNoti.branchId = MsgBoxListConsultListType;
                modelNoti.type = MsgBoxListConsultListType;
                modelNoti.title = FreeConsultListTitle;
                
                modelNoti.content = modelCus.consultShowTitle;
                modelNoti.formatShowTime = modelCus.consultFormatShowTime;
                modelNoti.latestTime = modelCus.consultLatestTime;
                
                modelNoti.unreadCounts = [NSString stringWithFormat:@"%d",intNewCount];
                [PharMsgModel updateObjToDB:modelNoti WithKey:modelNoti.branchId];
            } else {
                modelPhar.unreadCounts = [NSString stringWithFormat:@"%d",intNewCount];
                // 判断最新的回复的会话是否是在消息盒子列表中最新的
                if ([modelCus.consultLatestTime longLongValue] > [modelPhar.latestTime longLongValue]) {
                    modelPhar.formatShowTime = modelCus.consultFormatShowTime;
                    modelPhar.latestTime = modelCus.consultLatestTime;
                    modelPhar.content = modelCus.consultShowTitle;
                }
                
                [PharMsgModel updateObjToDB:modelPhar WithKey:modelPhar.branchId];
            }
            
//            QWUnreadCountModel *modelUnread = [self getUnreadModel];
//            modelUnread.count_NotifyListUnread = [NSString stringWithFormat:@"%d",intNewCount];
//            [QWUnreadCountModel updateObjToDB:modelUnread WithKey:QWGLOBALMANAGER.configure.passPort];
//            [self updateRedPoint];
//            
//            //发消息过去
//            [self postNotif:NotiMessageUpdateMsgNotiList data:listModel object:self];
        }
    } failure:^(HttpException *e) {
        
    }];
}

/**
 *  轮询拉取圈子会话列表
 */
- (void)pullNewCircleSessions
{
//    if (QWGLOBALMANAGER.loginStatus == NO) {
//        return;
//    }
    
}

/**
 *  轮询拉取圈子消息列表
 */
- (void)pullNewCircleMsg{
    if (QWGLOBALMANAGER.loginStatus == NO) {
        return;
    }
    InfoCircleNewMsgListModelR *modelR = [InfoCircleNewMsgListModelR new];
    modelR.token = QWGLOBALMANAGER.configure.userToken;
    [[CircleMsgSyncModel sharedInstance] pullNewCircleMsgListWithParams:modelR Success:^(CircleMsgListModel *model) {
  
//  单例里面已经做了同步 // 应该判断数据的日期
//        [[CircleTeamMsgVoModel getUsingLKDBHelper] executeForTransaction:^BOOL(LKDBHelper *helper) {
//            BOOL suc = YES;
//            for (CircleTeamMsgVoModel *modelV in model.teamMsgList) {
//               suc =  [CircleTeamMsgVoModel updateObjToDB:modelV WithKey:modelV.id];
//                if (!suc) {
//                    break;
//                }
//            }
//            return suc;
//        }];
        if (model.teamMsgList.count) {
            for (CircleTeamMsgVoModel *item in model.teamMsgList) {
                if (!item.flagRead) {
                    if (item.msgClass.integerValue == 1) {
                        self.configure.expertCommentRed = YES;
                    } else if (item.msgClass.integerValue == 2) {
                        self.configure.expertFlowerRed = YES;
                    } else if (item.msgClass.integerValue == 99) {
                        self.configure.expertSystemInfoRed = YES;
                    }
                }
            }
            if (self.configure.expertCommentRed || self.configure.expertFlowerRed || self.configure.expertSystemInfoRed) {
                [self saveAppConfigure];
                [self noticeUnreadByMsgBoxTypes:@[@(MsgBoxListMsgTypeCircle)] readFlag:NO];
            }
        }
        if (model.sessionMsglist.count) {
            BOOL hasUnread = NO;
            for (CircleChatPointModel *item in model.sessionMsglist) {
                if (!item.readFlag) {
                    hasUnread = YES;
                    break;
                }
            }
            if (hasUnread) {
                [self noticeUnreadByMsgBoxTypes:@[@(MsgBoxListMsgTypeExpertPTP)] readFlag:NO];
            }
        }
    } failure:^(HttpException *e) {
        DDLogVerbose(@"[%@ %s]:%d. poll circle msg error:%@", NSStringFromClass(self.class), __func__, __LINE__, e.Edescription);
    }];
}

//每10秒 同步一次服务器时间
- (void)checkCurrentSystemTime
{
    if([[QWUserDefault getNumberBy:SERVER_TIME] longLongValue] == 0 ) {
        [System checkTimeWithParams:nil success:^(CheckTimeModel *model) {
            if([model.apiStatus integerValue] == 0) {
                //计算差值,本地保留服务器与当前系统时间的差
                NSTimeInterval current = [[NSDate date] timeIntervalSince1970] * 1000ll;
                long long offset = model.check_timestamp - current;
                [QWUserDefault setNumber:[NSNumber numberWithLongLong:offset] key:SERVER_TIME];
                if(offset != 0) {
                    [self releaseHeartBeatTimer];
                }
            }
        } failure:NULL];
    }
}

- (void)checkTokenVaild
{
    if(!StrIsEmpty(self.configure.userToken)) {
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[@"token"] = self.configure.userToken;
        HttpClientMgr.progressEnabled=NO;
        [Mbr tokenValidWithParams:setting success:^(BaseAPIModel *obj) {
            if([obj.apiStatus integerValue] != 0) {
                [SVProgressHUD showErrorWithStatus:obj.apiMessage duration:0.8f];
                [QWUserDefault setBool:NO key:APP_LOGIN_STATUS];
                [QWGLOBALMANAGER unOauth];
                [QWUserDefault setString:@"" key:APP_PASSWORD_KEY];
                
                [self clearAccountInformation];
                [QWGLOBALMANAGER postNotif:NotifQuitOut data:nil object:nil];
            }else{
                if(!self.loginStatus) {
                    self.loginStatus = YES;
                    [QWGLOBALMANAGER loadAppConfigure];
                    [self loginSucessCallBack];
                    
                    [QWGLOBALMANAGER postNotif:NotifLoginSuccess data:nil object:self];
                    [QWGLOBALMANAGER saveOperateLog:@"2"];
                }else{
                    [QWGLOBALMANAGER saveOperateLog:@"2"];
                }
            }
        } failure:^(HttpException *e) {

        }];
    }
}


- (void)syncInfoChannelList:(BOOL)needUpdateList
{
    NSArray *arrSort = [ResortItem getArrayFromDBWithWhere:@"dataType = '1'"];
    if (arrSort.count > 0) {
        ResortItem *firstItem = arrSort[0];
        if ([firstItem.updatedStatus isEqualToString:@"N"]) {
            InfoMsgUpdateUserChannelModelR *modelR = [InfoMsgUpdateUserChannelModelR new];
            modelR.token = QWGLOBALMANAGER.configure.userToken == nil ? @"" : QWGLOBALMANAGER.configure.userToken;
            modelR.device = DEVICE_ID;
            ResortItem *itemOne = arrSort[0];
            NSMutableString *str = [[NSMutableString alloc] initWithString:itemOne.strID];
            for (int i = 1; i < arrSort.count; i++) {
                ResortItem *itemOne = arrSort[i];
                [str appendString:[NSString stringWithFormat:@"%@%@",SeparateStr,itemOne.strID]];
            }
            modelR.list = str;
            [InfoMsg updateUserMsgList:modelR success:^(MsgChannelListVO *model) {
                if (model.list.count > 0) {
                    [self saveInfoChannelList:model needUpdateList:needUpdateList];
                } else {
                    [QWGLOBALMANAGER postNotif:NotifInfoListUpdated data:nil object:nil];
                }
            } failure:^(HttpException *e) {
                [QWGLOBALMANAGER postNotif:NotifInfoListUpdated data:nil object:nil];
            }];
        } else {
            if (needUpdateList) {
                [QWGLOBALMANAGER postNotif:NotifInfoListUpdated data:nil object:nil];
            }
        }
    }
}

- (void)updateInfoChannelList:(NSMutableArray *)arrAdd
{
    InfoMsgUpdateUserChannelModelR *modelR = [InfoMsgUpdateUserChannelModelR new];
    modelR.token = QWGLOBALMANAGER.configure.userToken == nil ? @"" : QWGLOBALMANAGER.configure.userToken;
    modelR.device = DEVICE_ID;
    ResortItem *itemOne = arrAdd[0];
    NSMutableString *str = [[NSMutableString alloc] initWithString:itemOne.strID];
    for (int i = 1; i < arrAdd.count; i++) {
        ResortItem *itemOne = arrAdd[i];
        [str appendString:[NSString stringWithFormat:@"%@%@",SeparateStr,itemOne.strID]];
    }
    modelR.list = str;
    // 更新用户频道列表
    [InfoMsg updateUserMsgList:modelR success:^(MsgChannelListVO *model) {
        if (model.list.count >0) {
            [self saveInfoChannelList:model needUpdateList:NO];
        }
    } failure:^(HttpException *e) {
        
    }];
}

- (void)saveInfoChannelList:(MsgChannelListVO *)model needUpdateList:(BOOL)needUpdate
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableArray *arrTop = [@[] mutableCopy];
        NSMutableArray *arrCenter = [@[] mutableCopy];
        NSMutableArray *arrBottom = [@[] mutableCopy];
        for (int i = 0; i < model.list.count; i++) {
            MsgChannelVO *modelVO = model.list[i];
            ResortItem *item = [ResortItem new];
            item.strTitle = modelVO.channelName;
            item.strID = modelVO.channelID;
            if ([modelVO.type intValue] == 1) {
                item.olocation = ocenter;
            } else {
                item.olocation = obottom;
            }
            if ([item.strTitle isEqualToString:@"热点"]) {
                item.olocation = otop;
            }
            item.updatedStatus = @"Y";
            item.dataType = @"1";
            [arrTop addObject:item];
        }
        for ( int i = 0; i < model.listNoAdd.count; i++) {
            MsgChannelVO *modelVO = model.listNoAdd[i];
            ResortItem *item = [ResortItem new];
            item.strTitle = modelVO.channelName;
            item.strID = modelVO.channelID;
            if ([modelVO.type intValue] == 1) {
                item.olocation = ocenter;
                item.dataType = @"2";
                [arrCenter addObject:item];
            } else {
                item.olocation = obottom;
                item.dataType = @"3";
                [arrBottom addObject:item];
            }
        }
        [ResortItem deleteAllObjFromDB];
        [ResortItem saveObjToDBWithArray:arrTop];
        [ResortItem saveObjToDBWithArray:arrCenter];
        [ResortItem saveObjToDBWithArray:arrBottom];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (needUpdate) {
                [QWGLOBALMANAGER postNotif:NotifInfoListUpdated data:nil object:nil];
            } else {
            }
        });
    });
}

- (void)setBadgeNumStatus:(BOOL)isShow
{
//    [self.tabBar showBadgePoint:isShow itemTag:Enum_TabBar_Items_HealthInformation];
}

#pragma mark -
#pragma mark  私有数据库名称
- (NSString*)getPrivateDBName
{
    NSString* ret = @"";
    if (self.configure) {
        ret = self.configure.userName;
    }
    
    return ret;
}


#pragma mark -
#pragma mark  全局配置信息
- (void)loadAppConfigure
{
    self.configure = [UserInfoModel getFromNsuserDefault:USER_PERSON_INFO];
    if (!self.configure) {
        self.configure = [[UserInfoModel alloc] init];
    }
}
- (void)loadBranchConfigure
{
    self.tdModel=[TdVo getFromNsuserDefault:BRANCH_INFO];
    if (!self.tdModel) {
        self.tdModel = [[TdVo alloc] init];
    }
}

- (void)saveBranchConfigure
{
    [self.tdModel saveToNsuserDefault:BRANCH_INFO];
}

//根据当前登陆的账号,保存配置信息
- (void)saveAppConfigure
{
    [self.configure saveToNsuserDefault:USER_PERSON_INFO];
}

#pragma mark 发出全局通知
- (NSDictionary *)postNotif:(Enum_Notification_Type)type data:(id)data object:(id)obj{
    return [super postNotif:type data:data object:obj];
}

/**
 *  查询圈子消息的红点
 *
 *  @return
 */
- (BOOL)queryCircleMsgRedPoint
{
    BOOL showRedPoint = NO;
    if (self.configure.expertCommentRed) {
        showRedPoint = YES;
    } else if (self.configure.expertFlowerRed) {
        showRedPoint = YES;
    } else if (self.configure.expertSystemInfoRed) {
        showRedPoint = YES;
    } else if (self.configure.expertPrivateMsgRed) {
        showRedPoint = YES;
    }
    return showRedPoint;
}

- (void)updateCircleMsgRedPoint
{
    if ([CircleChatPointModel rowCountWithWhere:@"readFlag = 0"] == 0) {
        self.configure.expertPrivateMsgRed = NO;
    } else {
        self.configure.expertPrivateMsgRed = YES;
    }
    [self saveAppConfigure];
    [QWGLOBALMANAGER postNotif:NotifCircleMsgRedPoint data:nil object:nil];
}

#pragma mark - 友盟
- (void)umengInit{
//    [MobClick startWithAppkey:UMENG_KEY];
//    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    [MobClick setAppVersion:version];
}

#pragma mark  社会分享
-(void)initsocailShare:(NSString *)urlString
{
    //设置友盟appkey  5355fc9256240b418f014450
    [UMSocialData setAppKey:UMENG_KEY];//ok,已是全维应用
    
    //设置手机腾讯AppKey   QQ2826456758
    [UMSocialQQHandler setQQWithAppId:@"1101843707"
                               appKey:@"CcKMij0UJErBOhbp"
                                  url:urlString];
    //微信
    [UMSocialWechatHandler setWXAppId:@"wxa2c68380a4a2f5d7"
                            appSecret:@"373c55b1c94339d803d5f7e6ed4876d6"
                                  url:urlString];
    
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:@"1357664090"
                                              secret:@"de7bacbf2fd05a3f4ba4d02972e78ba2"
                                         RedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    
    
}

- (NSString *)removeSpace:(NSString *)string
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


#pragma mark 计算文字大小
- (CGSize)getTextSizeWithContent:(NSString*)text WithUIFont:(UIFont*)font WithWidth:(CGFloat)width
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 5000)];
    label.font = font;
    label.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    label.numberOfLines = 0;
    label.text = text;
    [label sizeToFit];
    return label.frame.size;
}

#pragma mark 特殊字符的替换
- (NSString *)replaceSpecialStringWith:(NSString *)string
{
    if(!string)
        return @"";
    string = [string stringByReplacingOccurrencesOfString:@"    &nbsp;&nbsp;&nbsp;&nbsp;" withString:@"    "];
    string = [string stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"<p/>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt:" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt:" withString:@">"];
    return string;
}

#pragma mark 符号字符的替换，用于搜索关键词净化
- (NSString *)replaceSymbolStringWith:(NSString *)string
{
    if(!string || string.length == 0)
        return @"";

    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@$%^&*()_+'\".,?/'-_!！();: "];
    NSArray *arrSet = @[@"@",@"／",@"：",@"；",@"（",@"）",@"¥",@"「",@"」",@"＂",@"、",@"[",@"]",@"{",@"}",@"#",@"%",@"-",@"*",@"+",@"=",@"_",@"\\",@"|",@"~",@"＜",@"＞",@"$",@"€",@"^",@"•",@"'",@"@",@"$",@"%",@"^",@"&",@"*",@"(",@")",@"“",@"”",@"_",@"-",@"。",@".",@",",@"，",@"?",@"？",@"/",@"'",@"!",@"！",@";",@"；",@":",@"：",@" ",@"\""];
    
    for(NSString *str in arrSet){
        string = [string stringByReplacingOccurrencesOfString:str withString:@""];
    }

    return string;
}

-(int)compareDate:(NSString*)date01 withDate:(NSString*)date02{
    int ci;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dt1 = [[NSDate alloc] init];
    NSDate *dt2 = [[NSDate alloc] init];
    dt1 = [df dateFromString:date01];
    dt2 = [df dateFromString:date02];
    NSComparisonResult result = [dt1 compare:dt2];
    switch (result)
    {
            //date02比date01大
        case NSOrderedAscending: ci=1; break;
            //date02比date01小
        case NSOrderedDescending: ci=-1; break;
            //date02=date01
        case NSOrderedSame: ci=0; break;
        default: DDLogVerbose(@"erorr dates %@, %@", dt2, dt1); break;
    }
    return ci;
}

- (void)clearOldCache
{
    NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for(NSString *userDir in [fileManager contentsOfDirectoryAtPath:homePath error:nil])
    {
        [fileManager removeItemAtPath:[homePath stringByAppendingFormat:@"/%@",userDir] error:nil];
    }
    [QWUserDefault setBool:NO key:APP_LOGIN_STATUS];
}

- (NSString *)updateDisplayTime:(NSDate *)date
{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:date];
    NSDateComponents *todayComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:today];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm "];
    NSString *staicString = [dateFormatter stringFromDate:date];
    NSString *dynamicString = nil;
    if (dateComponents.year == todayComponents.year && dateComponents.month == todayComponents.month && dateComponents.day == todayComponents.day)
    {
        dynamicString = @"";
    }else if ((dateComponents.year == todayComponents.year) && (dateComponents.month == todayComponents.month) && (dateComponents.day == todayComponents.day - 1)) {
        dynamicString = NSLocalizedString(@"昨天", nil);
    }else if ((dateComponents.year == todayComponents.year) && (dateComponents.weekOfYear == todayComponents.weekOfYear)) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EEEE";
        dynamicString = [dateFormatter stringFromDate:date];
        dynamicString = NSLocalizedString(dynamicString, nil);
    }else if (dateComponents.year == todayComponents.year){
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM-dd";
        dynamicString = [dateFormatter stringFromDate:date];
    }else{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        dynamicString = [dateFormatter stringFromDate:date];
    }
    return [NSString stringWithFormat:@" %@ %@",dynamicString,staicString];
}

// TODO:小红点
- (NSInteger)updateRedPoint
{
    if (!self.loginStatus) {
        return -1;
    }
//    BOOL bool_shouldShowRed = flag.healthMsgUnread || flag.orderMsgUnread || flag.circleMsgUnread || flag.noticeMsgUnread || flag.shopConsultUnread || flag.expertPTPMsgUnread;
    NSInteger intTotalCount = [self getAllUnreadCount];
    [self updateUnreadCountBadge:intTotalCount];
    
    NSInteger intNotiShow = intTotalCount > 0 ? intTotalCount : -1;
    [QWGLOBALMANAGER postNotif:NotiWhetherHaveNewMessage data:[NSString stringWithFormat:@"%ld",intNotiShow] object:nil];
    return intNotiShow;
}

- (NSInteger)getAllUnreadCount
{
    QWUnreadFlagModel *flag = [self getUnreadModel];
    NSInteger unreadSum = (NSInteger)flag.healthMsgUnread + (NSInteger)flag.orderMsgUnread + (NSInteger)flag.circleMsgUnread + (NSInteger)flag.noticeMsgUnread;
    if (flag.shopConsultUnread) {
        NSArray *modelArr = [PharMsgModel getArrayFromDBWithWhere:@"type = 3"];
        NSInteger scSum = 0;
        for (PharMsgModel *model in modelArr) {
            scSum += (model.unreadCounts.integerValue > 0 ? 1 : 0);
        }
        unreadSum += scSum;
    }
    if (flag.expertPTPMsgUnread) {
        NSArray *modelArr = [CircleChatPointModel getArrayFromDBWithWhere:nil];
        NSInteger ecSum = 0;
        for (CircleChatPointModel *model in modelArr) {
            ecSum += (NSInteger)(!model.readFlag);
        }
        unreadSum += ecSum;
    }
    return unreadSum;
}

//刷新界面
- (void)updateUnreadCountBadge:(NSInteger)totalCount
{
    QWGLOBALMANAGER.unReadCount = totalCount;
    if(QWGLOBALMANAGER.unReadCount > 99) {
        QWGLOBALMANAGER.unReadCount = 99;
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = QWGLOBALMANAGER.unReadCount;
    [QWGLOBALMANAGER postNotif:NotiMessageBadgeNum data:[NSString stringWithFormat:@"%ld",QWGLOBALMANAGER.unReadCount] object:nil];
}

//- (void)updateUnreadCountBadge:(NSInteger)pullCount
//{
//    NSUInteger unreadCount = [OfficialMessages getcountFromDBWithWhere:@"issend = 0"];
//    pullCount+=unreadCount;
//    if(pullCount > QWGLOBALMANAGER.unReadCount) {
//        [XHAudioPlayerHelper playMessageReceivedSound];
//    }
//    QWGLOBALMANAGER.unReadCount = pullCount;
//    DDLogVerbose(@"the application int number is %d",[UIApplication sharedApplication].applicationIconBadgeNumber);
//    
//    
//    if(QWGLOBALMANAGER.unReadCount > 99) {
//        QWGLOBALMANAGER.unReadCount = 99;
//        [UIApplication sharedApplication].applicationIconBadgeNumber = 99;
//        [QWGLOBALMANAGER.tabBar showBadgeNum:QWGLOBALMANAGER.unReadCount itemTag:0];
//    }else{
//        [UIApplication sharedApplication].applicationIconBadgeNumber = QWGLOBALMANAGER.unReadCount;
//        [QWGLOBALMANAGER.tabBar showBadgeNum:QWGLOBALMANAGER.unReadCount itemTag:0];
//    }
//    NewHomePageViewController *newHomePageViewController = ((UINavigationController *)QWGLOBALMANAGER.tabBar.viewControllers[0]).viewControllers[0];
//    [newHomePageViewController.badgeView setValueOnly:QWGLOBALMANAGER.unReadCount];
////    NSUInteger unread = [OfficialMessages getcountFromDBWithWhere:@"issend = 0"];
////
////    if (unread >0) {
////        QWGLOBALMANAGER.unReadCount += unread;
////    }
////    
////    //NSUInteger unreadMessage = [HistoryMessages getcountFromDBWithWhere:@"unreadCounts > 0"];
////    //QWGLOBALMANAGER.unReadCount += unreadMessage;
////    
////    NSArray* array = [HistoryMessages getArrayFromDBWithWhere:@"unreadCounts > 0"];
////    NSUInteger count = 0;
////    for(int i=0;i<array.count;i++)
////    {
////        HistoryMessages* msg = [array objectAtIndex:i];
////        count += [msg.unreadCounts integerValue];
////    }
////    QWGLOBALMANAGER.unReadCount += count;
////    
////    //更新ui
////
//    DDLogVerbose(@"the unread count is %ld",(long)QWGLOBALMANAGER.unReadCount);
//}

- (void)startRgisterVerifyCode:(NSString *)phoneNum
{
    if(self.getVerifyTimer)
        return;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"mobile"] = phoneNum;
    param[@"type"] = @"1";
    [Mbr sendVerifyCodeWithParams:param success:^(id resultObj){
        
        msgModel *msg = (msgModel *)resultObj;
        if ([msg.apiStatus intValue] == 0){
            _getVerifyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDownRegisterTimer:) userInfo:[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:60] forKey:@"countDown"] repeats:YES];
            [SVProgressHUD showSuccessWithStatus:@"获取验证码成功" duration:DURATION_LONG];
        }
        else{
            [SVProgressHUD showErrorWithStatus:msg.apiMessage duration:DURATION_LONG];
        }
    }failure:^(HttpException *e){
        [SVProgressHUD showErrorWithStatus:e.Edescription duration:DURATION_SHORT];
    }];
}

- (void)startRgisterVerifyCode:(NSString *)phoneNum imageCode:(NSString*)imageCode
{
    if(self.getVerifyTimer)
        return;
    NSDictionary *param = @{@"mobile":phoneNum,
                            @"type":@"1",
                            @"imageCode":imageCode};

    [Mbr sendCodeByImageVerifyWithParams:param success:^(id resultObj){
        
        msgModel *msg = (msgModel *)resultObj;
        if ([msg.apiStatus intValue] == 0){
            _getVerifyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDownRegisterTimer:) userInfo:[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:60] forKey:@"countDown"] repeats:YES];
            [SVProgressHUD showSuccessWithStatus:@"获取验证码成功" duration:DURATION_LONG];
            [QWGLOBALMANAGER postNotif:NotiGetRegisterVerifyCodeSucess data:nil object:nil];
        }
        else{
            [QWGLOBALMANAGER postNotif:NotiGetRegisterVerifyCodeFailed data:nil object:nil];
            [SVProgressHUD showErrorWithStatus:msg.apiMessage duration:DURATION_LONG];
        }
    }failure:^(HttpException *e){
        [SVProgressHUD showErrorWithStatus:e.Edescription duration:DURATION_SHORT];
    }];
}

- (void)countDownRegisterTimer:(NSTimer *)timer
{
    NSMutableDictionary *userInfo = timer.userInfo;
    NSInteger countDonw = [userInfo[@"countDown"] integerValue];
    if(countDonw == 0) {
        [_getVerifyTimer invalidate];
        _getVerifyTimer = nil;
    }else{
        countDonw--;
        userInfo[@"countDown"] = [NSNumber numberWithInteger:countDonw];
    }
    [self postNotif:NotiCountDonwRegister data:[NSNumber numberWithInteger:countDonw] object:nil];
}

- (void)stopCountDownRegisterTimer:(NSTimer *)timer
{
    NSMutableDictionary *userInfo = _getVerifyTimer.userInfo;
    userInfo[@"countDown"] = [NSNumber numberWithInteger:0];
    [_getVerifyTimer invalidate];
    _getVerifyTimer = nil;
}

- (void)startChangePhoneVerifyCode:(NSString *)phoneNum
{
    if(_getChangePhoneTimer)
        return;

    [QWGLOBALMANAGER statisticsEventId:@"x_jfrw_bdsjh_hqyzm" withLable:@"积分任务-修改手机号-获取验证码" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl)}]];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"mobile"] = phoneNum;
    if (QWGLOBALMANAGER.configure.isThirdLogin) {
        param[@"type"] = @"11";
    }
    else
        param[@"type"] = @"3";
    [Mbr sendVerifyCodeWithParams:param success:^(id resultObj){
        
        msgModel *msg = (msgModel *)resultObj;
        if ([msg.apiStatus intValue] == 0){
            [SVProgressHUD showSuccessWithStatus:@"获取验证码成功" duration:DURATION_LONG];
            _getChangePhoneTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDownChangePhoneTimer:) userInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:60], @"countDown", StrIsEmpty(phoneNum) ? @"" : phoneNum, @"phoneNumber", nil] repeats:YES];
        }
        else{
            [SVProgressHUD showErrorWithStatus:msg.apiMessage duration:DURATION_LONG];
        }
    }failure:^(HttpException *e){
        [SVProgressHUD showErrorWithStatus:e.Edescription duration:DURATION_SHORT];
    }];
}

- (void)countDownChangePhoneTimer:(NSTimer *)timer
{
    NSMutableDictionary *userInfo = timer.userInfo;
    NSInteger countDonw = [userInfo[@"countDown"] integerValue];
    if(countDonw == 0) {
        [_getChangePhoneTimer invalidate];
        _getChangePhoneTimer = nil;
    }else{
        countDonw--;
        userInfo[@"countDown"] = [NSNumber numberWithInteger:countDonw];
    }
    [self postNotif:NotiCountDonwChangePhone data:[NSNumber numberWithInteger:countDonw] object:nil];
}

- (void)startForgetPasswordVerifyCode:(NSString *)phoneNum
{
    if(_getForgetPasswordTimer)
        return;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"mobile"] = phoneNum;
    param[@"type"] = @"2";
    
    [Mbr sendVerifyCodeWithParams:param success:^(id resultObj){

        msgModel *msg = (msgModel *)resultObj;
        if ([msg.apiStatus intValue] == 0){
            [SVProgressHUD showSuccessWithStatus:@"获取验证码成功" duration:DURATION_LONG];
            _getForgetPasswordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDownForgetPasswordTimer:) userInfo:[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:60] forKey:@"countDown"] repeats:YES];
        }
        else{
            [SVProgressHUD showErrorWithStatus:msg.apiMessage duration:DURATION_LONG];
        }
        
    }failure:^(HttpException *e){
        [SVProgressHUD showErrorWithStatus:e.Edescription duration:DURATION_SHORT];
    }];
}

- (void)countDownForgetPasswordTimer:(NSTimer *)timer
{
    NSMutableDictionary *userInfo = timer.userInfo;
    NSInteger countDonw = [userInfo[@"countDown"] integerValue];
    if(countDonw == 0) {
        [_getForgetPasswordTimer invalidate];
        _getForgetPasswordTimer = nil;
    }else{
        countDonw--;
        userInfo[@"countDown"] = [NSNumber numberWithInteger:countDonw];
    }
    [self postNotif:NotiCountDonwForgetPassword data:[NSNumber numberWithInteger:countDonw] object:nil];
}

- (void)startValidCodeLoginVerifyCode:(NSString *)phoneNum
{
    if (_getValidCodeLoginTimer) {
        return;
    }
    
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8];
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"mobile"] = phoneNum;
    param[@"type"] = @"9";
    
    [Mbr sendVerifyCodeWithParams:param success:^(id resultObj){
        
        msgModel *msg = (msgModel *)resultObj;
        if ([msg.apiStatus intValue] == 0){
            [SVProgressHUD showSuccessWithStatus:@"获取验证码成功" duration:DURATION_LONG];
            _getValidCodeLoginTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDownValidCodeLoginTimer:) userInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:60], @"countDown", StrIsEmpty(phoneNum) ? @"" : phoneNum, @"phoneNumber", nil] repeats:YES];
        }
        else{
            [SVProgressHUD showErrorWithStatus:msg.apiMessage duration:DURATION_LONG];
        }
        
    }failure:^(HttpException *e){
        [SVProgressHUD showErrorWithStatus:e.Edescription duration:DURATION_SHORT];
    }];
}

- (void)startValidCodeLoginVerifyCode:(NSString *)phoneNum imageCode:(NSString*)imageCode
{
    if (_getValidCodeLoginTimer) {
        return;
    }
    
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8];
        return;
    }
    
    NSDictionary *param = @{@"mobile":phoneNum,
                            @"type":@"9",
                            @"imageCode":imageCode};
    
    [Mbr sendCodeByImageVerifyWithParams:param success:^(id resultObj){
        
        msgModel *msg = (msgModel *)resultObj;
        if ([msg.apiStatus intValue] == 0){
            [SVProgressHUD showSuccessWithStatus:@"获取验证码成功" duration:DURATION_LONG];
            _getValidCodeLoginTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDownValidCodeLoginTimer:) userInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:60], @"countDown", StrIsEmpty(phoneNum) ? @"" : phoneNum, @"phoneNumber", nil] repeats:YES];
            [QWGLOBALMANAGER postNotif:NotiGetMobileLoginVerifyCodeSucess data:nil object:nil];
        }
        else{
            [QWGLOBALMANAGER postNotif:NotiGetMobileLoginVerifyCodeFailed data:nil object:nil];
            [SVProgressHUD showErrorWithStatus:msg.apiMessage duration:DURATION_LONG];
        }
        
    }failure:^(HttpException *e){
        [SVProgressHUD showErrorWithStatus:e.Edescription duration:DURATION_SHORT];
    }];

}

- (void)countDownValidCodeLoginTimer:(NSTimer *)timer
{
    NSMutableDictionary *userInfo = timer.userInfo;
    NSInteger countDonw = [userInfo[@"countDown"] integerValue];
    if(countDonw == 0) {
        [_getValidCodeLoginTimer invalidate];
        _getValidCodeLoginTimer = nil;
    }else{
        countDonw--;
        userInfo[@"countDown"] = [NSNumber numberWithInteger:countDonw];
    }
    [self postNotif:NotiCountDonwValidCodeLogin data:[NSNumber numberWithInteger:countDonw] object:nil];
}

- (void)startVoiceValidCodeToLogin:(NSString *)phoneNum
{
    if (_getVoiceValidCodeLoginTimer) {
        return;
    }
    
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8];
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"mobile"] = phoneNum;
    param[@"type"] = @"9";
    
    [Mbr sendVoiceVerifyCodeWithParams:param success:^(id resultObj){
        BaseAPIModel* apiModel = resultObj;
        if ([apiModel.apiStatus intValue] == 0){
            [SVProgressHUD showSuccessWithStatus:@"获取验证码成功" duration:DURATION_LONG];
            _getVoiceValidCodeLoginTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDownVoiceValidCodeLoginTimer:) userInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:60], @"countDown", StrIsEmpty(phoneNum) ? @"" : phoneNum, @"phoneNumber", nil] repeats:YES];
        }
        else{
            [SVProgressHUD showErrorWithStatus:apiModel.apiMessage duration:DURATION_LONG];
        }
        
    }failure:^(HttpException *e){
        [SVProgressHUD showErrorWithStatus:e.Edescription duration:DURATION_SHORT];
    }];
}

- (void)countDownVoiceValidCodeLoginTimer:(NSTimer *)timer
{
    NSMutableDictionary *userInfo = timer.userInfo;
    NSInteger countDonw = [userInfo[@"countDown"] integerValue];
    if(countDonw == 0) {
        [_getVoiceValidCodeLoginTimer invalidate];
        _getVoiceValidCodeLoginTimer = nil;
    }else{
        countDonw--;
        userInfo[@"countDown"] = [NSNumber numberWithInteger:countDonw];
    }
    [self postNotif:NotiCountDonwValidVoiceCodeLogin data:[NSNumber numberWithInteger:countDonw] object:nil];
}

- (NSString *)updateFirstPageTimeDisplayer:(NSDate *)date{
    
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:date];
    NSDateComponents *todayComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:today];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm "];
    NSString *staicString = [dateFormatter stringFromDate:date];
    NSString *dynamicString = nil;
    if (dateComponents.year == todayComponents.year && dateComponents.month == todayComponents.month && dateComponents.day == todayComponents.day){
        dynamicString = @"";
    }else if ((dateComponents.year == todayComponents.year) && (dateComponents.month == todayComponents.month) ) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM-dd";
        dynamicString = [dateFormatter stringFromDate:date];
        return dynamicString;
    }else if (dateComponents.year == todayComponents.year){
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM-dd";
        dynamicString = [dateFormatter stringFromDate:date];
        return dynamicString;
    }else{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        dynamicString = [dateFormatter stringFromDate:date];
        return dynamicString;
    }
    return [NSString stringWithFormat:@" %@ %@",dynamicString,staicString];
}

#pragma mark -
#pragma mark ReachabilityDelegate  网络状态监控
-(void)networkDisconnectFrom:(NetworkStatus)netStatus
{
    QWGLOBALMANAGER.currentNetWork = NotReachable;
    //掉线
    if(QWGLOBALMANAGER.configure.userToken.length > 0) {
        _clearShoppingCartStepOne = YES;
    }
    [self postNotif:NotifNetworkDisconnect data:nil object:self];
}

- (void)networKCannotStartupWhenFinishLaunching
{
    QWGLOBALMANAGER.currentNetWork = NotReachable;
    if(QWGLOBALMANAGER.configure.userToken.length > 0) {
        _clearShoppingCartStepOne = YES;
    }
    [self postNotif:NotifNetworkDisconnectWhenStart data:nil object:self];
}

- (void)networkStartAtApplicationDidFinishLaunching:(NetworkStatus)netStatus
{
    QWGLOBALMANAGER.currentNetWork = netStatus;
}

- (void)networkRestartFrom:(NetworkStatus)oldStatus toStatus:(NetworkStatus)newStatus
{
    QWGLOBALMANAGER.currentNetWork = newStatus;
    if (QWGLOBALMANAGER.loginStatus && newStatus != kNotReachable)
    {
        
    }
    if(QWGLOBALMANAGER.configure.userToken.length > 0 && _clearShoppingCartStepOne) {
        _clearShoppingCartStepOne = NO;
        [self postNotif:NotifShoppingCartForcedClear data:nil object:nil];
    }
    [self postNotif:NotifNetworkReconnect data:nil object:self];
}

#pragma mark -
#pragma mark  清除账户信息 退出登录
- (void)clearAccountInformation
{
    //退出登录
    if(QWGLOBALMANAGER.configure.userToken == nil)
        return;
    QWGLOBALMANAGER.loginStatus = NO;
    [QWGLOBALMANAGER unOauth];
    HttpClientMgr.progressEnabled=NO;
    
    DDLogVerbose(@"===%@",self.configure.userToken);
    
//    [self updateUnreadCountBadge:0];
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = StrFromObj(QWGLOBALMANAGER.configure.userToken);
    setting[@"source"] = @"1";
    setting[@"pushStatus"] = @1;
    
    [System systemPushSetWithParams:setting success:^(id obj) {
        
    } failure:^(HttpException *e) {
        
    }];
    
    [Mbr logoutWithParams:@{@"token":self.configure.userToken}
                  success:^(id obj){
                      
                 }
                 failure:^(HttpException *e){
                     
                 }];
    
    //通知其他地方退出登录
    [self postNotif:NotifQuitOut data:nil object:self];
//    [self showDiseaseBudge:NO];
//    self.hasNewDisease = NO;
    
    [self releaseMessageTimer];

    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    QWGLOBALMANAGER.unReadCount = 0;
    
    
    UINavigationController *navgationController = _tabBar.viewControllers[0];
    navgationController.tabBarItem.badgeValue = nil;
    [navgationController popToRootViewControllerAnimated:YES];
    navgationController = _tabBar.viewControllers[1];
    [navgationController popToRootViewControllerAnimated:YES];
    navgationController = _tabBar.viewControllers[2];
    [navgationController popToRootViewControllerAnimated:YES];
    navgationController = _tabBar.viewControllers[3];
    [navgationController popToRootViewControllerAnimated:YES];
 
    self.configure.userToken = nil;
    self.configure.passWord = nil;
    self.configure.expertFlowerRed = NO;
    self.configure.expertCommentRed = NO;
    self.configure.expertPrivateMsgRed = NO;
    self.configure.expertSystemInfoRed = NO;
    
    [self saveAppConfigure];
    
}


- (void)checkLogEnable
{
    if(!self.loginStatus) {
        return;
    }
    SystemModelR *modelR = [SystemModelR new];
    modelR.token = self.configure.userToken;
    [System systemAppLogFlagWithParams:modelR success:^(AppLogFlagModel *model) {
        self.DebugLogEnable = model.flag;
        if (self.DebugLogEnable) {
            [DDLog addLogger:QWGLOBALMANAGER.fileLogger];
            
        }else{
            [DDLog removeLogger:QWGLOBALMANAGER.fileLogger];
        }
    } failure:NULL];
}

- (void)upLoadLogFile
{
    if(!self.loginStatus) {
        return;
    }
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/Log/"]];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *filesPath = [manager contentsOfDirectoryAtPath:path error:nil];
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *filePathArray = [NSMutableArray array];
    for(NSString *filePath in filesPath)
    {
        NSData *file = [NSData dataWithContentsOfFile:[path stringByAppendingFormat:@"/%@",filePath]];
        [array addObject:file];
        [filePathArray addObject:[path stringByAppendingFormat:@"/%@",filePath]];
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = QWGLOBALMANAGER.configure.userToken;
    params[@"deviceType"] = @"2";
    [HttpClientMgr upLogFile:array filePaths:filePathArray params:params withUrl:AppUploadLog success:^(NSString *path) {
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:path error:nil];
    } failure:NULL uploadProgressBlock:NULL];
}

- (void)closePushPull
{
    
}

- (void)openPushPull
{

}

#pragma mark - 
#pragma mark 统计用户行为
- (void)saveOperateLog:(NSString *)type
{
    OperateModelR *modelR = [OperateModelR new];
    modelR.channel = @"APP STORE";
    modelR.type = type;
    modelR.deviceType = @"2";
    modelR.deviceCode = DEVICE_ID;
    NSString *strPhone = [QWUserDefault getStringBy:APP_USERNAME_KEY];
    if (strPhone == nil) {
        strPhone = @"";
    }
    modelR.mobile = strPhone;
    [[QWGlobalManager sharedInstance] readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        if(mapInfoModel == nil){
            modelR.city = @"";
        }else{
            modelR.city = mapInfoModel.city;
        }
    }];
    
    if (QWGLOBALMANAGER.configure.userToken == nil) {
        modelR.token = @"";
    } else {
        modelR.token = QWGLOBALMANAGER.configure.userToken;
    }
    modelR.userType = 1;
    [OperateLog saveOperateLog:modelR success:^(BaseModel *responModel) {
        
    } failure:^(HttpException *e) {
        
    }];
}

#pragma mark -
#pragma mark  版本检查

- (void)applicationDidBecomeActive
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if([[userDefault objectForKey:@"showGuide"] boolValue]){
        if (self.isForceUpdating) {
            if (self.currentNetWork == NotReachable) {
                Version * vmodel = [Version getFromNsuserDefault:@"Version"];
                if (vmodel != nil) {
                    [self showForceUpdateAlert:vmodel];
                } else {
                    [self checkVersion];
                }
            } else {
                
                [self checkVersion];
            }
            
        } else {
            [self checkNeedUpdate];
        }
    }
    [self checkLogEnable];
    
    if (QWGLOBALMANAGER.loginStatus) {
        GetAllSessionModelR *modelSR = [GetAllSessionModelR new];
        modelSR.token = QWGLOBALMANAGER.configure.userToken;
        modelSR.point = @"0";
        modelSR.view = @"10000";
        modelSR.viewType = @"-1";
        
        if ((QWGLOBALMANAGER.strConsultID.length > 0)||(QWGLOBALMANAGER.strPTPSessionID.length > 0)||(QWGLOBALMANAGER.strPrivateCircleMsgID.length > 0)) {
            
        } else {
            MsgBoxListModelR *modelR = [MsgBoxListModelR new];
            modelR.token = QWGLOBALMANAGER.configure.userToken;
            [Consult getMsgBoxIndexListWithParam:modelR success:^(MsgBoxListModel *responModel) {
                [MsgBoxListItemModel syncDBWithObjArray:responModel.notices];
                [self updateUnreadFlagWithIndex:responModel.notices];
            } failure:^(HttpException *e) {
            }];
        }

    }
    [self createCircleMessageTimer];
    [self createMessageTimer];
    [self createMessageTimer2];
    [self checkTokenVaild];
    
    AppDelegate *apppp = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (apppp.isLaunchByNotification) {
        apppp.isLaunchByNotification = NO;
    }else{
        [self pullCircleMessage];
    }
    
    [self postNotif:NotiRestartTimer data:nil object:nil];
    
}

- (void)updateUnreadFlagWithIndex:(NSArray *)modelArr
{
    QWUnreadFlagModel *model = [QWUnreadFlagModel new];
    model.passport = QWGLOBALMANAGER.configure.passPort;
    for (MsgBoxListItemModel *item in modelArr) {
        MsgBoxListMsgType type = item.type.integerValue;
        BOOL unread = item.unread.boolValue;
        if (type == MsgBoxListMsgTypeNotice) {
            model.noticeMsgUnread = unread;
        } else if (type == MsgBoxListMsgTypeOrder) {
            model.orderMsgUnread = unread;
        } else if (type == MsgBoxListMsgTypeCredit) {
            model.creditUnread = unread;
        } else if (type == MsgBoxListMsgTypeHealth) {
            model.healthMsgUnread = unread;
        } else if (type == MsgBoxListMsgTypeCircle) {
            model.circleMsgUnread = unread;
        } else if (type == MsgBoxListMsgTypeShopConsult) {
            model.shopConsultUnread = NO || unread;
        } else if (type == MsgBoxListMsgTypeExpertPTP) {
            model.expertPTPMsgUnread = NO || unread;
        }
    }
    [model updateToDB];
    [QWGLOBALMANAGER updateRedPoint];
}

- (BOOL)checkSanpUpAlive
{
    if(self.tabBar.selectedIndex == 0 ) {
        UIViewController *controller = [((UINavigationController *)self.tabBar.viewControllers[0]).viewControllers lastObject];
        if([controller isKindOfClass:[PurchaseViewController class]]) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - 热门搜索Request

- (void)loadHotWord
{
    KeywordModelR *modelR = [KeywordModelR new];
    
    MapInfoModel *mapInfoModel = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
    if(mapInfoModel)
    {

        if(!StrIsEmpty(mapInfoModel.branchCityName))
        {
            modelR.city = mapInfoModel.branchCityName;
//            modelR.province = mapInfoModel.province;
        }
        else
        {
            modelR.city = @"苏州市";
            modelR.province = @"江苏省";
        }
    }
    else
    {
        modelR.city = @"苏州市";
        modelR.province = @"江苏省";
    }
    
    [Search searchHotKeyword:modelR success:^(hotKeywordList *obj) {
        
        self.hotWord = (hotKeywordList *)obj;
        [self postNotif:NOtifHotKeyChange data:nil object:nil];
    } failure:^(HttpException *e) {
        //[SVProgressHUD showErrorWithStatus:e.Edescription duration:0.5f];
    }];
    
}



- (void)applicationDidEnterBackground
{
    [self releaseMessageTimer];
    [self postNotif:NotiReleaseTimer data:nil object:nil];
    //MARK: - need modify
//    [self releaseMessageTimer];
}

//检查版本更新
- (void)checkVersion
{
    if (self.boolLoadFromFirstIn) {
        self.boolLoadFromFirstIn = NO;
        return;
    }
    // need update
    self.boolLoadFromFirstIn = YES;
    HttpClientMgr.progressEnabled=NO;
    [VersionUpdate checkVersion:APP_VERSION
                        success:^(Version * model){
                            self.boolLoadFromFirstIn = NO;
                            installUrl = model.downloadUrl;
                            NSInteger intCurVersion = [self getIntValueFromVersionStr:APP_VERSION];
                            intCurVersion = intCurVersion / 10;
                            NSInteger intSysVersion = [self getIntValueFromVersionStr:model.version];
//                            intSysVersion = intSysVersion * 10;
                            NSInteger intLastSysVersion = [self getIntValueFromVersionStr:[[NSUserDefaults standardUserDefaults] objectForKey:APP_LAST_SYSTEM_VERSION]];
                            [[NSUserDefaults standardUserDefaults] setObject:model.version forKey:APP_LAST_SYSTEM_VERSION];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            if ([model.compel integerValue] == 1) {
                                // force update
                                self.isForceUpdating = YES;
                                [self showForceUpdateAlert:model];
                                [model saveToNsuserDefault:@"Version"];
                            } else {
                                // normal update
                                // add here
                                self.isForceUpdating = NO;
//                                if ((intLastSysVersion < intSysVersion)&&intLastSysVersion!=0)
//                                {
//                                    [self showNormalUpdateAlert:model];
//                                }
//                                else
//                                {
                                    if ([[[NSUserDefaults standardUserDefaults] objectForKey:APP_UPDATE_AFTER_THREE_DAYS] boolValue])
                                    {

                                    }
                                    else
                                    {
                                        [self showNormalUpdateAlert:model];
                                    }
//                                }
                            }
                        }
                        failure:^(HttpException *e){
                            DDLogVerbose(@"fail");
                        }];
}

- (void)checkNeedUpdate
{
    lastTimeStamp = (double)[[NSDate date] timeIntervalSince1970];//[dicReturn[@"respTime"] doubleValue];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:APP_UPDATE_AFTER_THREE_DAYS] boolValue]) {
        // 3天后提醒
        NSTimeInterval intevalLast = [[[NSUserDefaults standardUserDefaults] objectForKey:APP_LAST_TIMESTAMP] doubleValue];//
        if (lastTimeStamp - intevalLast >= 3*24*60*60) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:APP_UPDATE_AFTER_THREE_DAYS];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self checkVersion];
        }
        return ;
    } else {
        [self checkVersion];
    }
}

- (void)showForceUpdateAlert:(Version *)model
{
    if (!self.isShowAlert) {
        NSString *strAlertMessage = [NSString stringWithFormat:@"版本号: %@    \n%@",model.version, model.note];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"检测到新版本" message:strAlertMessage delegate:self cancelButtonTitle:@"暂不升级" otherButtonTitles:@"立即更新", nil];
        alertView.tag = 10000;
    
        [alertView show];
        [self postNotif:NOtifAppversionNew data:nil object:nil];
        self.isShowAlert = YES;
    }
    
}

- (void)showNormalUpdateAlert:(Version *)model
{
    if (!self.isShowAlert) {
    //    NSString *strAlertMessage = [NSString stringWithFormat:@"版本号: %@    大小: %@",dicUpdate[@"versionName"], dicUpdate[@"size"]];
        NSString *strAlertMessage = [NSString stringWithFormat:@"版本号: %@    ",model.version];
    
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发现新版本" message:strAlertMessage delegate:self cancelButtonTitle:@"暂不升级" otherButtonTitles:@"立即更新", nil];
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"customAlertView"
                                                      owner:self
                                                    options:nil];
    
        myAlertView = [ nibViews objectAtIndex: 0];
    
        myAlertView.tvViewMessage.text = model.note;
        //check if os version is 7 or above
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            [alertView setValue:myAlertView forKey:@"accessoryView"];
        }else{
            [alertView addSubview:myAlertView];
        }
        alertView.tag = 10001;
        [alertView show];
        [self postNotif:NOtifAppversionNew data:nil object:nil];
        self.isShowAlert = YES;
    }
    
}

- (void)getCramePrivate{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"无法使用相机"message:kWarning41 delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}


#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10000) {
        self.isShowAlert = NO;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:APP_UPDATE_AFTER_THREE_DAYS];
        NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (buttonIndex == 0) {
            
            [QWGLOBALMANAGER statisticsEventId:@"x_qzsj_bsj" withLable:@"强制升级" withParams:tdParams];
            exit(0);
        } else {
            [QWGLOBALMANAGER statisticsEventId:@"x_qzsj_sj" withLable:@"强制升级" withParams:tdParams];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:installUrl]];
        }
    } else if (alertView.tag == 10001) {
        self.isShowAlert = NO;
        if (buttonIndex == 0) {
            if (myAlertView.isClick) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:APP_UPDATE_AFTER_THREE_DAYS];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:(double)[[NSDate date] timeIntervalSince1970]] forKey:APP_LAST_TIMESTAMP];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:APP_UPDATE_AFTER_THREE_DAYS];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:APP_UPDATE_AFTER_THREE_DAYS];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:installUrl]];
        }
    }
}

- (NSInteger)getIntValueFromVersionStr:(NSString *)strVersion
{
    NSArray *arrVer = [strVersion componentsSeparatedByString:@"."];
    NSString *strVer = [arrVer componentsJoinedByString:@""];
    NSInteger intVer = [strVer integerValue];
    return intVer;
}

- (NSString *)checkStr:(id)obj
{
    if (([obj isKindOfClass:[NSString class]])&&[(NSString *)obj length]>0) {
        return (NSString *)obj;
    } else {
        return @"";
    }
}

- (void)showSplash
{
    if (![QWUserDefault getBoolBy:ONCE_LOADING]) {
        //显示引导页
        if (IS_IPHONE_4_OR_LESS){
            showAppGuide(@[@"user_bg_guide1_960",@"user_bg_guide2_960",@"user_bg_guide3_960"]);
        }else{
            showAppGuide(@[@"user_bg_guide1",@"user_bg_guide2",@"user_bg_guide3"]);
        }
        [QWUserDefault setBool:YES key  :ONCE_LOADING];
    } else {
        [APPDelegate showOPSplash];
        //MARK: 别删，未来可能使用 comment by perry
//            [QWGLOBALMANAGER postNotif:NotifAppCheckVersion data:nil object:nil];
//        }
    }
}

- (void)showOPSplash
{
    if ([QWUserDefault getBoolBy:ONCE_LOADING]) {
        if([QWUserDefault getObjectBy:APP_LAUNCH_IMAGE]) {
            showAppOPGuide([QWUserDefault getObjectBy:APP_LAUNCH_IMAGE]);
        }else{
            showAppOPGuide([UIImage imageNamed:@"user_bg_guide2"]);//默认一张
        }
    }
}

#pragma mark - 检查有没有新的慢病订阅
//- (void)checkAllNewDisease
//{
//    if (!QWGLOBALMANAGER.loginStatus) {
//        return;
//    }
////    if (QWGLOBALMANAGER.needShowBadge || QWGLOBALMANAGER.tabBar.selectedIndex == 2) {
////        //如果当前已经显示红点或者当前选中的是tab=3的慢病订阅界面
////        return;
////    }
//
//    QueryDrugGuideNewItemModelR *modelR = [[QueryDrugGuideNewItemModelR alloc] init];
//    modelR.token = QWGLOBALMANAGER.configure.userToken;
//    HttpClientMgr.progressEnabled = NO;
//    [DrugGuideApi queryNewDiseaseList:modelR success:^(id model) {
//        DrugGuideCheckNewMsgListModel *modelList = (DrugGuideCheckNewMsgListModel *)model;
//        BOOL hasNewDisease = NO;
//        for (DrugGuideCheckNewMsgModel *modelNew in modelList.list) {
//            DrugGuideListModel *modelGuide = [DrugGuideListModel getObjFromDBWithWhere:[NSString stringWithFormat:@" attentionId = '%@'",modelNew.attentionId]];
//            if (modelGuide == nil) {
//                continue;
//            }
//            if (![modelNew.nodeTime isEqualToString:modelGuide.nodeTime]) {
//                hasNewDisease = YES;
//                modelGuide.nodeTime = modelNew.nodeTime;
//                modelGuide.hasRead = NO;
//                [DrugGuideListModel updateObjToDB:modelGuide WithKey:modelGuide.guideId];
//            }
//        }
//        if (hasNewDisease) {
//            QWGLOBALMANAGER.needShowBadge = YES;
//            [QWGLOBALMANAGER setBadgeNumStatus:YES];
//        }
//    } failure:^(HttpException *err) {
//        
//    }];
//}
- (void)queryAllDisease
{

    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = StrFromObj(QWGLOBALMANAGER.configure.userToken);
    
    [DrugGuideApi drugGuidePushMesWithParams:setting success:^(id obj) {
        
        if ([obj[@"apiStatus"] integerValue] == 0) {
         
            if ([obj[@"redDot"] integerValue] == 1)
            {
                //显示小红点
                QWGLOBALMANAGER.needShowBadge = YES;
                [QWGLOBALMANAGER setBadgeNumStatus:YES];
                
            }else if ([obj[@"redDot"] integerValue] == 0)
            {
                //不显示小红点
                QWGLOBALMANAGER.needShowBadge = NO;
                [QWGLOBALMANAGER setBadgeNumStatus:NO];
             
            }
        }
        
    } failure:^(HttpException *e) {
        
    }];
    
//    if (QWGLOBALMANAGER.needShowBadge || QWGLOBALMANAGER.tabBar.selectedIndex == 2) {
//        //如果当前已经显示红点或者当前选中的是tab=3的慢病订阅界面
//        return;
//    }
//    DrugGuideListModelR *modelR = [[DrugGuideListModelR alloc] init];
//    modelR.token = QWGLOBALMANAGER.configure.userToken;
//    modelR.status = @"3";       // 慢病订阅状态
//    modelR.currPage = @"1";
//    modelR.pageSize = @"100";
//    HttpClientMgr.progressEnabled=NO;
//    [DrugGuideApi getDrugGuideList:modelR success:^(id array) {
//        if (array != nil) {
//            DrugGuideModel *tempDrug = (DrugGuideModel *)array;
//            if (tempDrug.list.count > 0) {
//                __block BOOL result = NO;
//                __block NSArray *arrModelFromWeb = tempDrug.list;
//                __block NSArray *arrModelFromDB = [DrugGuideListModel getArrayFromDBWithWhere:nil];
//                // 所有guideID 数组
//                NSMutableArray *arrGuides = [[NSMutableArray alloc] init];
//                for (DrugGuideListModel *model in arrModelFromDB) {
//                    [arrGuides addObject:model.guideId];
//                }
//                // 首先遍历服务器传来的数组，和本地缓存的慢病进行guideID的比较，找出有没有服务器新增的或者删除的
//                [arrModelFromWeb enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                    DrugGuideListModel *modelWeb = (DrugGuideListModel *)obj;
//                    BOOL compareResult = NO;
//                    for (NSString *strGuide in arrGuides) {
//                        if ([strGuide isEqualToString:modelWeb.guideId]) {
//                            compareResult = YES;
//                            break;
//                        }
//                    }
//                    if (!compareResult) {
//                        *stop = YES;
//                        result = YES;
//                    }
//                }];
//                if (!result) {
//                    [arrModelFromWeb enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                        DrugGuideListModel *modelWeb = (DrugGuideListModel *)obj;
//                        BOOL compareResult = NO;
//                        for (DrugGuideListModel *modelDB in arrModelFromDB) {
//                            if ([modelDB.unReadCount isEqual:[NSNull null]]) {
//                                continue;
//                            }
//                            if ([modelDB.guideId isEqualToString:modelWeb.guideId]) {
//                                if ([modelDB.unReadCount integerValue] != [modelWeb.unReadCount integerValue]) {
//                                    compareResult = YES;
//                                    break;
//                                }
//                            }
//                        }
//                        if (compareResult) {
//                            result = YES;
//                            modelWeb.hasRead = NO;
//                            [DrugGuideListModel updateObjToDB:modelWeb WithKey:modelWeb.guideId];
//                        }
//                    }];
//                }
//                if (result) {
//                    // 有新数据
//                    QWGLOBALMANAGER.needShowBadge = YES;
//                    [QWGLOBALMANAGER setBadgeNumStatus:YES];
//                } else {
//                    QWGLOBALMANAGER.needShowBadge = NO;
//                    [QWGLOBALMANAGER setBadgeNumStatus:NO];
//                }
//            }
//        }
//    } failure:^(HttpException *err) {
//    }];
//    
}

//向服务器回执未读数
- (void)updateUnreadCount:(NSString *)strUnread
{
    
    if (QWGLOBALMANAGER.loginStatus == NO) {
        return;
    }
    ConsultSetUnreadNumModelR *modelR = [ConsultSetUnreadNumModelR new];
    modelR.token = QWGLOBALMANAGER.configure.userToken;
    modelR.num = strUnread;
    [Consult updateNotiNumberWithParam:modelR success:^(id ResModel) {
        ConsultModel *modelResponse = (ConsultModel *)ResModel;
        if (modelResponse.apiStatus == 0) {
        }
    } failure:^(HttpException *e) {
        
    }];
}

#pragma mark -
#pragma mark 长按保存图片

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        UIImageWriteToSavedPhotosAlbum(QWGLOBALMANAGER.saveImage,  self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(!error) {
        [SVProgressHUD showSuccessWithStatus:@"图片保存成功" duration:0.8f];
    }
}

#pragma mark - 评论
- (APPCmtModel*)getCommentModel{
    APPCmtModel *mm=[APPCmtModel getObjFromDBWithWhere:nil];
    if (mm==nil) {
        mm=[[APPCmtModel alloc]init];
        mm.version=APP_VERSION;
        [APPCmtModel saveObjToDB:mm];
    }
    return mm;
}
- (void)checkAppComment{
    APPCmtModel *mm=[self getCommentModel];
    if (![mm.version isEqualToString:APP_VERSION]) {
        mm=[[APPCmtModel alloc]init];
        mm.version=APP_VERSION;
        [APPCmtModel updateToDB:mm where:nil];
    }
    BOOL canShow=YES;
    
    if (mm.isClicked.intValue==1) {
        canShow=NO;
    }
    if (mm.useCoupon.intValue==0 && mm.useGoods.intValue==0 && mm.hadConsult.intValue==0) {
        canShow=NO;
    }
    
    if (canShow) {
        APPCommentAlert *alert=[APPCommentAlert instance];
        [alert show];
    }
}

- (void)appCommentClick{
    APPCmtModel *mm=[self getCommentModel];
    mm.isClicked=@"1";
    [APPCmtModel updateToDB:mm where:nil];
}

- (void)appHadConsult{
    APPCmtModel *mm=[self getCommentModel];
    if (mm.hadConsult.intValue==1) {
        return;
    }
    mm.hadConsult=@"1";
    [APPCmtModel updateToDB:mm where:nil];
}

- (void)appUseGoods{
    APPCmtModel *mm=[self getCommentModel];
    if (mm.useGoods.intValue==1) {
        return;
    }
    mm.useGoods=@"1";
    [APPCmtModel updateToDB:mm where:nil];
}

- (void)appUseCoupon{
    APPCmtModel *mm=[self getCommentModel];
    if (mm.useCoupon.intValue==1) {
        return;
    }
    mm.useCoupon=@"1";
    [APPCmtModel updateToDB:mm where:nil];
}

// 解除第三方授权  qq: UMShareToQQ  weixin: UMShareToWechatSession
- (void)p_unOauthWithType:(NSString *)platformType
{
    [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToQQ  completion:^(UMSocialResponseEntity *response){
        DDLogVerbose(@"response is %@",response);
        if (response.responseCode == UMSResponseCodeSuccess && response.responseType == UMSResponseUnOauth) {
            DebugLog(@"%@, 解除授权成功", platformType);
        }
    }];
}

// 密码登录、验证码登录、第三方登录、注册登录成功统一的操作
- (void)loginSuccessWithUserInfo:(mbrUser*)user
{
    QWGLOBALMANAGER.configure.userToken = user.token;
    QWGLOBALMANAGER.configure.passPort = user.passportId;
    QWGLOBALMANAGER.configure.userName = user.userName;
    QWGLOBALMANAGER.configure.nickName = user.nickName;
    QWGLOBALMANAGER.configure.avatarUrl = user.avatarUrl;
    QWGLOBALMANAGER.loginStatus = YES;
    // 2.2.3 增加
    QWGLOBALMANAGER.configure.mobile = user.mobile;
    QWGLOBALMANAGER.configure.setPwd = user.setPwd;
    QWGLOBALMANAGER.configure.firstTPAL = user.firstTPAL;
    // 2.2.4 增加
    QWGLOBALMANAGER.configure.full = user.full;
    QWGLOBALMANAGER.configure.inviteCode = user.inviteCode;
    QWGLOBALMANAGER.configure.qq = user.qq;
    QWGLOBALMANAGER.configure.weChat = user.weChat;
    
    [QWGLOBALMANAGER saveAppConfigure];
    
    [QWUserDefault setString:user.mobile key:APP_USERNAME_KEY];
    
    // 4.0.0 赠送新人大礼包
    [self checkAndAlertNewerGiftBag_4_0];
}

// 验证手机号是否已经在该客户端已经登录，如果没有则返回NO，并且保存缓存
- (BOOL) verifyMobileHasLogin:(NSString*)mobile
{
    BOOL flag = NO;
    if (!StrIsEmpty(mobile)) {
        NSString* key = [NSString stringWithFormat:@"qwlogin_%@", mobile];
        flag = [QWUserDefault getBoolBy:key];
        if (!flag) {
            [QWUserDefault setBool:YES key:key];
        }
    }
    return flag;
}

// 获取用户基础信息
- (void)getUserBaseInfo
{
    if (!StrIsEmpty(QWGLOBALMANAGER.configure.userToken)) {
        DDLogInfo(@"get userBaseInfo");
        [Mbr getBaseInfoWithParams:@{@"token":QWGLOBALMANAGER.configure.userToken} success:^(id DFUserModel) {
            mbrBaseInfo* baseInfo = DFUserModel;
            if ([baseInfo isKindOfClass:[mbrBaseInfo class]]) {
                QWGLOBALMANAGER.configure.inviteCode = baseInfo.inviteCode;
                QWGLOBALMANAGER.configure.full = baseInfo.full;
                QWGLOBALMANAGER.configure.qq = baseInfo.qq;
                QWGLOBALMANAGER.configure.weChat = baseInfo.weChat;
                QWGLOBALMANAGER.configure.setPwd = baseInfo.setPwd;
                QWGLOBALMANAGER.configure.flagSilenced = baseInfo.flagSilenced;
                [QWGLOBALMANAGER saveAppConfigure];
                DDLogInfo(@"get userBaseInfo sccess1");
            }
        } failure:^(HttpException *e) {
            DDLogError(@"get userBaseInfo failed1");
        }];
        
        GetMyInfoR* getMyInfoR = [GetMyInfoR new];
        getMyInfoR.token = QWGLOBALMANAGER.configure.userToken;
        getMyInfoR.mbrId = QWGLOBALMANAGER.configure.passPort;
        getMyInfoR.tokenFlag = @"N";
        [Forum getMyInfo:getMyInfoR success:^(QWMyForumInfo *myForumInfo) {
            if ([myForumInfo.apiStatus integerValue] == 0) {
                QWGLOBALMANAGER.configure.userType = myForumInfo.userType;
                QWGLOBALMANAGER.configure.mbrLvl = myForumInfo.mbrLvl;
                [QWGLOBALMANAGER saveAppConfigure];
                DDLogInfo(@"get userBaseInfo sccess2");
            }
        } failure:^(HttpException *e) {
            DDLogError(@"get userBaseInfo faild1");
        }];

    }
}
// 获取保存积分规则
- (void)queryAndSaveCreditRules
{
//    CreditTaskRulesModel* creditTaskRules = [CreditTaskRulesModel getFromNsuserDefault:CREDIT_RULES];
//    if (creditTaskRules) {
//        DebugLog(@"rules have exist : %@", creditTaskRules.rules);
//    }
//    else
//    {
        [Credit queryTaskRulesSuccess:^(CreditTaskRulesModel *creditTaskRules) {
            if ([creditTaskRules.apiStatus integerValue] == 0) {
                [creditTaskRules saveToNsuserDefault:CREDIT_RULES];
            }
        } failure:^(HttpException *e) {
            ;
        }];
//    }
}

- (void)pullCircleMessage
{
    if(!QWGLOBALMANAGER.loginStatus)
        return;
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = QWGLOBALMANAGER.configure.userToken;
    NSString *str = @"";
    if (QWGLOBALMANAGER.configure.lastTimestamp && ![QWGLOBALMANAGER.configure.lastTimestamp isEqualToString:@""]) {
        str = QWGLOBALMANAGER.configure.lastTimestamp;
    }
    setting[@"lastTimestamp"] = StrFromObj(str);
    [Circle TeamQueryUnReadMessageWithParams:setting success:^(id obj) {
        [self addCircleRedPoint];
        TeamMessagePageModel *page = [TeamMessagePageModel parse:obj Elements:[TeamMessageModel class] forAttribute:@"msglist"];
        if ([page.apiStatus integerValue] == 0) {
            QWGLOBALMANAGER.configure.lastTimestamp = page.lastTimestamp;
            [QWGLOBALMANAGER saveAppConfigure];
            if (page.msglist.count > 0) {
                for (TeamMessageModel *model in page.msglist) {
                    [self addCenterRedPoint];
                    self.expertMineRedPoint.hidden = NO;
                    if (model.msgClass == 1) {
                        QWGLOBALMANAGER.configure.expertCommentRed = YES;
                    }else if (model.msgClass == 2){
                        QWGLOBALMANAGER.configure.expertFlowerRed = YES;
                    }else if (model.msgClass == 99){
                        QWGLOBALMANAGER.configure.expertSystemInfoRed = YES;
                    }
                    [QWGLOBALMANAGER saveAppConfigure];
                    [QWGLOBALMANAGER postNotif:NotifCircleMsgRedPoint data:nil object:nil];
                }
            }
        }
    } failure:^(HttpException *e) {
        
    }];
}

//轮训用户禁言
- (void)pullCircleForbidMessage
{
    if(!QWGLOBALMANAGER.loginStatus)
        return;
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = QWGLOBALMANAGER.configure.userToken;
    NSString *str = @"";
    if (QWGLOBALMANAGER.configure.lastTimestamp && ![QWGLOBALMANAGER.configure.lastTimestamp isEqualToString:@""]) {
        str = QWGLOBALMANAGER.configure.lastTimestamp;
    }
    setting[@"lastTimestamp"] = StrFromObj(str);
    [Circle TeamQueryUnReadMessageWithParams:setting success:^(id obj) {
        [self addCircleRedPoint];
        TeamMessagePageModel *page = [TeamMessagePageModel parse:obj Elements:[TeamMessageModel class] forAttribute:@"msglist"];
        if ([page.apiStatus integerValue] == 0) {
            QWGLOBALMANAGER.configure.lastTimestamp = page.lastTimestamp;
            [QWGLOBALMANAGER saveAppConfigure];
            if (page.msglist.count > 0) {
                for (TeamMessageModel *model in page.msglist) {
                    
                    //16:用户禁言 17:用户解禁
                    if (model.msgType == 16 || model.msgType == 18) {
                        QWGLOBALMANAGER.configure.flagSilenced = YES;
                    }else if (model.msgType == 17 || model.msgType == 19){
                        QWGLOBALMANAGER.configure.flagSilenced = NO;
                    }
                    [QWGLOBALMANAGER saveAppConfigure];
                }
            }
        }
    } failure:^(HttpException *e) {
        
    }];
}


#pragma mark ---- 圈子有新消息 中间发光动画 ----
- (void)addCenterRedPoint
{
    if (![APPDelegate isMainTab]) {
    };
}

// TODO:.....
- (void)addCircleRedPoint
{
    CGRect frm=(CGRect){APP_W-21,7,8,8};
    if (IS_IPHONE_6) {
        frm.origin.x = APP_W-26;
    }else if (IS_IPHONE_6P){
        frm.origin.x = APP_W-30;
    }
    if (self.expertMineRedPoint) {
        [self.expertMineRedPoint removeFromSuperview];
        self.expertMineRedPoint = nil;
    }
    if (self.sellerMineRedPoint) {
        [self.sellerMineRedPoint removeFromSuperview];
        self.sellerMineRedPoint = nil;
    }
    self.expertMineRedPoint = [[UIImageView alloc] initWithFrame:frm];
    self.expertMineRedPoint.image = [UIImage imageNamed:@"img_redDot"];
    self.expertMineRedPoint.hidden = YES;
    
    self.sellerMineRedPoint = [[UIImageView alloc] initWithFrame:frm];
    self.sellerMineRedPoint.image = [UIImage imageNamed:@"img_redDot"];
    self.sellerMineRedPoint.hidden = YES;
    
    if (QWGLOBALMANAGER.configure.expertCommentRed || QWGLOBALMANAGER.configure.expertFlowerRed || QWGLOBALMANAGER.configure.expertSystemInfoRed || QWGLOBALMANAGER.configure.expertPrivateMsgRed) {
        self.expertMineRedPoint.hidden = NO;
    }
    
    if (QWGLOBALMANAGER.unReadCount > 0) {
        self.sellerMineRedPoint.hidden = NO;
    }
    
    [APPDelegate.mainVC.tabbarTwo.tabBar addSubview:self.expertMineRedPoint];
    [APPDelegate.mainVC.tabbarOne.tabBar addSubview:self.sellerMineRedPoint];
}

- (void)createCircleMessageTimer
{
    _pullCircleMessageTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(_pullCircleMessageTimer, dispatch_time(DISPATCH_TIME_NOW, 0), 60ull*NSEC_PER_SEC, DISPATCH_TIME_FOREVER);
    dispatch_source_set_event_handler(_pullCircleMessageTimer, ^{
        DebugLog(@"－－－111 圈子消息轮询");
        [self pullCircleForbidMessage];
    });
    dispatch_resume(_pullCircleMessageTimer);
}


// 根据任务key返回奖励积分，如果任务key不存在返回0
- (NSInteger)rewardScoreWithTaskKey:(NSString*)taskKey
{
    CreditTaskRulesModel* creditTaskRules = [CreditTaskRulesModel getFromNsuserDefault:CREDIT_RULES];
    if (creditTaskRules == nil) {
        return 0;
    }
    return [creditTaskRules rewardScoreWithTaskKey:taskKey];
}

- (void) unOauth
{
    NSString* appLoginType = [QWUserDefault getStringBy:APP_LOGIN_TYPE];
    if ([appLoginType isEqual:APPLOGINTYPE_QQ]) {
        [self p_unOauthWithType:UMShareToQQ];
    }
    else if ([appLoginType isEqualToString:APPLOGINTYPE_WEIXIN])
    {
        [self p_unOauthWithType:UMShareToWechatSession];
    }
}

- (NSString *)randomUUID
{
    NSString* uuid = [NSUUID UUID].UUIDString;
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return uuid;
}

static NSDateFormatter* dateFormatter;
- (NSString*)timeStrNow
{
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm";
    return [dateFormatter stringFromDate:[NSDate new]];
}

- (NSString*)timeStrSinceNowWithPastDateStr:(NSString*)pastDateStr withFormatter:(NSString*)formatterStr
{
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatterStr;
    NSDate* pastDate = [dateFormatter dateFromString:pastDateStr];
    return [self timeStrSinceNowWithPastDate:pastDate];
}

- (NSString *)timeStrSinceNowWithPastDate:(NSDate *)pastDate
{
    if (pastDate == nil) {
        return @"很久以前";
    }
    dateFormatter = [[NSDateFormatter alloc] init];
    NSString* dateFormatterString1 = @"yyyy.MM.dd hh:mm";
    NSString* dateFormatterString2 = @"MM.dd hh:mm";
    NSString* dateFormatterString3 = @"hh:mm";
    dateFormatter.dateFormat = dateFormatterString1;
    NSDate* now = [NSDate new];
    if (![now isSameYearAsDate:pastDate]) {
        dateFormatter.dateFormat = dateFormatterString1;
        return [dateFormatter stringFromDate:pastDate];
    }
    else
    {
        if ([pastDate isYesterday]) {
            dateFormatter.dateFormat = dateFormatterString3;
            return [NSString stringWithFormat:@"昨日 %@", [dateFormatter stringFromDate:pastDate]];
        }
        else if ([pastDate isToday])
        {
            NSTimeInterval interval = fabs([pastDate timeIntervalSinceNow]);
            if (interval < 60) {
                return @"刚刚";
            }
            else if (interval < 60 * 60 )
            {
                return [NSString stringWithFormat:@"%ld分钟前", MAX(1, ((long)interval) / 60)];
            }
            else if (interval < 60 * 60 * 5)
            {
                return [NSString stringWithFormat:@"%ld小时前", MAX(1, ((long)interval)%(60*60*60) / (60*60))];
            }
            else
            {
                dateFormatter.dateFormat = dateFormatterString3;
                return [dateFormatter stringFromDate:pastDate];
            }
        }
        else
        {
            dateFormatter.dateFormat = dateFormatterString2;
            return [dateFormatter stringFromDate:pastDate];
        }
    }
}

/**
 *  3.1.0 四舍五入
 */
-(NSString *)notRounding:(float)price afterPoint:(int)position{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [NSString stringWithFormat:@"%@",roundedOunces];
}


/**
 *  3.1.0 新增新人专享礼包提示需求 by martin
 */
- (void)alertNewerGiftBag
{
    /**
     *  4.0.0 只有当药房存在才弹
     */
    MapInfoModel *mapInfo = [QWUserDefault getModelBy:APP_MAPINFOMODEL];
    if (mapInfo && !StrIsEmpty(mapInfo.groupId)) {
        [QWProgressHUD showGiftBagView];
    }
}

/**
 *  4.0.0 赠送新人大礼包
 */
- (void)checkAndAlertNewerGiftBag_4_0
{
    if (!StrIsEmpty([self getMapBranchId])) {
        PresentGiftR* presentGiftR = [PresentGiftR new];
        presentGiftR.token = self.configure.userToken;
        presentGiftR.branchId = [self getMapBranchId];
        presentGiftR.deviceType = @"2";
        [Mbr presentGift:presentGiftR success:^(PresentGiftModel *presentGiftModel) {
            if (presentGiftModel.claimSuccess) {
                MapInfoModel *mapInfo = [QWUserDefault getModelBy:APP_MAPINFOMODEL];
                if (mapInfo && !StrIsEmpty(mapInfo.groupId)) {
                    [QWProgressHUD showGiftBagView];
                }
            };
        } failure:^(HttpException *e) {
            DDLogError(@"Present newer gift bag error：%@", e);
        }];
    }
}


//#pragma mark - TalkingDataAppCpa
//- (void)TalkingDataAppCpaKey:(NSString*)key{
//    //@"78449c37fbdf4858b39ead87a15db5de"
//    [TalkingDataAppCpa init:key withChannelId:@"AppStore"];
//}

#pragma mark - 获取地址
- (MapInfoModel *)QWGetLocation{
    
    MapInfoModel *obj = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
    if(obj == nil){
        return [MapInfoModel new];
    }else{
        return obj;
    }
}

/**
 *  根据控制返回对应药品属性
 *
 *  @param signcode 药品控制码
 *
 *  @return String类型
 */
- (NSString *)TypeOfDrugByCode:(NSString *)signcode{
    
    if([signcode isEqualToString:@"1a"]){           //处方药西药
        return @"处方药西药";
    }else if([signcode isEqualToString:@"1b"]){     //处方药中成药
        return @"处方药中成药";
    }else if([signcode isEqualToString:@"2a"]){     //甲类OTC非处方药西药
        return @"甲类OTC非处方药西药";
    }else if([signcode isEqualToString:@"2b"]){     //甲类OTC非处方药中成药
        return @"甲类OTC非处方药中成药";
    }else if ([signcode isEqualToString:@"3a"]){    //乙类OTC非处方药西药
        return @"乙类OTC非处方药西药";
    }else if([signcode isEqualToString:@"3b"]) {    //乙类OTC非处方药乙类OTC非处方药
        return @"乙类OTC非处方药乙类OTC非处方药";
    }else if([signcode isEqualToString:@"4c"]) {    //定型包装中药饮片
        return @"定型包装中药饮片";
    }else if([signcode isEqualToString:@"4d"]) {    //散装中药饮片
        return @"散装中药饮片";
    }else if([signcode isEqualToString:@"5"]) {     //保健食品
        return @"保健食品";
    }else if([signcode isEqualToString:@"6"]) {     //食品
        return @"食品";
    }else if([signcode isEqualToString:@"7"]) {     //械字号一类
        return @"械字号一类";
    }else if([signcode isEqualToString:@"8"]) {     //械字号二类
        return @"械字号二类";
    }else if([signcode isEqualToString:@"10"]) {    //消字号
        return @"消字号";
    }else if([signcode isEqualToString:@"11"]) {    //妆字号
        return @"妆字号";
    }else if([signcode isEqualToString:@"12"]) {    //无批准号
        return @"无批准号";
    }else if([signcode isEqualToString:@"13"]) {    //其他
        return @"其他";
    }else if([signcode isEqualToString:@"9"]) {     //械字号三类
        return @"械字号三类";
    }
    return @"";
}

/**
 *  根据控制返回对应药品显示用途
 *
 *  @param Signcode 药品控制码
 *
 *  @return String类型
 */
- (NSString *)UseOfDrugByCode:(NSString *)signcode{
    
    //1.适应症
    //西药(处方药西药1a,甲类OTC西药2a,乙类OTC西药3a)
    //2.主治功能
    //中成药(处方药中成药1b,甲类OTC中成药2b,乙类OTC中成药3b)、中药饮片(中药定型包装4c,散装中药饮片4d)
    //3.保健功能
    //保健食品(保健食品5，食品6)
    //4.适用范围
    //个人护理品(消字号10，妆字号11)
    //5.产品用途
    //医疗器械(械字号一类7,械字号二类8,械字号三类9)
    //6.不展示
    //其他
    
    //1.西药            展示适应症
    if([signcode isEqualToString:@"1a"]){
        return @"适应症";
    }
    if([signcode isEqualToString:@"2a"]){
        return @"适应症";
    }
    if([signcode isEqualToString:@"3a"]){
        return @"适应症";
    }
    //2.中成药、中药饮片   展示主治功能
    if([signcode isEqualToString:@"1b"]){
        return @"主治功能";
    }
    if([signcode isEqualToString:@"2b"]){
        return @"主治功能";
    }
    if([signcode isEqualToString:@"3b"]){
        return @"主治功能";
    }
    if([signcode isEqualToString:@"4c"]){
        return @"主治功能";
    }
    if([signcode isEqualToString:@"4d"]){
        return @"主治功能";
    }
    //3.保健功能          展示保健功能
    if([signcode isEqualToString:@"5"]){
        return @"保健功能";
    }
    if([signcode isEqualToString:@"6"]){
        return @"保健功能";
    }
    //4.个人护理品        展示适用范围
    if([signcode isEqualToString:@"10"]){
        return @"适用范围";
    }
    if([signcode isEqualToString:@"11"]){
        return @"适用范围";
    }
    //5.医疗器械         展示产品用途
    if([signcode isEqualToString:@"7"]){
        return @"产品用途";
    }
    if([signcode isEqualToString:@"8"]){
        return @"产品用途";
    }
    if([signcode isEqualToString:@"9"]){
        return @"产品用途";
    }
    
    return @"";
}
@end

static NSMutableDictionary * app_history = nil;

NSString * getHistoryFilePath()
{
    NSString * account = [QWUserDefault getStringBy:APP_USERNAME_KEY];
    if (account == nil) {
        account = @"anonymous";
    }
    NSString * historyPath = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),account];
    //DDLogVerbose(@"path = %@",historyPath);
    NSString * historyFile = [NSString stringWithFormat:@"%@/history.plist",historyPath];
    //DDLogVerbose(@"file = %@",historyFile);
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:historyPath]) {
        [fileManager createDirectoryAtPath:historyPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath:historyFile]) {
        app_history = [[NSMutableDictionary alloc] init];
        [app_history writeToFile:historyFile atomically:YES];
    }else {
        app_history = [[NSMutableDictionary alloc] initWithContentsOfFile:historyFile];
        
    }
    if (!app_history) {
        app_history = [[NSMutableDictionary alloc] initWithContentsOfFile:historyFile];
    }
    return historyFile;
}

void setHistoryConfig(NSString * key , id value)
{
    NSString * historyFile = getHistoryFilePath();
    if (value) {
        app_history[key] = value;
    }else {
        [app_history removeObjectForKey:key];
    }
    [app_history writeToFile:historyFile atomically:YES];
}

id getHistoryConfig(NSString *key){
    getHistoryFilePath();
    return app_history[key];
}
