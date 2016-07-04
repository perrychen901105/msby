//
//  MedicineDetailViewController.m
//  APP
//  微商药品详情 3.0.0新增
//  使用接口如下：
//  h5/mmall/product/byId 店内药品详情
//  Created by 李坚 on 16/1/4.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "MedicineDetailViewController.h"
#import "MallBranchTableViewCell.h"
#import "ConsultStore.h"
#import "ShoppingCartViewController.h"
#import "MarketDetailViewController.h"
#import "BranchPromotionView.h"
#import "WebDirectViewController.h"
#import "SVProgressHUD.h"
#import "MallCart.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "XHImageViewer.h"
#import "MedicineUseTypeTableViewCell.h"
#import "MedicinePromotionTableViewCell.h"
#import "BarTwoViewController.h"
#import "ChooseCouponView.h"
#import "PackageView.h"
#import "SimpleShoppingCartViewController.h"
#import "LoginViewController.h"
#import "ChatViewController.h"
#import "ChatChooserViewController.h"
#import "RightIndexView.h"
#import "PromotionShower.h"
#import "UIViewController+KNSemiModal.h"
#import "PackageListShower.h"
#import "PharmacySotreViewController.h"

static NSString *const PromotionCellIdentifier = @"MedicinePromotionTableViewCell";
static NSString *const UseTypeCellIdentifier = @"MedicineUseTypeTableViewCell";
static NSString *const storeCellIdentifier = @"MallBranchTableViewCell";

@interface MedicineDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate,XLCycleScrollViewDatasource,XLCycleScrollViewDelegate,XHImageViewerDelegate,UIScrollViewDelegate>{
    
    CGFloat floatCouponDetailHeight;
    MedicineHeaderView *headerView;
    MedicineFooterView *footerView;
    XLCycleScrollView *cycleScrollView;
    MicroMallBranchProductVo *productDetail;
    UIImageView *brannerImage;
    UIView *loadingView;
}
@property (nonatomic, strong) RightIndexView *indexView;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIButton *addCarBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bttomLineConstant;
@property (weak, nonatomic) IBOutlet UIButton *goodCatBtn;
@property (weak, nonatomic) IBOutlet UIImageView *chatImage;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (weak, nonatomic) IBOutlet UILabel *chatLabel;
@end

@implementation MedicineDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.title = @"商品详情";
    floatCouponDetailHeight = 0.0;
    _bttomLineConstant.constant = 0.5f;
    if(StrIsEmpty(self.lastPageName)){
        self.lastPageName = @"未知";
    }
    [QWGLOBALMANAGER statisticsEventId:@"商品详情页出现" withLable:nil withParams:nil];
    _mainTableView.contentInset = UIEdgeInsetsMake(22, 0, 0, 0);
    
    //判断是否是从聊天页面跳转进入，是则隐藏咨询入口，防止页面push循环
    if(self.pushFromChatView){
        [self.chatBtn removeFromSuperview];
        [self.chatImage removeFromSuperview];
        [self.chatLabel removeFromSuperview];
    }
    
    [self naviRightBottonImage:@"icon_more_shoppin" action:@selector(returnIndex)];
    
    [self setupTableView];
    self.addCarBtn.enabled = NO;
    [self loadProductDetail];
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self naviLeftBottonImage:[UIImage imageNamed:@"icon_return_details"] highlighted:[UIImage imageNamed:@"icon_return_details"] action:@selector(popVCAction:)];
    [self setNavigationBarColor:[UIColor clearColor] Shadow:NO];
    
    if([QWGLOBALMANAGER getUnreadShoppingCart] > 0){
        _goodCountLabel.hidden = NO;
        _goodCountLabel.text = [NSString stringWithFormat:@"%d",(int)[QWGLOBALMANAGER getUnreadShoppingCart]];
    }else{
        _goodCountLabel.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self setNavigationBarColor:nil Shadow:YES];
    
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"img-shaow"]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if([scrollView isEqual:_mainTableView]){
        
        CGFloat offsetY = scrollView.contentOffset.y;
        CGFloat offsetH = 22 + offsetY;
        CGFloat alpha = offsetH / 22;
        
        [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[RGBHex(qwColor4) colorWithAlphaComponent:alpha]] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[self imageWithColor:[RGBHex(qwColor20) colorWithAlphaComponent:alpha]]];
        
        if(alpha > 1.0){
            if(self.RightItemBtn.alpha != 1.0){
                self.RightItemBtn.alpha = alpha - 1.0;
                self.LeftItemBtn.alpha = alpha - 1.0;
                [self.LeftItemBtn setImage:[UIImage imageNamed:@"arrow_slide_details"] forState:UIControlStateNormal];
                [self.LeftItemBtn setImage:[UIImage imageNamed:@"arrow_slide_details"] forState:UIControlStateHighlighted];
                [self.RightItemBtn setImage:[UIImage imageNamed:@"icon_more_slide_details"] forState:UIControlStateNormal];
            }
        }else{
            [self.LeftItemBtn setImage:[UIImage imageNamed:@"icon_return_details"] forState:UIControlStateNormal];
            [self.LeftItemBtn setImage:[UIImage imageNamed:@"icon_return_details"] forState:UIControlStateHighlighted];
            [self.RightItemBtn setImage:[UIImage imageNamed:@"icon_more_shoppin"] forState:UIControlStateNormal];
            self.RightItemBtn.alpha = 1.0 - alpha;
            self.LeftItemBtn.alpha = 1.0 - alpha;
        }
    }
}

