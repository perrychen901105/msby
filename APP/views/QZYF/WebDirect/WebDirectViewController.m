//
//  WebDirectViewController.m
//  APP
//
//  Created by PerryChen on 8/20/15.
//  Copyright (c) 2015 carret. All rights reserved.
//

#import "WebDirectViewController.h"
#import "LoginViewController.h"
#import "MessageBoxListViewController.h"
#import "SVProgressHUD.h"
#import "RCDraggableButton.h"
#import "ConsultForFreeRootViewController.h"
#import "System.h"
#import "AppDelegate.h"
#import "CommonDiseaseDetailViewController.h"
#import "QuestionListViewController.h"
#import "DiseaseMedicineListViewController.h"
#import "PickPromotionSuccessViewController.h"
#import "FamliyMedcineViewController.h"
#import "FamilyMedicineListViewController.h"
#import "MoreConsultViewController.h"
#import "ChatViewController.h"
#import "WebCommentViewController.h"
#import "MyCouponDrugViewController.h"
#import "DrugModel.h"
#import "CouponSuccessViewController.h"
#import "PromotionDrugDetailViewController.h"
#import "CenterCouponDetailViewController.h"
#import "WinDetialViewController.h"
#import "QWH5Loading.h"
#import "MyCreditViewController.h"
#import "PromotionActivityDetailViewController.h"
#import "ReceiverAddressTableViewController.h"
#import "NSString+TransDomain.h"
#import "MedicineSearchResultViewController.h"
#import "MallCart.h"
#import "MedicineDetailViewController.h"
#import "SendPostViewController.h"
#import "ExpertPageViewController.h"
#import "CircleDetailViewController.h"
#import "PostDetailViewController.h"
#import "IndentDetailListViewController.h"
#import "PayInfoModel.h"
#import "PayOrderStatusViewController.h"
#import "SimpleShoppingCartViewController.h"
#import "SubmitOrderSuccessViewController.h"
#import "ChangePhoneNumberViewController.h"


@interface WebDirectViewController ()
@property (nonatomic, assign) BOOL theBool;
@property (nonatomic, strong) IBOutlet UIProgressView* progressBarLoading;
@property (nonatomic, strong) NSTimer *myTimer;
@property (nonatomic, weak) IBOutlet UIWebView *webViewDirect;
@property (nonatomic, strong) UILabel *numLabel;        //数字角标
@property (nonatomic, strong) UILabel *redLabel;        //小红点
@property (nonatomic, assign) int passNumber;
@property (nonatomic, assign) BOOL needUpdateInfoList;   // 是否刷新资讯列表
@property (nonatomic, strong) NSString *phoneNumber;

@property (nonatomic, strong) NSString *strWebUrl;       // H5 链接
//@property (nonatomic, assign) LocalShareType typeShare;

//@property (weak, nonatomic) IBOutlet UIProgressView *progressBarLoading;

@property (nonatomic, strong) ShareContentModel *modelShare;

@property (nonatomic, assign) BOOL neednotShowloading;

@property (nonatomic, strong) WebDirectLocalModel *modelLocal;
//咨询按钮
@property (nonatomic, strong) RCDraggableButton *avatar;

@property (nonatomic, assign) BOOL showCustomeBack;


@property (nonatomic,assign) BOOL isFind;
@end

@implementation WebDirectViewController

- (void)needUpdateInfoList:(BOOL)needUp
{
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.showCustomLoading && QWGLOBALMANAGER.currentNetWork != kNotReachable) {
        [QWH5LOADING showLoading];
    }
    /**
     *  3.1增加的，从h5外链进来积分商城详情，加一个返回按钮
     */
    if (self.navigationController == nil || self.navigationController.topViewController == self) {
        [self naviBackBotton];
    }
    //3.0去掉咨询按钮
    
//    if (self.showConsultBtn) {
//        self.avatar = [[RCDraggableButton alloc] initWithFrame:CGRectMake(APP_W-78, SCREEN_H-142, 45, 45)];
//        [self.avatar setBackgroundImage:[UIImage imageNamed:@"img_btn_advisory"] forState:UIControlStateNormal];
//        [self.view addSubview:self.avatar];//加载图片
//        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(consultDoctor:)];
//        [self.avatar addGestureRecognizer:singleTap];//点击图片事件
//        [self.view addSubview:self.avatar];//加载图片
//    }
    self.isFind = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.passNumber = [QWGLOBALMANAGER updateRedPoint];
    self.isUp=YES;
    if (self.showConsultBtn == YES||self.payButton || self.pageType == WebPageToWebTypeExchangeList || self.pageType == WebLocalTypeAnswerDetail) {
        ((QWBaseNavigationController *)self.navigationController).canDragBack = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isUp=NO;
    if (self.showConsultBtn == YES||self.payButton || self.pageType == WebPageToWebTypeExchangeList || self.pageType == WebLocalTypeAnswerDetail) {
        ((QWBaseNavigationController *)self.navigationController).canDragBack = YES;
    }
}

