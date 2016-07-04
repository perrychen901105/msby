//
//  HomePageViewController.m
//  APP
//
//  Created by garfield on 15/11/10.
//  Copyright © 2015年 carret. All rights reserved.
//

#import "HomePageViewController.h"
#import "UIImageView+WebCache.h"
#import "QWTopNotice.h"
#import "Constant.h"
#import "FamiliarQuestionViewController.h"
#import "Promotion.h"
#import "HomeScanViewController.h"
#import "LoginViewController.h"
#import "SVProgressHUD.h"
#import "MJRefresh.h"
#import "BannerModel.h"
#import "Problem.h"
#import "QWConstant.h"
#import "Coupon.h"
#import "AppDelegate.h"
#import "MessageBoxListViewController.h"
#import "NotificationModel.h"
#import "QYPhotoAlbum.h"
#import "swiftModule-swift.h"
#import "APP-Bridging-Header.h"
#import "ConsultForFreeRootViewController.h"
#import "MallCart.h"
#import "APPCommentAlert.h"
#import "WebDirectViewController.h"
#import "CouponPromotionHomePageViewController.h"
#import "ConfigInfo.h"
#import "UIButton+WebCache.h"
#import "ProjectTemplateOneTableViewCell.h"
#import "ProjectTemplateSecondTableViewCell.h"
#import "ProjectTemplateTableViewCell.h"
#import "CouponPharmacyDeailViewController.h"
#import "LoginViewController.h"
#import "Search.h"
#import "ProjectTemplateFifthTableViewCell.h"
#import "ProjectTemplateForthTableViewCell.h"
#import "QWProgressHUD.h"
#import "HomepageCollectionView.h"
#import "HomepageCollectionFlowLayout.h"
#import "ReceiverAddressTableViewController.h"
#import "HomeSearchMedicineViewController.h"
#import "BranchChangeViewController.h"
#import "BranchChooseViewController.h"
#import "ConsultStore.h"
#import "CouponProductCell.h"
#import "ComboProductCell.h"
#import "MedicineDetailViewController.h"
#import "ChatChooserViewController.h"
#import "ChatViewController.h"
#import "PharmacySotreViewController.h"
#import "FinderMainViewController.h"
#import "HealthInfoMainViewController.h"
#import "CircleDetailViewController.h"
#import "WYLocalNotifVC.h"
#import "PharmacyGoodsListViewController.h"

static NSString  *const ProjectTemplateOneIdentifier = @"ProjectTemplateOneIdentifier";
static NSString  *const ProjectTemplateSecondIdentifier = @"ProjectTemplateSecondIdentifier";
static NSString  *const ProjectSimpeContentIdentifier = @"ProjectSimpeContentIdentifier";
static NSString  *const ProjectTemplateForthIdentifier = @"ProjectTemplateForthIdentifier";
static NSString  *const ProjectTemplateFifthIdentifier = @"ProjectTemplateFifthIdentifier";
static NSString  *const CouponProductCellIdentifier = @"CouponProductCellIdentifier";
static NSString  *const ComboProductCellIdentifier = @"ComboProductCellIdentifier";


@interface HomePageViewController ()<XLCycleScrollViewDatasource,XLCycleScrollViewDelegate,UIAlertViewDelegate,UIWebViewDelegate,UITableViewDataSource,UITableViewDelegate,HomepageCollectionViewDelegate,PackageScrollViewDelegate>
{
    //用户地理位置
    CLLocation          *userLocation;
    //轮播banner数据源
    NSMutableArray      *bannerArray;
    //当前banner停留在哪个Index索引
    int                 pushIndex;
    UIButton            *btn;
    BOOL                showNotice;
    MapInfoModel        *checkInfoModel;
    BOOL                branchOnline;
    BOOL                branchHasExpert;
}

//热词标签
@property (weak, nonatomic) IBOutlet UIButton *branchBtn;
@property (nonatomic, strong) CAGradientLayer      *shadowGradientShadow;
@property (nonatomic, strong) ConfigInfoVoModel    *noticeConfigInfoVoModel;
//背景刷新的图片的高度,根据后台设置的图片配置等比例高度

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *refreshImageHeight;
@property (weak, nonatomic) IBOutlet UIImageView *refreshImageView;
@property (strong, nonatomic) UIImageView           *redPoint;
@property (strong, nonatomic) IBOutlet UIView *searchContainer;
@property (weak, nonatomic) IBOutlet UIView *topNavigationBar;
@property (nonatomic, strong) NSMutableArray        *bottomDataSource;
@property (strong, nonatomic) XLCycleScrollView *cycleScrollView;

@property (weak, nonatomic) IBOutlet UIView *bannerContaier;
@property (weak, nonatomic) IBOutlet UILabel *searchTextLabel;
@property (nonatomic, strong) HomepageCollectionView    *collectionView;

@property (nonatomic, strong) NSString          *lastCityName;
@property (nonatomic, strong) NSString          *currentProvinceName;
@property (weak, nonatomic) IBOutlet UIView *headerContainer;

@property (weak, nonatomic) IBOutlet UIImageView *searchBackGroundImage;

@property (strong,nonatomic) NSMutableArray   *ForumAreaList;
@property (nonatomic, strong) NSMutableArray<TemplatePosVoModel *>  *configInfoList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView      *footerView;
//首页运营点Model,多处需要使用,故全局保存
@property (nonatomic, strong) ConfigInfoListVoModel  *homePageEleVoModel;
@property (nonatomic, strong) NSMutableArray         *combosArray;
@property (nonatomic, strong) NSMutableArray         *preferentialGoodsArray;
@property (nonatomic, strong) NSMutableArray         *otherArray;
@property (nonatomic, strong) IBOutlet UIImageView   *circleImageView;
//以下若干约束,需要适配iPhone6 6p适配 约束需要根据比例重新设置
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerHeight;

@property (weak, nonatomic) IBOutlet UILabel *changeLabel;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UIImageView *searchIcon;
@property (weak, nonatomic) IBOutlet UIImageView *arrowIcon;
@property (strong, nonatomic) UIButton          *messageButton;



@end

@implementation HomePageViewController
@synthesize globalMapInfo;
@synthesize temp_globalMapInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self adjustConstraint];
    [self setNaviItem];
    self.branchBtn.layer.masksToBounds = YES;
    self.branchBtn.layer.cornerRadius = 12.0;
    bannerArray = [NSMutableArray array];
    self.configInfoList = [self buildCacheConfigData];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = fontSystem(14.0);
    btn.layer.cornerRadius = 11;
    btn.layer.masksToBounds = YES;
    self.ForumAreaList = [NSMutableArray array];
    __weak typeof (self) __weakSelf = self;
    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        [__weakSelf stLeftBarButtonWithModel:mapInfoModel];
        _lastCityName = mapInfoModel.city;
        globalMapInfo = mapInfoModel;
    }];
    
    //下拉刷新
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view setBackgroundColor:RGBHex(qwColor21)];
    
    [self setupView];
    [self setupTableView];
    [self setupCollectionView];
    [self showHeaderGradientShadow];
    [self performSelector:@selector(checkAppCommentStatus) withObject:nil afterDelay:10.0];
    
    [self enableSimpleRefresh:self.tableView block:^(SRRefreshView *sender) {
        
        [self queryData];
    }];
    //首页Banner缓存
    [self loadBannerCache];
    //专题专区模板 缓存
    [self loadForumAreaCache];
    //首页运营点 缓存
    [self loadConfigInfo];
    //开通微商时缓存
    [self loadBusinessConfigInfoCache];
    //开启定位
    [self startUserLocation];
}

