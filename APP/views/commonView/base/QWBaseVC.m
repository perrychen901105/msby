
//
//  basePage.m
//  Show
//
//  Created by YAN Qingyang on 15-2-11.
//  Copyright (c) 2015年 YAN Qingyang. All rights reserved.
//

#import "QWBaseVC.h"
#import "AppDelegate.h"
#import "QWProgressHUD.h"
#import "Reachability.h"
#import "CustomShareView.h"

#import "System.h"
#import "SystemModel.h"
#import "SystemModelR.h"
#import "Forum.h"
#import "CreditModel.h"

static float kTopBarItemWidth = 40;
static float kDelay = 1.5f;
static float kTopBackBtnMargin = -13.f;
static float kTopBtnMargin = -16.f;
@interface QWBaseVC () <UIGestureRecognizerDelegate,UINavigationBarDelegate,UMSocialUIDelegate,UMSocialDataDelegate,SRRefreshDelegate>
//<UITableViewDataSource, UITableViewDelegate >
{
    UIView *vQLog;
    UITextView *txtQLog;
    BOOL canLoadMore;
    UIView *infoView;
}
@property (strong, nonatomic) ShareContentModel *modelShare;
@property (strong, nonatomic) CustomShareView *viewCusShare;
@property (strong, nonatomic) NSString *strChannel;


@end

@implementation QWBaseVC
@synthesize delegate=_delegate;
@synthesize delegatePopVC=_delegatePopVC;

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [QWCLICKEVENT qwTrackPageBegin:StrFromObj([self class])];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickStatusBar) name:kQWClickStatusNotification object:nil];
    NSString *strClass = NSStringFromClass([self class]);
//    DDLogVerbose(@"####str clsss is %@",strClass);
//    [self mapIdentifierWithClassName:strClass];
    if (self.navigationController.viewControllers.count<=1 && _backButtonEnabled == NO)
        return;
    else
        [self naviBackBotton];
    
}

- (void)clickStatusBar
{
}

- (NSString *)mapIdentifierWithClassName:(NSString *)strClass
{
    NSString *strMappedID = @"";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"ClassNameToID" ofType:@"plist"];
    NSDictionary *dicRoot = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *strValue = dicRoot[@"ConsultViewController"];
    DDLogVerbose(@"the value is %@",strValue);
    return strMappedID;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [QWCLICKEVENT qwTrackPageEnd:StrFromObj([self class])];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kQWClickStatusNotification object:nil];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    canLoadMore=YES;
    _refreshTops = [NSMutableArray arrayWithCapacity:3];
    [self UIGlobal];
//    [self setupGesture];
    
//    DebugLog(@"hidesBottomBarWhenPushed %@ %i",[self class],self.hidesBottomBarWhenPushed);
//    DebugLog(@"###1 %@ %@",[self class],NSStringFromCGRect(self.view.bounds));
    /**
     *  如果不要显示头部的下拉刷新，添加header              `              Hidden=YES;
     */
    //self.tableMain.headerHidden=YES;
    
    
    
    
}



- (void)enableSimpleRefresh:(UIScrollView *)scrollView  block:(SRRefreshBlock)block
{
    [[scrollView viewWithTag:1018] removeFromSuperview];
    SRRefreshView *slimeView = [[SRRefreshView alloc] init];
    [_refreshTops addObject:slimeView];
    slimeView.delegate = self;
    slimeView.upInset = scrollView.contentInset.top;
    slimeView.slimeMissWhenGoingBack = YES;
    slimeView.slime.bodyColor = RGBHex(qwColor1);
    slimeView.slime.skinColor = RGBHex(qwColor1);
    slimeView.slime.lineWith = 1;
//    slimeView.slime.shadowBlur = 4;
//    slimeView.slime.shadowColor = RGBHex(qwColor1);
    slimeView.block = block;
    slimeView.tag = 1018;
    if(!scrollView.delegate)
        scrollView.delegate = self;
    [scrollView addSubview:slimeView];
}

- (void)removeSimpleRefresh
{
    [_refreshTops enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SRRefreshView *refreshView = obj;
        [refreshView endRefresh];
        [refreshView removeFromSuperview];
    }];
    [_refreshTops removeAllObjects];
}

- (void)endHeaderRefresh
{
    [_refreshTops enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SRRefreshView *refreshView = obj;
        [refreshView endRefresh];
    }];
    
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshTops enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SRRefreshView *refreshView = obj;
        [refreshView scrollViewDidScroll];
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshTops enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SRRefreshView *refreshView = obj;
        [refreshView scrollViewDidEndDraging];
    }];
    
}

#pragma mark - slimeRefresh delegate

- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [_refreshTops enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SRRefreshView *refreshView = obj;
        [refreshView performSelector:@selector(endRefresh)
                         withObject:nil afterDelay:1.5
                            inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    }];
    
}



- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self naviTitleView:nil];
    
    
//    DebugLog(@"###2 %@ %@",[self class],NSStringFromCGRect(self.view.bounds));
}
#pragma mark - 全局界面UI
- (void)UIGlobal{
    [super UIGlobal];
    
    self.view.backgroundColor=RGBHex(qwColor11);
    
    
    if (self.tableMain==nil) {
        self.tableMain=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    }
    
    self.tableMain.backgroundColor=RGBAHex(qwColor4, 1);
    self.tableMain.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableMain addFooterWithTarget:self action:@selector(footerPulling)];
    
    self.tableMain.footerPullToRefreshText = kWarning6;
    self.tableMain.footerReleaseToRefreshText = kWarning7;
    self.tableMain.footerRefreshingText = kWarning9;
    self.tableMain.footerNoDataText = kWarning44;
}
#pragma mark - 滑动返回上一页
- (void)setupGesture
{
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if (self.navigationController.viewControllers.count<=1 && _backButtonEnabled == NO) {
            return;
        }
        else
            [self popVCAction:nil];
    }
}
#pragma mark - table 刷新
- (void)headerRereshing{
    
}

- (void)footerRereshing{
    
}

- (void)footerPulling{
    DebugLog(@"+++++++ footerPulling: %@",self);
    if (!canLoadMore)
        [self footerNoMore];
    else
        [self footerRereshing];
}

- (void)footerNoMore{
    [self.tableMain footerNoData];
}