#pragma mark - 返回一张纯色图片
/** 返回一张纯色图片 */
- (UIImage *)imageWithColor:(UIColor *)color {
    // 描述矩形
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    // 开启位图上下文
    UIGraphicsBeginImageContext(rect.size);
    // 获取位图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 使用color演示填充上下文
    CGContextSetFillColorWithColor(context, [color CGColor]);
    // 渲染上下文
    CGContextFillRect(context, rect);
    // 从上下文中获取图片
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    return theImage;
}
#pragma mark - 返回Action处理统计事件
- (void)popVCAction:(id)sender{
    [super popVCAction:sender];
    [QWGLOBALMANAGER statisticsEventId:@"x_ypxq_fh" withLable:@"药品详情" withParams:nil];
}

#pragma mark - XLCycleScrollViewDataSource
- (NSInteger)numberOfPages{
    
    if(productDetail){
        if(productDetail.imgUrls.count == 0){
            return 1;
        }else{
            return productDetail.imgUrls.count;
        }
    }else{
       return 1;
    }
}

- (UIView *)pageAtIndex:(NSInteger)index{
    
    brannerImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,APP_W, APP_W)];
    brannerImage.contentMode = UIViewContentModeScaleAspectFit;
    if(productDetail){
        if(productDetail.imgUrls.count == 0){
            [brannerImage setImage:[UIImage imageNamed:@"bg_nomal_two"]];
        }else{
            [brannerImage setImageWithURL:[NSURL URLWithString:productDetail.imgUrls[index]] placeholderImage:[UIImage imageNamed:@"bg_nomal_two"]];
        }
    }else{
        [brannerImage setImage:[UIImage imageNamed:@"bg_nomal_two"]];
        
    }
    return brannerImage;
}
- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index{
    [self showFullScreenImage:index];
}

#pragma mark - 右上角首页按钮点击Action
- (void)backToHome:(id)sender{
    [QWGLOBALMANAGER statisticsEventId:@"商品详情_返回首页" withLable:nil withParams:nil];

    [self performSelector:@selector(delayPop) withObject:nil afterDelay:0.01];
    QWGLOBALMANAGER.tabBar.selectedIndex = 0;
}

- (void)delayPop
{
    if(APPDelegate.mainVC.selectedTab == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:NO];
            APPDelegate.mainVC.selectedTab = 0;
        });
        
    }else{
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:NO];
            APPDelegate.mainVC.selectedTab = 0;
        });
    }
}

#pragma mark - 建立tableHeaderView
- (void)setupHeaderView{
    if(headerView == nil){
        headerView = [MedicineHeaderView getView];
        
        headerView.bannerHeight.constant = APP_W;
        headerView.frame = CGRectMake(0, 0, APP_W, 134.0f + APP_W);
        cycleScrollView = [[XLCycleScrollView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_W)];
        cycleScrollView.tag = 1008;
        cycleScrollView.datasource = self;
        cycleScrollView.delegate = self;
        [cycleScrollView setupUIControl];
        CGFloat PCFrameX = (APP_W - cycleScrollView.pageControl.frame.size.width)/2;
        CGRect rect = cycleScrollView.pageControl.frame;
        rect.origin.x = PCFrameX;
        cycleScrollView.pageControl.frame = rect;

        cycleScrollView.pageControl.pageIndicatorTintColor = RGBAHex(qwColor9, 0.3f);
        cycleScrollView.pageControl.currentPageIndicatorTintColor = RGBHex(qwColor1);
        
        [headerView.topView addSubview:cycleScrollView];
        _mainTableView.tableHeaderView = headerView;
    }
}