- (void)webViewStartLoad
{
    if (!self.neednotShowloading) {
        self.progressBarLoading.hidden = YES;
        self.progressBarLoading.progress = 0;
        self.theBool = false;
        if (self.myTimer != nil) {
            [self.myTimer invalidate];
        }
        if (!self.myTimer) {
            self.myTimer = [NSTimer timerWithTimeInterval:0.01667 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
        }
        
        if (self.myTimer) {
            [[NSRunLoop mainRunLoop] addTimer:self.myTimer forMode:NSDefaultRunLoopMode];
        }
    }
}

- (void)consultDoctor:(id)sender {
    ConsultForFreeRootViewController *consultFirstViewController = [[UIStoryboard storyboardWithName:@"ConsultForFree" bundle:nil] instantiateViewControllerWithIdentifier:@"ConsultForFreeRootViewController"];
    consultFirstViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:consultFirstViewController animated:YES];
}
- (void)webViewDidLoad
{
    NSString *strDataType = [self.m_webView stringByEvaluatingJavaScriptFromString:@"var a=document.getElementById(\"data-appType\"); var str = a.getAttribute(\"data-type\");decodeURIComponent(str)"];
    if (self.modelLocal.typeLocalWeb == WebLocalTypeOuterLink) {
        if (strDataType) {
            if ([strDataType intValue] == WebPageTypeIntegralIndex) {
                self.pageType = WebPageTypeIntegralIndex;
            }
        }
        // 控制分享类型
        NSString *strShareState = [self.m_webView stringByEvaluatingJavaScriptFromString:@"var a=document.getElementById(\"data-appType\"); var str = a.getAttribute(\"shareState\");decodeURIComponent(str)"];
        if (strShareState.length != 0) {
            [QWH5LOADING closeLoading];
        }
        
        
        if (!self.didSetShare){//调用的H5（其他地方不传的默认走H5的）
            if ([strShareState isEqualToString:@""]) {
                // 隐藏分享功能
//                [self setupNaviItem:WebTitleTypeNone];
            }else{
                if ([strShareState intValue] == 0) {
                    // 显示分享功能
                    [self setupNaviItem:WebTitleTypeOnlyShare];
                } else {
                    // 隐藏分享功能
                    [self setupNaviItem:WebTitleTypeNone];
                }
            }
        }else{//不调用H5的
        
        }
        
    }
    if (self.isOtherLinks == YES) {
        // 是外链
        
        if ([self.modelLocal.title length] == 0) {
            NSString *theTitle=[self.m_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
            self.navigationItem.title = theTitle;
        } else {
            self.navigationItem.title = self.modelLocal.title;
        }
        if (self.navigationItem.title.length == 0) {
            NSString *strTitle = [self.m_webView stringByEvaluatingJavaScriptFromString:@"var a=document.getElementById(\"data-title\"); var str = a.getAttribute(\"data\"); decodeURIComponent(str)"];
            if (strTitle.length > 0) {
                self.navigationItem.title = strTitle;
            }
        }
        
    }
    if (!self.neednotShowloading) {
        self.theBool = true;
        self.phoneNumber = @"";
    }
}
-(void)timerCallback {
    if (self.theBool) {
        if (self.progressBarLoading.progress >= 1) {
            self.progressBarLoading.hidden = true;
            if (self.myTimer) {
                [self.myTimer invalidate];
            }
        }
        else {
            self.progressBarLoading.progress += 0.1;
        }
    }
    else {
        self.progressBarLoading.progress += 0.05;
        if (self.progressBarLoading.progress >= 0.95) {
            self.progressBarLoading.progress = 0.95;
        }
    }
}

- (void)setupNaviItem:(WebTitleType)enutTitle
{
    self.passNumber = [QWGLOBALMANAGER updateRedPoint];
    
    if (enutTitle == WebTitleTypeNone) {
        self.navigationItem.rightBarButtonItems = nil;
    } else if (enutTitle == WebTitleTypeBackToHomeWithMsg) {
        [self setUpRightItemOne];
    } else if (enutTitle == WebTitleTypeMsgAndShare) {
        [self setUpRightItemTwo];
    } else if (enutTitle == WebTitleTypeWithJumpAndMsg) {
        [self setUpRightItemFour];
    } else if (enutTitle == WebTitleTypeWithFontAndMsgWithoutShare) {
        [self setUpRightItemFive];
    } else if (enutTitle == WebTitleTypeWithFontAndMsgWithShare) {
        [self setUpRightItemSix];
    } else if (enutTitle == WebTitleTypeWithJump) {
        [self setUpRightItemFour];
    } else if (enutTitle == WebTitleTypeOnlyShare) {
        [self setUpRightItemSeven];
    } else if (enutTitle == WebTitleTypeWithFontOnly){
        [self setUpRightItemEight];
    } else if (enutTitle == WebTitleTypeBackToHomeRoot) {
        [self setUpRightItemNine];
    } else {
//        [self setUpRightItemOne];
    }
}

- (void)setupFontAction
{
    if (self.extShare) {
        [self.extShare runExtWithCallBackId:CallbackTypeScale];
    }
}

- (void)WebDirectLocalModel:(WebDirectModel *)modelDir
{
    self.navigationItem.title = modelDir.title;
}
// 设置本地跳转H5的接口
- (void)setWVWithLocalModel:(WebDirectLocalModel *)modelDir
{
    NSString *tokenStr = @"";
    if (QWGLOBALMANAGER.configure.userToken.length > 0) {
        tokenStr = QWGLOBALMANAGER.configure.userToken;
    }

    if (modelDir.typeLocalWeb == WebPageToWebTypeMedicine) {
        // 优惠商品
        modelDir.typeShare = LocalShareTypeMedicine;
        if (modelDir.modelDrug.proDrugID == nil) {
            modelDir.modelDrug.proDrugID = @"";
        }
        if (modelDir.modelDrug.promotionID == nil) {
            modelDir.modelDrug.promotionID = @"";
        }
        if (modelDir.modelDrug.activityID == nil) {
            modelDir.modelDrug.activityID = @"";
        }
        NSString *url = @"";
        if([modelDir.modelDrug.promotionID isEqualToString:@""]){
            // 普通商品
            
            modelDir.modelDrug.showDrug=@"1";
            modelDir.typeTitle = WebTitleTypeBackToHomeRoot;
            //TODO: need change
            if ([APPDelegate isMainTab]) {
                // 判断为内容屏
                modelDir.title = @"药品详情";
                url = [NSString stringWithFormat:@"%@QWYH/web/drug/html/normal/nDrugDetail.html?id=%@",H5_BASE_URL,modelDir.modelDrug.proDrugID];
            } else {
                // 判断为营销屏
                modelDir.title = @"商品详情";
                url = [NSString stringWithFormat:@"%@QWYH/web/drug/html/normal/yDrugDetail.html?id=%@",H5_BASE_URL,modelDir.modelDrug.proDrugID];
            }
        }
        else{
            modelDir.typeTitle = WebTitleTypeBackToHomeRoot;
            //是优惠商品的针对内容屏遗留的优惠商品做优化  cj
            if ([APPDelegate isMainTab]) {
                // 判断为内容屏  有优惠也直接是普通药品详情
                // 判断是否从通知进入
                    modelDir.title = @"药品详情";
                    url = [NSString stringWithFormat:@"%@QWYH/web/drug/html/normal/nDrugDetail.html?id=%@",H5_BASE_URL,modelDir.modelDrug.proDrugID];
            }else{
                //TODO: need change
                // 优惠商品和抢购商品
                modelDir.modelDrug.showDrug=@"0";   // 显示优惠标签
                if(StrIsEmpty(modelDir.modelDrug.activityID)){
                    // 优惠商品
                    if(_NeedTwoTab){
                        modelDir.title = @"药品详情";
                        url = [NSString stringWithFormat:@"%@QWYH/web/drug/html/normal/nDrugDetail.html?id=%@",H5_BASE_URL,modelDir.modelDrug.proDrugID];
                    }else{
                        modelDir.title = @"商品详情";
                        url = [NSString stringWithFormat:@"%@/p_drugDetail.html?id=%@&promotionId=%@",HTML5_DIRECT_URL_NEW_VERSION,modelDir.modelDrug.proDrugID,modelDir.modelDrug.promotionID];
                    }
                }else{
                    // 抢购商品
                    modelDir.title = @"抢购详情";
                    if (QWGLOBALMANAGER.weChatBusiness) {
                        // 微商
                        url = [NSString stringWithFormat:@"%@QWYH/web/drug/html/quickBuy/yBizDrugDetail.html?id=%@rushId=%@",H5_BASE_URL,modelDir.modelDrug.proDrugID, modelDir.modelDrug.activityID];
                    } else {
                        // 非微商
                        url = [NSString stringWithFormat:@"%@/p_drugDetail.html?id=%@&promotionId=%@",HTML5_DIRECT_URL_NEW_VERSION,modelDir.modelDrug.proDrugID,modelDir.modelDrug.promotionID];
                    }
                }
            }
        }
        modelDir.url = url;
        self.showCustomLoading = YES;
    }else if (modelDir.typeLocalWeb == WebLocalTypeOuterLink) {
        // 外链
        if (modelDir.typeTitle == 0) {
            modelDir.typeTitle = WebTitleTypeOnlyShare;
        }
        modelDir.typeShare = LocalShareTypeOuterLink;
        self.strWebUrl = modelDir.url;
        self.showCustomLoading = NO;
    } else if (modelDir.typeLocalWeb == WebLocalTypeJumpChronicGuidePage) {
        // 跳过外链
        modelDir.title = @"如何认证慢病用户";
        modelDir.url = [NSString stringWithFormat:@"%@/guide_page.html",HTML5_DIRECT_URL_WITH_VERSION];
        modelDir.typeTitle = WebTitleTypeWithJump;
    } else if (modelDir.typeLocalWeb == WebLocalTypeCouponProductManual) {
        // 优惠商品使用说明
        modelDir.title = @"优惠商品使用说明";
        modelDir.url = [NSString stringWithFormat:@"%@/discount_explain.html",HTML5_DIRECT_URL_WITH_VERSION];
        modelDir.typeTitle = WebTitleTypeOnlyShare;
    } else if (modelDir.typeLocalWeb == WebPageToWebTypeDisease) {
        // 跳转疾病详情
        //cj  右侧
        modelDir.typeShare = LocalShareTypeDiseaseTypeBC;
        if (modelDir.modelDisease.diseaseId == nil) {
            modelDir.modelDisease.diseaseId = @"";
        }
        NSString *url = [NSString stringWithFormat:@"%@/disease.html?id=%@",HTML5_DIRECT_URL,modelDir.modelDisease.diseaseId];
        modelDir.url = url;
        modelDir.typeTitle =WebTitleTypeWithFontOnly;
        self.showCustomLoading = YES;
    } else if (modelDir.typeLocalWeb == WebPageToWebTypeSympton) {
        // 跳转至症状详情
        //cj  右侧
        
        NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
        tdParams[@"上级来源"]=self.title;
        [QWGLOBALMANAGER statisticsEventId:@"x_zzxq" withLable:@"症状详情" withParams:tdParams];

        modelDir.typeShare = LocalShareTypeNone;
        modelDir.typeTitle =WebTitleTypeWithFontOnly;
        if (modelDir.modelSymptom.symptomId == nil) {
            modelDir.modelSymptom.symptomId = @"";
        }
        NSString *url = [NSString stringWithFormat:@"%@/symptom.html?id=%@&token=%@",HTML5_DIRECT_URL,modelDir.modelSymptom.symptomId,tokenStr];
        modelDir.url = url;
        self.showCustomLoading = YES;
    } else if (modelDir.typeLocalWeb == WebLocalTypeCouponCondition) {
        // 跳转优惠细则
        modelDir.title = @"优惠细则";
        modelDir.typeTitle = WebTitleTypeNone;
        modelDir.typeShare = LocalShareTypeNone;
        if (modelDir.modelCondition.couponId == nil) {
            modelDir.modelCondition.couponId = @"";
        }
        NSString *url = [NSString stringWithFormat:@"%@QWYH/web/ruleDes/html/condition.html?type=%@&id=%@",H5_BASE_URL,modelDir.modelCondition.type,modelDir.modelCondition.couponId];
        modelDir.url = url;
    } else if (modelDir.typeLocalWeb == WebLocalTypeCouponTicketHelp) {
        // 跳转优惠券帮助
        modelDir.title = @"优惠券帮助";
        modelDir.url = [NSString stringWithFormat:@"%@/help/coupon_help.html",HTML5_DIRECT_URL];
        modelDir.typeTitle = WebTitleTypeNone;
        modelDir.typeShare = LocalShareTypeNone;
    } else if (modelDir.typeLocalWeb == WebLocalTypeCouponHelp) {
        // 跳转优惠商品帮助
        modelDir.title = @"优惠商品帮助";
        modelDir.url = [NSString stringWithFormat:@"%@/help/coupon_help.html",HTML5_DIRECT_URL];
        modelDir.typeTitle = WebTitleTypeNone;
        modelDir.typeShare = LocalShareTypeNone;
    } else if (modelDir.typeLocalWeb == WebLocalTypeDiscountExplain) {
        // 跳转至使用说明
        modelDir.title = @"使用说明";
        modelDir.url = [NSString stringWithFormat:@"%@/discount_explain.html",HTML5_DIRECT_URL_WITH_VERSION];
        modelDir.typeTitle = WebTitleTypeBackToHome;
        modelDir.typeShare = LocalShareTypeNone;
    } else if (modelDir.typeLocalWeb == WebLocalTypeMedicineHelp) {
        // 跳转至用药帮助
        modelDir.title = @"用药帮助";
        modelDir.url = [NSString stringWithFormat:@"%@/help/yongyao_help.html?token=%@",HTML5_DIRECT_URL,tokenStr];
        modelDir.typeTitle = WebTitleTypeNone;
        modelDir.typeShare = LocalShareTypeNone;
    } else if (modelDir.typeLocalWeb == WebLocalTypeAnalyzeMember) {
        // 跳转至用药分析
        modelDir.title = @"用药分析";
        modelDir.url = [NSString stringWithFormat:@"%@/help/analystByMember.html?token=%@",HTML5_DIRECT_URL,tokenStr];
        modelDir.typeTitle = WebTitleTypeNone;
        modelDir.typeShare = LocalShareTypeNone;
    } else if (modelDir.typeLocalWeb == WebPageToWebTypeInfo) {
        // 跳转至健康资讯
        modelDir.title = @"健康资讯";
        NSString *url = @"";
        if (([modelDir.modelHealInfo.contentType intValue] == 1)||([modelDir.modelHealInfo.contentType intValue] == 2)) {
            url = [NSString stringWithFormat:@"%@QWYH/web/message/html/message_char.html?id=%@&contentType=%@",H5_BASE_URL,modelDir.modelHealInfo.msgID,modelDir.modelHealInfo.contentType];
        } else {
            url = [NSString stringWithFormat:@"%@QWYH/web/message/html/message_char.html?id=%@&contentType=",H5_BASE_URL,modelDir.modelHealInfo.msgID];
//            url = [NSString stringWithFormat:@"%@/message.html?id=%@&token=%@&from=0",HTML5_DIRECT_URL,modelDir.modelHealInfo.healthID,tokenStr];
        }
        modelDir.url = url;
        modelDir.typeTitle = WebTitleTypeWithFontOnly;//WebTitleTypeMsgAndShare;
        modelDir.typeShare = LocalShareTypeInfo;
        self.showCustomLoading = YES;
    } else if (modelDir.typeLocalWeb == WebLocalTypeMyTopics) {
        // 跳转至我收藏的专题页面
        modelDir.title = @"专题";
        NSString *webUrl = [NSString stringWithFormat:@"%@/my_topics.html?token=%@",HTML5_DIRECT_URL_WITH_VERSION,tokenStr];
        modelDir.url = webUrl;
        modelDir.typeTitle = WebTitleTypeSpecialZone;
    } else if (modelDir.typeLocalWeb == WebLocalTypeMySpecialTopics) {
        // 跳转至我收藏的专刊页面
        modelDir.title = @"专刊";
        NSString *webUrl = [NSString stringWithFormat:@"%@/my_specialTopic.html?token=%@",HTML5_DIRECT_URL_WITH_VERSION,tokenStr];
        modelDir.url = webUrl;
        modelDir.typeTitle = WebTitleTypeSpecialZone;
    } else if (modelDir.typeLocalWeb == WebLocalTypeSlowDiseaseArea) {
        // 跳转到慢病专区
        modelDir.typeTitle = WebTitleTypeNone;
        modelDir.typeShare = LocalShareTypeNone;
        if (modelDir.url.length <= 0) {
            modelDir.url = [NSString stringWithFormat:@"%@%@",BASE_URL_V2,modelDir.strParams];
        } else {
            modelDir.url = [NSString stringWithFormat:@"%@",modelDir.url];
        }
        self.showCustomLoading = YES;
    } else if (modelDir.typeLocalWeb == WebLocalTypeTopicList) {
        // 跳转到专题列表
        modelDir.typeTitle = WebTitleTypeNone;
        modelDir.typeShare = LocalShareTypeNone;
        if (modelDir.url.length <= 0) {
            modelDir.url = [NSString stringWithFormat:@"%@%@",BASE_URL_V2,modelDir.strParams];
        }
        self.showCustomLoading = YES;
    } else if (modelDir.typeLocalWeb == WebLocalTypeDivision) {
        // 跳转到专区
        modelDir.typeTitle = WebTitleTypeOnlyShare;
        modelDir.typeShare = LocalShareTypeArea;
        if (modelDir.url.length <= 0) {
            modelDir.url = [NSString stringWithFormat:@"%@%@",BASE_URL_V2,modelDir.strParams];
        }
        self.showCustomLoading = YES;
    } else if (modelDir.typeLocalWeb == WebPageToWebTypeTopicDetail) {
        // 跳转到专题详情
        modelDir.typeTitle = WebTitleTypeOnlyShare;
        modelDir.typeShare = LocalShareTypeTopic;
        if (modelDir.url.length <= 0) {
            modelDir.url = [NSString stringWithFormat:@"%@%@",BASE_URL_V2,modelDir.strParams];
        }
        self.showCustomLoading = YES;
    } else if (modelDir.typeLocalWeb == WebPageToWebTypeHealthCheckBegin) {
        // 跳转至健康评测
        
        //cj 右侧小红点
        modelDir.typeTitle = WebTitleTypeNone;
        modelDir.typeShare = LocalShareTypeHealthCheckList;
        modelDir.url = [NSString stringWithFormat:@"%@QWYH/web/self_check/html/list.html",H5_BASE_URL];
        self.showCustomLoading = YES;
    } else if (modelDir.typeLocalWeb == WebLocalTypeRoller) {
        // 跳转至大转盘
        modelDir.typeTitle = WebTitleTypeOnlyShare;
        modelDir.typeShare = LocalShareTypeRoller;
        modelDir.url = [NSString stringWithFormat:@"%@QWAPP/activity/turntable/html/turntable.html",H5_DOMAIN_URL];
    } else if (modelDir.typeLocalWeb == WebLocalTypeIMMerchant) {
        // 跳转至我是商家
        modelDir.typeTitle = WebTitleTypeNone;
        modelDir.typeShare = LocalShareTypeNone;
        modelDir.url = [NSString stringWithFormat:@"%@html5/merchantLoad.html",BASE_URL_V2];
    } else if (modelDir.typeLocalWeb == WebPageTypeIntegralIndex) {
        // 跳转积分商城
       
        modelDir.typeTitle = WebTitleTypeNone;
        modelDir.typeShare = LocalShareTypeNone;
        modelDir.url = [NSString stringWithFormat:@"%@QWYH/web/integral_mall/html/index.html",H5_BASE_URL];
        self.showCustomLoading = YES;
    } else if (modelDir.typeLocalWeb == WebLocalTypeExchangeList) {
        // 跳转积分兑换记录
        modelDir.typeTitle = WebTitleTypeNone;
        modelDir.typeShare = LocalShareTypeNone;
        modelDir.url = [NSString stringWithFormat:@"%@QWYH/web/integral_mall/html/records.html",H5_BASE_URL];
        self.showCustomLoading = YES;
    } else if (modelDir.typeLocalWeb == WebLocalTypeIntegralRull) {
        // 跳转积分规则
        modelDir.typeTitle = WebTitleTypeNone;
        modelDir.typeShare = LocalShareTypeNone;
        modelDir.url = [NSString stringWithFormat:@"%@QWYH/web/ruleDes/html/ruleDescription.html",H5_BASE_URL];
    }else if (modelDir.typeLocalWeb == WebLocalTypeMatchGame) {
        modelDir.typeTitle = WebTitleTypeOnlyShare;
        modelDir.typeShare = LocalShareTypeOuterLink;
        modelDir.url = [NSString stringWithFormat:@"%@QWAPP/activity/matchgame_v2/html/index.html",H5_DOMAIN_URL];

    }else if (modelDir.typeLocalWeb == WebLocalTypeBp){
        //血压
        modelDir.typeTitle = WebTitleTypeOnlyShare;
        modelDir.url = [NSString stringWithFormat:@"%@QWYH/web/self_check/html/bp.html?qwxzhide=1",H5_BASE_URL];
    }else if (modelDir.typeLocalWeb == WebLocalTypeHeight){
        
        modelDir.url = [NSString stringWithFormat:@"%@QWYH/web/self_check/html/height.html?qwxzhide=1",H5_BASE_URL];
    }else if (modelDir.typeLocalWeb == WebLocalTypeWeight){
        //体重指数
        modelDir.typeTitle = WebTitleTypeOnlyShare;
        modelDir.url = [NSString stringWithFormat:@"%@QWYH/web/self_check/html/weight.html?qwxzhide=1",H5_BASE_URL];
    }else if (modelDir.typeLocalWeb == WebLocalTypeTemperature){
        //体温
        modelDir.typeTitle = WebTitleTypeOnlyShare;
        modelDir.url = [NSString stringWithFormat:@"%@QWYH/web/self_check/html/temperature.html?qwxzhide=1",H5_BASE_URL];
    }else if (modelDir.typeLocalWeb == WebLocalTypeEdc){
        //预产期
        modelDir.typeTitle = WebTitleTypeOnlyShare;
        modelDir.url = [NSString stringWithFormat:@"%@QWYH/web/self_check/html/edc.html?qwxzhide=1",H5_BASE_URL];
    }else if (modelDir.typeLocalWeb == WebLocalTypeSelfCheck) {
        //检测指标
        modelDir.typeTitle = WebTitleTypeOnlyShare;
        modelDir.url = [NSString stringWithFormat:@"%@QWYH/web/self_check/html/health.html",H5_BASE_URL];
    }else if (modelDir.typeLocalWeb == WebLocalTypeToPurchaseDetail){
        //微商抢购
        modelDir.title = @"抢购详情";
        modelDir.url = [NSString stringWithFormat:@"%@QWYH/web/drug/html/quickBuy/yBizDrugDetail.html?id=%@&rushId=%@",H5_BASE_URL,modelDir.modelDrug.proDrugID,modelDir.modelDrug.activityID];
        self.showCustomLoading = YES;
    } else if (modelDir.typeLocalWeb == WebLocalTypeHealthCheckDetail) {
        //健康自测详情
        modelDir.title = modelDir.title;
        modelDir.url = [NSString stringWithFormat:@"%@QWYH/web/self_check/html/health_test.html?id=%@",H5_BASE_URL,modelDir.modelHealthCheck.checkTestId];
        modelDir.typeTitle = WebTitleTypeOnlyShare;
    } else if (modelDir.typeLocalWeb == WebLocalTypeToCircleRules) {
        //圈子任务规则
        modelDir.title = modelDir.title;
        modelDir.url = [NSString stringWithFormat:@"%@QWYH/web/ruleDes/html/ruleTeams.html",H5_BASE_URL];
        modelDir.typeTitle = WebTitleTypeNone;
    } else if (modelDir.typeLocalWeb == WebLocalTypeAnswerDetail) {
        [self setupNaviItem:WebTitleTypeWithFontOnly];
        [self setShowCustomLoading:YES];
        NSString *url = [NSString stringWithFormat:@"%@QWYH/web/discover/html/answers.html",H5_BASE_URL];
        modelDir.url = url;
    }
    self.modelLocal = modelDir;
    if (self.isOtherLinks == NO) {  // 非外链，使用本地的title
        self.navigationItem.title = modelDir.title;
    }
    // 记录H5页面类型
    self.pageType = modelDir.typeLocalWeb;
    self.typeShare = modelDir.typeShare;
    DebugLog(@"###### the load web url is %@",modelDir.url);
    [self setupNaviItem:modelDir.typeTitle];
    if (QWGLOBALMANAGER.currentNetWork != NotReachable) {
        [self initWebViewWithURL:[NSURL URLWithString:[modelDir.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    } else {
        [self showInfoView:kWarning12 image:@"网络信号icon"];
    }
    if (self.showConsultBtn) {
        [self.view bringSubviewToFront:self.avatar];
    }
}

- (void)backToRoot:(id)sender {
    
}

- (void)dealloc
{
    self.callBackDelegate = nil;
    self.modelDir = nil;
    self.webURL = nil;
    self.m_webView.delegate = nil;
    self.m_webView = nil;
    self.extShare = nil;
    DDLogVerbose(@"dealloc");
}

- (void)naviBackBotton
{
    if (self.showCustomeBack) {
        [self naviLeftBottonImage:[[UIImage imageNamed:@"icon_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] highlighted:[[UIImage imageNamed:@"icon_close_click"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] action:@selector(popVCAction:)];
    } else {
        [super naviBackBotton];
    }
}

// 设置H5跳转H5的接口
- (void)setWVWithModel:(WebDirectModel *)modelDir withType:(WebTitleType)enumType
{
    self.navigationItem.title = modelDir.title;
    
    
    if ([modelDir.pageType intValue] == WebPageToWebTypeHealthCheckBegin) {
        self.showCustomeBack = YES;
        [self naviBackBotton];
    } else {
        self.showCustomeBack = NO;
    }
    //cj 右侧小红点
    enumType =WebTitleTypeNone;
    NSString *strWebDirRoot = BASE_URL_V2;
    NSString *strWebLoad = @"";
    if (modelDir.url.length > 0) {
        modelDir.url = [modelDir.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if ([modelDir.pageType intValue] == WebPageTypeStaticPage) {
        self.showCustomLoading = NO;
    } else {
        self.showCustomLoading = YES;
    }
    if ([modelDir.pageType intValue] == WebPageToWebTypeSympton) {
        // 症状详情页面
        NSString *strWeb = @"";
        if ([modelDir.url hasPrefixWithHTTPDomain]) {
            strWeb = [NSString stringWithFormat:@"%@?id=%@&token=%@",modelDir.url,modelDir.params.id,QWGLOBALMANAGER.configure.userToken];
        } else {
            if (QWGLOBALMANAGER.configure.userToken.length > 0) {
                strWeb = [NSString stringWithFormat:@"%@%@?id=%@&token=%@",strWebDirRoot,modelDir.url,modelDir.params.id,QWGLOBALMANAGER.configure.userToken];
            } else {
                strWeb = [NSString stringWithFormat:@"%@%@?id=%@&token=",strWebDirRoot,modelDir.url,modelDir.params.id];
            }
        }
        strWebLoad = strWeb;
        enumType = WebTitleTypeWithFontOnly;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeDisease) {
        // 疾病详情页面
        NSString *strWeb = @"";
        if ([modelDir.url hasPrefixWithHTTPDomain]) {
            strWeb = [NSString stringWithFormat:@"%@?id=%@",modelDir.url,modelDir.params.id];
        } else {
            strWeb = [NSString stringWithFormat:@"%@%@?id=%@",strWebDirRoot,modelDir.url,modelDir.params.id];
        }
        strWebLoad = strWeb;
//        enumType = WebTitleTypeWithFontAndMsgWithShare;
        enumType = WebTitleTypeWithFontOnly;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeSlowDiseaseCouponList){
        // 慢病优惠券列表页面
        if ([modelDir.url hasPrefixWithHTTPDomain]) {
            strWebLoad = [NSString stringWithFormat:@"%@?token=%@",modelDir.url,QWGLOBALMANAGER.configure.userToken];
        } else {
            strWebLoad = [NSString stringWithFormat:@"%@%@?token=%@",strWebDirRoot,modelDir.url,QWGLOBALMANAGER.configure.userToken];
        }
        enumType = WebTitleTypeNone;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeSlowDiseaseGuide){
        // 慢病引导页
        if ([modelDir.url hasPrefixWithHTTPDomain]) {
            strWebLoad = modelDir.url;
        } else {
            strWebLoad = [NSString stringWithFormat:@"%@%@",strWebDirRoot,modelDir.url];
        }
        
        enumType = WebTitleTypeWithJump;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeSlowSubscribe){
        // 慢病订阅列表
        if ([modelDir.url hasPrefixWithHTTPDomain]) {
            strWebLoad = [NSString stringWithFormat:@"%@?token=%@",modelDir.url,QWGLOBALMANAGER.configure.userToken];
        } else {
            strWebLoad = [NSString stringWithFormat:@"%@%@?token=%@",strWebDirRoot,modelDir.url,QWGLOBALMANAGER.configure.userToken];
        }
        
        enumType = WebTitleTypeNone;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeSlowDiseaseDetail){
        // 慢病详情页面
        NSString *strWeb = @"";
        if ([modelDir.url hasPrefixWithHTTPDomain]) {
            strWeb = [NSString stringWithFormat:@"%@?attentionId=%@&drugGuideId=%@&token=%@",modelDir.url,modelDir.params.attentionId,modelDir.params.drugGuideId,QWGLOBALMANAGER.configure.userToken];
        } else {
            strWeb = [NSString stringWithFormat:@"%@%@?attentionId=%@&drugGuideId=%@&token=%@",strWebDirRoot,modelDir.url,modelDir.params.attentionId,modelDir.params.drugGuideId,QWGLOBALMANAGER.configure.userToken];
        }
        strWebLoad = strWeb;
        self.navigationItem.title = modelDir.params.title;
        enumType = WebTitleTypeNone;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeTopicDetail){
        // 专题详情页面
        NSString *strToken = @"";
        if (QWGLOBALMANAGER.configure.userToken.length > 0) {
            strToken = QWGLOBALMANAGER.configure.userToken;
        }
        DDLogVerbose(@"model DIR is %@",modelDir);
        if ([modelDir.url hasPrefixWithHTTPDomain]) {
            strWebLoad = [NSString stringWithFormat:@"%@&id=%@&token=%@",modelDir.url,modelDir.params.id,strToken];;
        } else {
            strWebLoad = [NSString stringWithFormat:@"%@%@&id=%@&token=%@",strWebDirRoot,modelDir.url,modelDir.params.id,strToken];
        }
        
        enumType = WebTitleTypeOnlyShare;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeSlowProductList){
        // 慢病优惠券列表
        NSString *strToken = @"";
        if (QWGLOBALMANAGER.configure.userToken.length > 0) {
            strToken = QWGLOBALMANAGER.configure.userToken;
        }
        
        if ([modelDir.url hasPrefixWithHTTPDomain]) {
            strWebLoad = [NSString stringWithFormat:@"%@?token=%@",modelDir.url,strToken];
        } else {
            strWebLoad = [NSString stringWithFormat:@"%@%@?token=%@",strWebDirRoot,modelDir.url,strToken];
        }
        
        enumType = WebTitleTypeNone;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeInfo) {
        // 资讯详情页面
        NSString *strWeb = [modelDir.url transStrWithDomain:H5_BASE_URL];
        
//        if (QWGLOBALMANAGER.configure.userToken.length == 0) {
//            strWeb = [NSString stringWithFormat:@"%@%@?id=%@&token=&from=0",strWebDirRoot,modelDir.url,modelDir.params.id];
//        } else {
//            strWeb = [NSString stringWithFormat:@"%@%@?id=%@&token=%@&from=0",strWebDirRoot,modelDir.url,modelDir.params.id,QWGLOBALMANAGER.configure.userToken];
//        }
        strWebLoad = strWeb;
        enumType = WebTitleTypeWithFontOnly;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeCouponDetail) {
        // 优惠细则页面
        NSString *strWeb = @"";
        if ([modelDir.url hasPrefixWithHTTPDomain]) {
            strWeb = [NSString stringWithFormat:@"%@?type=%@&id=%@",modelDir.url,modelDir.params.type,modelDir.params.id];
        } else {
            strWeb = [NSString stringWithFormat:@"%@%@?type=%@&id=%@",strWebDirRoot,modelDir.url,modelDir.params.type,modelDir.params.id];
        }
        strWebLoad = strWeb;
        enumType = WebTitleTypeNone;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeMedicine) {
        // 药品列表页面
        NSString *strToken = @"";
        if (QWGLOBALMANAGER.configure.userToken.length > 0) {
            strToken = QWGLOBALMANAGER.configure.userToken;
        }
        if (modelDir.params.promotionId == nil) {
            modelDir.params.promotionId = @"";
        }
        if (modelDir.params.mktgId == nil) {
            modelDir.params.mktgId = @"";
        }
        NSString *strWeb = @"";
        if ([modelDir.url hasPrefixWithHTTPDomain]) {
            strWeb = [NSString stringWithFormat:@"%@?id=%@&promotionId=%@&mktgId=%@&token=%@",modelDir.url,modelDir.params.id,modelDir.params.promotionId,modelDir.params.mktgId,strToken];
        } else {
            strWeb = [NSString stringWithFormat:@"%@%@?id=%@&promotionId=%@&mktgId=%@&token=%@",strWebDirRoot,modelDir.url,modelDir.params.id,modelDir.params.promotionId,modelDir.params.mktgId,strToken];
        }
        strWebLoad = strWeb;
        enumType = WebTitleTypeOnlyShare;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeHealthCheckBegin) {
        // 开始健康评测页面
        NSString *strWeb = @"";
        if ([modelDir.url hasPrefixWithHTTPDomain]) {
            strWeb = modelDir.url;
        } else {
            strWeb = [NSString stringWithFormat:@"%@%@",H5_BASE_URL,modelDir.url];
        }
        strWebLoad = strWeb;
        //cj 右侧小红点
        enumType = WebTitleTypeOnlyShare;
        [QWGLOBALMANAGER statisticsEventId:@"自查_健康评测_列表点击" withLable:@"健康自测" withParams:nil];
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeProductInstrumets) {
        // 商品说明书
        NSString *strWeb = @"";
        if ([modelDir.url hasPrefixWithHTTPDomain]) {
            strWeb = modelDir.url;
        } else {
            strWeb = [NSString stringWithFormat:@"%@%@",H5_BASE_URL,modelDir.url];
        }
        strWebLoad = strWeb;
        enumType =WebTitleTypeWithFontOnly;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeSpecialDetail) {
    } else if ([modelDir.pageType intValue] == WebPageTypeInfoCommentList) {
        // 资讯评论列表
//        NSString *strWeb = [NSString stringWithFormat:@"%@%@",H5_BASE_URL,modelDir.url];
        
        strWebLoad = [modelDir.url transStrWithDomain:H5_BASE_URL];
        enumType = WebTitleTypeNone;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeProDetail){
        //兑换商品详情
        strWebLoad = [modelDir.url transStrWithDomain:H5_BASE_URL];
        enumType = WebTitleTypeOnlyShare;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeSuccessToList || [modelDir.pageType intValue] == WebPageToWebTypeExchangeList){
        //兑换记录
        strWebLoad = [modelDir.url transStrWithDomain:H5_BASE_URL];
        enumType = WebTitleTypeNone;
    }else if ([modelDir.pageType intValue] == WebPageToWebTypeAddress){
        //兑换订单，填写地址
        strWebLoad = [modelDir.url transStrWithDomain:H5_BASE_URL];
        enumType = WebTitleTypeNone;
    }else if ([modelDir.pageType intValue] == WebPageToWebTypeExchangeSuccess){
        //兑换成功
        strWebLoad = [modelDir.url transStrWithDomain:H5_BASE_URL];
        enumType = WebTitleTypeNone;
    }else if ([modelDir.pageType intValue] == WebPageToWebTypeExchangeDetail){
        //兑换详情
        strWebLoad = [modelDir.url transStrWithDomain:H5_BASE_URL];
        enumType = WebTitleTypeNone;
    } else if ([modelDir.pageType intValue] == WebPageTypeMedExa) {
        strWebLoad = [modelDir.url transStrWithDomain:H5_BASE_URL];
        enumType = WebTitleTypeOnlyShare;
    } else if ([modelDir.pageType intValue] == WebPageTypeOuterLink) {
        // H5 跳转 H5的外链类型
        //外链的时候已经有http的头了
        if (([modelDir.url hasPrefix:@"http://"])||([modelDir.url hasPrefix:@"https://"])) {
            strWebLoad = modelDir.url;
        }else{
            NSString *strWeb = [NSString stringWithFormat:@"%@%@",strWebDirRoot,modelDir.url];
            strWebLoad = strWeb;
        }
        self.modelLocal = [WebDirectLocalModel new];
        self.modelLocal.typeLocalWeb = WebLocalTypeOuterLink;
        self.typeShare = LocalShareTypeOuterLink;
    } else {
        //外链的时候已经有http的头了
        if (([modelDir.url hasPrefix:@"http://"])||([modelDir.url hasPrefix:@"https://"])) {
            strWebLoad = modelDir.url;
        }else{
            NSString *strWeb = [NSString stringWithFormat:@"%@%@",strWebDirRoot,modelDir.url];
            strWebLoad = strWeb;
        }
    }
    
    // 设置分享按钮
    [self setupNaviItem:enumType];
    
    DDLogVerbose(@"###### the load web url is %@",strWebLoad);
    if ([self.modelDir.progressbar isKindOfClass:[NSString class]]) {
        if ([self.modelDir.progressbar isEqualToString:@"0"]) {
            self.neednotShowloading = YES;
        }
    } else {
        if (self.modelDir.progressbar == 0) {
            self.neednotShowloading = YES;
        }
    }
    if (QWGLOBALMANAGER.currentNetWork != NotReachable) {
        [self initWebViewWithURL:[NSURL URLWithString:strWebLoad]];
    } else {
        [self showInfoView:kWarning12 image:@"网络信号icon"];
    }
    
    if (!self.neednotShowloading) {
        self.progressBarLoading.hidden = NO;
        [self.view bringSubviewToFront:self.progressBarLoading];
    }
    if (self.showConsultBtn) {
        [self.view bringSubviewToFront:self.avatar];
    }
}


- (void)setWVWithURL:(NSString *)strURL title:(NSString *)strTitle withType:(WebTitleType)enumType;
{
    if (self.isOtherLinks == NO) {
        self.navigationItem.title = strTitle;
    }
    
    DDLogVerbose(@"###### the load web url is %@",strURL);
    self.strWebUrl = strURL;
    [self setupNaviItem:enumType];
    [self initWebViewWithURL:[NSURL URLWithString:strURL]];
    
    if (self.showConsultBtn) {
        [self.view bringSubviewToFront:self.avatar];
    }
}

- (void)setWVWithURL:(NSString *)strURL title:(NSString *)strTitle withType:(WebTitleType)enumType withShareType:(LocalShareType)enumShareType
{
    self.navigationItem.title = strTitle;
    self.typeShare = enumShareType;
    DDLogVerbose(@"###### the load web url is %@",strURL);
    self.strWebUrl = strURL;
    [self setupNaviItem:enumType];
    
    [self initWebViewWithURL:[NSURL URLWithString:strURL]];
    if (self.showConsultBtn) {
        [self.view bringSubviewToFront:self.avatar];
    }
    [self.view bringSubviewToFront:self.progressBarLoading];
}

//- (void)actionCommentRefresh        // 刷新专题评论列表
//{
//    if (self.extShare) {
//        [self.extShare runExtWithCallBackId:CallbackTypeAreaComment];
//    }
//}
//
//- (void)actionCouponTitle   // 通知药品详情H5页面立即领取按钮置灰逻辑
//{
//    if (self.extShare) {
//        [self.extShare runExtWithCallBackId:CallbackTypeMedicineBack];
//    }
//}

- (void)showAlertWithMessage:(NSString *)strMsg
{
    [SVProgressHUD showSuccessWithStatus:strMsg duration:0.8f];
    //    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:strMsg message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
    //    [alertV show];
}

- (void)actionHideShareBtn
{
    self.navigationItem.rightBarButtonItems = nil;
    
}
- (void)popCurVC
{
    [self popVCAction:nil];
}

- (void)popToRoot
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    UITabBarController *vcTab = APPDelegate.currentTabBar;
    vcTab.selectedIndex = 0;
    UINavigationController *vcNavi = (UINavigationController *)vcTab.selectedViewController;
    [vcNavi popToRootViewControllerAnimated:YES];
}

// MARK: 分享
// 点击分享按钮
- (void)shareClick
{
    if (self.typeShare == LocalShareTypeOuterLink) {
        
        ShareContentModel *modelShare = [ShareContentModel new];
        NSString *strTitle = [self.m_webView stringByEvaluatingJavaScriptFromString:@"var a=document.getElementById(\"data-title\"); var str = a.getAttribute(\"data\"); decodeURIComponent(str)"];
        NSString *strURL = [self.m_webView stringByEvaluatingJavaScriptFromString:@"var a=document.getElementById(\"data-url\"); var str = a.getAttribute(\"data\"); decodeURIComponent(str)"];
        NSString *strContent = [self.m_webView stringByEvaluatingJavaScriptFromString:@"var a=document.getElementById(\"data-content\"); var str = a.getAttribute(\"data\");decodeURIComponent(str)"];
        NSString *strImgURL = [self.m_webView stringByEvaluatingJavaScriptFromString:@"var a=document.getElementById(\"data-imgUrl\"); var str = a.getAttribute(\"data\");decodeURIComponent(str)"];
       
        modelShare.typeShare = ShareTypeOuterLink;
        modelShare.title = strTitle;
        modelShare.content = strContent;
        modelShare.shareLink = strURL;
        modelShare.imgURL = strImgURL;
        [self popUpShareView:modelShare];
        return;
    }
    if (self.extShare != nil) {
        if (self.modelDir == nil) {
            // 从HTML链接进入的页面
            if (self.typeShare == LocalShareTypeArea) {
                // 专区分享
                [self.extShare runExtWithCallBackId:CallbackTypeShareArea];
            } else if (self.typeShare == LocalShareTypeTopic) {
                // 专题分享
                [self.extShare runExtWithCallBackId:CallbackTypeShareTopic];
            } else if (self.typeShare == LocalShareTypeMedicine) {
                [self.extShare runExtWithCallBackId:CallbackTypeMedicineShare];
            } else if (self.typeShare == LocalShareTypeInfo) {
                [self.extShare runExtWithCallBackId:CallbackTypeShareInfo];
            } else if (self.typeShare == LocalShareTypeDiseaseTypeBC) {
                [self.extShare runExtWithCallBackId:CallbackTypeShareDisease];
            } else {
                [self.extShare runExtWithCallBackId:CallbackTypeMedicineShare];
            }
        } else {
            // 从 H5页面内部进入的
            if ([self.modelDir.pageType intValue] == WebPageToWebTypeTopicDetail) {
                // 获取专题的分享内容
                [self.extShare runExtWithCallBackId:CallbackTypeShareTopic];
            } else if ([self.modelDir.pageType intValue] == WebPageToWebTypeDisease) {
                // 获取可能疾病的分享内容
                [self.extShare runExtWithCallBackId:CallbackTypeShareDisease];
            } else if ([self.modelDir.pageType intValue] == WebPageToWebTypeSympton) {
                
            } else if ([self.modelDir.pageType intValue] == WebPageToWebTypeSlowSubscribe) {
                
            } else if ([self.modelDir.pageType intValue] == WebPageToWebTypeInfo) {
                // 获取资讯的分享内容
                [self.extShare runExtWithCallBackId:CallbackTypeShareInfo];
            }
            else {
                // 获取药品详情的分享内容
                [self.extShare runExtWithCallBackId:CallbackTypeMedicineShare];
            }
        }
    }
}

- (void)actionShowShare
{
    [self setupNaviItem:WebTitleTypeOnlyShare];
}

- (void)handleViewControllerStack
{
    NSMutableArray *viewController = self.navigationController.viewControllers;
    
    
}

//跳转到支付宝界面
- (void)actionWithAliPayInfo:(NSString *)orderInfo withObjId:(NSString*)objId
{
    [QWGLOBALMANAGER aliPayOrder:orderInfo withObjId:(NSString*)objId];
}

//跳转到微信支付界面
- (void)actionWithWetChatPayInfo:(NSString *)orderInfo withObjId:(NSString*)objId
{
    [QWGLOBALMANAGER weChatPayOrder:orderInfo withObjId:(NSString*)objId];
}

// 分享功能
- (void)actionShare:(WebPluginModel *)modelPlugin
{
    
    ShareContentModel *modelShare = [[ShareContentModel alloc] init];
    NSString *strTitle = modelPlugin.params.title;
    NSString *imgURL = @"";
    NSString *shareURL = @"";
    if (modelPlugin.params.img_url.length > 0) {
        if ([modelPlugin.params.img_url hasPrefix:@"http"]) {
            imgURL = [NSString stringWithFormat:@"%@",modelPlugin.params.img_url];
        } else {
            imgURL = [NSString stringWithFormat:@"%@%@",BASE_URL_V2,modelPlugin.params.img_url];
        }
    }
    modelShare.imgURL = imgURL;
    modelShare.title = strTitle;
    if (modelPlugin.url.length > 0) {
        if ([modelPlugin.url hasPrefix:@"http"]) {
            shareURL = [NSString stringWithFormat:@"%@",modelPlugin.url];
        } else {
            shareURL = [NSString stringWithFormat:@"%@%@",BASE_URL_V2,modelPlugin.url];
        }
    }
    modelShare.shareLink = shareURL;
    modelShare.content = modelPlugin.params.content;
    // 根据H5返回的json，转换出相应的分享数据
    if ([modelPlugin.params.shareType intValue] == WebPageShareTypeDisease) {
        // 分享疾病的内容
        modelShare.typeShare = ShareTypeDisease;
    } else if ([modelPlugin.params.shareType intValue] == WebPageShareTypeMedicine) {
        // 分享药品的内容
        if (modelPlugin.params.objId.length > 0) {
            NSArray *arrIDs = [modelPlugin.params.objId componentsSeparatedByString:SeparateStr];
            if (arrIDs.count > 1) {
                modelShare.typeShare = ShareTypeMedicineWithPromotion;
                modelShare.shareID = modelPlugin.params.objId;
                ShareSaveLogModel *modelSaveLog = [ShareSaveLogModel new];
                MapInfoModel *mapInfoModel = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
                if(mapInfoModel) {
                    modelSaveLog.city = mapInfoModel.city;
                    modelSaveLog.province = mapInfoModel.province;
                }else{
                    modelSaveLog.city = @"苏州市";
                    modelSaveLog.province = @"江苏省";
                }
                modelSaveLog.shareObj = @"2";
                modelSaveLog.shareObjId = arrIDs[1];
                
                modelShare.modelSavelog = modelSaveLog;
                
            } else {
                modelShare.typeShare = ShareTypeMedicine;
            }
        } else {
            modelShare.typeShare = ShareTypeMedicine;
        }
    } else if ([modelPlugin.params.shareType intValue] == WebPageShareTypeTopic) {
        // 专题分享
        modelShare.typeShare = ShareTypeSubject;
    } else if ([modelPlugin.params.shareType intValue] == WebPageShareTypeArea) {
        // 专区分享
        modelShare.title = [NSString stringWithFormat:@"%@%@",self.navigationItem.title,modelShare.title];
        modelShare.typeShare = ShareTypeDivision;
    } else if ([modelPlugin.params.shareType intValue] == WebPageShareTypeSympton) {
        // 分享症状
        modelShare.typeShare = ShareTypeSymptom;
    } else if ([modelPlugin.params.shareType intValue] == WebPageShareTypeInfo) {
        // 资讯的分享内容
        modelShare.typeShare = ShareTypeInfo;
    } else if ([modelPlugin.params.shareType intValue] == WebPageShareTypeOuterLink) {
        modelShare.typeShare = ShareTypeOuterLink;
    }else if ([modelPlugin.params.shareType intValue] == WebPageShareTypeIntegralMallProDetail){
        modelShare.typeShare = ShareTypeIntegralProDetail;
    }else if ([modelPlugin.params.shareType intValue] == WebPageShareTypeHealthCheckList) {
        modelShare.typeShare = ShareTypeHealthMeasurement;
        ShareSaveLogModel *modelSavelog = [ShareSaveLogModel new];
        MapInfoModel *mapInfoModel = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
        if(mapInfoModel) {
            modelSavelog.city = mapInfoModel.city;
            modelSavelog.province = mapInfoModel.province;
        }else{
            modelSavelog.city = @"苏州市";
            modelSavelog.province = @"江苏省";
        }
        modelSavelog.shareObj = @"5";
        modelSavelog.shareObjId = @"";
        modelShare.modelSavelog = modelSavelog;
    } else if ([modelPlugin.params.shareType intValue] == WebPageShareTypeHealthCheckDetail) {
        modelShare.typeShare = ShareTypeHealthCheckDetail;
        
        ShareSaveLogModel *modelSavelog = [ShareSaveLogModel new];
        MapInfoModel *mapInfoModel = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
        if(mapInfoModel) {
            modelSavelog.city = mapInfoModel.city;
            modelSavelog.province = mapInfoModel.province;
        }else{
            modelSavelog.city = @"苏州市";
            modelSavelog.province = @"江苏省";
        }
        modelSavelog.shareObj = @"5";
        modelSavelog.shareObjId = modelPlugin.params.objId;
        modelShare.modelSavelog = modelSavelog;
        [QWGLOBALMANAGER statisticsEventId:@"自查_健康评测_邀请好友" withLable:@"健康评测" withParams:nil];
    } else if ([modelPlugin.params.shareType intValue] == WebPageShareTypeActivityList) {
        // 活动列表分享
        modelShare.typeShare = ShareTypeActivityList;
    } else if ([modelPlugin.params.shareType intValue] == WebPageShareTypeRollCard) {
        // 翻牌子分享
        modelShare.typeShare = ShareTypeFanPai;
    }
    
    
    
    [self popUpShareView:modelShare];
}
- (void)actionPhoneWithNumber:(NSString *)phoneNum
{
    if (phoneNum.length > 0) {
        self.phoneNumber = phoneNum;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否打电话" message:phoneNum delegate:self
                                              cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = AlertViewTypePhoneNum;
        [alert show];
        
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"电话号码为空" duration:DURATION_SHORT];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == AlertViewTypePhoneNum) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.phoneNumber]]];
        }
    }else if (alertView.tag == AlertViewTypePay) {
        if (buttonIndex == 1) {//放弃付款，但是不是中途放弃付款
            [self jumpOrderSome:@""];
        }
    }
}

- (void)jumpAction
{
    if (self.extShare) {
        [self.extShare runExtWithCallBackId:CallbackTypeDiseaseJump];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)backToFreshList     // 添加慢病专区返回
//{
//    if (self.extShare != nil) {
//        [self.extShare runExtWithCallBackId:CallbackTypeSlowDiseaseBack];
//    }
//}
//
//- (void)backToFreshTitle            // 慢病订阅资讯返回刷新new字段
//{
//    if (self.extShare != nil) {
//        [self.extShare runExtWithCallBackId:CallbackTypeSlowDiseaseTitle];
//    }
//}

//- (void)backFromSlowGuide           // 通知H5 跳过慢病引导页
//{
//    if (self.extShare != nil) {
//        [self.extShare runExtWithCallBackId:CallbackTypeSlowDiseaseGuideRefresh];
//    }
//}

//- (void)backToMyCollectTopic        // 通知H5专题专刊列表更新
//{
//    if (self.extShare != nil) {
//        [self.extShare runExtWithCallBackId:CallbackTypeMyCollectTopicRefresh];
//    }
//}

// 统一通知H5的JS调用方法
- (void)runCallbackWithPageType:(NSString *)strType
{
    DDLogVerbose(@"###### the call back page type is %@",strType);
    if (self.extShare != nil) {
        [self.extShare runExtWithCallBackPageType:strType];
    }
}

- (void)runCallbackWithTypeID:(CallbackType)typeCallback
{
    DDLogVerbose(@"###### the call back page type is %d",typeCallback);
    [self actionInformH5:typeCallback];
}

- (void)actionInformH5:(CallbackType)typeCallback
{
    if (self.extShare != nil) {
        [self.extShare runExtWithCallBackId:typeCallback];
    }
}

- (void)returnIndexOne
{
    self.indexView = [ReturnIndexView sharedManagerWithImage:@[@"ic_img_notice",@"icon home.PNG"] title:@[@"消息",@"首页"] passValue:self.passNumber];
    self.indexView.delegate = self;
    [self.indexView show];
}

- (void)returnIndexTwo
{
    self.indexView = [ReturnIndexView sharedManagerWithImage:@[@"ic_img_notice",@"icon home.PNG",@"icon_share_new.PNG"] title:@[@"消息",@"首页",@"分享"] passValue:self.passNumber];
    self.indexView.delegate = self;
    [self.indexView show];
}

- (void)RetunIndexView:(ReturnIndexView *)ReturnIndexView didSelectedIndex:(NSIndexPath *)indexPath
{
    [self.indexView hide];
    if (indexPath.row == 0)
    {
        if(!QWGLOBALMANAGER.loginStatus) {
            LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
            loginViewController.isPresentType = YES;
            [self presentViewController:navgationController animated:YES completion:NULL];
            return;
        }
        
        MessageBoxListViewController *vcMsgBoxList = [[UIStoryboard storyboardWithName:@"MessageBoxListViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MessageBoxListViewController"];
        vcMsgBoxList.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vcMsgBoxList animated:YES];
        
    }else if (indexPath.row == 1)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self performSelector:@selector(delayPopToHome) withObject:nil afterDelay:0.01];
    }else if (indexPath.row == 2)
    {
        [self shareClick];
    }
}

- (void)popVCAction:(id)sender
{
    
    if (self.modelLocal.typeLocalWeb == WebLocalTypeToPayOrder) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"您是否狠心放弃付款" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = AlertViewTypePay;
        [alert show];
        return;
    }
    
    
    if ([self.modelDir.pageType intValue] == WebPageToWebTypeSlowSubscribe) {
        // 添加慢病专区返回
        if ([self.callBackDelegate respondsToSelector:@selector(runCallbackWithTypeID:)]) {
            [self.callBackDelegate runCallbackWithTypeID:CallbackTypeSlowDiseaseBack];
        }
    } else if ([self.modelDir.pageType intValue] == WebPageToWebTypeSlowDiseaseDetail) {
        // 慢病订阅资讯返回刷新new字段
        if ([self.callBackDelegate respondsToSelector:@selector(runCallbackWithTypeID:)]) {
            [self.callBackDelegate runCallbackWithTypeID:CallbackTypeSlowDiseaseTitle];
        }
    } else if ([self.modelDir.pageType intValue] == WebPageToWebTypeSlowDiseaseGuide) {
        // 通知H5 跳过慢病引导页
        if ([self.callBackDelegate respondsToSelector:@selector(runCallbackWithTypeID:)]) {
            [self.callBackDelegate runCallbackWithTypeID:CallbackTypeSlowDiseaseGuideRefresh];
        }
    } else if ([self.modelDir.pageType intValue] == WebPageToWebTypeSlowDiseaseCouponList) {
        // 通知H5 跳过慢病引导页
        if ([self.callBackDelegate respondsToSelector:@selector(runCallbackWithTypeID:)]) {
            [self.callBackDelegate runCallbackWithTypeID:CallbackTypeSlowDiseaseGuideRefresh];
        }
    } else if ([self.modelDir.pageType intValue] == WebPageToWebTypeTopicDetail) {
        // 通知H5专题专刊列表更新
        if ([self.callBackDelegate respondsToSelector:@selector(runCallbackWithTypeID:)]) {
            [self.callBackDelegate runCallbackWithTypeID:CallbackTypeMyCollectTopicRefresh];
        }
    } else if ([self.modelDir.pageType intValue] == WebPageTypeOuterLink) {
        // 通知H5外链更新
        if ([self.callBackDelegate respondsToSelector:@selector(runCallbackWithPageType:)]) {
            [self.callBackDelegate runCallbackWithPageType:[NSString stringWithFormat:@"%@",self.modelDir.pageType]];
        }
    }
    else {
        if ([self.callBackDelegate respondsToSelector:@selector(runCallbackWithPageType:)]) {
            [self.callBackDelegate runCallbackWithPageType:[NSString stringWithFormat:@"%@",self.modelDir.pageType]];
        }
    }
   
    
    // 统计
    if (self.modelLocal.typeLocalWeb == WebPageTypeMedicinePharMore) {
        [QWGLOBALMANAGER statisticsEventId:@"x_ypxq_fh" withLable:@"药品详情" withParams:nil];
    }else if (self.modelLocal.typeLocalWeb == WebPageToWebTypeSympton) {
        [QWGLOBALMANAGER statisticsEventId:@"x_zz_3_fh" withLable:@"症状" withParams:nil];
        [QWGLOBALMANAGER statisticsEventId:@"x_zzxq_fh" withLable:@"症状详情" withParams:nil];
    }else if (self.modelLocal.typeLocalWeb == WebPageToWebTypeExchangeSuccess) {
        [QWGLOBALMANAGER statisticsEventId:@"x_jfsc_spxq_dhcg" withLable:@"积分商城" withParams:nil];
    }else if (self.modelLocal.typeLocalWeb == WebPageTypeIntegralIndex){
        [QWGLOBALMANAGER statisticsEventId:@"x_jfsc_fh" withLable:@"积分商城" withParams:nil];
    }else if (self.modelLocal.typeLocalWeb == WebPageToWebTypeExchangeList){
        [QWGLOBALMANAGER statisticsEventId:@"x_dhjl_fh" withLable:@"积分商城" withParams:nil];
    }else if (self.modelLocal.typeLocalWeb == WebPageToWebTypeAddress){
        [QWGLOBALMANAGER statisticsEventId:@"x_jfsc_yj_fh" withLable:@"积分商城" withParams:nil];
    }
    if (self.blockInfoList) {
        self.blockInfoList(YES);
    }
    if ([self.callBackDelegate respondsToSelector:@selector(needUpdateInfoList:)]) {
        // 刷新本地资讯列表
        [self.callBackDelegate needUpdateInfoList:YES];
    }
    // 清空缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        
        if([[cookie domain] isEqualToString:BASE_URL_V2
            ]) {
            
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
        
        if([[cookie domain] isEqualToString:H5_DOMAIN_URL]) {
            
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    self.progressBarLoading = nil;
    if (self.myTimer) {
        [self.myTimer invalidate];
        self.myTimer = nil;
    }
    if (self.modelLocal.typeLocalWeb == WebLocalTypeIMMerchant) {   // 是否是我是商家页面
        if ([self.navigationController respondsToSelector:@selector(popViewControllerAnimated:)]) {
            if (self.navigationController.viewControllers.count>1)
                [self.navigationController popViewControllerAnimated:YES];
            else if ([self.navigationController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    //
                }];
            }
            
        }
        else if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }
    }else if (self.pageType == WebPageToWebTypeExchangeSuccess || self.pageType == WebPageToWebTypeExchangeList || self.pageType == WebPageToWebTypeSuccessToList){         //是否是兑换成功页面
        WebDirectViewController *vcTemp = nil;
        for (WebDirectViewController *vc in self.navigationController.viewControllers) {
            
            if ([vc respondsToSelector:@selector(pageType)]) {
                DDLogVerbose(@"%d",vc.pageType);
                if (vc.pageType == WebPageTypeIntegralIndex ) {
                    vcTemp = vc;
                    break;
                }
            }
        }
        if (vcTemp != nil) {
            [QWGLOBALMANAGER postNotif:NotifRefreshCurH5Page data:[NSString stringWithFormat:@"%d",self.pageType] object:nil];
            [self.navigationController popToViewController:vcTemp animated:NO];
        }else {
            [super popVCAction:sender];
        }
    }else if (self.pageType == WebPageToWebTypeProDetail){
        [QWGLOBALMANAGER postNotif:NotifRefreshCurH5Page data:[NSString stringWithFormat:@"%d",self.pageType] object:nil];
        [super popVCAction:sender];
    }
    else{
        [super popVCAction:sender];
    }
    
}


