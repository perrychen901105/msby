//
//  HealthInfoMainViewController.m
//  APP
//
//  Created by PerryChen on 1/4/16.
//  Copyright © 2016 carret. All rights reserved.
//

#import "HealthInfoMainViewController.h"
#import "ResortViewController.h"
#import "BYListBar.h"
#import "HealthInfoListViewController.h"
#import "ResortViewHeader.h"
#import "InfoMsg.h"
#import "QWLocation.h"
#import "LocationShowWelcomeOnce.h"
#import "AppDelegate.h"
#import "jumpHtmlViewController.h"

#define kListBarH       kScreenW/320*39      // 顶部栏高度
#define kArrowW         40      // 添加按钮宽度
#define kAnimationTime  0.8     // 动画时间

@interface HealthInfoMainViewController() <UIScrollViewDelegate>
@property (nonatomic,strong) BYListBar      *listBar;           //频道选择横向条
@property (nonatomic,strong) UIButton       *btnAdd;
@property (nonatomic,strong) UIScrollView   *mainScroller;
@property (nonatomic,strong) NSMutableArray *arrTop;
@property (nonatomic,strong) ResortItem     *itemSelect;        //选中的频道model
@property (nonatomic,assign) NSInteger      intIndex;           //选中的频道index
@property (nonatomic,assign) BOOL           isLogout;
@property (nonatomic,strong) UIButton       *btnHtml;

@end

@implementation HealthInfoMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"阅读";
    //供HTML5测试
//    if([SHOW_HTML boolValue]) {
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"测试HTML" style:UIBarButtonItemStylePlain target:self action:@selector(jumpTest:)];
//     }
//    
    
    self.arrTop = [@[] mutableCopy];
    // 拿缓存数据
    NSArray *arrSort = [ResortItem getArrayFromDBWithWhere:@"dataType = '1'"];
    if (arrSort.count > 0) {
        ResortItem *firstItem = arrSort[0];
        DDLogDebug(@"the item need sync tag is %@",firstItem.updatedStatus);
        if ([firstItem.updatedStatus isEqualToString:@"N"]) {
            [QWGLOBALMANAGER syncInfoChannelList:YES];
        } else {
            [self requestChannelList];
        }
    } else {
        [self requestChannelList];
    }
}

-(void)jumpTest:(id)sender{
    jumpHtmlViewController *vc=[[jumpHtmlViewController alloc] initWithNibName:@"jumpHtmlViewController" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self checkGuideShowOnce];
}