- (BOOL)checkTotal:(NSInteger)total pageSize:(NSInteger)pSize pageNum:(NSInteger)pNum{
    DebugLog(@"%i %i %i",total,pSize,pNum);
    if (pNum*pSize<total) {
        canLoadMore=YES;
    }
    else canLoadMore=NO;
    return canLoadMore;
}
#pragma mark - 左上按钮
- (void)naviLeftBottonImage:(UIImage*)aImg highlighted:(UIImage*)hImg action:(SEL)action{
//    [self.navigationItem setHidesBackButton:YES];
    
  
    CGFloat margin=10;
    CGFloat ww=kTopBarItemWidth, hh=44;
    CGFloat bw,bh;
    
    //12,21 nav_btn_back
    bw=aImg.size.width;
    bh=aImg.size.height;

    CGRect frm = CGRectMake(0,0,ww,hh);
    _LeftItemBtn = [[UIButton alloc] initWithFrame:frm];
    
    [_LeftItemBtn setImage:aImg forState:UIControlStateNormal];
    if (hImg)
        [_LeftItemBtn setImage:hImg forState:UIControlStateHighlighted];
    [_LeftItemBtn setImageEdgeInsets:UIEdgeInsetsMake((hh-bh)/2, margin, (hh-bh)/2, ww-margin-bw)];
    
  
    [_LeftItemBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    _LeftItemBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _LeftItemBtn.backgroundColor=[UIColor clearColor];
    
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = kTopBackBtnMargin;
    //
    UIBarButtonItem* btnItem = [[UIBarButtonItem alloc] initWithCustomView:_LeftItemBtn];
    self.navigationItem.leftBarButtonItems = @[fixed,btnItem];
}
#pragma mark - 右侧文字按钮
- (void)naviRightBotton:(NSString*)aTitle action:(SEL)action
{
    UIFont *ft=fontSystemBold(kFontS1);
    CGFloat ww=kTopBarItemWidth, hh=44;
    
    CGSize sz=[GLOBALMANAGER sizeText:aTitle font:ft];
    if (sz.width>ww) {
        ww=sz.width;
    }

    CGRect frm = CGRectMake(0,0,ww,hh);
    _RightItemBtn = [[UIButton alloc] initWithFrame:frm];
    
    
    [_RightItemBtn setTitle:aTitle forState:UIControlStateNormal];
    _RightItemBtn.titleLabel.font=ft;
    _RightItemBtn.titleLabel.textColor=RGBHex(qwColor1);
    [_RightItemBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    _RightItemBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _RightItemBtn.backgroundColor=[UIColor whiteColor];
    
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -16.0f;
    
    UIBarButtonItem* btnItem = [[UIBarButtonItem alloc] initWithCustomView:_RightItemBtn];
    self.navigationItem.rightBarButtonItems = @[fixed,btnItem];
}

#pragma mark - 导航返回按钮自定义
- (void)naviBackBotton
{
    UIImage *image = [[UIImage imageNamed:@"arrow_return_"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *imageHighlighted = [[UIImage imageNamed:@"arrow_return_"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self naviLeftBottonImage:image highlighted:imageHighlighted action:@selector(popVCAction:)];
}

- (id)naviTitleView:(UIView*)vTitle{
    id aView=vTitle;
//    float ww=(width>=0)?width:200;
    CGRect frm=CGRectMake(0, 0, 200, 44);//self.navigationController.navigationBar.bounds;
    if (aView==nil) {
        aView=[[UIView alloc]init];
        
        UILabel *lbl=[[UILabel alloc]initWithFrame:frm];
        [lbl setFont:fontSystem(kFontS2)];
        [lbl setTextColor:RGBHex(qwColor4)];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl setText:self.title];
//        [lbl setBackgroundColor:RGBAHex(0xffee00, 0.25)];
        
        [aView addSubview:lbl];
    }
    
    if ([aView respondsToSelector:@selector(setBackgroundColor:)])
//        [aView setBackgroundColor:RGBAHex(0xff00ff, 0.5)];
    
    if ([aView respondsToSelector:@selector(setFrame:)]) {
        [aView setFrame:frm];
    }
    
//    [aView setFrame:self.navigationController.navigationBar.frame];
    [self.navigationItem setTitleView:aView];
    
    return aView;
}

- (void)naviSpaceWidth:(float)width pos:(UIRectEdge)edge{
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = width;
    if (edge==UIRectCornerBottomLeft)
        self.navigationItem.leftBarButtonItems = @[fixed];
    if (edge==UIRectCornerBottomRight)
        self.navigationItem.rightBarButtonItems = @[fixed];
}
#pragma mark - 返回主页，收藏等列表

#pragma mark 全局通知
- (void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj{
    
}

#pragma mark - tmp
- (CGSize)sizeText:(NSString*)text
              font:(UIFont*)font
        limitWidth:(float)width
{
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin//|NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    rect.size.width=width;
    rect.size.height=ceil(rect.size.height);
    return rect.size;
}
#pragma mark - 无数据页面水印
-(void)showInfoView:(NSString *)text image:(NSString*)imageName {
    [self showInfoView:text image:imageName tag:0];
}

-(void)showInfoInView:(UITableView *)showView
           offsetSize:(CGFloat)offset
                 text:(NSString *)text
                image:(NSString*)imageName
{
    UIImage * imgInfoBG = [UIImage imageNamed:imageName];
    
    if (self.vInfo==nil) {
        self.vInfo = [[UIView alloc] initWithFrame:CGRectMake(0, offset + 100, APP_W,300)];
       self.vInfo.backgroundColor = RGBAHex(qwColor10,0);
    }
    for (id obj in self.vInfo.subviews) {
        [obj removeFromSuperview];
    }
    
    UIImageView *imgvInfo;
    UILabel* lblInfo;
    
    imgvInfo=[[UIImageView alloc]init];
    [self.vInfo addSubview:imgvInfo];
    
    lblInfo = [[UILabel alloc]init];
    lblInfo.tag = 101;
    lblInfo.numberOfLines=0;
    lblInfo.font = fontSystem(kFontS1);
    lblInfo.textColor = RGBHex(qwColor8);//0x89889b 0x6a7985
    lblInfo.textAlignment = NSTextAlignmentCenter;
    [self.vInfo addSubview:lblInfo];
    
    UIButton *btnClick = [[UIButton alloc] initWithFrame:self.vInfo.bounds];
    btnClick.tag = 0;
    [btnClick addTarget:self action:@selector(viewInfoClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.vInfo addSubview:btnClick];
    
    
    float vw=CGRectGetWidth(self.vInfo.bounds);
    
    CGRect frm;
    frm=RECT((vw-imgInfoBG.size.width)/2,45, imgInfoBG.size.width, imgInfoBG.size.height);
    imgvInfo.frame=frm;
    imgvInfo.image = imgInfoBG;
    
    float lw=vw-40*2;
    float lh=(imageName!=nil)?CGRectGetMaxY(imgvInfo.frame) + 24:40;
    CGSize sz=[self sizeText:text font:lblInfo.font limitWidth:lw];
    frm=RECT((vw-lw)/2, imgvInfo.frame.origin.y + imgvInfo.frame.size.height + 22, lw,sz.height);
    lblInfo.frame=frm;
    lblInfo.text = text;
    showView.contentSize = CGSizeMake(showView.frame.size.width, self.vInfo.frame.origin.y + self.vInfo.frame.size.height );
    [showView addSubview:self.vInfo];
    [showView bringSubviewToFront:self.vInfo];
}

-(UIView *)showInfoView:(NSString *)text image:(NSString*)imageName tag:(NSInteger)tag
{
    UIImage * imgInfoBG = [UIImage imageNamed:imageName];
    
    if (self.vInfo==nil) {
        self.vInfo = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.vInfo.backgroundColor = RGBHex(qwColor11);
    }
    
    self.vInfo.frame = [UIScreen mainScreen].bounds;
    
    for (id obj in self.vInfo.subviews) {
        [obj removeFromSuperview];
    }
    
    UIImageView *imgvInfo;
    UILabel* lblInfo;
    
    imgvInfo=[[UIImageView alloc]init];
    [self.vInfo addSubview:imgvInfo];
    
    lblInfo = [[UILabel alloc]init];
    lblInfo.tag = 101;
    lblInfo.numberOfLines=0;
    lblInfo.font = fontSystem(kFontS1);
    lblInfo.textColor = RGBHex(qwColor8);//0x89889b 0x6a7985
    lblInfo.textAlignment = NSTextAlignmentCenter;
    [self.vInfo addSubview:lblInfo];
    
    UIButton *btnClick = [[UIButton alloc] initWithFrame:self.vInfo.bounds];
    btnClick.tag=tag;
    [btnClick addTarget:self action:@selector(viewInfoClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.vInfo addSubview:btnClick];
    
    
    float vw=CGRectGetWidth(self.vInfo.bounds);
    
    CGRect frm;
    frm=RECT((vw-imgInfoBG.size.width)/2,45, imgInfoBG.size.width, imgInfoBG.size.height);
    imgvInfo.frame=frm;
    imgvInfo.image = imgInfoBG;
    
    float lw=vw-40*2;
    float lh=(imageName!=nil)?CGRectGetMaxY(imgvInfo.frame) + 24:40;
    CGSize sz=[self sizeText:text font:lblInfo.font limitWidth:lw];
    frm=RECT((vw-lw)/2, imgvInfo.frame.origin.y + imgvInfo.frame.size.height + 22, lw,sz.height);
    lblInfo.frame=frm;
    lblInfo.text = text;
    
    [self.view addSubview:self.vInfo];
    [self.view bringSubviewToFront:self.vInfo];
    return self.vInfo;
}

//-(void)showInfoView:(NSString *)text image:(NSString*)imageName tag:(NSInteger)tag
//{
//    
////    DebugLog(@"###3 %@ %@",[self class],NSStringFromCGRect(self.view.frame));
//    UIImage * imgInfoBG = [UIImage imageNamed:imageName];
//    
//    
//    if (self.vInfo==nil) {
//        self.vInfo = [[UIView alloc]initWithFrame:self.view.bounds];
//        self.vInfo.backgroundColor = RGBHex(qwColor11);
//    }
//    
//    self.vInfo.frame = self.view.bounds;
////    self.vInfo.backgroundColor=[UIColor redColor];
//    
//    for (id obj in self.vInfo.subviews) {
//        [obj removeFromSuperview];
//    }
//    
//    UIImageView *imgvInfo;
//    UILabel* lblInfo;
//    
//    imgvInfo=[[UIImageView alloc]init];
//    [self.vInfo addSubview:imgvInfo];
//    
//    lblInfo = [[UILabel alloc]init];
//    lblInfo.font = fontSystem(kFontS5);
//    lblInfo.textColor = RGBHex(kColor22);
//    lblInfo.textAlignment = NSTextAlignmentCenter;
//    [self.vInfo addSubview:lblInfo];
//    
//    UIButton *btnClick = [[UIButton alloc] initWithFrame:self.vInfo.bounds];
//    btnClick.tag=tag;
//    [btnClick addTarget:self action:@selector(viewInfoClickAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.vInfo addSubview:btnClick];
//    
//    CGFloat fix=imgInfoBG.size.height/3*2;
////    if (self.hidesBottomBarWhenPushed) {
////        fix=100;
////    }
//    
//    CGRect frm;
//    frm=RECT(0, 0, imgInfoBG.size.width, imgInfoBG.size.height);
//    imgvInfo.frame=frm;
//    imgvInfo.center = CGPointMake(self.vInfo.center.x, self.vInfo.center.y-fix);
//    imgvInfo.image = imgInfoBG;
//    
//    frm=RECT(0, CGRectGetMaxY(imgvInfo.frame) + 10, text.length*20,30);
//    lblInfo.frame=frm;
//    lblInfo.center = CGPointMake(self.vInfo.center.x, lblInfo.center.y);
//    lblInfo.text = text;
//    
////    [self.view insertSubview:self.vInfo atIndex:self.view.subviews.count ];
//    [self.view addSubview:self.vInfo];
//    [self.view bringSubviewToFront:self.vInfo];
//    
////    DebugLog(@"image: %@",NSStringFromCGRect(imgvInfo.frame));
//}

- (void)removeInfoView{
    
    [infoView removeFromSuperview];
    [self.vInfo removeFromSuperview];
}

- (IBAction)viewInfoClickAction:(id)sender{
//    NSInteger tag=[sender tag];
}


- (void)showLoadingWithMessage:(NSString*)msg {
    if (HUD==nil) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        [self.view bringSubviewToFront:HUD];

        HUD.delegate = self;
    }
    HUD.labelText=msg;
    
    [HUD show:YES];
}

- (void)didLoad{
    
    [HUD hide:YES];
}


#pragma mark - 检测网络
- (BOOL)isNetWorking{
    
    BOOL isNet = NO;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    
    switch ([r currentReachabilityStatus]) {
            
        case NotReachable:
            isNet = YES;
            break;
            
        case ReachableViaWWAN:
            isNet = NO;
            break;
            
        case ReachableViaWiFi:
            isNet = NO;
            break;
            
        default:
            break;
    }
    
    return isNet;
}

#pragma mark - 对数组进行操作
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

- (NSMutableArray *)sortArrWithKey:(NSString *)strKey isAscend:(BOOL)isAscend oriArray:(NSMutableArray *)oriArr
{
    NSMutableArray *arrSorted = [@[] mutableCopy];
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:strKey ascending:isAscend];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
    arrSorted = [[oriArr sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    return arrSorted;
}
#pragma mark - 自动消息
- (void)showText:(NSString*)txt{
    [self showText:txt delay:1.5];
}

- (void)showText:(NSString*)txt delay:(double)delay{
    [self.view endEditing:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
//    hud.labelText = txt;
    hud.detailsLabelText = txt;
//    hud.margin = 10.f;
//    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    double dl=(delay>0)?delay:1.f;
    [hud hide:YES afterDelay:dl];
}

- (void)showError:(NSString *)msg{
    [self showMessage:msg icon:@"error.png" afterDelay:kDelay ];
//    [self show:error icon:@"error.png" view:view];
}

- (void)showSuccess:(NSString *)msg
{
    [self showMessage:msg icon:@"success.png" afterDelay:kDelay ];
}

- (void)showSuccess:(NSString *)msg completion:(CallBack)completion{
    [self showMessage:msg icon:@"success.png" afterDelay:kDelay ];
    [self performSelector:@selector(completionYes:) withObject:completion afterDelay:kDelay];
}

- (void)showMessage:(NSString*)txt icon:(NSString *)icon afterDelay:(double)delay{
    [self.view endEditing:YES];
//    [SVProgressHUD showErrorWithStatus:txt duration:0.8];
    
//    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = txt;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
//    hud.margin = 10.f;
//    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    double dl=(delay>0)?delay:1.f;
    [hud hide:YES afterDelay:dl];
}

- (void)showErrorMessage:(NSError*)error{
//    NSDictionary *errs=error.userInfo;
//    NSString *code=[self getErrCode:[errs objectForKey:@"errors"]];
//    NSString *err_code=[NSString stringWithFormat:@"ERR_%@",code];
//    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[AppDelegate localized:@"ERROR" defaultValue:nil]
//                                                       message:[AppDelegate localized:err_code defaultValue:code]
//                                                      delegate:self
//                                             cancelButtonTitle:[AppDelegate localized:@"btnClose" defaultValue:nil]
//                                             otherButtonTitles:nil, nil];
//    
//    [alertView show];
}
#pragma mark - CallBack
- (void)completionYes:(CallBack)completion{
    if (completion) {
        completion(YES);
    }
}
#pragma mark alert
- (void)showAlert:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion{
    
}
#pragma mark 错误处理
- (NSString*)getErrCode:(id)obj{
    NSMutableString *str=[NSMutableString stringWithString:@"UNKNOW"];
//    NSArray *arrErrs;
//    if (!ObjClass(obj, [NSArray class])) {
//        return str;
//    }
//    arrErrs=(NSArray*)obj;
//    if (arrErrs.count) {
//        NSDictionary *dd=[arrErrs objectAtIndex:0];
//        if ([dd objectForKey:@"err_code"]) {
//            return [dd objectForKey:@"err_code"];
//            //[str appendString:[dd objectForKey:@"err_code"]];
//            //            [str stringByAppendingString:[dd objectForKey:@"err_code"]];
//        }
//    }
    
    return str;
}
#pragma mark 控制台
- (void)showLog:(NSString*)firstObject, ...{

    NSMutableString *allStr=[[NSMutableString alloc]initWithCapacity:0];
    
    NSString *eachObject=nil;
    va_list argumentList;
    if (firstObject>=0)
    {
        [allStr appendFormat:@"%@",firstObject];
        
        va_start(argumentList, firstObject);          // scan for arguments after firstObject.
        eachObject = va_arg(argumentList, NSString*);
        while (eachObject!=nil) // get rest of the objects until nil is found
        {

            [allStr appendFormat:@"\n-------------------------------------------------\n%@",eachObject];
            
            eachObject = va_arg(argumentList, NSString*);
        }
        va_end(argumentList);
    }
    
    CGRect frm=self.view.bounds;
    if (vQLog==nil) {
        vQLog=[[UIView alloc]initWithFrame:frm];
        
        frm.size.height-=80;
        frm.size.width-=2;
        frm.origin.x=1;
        frm.origin.y=20;
        txtQLog=[[UITextView alloc]initWithFrame:frm];
        txtQLog.editable=NO;
        [vQLog addSubview:txtQLog];
        
        frm.size.height=60;
        
        frm.origin.y=CGRectGetMaxY(txtQLog.frame)+1;
        UIButton *btn=[[UIButton alloc]initWithFrame:frm];
        [btn addTarget:self action:@selector(hideLogAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor=[UIColor clearColor];//[QYGlobal colorWithHexString:kMainColor alpha:1];
        [btn setTitle:@"关........闭" forState:UIControlStateNormal];
        [vQLog addSubview:btn];
        
        [self.view addSubview:vQLog];
    }
    
//    NSString *ss=allStr;
    if ([txtQLog.text length]) {
        [allStr appendFormat:@"\n\n++++++++++++++++++++++++++++++++++++++++++++++\n\n%@",txtQLog.text];
    }
    txtQLog.text=allStr;
    vQLog.hidden=NO;
}

- (void)hideLogAction:(id)sender{
    vQLog.hidden=YES;
    txtQLog.text=nil;
}

#pragma mark - Delegate 托管模块
#pragma mark MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
    /**
     *  HUD消失，添加对应方法
     */
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    
    return YES;
}



#pragma mark －
#pragma mark 返回上一页
- (IBAction)popVCAction:(id)sender{
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
            //
        }];
    }
}

- (void)backToPreviousController:(id)sender{
    
}

#pragma mark - share
// 选择某个平台后，开始调用分享服务
- (void)shareService:(ShareContentModel *)modelShare
{
    if (modelShare == nil) {
        return;
    }
    self.modelShare = modelShare;
    DDLogVerbose(@"the model share is %@",self.modelShare);
    //设置分享内容和回调对象
    [[UMSocialControllerService defaultControllerService] setShareText:@"分享" shareImage:[UIImage imageNamed:@"icon"] socialUIDelegate:self];
    //选择平台后调用
    [self selectPlatformService];
}

- (void)selectPlatformService
{
    NSString *strPlatform = @"";
    NSString *channel = @"";
    switch (self.modelShare.platform) {
        case SharePlatformSina:
        {
            strPlatform = UMShareToSina;
            channel = @"2";
        }
            break;
        case SharePlatformQQ:
        {
            strPlatform = UMShareToQzone;
            channel = @"3";
            if ([QQApiInterface isQQInstalled]) {
            } else {
                [self showError:@"您未安装QQ客户端，请先安装"];
                [self dismissShareView];
                return;
            }
        }
            break;
        case SharePlatformWechatSession:
        {
            strPlatform = UMShareToWechatSession;
            channel = @"1";
        }
            break;
        case SharePlatformWechatTimeline:
        {
            strPlatform = UMShareToWechatTimeline;
            channel = @"4";
        }
            break;
        default:
            break;
    }
    self.strChannel = channel;
    // 设置分享内容
    if (![self setupShareContent:strPlatform]) {
        return;
    }
    
    [UMSocialSnsPlatformManager getSocialPlatformWithName:strPlatform].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
    [self dismissShareView];
}

- (BOOL)setupShareContent:(NSString *)platformName
{
    NSString *strTrackPlatform = @"";
    NSString *strTrackTitle = @"";
    NSString *strTrackPage = @"";
    
 
    UIImage *imgShareContent = (self.modelShare.imgURL.length <= 0) ? [UIImage imageNamed:@"share_logo"] : [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.modelShare.imgURL]]];
    NSString *shareTextContent = @"";
    NSString *shareTextTitle = @"";
    NSString *shareURL = @"";
    NSMutableString *strTrackStr = [@"" mutableCopy];
    NSString *shareLogStr = @"";    // 分享事件统计
    switch (self.modelShare.typeShare) {
        case ShareTypeInfo:         //资讯详情
        {
            
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_HEALTHINFO_WITHVERSION(self.modelShare.shareID);
            shareTextTitle = (self.modelShare.title.length > 0) ? self.modelShare.title : @"分享资讯";
                shareTextContent = self.modelShare.content;
            strTrackPage = @"健康资讯";
            strTrackTitle = shareTextTitle;

            [QWGLOBALMANAGER statisticsEventId:@"资讯详情_分享" withLable:@"资讯" withParams:nil];
            
            shareLogStr = @"资讯详情_分享渠道";
        }
            break;
        case ShareTypeDisease:      // 疾病一级详情
        {
            shareTextTitle = (self.modelShare.title.length > 0) ? self.modelShare.title : @"分享疾病";// [NSString stringWithFormat:@"我在使用问药APP，连接你与你身边的药店，了解更多%@详情，请点击",self.modelShare.title];
            shareTextContent = (self.modelShare.content.length > 0) ? self.modelShare.content : [NSString stringWithFormat:@"想了解更多%@详情，请点击",self.modelShare.title];
            strTrackPage = @"疾病";
            strTrackTitle = shareTextTitle;
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_DISEASE_WITHVERSION(self.modelShare.shareID,QWGLOBALMANAGER.deviceToken);
        }
            break;
        case ShareTypeMedicine:     // 药品详情-无优惠
        {
            shareTextTitle = (self.modelShare.title.length > 0) ? self.modelShare.title : @"分享药品";
            shareTextContent = (self.modelShare.content.length > 0) ? self.modelShare.content : [NSString stringWithFormat:@"我在使用问药APP，分享%@",self.modelShare.title];
            strTrackPage = @"药品详情";
            strTrackTitle = shareTextTitle;
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_DRUGDETAIL_WITHVERSION(self.modelShare.shareID,QWGLOBALMANAGER.deviceToken);
        }
            break;
        case ShareTypePharmacy:     // 药房详情
        {
            shareTextTitle = (self.modelShare.title.length > 0) ? self.modelShare.title : @"分享药房";
            shareTextContent = (self.modelShare.content.length > 0) ? self.modelShare.content : [NSString stringWithFormat:@"我在问药客户端发现了%@, 很不错噢",self.modelShare.title];
            strTrackPage = @"药房详情";
            strTrackTitle = shareTextTitle;
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_STORE_WITHVERSION(self.modelShare.shareID);
        }
            break;
        case ShareTypeSymptom:      //症状详情
        {
            shareTextTitle = (self.modelShare.title.length > 0) ? self.modelShare.title : @"分享症状";
            shareTextContent = (self.modelShare.content.length > 0) ? self.modelShare.content : [NSString stringWithFormat:@"想了解更多%@详情，请点击",self.modelShare.title];
            strTrackPage = @"症状详情";
            strTrackTitle = shareTextTitle;
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_SYMPTOM_WITHVERSION(self.modelShare.shareID,QWGLOBALMANAGER.deviceToken);
        }
            break;
        case ShareTypeRecommendFriends:
        {
            shareTextTitle = (self.modelShare.title.length > 0) ? self.modelShare.title : [NSString stringWithFormat:@"问药，您的口袋药房，不仅仅是优惠~"];
            shareTextContent = (self.modelShare.content.length > 0) ? self.modelShare.content : [NSString stringWithFormat:@"比医生更懂药，比药房更便捷，注册即送50积分，任性兑换不花钱，更有万分豪礼等你来拿~"];
            strTrackPage = @"推荐好友";
            strTrackTitle = shareTextTitle;
            shareURL = self.modelShare.shareLink;
            shareLogStr = @"我的_邀请好友_渠道";
        }
            break;
        case ShareTypeCommonActivity:
        {
            shareTextTitle = (self.modelShare.title.length > 0) ? self.modelShare.title : @"分享优惠活动";
            shareTextContent = (self.modelShare.content.length > 0) ? self.modelShare.content : [NSString stringWithFormat:@"我在问药客户端发现了%@, 很不错噢",self.modelShare.title];
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_WITHACTIVITY(self.modelShare.shareID);
        }
            break;
        case ShareTypePharmacyWithActivity:     // 2、药房详情－优惠活动的分享
        {
            shareTextTitle = (self.modelShare.title.length > 0) ? self.modelShare.title : @"分享优惠活动";
            shareTextContent = (self.modelShare.content.length > 0) ? self.modelShare.content : [NSString stringWithFormat:@"我在问药客户端发现了%@, 很不错噢",self.modelShare.title];
            NSArray *arrPharm = [self.modelShare.shareID componentsSeparatedByString:SeparateStr];
            shareURL = @"";
            if (arrPharm.count == 2) {
                shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_STORE_WITHPROMOTION_WITHVERSION(arrPharm[0], arrPharm[1],QWGLOBALMANAGER.deviceToken);
            }
            strTrackPage = @"药房详情－优惠活动";
            strTrackTitle = shareTextTitle;
        }
            break;
        case ShareTypeMedicineWithPromotion:        // 药品详情-带优惠游动
        {
            shareTextTitle = (self.modelShare.title.length > 0) ? self.modelShare.title : [NSString stringWithFormat:@"劲爆优惠，一手掌握"];
            shareTextContent = (self.modelShare.content.length > 0) ? self.modelShare.content : [NSString stringWithFormat:@"劲爆优惠 全民疯抢 问药领优惠 购药更实惠"];
            strTrackPage = @"药品详情－优惠活动";
            strTrackTitle = shareTextTitle;
            NSArray *arrPharm = [self.modelShare.shareID componentsSeparatedByString:SeparateStr];
            shareURL = @"";
            if (arrPharm.count == 2) {
                shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_DRUGDETAIL_WITHPROMOTION_WITHVERSION(arrPharm[0], arrPharm[1],QWGLOBALMANAGER.deviceToken);
            }
        }
            break;
        case ShareTypeGetCouponList:        // 领券中心列表
        {
            shareTextTitle = [NSString stringWithFormat:@"劲爆优惠 全民疯抢 问药领优惠 购药更实惠"];
            shareTextContent = [NSString stringWithFormat:@"劲爆优惠 全民疯抢 问药领优惠 购药更实惠"];
            strTrackPage = @"领券中心列表";
            strTrackTitle = shareTextTitle;   
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_GET_COUPONLIST_WITHVERSION;
        }
            break;
        case ShareTypeSubject:
        {
            shareTextTitle = (self.modelShare.title.length > 0) ? self.modelShare.title : @"分享专题";
            shareTextContent = self.modelShare.content;
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_SUBJECT_WITHVERSION(self.modelShare.shareID);
            strTrackPage = @"专题详情";
            strTrackTitle = shareTextTitle;
            
        }
            break;
        case ShareTypeDivision:
        {
            shareTextTitle = (self.modelShare.title.length > 0) ? self.modelShare.title : @"分享专区";
            shareTextContent = (self.modelShare.content.length > 0) ? self.modelShare.content : shareTextTitle;
            strTrackPage = @"专区详情";
            strTrackTitle = shareTextTitle;
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_DIVISION_WITHVERSION(self.modelShare.shareID,QWGLOBALMANAGER.deviceToken);
        }
            break;
        case ShareTypeSlowDiseaseCoupon:            // 慢病优惠券使用前分享
        {
            shareTextTitle = (self.modelShare.title.length > 0) ? self.modelShare.title : [NSString stringWithFormat:@"比快不如比实在，用问药优惠实在太赞了，你也赶紧来试试吧"];
            shareTextContent = (self.modelShare.content.length > 0) ? self.modelShare.content : [NSString stringWithFormat:@"劲爆优惠 全民疯抢 问药领优惠 购药更实惠"];
            strTrackPage = @"慢病优惠券使用前分享";
            strTrackTitle = shareTextTitle;
            NSArray *arrPharm = [self.modelShare.shareID componentsSeparatedByString:SeparateStr];
            shareURL = @"";
            if (arrPharm.count == 2) {
                shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_SLOWDISEASECOUPON_WITHVERSION(arrPharm[0], arrPharm[1], QWGLOBALMANAGER.deviceToken);
            }
        }
            break;
        case ShareTypeMyCoupon:                 // 我的－优惠券详情的分享（使用前)
        {
            shareTextTitle = (self.modelShare.title.length > 0) ? self.modelShare.title : [NSString stringWithFormat:@"比快不如比实在，用问药优惠实在太赞了，你也赶紧来试试吧"];
            shareTextContent = (self.modelShare.content.length > 0) ? self.modelShare.content : [NSString stringWithFormat:@"劲爆优惠 全民疯抢 问药领优惠 购药更实惠"];
            strTrackPage = @"我的－优惠券详情";
            strTrackTitle = shareTextTitle;
            NSArray *arrPharm = [self.modelShare.shareID componentsSeparatedByString:SeparateStr];
            shareURL = @"";
            
            if(!StrIsEmpty(self.modelShare.shareLink))
//                shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_MY_COUPON_WITHVERSION(arrPharm[0], arrPharm[1], QWGLOBALMANAGER.deviceToken);
//                
//                //fiexd by lijian at V3.2.0
            shareURL = self.modelShare.shareLink;

            shareLogStr = @"x_yhq_fxqd";
        }
            break;
        case ShareTypeMyDrug:                 // 我的－优惠商品详情的分享（使用前)
        {
            shareTextTitle = (self.modelShare.title.length > 0) ? self.modelShare.title : [NSString stringWithFormat:@"劲爆优惠，一手掌握"];
            shareTextContent = (self.modelShare.content.length > 0) ? self.modelShare.content : [NSString stringWithFormat:@"劲爆优惠 全民疯抢 问药领优惠 购药更实惠"];
            strTrackPage = @"我的－优惠券详情";
            strTrackTitle = shareTextTitle;
            NSArray *arrPharm = [self.modelShare.shareID componentsSeparatedByString:SeparateStr];
            shareURL = @"";
            if (arrPharm.count == 2) {
                shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_MY_DRUG_WITHVERSION(arrPharm[0], arrPharm[1], QWGLOBALMANAGER.deviceToken);
            }
        }
            break;
        case ShareTypeOuterLink:
        {
            // 分享外链
            shareTextTitle = self.modelShare.title;//[NSString stringWithFormat:@"劲爆优惠，一手掌握"];
            shareTextContent = (self.modelShare.content.length > 0) ? self.modelShare.content : [NSString stringWithFormat:@""];
            strTrackPage = @"分享外链";
            strTrackTitle = shareTextTitle;
            shareURL = self.modelShare.shareLink;
        }
            break;
        case ShareTypeHealthMeasurement:
        {
            // 健康自测
            shareTextTitle = self.modelShare.title;
            shareTextContent = (self.modelShare.content.length > 0) ? self.modelShare.content : [NSString stringWithFormat:@""];
            shareURL = self.modelShare.shareLink;
        }
            break;
        case ShareTypeHealthCheckDetail:
        {   // 健康自测详情
            shareTextTitle = self.modelShare.title;
            shareTextContent = (self.modelShare.content.length > 0) ? self.modelShare.content : [NSString stringWithFormat:@""];
            shareURL = self.modelShare.shareLink;
            shareLogStr = @"x_fx_jkgj_fxqd";
        }
            break;
        case ShareTypeFanPai:
        {
            // 翻牌子
            shareTextTitle = self.modelShare.title;//[NSString stringWithFormat:@"劲爆优惠，一手掌握"];
            shareTextContent = (self.modelShare.content.length > 0) ? self.modelShare.content : [NSString stringWithFormat:@""];
            strTrackPage = @"分享外链";
            strTrackTitle = shareTextTitle;
            shareURL = self.modelShare.shareLink;
        }
            break;
        case ShareTypePostDetail:
        {
            // 帖子详情分享
            shareTextTitle = self.modelShare.title;
            shareTextContent = self.modelShare.content;
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_POST_DETAIL(self.modelShare.shareID,DEVICE_ID);
            strTrackPage = @"帖子详情_分享渠道";
            NSString* paramValue = @"渠道名";
            if ([platformName isEqualToString:UMShareToSina]) {
                paramValue = @"新浪微博";
            }
            else if ([platformName isEqualToString:UMShareToQzone]) {
                paramValue = @"QQ空间";
            }
            else if ([platformName isEqualToString:UMShareToWechatSession]) {
                paramValue = @"微信好友";
            }
            else if ([platformName isEqualToString:UMShareToWechatTimeline]) {
                paramValue = @"微信朋友圈";
            }
            [QWGLOBALMANAGER statisticsEventId:strTrackPage withLable:@"帖子详情-分享-渠道" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"渠道名":paramValue}]];
        }
            break;
        case ShareTypeIntegralProDetail:
        {
            // 积分商城商品详情分享
            shareTextTitle = self.modelShare.title;
            shareTextContent = self.modelShare.content;
            shareURL = self.modelShare.shareLink;//(self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_POST_DETAIL(self.modelShare.shareID,DEVICE_ID);
        }
            break;
        case ShareTypeActivityList:
        {
            // 活动列表分享
            shareTextTitle = self.modelShare.title;
            shareTextContent = self.modelShare.content;
            shareURL = self.modelShare.shareLink;
        }
            break;
        case ShareTypeWechatProduct:
        {
            // 微商商品详情分享
            shareTextTitle = self.modelShare.title;
            shareTextContent = self.modelShare.content;
            shareURL = self.modelShare.shareLink;
        }
        default:
            break;
    }
    //短信、qq好友
    if (shareTextTitle.length == 0) {
        [self showError:@"无法获取分享内容，请稍后重试"];
        [self dismissShareView];
        return NO;
    }
    if (shareURL.length == 0) {
        [self showError:@"无法获取分享内容，请稍后重试"];
        [self dismissShareView];
        return NO;
    }
    if (imgShareContent == nil) {
        imgShareContent = [UIImage imageNamed:@"share_logo"];
    }
    BOOL canTrack = NO;
    if (strTrackStr.length > 0) {
        canTrack = YES;
    }
    if (platformName == UMShareToQzone) {
        [UMSocialData defaultData].extConfig.qzoneData.shareImage = imgShareContent;

        [UMSocialData defaultData].extConfig.qzoneData.title = shareTextTitle;
        [UMSocialData defaultData].extConfig.qzoneData.shareText = shareTextContent;
        [UMSocialData defaultData].extConfig.qzoneData.url = shareURL;
        
        [strTrackStr appendString:@"qqzone"];
        strTrackPlatform = @"QQ空间";
        if (shareLogStr.length > 0) {
            NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
            tdParams[@"渠道名"]=@"qq空间";
            [QWGLOBALMANAGER statisticsEventId:shareLogStr withLable:@"分享渠道" withParams:tdParams];
        }
        //微信
    }else if (platformName == UMShareToWechatSession){
        [UMSocialData defaultData].extConfig.wechatSessionData.title = shareTextTitle;
        [UMSocialData defaultData].extConfig.wechatSessionData.shareText = shareTextContent;
        [UMSocialData defaultData].extConfig.wechatSessionData.shareImage = imgShareContent;
        [UMSocialData defaultData].extConfig.wechatSessionData.url = shareURL;
        [strTrackStr appendString:@"wxhaoyou"];
        strTrackPlatform = @"QQ空间";
        if (shareLogStr.length > 0) {
            NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
            tdParams[@"渠道名"]=@"微信好友";
            [QWGLOBALMANAGER statisticsEventId:shareLogStr withLable:@"分享渠道" withParams:tdParams];
        }
    }//微信朋友圈
    else if (platformName == UMShareToWechatTimeline){
        if ((self.modelShare.typeShare == ShareTypeMedicineWithPromotion)||
            (self.modelShare.typeShare == ShareTypeSlowDiseaseCoupon)||
            (self.modelShare.typeShare == ShareTypeMyCoupon)||
            (self.modelShare.typeShare == ShareTypeMyDrug)||
            (self.modelShare.typeShare == ShareTypeMedicine)) {
            [UMSocialData defaultData].extConfig.wechatTimelineData.title = shareTextContent;
        } else {
            [UMSocialData defaultData].extConfig.wechatTimelineData.title = shareTextTitle;
        }
        [UMSocialData defaultData].extConfig.wechatTimelineData.shareText = shareTextContent;
        [UMSocialData defaultData].extConfig.wechatTimelineData.shareImage = imgShareContent;
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareURL;
        
        [strTrackStr appendString:@"wxcircle"];
        strTrackPlatform = @"QQ空间";
        if (shareLogStr.length > 0) {
            NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
            tdParams[@"渠道名"]=@"微信朋友圈";
            [QWGLOBALMANAGER statisticsEventId:shareLogStr withLable:@"分享渠道" withParams:tdParams];
        }
        //新浪微博、腾讯微博 self.infoDict[@"htmlUrl"]
    }else if (platformName == UMShareToSina) {
        [UMSocialData defaultData].extConfig.sinaData.shareText = [NSString stringWithFormat:@"%@,%@",shareTextContent,shareURL];
        [strTrackStr appendString:@"sinaweibo"];
        strTrackPlatform = @"微博";
        [UMSocialData defaultData].extConfig.sinaData.shareImage = imgShareContent;
        [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:shareURL];
        if (shareLogStr.length > 0) {
            NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
            tdParams[@"渠道名"]=@"新浪微博";
            [QWGLOBALMANAGER statisticsEventId:shareLogStr withLable:@"分享渠道" withParams:tdParams];
        }
    } else {
        //其他分享平台
    }

    if (canTrack) {

    }
    return YES;
}




- (void)popUpShareView:(ShareContentModel *)modelShare
{
    if (modelShare == nil) {
        return;
    }
    self.modelShare = modelShare;
    if (self.viewCusShare == nil) {
        self.viewCusShare = (CustomShareView *)[[NSBundle mainBundle] loadNibNamed:@"CustomShareView" owner:self options:nil][0];
        if (modelShare.typeShare == ShareTypeRecommendFriends) {
            self.viewCusShare.titleLabel.text = @"邀请好友";
        }
        
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self.viewCusShare];
        [self.viewCusShare.btnDismissShareView addTarget:self
                                                  action:@selector(dismissShareView)
                                        forControlEvents:UIControlEventTouchUpInside];
        [self.viewCusShare.btnShareWeChatTimeline addTarget:self
                                                     action:@selector(btnPressedShareToPlatform:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewCusShare.btnShareWeChatSession addTarget:self
                                                     action:@selector(btnPressedShareToPlatform:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewCusShare.btnShareQZone addTarget:self
                                                     action:@selector(btnPressedShareToPlatform:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewCusShare.btnShareSina addTarget:self
                                                     action:@selector(btnPressedShareToPlatform:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    self.viewCusShare.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.viewCusShare.alpha = 1;
    self.viewCusShare.viewBG.alpha = 0;
    CGRect rectFrame = self.viewCusShare.viewShareContent.frame;
    [UIView animateWithDuration:0.25 animations:^{
        self.viewCusShare.viewBG.alpha = 1;
        self.viewCusShare.viewShareContent.hidden = NO;
    } completion:^(BOOL finished) {
        self.viewCusShare.constraintContentTop.constant = -130;
        [self.viewCusShare setNeedsLayout];
        [UIView animateWithDuration:1.0 animations:^{
            self.viewCusShare.constraintContentTop.constant = 0;
            [self.viewCusShare setNeedsLayout];
        } completion:^(BOOL finished) {
           
        }];
    }];
    // 统计
    if ((modelShare.typeShare == ShareTypeMyCoupon)) {
        NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
        tdParams[@"优惠券内容"]=self.modelShare.content;
        tdParams[@"是否开通微商"]=QWGLOBALMANAGER.weChatBusiness ? @"是" : @"否" ;
        [QWGLOBALMANAGER statisticsEventId:@"x_yhq_fx" withLable:@"优惠券详情" withParams:tdParams];
    }
}

- (void)btnPressedShareToPlatform:(id)sender
{
    UIButton *btnShare = (UIButton *)sender;
    NSString *strSharePlatform = @"";
     NSString *refid = @"";
    if (btnShare == self.viewCusShare.btnShareWeChatTimeline) {
        self.modelShare.platform = SharePlatformWechatTimeline;
        refid = @"app_wxpyq";
        strSharePlatform = @"微信朋友圈";
    } else if (btnShare == self.viewCusShare.btnShareWeChatSession) {
        self.modelShare.platform = SharePlatformWechatSession;
        refid = @"app_wxhy";
        strSharePlatform = @"微信聊天";
    } else if (btnShare == self.viewCusShare.btnShareQZone) {
        self.modelShare.platform = SharePlatformQQ;
        refid = @"app_qqkj";
        strSharePlatform = @"QQ";
    } else if (btnShare == self.viewCusShare.btnShareSina) {
        self.modelShare.platform = SharePlatformSina;
        refid = @"app_xlwb";
        strSharePlatform = @"新浪微博";
    }

    
    __block NSString *shareURL = @"";
    switch (self.modelShare.typeShare) {
        case ShareTypeInfo:         //资讯详情
        {
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_HEALTHINFO_WITHVERSION(self.modelShare.shareID);
        }
            break;
        case ShareTypeDisease:      // 疾病一级详情
        {
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_DISEASE_WITHVERSION(self.modelShare.shareID,QWGLOBALMANAGER.deviceToken);
        }
            break;
        case ShareTypeMedicine:     // 药品详情-无优惠
        {
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_DRUGDETAIL_WITHVERSION(self.modelShare.shareID,QWGLOBALMANAGER.deviceToken);
        }
            break;
        case ShareTypePharmacy:     // 药房详情
        {
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_STORE_WITHVERSION(self.modelShare.shareID);
        }
            break;
        case ShareTypeSymptom:      //症状详情
        {
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_SYMPTOM_WITHVERSION(self.modelShare.shareID,QWGLOBALMANAGER.deviceToken);
        }
            break;
        case ShareTypeRecommendFriends:
        {   // 邀请好友
            shareURL = self.modelShare.shareLink;
            if ([self.modelShare.typeCome isEqualToString:@"2"]) {
                
                NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
                tdParams[@"具体渠道"]=strSharePlatform;
                tdParams[@"用户等级"] = StrFromInt(QWGLOBALMANAGER.configure.mbrLvl);
                [QWGLOBALMANAGER statisticsEventId:@"x_jfrw_yqhy_qd" withLable:@"积分任务" withParams:tdParams];
            } else {
                NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
                tdParams[@"哪个渠道"]=strSharePlatform;
                tdParams[@"用户等级"] = StrFromInt(QWGLOBALMANAGER.configure.mbrLvl);
                [QWGLOBALMANAGER statisticsEventId:@"x_wd_yqhy_qd" withLable:@"邀请好友" withParams:tdParams];
            }

        }
            break;
        case ShareTypeCommonActivity:
        {
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_WITHACTIVITY(self.modelShare.shareID);
        }
            break;
        case ShareTypePharmacyWithActivity:     // 2、药房详情－优惠活动的分享
        {
            NSArray *arrPharm = [self.modelShare.shareID componentsSeparatedByString:SeparateStr];
            if (arrPharm.count == 2) {
                shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_STORE_WITHPROMOTION_WITHVERSION(arrPharm[0], arrPharm[1],QWGLOBALMANAGER.deviceToken);
            }
        }
            break;
        case ShareTypeMedicineWithPromotion:        // 药品详情-带优惠游动
        {
            NSArray *arrPharm = [self.modelShare.shareID componentsSeparatedByString:SeparateStr];
            if (arrPharm.count == 2) {
                shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_DRUGDETAIL_WITHPROMOTION_WITHVERSION(arrPharm[0], arrPharm[1],QWGLOBALMANAGER.deviceToken);
            }
        }
            break;
        case ShareTypeGetCouponList:        // 领券中心列表
        {
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_GET_COUPONLIST_WITHVERSION;
            NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
            tdParams[@"渠道属性"]=strSharePlatform;
            [QWGLOBALMANAGER statisticsEventId:@"x_lqzx_fxqd" withLable:@"领券中心" withParams:tdParams];
        }
            break;
        case ShareTypeSubject:
        {
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_SUBJECT_WITHVERSION(self.modelShare.shareID);
        }
            break;
        case ShareTypeDivision:
        {
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_DIVISION_WITHVERSION(self.modelShare.shareID,QWGLOBALMANAGER.deviceToken);
        }
            break;
        case ShareTypeSlowDiseaseCoupon:            // 慢病优惠券使用前分享
        {
            NSArray *arrPharm = [self.modelShare.shareID componentsSeparatedByString:SeparateStr];
            if (arrPharm.count == 2) {
                shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_SLOWDISEASECOUPON_WITHVERSION(arrPharm[0], arrPharm[1], QWGLOBALMANAGER.deviceToken);
            }
        }
            break;
        case ShareTypeMyCoupon:                 // 我的－优惠券详情的分享（使用前)
        {
            NSArray *arrPharm = [self.modelShare.shareID componentsSeparatedByString:SeparateStr];
            if (arrPharm.count > 0) {
                    shareURL = [NSString stringWithFormat:@"%@QWWAP/discount/html/couponSub.html?id=%@&branchId=%@&type=1",H5_NEW_SHARE_URL,arrPharm[0],[QWGLOBALMANAGER getMapBranchId]];
            }

        }
            break;
        case ShareTypeMyDrug:                 // 我的－优惠商品详情的分享（使用前)
        {
            NSArray *arrPharm = [self.modelShare.shareID componentsSeparatedByString:SeparateStr];
            if (arrPharm.count == 2) {
                shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_MY_DRUG_WITHVERSION(arrPharm[0], arrPharm[1], QWGLOBALMANAGER.deviceToken);
            }
        }
            break;
        case ShareTypeOuterLink:
        {
            shareURL = self.modelShare.shareLink;
        }
            break;
        case ShareTypeHealthMeasurement:
        {
            shareURL = self.modelShare.shareLink;
        }
            break;
        case ShareTypeHealthCheckDetail:
        {
            shareURL = self.modelShare.shareLink;
            NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
//            tdParams[@"自测标题"]=self.modelShare.title == nil ? @"" : self.modelShare.title;
            [QWGLOBALMANAGER statisticsEventId:@"自查_健康评测_分享" withLable:@"健康自测" withParams:tdParams];
        }
            break;
        case ShareTypeFanPai:
        {
            shareURL = [NSString stringWithFormat:@"%@&refid=%@",self.modelShare.shareLink,refid];
        }
            break;
        case ShareTypePostDetail:
        {
            shareURL = (self.modelShare.shareLink.length > 0) ? self.modelShare.shareLink : SHARE_URL_POST_DETAIL(self.modelShare.shareID,DEVICE_ID);
        }
            break;
        case ShareTypeIntegralProDetail:
        {
            shareURL = self.modelShare.shareLink;
        }
            break;
        case ShareTypeActivityList:
        {
            shareURL = self.modelShare.shareLink;
        }
            break;
        case ShareTypeWechatProduct:
        {
            shareURL = self.modelShare.shareLink;
        }
            break;
        default:
            break;
    }
    // 长连接转换短链接
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"originalUrl"] = StrFromObj(shareURL);
    [System systemShortWithParams:setting success:^(id obj) {
        if ([obj[@"apiStatus"] integerValue] == 0) {
            NSString * sinaUrl = obj[@"shortUrl"];
            self.modelShare.shareLink = sinaUrl;
        }
        [self shareService:self.modelShare];
    } failure:^(HttpException *e) {
        [self shareService:self.modelShare];
    }];
}

- (void)dismissShareView
{
    [UIView animateWithDuration:0.25 animations:^{
        self.viewCusShare.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.viewCusShare.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
    }];
}

- (void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    DDLogVerbose(@"platformName = %@  socialData = %@",platformName,socialData);
}
#pragma mark -
#pragma mark 社会分享delegate
//- (void)didFinishGetUMSocialDataResponse:(UMSocialResponseEntity *)response
//{
//    DDLogVerbose(@"+++++++ success");
//}
//
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    DDLogVerbose(@"+++++++ success");
    if (response.responseCode == UMSResponseCodeSuccess) {
        [self shareFeedbackSuccess];
    } else {
        DDLogError(@"fail error %@",response.description);
    }
//    [self didFinishGetUMSocialDataInViewController:response];
}

- (void)shareFeedbackSuccess
{
    DDLogVerbose(@"### 分享成功");

    // 分享统计
    RptShareSaveLogModelR *modelR = [RptShareSaveLogModelR new];
    modelR.channel = self.strChannel;
    modelR.client = @"1";
    modelR.device = @"2";
    modelR.obj = self.modelShare.modelSavelog.shareObj;
    modelR.objId = self.modelShare.modelSavelog.shareObjId;
    if (modelR.obj == nil) {
        modelR.obj = @"0";
    }
    if (modelR.objId == nil) {
        modelR.objId = @"";
    }
    
    MapInfoModel *mapInfoModel = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
    if(mapInfoModel) {
        modelR.city = mapInfoModel.city;
        modelR.province = mapInfoModel.province;
    }else{
        modelR.city = @"苏州市";
        modelR.province = @"江苏省";
    }
    NSString *strToken = self.modelShare.modelSavelog.token;
    if (QWGLOBALMANAGER.configure.userToken.length > 0) {
        strToken = QWGLOBALMANAGER.configure.userToken;
    }
    modelR.token = strToken;
    // 添加每月统计次数的需求
    // comment in V2.2.4
    
    if (self.modelShare.typeShare == ShareTypeRecommendFriends) {
        
    } else if (self.modelShare.typeShare == ShareTypePostDetail) {
        PostShareR* postShareR = [PostShareR new];
        postShareR.token = QWGLOBALMANAGER.configure.userToken;
        postShareR.postId = self.modelShare.shareID;
        // （1:微信, 2:微博, 3:QQ, 4:朋友圈）
        switch (self.modelShare.platform) {
            case SharePlatformWechatTimeline:
                postShareR.channel = 4;
                break;
            case SharePlatformWechatSession:
                postShareR.channel = 1;
                break;
                
            case SharePlatformQQ:
                postShareR.channel = 3;
                break;
            case SharePlatformSina:
                postShareR.channel = 2;
                break;
            default:
                break;
        }
        
        [Forum sharePost:postShareR success:^(QWCirclePostShareModel *postShareModel) {
            if ([postShareModel.apiStatus integerValue] == 0) {
                DDLogInfo(@"分享成功  渠道: %@", postShareR);
                if (postShareModel.taskChanged) {
                    [QWProgressHUD showSuccessWithStatus:@"分享" hintString:[NSString stringWithFormat:@"+%ld", (long)[QWGLOBALMANAGER rewardScoreWithTaskKey:CreditTaskKey_Share]] duration:DURATION_CREDITREWORD];
                }
            }
        } failure:^(HttpException *e) {
            DDLogInfo(@"分享失败  error : %@", e);
        }];
    } else {
        [self callSaveLogRequest:modelR];
    }
    
    

    DDLogVerbose(@"model share is %d",self.modelShare.typeShare);
}
- (void)shareFeedbackFailed
{
    DDLogVerbose(@"### 分享失败");
    DDLogVerbose(@"model share is %d",self.modelShare.typeShare);
}

- (void)callSaveLogRequest:(RptShareSaveLogModelR *)modelSave
{
    DDLogVerbose(@"the model r is %@",modelSave);
    [System rptShareSaveLog:modelSave success:^(id responseModel) {
        NSString *strChanged = responseModel[@"taskChanged"];
        DDLogVerbose(@"success, response is %@",strChanged);
        if ([strChanged intValue] == 1) {
            NSInteger intScore = [QWGLOBALMANAGER rewardScoreWithTaskKey:[NSString stringWithFormat:@"SHARE"]];
            [QWProgressHUD showSuccessWithStatus:@"分享成功!" hintString:[NSString stringWithFormat:@"+%d",intScore] duration:2.0];
            [self reloadDataAfterShare];
            if([self.modelShare.typeCome isEqualToString:@"1"]){//从我的个人中心进入
                [QWGLOBALMANAGER postNotif:NotifRefreshCurAppPageOne data:nil object:self];
            }else if ([self.modelShare.typeCome isEqualToString:@"2"]){//从我的积分进入
                [QWGLOBALMANAGER postNotif:NotifRefreshCurAppPageTwo data:nil object:self];
            }
          
            
        }
    } failure:^(HttpException *e) {
        DDLogVerbose(@"fail");
    }];
}

- (void)reloadDataAfterShare
{
}

#pragma mark 不知道谁加的方法
- (void)viewDidCurrentView{

}

- (void)zoomClick{
    
}
#pragma mark -加入购物车动画
-(void)JoinCartAnimationWithStratPoint:(CGPoint)sPoint endPoint:(CGPoint)EPoint middlePoint:(CGPoint)MPoint withImage:(UIImage *)image
{
    
    CGFloat startX = sPoint.x;
    CGFloat startY = sPoint.y;
    
    _path= [UIBezierPath bezierPath];
    [_path moveToPoint:CGPointMake(startX, startY)];
    
    //三点曲线
    [_path addCurveToPoint:CGPointMake(EPoint.x, EPoint.y)
             controlPoint1:CGPointMake(sPoint.x, sPoint.y)
             controlPoint2:CGPointMake(MPoint.x, MPoint.y)];
    
    _dotLayer = [CALayer layer];
    _dotLayer.contents = (__bridge id _Nullable)(image.CGImage);
    _dotLayer.backgroundColor = [UIColor redColor].CGColor;
    _dotLayer.frame = CGRectMake(0, 0, 61, 61);
    _dotLayer.cornerRadius = (15 + 15) /4;
    [[UIApplication sharedApplication].keyWindow.layer addSublayer:_dotLayer];
    [self groupAnimation];
    
}

#pragma mark - 组合动画
-(void)groupAnimation
{
    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    scaleAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    scaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.05, 0.05, 1.0)];
    
    scaleAnim.removedOnCompletion = YES;
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = _path.CGPath;
    animation.rotationMode = kCAAnimationRotateAuto;
    
    CAAnimationGroup *groups = [CAAnimationGroup animation];
    groups.animations = @[animation,scaleAnim];
    groups.duration = 0.5f;
    groups.removedOnCompletion = NO;
    groups.fillMode = kCAFillModeForwards;
    groups.delegate = self;
    [groups setValue:@"groupsAnimation" forKey:@"animationName"];
    [_dotLayer addAnimation:groups forKey:nil];
    
    [self performSelector:@selector(removeFromLayer:) withObject:_dotLayer afterDelay:0.5f];
    
}

- (void)removeFromLayer:(CALayer *)layerAnimation{
    
    [layerAnimation removeFromSuperlayer];
    
}

#pragma mark - 右侧图片按钮
//add by lijian at V4.0
- (void)naviRightBottonImage:(NSString *)imageStr action:(SEL)action
{
    CGRect frm = CGRectMake(0,0,44.0f,44.0f);
    _RightItemBtn = [[UIButton alloc] initWithFrame:frm];
    UIImage *image = [[UIImage imageNamed:imageStr] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [_RightItemBtn setImage:image forState:UIControlStateNormal];
    [_RightItemBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    _RightItemBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _RightItemBtn.backgroundColor=[UIColor clearColor];
    
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -13.0f;
    
    UIBarButtonItem* btnItem = [[UIBarButtonItem alloc] initWithCustomView:_RightItemBtn];
    self.navigationItem.rightBarButtonItems = @[fixed,btnItem];
}

#pragma mark - 导航栏颜色、分割线
//add by lijian at V4.0
- (void)setNavigationBarColor:(UIColor *)color Shadow:(BOOL)flag{
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if(color){
        CGContextSetFillColorWithColor(context,color.CGColor);
    }else{
        CGContextSetFillColorWithColor(context,RGBHex(qwColor4).CGColor);
    }
    CGContextFillRect(context, rect);
    UIImage * imge = [[UIImage alloc] init];
    imge = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.navigationController.navigationBar setBackgroundImage:imge forBarMetrics:UIBarMetricsDefault];
    if(flag){
        [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"img-shaow"]];
    }else{
        [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    }
}

#pragma mark - 立即登录背景提示
//add by lijian at V4.0
- (void)showLoginView:(NSString *)str image:(NSString *)imageName action:(SEL)selector{
    
    if(infoView == nil){
        infoView = [[UIView alloc]initWithFrame:self.view.frame];
        infoView.backgroundColor = RGBHex(qwColor11);
    }else{
        for(UIView *view in infoView.subviews){
            [view removeFromSuperview];
        }
    }
    
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((APP_W - image.size.width)/2.0f, 68.0f, image.size.width, image.size.height)];
    imageView.image = image;
    [infoView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, imageView.frame.origin.y + imageView.frame.size.height + 20.0f, APP_W - 20, 18)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = fontSystem(kFontS13);
    label.textColor = RGBHex(qwColor22);
    label.text = str;
    [infoView addSubview:label];
    
    UIButton *loginBtn = [[UIButton alloc]initWithFrame:CGRectMake((APP_W - 208.0f)/2.0f, label.frame.origin.y + label.frame.size.height + 21.0f, 208.0f, 42.0f)];
    [loginBtn setTitle:@"立即登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:RGBHex(qwColor7) forState:UIControlStateNormal];
    loginBtn.titleLabel.font = fontSystem(kFontS13);
    loginBtn.backgroundColor = RGBHex(qwColor4);
    loginBtn.layer.masksToBounds = YES;
    loginBtn.layer.cornerRadius = 7.0f;
    loginBtn.layer.borderWidth = 1.0f;
    loginBtn.layer.borderColor = RGBHex(qwColor10).CGColor;
    [loginBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:loginBtn];
    
    [self.view addSubview:infoView];
}

@end