// MARK: H5跳转原生页面

/**
 *  H5跳转原生页面
 *
 *  @param modelDir 跳转的Model
 */
- (void)jumpToLocalVC:(WebDirectModel *)modelDir
{
    UITabBarController *vcTab = APPDelegate.currentTabBar;
    UINavigationController *vcNavi = (UINavigationController *)vcTab.selectedViewController;
    if ([modelDir.pageType intValue] == WebPageTypeDisease)
    {
        // direct to disease detail view controller
        // 跳转至本地疾病详情页面
        
        CommonDiseaseDetailViewController *commonDiseaseDetail = [[CommonDiseaseDetailViewController alloc] init];
        commonDiseaseDetail.diseaseId = [NSString stringWithFormat:@"%@",modelDir.params.id];
        commonDiseaseDetail.title = modelDir.params.diseaseName;
        commonDiseaseDetail.hidesBottomBarWhenPushed = YES;
        [vcNavi pushViewController:commonDiseaseDetail animated:YES];
    } else if ([modelDir.pageType intValue] == WebPageTypeFamiliarQuestion) {
        // 大家都在问
        QuestionListViewController *familiarVC = [[QuestionListViewController alloc] init];
        //专区的id
        familiarVC.strModuleId = modelDir.params.id;
        familiarVC.hidesBottomBarWhenPushed = YES;
        [vcNavi pushViewController:familiarVC animated:YES];
    } else if ([modelDir.pageType intValue] == WebPageTypeMedicineList) {
        // 药品列表
        DiseaseMedicineListViewController* vc = [[DiseaseMedicineListViewController alloc] init];
        vc.title = modelDir.title;
        vc.params = @{@"diseaseId":modelDir.params.id, @"formulaId":modelDir.params.zufangId};
        [vcNavi pushViewController:vc animated:YES];
        
    } else if ([modelDir.pageType intValue] == WebPageTypeGetCoupon) {
        PickPromotionSuccessViewController *vcSuccess = [[PickPromotionSuccessViewController alloc] initWithNibName:@"PickPromotionSuccessViewController" bundle:nil];
        vcSuccess.proDrugId = modelDir.params.id;
        vcSuccess.extCallback = ^(BOOL success){
            // 药品详情H5页面立即领取按钮置灰逻辑
            [self actionInformH5:CallbackTypeMedicineBack];
        };
        [vcNavi pushViewController:vcSuccess animated:YES];
    } else if ([modelDir.pageType intValue] == WebPageTypeDiseaseCoupon) {
        // 慢病优惠券
        CenterCouponDetailViewController *vcDetail =[[CenterCouponDetailViewController alloc] initWithNibName:@"CenterCouponDetailViewController" bundle:nil];
        if(!StrIsEmpty(modelDir.params.mktgId)){
            //传递会员营销Id
            vcDetail.mktgId = modelDir.params.mktgId;
        }
        vcDetail.couponId=modelDir.params.id;
        
        
        
        vcDetail.hidesBottomBarWhenPushed = YES;
        vcDetail.extCallback = ^(BOOL success) {
            // 药品详情H5页面立即领取按钮置灰逻辑
            [self actionInformH5:CallbackTypeMedicineBack];
        };
        [vcNavi pushViewController:vcDetail animated:YES];
        
    } else if ([modelDir.pageType intValue] == WebPageTypeFamilyMedicine) {
        FamliyMedcineViewController *famliyMedcineViewController = [[UIStoryboard storyboardWithName:@"FamilyMedicineListViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FamliyMedcineViewController"];
        famliyMedcineViewController.hidesBottomBarWhenPushed = YES;
        [vcNavi pushViewController:famliyMedcineViewController animated:YES];
    } else if ([modelDir.pageType intValue] == WebPagePharGetMore) {
        // 跳转查看更多药房
        MoreConsultViewController *moreConsult = [[MoreConsultViewController alloc]init];
        moreConsult.consultType = Enum_Consult_ComeFromUserCenterPromotion;
        MyDrugVo *modelDrug = [[MyDrugVo alloc] init];
        modelDrug.pid = modelDir.params.pid;
        moreConsult.pid = modelDir.params.pid;
        [vcNavi pushViewController:moreConsult animated:YES];
        
    } else if ([modelDir.pageType intValue] == WebPageTypeChatView) {
        // 跳转聊天页面
        ChatViewController *consultViewController = [[UIStoryboard storyboardWithName:@"ChatViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ChatViewController"];
        
        consultViewController.branchId=modelDir.params.branchId;
        consultViewController.branchName = modelDir.params.consultTitle;
        DrugDetailModel *drugModel = [[DrugDetailModel alloc] init];
        drugModel.id = modelDir.params.drugId;
        drugModel.imgUrl = modelDir.params.drugImgUrl;
        drugModel.shortName = modelDir.params.drugName;
        drugModel.promotionId = modelDir.params.promotionId;
        drugModel.knowledgeTitle = modelDir.params.label;
        consultViewController.drugDetailModel = drugModel;
        consultViewController.proId = modelDir.params.drugId;
        consultViewController.sendConsultType = Enum_SendConsult_Drug;
        
        [vcNavi pushViewController:consultViewController animated:YES];
        
    } else if ([modelDir.pageType intValue] == WebPageFamilyMedicine) {
        FamilyMedicineListViewController *famliyMedcineViewController = [[UIStoryboard storyboardWithName:@"FamilyMedicineListViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FamilyMedicineListViewController"];
        famliyMedcineViewController.fromSlowGuide = YES;
        famliyMedcineViewController.extCallback = ^(BOOL success){
            // 通知H5 跳过慢病引导页
            [self.callBackDelegate runCallbackWithTypeID:CallbackTypeSlowDiseaseGuideRefresh];
        };
        [vcNavi pushViewController:famliyMedcineViewController animated:YES];
    } else if ([modelDir.pageType intValue] == WebPagePharDetail) {//药房详情
  
        [QWGLOBALMANAGER pushBranchDetail:modelDir.params.branchId withType:modelDir.params.type navigation:vcNavi];

    } else if ([modelDir.pageType intValue] == WebPageTypeCallbackSuccess) {
        WebCommentViewController *storeDetail = [[WebCommentViewController alloc] initWithNibName:@"WebCommentViewController" bundle:nil];
        storeDetail.subjectId = modelDir.params.id;
        if (self.isSpecial == NO) {     // 是否是专区
            storeDetail.isTopic = 1;
        } else {
            storeDetail.isTopic = 2;
        }
        if (modelDir.params.nMes != nil) {
            if ([modelDir.params.nMes isEqualToString:@"Y"]) {
                storeDetail.isNewMes = YES;
            } else {
                storeDetail.isNewMes = NO;
            }
        } else {
            storeDetail.isNewMes = NO;
        }
        if (modelDir.params.title.length == 0) {
            modelDir.params.title = @"";
        }
        storeDetail.successBlock = ^(BOOL success, NSString *callBackId){
            if (success) {
                // 通知专题H5页面刷新评论列表
                [self actionInformH5:CallbackTypeAreaComment];
            }
        };
        [vcNavi pushViewController:storeDetail animated:YES];
    } else if ([modelDir.pageType intValue] == WebPageMyCouponProductList) {
        MyCouponDrugViewController * myCouponDrug = [[MyCouponDrugViewController alloc]init];
        myCouponDrug.popToRootView = NO;
        [vcNavi pushViewController:myCouponDrug animated:YES];
    } else if ([modelDir.pageType intValue] == WebPageTypeMedicinePharMore) {

    } else if ([modelDir.pageType intValue] == WebPageTypeDiseaseToFamilyMedicine) {
        FamilyMedicineListViewController *famliyMedcineViewController = [[UIStoryboard storyboardWithName:@"FamilyMedicineListViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FamilyMedicineListViewController"];
        famliyMedcineViewController.extCallback = ^(BOOL success){
            // 通知H5 跳过慢病引导页
            [self actionInformH5:CallbackTypeSlowDiseaseGuideRefresh];
        };
        [vcNavi pushViewController:famliyMedcineViewController animated:YES];
    } else if ([modelDir.pageType intValue] == WebPageTypeCouponDetailSuccess) {
        CouponSuccessViewController *successViewController = [[CouponSuccessViewController alloc] initWithNibName:@"CouponSuccessViewController" bundle:nil];
        CouponPickVoModel *model = [CouponPickVoModel new];
        model.myCouponId = modelDir.params.id;
        successViewController.myCouponModel = model;
        successViewController.extCallback = ^(BOOL success){
            // 药品详情H5页面立即领取按钮置灰逻辑
            [self actionInformH5:CallbackTypeMedicineBack];
        };
        [vcNavi pushViewController:successViewController animated:YES];
    } else if ([modelDir.pageType intValue] == WebPageTypeAreaToCouponDrug) {
        // 专区跳转优惠商品
        PromotionDrugDetailViewController *drugDetailVC = [[PromotionDrugDetailViewController alloc]init];
        DrugVo *vo = [DrugVo new];
        vo.proId = modelDir.params.id;
        drugDetailVC.vo = vo;
        [vcNavi pushViewController:drugDetailVC animated:YES];
    }else if ([modelDir.pageType intValue] == WebPageTypeToActionWinning) {
        // 跳转原生中奖记录
        
        WinDetialViewController *viewController = [WinDetialViewController new];
        [vcNavi pushViewController:viewController animated:YES];
    }else if ([modelDir.pageType intValue] == WebPageTypeToIntegralCenter) {
        // 跳转原生积分中心
        if (self.isComeFromCredit) {
            [self popVCAction:nil];
        }else {
            MyCreditViewController* creditVC = [[UIStoryboard storyboardWithName:@"Credit" bundle:nil] instantiateViewControllerWithIdentifier:@"MyCreditViewController"];
            [self.navigationController pushViewController:creditVC animated:YES];
        }
        
    }else if ([modelDir.pageType intValue] == WebPageTypeToPromotionActivityList) {
        // 跳转原生优惠活动列表
        ChannelProductVo *vo = [ChannelProductVo new];
        vo.proId = modelDir.params.proid;
        PromotionActivityDetailViewController *drugDetail = [[PromotionActivityDetailViewController alloc]init];
        drugDetail.vo = vo;
        [vcNavi pushViewController:drugDetail animated:YES];
    }else if ([modelDir.pageType intValue] == WebPageTypePharComparePrice) {
        // 跳转商品比价页面
        MedicineSearchResultViewController *VC = [[MedicineSearchResultViewController alloc]initWithNibName:@"MedicineSearchResultViewController" bundle:nil];
        VC.productCode = modelDir.params.code;
        VC.lastPageName = self.title;
        [vcNavi pushViewController:VC animated:YES];
    }else if ([modelDir.pageType intValue] == WebPageTypeToShoppingCar) {
        // 跳转商品比价页面
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[@"上级页面"] = @"抢购";
        [QWGLOBALMANAGER statisticsEventId:@"x_gwcym_cx" withLable:@"购物车页面-出现" withParams:setting];
        SimpleShoppingCartViewController *simpleViewController = [[SimpleShoppingCartViewController alloc] initWithNibName:@"SimpleShoppingCartViewController" bundle:nil];
        simpleViewController.shouldRequireShoppingList = NO;
        [self.navigationController pushViewController:simpleViewController animated:YES];
        CartBranchVoModel *branchVoModel = [CartBranchVoModel new];
        branchVoModel.branchId = modelDir.params.branchId;
        branchVoModel.branchName = modelDir.params.branchName;
        branchVoModel.products = [NSMutableArray arrayWithCapacity:1];
        branchVoModel.timeStamp = [[NSDate date] timeIntervalSince1970];
        CartProductVoModel *productModel = [CartProductVoModel new];
        productModel.id = modelDir.params.branchProId;
        productModel.code = modelDir.params.ProCode;
        productModel.name = modelDir.params.proName;
        productModel.brand = modelDir.params.proBrand;
        productModel.spec = modelDir.params.proSpec;
        productModel.imgUrl = modelDir.params.proImgUrl;
        productModel.price = modelDir.params.proPrice;
        productModel.stock = modelDir.params.proStock;
        productModel.saleStock = modelDir.params.saleStock;
        productModel.choose = YES;
        productModel.quantity = 1;
        productModel.promotions = [NSMutableArray arrayWithCapacity:1];
        [branchVoModel.products addObject:productModel];
        
        CartPromotionVoModel *promotionModel = [CartPromotionVoModel new];
        promotionModel.id = modelDir.params.proPromotionId;
        promotionModel.title = modelDir.params.title;
        promotionModel.type = 5;
        promotionModel.showType = 3;
        promotionModel.limitQty = [modelDir.params.limitQty integerValue];
        promotionModel.value = [modelDir.params.value doubleValue];
        promotionModel.unitNum = 1;
        [productModel.promotions addObject:promotionModel];
        [QWGLOBALMANAGER postNotif:NotifShoppingCartSync data:branchVoModel object:nil];
    }else if ([modelDir.pageType intValue] == WebPageTypeMicroDetail) {
        // 跳转微商商品详情
        MedicineDetailViewController *VC = [[MedicineDetailViewController alloc]initWithNibName:@"MedicineDetailViewController" bundle:nil];
        VC.lastPageName = self.title;
        VC.proId = modelDir.params.id;
        [vcNavi pushViewController:VC animated:YES];
    } else if ([modelDir.pageType intValue] == WebPageTypeToCircleDetail) {
        // 跳转圈子详情
        CircleDetailViewController *vc = [[UIStoryboard storyboardWithName:@"Circle" bundle:nil] instantiateViewControllerWithIdentifier:@"CircleDetailViewController"];
        vc.teamId = modelDir.params.id;
//        vc.title = [NSString stringWithFormat:@"%@圈",_postDetail.teamName];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([modelDir.pageType intValue] == WebPageTypeToColumnDetail) {
        // 跳转某一个药师专栏
        ExpertPageViewController *vc = [[UIStoryboard storyboardWithName:@"ExpertPage" bundle:nil] instantiateViewControllerWithIdentifier:@"ExpertPageViewController"];
        vc.hidesBottomBarWhenPushed = YES;
        vc.posterId = modelDir.params.id;
        vc.expertType = (int)modelDir.params.type;
        vc.preVCNameStr = @"H5页面";
        [vcNavi pushViewController:vc animated:YES];
    } else if ([modelDir.pageType intValue] == WebPageTypeToPostDetail) {
        // 跳转帖子详情
        PostDetailViewController* postDetailVC = [[UIStoryboard storyboardWithName:@"Forum" bundle:nil] instantiateViewControllerWithIdentifier:@"PostDetailViewController"];
        postDetailVC.postId = modelDir.params.id;
        postDetailVC.preVCNameStr = @"H5页面";
        [vcNavi pushViewController:postDetailVC animated:YES];
    } else if ([modelDir.pageType intValue] == WebPageTypeToPostTiezi) {
        // 跳转发帖
        SendPostViewController* sendPostVC = [[UIStoryboard storyboardWithName:@"Forum" bundle:nil] instantiateViewControllerWithIdentifier:@"SendPostViewController"];
        sendPostVC.needChooseCircle = YES;
        sendPostVC.preVCNameStr = @"H5页面";
        [vcNavi pushViewController:sendPostVC animated:YES];
    } else if ([modelDir.pageType intValue] == WebPageTypeToPickCouponTicket) {
        // 跳转到领取优惠券
        CenterCouponDetailViewController *vc =[[CenterCouponDetailViewController alloc] initWithNibName:@"CenterCouponDetailViewController" bundle:nil];
        vc.couponId=modelDir.params.couponId;
        
        [self.navigationController pushViewController:vc animated:YES];

    }else if ([modelDir.pageType integerValue] == WebPageTypeToLinkPhonenum) {
        ChangePhoneNumberViewController *bindPhoneVC = [[ChangePhoneNumberViewController alloc] initWithNibName:@"ChangePhoneNumberViewController" bundle:nil];
        bindPhoneVC.isPresentType = NO;
        bindPhoneVC.changePhoneType = ChangePhoneType_BindPhoneNumber;
        bindPhoneVC.extCallBack = ^(BOOL success) {
            [self.callBackDelegate runCallbackWithTypeID:CallbackBindPhone];
        };
        [self.navigationController pushViewController:bindPhoneVC animated:YES];
    }else if([modelDir.pageType integerValue] == WebPageTypeToHomePage) {
        
        [(QWBaseNavigationController *)QWGLOBALMANAGER.tabBar.viewControllers[0] popToRootViewControllerAnimated:YES];
        [QWGLOBALMANAGER.tabBar setSelectedIndex:0];
    }
}
// MARK:H5跳转H5页面
// H5跳转H5页面
- (void)jumpToH5Page:(WebDirectModel *)modelDir
{
    WebDirectViewController *vcDirect = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
    vcDirect.modelDir = modelDir;
    
    if ([modelDir.pageType intValue] == WebPageToWebTypeDisease) {
        vcDirect.showConsultBtn = YES;
    }
    // 设置H5 的model
    [vcDirect setWVWithModel:modelDir withType:WebTitleTypeOnlyShare];
    vcDirect.pageType = [modelDir.pageType intValue];
    if ([modelDir.pageType intValue] == WebPageToWebTypeSlowSubscribe) {
        vcDirect.callBackDelegate = self;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeSlowDiseaseDetail) {
        vcDirect.callBackDelegate = self;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeSlowDiseaseGuide) {
        vcDirect.callBackDelegate = self;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeInfo) {
        
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeSlowDiseaseGuide) {
        vcDirect.callBackDelegate = self;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeSlowDiseaseCouponList) {
        vcDirect.callBackDelegate = self;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeTopicDetail) {
        vcDirect.callBackDelegate = self;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeMedicine) {
        
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeHealthCheckBegin) {
        vcDirect.callBackDelegate = self;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeProductInstrumets) {
        
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeSpecialDetail) {
        
    } else if ([modelDir.pageType intValue] == WebPageTypeInfoCommentList) {
        vcDirect.callBackDelegate = self;
    } else if ([modelDir.pageType intValue] == WebPageTypeOuterLink) {
        vcDirect.callBackDelegate = self;
    } else if ([modelDir.pageType intValue] == WebPageToWebTypeProDetail || [modelDir.pageType intValue] == WebPageToWebTypeExchangeSuccess ||[modelDir.pageType intValue] == WebPageToWebTypeExchangeList || [modelDir.pageType intValue] == WebPageToWebTypeSuccessToList) {
//        vcDirect.callBackDelegate = self;
    }
    QWTabBar *vcTab = APPDelegate.currentTabBar;
    QWBaseNavigationController *vcNavi = (QWBaseNavigationController *)vcTab.selectedViewController;
    [vcNavi pushViewController:vcDirect animated:YES];
}

- (void)delayPopToHome
{
    [[QWGlobalManager sharedInstance].tabBar setSelectedIndex:0];
}

- (void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj{
    if (NotiWhetherHaveNewMessage == type) {
        
        NSString *str = data;
        self.passNumber = [str integerValue];
        self.indexView.passValue = self.passNumber;
        [self.indexView.tableView reloadData];
        if (self.passNumber > 0)
        {
            //显示数字
            self.numLabel.hidden = NO;
            self.redLabel.hidden = YES;
            if (self.passNumber > 99) {
                self.passNumber = 99;
            }
            self.numLabel.text = [NSString stringWithFormat:@"%d",self.passNumber];
            
        }else if (self.passNumber == 0)
        {
            //显示小红点
            self.numLabel.hidden = YES;
            self.redLabel.hidden = YES;
            
        }else if (self.passNumber < 0)
        {
            //全部隐藏
            self.numLabel.hidden = YES;
            self.redLabel.hidden = YES;
        }
    } else if (NotifQuitOut == type) {
        
    } else if (NotifRefreshIntegralIndex == type){
        
    }else if (NotifRefreshCurH5Page == type) {
        if (self.pageType == WebPageTypeIntegralIndex) {
            NSString *pageType = (NSString *)data;
//            NSInteger type = pageType.integerValue;
            NSLog(@"THE SELF PAGE TYPE IS %d",self.pageType);
            if (self.extShare!=nil) {
                [self.extShare runExtWithCallBackPageType:pageType];
            }
        }
    }else if(type == NotifPayStatusFinish){
        if(self.isUp){
//             [self jumpOrderSome:@"2"];
            
            SubmitOrderSuccessViewController *submitOrderVC = [[SubmitOrderSuccessViewController alloc] initWithNibName:@"SubmitOrderSuccessViewController" bundle:nil];
            submitOrderVC.payType = 2;
            submitOrderVC.orderId = self.modelLocal.modelOrder.orderId;
            [self.navigationController pushViewController:submitOrderVC animated:YES];
        }
       
        }else if (type == NotifPayStatusUnknown){//支付宝 微信状态未知
            if(self.isUp){
            PayInfoModel *payModel =[PayInfoModel new];
            payModel=(PayInfoModel*)data;
            if([payModel.notiType isEqualToString:@"ali"]){
                if([payModel.notiTypeStatus isEqualToString:@"3"]){
                    PayOrderStatusViewController *vc=[PayOrderStatusViewController new];
                    vc.orderId = self.modelLocal.modelOrder.orderId;
                    vc.outTradeNo=QWGLOBALMANAGER.payOrderId;
                    vc.orderCode= self.modelLocal.modelOrder.orderCode;
                    vc.branchName = self.modelLocal.modelOrder.orderIdName;
                    vc.type=@"ali";
                    vc.isComeFrom=self.isComeFromConfirm;//1//从订单详情页面进入 2订单列表
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                     [self jumpOrderSome:@"1"];
                }
            }else if([payModel.notiType isEqualToString:@"wx"]){
                if([payModel.notiTypeStatus isEqualToString:@"3"]){
                    PayOrderStatusViewController *vc=[PayOrderStatusViewController new];
                    vc.orderId = self.modelLocal.modelOrder.orderId;
                    vc.outTradeNo=QWGLOBALMANAGER.payOrderId;
                    vc.orderCode= self.modelLocal.modelOrder.orderCode;
                    vc.branchName = self.modelLocal.modelOrder.orderIdName;
                    vc.type=@"wx";
                    vc.isComeFrom=self.isComeFromConfirm;
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    [self jumpOrderSome:@"1"];
                }
            }
            }
        }
    
}

-(void)jumpOrderSome:(NSString *)typeStatus
{

    if([self.isComeFromConfirm isEqualToString:@"1"]){//从订单详情页面进入
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isKindOfClass:[IndentDetailListViewController class]]) {
                [QWGLOBALMANAGER postNotif:NotifPayStatusAlert data:typeStatus object:nil];
                [self.navigationController popToViewController:temp animated:YES];
                return;
            }
        }

    }else if([self.isComeFromConfirm isEqualToString:@"2"]){//从订单列表进入
        IndentDetailListViewController *indentDetailListViewController = [IndentDetailListViewController new];
        indentDetailListViewController.orderId = self.modelLocal.modelOrder.orderId;
        indentDetailListViewController.isComeFromList = YES;
        indentDetailListViewController.typeAlert=typeStatus;
        [self.navigationController pushViewController:indentDetailListViewController animated:YES];
    }else{//购物车进入
        IndentDetailListViewController *indentDetailListViewController = [IndentDetailListViewController new];
        indentDetailListViewController.orderId = self.modelLocal.modelOrder.orderId;
        indentDetailListViewController.isComeFromCode = YES;
        indentDetailListViewController.typeAlert=typeStatus;
        [self.navigationController pushViewController:indentDetailListViewController animated:YES];
    }

}




//分享成功回调
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    DDLogVerbose(@"share success = %@",response);
    if (response.responseCode == UMSResponseCodeSuccess)//分享成功
    {
        if (self.extShare) {
            [self.extShare runExtWithCallBackId:CallbackTypeRoundPanel];
        }
        NSString *strDataType = [self.m_webView stringByEvaluatingJavaScriptFromString:@"var a=document.getElementById(\"data-appType\"); var str = a.getAttribute(\"data-type\");decodeURIComponent(str)"];
        DDLogVerbose(@"the str data type is %@",strDataType);
        NSString *strChannel = @"";
        NSDictionary *dicData = response.data;
        if (dicData[@"sina"] != nil) {
            DDLogVerbose(@"share sina");
            strChannel = @"2";
        } else if (dicData[@"wxtimeline"] != nil) {
            DDLogVerbose(@"share wxtimeline");
            strChannel = @"1";
        } else if (dicData[@"wxsession"] != nil) {
            DDLogVerbose(@"share wxsession");
            strChannel = @"4";
        }else if (dicData[@"qzone"] != nil) {
            DDLogVerbose(@"share qzone");
            strChannel = @"3";
        }
        
        NSString *strDataID = [self.m_webView stringByEvaluatingJavaScriptFromString:@"var a=document.getElementById(\"data-appType\"); var str = a.getAttribute(\"data-id\");decodeURIComponent(str)"];
        RptShareSaveLogModelR *modelR = [RptShareSaveLogModelR new];
        modelR.channel = strChannel;
        modelR.client = @"1";
        modelR.device = @"2";
        if ([strDataType intValue] == 1) {
            // 大转盘
            modelR.obj = @"8";
        } else if ([strDataType intValue] == 2) {
            // 翻牌
            modelR.obj = @"9";
        } else if ([strDataType intValue] == 3) {
            // 专题
            modelR.obj = @"17";
        } else if ([strDataType intValue] == 4) {
            // 资讯
            modelR.obj = @"16";
        } else {
            modelR.obj = @"0";
        }
        modelR.objId = @"";
        if (strDataID != nil) {
            modelR.objId = strDataID;
        }
        
        MapInfoModel *mapInfoModel = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
        if(mapInfoModel) {
            modelR.city = mapInfoModel.city;
        }else{
            modelR.city = @"苏州市";
        }
        NSString *strToken = self.modelShare.modelSavelog.token;
        if (QWGLOBALMANAGER.configure.userToken.length > 0) {
            strToken = QWGLOBALMANAGER.configure.userToken;
        }
        modelR.token = strToken;
        
        [self callSaveLogRequest:modelR];

        //需要验证
    }
}
-(void)didFinishGetUMSocialDataResponse:(UMSocialResponseEntity *)response
{
    [super shareFeedbackFailed];
}


#pragma mark - 设置导航栏标题
- (void)setupNumLabel
{
    self.numLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 1, 18, 18)];
    self.numLabel.backgroundColor = RGBHex(qwColor3);
    self.numLabel.layer.cornerRadius = 9.0;
    self.numLabel.textColor = [UIColor whiteColor];
    self.numLabel.font = [UIFont systemFontOfSize:11];
    self.numLabel.textAlignment = NSTextAlignmentCenter;
    self.numLabel.layer.masksToBounds = YES;
    self.numLabel.text = @"10";
    self.numLabel.hidden = YES;
}