- (void)checkGuideShowOnce
{
    if([QWUserDefault getBoolBy:ONCE_COVER_LOADING])
    {
        return;
    }
    [QWUserDefault setBool:YES key:ONCE_COVER_LOADING];
    LocationShowWelcomeOnce *view = (LocationShowWelcomeOnce *)[[NSBundle mainBundle] loadNibNamed:@"LocationShowWelcomeOnce" owner:self options:nil][0];
    NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
    [QWGLOBALMANAGER statisticsEventId:@"x_wzdl" withLable:@"浮层" withParams:tdParams];
    [view showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 *  获取缓存数据
 */
- (void)getCachedList
{
    // 获取缓存列表
    self.arrTop = (NSMutableArray *)[ResortItem getArrayFromDBWithWhere:@"dataType = '1'"];
    [self initInfoList];
}

/**
 *  初始化资讯页面
 */
- (void)initInfoList
{
    if (self.arrTop.count == 0) {
        if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
            [self showInfoView:kWarning12 image:@"网络信号icon"];
        } else {
            [self showInfoView:@"缺少数据" image:@"ic_img_fail"];
        }
        return;
    }
    __weak typeof(self) unself = self;

    NSArray *originalArray = self.arrTop;                   // original array of objects with duplicates
    NSMutableArray *uniqueArray = [NSMutableArray array];   // 用来频道去重
    NSMutableSet *names = [NSMutableSet set];
    // 过滤，防止频道重复
    for (ResortItem *obj in originalArray) {
        NSString *destinationName = obj.strID;
        if (![names containsObject:destinationName]) {
            [uniqueArray addObject:obj];
            [names addObject:destinationName];
        }
    }
    self.arrTop = uniqueArray;
    // 增加添加频道按钮
    if (!self.btnAdd) {
        self.btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnAdd.frame = CGRectMake(kScreenW-kArrowW, 0, kArrowW, kListBarH);
        [self.btnAdd addTarget:self
                        action:@selector(btnActionPush:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnAdd setImage:[UIImage imageNamed:@"info_btn_edit"] forState:UIControlStateNormal];
        self.btnAdd.backgroundColor = RGBHex(qwColor4);
        [self.view addSubview:self.btnAdd];
    }
    // 添加底部滑动主页面
    if (self.mainScroller) {
        for (UIView *subView in self.mainScroller.subviews) {
            [subView removeFromSuperview];
        }
        for (QWBaseVC *vcSub in self.childViewControllers) {
            [vcSub removeFromParentViewController];
        }
        [self.mainScroller removeFromSuperview];
        self.mainScroller = nil;
    }
    if (!self.mainScroller) {
        self.mainScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kListBarH, kScreenW , self.view.frame.size.height-kListBarH)];//-64.0f-50.0f
        self.mainScroller.backgroundColor = [UIColor yellowColor];
        self.mainScroller.bounces = NO;
        self.mainScroller.pagingEnabled = YES;
        self.mainScroller.showsHorizontalScrollIndicator = NO;
        self.mainScroller.showsVerticalScrollIndicator = NO;
        self.mainScroller.delegate = self;
        self.mainScroller.contentSize = CGSizeMake(kScreenW*self.arrTop.count,self.mainScroller.frame.size.height);
        [self.view insertSubview:self.mainScroller atIndex:0];
        
        for (int i = 0; i < self.arrTop.count; i++) {
            // 添加子视图
            [self addScrollViewWithItemName:self.arrTop[i] index:i];
        }
        if (self.arrTop.count > 0) {
            // 刷新数据
            HealthInfoListViewController *vcList = (HealthInfoListViewController *)self.childViewControllers[0];
            [vcList refreshData];
        }
    }
    // 添加顶部横向view
    if (self.listBar) {
        for (UIView *sview in self.listBar.subviews) {
            [sview removeFromSuperview];
        }
        [self.listBar removeFromSuperview];
        self.listBar = nil;
    }
    if (!self.listBar) {
        self.listBar = [[BYListBar alloc] initWithFrame:CGRectMake(0, 0, kScreenW-kArrowW, kListBarH)];
        self.listBar.backgroundColor = RGBHex(qwColor4);
        // 设置显示的item
        self.listBar.visibleItemList = self.arrTop;
        self.listBar.listBarItemClickBlock = ^(ResortItem *item , NSInteger itemIndex){
            //添加scrollview
            // 设置选中的
            unself.itemSelect = item;
            unself.intIndex = itemIndex;
            //移动到该位置
            unself.mainScroller.contentOffset = CGPointMake(itemIndex * unself.mainScroller.frame.size.width, 0);
            
            HealthInfoListViewController *vcList = (HealthInfoListViewController *)unself.childViewControllers[itemIndex];
            // 是否是专题栏
            if ([item.strTitle isEqualToString:@"专题"]) {
                vcList.isTopicChannel = YES;
            } else {
                vcList.isTopicChannel = NO;
            }
            
            [vcList refreshData];
            // 统计事件
            
            [QWGLOBALMANAGER statisticsEventId:@"阅读_频道" withLable:@"资讯" withParams:nil];
        };
        
        UIView *viewBottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, kListBarH, kScreenW, 0.5)];
        viewBottomLine.backgroundColor = RGBHex(qwColor10);
        [self.view addSubview:viewBottomLine];
        
        [self.view addSubview:self.listBar];
        // 重置tabbar的Offset
        if (self.intIndex > -1) {
            [self.listBar itemClickByScrollerWithIndex:self.intIndex];
        } else {
            [self.listBar itemClickByScrollerWithIndex:self.intIndex];
        }
        
        //添加频道事件的回调，暂时未用
        self.listBar.listBarAddItemBlock = ^(ResortItem *item, NSInteger itemIndex, NSMutableArray *arrTop) {
            unself.mainScroller.contentSize = CGSizeMake(kScreenW*arrTop.count,unself.mainScroller.frame.size.height);
            [unself addScrollViewWithItemName:item index:itemIndex];
            unself.arrTop = arrTop;
        };
        //删除频道事件的回调，暂时未用
        self.listBar.listBarDeleteItemBlock = ^(ResortItem *item, NSInteger itemIndex) {
            [unself removeScrollViewWithItemName:item index:itemIndex];
        };
        //重排频道事件的回调，暂时未用
        self.listBar.listBarSwitchItemBlock = ^(NSInteger preIndex, NSInteger afterIndex) {
            [unself switchScrollViewWithPreIndex:preIndex afterIndex:afterIndex];
        };
    }
}
/**
 *  断网的点击事件
 *
 *  @param sender 按钮
 */