#pragma mark - 建立tableFooterView
- (void)setupFooterView{
    if(footerView == nil){
        footerView = [MedicineFooterView getView];
        footerView.frame = CGRectMake(0, 0, APP_W, 0.0f);
        footerView.WebCondition.backgroundColor = [UIColor clearColor];
        footerView.WebCondition.delegate = self;
        footerView.WebCondition.hidden = YES;
        footerView.drugLabel.hidden = YES;
//        [footerView.nearByStoreBtn addTarget:self action:@selector(nearStoreAction:) forControlEvents:UIControlEventTouchDown];
        _mainTableView.tableFooterView = footerView;
    }
}

#pragma mark - 购物车点击Action
- (IBAction)pushIntoGoodsCar:(id)sender {

    [QWGLOBALMANAGER checkEventId:@"商品详情_购物车" withLable:nil withParams:nil];
    
    SimpleShoppingCartViewController *simpleShoppingCartViewController = [[SimpleShoppingCartViewController alloc] initWithNibName:@"SimpleShoppingCartViewController" bundle:nil];
    simpleShoppingCartViewController.shouldRequireShoppingList = YES;
    [self.navigationController pushViewController:simpleShoppingCartViewController animated:YES];
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"上级页面"] = @"药品详情";
    [QWGLOBALMANAGER statisticsEventId:@"x_gwcym_cx" withLable:@"购物车页面-出现" withParams:setting];
    
}

#pragma mark - 全局通知接收
- (void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj{
    
    if(type == NotifShoppingUnreadUpdate){
        if([QWGLOBALMANAGER getUnreadShoppingCart] > 0){
            _goodCountLabel.hidden = NO;
            _goodCountLabel.text = [NSString stringWithFormat:@"%d",[QWGLOBALMANAGER getUnreadShoppingCart]];
        }else{
            _goodCountLabel.hidden = YES;
        }
    }
    if(type == NotifShoppingCartSync){
        [self goodAddAnimation];
    }
}

#pragma mark - 建立TableView
- (void)setupTableView{
    
    self.goodCountLabel.layer.masksToBounds = YES;
    self.goodCountLabel.layer.cornerRadius = 10.0f;
    
    [_mainTableView registerNib:[UINib nibWithNibName:storeCellIdentifier bundle:nil] forCellReuseIdentifier:storeCellIdentifier];
    [_mainTableView registerNib:[UINib nibWithNibName:PromotionCellIdentifier bundle:nil] forCellReuseIdentifier:PromotionCellIdentifier];
    [_mainTableView registerNib:[UINib nibWithNibName:UseTypeCellIdentifier bundle:nil] forCellReuseIdentifier:UseTypeCellIdentifier];

    _mainTableView.backgroundColor = RGBHex(qwColor4);
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - 商品详情静态web页面请求
- (void)requestWebWithUrl:(NSString *)url{
    
    [footerView.WebCondition loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

#pragma mark - 药品详情HTTP请求
- (void)loadProductDetail{
    
    [self showLoadingView];
    
    __weak __typeof(self) weakSelf = self;
 
    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) { //add by jxb
 
        ProductModelR *modelR = [ProductModelR new];
        modelR.id = weakSelf.proId;
        modelR.longitude = [NSString stringWithFormat:@"%f",mapInfoModel.location.coordinate.longitude];
        modelR.latitude = [NSString stringWithFormat:@"%f",mapInfoModel.location.coordinate.latitude];
        modelR.city = mapInfoModel.city;
        
        [ConsultStore StoreProductDetail:modelR success:^(MicroMallBranchProductVo *model) {
            [weakSelf removeLoadingView];
            if ([model.apiStatus integerValue] != 0) {
                [weakSelf showInfoView:@"抱歉，没有为您找到相关商品" image:@"icon_no result_search"];
            }
            else
            {
                productDetail = model;
                NSString *branchName = @"";
                if(model.branch.branchName.length == 0){
                    branchName = model.branch.name;
                }else{
                    branchName = model.branch.branchName;
                }
                [QWGLOBALMANAGER statisticsEventId:@"x_spxq_tjyf" withLable:@"商品详情页-推荐药房" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"药房名":branchName}]];
                [weakSelf refreshUI];
            }

         }failure:^(HttpException *e) {
             [weakSelf removeLoadingView];
             if(e.errorCode!=-999){
                 if(e.errorCode == -1001){
                     [weakSelf showInfoView:kWarning215N26 image:@"icon_no result_search"];
                 }else{
                     [weakSelf showInfoView:kWarning39 image:@"icon_no result_search"];
                 }
             }
        }];
    }];
}


- (void)showLoadingView{
    if(!loadingView){
        loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H)];
        loadingView.backgroundColor = RGBHex(qwColor4);
    }
    if(!loadingView.superview){
        [self.view addSubview:loadingView];
    }
}