- (void)setupRedLabel
{
    self.redLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 10, 8, 8)];
    self.redLabel.backgroundColor = RGBHex(qwColor3);
    self.redLabel.layer.cornerRadius = 4.0;
    self.redLabel.layer.masksToBounds = YES;
    self.redLabel.hidden = YES;
}

- (void)setupRedPoint
{
    if (self.passNumber > 0)
    {
        //显示数字
        self.numLabel.hidden = NO;
        self.redLabel.hidden = YES;
        if (self.passNumber > 99) {
            self.passNumber = 99;
        }
        self.numLabel.text = [NSString stringWithFormat:@"%d",self.passNumber];
        
    }else if (self.passNumber == 0)
    {
        //显示小红点
        self.numLabel.hidden = YES;
        self.redLabel.hidden = NO;
        
    }else if (self.passNumber < 0)
    {
        //全部隐藏
        self.numLabel.hidden = YES;
        self.redLabel.hidden = YES;
    }
}

// 返回首页的图片
- (void)setUpRightItemNine
{
    UIView *ypDetailBarItems=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 55)];
    UIButton * zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [zoomButton setFrame:CGRectMake(23, -2, 55,55)];
    [zoomButton addTarget:self action:@selector(popToRoot) forControlEvents:UIControlEventTouchUpInside];
    UIImage *iconImage = [[UIImage imageNamed:@"ic_popup_detail_blue"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [zoomButton setImage:iconImage forState:UIControlStateNormal];
    [ypDetailBarItems addSubview:zoomButton];
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -15;
    self.navigationItem.rightBarButtonItems=@[fixed,[[UIBarButtonItem alloc]initWithCustomView:ypDetailBarItems]];
}

// 只有分享图标的页面
- (void)setUpRightItemSeven
{
    UIView *ypDetailBarItems=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 55)];
    UIButton * zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [zoomButton setFrame:CGRectMake(23, -2, 55,55)];
    [zoomButton addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
    //    zoomButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    //    zoomButton.titleLabel.textColor = [UIColor whiteColor];
    //    [zoomButton setTitle:@"分享" forState:UIControlStateNormal];
//    [zoomButton setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    UIImage *iconImage = [[UIImage imageNamed:@"icon_share"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [zoomButton setImage:iconImage forState:UIControlStateNormal];
//    [zoomButton setImage:[UIImage imageNamed:@"icon_share_click"] forState:UIControlStateHighlighted];
    [ypDetailBarItems addSubview:zoomButton];
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -15;
//    if(self.modelLocal.typeShare != LocalShareTypeNone) {
        self.navigationItem.rightBarButtonItems=@[fixed,[[UIBarButtonItem alloc]initWithCustomView:ypDetailBarItems]];
//    }
}