- (NSMutableArray *)buildCacheConfigData
{
    NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:8];
    NSArray *textSource = @[@"咨询",@"优惠券",@"积分商城",@"本店商品",@"自查",@"用药提醒",@"阅读",@"圈子"];
    NSArray *imageSource = @[@"icon_consult_homepage",@"icon_coupons_homepage",@"icon_mall_homepage",@"icon_goods_homepage",@"icon_check_homepage",@"icon_remind_homepage",@"icon_read_homepage",@"icon_circle_homepage"];
    for(NSInteger index = 0;  index < textSource.count;index++) {
        TemplatePosVoModel *model = [[TemplatePosVoModel alloc] init];
        model.title = textSource[index];
        model.placeHolder = imageSource[index];
        model.cls = index;
        [retArray addObject:model];
    }
    return retArray;
}

- (void)pushIntoChooseView:(id)sender{
    
    BranchChooseViewController *chooseVC = [[BranchChooseViewController alloc]init];
    chooseVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chooseVC animated:YES];
}

//初始化TableView
- (void)setupTableView
{
    if(!self.tableView.tableHeaderView) {
        [self.tableView registerNib:[UINib nibWithNibName:@"ProjectTemplateOneTableViewCell" bundle:nil] forCellReuseIdentifier:ProjectTemplateOneIdentifier];
        [self.tableView registerNib:[UINib nibWithNibName:@"ProjectTemplateSecondTableViewCell" bundle:nil] forCellReuseIdentifier:ProjectTemplateSecondIdentifier];
        [self.tableView registerNib:[UINib nibWithNibName:@"ProjectTemplateTableViewCell" bundle:nil] forCellReuseIdentifier:ProjectSimpeContentIdentifier];
        [self.tableView registerNib:[UINib nibWithNibName:@"ProjectTemplateForthTableViewCell" bundle:nil] forCellReuseIdentifier:ProjectTemplateForthIdentifier];
        [self.tableView registerNib:[UINib nibWithNibName:@"ProjectTemplateFifthTableViewCell" bundle:nil] forCellReuseIdentifier:ProjectTemplateFifthIdentifier];
        [self.tableView registerNib:[UINib nibWithNibName:@"CouponProductCell" bundle:nil] forCellReuseIdentifier:CouponProductCellIdentifier];
        [self.tableView registerNib:[UINib nibWithNibName:@"ComboProductCell" bundle:nil] forCellReuseIdentifier:ComboProductCellIdentifier];
        
        if(iOSv7_1) {
            self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:self.headerContainer.bounds];
            [self.tableView.tableHeaderView addSubview:self.headerContainer];
        }else{
            self.tableView.tableHeaderView = self.headerContainer;
        }
    }
}

- (void)setupCollectionView
{
    _collectionView = [[HomepageCollectionView alloc] initWithFrame:CGRectMake(0, self.headerContainer.frame.size.height - 184 - 9, APP_W, 184) collectionViewLayout:[HomepageCollectionFlowLayout new]];
    _collectionView.scrollEnabled = NO;
    _collectionView.collectionDelegate = self;
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    _collectionView.weChatBusiness = QWGLOBALMANAGER.weChatBusiness;
    [self.headerContainer addSubview:_collectionView];
}

- (void)showHeaderGradientShadow
{
    if(!self.shadowGradientShadow) {
        self.shadowGradientShadow = [CAGradientLayer new];
        UIColor *startColor = [UIColor colorWithWhite:0.0 alpha:0.60];
        UIColor *endColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        self.shadowGradientShadow.colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
        self.shadowGradientShadow.startPoint = CGPointMake(0, 0);
        self.shadowGradientShadow.endPoint = CGPointMake(0, 1);
        CGRect rect = self.topNavigationBar.bounds;
        rect.size.width = APP_W;
        self.shadowGradientShadow.frame = rect;
    }
    [self.topNavigationBar.layer insertSublayer:self.shadowGradientShadow below:self.searchBackGroundImage.layer];
}

- (IBAction)changeBranchAction:(id)sender
{
    [QWGLOBALMANAGER statisticsEventId:@"首页_切换" withLable:@"首页_切换" withParams:nil];
    BranchChangeViewController *VC = [[BranchChangeViewController alloc]init];
    VC.pageType = Enum_ComFrome_Homepage;
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark -
#pragma mark HomepageCollectionViewDelegate
- (NSUInteger)numberOfItemsInHomepageCollectionView
{
    return self.configInfoList.count;
}

- (id)contentForHomepageIndexPath:(NSIndexPath *)indexPath
{
    id model = self.configInfoList[indexPath.row];
    return model;
}

- (void)collectionViewHomepage:(UICollectionView *)collectionView didSelectAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    TemplatePosVoModel *model = self.configInfoList[indexPath.row];
    switch (model.cls) {
        case 0:{
            //咨询
            [self pushToChatView:nil];
            break;
        }
        case 1: {
            //优惠券
            [QWGLOBALMANAGER statisticsEventId:@"首页_优惠券" withLable:@"首页-优惠券" withParams:nil];
            [self pushIntoCouponTicket:nil];
            break;
        }
        case 2:{
            [QWGLOBALMANAGER statisticsEventId:@"首页_积分商城" withLable:@"首页_积分商城" withParams:nil];
            WebDirectViewController *vcWebMedicine = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
            WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
            modelLocal.typeLocalWeb = WebPageTypeIntegralIndex;
            modelLocal.title = @"积分商城";
            [vcWebMedicine setWVWithLocalModel:modelLocal];
            vcWebMedicine.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vcWebMedicine animated:YES];
            break;
        }
        case 3: {
            [QWGLOBALMANAGER statisticsEventId:@"首页_本店商品" withLable:@"首页_本店商品" withParams:nil];
//            [[QWGlobalManager sharedInstance].tabBar setSelectedIndex:1];
            
            PharmacyGoodsListViewController *VC = [[PharmacyGoodsListViewController alloc]initWithNibName:@"PharmacyGoodsListViewController" bundle:nil];
            VC.branchId = [QWGLOBALMANAGER getMapBranchId];
            VC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:VC animated:YES];
            
            break;
        }
        case 4: {
            //自查
            [QWGLOBALMANAGER statisticsEventId:@"首页_自查" withLable:@"首页_自查" withParams:nil];
            FinderMainViewController *viewController = [[FinderMainViewController alloc] initWithNibName:@"FinderMainViewController" bundle:nil];
            viewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case 5: {
            //用药提醒
            [QWGLOBALMANAGER statisticsEventId:@"首页_用药提醒" withLable:@"首页_用药提醒" withParams:nil];
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"LocalNotif" bundle:nil];
            WYLocalNotifVC* vc = [sb instantiateViewControllerWithIdentifier:@"WYLocalNotifVC"];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 6: {
            //阅读-资讯
            [QWGLOBALMANAGER statisticsEventId:@"首页_阅读" withLable:@"首页_阅读" withParams:nil];
            HealthInfoMainViewController *viewController = [[HealthInfoMainViewController alloc] initWithNibName:@"HealthInfoMainViewController" bundle:nil];
            viewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case 7: {
            //商家圈
            [QWGLOBALMANAGER statisticsEventId:@"首页_圈子" withLable:@"首页_圈子" withParams:nil];
            CircleDetailViewController *vc = [[UIStoryboard storyboardWithName:@"Circle" bundle:nil] instantiateViewControllerWithIdentifier:@"CircleDetailViewController"];
            vc.hidesBottomBarWhenPushed = YES;
            vc.teamId = QWGLOBALMANAGER.getMapInfoModel.teamId;
            [self.navigationController pushViewController:vc animated:YES];
            
            break;
        }
        default:
            break;
    }
}