- (void)removeLoadingView{
    [loadingView removeFromSuperview];
}

- (void)refreshUI{
    [self setupHeaderView];
    [self setupFooterView];
    [_mainTableView reloadData];
    [cycleScrollView reloadData];
    if([productDetail.status intValue] == 3){//商品售卖状态：2.在售 3.下架
        headerView.statusImage.image = [UIImage imageNamed:@"lable_shelves"];
        [self.addCarBtn setBackgroundColor:RGBHex(qwColor9)];
        self.addCarBtn.enabled = NO;
    }else if([productDetail.status intValue] == 2){
        if((productDetail.stock + productDetail.saleStock) == 0){
            headerView.statusImage.image = [UIImage imageNamed:@"lable_soldout"];
            [self.addCarBtn setBackgroundColor:RGBHex(qwColor9)];
            self.addCarBtn.enabled = NO;
        }else{
            headerView.statusImage.image = nil;
            [self.addCarBtn setBackgroundColor:RGBHex(qwColor2)];
            self.addCarBtn.enabled = YES;
        }
    }

    //赠送积分UI,add by lijian at V3.2.0
    if([productDetail.userScore intValue] != 0){
        headerView.scoreImage.hidden = NO;
        headerView.scoreLabel.hidden = NO;
        
        if(StrIsEmpty(productDetail.userScoreLimit)){
            headerView.scoreLabel.text = [NSString stringWithFormat:@"送%d积分",[productDetail.userScore intValue]];
        }else{
            headerView.scoreLabel.text = [NSString stringWithFormat:@"送%d积分，%@",[productDetail.userScore intValue],productDetail.userScoreLimit];
        }
    }else{
        headerView.scoreImage.hidden = YES;
        headerView.scoreLabel.hidden = YES;
    }
    
    headerView.proName.text = productDetail.name;
    headerView.quantityLabel.text = productDetail.spec;
    
    //折后价，原价
    if(productDetail.promotions.count > 0){
        BranchProductPromotionVo *VO = productDetail.promotions[0];
        //在进行中的
        if([VO.timeStatus intValue]==2){
            if([VO.type intValue] == 4 || [VO.type intValue] == 5){// 4.特价 5.抢购
                headerView.BPriceLabel.hidden = NO;
                headerView.moneyLine.hidden = NO;
                headerView.APiceLabel.text = [NSString stringWithFormat:@"￥%.2f",[productDetail.discountPrice floatValue]];
                headerView.BPriceLabel.text = [NSString stringWithFormat:@"￥%.2f",[productDetail.price floatValue]];
            }else{
                headerView.APiceLabel.text = [NSString stringWithFormat:@"￥%.2f",[productDetail.price floatValue]];
                headerView.BPriceLabel.hidden = YES;
                headerView.moneyLine.hidden = YES;
            }
        }else{
            headerView.APiceLabel.text = [NSString stringWithFormat:@"￥%.2f",[productDetail.price floatValue]];
            headerView.BPriceLabel.hidden = YES;
            headerView.moneyLine.hidden = YES;
        }
 
    }else{
        headerView.APiceLabel.text = [NSString stringWithFormat:@"￥%.2f",[productDetail.price floatValue]];
        headerView.BPriceLabel.hidden = YES;
        headerView.moneyLine.hidden = YES;
    }

    CGRect rect = headerView.frame;
    rect.size.height = APP_W + 93.0f;
    headerView.frame = rect;
    
    
    if(!StrIsEmpty(productDetail.redemptionInfo)){
        headerView.changeInfoLable.hidden=NO;
        headerView.changeInfoLable.text=productDetail.redemptionInfo;
        CGSize size =[GLOBALMANAGER sizeText:productDetail.redemptionInfo font:fontSystem(kFontS5) limitWidth:APP_W-30];
        headerView.centerViewConstant.constant=89.0f+size.height + 12.0f;
        rect.size.height = rect.size.height+size.height + 16.0f;
        headerView.frame = rect;
    }else{
        headerView.changeInfoLable.hidden=YES;
        headerView.centerViewConstant.constant=86.0f;
    }
    
    
    if([productDetail.signCode isEqualToString:@"1a"] || [productDetail.signCode isEqualToString:@"1b"]){//处方药
        headerView.signCodeLabel.font = fontSystem(kFontS5);
        headerView.signCodeLabel.textColor = RGBHex(qwColor7);
        rect.size.height = rect.size.height+ 46.0f ;
        headerView.frame = rect;
        headerView.footerLine.hidden = NO;
    }else{
        [headerView.signCodeLabel removeFromSuperview];
        [headerView.tishi removeFromSuperview];
        headerView.footerLine.hidden = YES;
    }

    _mainTableView.tableHeaderView = headerView;
    _mainTableView.tableFooterView = footerView;
    
    
//    [self requestWebWithUrl:[NSString stringWithFormat:@"http://192.168.5.235:8184/QWYH/web/drug/html/normal/yBizDrugDetail.html?id=%@",productDetail.id]];
    
    [self requestWebWithUrl:[NSString stringWithFormat:@"%@QWYH/web/drug/html/normal/yBizDrugDetail.html?id=%@",H5_BASE_URL,productDetail.id]];
}