- (void)viewInfoClickAction:(id)sender
{
    [self requestChannelList];
}

/**
 *  请求资讯所有频道
 */
- (void)requestChannelList
{
    if (QWGLOBALMANAGER.currentNetWork != kNotReachable) {
        InfoMsgQueryUserNotAddChannelModelR *modelR = [InfoMsgQueryUserNotAddChannelModelR new];
        if (self.isLogout) {
            modelR.token = @"";
        } else {
            modelR.token = QWGLOBALMANAGER.configure.userToken == nil ? @"" : QWGLOBALMANAGER.configure.userToken;
        }
        modelR.device = DEVICE_ID;
        // 请求接口
        [InfoMsg getNotAddedHealthInfoChannelList:modelR success:^(MsgChannelListVO *model) {
            [self removeInfoView];
            if (model.list.count <= 0) {
                [self showInfoView:@"缺少数据" image:@"ic_img_fail"];
                return ;
            }
            [self.arrTop removeAllObjects];

            for (int i = 0; i < model.list.count; i++) {
                MsgChannelVO *modelVO = model.list[i];
                ResortItem *item = [ResortItem new];
                item.strTitle = modelVO.channelName;
                if ([modelVO.type intValue] == 1) {
                    item.olocation = ocenter;           // 设置这个item的原始位置 中间
                } else {
                    item.olocation = obottom;           // 设置这个item的原始位置 底部
                }
                if ([item.strTitle isEqualToString:@"热点"]) {
                    item.olocation = otop;
                }
                item.dataType = @"1";                   // 保存数据库时使用 标示用户添加的频道
                item.strID = modelVO.channelID;
                [self.arrTop addObject:item];
            }
            NSMutableArray *arrCenter = [@[] mutableCopy];
            NSMutableArray *arrBottom = [@[] mutableCopy];
            for ( int i = 0; i < model.listNoAdd.count; i++) {
                MsgChannelVO *modelVO = model.listNoAdd[i];
                ResortItem *item = [ResortItem new];
                item.strTitle = modelVO.channelName;
                item.strID = modelVO.channelID;
                if ([modelVO.type intValue] == 1) {
                    item.olocation = ocenter;
                    item.dataType = @"2";               // 资讯频道
                    [arrCenter addObject:item];
                } else {
                    item.olocation = obottom;
                    item.dataType = @"3";               // 疾病频道
                    [arrBottom addObject:item];
                }
            }
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            DDLogDebug(@"path is %@",paths.firstObject);
            // 初始化选择的item
            self.itemSelect = nil;
            self.intIndex = 0;
            [self initInfoList];
            
            // 通过线程进行数据保存
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [ResortItem deleteAllObjFromDB];
                NSArray *arrT = [NSArray arrayWithArray:self.arrTop];
                [ResortItem saveObjToDBWithArray:arrT];
                [ResortItem saveObjToDBWithArray:(NSArray *)arrCenter];
                [ResortItem saveObjToDBWithArray:(NSArray *)arrBottom];
            });
        } failure:^(HttpException *e) {
            [self getCachedList];
        }];
    } else {
        [self getCachedList];
    }
}

/**
 *  进入添加频道
 *
 *  @param sender 添加频道按钮
 */
- (IBAction)btnActionPush:(id)sender {
    
    [QWGLOBALMANAGER statisticsEventId:@"阅读_更多频道" withLable:@"资讯" withParams:nil];
    
    __weak typeof(self) unself = self;
    // 跳转动画
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    ResortViewController *vc = [[ResortViewController alloc] initWithNibName:@"ResortViewController" bundle:nil];
    vc.listBar = self.listBar;
    // 设置选择中的item
    if (self.itemSelect != nil) {
        vc.itemSelect = self.itemSelect;
    } else {
        vc.itemSelect = self.arrTop[0];
    }
    // 可优化，将所有操作结果放在这里
    vc.resortRefresh = ^(NSMutableArray *arrListTop, NSMutableArray *arrListCenter, NSMutableArray *arrListBottom, NSInteger indexSelect, ResortItem *itemSelect) {
        // 从编辑频道列表页面返回的block
        unself.intIndex = indexSelect;
        unself.arrTop = arrListTop;
        // 可能出现index 是-1的情况
        if (indexSelect > 0) {
            unself.itemSelect = itemSelect;
        } else {
            unself.itemSelect = arrListTop[0];
        }
        // 重置页面
        [unself initInfoList];
    };
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:NO];
}