//推入药品详情界面
- (void)pushToDrugDetailWithDrugID:(NSString *)drugId promotionId:(NSString *)promotionID mapInfo:(MapInfoModel *)modelMap
{
    WebDirectViewController *vcWebMedicine = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
    
    WebDrugDetailModel *modelDrug = [WebDrugDetailModel new];
    modelDrug.modelMap = modelMap;
    modelDrug.proDrugID = drugId;
    modelDrug.promotionID = promotionID;
//    modelDrug.showDrug = @"0";
    WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
//    modelLocal.title = @"药品详情";
    modelLocal.modelDrug = modelDrug;
    modelLocal.typeLocalWeb = WebPageToWebTypeMedicine;
    [vcWebMedicine setWVWithLocalModel:modelLocal];
    [self.navigationController pushViewController:vcWebMedicine animated:YES];
}

- (void)setNaviItem
{
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 2;
    
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(APP_W - 70, 24, 70, 44)];
    bg.backgroundColor = [UIColor clearColor];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(15.5, -8, 60, 44);
    [btn1 setImage:[UIImage imageNamed:@"icon_news_homepage_rest"] forState:UIControlStateNormal];
//    [btn1 setImage:[UIImage imageNamed:@"icon_news_click"] forState:UIControlStateHighlighted];
    [btn1 addTarget:self action:@selector(pushIntoMessageBox:) forControlEvents:UIControlEventTouchUpInside];
    self.messageButton = btn1;
    [bg addSubview:btn1];
    
    self.redPoint = [[UIImageView alloc] initWithFrame:CGRectMake(49.5, 0, 10, 10)];
    self.redPoint.image = [UIImage imageNamed:@"icon_red"];
    self.redPoint.hidden = YES;
    [bg addSubview:self.redPoint];
    
    [self.topNavigationBar addSubview:bg];
}

//初始化滚动条以及tableViewHeader约束
- (void)setupView
{
    if(!self.cycleScrollView) {
        self.cycleScrollView = [[XLCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, APP_W,  self.bannerHeight.constant)];
        self.cycleScrollView.tag = 118;
        self.cycleScrollView.delegate = self;
        self.cycleScrollView.datasource = self;
        [self.cycleScrollView setupCustomPageControl];
        [self.bannerContaier addSubview:self.cycleScrollView];
        [self.headerContainer sendSubviewToBack:self.bannerContaier];
        self.cycleScrollView.pageControl.pageIndicatorTintColor = RGBHex(qwColor8);
        self.cycleScrollView.pageControl.currentPageIndicatorTintColor = RGBHex(qwColor1);
        self.cycleScrollView.pageControl.hidesForSinglePage = YES;
        self.cycleScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    self.circleImageView.layer.masksToBounds = YES;
    self.circleImageView.layer.borderColor = RGBHex(qwColor12).CGColor;
    self.circleImageView.layer.borderWidth = 4.0;
    self.circleImageView.layer.cornerRadius = 8.5;
    
    self.searchBackGroundImage.layer.masksToBounds = YES;
    self.searchBackGroundImage.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.35];
    self.searchBackGroundImage.layer.cornerRadius = 5.0;

}

- (void)pushIntoMessageBox:(id)sender
{
    if(!QWGLOBALMANAGER.loginStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        __weak typeof(self) weakSelf = self;
        loginViewController.loginSuccessBlock = ^(){
            [weakSelf enterMessageBox];
        };
        return;
    }else {
        [self enterMessageBox];
    }
}

-(void)enterMessageBox {
    [QWGLOBALMANAGER statisticsEventId:@"首页_消息" withLable:@"首页_消息" withParams:nil];
    MessageBoxListViewController *vcMsgBoxList = [[UIStoryboard storyboardWithName:@"MessageBoxListViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MessageBoxListViewController"];
    vcMsgBoxList.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vcMsgBoxList animated:YES];

}

#pragma mark - 缓存读取及保存
- (void)saveBannerCache:(NSArray *)bannerList
{
    [BannerInfoModel deleteAllObjFromDB];
    [BannerInfoModel saveObjToDBWithArray:bannerList];
}

- (void)loadBannerCache
{
    NSArray *array = [BannerInfoModel getArrayFromDBWithWhere:nil];
    if(array && array.count > 0) {
        [bannerArray removeAllObjects];
        [bannerArray addObjectsFromArray:array];
        [self.cycleScrollView reloadData];
        self.cycleScrollView.scrollView.scrollEnabled = YES;
    }
}

- (void)saveConfigInfoCache:(id)responModel
{
    [QWUserDefault setObject:responModel key:ConfigInfoListVoModelKey];
}

- (void)loadConfigInfo
{
    [QWUserDefault setString:@"" key:HomePageEleVoModelKey];
    self.homePageEleVoModel = [QWUserDefault getModelBy:ConfigInfoListVoModelKey];
    [self fillupOperatingPoint:_homePageEleVoModel];
}

- (void)saveBusinessConfigInfoCache:(TemplateListVoModel *)model
{
    if(model) {
        [QWUserDefault setModel:model key:CONFIGINFO_MODEL_KEY];
    }
}

- (void)saveForumAreaCache:(NSArray *)array
{
    if(array) {
        [QWUserDefault setModel:array key:TEMPLATE_MODEL_KEY];
    }
}

- (void)loadBusinessConfigInfoCache
{
    TemplateListVoModel *model = [QWUserDefault getModelBy:CONFIGINFO_MODEL_KEY];
    if(model) {
        [self fillupWeBusinessPoint:model];
    }
}

- (void)loadForumAreaCache
{
    NSArray *array = [QWUserDefault getModelBy:TEMPLATE_MODEL_KEY];
    if(array) {
        [self.ForumAreaList removeAllObjects];
        [self.ForumAreaList addObjectsFromArray:array];
        [self.tableView reloadData];
    }
}

#pragma mark -
#pragma mark 接口逻辑,填充首页数据
//填充微商情况下首页运营点
- (void)fillupWeBusinessPoint:(TemplateListVoModel *)modelList
{
    [self.ForumAreaList removeAllObjects];
    [self.tableView reloadData];
    for(TemplateVoModel *model in modelList.templates) {
        switch (model.posUsed) {
            case 1:{
                if(!QWGLOBALMANAGER.weChatBusiness)
                    return;
                //首页频道
                if(modelList.templateCounts > 0) {
                    for(NSInteger index = 0;index< model.pos.count; ++index) {
                        self.configInfoList[index].imgUrl = model.pos[index].imgUrl;
                    }
                }
                [_collectionView reloadData];
                break;
            }
            case 2:{
                //首页主题
                [self.ForumAreaList addObject:model];
                
                if(self.ForumAreaList.count > 0) {
                    [self saveForumAreaCache:self.ForumAreaList];
                }
                [self.tableView reloadData];
                break;
            }
            default:
                break;
        }
    }
}