// 带字体的三个页面，含分享
- (void)setUpRightItemSix
{
    UIView *ypDetailBarItems=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 120, 55)];
    UIButton * zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [zoomButton setFrame:CGRectMake(23, -2, 55,55)];
    [zoomButton addTarget:self action:@selector(setupFontAction) forControlEvents:UIControlEventTouchUpInside];
    zoomButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    zoomButton.titleLabel.textColor = RGBHex(qwColor1);
    [zoomButton setTitle:@"Aa" forState:UIControlStateNormal];
    [ypDetailBarItems addSubview:zoomButton];
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -15;
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(65, 10, 60, 40)];
    //三个点button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(5, -2, 50, 40);
    [button setImage:[[UIImage imageNamed:@"icon_more_slide_details"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(returnIndexTwo) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:button];
    [ypDetailBarItems addSubview:rightView];
    
    //数字角标
    [self setupNumLabel];
    [rightView addSubview:self.numLabel];
    
    //小红点
    [self setupRedLabel];
    [rightView addSubview:self.redLabel];
    self.navigationItem.rightBarButtonItems=@[fixed,[[UIBarButtonItem alloc]initWithCustomView:ypDetailBarItems]];
    [self setupRedPoint];
}


// 带字体的三个点页面，不含分享
- (void)setUpRightItemFive
{
    UIView *ypDetailBarItems=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 120, 55)];
    UIButton * zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [zoomButton setFrame:CGRectMake(23, -2, 55,55)];
    [zoomButton addTarget:self action:@selector(setupFontAction) forControlEvents:UIControlEventTouchUpInside];
    zoomButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    zoomButton.titleLabel.textColor = RGBHex(qwColor1);
    [zoomButton setTitle:@"Aa" forState:UIControlStateNormal];
    [ypDetailBarItems addSubview:zoomButton];
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -15;
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(65, 10, 60, 40)];
    //三个点button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(5, -2, 50, 40);
    [button setImage:[[UIImage imageNamed:@"icon_more_slide_details"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(returnIndexOne) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:button];
    [ypDetailBarItems addSubview:rightView];
    
    //数字角标
    [self setupNumLabel];
    [rightView addSubview:self.numLabel];
    
    //小红点
    [self setupRedLabel];
    [rightView addSubview:self.redLabel];
    self.navigationItem.rightBarButtonItems=@[fixed,[[UIBarButtonItem alloc]initWithCustomView:ypDetailBarItems]];
    [self setupRedPoint];
}
//只有字体
-(void)setUpRightItemEight{
//    UIView *ypDetailBarItems=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 120, 55)];
//    UIButton * zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [zoomButton setFrame:CGRectMake(23, -2, 55,55)];
//    [zoomButton addTarget:self action:@selector(setupFontAction) forControlEvents:UIControlEventTouchUpInside];
//    zoomButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
//    zoomButton.titleLabel.textColor = RGBHex(qwColor1);
//    [zoomButton setTitle:@"Aa" forState:UIControlStateNormal];
//
//    [ypDetailBarItems addSubview:zoomButton];
//    
//    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    fixed.width = -48;
//
//    UIBarButtonItem *itemFont = [[UIBarButtonItem alloc]initWithCustomView:ypDetailBarItems];
//    [itemFont setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                   [UIColor redColor], NSForegroundColorAttributeName,nil]
//                         forState:UIControlStateNormal];
//    self.navigationItem.rightBarButtonItems=@[fixed,itemFont];
      self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Aa" style:UIBarButtonItemStyleDone target:self action:@selector(setupFontAction)];

}



// 带跳过的导航栏
- (void)setUpRightItemFour
{
    UIView *ypDetailBarItems=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 70, 55)];
    UIButton * zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [zoomButton setFrame:CGRectMake(10, -2, 55,55)];
    [zoomButton addTarget:self action:@selector(jumpAction) forControlEvents:UIControlEventTouchUpInside];
    zoomButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    zoomButton.titleLabel.textColor = [UIColor whiteColor];
    [zoomButton setTitle:@"跳过" forState:UIControlStateNormal];
    [ypDetailBarItems addSubview:zoomButton];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -15;
    self.navigationItem.rightBarButtonItems=@[fixed,[[UIBarButtonItem alloc]initWithCustomView:ypDetailBarItems]];
}