/**
 *  增加一个子视图
 *
 *  @param item  该子视图需要的model
 *  @param index 该子视图的index
 */
-(void)addScrollViewWithItemName:(ResortItem *)item index:(NSInteger)index{
    HealthInfoListViewController *detailVC = [[HealthInfoListViewController alloc] initWithNibName:@"HealthInfoListViewController" bundle:nil];
    detailVC.view.frame = CGRectMake(index * self.mainScroller.frame.size.width, 0, self.mainScroller.frame.size.width, self.mainScroller.frame.size.height);
    detailVC.itemSelect = item;
    detailVC.channelID = item.strID;
    detailVC.channelName = item.strTitle;
    [self addChildViewController:detailVC];
    detailVC.view.tag = index;
    [self.mainScroller addSubview:detailVC.view];
    
}

/**
 *  遍历子视图，给界面增加tag
 */
- (void)loopSubViews
{
    for (int i = 0; i < self.childViewControllers.count; i++) {
        HealthInfoListViewController *vcD = self.childViewControllers[i];
        vcD.view.frame = CGRectMake(i * self.mainScroller.frame.size.width, 0, self.mainScroller.frame.size.width, self.mainScroller.frame.size.height);
        vcD.view.tag = i;
    }
}

/**
 *  scrollview滚动到停止的事件
 *
 *  @param scrollView MainScrollView
 */
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.listBar itemClickByScrollerWithIndex:scrollView.contentOffset.x / self.mainScroller.frame.size.width];
}

- (void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj
{
    if (type == NotifQuitOut) {                             // 用户退出登录
        self.isLogout = YES;
        [self requestChannelList];
    } else if (type == NotifLoginSuccess) {                 // 用户登录
        self.isLogout = NO;
        [self requestChannelList];
    } else if (type == NotifInfoListTabbarSelected) {       // 点击tabbar
        [QWGLOBALMANAGER syncInfoChannelList:NO];
    } else if (type == NotifInfoListUpdated) {              // 通知列表更新
        [self getCachedList];
    } else if (type == NotifPushViewAfterStartUp) {
        AppDelegate *delega = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delega delayPushVC];
    }
}

// 点击状态栏，子视图滚到顶部
- (void)clickStatusBar
{
    if (self.intIndex >= 0) {
        HealthInfoListViewController *vcList = self.childViewControllers[self.intIndex];
        if (vcList != nil) {
            [vcList scrollToTop];
        }
    }
}

#pragma mark - 删除和重排界面的操作，暂时未用
- (void)removeScrollViewWithItemName:(ResortItem *)item index:(NSInteger)index {
    for (UIView *sview in self.mainScroller.subviews) {
        if (sview.tag == index) {
            [sview removeFromSuperview];
            break;
        }
    }
    HealthInfoListViewController *vcD = self.childViewControllers[index];
    [vcD removeFromParentViewController];
    [self loopSubViews];
    self.mainScroller.contentSize = CGSizeMake(kScreenW*self.arrTop.count,self.mainScroller.frame.size.height);
}

- (void)switchScrollViewWithPreIndex:(NSInteger)preIndex afterIndex:(NSInteger)afterIndex
{
    HealthInfoListViewController *vcPre = self.childViewControllers[preIndex];
    HealthInfoListViewController *vcAfter = self.childViewControllers[afterIndex];
    if (vcPre == nil || vcAfter == nil) {
        return;
    }
    UIView *preView = [self.mainScroller viewWithTag:preIndex];
    UIView *afterView = [self.mainScroller viewWithTag:afterIndex];
    CGRect tempRect = CGRectZero;
    tempRect = preView.frame;
    preView.frame = afterView.frame;
    afterView.frame = tempRect;
    
    NSMutableArray *arrTempControllers = [self.childViewControllers mutableCopy];
    arrTempControllers[preIndex] = vcAfter;
    arrTempControllers[afterIndex] = vcPre;
    for (HealthInfoListViewController *vc in self.childViewControllers) {
        [vc removeFromParentViewController];
    }
    for (HealthInfoListViewController *vc in arrTempControllers) {
        [self addChildViewController:vc];
    }
    
    NSInteger tempTag = vcPre.view.tag;
    vcPre.view.tag = vcAfter.view.tag;
    vcAfter.view.tag = tempTag;
}

@end