//填充首页运营点数据
- (void)fillupOperatingPoint:(ConfigInfoListVoModel *)modelList
{
    //填充运营点之前,清除缓存数据
    [QWUserDefault setString:@"" key:APP_LAUNCH_URL];
    [QWUserDefault setString:@"" key:APP_LAUNCH_TITLE];
    _refreshImageView.image = nil;
    
    for(ConfigInfoVoModel *model in modelList.configInfos)
    {
        switch (model.configIndex) {
            case 1:
            {
                //启动页
                [QWUserDefault setDouble:[model.duration doubleValue] key:APP_LAUNCH_DURATION];
                //保存外链地址
                [QWUserDefault setString:model.content key:APP_LAUNCH_URL];
                [QWUserDefault setString:model.title key:APP_LAUNCH_TITLE];
                if(StrIsEmpty(model.imgUrl)){//若图片URL为空，说明后台把图片下架了，将启动页图片置空
                    [QWUserDefault setObject:nil key:APP_LAUNCH_IMAGE];
                }else{//URL不为空，就去做下载操作
                    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:model.imgUrl] options:SDWebImageDownloaderHighPriority progress:NULL completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                        //保存启动引导页
                        if(image)
                            [QWUserDefault setObject:image key:APP_LAUNCH_IMAGE];
                    }];
                }
                break;
            }
            case 2:
            {
                //下拉刷新
                [_refreshImageView setImageWithURL:[NSURL URLWithString:model.imgUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    if(image) {
                        CGFloat height = APP_W / image.size.width * image.size.height;
                        self.refreshImageHeight.constant = height;
                    }
                }];
                break;
            }
            case 3:
            {
                //通告
                if((_noticeConfigInfoVoModel && ![model.uId isEqualToString:_noticeConfigInfoVoModel.uId])) {
                    _noticeConfigInfoVoModel = model;
                    if(showNotice) {
                        [QWGLOBALMANAGER postNotif:NotiMessageOPLaunchingScreenDisappear data:nil object:nil];
                    }
                }
                _noticeConfigInfoVoModel = model;
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark 请求数据  区分开通和未开通微商
//开通微商
- (void)queryData
{
    
    [self queryPharmacyStoreBranchInformation];
    
}

#pragma mark -
#pragma mark 请求数据  微商
- (void)queryPharmacyStoreBranchInformation
{
    CategoryModelR *modelR = [CategoryModelR new];
    modelR.branchId = [QWGLOBALMANAGER getMapBranchId];
    [ConsultStore MallBranchIndexNew:modelR success:^(MicroMallBranchNewIndexVo *model) {
        if([model.apiStatus intValue] == 0){
            branchOnline = model.online;
            branchHasExpert = model.hasExpert;
            [self.branchBtn setTitle:[NSString stringWithFormat:@"   %@ >   ",model.name] forState:UIControlStateNormal];
            [self.bottomDataSource removeAllObjects];
            self.bottomDataSource = [NSMutableArray arrayWithCapacity:3];
            if(model.categorys.count > 0){
                _otherArray = [NSMutableArray arrayWithCapacity:5];
                
                for(CategoryVo *categoryModel in model.categorys){
                    if([categoryModel.categoryId isEqualToString:@"39d14193ea1448758bfcadd055e42d7b"]){
                        _preferentialGoodsArray = [NSMutableArray arrayWithObject:categoryModel];
                    }else{
                        [_otherArray addObject:categoryModel];
                    }
                }
            }
            if(_preferentialGoodsArray.count > 0) {
                [self.bottomDataSource addObject:_preferentialGoodsArray];
            }
            if(model.combos.count > 0){
                _combosArray = [NSMutableArray arrayWithArray:model.combos];
                [self.bottomDataSource addObject:_combosArray];
            }
            if(_otherArray.count > 0) {
                [self.bottomDataSource addObjectsFromArray:_otherArray];
            }
            if(self.bottomDataSource.count > 0) {
                CGRect rect = self.footerView.frame;
                rect.size.width = APP_W;
                self.footerView.frame = rect;
                self.tableView.tableFooterView = self.footerView;
            }else{
                self.tableView.tableFooterView = nil;
            }
            [self.tableView reloadData];
            [QWGLOBALMANAGER updateMapInfoModel:model];
            [self queryGeneralConfigInfo];
            //fixed at 3.1.0 by lijian
            //热搜词汇重新放开
            [QWGLOBALMANAGER loadHotWord];
            [self queryWSChannelOrArea];

            [QWGLOBALMANAGER postNotif:NotiDismissSwitchAnimationLoading data:nil object:nil];
        }
    } failure:^(HttpException *e) {
        
    }];
}

//微商前提下 请求运营点数据 频道 8个圈
- (void)queryWSChannelOrArea
{
    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        ConfigInfoQueryModelR *modelR = [ConfigInfoQueryModelR new];
//        modelR.province = mapInfoModel.province;
        modelR.city = mapInfoModel.branchCityName;
        modelR.branchId = [QWGLOBALMANAGER getMapBranchId];
        modelR.deviceType = 2;
        //获取运营点 数据
        [ConfigInfo configInfoQueryOpTemplates:modelR success:^(TemplateListVoModel *responModel) {
            if([responModel.apiStatus integerValue] == 0) {
                [self fillupWeBusinessPoint:responModel];
                [self saveBusinessConfigInfoCache:responModel];
            }
        } failure:^(HttpException *e) {
            [self loadBusinessConfigInfoCache];
        }];
    }];
}

#pragma mark -
#pragma mark 请求数据  新老版本都用，包含通告，启动页背景图，下拉刷新背景图 banner

//运营点接口,包括滚动Bannder图片
- (void)queryGeneralConfigInfo
{
    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        
        ConfigInfoQueryModelR *modelR = [ConfigInfoQueryModelR new];
        if(mapInfoModel) {
//            modelR.province = mapInfoModel.province;
            modelR.city = mapInfoModel.branchCityName;
        }else{
            modelR.province = @"江苏省";
            modelR.city = @"苏州市";
        }
        //获取运营
        [ConfigInfo queryConfigInfos:modelR success:^(ConfigInfoListVoModel *responModel) {
            if([responModel.apiStatus integerValue] == 0) {
                [self fillupOperatingPoint:responModel];
                [self saveConfigInfoCache:responModel];
            }
        } failure:^(HttpException *e) {
            [self loadConfigInfo];
        }];
        
        modelR.place = @"1";
        [self.cycleScrollView stopAutoScroll];
        HttpClientMgr.progressEnabled=NO;
        self.cycleScrollView.userInteractionEnabled = NO;
        
        
        modelR.place = nil;
        modelR.branchId = mapInfoModel.branchId;
        modelR.deviceType = 2;
        modelR.platform = 1;
        //获取首页Banner接口
        [ConfigInfo configInfoQueryHomePageBanner:modelR success:^(BannerInfoListModel *responModel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *bannerList = responModel.list;
                if([responModel.apiStatus intValue] == 0){
                    [bannerArray removeAllObjects];
                    if(bannerList.count > 0){
                        [bannerArray addObjectsFromArray:bannerList];
                        [self saveBannerCache:bannerList];
                        self.cycleScrollView.customPageControl.hidden = NO;
                    }else{
                        self.cycleScrollView.customPageControl.hidden = YES;
                    }
                    [self.cycleScrollView reloadData];
                }else{
                    
                }
                self.cycleScrollView.userInteractionEnabled = YES;
            });
            
        } failure:^(HttpException *e) {
            [self loadBannerCache];
            self.cycleScrollView.datasource = self;
            self.cycleScrollView.delegate = self;
            self.cycleScrollView.userInteractionEnabled = YES;
        }];
    }];
}

#pragma mark -
#pragma mark 请求数据  不开通微商

//获取专区接口
- (void)queryNWSForumArea
{
    [QWGLOBALMANAGER readLastMapAddress:^(NSString *province, NSString *city, NSString *formattedAddress) {
        ConfigInfoQueryTemplateModelR *apiModelR = [ConfigInfoQueryTemplateModelR new];
        apiModelR.pos = 1;
        if(!city) {
            apiModelR.city = @"苏州";
            apiModelR.province = @"江苏省";
        }else{
            apiModelR.province = province;
            apiModelR.city = city;
        }
        [ConfigInfo queryTemplete:apiModelR success:^(TemplateListVoModel *responModel) {
            if([responModel.apiStatus integerValue] == 0) {
                [self.ForumAreaList removeAllObjects];
                if(responModel.templateCounts > 0) {
                    [self saveForumAreaCache:responModel.templates];
                    [self.ForumAreaList addObjectsFromArray:responModel.templates];
                }
                [self.tableView reloadData];
            }else{
                [self.ForumAreaList removeAllObjects];
                [self.tableView reloadData];
            }
        } failure:^(HttpException *e) {
            [self loadForumAreaCache];
        }];
    }];
}