// 有分享的三个点页面

- (void)setUpRightItemTwo
{
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -15;
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    //三个点button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(5, -2, 50, 40);
    [button setImage:[[UIImage imageNamed:@"icon_more_slide_details"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(returnIndexTwo) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:button];
    
    //数字角标
    [self setupNumLabel];
    [rightView addSubview:self.numLabel];
    
    //小红点
    [self setupRedLabel];
    [rightView addSubview:self.redLabel];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    
    self.navigationItem.rightBarButtonItems = @[fixed,rightItem];
    
    [self setupRedPoint];
}

// 没有分享的三个点页面
- (void)setUpRightItemOne
{
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -15;
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    
    //三个点button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(5, -2, 50, 40);
    [button setImage:[[UIImage imageNamed:@"icon_more_slide_details"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(returnIndexOne) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:button];
    
    //数字角标
    [self setupNumLabel];
    [rightView addSubview:self.numLabel];
    
    //小红点
    [self setupRedLabel];
    [rightView addSubview:self.redLabel];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItems = @[fixed,rightItem];
    
    [self setupRedPoint];
}

// 显示原生loading框
- (void)showLoading
{
    [QWLOADING showLoading];
}

// 隐藏原生loading框
- (void)hideLoading
{
    [QWLOADING removeLoading];
}

@end