#pragma mark - 咨询按钮点击事件
- (IBAction)chatAction:(id)sender {
    [QWGLOBALMANAGER statisticsEventId:@"商品详情_咨询按键" withLable:nil withParams:nil];

    if(!productDetail){//加一层判断，防止未请求完数据时点击咨询按钮奔溃
        return;
    }
    
    [QWGLOBALMANAGER statisticsEventId:@"x_spxq_zx" withLable:@"商品详情-咨询" withParams:nil];
    
    if(!QWGLOBALMANAGER.loginStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginViewController animated:YES];
        return;
    }
    
    //咨询按钮点击逻辑，fixed at V3.2.0 by lijian
    if(!productDetail.online && !productDetail.hasExpert){//药房既无药师也没有砖家，toast提示
        [SVProgressHUD showErrorWithStatus:@"本店暂无法为您提供咨询服务"];
        return;
    }

    if(productDetail.hasExpert){//药房下有砖家，跳转咨询选择中转页面
        
        ChatChooserViewController *chooseVC = [[ChatChooserViewController alloc]initWithNibName:@"ChatChooserViewController" bundle:nil];
        chooseVC.product = productDetail;
        chooseVC.branchId = productDetail.branch.branchId;
        chooseVC.branchName = productDetail.branch.branchName;
        chooseVC.branchLogo = productDetail.branch.branchLogo;
        chooseVC.online     = productDetail.online;
        [self.navigationController pushViewController:chooseVC animated:YES];
        
    }else{//药房下无砖家，直接跳转点对点聊天
        
        ChatViewController *chatVC = [[UIStoryboard storyboardWithName:@"ChatViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ChatViewController"];
        chatVC.sendConsultType = Enum_SendConsult_Drug;
        chatVC.product = productDetail;
        chatVC.branchId = productDetail.branch.branchId;
        chatVC.branchName = productDetail.branch.branchName;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

#pragma mark - 加入购物车点击事件
- (IBAction)addGoodsToCar:(id)sender {
    [QWGLOBALMANAGER checkEventId:@"商品详情_放入购物车" withLable:nil withParams:nil];
    
    if(QWGLOBALMANAGER.currentNetWork == kNotReachable)
    {
        [SVProgressHUD showErrorWithStatus:@"网络异常，请重试" duration:0.8];
        return;
    }
    
    CGPoint startPoint = [self.view convertPoint:self.addCarBtn.center toView:[UIApplication sharedApplication].keyWindow];
    CGPoint endPoint = [self.view convertPoint:self.goodCatBtn.center toView:[UIApplication sharedApplication].keyWindow];
    
    CGPoint midPoint = CGPointMake((startPoint.x + endPoint.x)/2.0f , (startPoint.y + endPoint.y)/2.0f - 180.0f);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    if(productDetail.imgUrls.count == 0){
        [imageView setImage:[UIImage imageNamed:@"bg_nomal_two"]];
    }else{
        [imageView setImageWithURL:[NSURL URLWithString:productDetail.imgUrls[0]] placeholderImage:[UIImage imageNamed:@"bg_nomal_two"]];
    }
    
    [self JoinCartAnimationWithStratPoint:startPoint endPoint:endPoint middlePoint:midPoint withImage:imageView.image];
    
    
    [QWGLOBALMANAGER statisticsEventId:@"x_spxq_gwc" withLable:@"商品详情页_购物车" withParams:nil];
    CartBranchVoModel *branchVoModel = [CartBranchVoModel new];
    branchVoModel.branchId = productDetail.branch.branchId;
    branchVoModel.branchName = productDetail.branch.branchName;
    branchVoModel.timeStamp = [[NSDate date] timeIntervalSince1970];
    branchVoModel.products = [NSMutableArray arrayWithCapacity:1];
    CartProductVoModel *productModel = [CartProductVoModel new];
    productModel.id = productDetail.id;
    productModel.name = productDetail.name;
    productModel.code = productDetail.code;
    productModel.imgUrl = productDetail.imgUrl;
    productModel.price = productDetail.price;
    productModel.quantity = 1;
    productModel.stock = productDetail.stock;
    productModel.saleStock = productDetail.saleStock;
    productModel.timeStamp = [[NSDate date] timeIntervalSince1970];
    productModel.promotions = [NSMutableArray arrayWithCapacity:10];
    productModel.sync = NO;
    if(productDetail.promotions.count > 0) {
        CartPromotionVoModel *model = [CartPromotionVoModel new];
        BranchProductPromotionVo *promotionVo = productDetail.promotions[0];
        model.type = [promotionVo.type integerValue];
        model.title = promotionVo.title;
        model.showType = [promotionVo.showType integerValue];
        model.value = [promotionVo.value doubleValue];
        model.unitNum = [promotionVo.unitNum doubleValue];
        model.presentName = promotionVo.presentName;
        model.presentUnit = promotionVo.presentUnit;
        model.id = promotionVo.id;
        [productModel.promotions addObject:model];
    }
    productModel.choose=YES;
    [branchVoModel.products addObject:productModel];
    [QWGLOBALMANAGER postNotif:NotifShoppingCartSync data:branchVoModel object:nil];
    
}

#pragma mark - 动画结束移除操作
- (void)removeFromLayer:(CALayer *)layerAnimation{
    
    [super removeFromLayer:layerAnimation];
    
}

- (void)goodAddAnimation{
    
    [UIView animateWithDuration:0.15 animations:^{
        self.goodCountLabel.transform = CGAffineTransformMakeScale(1.3, 1.3);
    }completion:^(BOOL finish){
        [UIView animateWithDuration:0.15 animations:^{
            self.goodCountLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }completion:^(BOOL finish){
            
        }];
    }];
}

#pragma mark - 优惠点击事件
- (void)couponAction:(NSIndexPath *)indexPath{
    [QWGLOBALMANAGER statisticsEventId:@"商品详情_优惠区" withLable:nil withParams:nil];

    int countCoupon=(int)productDetail.promotions.count;
    int countCombo=(int)productDetail.combos.count;
    __weak __typeof(self) weakSelf = self;
    
    if(countCoupon>0){//有优惠活动的
        if(countCombo>0){//有套餐的
            if(indexPath.row>countCoupon-1){//当値超过优惠活动的
                CartComboVoModel *model=(CartComboVoModel*)productDetail.combos[indexPath.row-countCoupon];
                [QWGLOBALMANAGER statisticsEventId:@"x_spxq_yhtc" withLable:@"商品详情页-优惠套餐" withParams:nil];
                
                [self presentSemiView:[PackageListShower showPackageContent:model.desc andDataList:productDetail.combos[indexPath.row-countCoupon] callBack:^(NSInteger obj) {
                    if(obj >= 1){
                        [self addPackageWithCount:obj withCombo:model];
                    }
                    [weakSelf dismissSemiModalView];
                }]];
                
                
            }else{
                [self presentSemiView:[PromotionShower showTitle:nil message:nil list:productDetail.promotions andCallBack:^(NSInteger obj) {
                    
                    [weakSelf dismissSemiModalView];
                }]];
            }
        }else{
            [self presentSemiView:[PromotionShower showTitle:nil message:nil list:productDetail.promotions andCallBack:^(NSInteger obj) {
                
                [weakSelf dismissSemiModalView];
            }]];
        }
        
    }else{//没有优惠活动的
        
        if(countCombo>0){
            CartComboVoModel *model=(CartComboVoModel*)productDetail.combos[indexPath.row];
            [QWGLOBALMANAGER statisticsEventId:@"x_spxq_yhtc" withLable:@"商品详情页-优惠套餐" withParams:nil];
            
            [self presentSemiView:[PackageListShower showPackageContent:model.desc andDataList:productDetail.combos[indexPath.row] callBack:^(NSInteger obj) {
                
                if(obj >= 1){
                    [self addPackageWithCount:obj withCombo:model];
                }
                [weakSelf dismissSemiModalView];
            }]];
            
        }else{
            
        }
    }
}

- (void)addPackageWithCount:(NSInteger)count withCombo:(CartComboVoModel *)model{
    
    CartBranchVoModel *branchModel = [CartBranchVoModel new];
    branchModel.branchId = productDetail.branch.branchId;
    branchModel.branchName = productDetail.branch.branchName;
    branchModel.timeStamp = [[NSDate date] timeIntervalSince1970];
    model.quantity = count;
    branchModel.combos = [NSMutableArray arrayWithObject:model];
    model.choose = YES;
    [QWGLOBALMANAGER postNotif:NotifShoppingCartSync data:branchModel object:nil];
}
#pragma mark - 主要治功能点击事件
- (void)useAction:(id)sender{
    [QWGLOBALMANAGER statisticsEventId:@"商品详情_功能说明" withLable:nil withParams:nil];

    //跳转H5页面
    NSString *url = [NSString stringWithFormat:@"%@QWYH/web/drug/html/explain.html?id=%@",H5_BASE_URL,productDetail.code];
    
    WebDirectViewController *serverInfo = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
    //外链Model
    WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
    modelLocal.url = url;
    modelLocal.typeLocalWeb = WebLocalTypeOuterLink;
    modelLocal.typeTitle = WebTitleTypeNone;
    serverInfo.isOtherLinks = YES;
//    modelLocal.title = productDetail.instructions.title;
    //fixed by lijian at V4.0 CJ需要修改
    modelLocal.title = @"说明";
    [serverInfo setWVWithLocalModel:modelLocal];
    
    serverInfo.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:serverInfo animated:YES];
    
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [self performSelector:@selector(dlayEE) withObject:nil afterDelay:2.5f];
}

#pragma mark - 延迟加载WebView高度
//不靠谱的方法，时而有效时而没用
- (void)dlayEE{
    
    floatCouponDetailHeight = [footerView.WebCondition getWebViewHeight];
    
    if(floatCouponDetailHeight == 0.0) return;
    
    if(floatCouponDetailHeight == 30){
        [footerView.WebCondition removeFromSuperview];
        [footerView.drugLabel removeFromSuperview];
        CGRect footFrame = footerView.frame;
        footFrame.size.height = 0;
        footerView.frame = footFrame;
    }else{
        footerView.WebCondition.hidden = NO;
        footerView.drugLabel.hidden = NO;
        CGRect footFrame = footerView.frame;
        footFrame.size.height = 38.0f + floatCouponDetailHeight;
        footerView.frame = footFrame;
    }
    _mainTableView.tableFooterView = footerView;
    [_mainTableView reloadData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(!productDetail){
        return 0;
    }
    
    switch (section) {
        case 0:{
            return productDetail.promotions.count+productDetail.combos.count;
        }
            break;
        case 1:{
            return 1;
        }
            break;
        case 2:{
            return 1;
        }
            break;
        default:{
            return 0;
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(!productDetail){
        return 0.0f;
    }
    switch (indexPath.section) {
        case 0:{
            if(indexPath.row + 1 == productDetail.promotions.count+productDetail.combos.count){
                return ([MedicinePromotionTableViewCell getCellHeight] + 10.0f);
            }else{
               return [MedicinePromotionTableViewCell getCellHeight];
            }
        }
            break;
        case 1:{
            return [MedicineUseTypeTableViewCell getCellHeight:productDetail.instructions];
        }
            break;
        case 2:{
            return [MallBranchTableViewCell getCellHeight:productDetail.branch];
        }
            break;
        default:{
            return 0.0f;
        }
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0:{
            return [self promotionCell:indexPath];
        }
            break;
        case 1:{
            return [self useTypeCell:indexPath];
        }
            break;
        case 2:{
            return [self branchCell:indexPath];
        }
            break;
        default:{
            return [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        }
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:{
            [self couponAction:indexPath];
        }
            break;
        case 1:{
            return;
        }
            break;
        case 2:{
            [QWGLOBALMANAGER statisticsEventId:@"商品详情_药房" withLable:nil withParams:nil];

            PharmacySotreViewController *VC = [[PharmacySotreViewController alloc]init];
            VC.branchId = productDetail.branch.branchId;
            VC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:VC animated:YES];
            
            return;
        }
            break;
        default:{
            return;
        }
            break;
    }
}

#pragma mark - 活动Cell
- (UITableViewCell *)promotionCell:(NSIndexPath *)indexPath{
    
    MedicinePromotionTableViewCell *cell = [self.mainTableView dequeueReusableCellWithIdentifier:PromotionCellIdentifier];
    int countCoupon=(int)productDetail.promotions.count;
    int countCombo=(int)productDetail.combos.count;
    if(countCoupon>0){//有优惠活动的
        if(countCombo>0){//有套餐的
            if(indexPath.row>countCoupon-1){//当値超过优惠活动的
                [cell setComboVoCell:productDetail.combos[indexPath.row-countCoupon]];
            }else{
                [cell setCell:productDetail.promotions[indexPath.row]];
            }
        }else{
            [cell setCell:productDetail.promotions[indexPath.row]];
        }

    }else{//没有优惠活动的
    
        if(countCombo>0){
            [cell setComboVoCell:productDetail.combos[indexPath.row]];
        }else{
            
        }
    }
    if(indexPath.row + 1 == countCoupon + countCombo){
        cell.sepatorLine.hidden = YES;
    }else{
        cell.sepatorLine.hidden = NO;
    }
    return cell;
}

#pragma mark - 适用范围Cell
- (UITableViewCell *)useTypeCell:(NSIndexPath *)indexPath{
    
    MedicineUseTypeTableViewCell *cell = [self.mainTableView dequeueReusableCellWithIdentifier:UseTypeCellIdentifier];
    
    [cell setCell:productDetail.instructions];
    [cell.useButton addTarget:self action:@selector(useAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - 药房Cell
- (UITableViewCell *)branchCell:(NSIndexPath *)indexPath{
    
    MallBranchTableViewCell *cell = [self.mainTableView dequeueReusableCellWithIdentifier:storeCellIdentifier];
    
    [cell setCell:productDetail.branch];
    
    return cell;
}

#pragma mark - Banner药品图片点击Action
- (void)showFullScreenImage:(NSInteger)currentIndex
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *imageList = [NSMutableArray array];
        for(NSString *imgUrl in productDetail.imgUrls) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,APP_W, cycleScrollView.frame.size.height)];
            [imageView setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"img_banner_nomal"]];
            [imageList addObject:imageView];
            imageView.tag = [productDetail.imgUrls indexOfObject:imgUrl];
        }
        UIImageView *imageView =  [cycleScrollView.curViews objectAtIndex:1];
        imageView.tag = currentIndex;
        [imageList replaceObjectAtIndex:currentIndex withObject:imageView];
        XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
        imageViewer.delegate = self;
        [imageViewer showWithImageViews:imageList selectedView:imageList[currentIndex]];
    });
}