#pragma mark
#pragma mark 定位功能
//定位在国外
- (void)caseOutOfChina
{
    [QWUserDefault setBool:NO key:kLocationSuccess];
    [QWUserDefault setBool:YES key:kCanConsultPharmacists];
    MapInfoModel *nativeModel = [QWGLOBALMANAGER buildSuzhouLocatinMapInfo];
    [QWGLOBALMANAGER postNotif:NotifLocateFinished data:nativeModel object:nil];
    [self stLeftBarButtonWithModel:nativeModel];
}


//用户启动定位
- (void)startUserLocation
{
    [QWGLOBALMANAGER statisticsEventId:@"x_dw" withLable:@"首页" withParams:nil];
    checkInfoModel = nil;
    [QWUserDefault setBool:YES key:kCanConsultPharmacists];
    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        [self refreshCityData:mapInfoModel];
    }];
}

- (void)refreshCityData:(MapInfoModel *)mapInfoModel
{
    if(mapInfoModel.status == 3) {
        QWGLOBALMANAGER.weChatBusiness = YES;
        _collectionView.weChatBusiness = YES;
    }else {
        QWGLOBALMANAGER.weChatBusiness = NO;
        _collectionView.weChatBusiness = NO;
    }
    if(mapInfoModel.branchName && mapInfoModel.branchName.length > 0) {
        [self.branchBtn setTitle:[NSString stringWithFormat:@"   %@ >   ",mapInfoModel.branchName] forState:UIControlStateNormal];
    }
    //如果没有省市区,代表是在国外,直接加载全部数据
    if (StrIsEmpty(mapInfoModel.province) && StrIsEmpty(mapInfoModel.city)) {
        //国外,加载苏州数据
        [self caseOutOfChina];
        [self queryData];
        
    }else{
        //如果有省市区,代表是在国内
        NSString *currentCity = mapInfoModel.city;
        //与上次定位城市不一致
        //与上次定位城市一致或者上次定位失败
        //存入QWUserDefault
        [QWUserDefault setBool:YES key:kCanConsultPharmacists];
        [self stLeftBarButtonWithModel:mapInfoModel];
        [QWGLOBALMANAGER saveLastLocationInfo:mapInfoModel];
        [QWGLOBALMANAGER postNotif:NotifLocateFinished data:mapInfoModel object:nil];
        [self queryData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //立刻刷新小红点
    [QWGLOBALMANAGER postNotif:NotifUpdateUnreadNum data:nil object:nil];
    [QWGLOBALMANAGER updateRedPoint];
    
}

//动态调整布局,适配6 6plus
- (void)adjustConstraint
{
//    self.searchBarWidth.constant = APP_W - 320.0 + self.searchBarWidth.constant;
    self.bannerHeight.constant = AdaptiveScale * self.bannerHeight.constant;
    CGFloat offset = self.bannerHeight.constant - 181.0f;
    self.headerContainer.frame = CGRectMake(0, 0, APP_W, self.headerContainer.frame.size.height + offset);
    CGRect rect = self.searchContainer.frame;
    rect.size.width = APP_W;
    self.searchContainer.frame = rect;
}

- (void)checkAppCommentStatus{
    //评论
    [QWGLOBALMANAGER checkAppComment];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self performSelector:@selector(stoped) withObject:nil afterDelay:0.5];
    [QWTopNotice hiddenNotice];
}

- (void)stoped
{
    [self.cycleScrollView stopAutoScroll];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [QWGLOBALMANAGER checkEventId:@"某个药房的首页" withLable:@"某个药房的首页" withParams:nil];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    CGRect frame = CGRectMake(0.0, 0.0, 320.0, 49.0);
    UIView *v = [[UIView alloc] initWithFrame:frame];
    v.backgroundColor = [UIColor clearColor];
    [self.tabBarController.tabBar insertSubview:v atIndex:0];
    [self.cycleScrollView resumeTimer];
    pushIndex = 0;
    if(![QWUserDefault getBoolBy:@"showBusinessGuide"])
        [APPDelegate.mainVC showBusinessGuide];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

//设置右上角城市City
- (void)stLeftBarButtonWithModel:(MapInfoModel *)model{
    NSString *title = model.city;
    if(title) {
        if([title hasSuffix:@"市"]) {
            title = [title substringToIndex:title.length - 1];
        }
        title = [NSString stringWithFormat:@"%@",title];
    }

    if(StrIsEmpty(title)){
        [btn setTitle:@"" forState:UIControlStateNormal];
        return;
    }
    if(model.formattedAddress.length > 0) {
        NSArray *formateArray = [model.formattedAddress componentsSeparatedByString:model.city];
        [btn setTitle:[NSString stringWithFormat:@"   %@ >  ",[formateArray lastObject]] forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark XLCycleScrollViewDelegate
//banner点击事件
- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index
{
    if(bannerArray.count == 0){
        return;
    }
    [self.cycleScrollView stopAutoScroll];
    if(pushIndex == 0){
        BannerInfoModel *banner = bannerArray[index];
        [QWGLOBALMANAGER statisticsEventId:@"首页_banner" withLable:@"首页_banner" withParams:nil];
        [QWGLOBALMANAGER pushIntoDifferentBannerType:banner navigation:self.navigationController bannerLocation:@"首页" selectedIndex:index];
        if([banner.type integerValue] == 9) {
            pushIndex = 0;
        }else{
            pushIndex ++;
        }
    }
}

- (NSInteger)numberOfPages
{
    if(bannerArray == nil || bannerArray.count == 0 || bannerArray.count == 1){
        self.cycleScrollView.scrollView.scrollEnabled = NO;
        [self.cycleScrollView stopAutoScroll];
        return 1;
    }else{
        self.cycleScrollView.scrollView.scrollEnabled = YES;
        [self.cycleScrollView startAutoScroll:5.0f];
        return bannerArray.count;
    }
}

- (UIView *)pageAtIndex:(NSInteger)index
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,APP_W, self.bannerHeight.constant)];
    if(bannerArray == nil || bannerArray.count == 0){
        [imageView setImage:[UIImage imageNamed:@"bg_banner_disable"]];
        return imageView;
    }else{
        BannerInfoModel *banner = bannerArray[index];
        [imageView setImageWithURL:[NSURL URLWithString:banner.imgUrl] placeholderImage:[UIImage imageNamed:@"bg_banner_disable"]];
        return imageView;
    }
}

#pragma mark - PackageScrollViewDelegate
- (void)didSelectedPackageView:(PackageScrollView *)packageView withBranchProId:(NSString *)branchProId{
    
    MedicineDetailViewController *VC = [[MedicineDetailViewController alloc]initWithNibName:@"MedicineDetailViewController" bundle:nil];
    VC.proId = branchProId;
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark 处理本视图收到的通知
- (void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj{
    if (NotifLoginSuccess == type || NotifQuitOut == type) {

        QWGLOBALMANAGER.needShowBadge = NO;
        [QWGLOBALMANAGER setBadgeNumStatus:NO];
        self.redPoint.hidden = YES;
        QWGLOBALMANAGER.sellerMineRedPoint.hidden = YES;

    }else if (NotiWhetherHaveNewMessage == type) {
        NSString *countStr = data;
        if ([countStr intValue] > 0) {
            self.redPoint.hidden = NO;
            QWGLOBALMANAGER.sellerMineRedPoint.hidden = NO;
        } else {
            self.redPoint.hidden = YES;
            QWGLOBALMANAGER.sellerMineRedPoint.hidden = YES;
        }
    }else if (NotifKickOff == type){
        [self quickOut];
    } else if (NotiMessageOPLaunchingScreenDisappear == type) {
        showNotice = YES;
        if(_noticeConfigInfoVoModel && _noticeConfigInfoVoModel.title.length > 0)
        {
            NSString *lastUID = [QWUserDefault getStringBy:@"NOTICE_UID"];
            if([_noticeConfigInfoVoModel.uId isEqualToString:lastUID]) {
                 _noticeConfigInfoVoModel = nil;
                return;
            }
            BannerInfoModel *bannerModel = [BannerInfoModel new];
            bannerModel.type = _noticeConfigInfoVoModel.type;
            bannerModel.name = _noticeConfigInfoVoModel.title;
            bannerModel.imgUrl = _noticeConfigInfoVoModel.imgUrl;
            bannerModel.content = _noticeConfigInfoVoModel.content;
            bannerModel.branchId = _noticeConfigInfoVoModel.branchId;
            bannerModel.groupId = _noticeConfigInfoVoModel.groupId;
            bannerModel.proId = _noticeConfigInfoVoModel.proId;
            [QWUserDefault setString:_noticeConfigInfoVoModel.uId key:@"NOTICE_UID"];
            
            __block NSMutableDictionary *setting = [NSMutableDictionary dictionary];
            if(bannerModel.content && bannerModel.content.length > 0) {
                setting[@"通告内容"] = bannerModel.content;
            }
            [QWTopNotice showNoticeWithText:_noticeConfigInfoVoModel.title clickBlock:^{
                [QWTopNotice hiddenNotice];
                [QWGLOBALMANAGER statisticsEventId:@"x_sy_tg" withLable:@"首页通告点击" withParams:setting];
                [QWGLOBALMANAGER pushIntoDifferentBannerType:bannerModel navigation:self.navigationController bannerLocation:@"首页" selectedIndex:0];
            }];
            _noticeConfigInfoVoModel = nil;
        }
    }else if(type == NOtifHotKeyChange) {
        if(!StrIsEmpty(QWGLOBALMANAGER.hotWord.homeHintMsg))
            _searchTextLabel.text = QWGLOBALMANAGER.hotWord.homeHintMsg;
    } else if (type == NotifPushViewAfterStartUp) {
        AppDelegate *delega = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delega delayPushVC];
    }else if (type == NotifHomepagePharmacyStoreChanged) {
        [bannerArray removeAllObjects];
        [self.cycleScrollView reloadData];
        _preferentialGoodsArray = nil;
        _combosArray = nil;
        _otherArray = nil;
        [self.bottomDataSource removeAllObjects];
        [self.ForumAreaList removeAllObjects];
        [self.tableView reloadData];
        [self refreshCityData:data];
    }
}

//app 被抢登,首页接收通知,作UI处理
- (void)quickOut
{
    [SVProgressHUD showErrorWithStatus:@"登录状态失效，请重新登录" duration:0.8];
    [QWGLOBALMANAGER clearAccountInformation];
    [QWUserDefault setBool:NO key:APP_LOGIN_STATUS];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"apploginloginstatus"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"apppasswordkey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    QWGLOBALMANAGER.loginStatus = NO;
    QWGLOBALMANAGER.configure.userToken = nil;
    [QWGLOBALMANAGER unOauth];
    [self performSelector:@selector(delayShowLoginViewController) withObject:nil afterDelay:0.3f];
}

//延迟加载登录界面
- (void)delayShowLoginViewController
{
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
    loginViewController.isPresentType = YES;
    [QWGLOBALMANAGER.tabBar presentViewController:navgationController animated:YES
                                       completion:NULL];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = self.ForumAreaList.count + self.bottomDataSource.count;
    return count;
}

//高度根据屏幕等比例调整
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section < self.ForumAreaList.count) {
        TemplateVoModel *model = self.ForumAreaList[indexPath.section];
        if([model.type integerValue] == 1) {
            return 161 * AdaptiveScale;
        }else if ([model.type integerValue] == 2) {
            return 186 * AdaptiveScale;
        }else if([model.type integerValue] == 3){
            return 93 * AdaptiveScale;
        }else if ([model.type integerValue] == 4) {
            return 81 * AdaptiveScale;
        }else {
            return 186 * AdaptiveScale;
        }
    }else{
        NSMutableArray *array = self.bottomDataSource[indexPath.section - self.ForumAreaList.count];
        if([array isEqual:_combosArray]) {
            return [ComboProductCell getCellHeight:nil];
        }else{
            return [CouponProductCell getCellHeight:nil];
        }
    }
}

//cell 分为三种类型 1-1 1-2  3,具体效果参考UI图,每个Cell上有1-4个Button ,点击不同Button需要对应到不同数据源的Model,然后进行H5界面
- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //专题专区模板UI匹配
    if(indexPath.section < self.ForumAreaList.count) {
        TemplateVoModel *areaModel = self.ForumAreaList[indexPath.section];
        if([areaModel.type integerValue] == 1) {//1-2
            ProjectTemplateOneTableViewCell *cell = [atableView dequeueReusableCellWithIdentifier:ProjectTemplateOneIdentifier];
            [cell setCell:areaModel withTarget:self];
            return cell;
            
        }else if ([areaModel.type integerValue] == 2) {//2-2
            ProjectTemplateSecondTableViewCell *cell = [atableView dequeueReusableCellWithIdentifier:ProjectTemplateSecondIdentifier];
            [cell setCell:areaModel withTarget:self];
            
            return cell;
        }else if([areaModel.type integerValue] == 3){
            ProjectTemplateTableViewCell *cell = [atableView dequeueReusableCellWithIdentifier:ProjectSimpeContentIdentifier];
            [cell setCell:areaModel];
            return cell;
        }else if ([areaModel.type integerValue] == 4) {
            ProjectTemplateForthTableViewCell *cell = [atableView dequeueReusableCellWithIdentifier:ProjectTemplateForthIdentifier];
            [cell setCell:areaModel withTarget:self];
            
            return cell;
        }else{
            ProjectTemplateFifthTableViewCell *cell = [atableView dequeueReusableCellWithIdentifier:ProjectTemplateFifthIdentifier];
            [cell setCell:areaModel];
            
            return cell;
        }
    }else{
        id data = self.bottomDataSource[indexPath.section - self.ForumAreaList.count];
        if([data isEqual:_combosArray]) {
            ComboProductCell *cell = [atableView dequeueReusableCellWithIdentifier:ComboProductCellIdentifier];
            cell.packageScrollView.delegate = self;
            [cell setCell:data];
            [cell.moreButton addTarget:self action:@selector(pushIntoComboProduct:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }else{
            CouponProductCell *cell = [atableView dequeueReusableCellWithIdentifier:CouponProductCellIdentifier];
            CategoryVo *category = nil;
            if([data isEqual:_preferentialGoodsArray]) {
                [cell setCouponProductCell:data[0]];
                [cell.moreButton addTarget:self action:@selector(pushIntoOtherProduct:) forControlEvents:UIControlEventTouchUpInside];
                
                category = _preferentialGoodsArray[0];
                cell.moreButton.obj = category.categoryId;
            }else{
                category = (CategoryVo *)data;
                [cell setOtherProductCell:data];
                [cell.moreButton addTarget:self action:@selector(pushIntoOtherProduct:) forControlEvents:UIControlEventTouchUpInside];
                cell.moreButton.obj = category.categoryId;
            }
            [cell.buttonBackgroundOne addTarget:self action:@selector(pushIntoMedicinedetail:) forControlEvents:UIControlEventTouchUpInside];
            [cell.buttonBackgroundTwo addTarget:self action:@selector(pushIntoMedicinedetail:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section < self.ForumAreaList.count) {
        TemplateVoModel *areaModel = self.ForumAreaList[indexPath.section];;
        if([areaModel.type integerValue] == 3) {
            TemplatePosVoModel *model = areaModel.pos[0];
            [self pushIntoWebViewControllerWithURL:model.forwordUrl objId:model.objId cls:[NSString stringWithFormat:@"%d",model.cls] isSpecial:[NSString stringWithFormat:@"%d",model.special] title:model.title canShare:model.flagShare];
        }
    }
}

- (void)pushIntoComboProduct:(QWButton *)sender
{
    [QWGLOBALMANAGER checkEventId:@"首页_更多" withLable:@"首页_更多" withParams:nil];
//    [[QWGlobalManager sharedInstance].tabBar setSelectedIndex:1];
//    [QWGLOBALMANAGER postNotif:NotifPushCategroy data:COMBO_CATEGROY_ID object:nil];
    
    //套餐分类更多
    PharmacyGoodsListViewController *VC = [[PharmacyGoodsListViewController alloc]initWithNibName:@"PharmacyGoodsListViewController" bundle:nil];
    VC.branchId = [QWGLOBALMANAGER getMapBranchId];
    VC.classID = COMBO_CATEGROY_ID;
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)pushIntoOtherProduct:(QWButton *)sender
{
    [QWGLOBALMANAGER checkEventId:@"首页_更多" withLable:@"首页_更多" withParams:nil];
//    [[QWGlobalManager sharedInstance].tabBar setSelectedIndex:1];
//    [QWGLOBALMANAGER postNotif:NotifPushCategroy data:sender.obj object:nil];
    
    //普通分类更多
    PharmacyGoodsListViewController *VC = [[PharmacyGoodsListViewController alloc]initWithNibName:@"PharmacyGoodsListViewController" bundle:nil];
    VC.branchId = [QWGLOBALMANAGER getMapBranchId];
    VC.classID = sender.obj;
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)pushIntoMedicinedetail:(QWButton *)button
{
    [QWGLOBALMANAGER checkEventId:@"首页_商品" withLable:@"首页_商品" withParams:nil];
    BranchProductVo *model = (BranchProductVo *)button.obj;
    MedicineDetailViewController *VC = [[MedicineDetailViewController alloc]initWithNibName:@"MedicineDetailViewController" bundle:nil];
    VC.proId = model.id;
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)fixedNavigationBar
{
    CGFloat offset = self.tableView.contentOffset.y;
    if(offset == 0) {
        [UIView animateWithDuration:0.25 animations:^{
            self.topNavigationBar.alpha = 1.0;
            [self showHeaderGradientShadow];
        }];
        
        self.changeLabel.textColor = RGBHex(qwColor4);
        self.searchIcon.image = [UIImage imageNamed:@"icon_search_homepage_rest"];
        self.arrowIcon.image = [UIImage imageNamed:@"arrow_homepage_rest"];
        self.searchTextLabel.textColor = RGBHex(qwColor4);
        [self.scanButton setImage:[UIImage imageNamed:@"icon_scan_homepage_rest"] forState:UIControlStateNormal];
        [self.messageButton setImage:[UIImage imageNamed:@"icon_news_homepage_rest"] forState:UIControlStateNormal];
        self.topNavigationBar.backgroundColor = [UIColor clearColor];
        self.searchBackGroundImage.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.45];
        
    }else if(offset > 0) {
        [UIView animateWithDuration:0.25 animations:^{
            self.topNavigationBar.alpha = 1.0;
            [self.shadowGradientShadow removeFromSuperlayer];
        }];
        [self fadeInNavigationBar:offset];
    }
    else{
        [UIView animateWithDuration:0.25 animations:^{
            self.topNavigationBar.alpha = 0.0;
            [self.shadowGradientShadow removeFromSuperlayer];
        }];
    }
    
}

- (void)fadeInNavigationBar:(CGFloat)offset
{
    self.topNavigationBar.backgroundColor = [UIColor colorWithWhite:1.0 alpha:offset / 60.0];
    [self.view addSubview:self.topNavigationBar];
    [self adjustTopNavaiagtionBarConstraintWithSuperView:self.view];
    
    self.changeLabel.textColor = RGBHex(qwColor7);
    self.searchIcon.image = [UIImage imageNamed:@"icon_search_homepage_selected"];
    self.arrowIcon.image = [UIImage imageNamed:@"arrow_homepage_selected"];
    self.searchTextLabel.textColor = RGBHex(qwColor9);
    [self.scanButton setImage:[UIImage imageNamed:@"icon_scan_homepage_selected"] forState:UIControlStateNormal];
    [self.messageButton setImage:[UIImage imageNamed:@"icon_news_homepage_selected"] forState:UIControlStateNormal];
    self.searchBackGroundImage.backgroundColor = [UIColor colorWithRed:204.0f/255.0f green:204.f/255.0f blue:204.0/255.0 alpha:0.35];
}

- (void)adjustTopNavaiagtionBarConstraintWithSuperView:(UIView *)superView
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.topNavigationBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:self.topNavigationBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:self.topNavigationBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [superView addConstraints:@[constraint,constraint1,constraint2]];
}


- (IBAction)checkAllProduct:(id)sender
{
    PharmacyGoodsListViewController *VC = [[PharmacyGoodsListViewController alloc]initWithNibName:@"PharmacyGoodsListViewController" bundle:nil];
    VC.branchId = [QWGLOBALMANAGER getMapBranchId];
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}


#pragma mark -
#pragma mark UIScrollerDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    [self fixedNavigationBar];
}

//cell 1-1的Button点击事件
- (void)buttonAction:(QWButton *)sender
{
    TemplatePosVoModel *model = sender.obj;
    [self pushIntoWebViewControllerWithURL:model.forwordUrl objId:model.objId cls:[NSString stringWithFormat:@"%d",model.cls] isSpecial:[NSString stringWithFormat:@"%hhd",model.special] title:model.title canShare:model.flagShare];
}

#pragma mark
#pragma mark H5界面各种跳转
- (void)pushIntoWebViewControllerWithURL:(NSString *)url objId:(NSString *)objId cls:(NSString *)cls isSpecial:(NSString *)isSpecial title:(NSString *)strTitle canShare:(NSString *)canShare
{
    [QWGLOBALMANAGER checkEventId:@"首页_运营点" withLable:@"首页_运营点" withParams:nil];
    WebDirectViewController *vcWebDirect = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
    WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
    modelLocal.title = strTitle;

    if ([isSpecial isEqualToString:@"Y"]) {
        vcWebDirect.isSpecial = YES;
    }
    if (([cls intValue] == 1) || ([cls intValue] == 2)) {       // 1 慢病  2 专题列表
        if ([url hasPrefix:@"http"]) {
            modelLocal.url = url;
        } else {
            modelLocal.url = @"";
            modelLocal.strParams = url;
        }
        if ([cls intValue] == 1) {
            // 慢病专区
            modelLocal.typeLocalWeb = WebLocalTypeSlowDiseaseArea;
        } else if ([cls intValue] == 2) {
            // 专题列表
            modelLocal.typeLocalWeb = WebLocalTypeTopicList;
            
        }
        [vcWebDirect setWVWithLocalModel:modelLocal];
    } else if (([cls intValue] == 3)||([cls intValue] == 4)){
        if ([url hasPrefix:@"http"]) {
            modelLocal.url = url;
        } else {
            modelLocal.url = @"";
            modelLocal.strParams = url;
        }
        if ([cls intValue] == 3) {
            //专区
            modelLocal.typeLocalWeb = WebLocalTypeDivision;
            [vcWebDirect setWVWithLocalModel:modelLocal];
            
        } else if ([cls intValue] == 4) {
            // 某个专题详情
            modelLocal.typeLocalWeb = WebPageToWebTypeTopicDetail;
            [vcWebDirect setWVWithLocalModel:modelLocal];
        }
    }else if([cls intValue] == 7) {
        //商品列表
        modelLocal.typeLocalWeb = WebLocalTypeOuterLink;
        
        modelLocal.url = [NSString stringWithFormat:@"%@QWWEB/activity/html/branchPros/pros.html?channel=1&branchId=%@&templateId=%@",H5_DOMAIN_URL,[QWGLOBALMANAGER getMapBranchId],objId];
        
        modelLocal.typeTitle = WebTitleTypeNone;
        if ([canShare boolValue]) {
            vcWebDirect.didSetShare = NO;
        } else {
            modelLocal.typeTitle = WebTitleTypeNone;
            vcWebDirect.didSetShare = YES;
        }
        vcWebDirect.isOtherLinks = YES;
        [vcWebDirect setWVWithLocalModel:modelLocal];
        
    }else if([cls intValue] == 8){
        //新微商模板
        modelLocal.typeLocalWeb = WebLocalTypeOuterLink;
        modelLocal.typeTitle = WebTitleTypeNone;
        modelLocal.url = [NSString stringWithFormat:@"%@QWWEB/activity/html/trendsTemplate.html?channel=1&id=%@",H5_DOMAIN_URL,objId];
        if ([canShare boolValue]) {
            //            modelLocal.typeTitle = WebTitleTypeOnlyShare;
            vcWebDirect.didSetShare = NO;
        } else {
            modelLocal.typeTitle = WebTitleTypeNone;
            vcWebDirect.didSetShare = YES;
        }
        vcWebDirect.isOtherLinks = YES;
        [vcWebDirect setWVWithLocalModel:modelLocal];
        
    }else if([cls intValue] == 9){
        //翻页模板
        modelLocal.typeLocalWeb = WebLocalTypeOuterLink;
        modelLocal.typeTitle = WebTitleTypeNone;
        modelLocal.url = [NSString stringWithFormat:@"%@QWWEB/activity/html/flipTemplate.html?channel=1&id=%@",H5_DOMAIN_URL,objId];
        if ([canShare boolValue]) {
            //            modelLocal.typeTitle = WebTitleTypeOnlyShare;
            vcWebDirect.didSetShare = NO;
        } else {
            modelLocal.typeTitle = WebTitleTypeNone;
            vcWebDirect.didSetShare = YES;
        }
        vcWebDirect.isOtherLinks = YES;
        [vcWebDirect setWVWithLocalModel:modelLocal];
        
    }else {
        NSString *strUrl = @"";
        if (![url hasPrefix:@"http"]) {
            url = [NSString stringWithFormat:@"%@%@",H5_BASE_URL,url];
        }
        strUrl = [NSString stringWithFormat:@"%@",url];
        modelLocal.url = strUrl;
        modelLocal.typeLocalWeb = WebLocalTypeOuterLink;
        if ([canShare boolValue]) {
//            modelLocal.typeTitle = WebTitleTypeOnlyShare;
            vcWebDirect.didSetShare = NO;
        } else {
            modelLocal.typeTitle = WebTitleTypeNone;
            vcWebDirect.didSetShare = YES;
        }
        
        vcWebDirect.isOtherLinks = YES;
        [vcWebDirect setWVWithLocalModel:modelLocal];
    }
    
    __weak typeof(self) weakSelf = self;
    vcWebDirect.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vcWebDirect animated:YES];
}

//点击跳转各类H5界面
- (void)pushIntoWebViewController:(NSString *)url title:(NSString *)title
{
    WebDirectViewController *vcWebDirect = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
    NSString *strUrl = @"";
    WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
    if (![url hasPrefix:@"http"]) {
        url = [NSString stringWithFormat:@"%@%@",H5_BASE_URL,url];
    }
    strUrl = [NSString stringWithFormat:@"%@",url];
    modelLocal.url = strUrl;
    modelLocal.typeLocalWeb = WebLocalTypeOuterLink;
    modelLocal.title = @"";
    vcWebDirect.isOtherLinks = YES;
    [vcWebDirect setWVWithLocalModel:modelLocal];
    
    vcWebDirect.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vcWebDirect animated:YES];
}

//跳转领券中心界面
- (IBAction)pushIntoCouponTicket:(id)sender
{
    CouponCenterViewController *couponCenterViewController = [[CouponCenterViewController alloc] initWithNibName:@"CouponCenterViewController" bundle:nil];
    couponCenterViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:couponCenterViewController animated:YES];
}

//跳转优惠商品界面
- (IBAction)pushIntoCouponProduct:(id)sender
{
    CouponPromotionHomePageViewController *couponProduct = [[CouponPromotionHomePageViewController alloc]init];
    couponProduct.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:couponProduct animated:YES];
}

#pragma mark -
#pragma mark 首页搜索逻辑
//跳转到搜索界面
- (IBAction)pushToSearchView:(id)sender
{
    [QWGLOBALMANAGER checkEventId:@"首页_点击搜索框" withLable:@"首页_点击搜索框" withParams:nil];
    HomeSearchMedicineViewController *VC = [[HomeSearchMedicineViewController alloc] initWithNibName:@"HomeSearchMedicineViewController" bundle:nil];
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}

//跳转到扫码界面
- (IBAction)pushToScanRedaerView:(id)sender {

    if (![QYPhotoAlbum checkCameraAuthorizationStatus]) {
        [QWGLOBALMANAGER getCramePrivate];
        return;
    }
    [QWGLOBALMANAGER checkEventId:@"首页_点击扫码按钮" withLable:@"首页_点击扫码按钮" withParams:nil];

    HomeScanViewController *scanVC = [[HomeScanViewController alloc] initWithNibName:@"HomeScanViewController" bundle:nil];
    scanVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scanVC animated:NO];
}