#pragma mark - XHImageViewerDelegate
- (void)imageViewer:(XHImageViewer *)imageViewer willDismissWithSelectedView:(UIImageView *)selectedView
{
    NSInteger index = selectedView.tag;
    if(index == cycleScrollView.currentPage) {
        return;
    }
    [cycleScrollView scrollAtIndex:index];
}

#pragma mark - 三个点点击调用方法
- (void)returnIndex
{
    if(self.indexView && self.indexView.isShow){
        [self.indexView hide];
    }else{
        __weak __typeof(self) weakSelf = self;
  
        self.indexView = [RightIndexView showIndexViewWithImage:@[@"ic_popup_detail",@"icon_share_shoppin"] title:@[@"首页",@"分享"] SelectCallback:^(NSInteger obj) {
            
            if (obj == 0)//返回首页
            {
                [weakSelf backToHome:nil];
                
            }else if (obj == 1)//分享
            {
                [weakSelf shareAction:nil];
            }
        }];
    }
}

#pragma mark - 分享按钮Action
- (void)shareAction:(id)sender{
    [QWGLOBALMANAGER statisticsEventId:@"商品详情_分享" withLable:nil withParams:nil];

    if(productDetail == nil || StrIsEmpty(productDetail.id)){
        return;
    }

    ShareContentModel *modelShare = [[ShareContentModel alloc] init];
    modelShare.typeShare = ShareTypeWechatProduct;
    modelShare.title = productDetail.name;
    modelShare.shareID = productDetail.id;
    modelShare.content = [NSString stringWithFormat:@"%@，火热促销中！",productDetail.branch.branchName];
    if (productDetail.imgUrl.length > 0) {
        modelShare.imgURL = productDetail.imgUrl;
    }
    modelShare.shareLink = SHARE_URL_WECHAT_PRODUCT(productDetail.id,[QWGLOBALMANAGER getMapBranchId],productDetail.branch.cityName);
    [self popUpShareView:modelShare];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

@implementation MedicineHeaderView

+ (MedicineHeaderView *)getView{
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSArray *xibArray = [bundle loadNibNamed:@"MedicineDetailViewController" owner:nil options:nil];
    for(UIView *view in xibArray){
        if([view isKindOfClass:[MedicineHeaderView class]]){
            view.clipsToBounds = YES;
            return (MedicineHeaderView *)view;
        }
    }
    return nil;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
}
@end

@implementation MedicineFooterView

+ (MedicineFooterView *)getView{
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSArray *xibArray = [bundle loadNibNamed:@"MedicineDetailViewController" owner:nil options:nil];
    for(UIView *view in xibArray){
        if([view isKindOfClass:[MedicineFooterView class]]){
            return (MedicineFooterView *)view;
        }
    }
    return nil;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    self.WebCondition.scrollView.scrollEnabled=NO;
}
@end