- (IBAction)pushIntoPharmacyStoreDetail:(id)sender
{
    [QWGLOBALMANAGER statisticsEventId:@"首页_药房名称" withLable:@"首页_药房名称" withParams:nil];
    PharmacySotreViewController *VC = [[PharmacySotreViewController alloc]init];
    VC.branchId = [QWGLOBALMANAGER getMapBranchId];
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 聊天 Action
- (void)pushToChatView:(id)sender{
    
    if(!QWGLOBALMANAGER.loginStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        loginViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:loginViewController animated:YES];
        return;
    }
    [QWGLOBALMANAGER statisticsEventId:@"首页_咨询" withLable:@"首页_咨询" withParams:nil];
    //咨询按钮点击逻辑，fixed at V3.2.0 by lijian
    if(!branchOnline && !branchHasExpert){
        //药房既无药师也没有砖家，toast提示
        [SVProgressHUD showErrorWithStatus:@"本店暂无法为您提供咨询服务"];
    }else{
        //有砖家，跳转咨询中间页面
        if(branchHasExpert){
            ChatChooserViewController *chooseVC = [[ChatChooserViewController alloc]initWithNibName:@"ChatChooserViewController" bundle:nil];
            chooseVC.branchId = [QWGLOBALMANAGER getMapBranchId];
            chooseVC.branchName = [QWGLOBALMANAGER getMapInfoModel].branchName;
            chooseVC.branchLogo = [QWGLOBALMANAGER getMapInfoModel].logo;
            chooseVC.hidesBottomBarWhenPushed = YES;
            chooseVC.online     = branchOnline;
            [self.navigationController pushViewController:chooseVC animated:YES];
        }else{//没有砖家，直接点对点聊天
            ChatViewController *chatVC = [[UIStoryboard storyboardWithName:@"ChatViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ChatViewController"];
            chatVC.title = [QWGLOBALMANAGER getMapInfoModel].branchName;
            chatVC.sendConsultType = Enum_SendConsult_Common;
            chatVC.branchId = [QWGLOBALMANAGER getMapBranchId];
            chatVC.hidesBottomBarWhenPushed = YES;
            chatVC.branchName = [QWGLOBALMANAGER getMapInfoModel].branchName;

            [self.navigationController pushViewController:chatVC animated:YES];
        }
    }
    
}


@end
