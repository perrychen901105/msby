//
//  FinderMainViewController.m
//  APP
//
//  Created by 李坚 on 15/12/30.
//  Copyright © 2015年 carret. All rights reserved.
//

#import "FinderMainViewController.h"
#import "FinderSearchViewController.h"
#import "TouchTableView.h"
#import "HealthToolView.h"
#import "Discover.h"
#import "WebDirectViewController.h"
#import "HealthToolViewController.h"
#import "ChooseCouponView.h"
#import "WYLocalNotifVC.h"
#import "FamliyMedcineViewController.h"
#import "HealthyScenarioViewController.h"
#import "FactoryListViewController.h"
#import "WebDirectViewController.h"
#import "QuickMedicineViewController.h"
#import "SymptomMainViewController.h"
#import "DiseaseViewController.h"
#import "HealthIndicatorViewController.h"
#import "LoginViewController.h"

#define kTableViewContentH 280
#define kSearchViewH 215
#import "NSString+TransDomain.h"

static NSString *const CellIdentifier = @"OrderListCellIdentifier";



@interface FinderMainViewController ()<UITableViewDataSource,UITableViewDelegate>{
    CGPoint gestureStartPoint;
    HealthToolView *view;
    CGFloat tabH;
}
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *healthLabel;
@property (nonatomic, strong) NSMutableArray *searchList;
@property (nonatomic,strong) NSMutableArray *testList;
@property (weak, nonatomic) IBOutlet UILabel *allSearch;
@property (nonatomic,assign)BOOL isSearch;
@property (nonatomic,strong)NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIButton *toolBtn;
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) IBOutlet UIView *footview;
@property (weak, nonatomic) IBOutlet UIView *footBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpace;

@end

@implementation FinderMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"自查";
    tabH = 0;
    self.healthLabel.layer.masksToBounds = YES;
    self.healthLabel.layer.cornerRadius = 25.0f;
    self.searchView.layer.masksToBounds = YES;
    self.searchView.layer.cornerRadius = 2.5f;
    
    self.mainTableView.tableFooterView = self.footview;
    self.mainTableView.tableHeaderView = self.headerView;
    _isSearch = YES;
    _pageControl.currentPage = 0;

  
    //tableview的左右手势
    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UISwipeGestureRecognizer *swipeleft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(changeSearchPage)];
    swipeleft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *swiperight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(changeSearchPage)];
    swiperight.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.mainTableView addGestureRecognizer:swipeleft];
    
    [self.mainTableView addGestureRecognizer:swiperight];
    
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:10.75 target:self selector:@selector(changeSearchPage) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}
-(UIView *)headerView {
    _headerView.frame = CGRectMake(0, 0, APP_W, 100);
    return _headerView;
}

-(UIView *)footview {
    self.footBgView.layer.cornerRadius = 10.0;
    self.footBgView.layer.masksToBounds = YES;
    DebugLog(@"-------%f",APP_H);
    NSArray *viewControllers = self.navigationController.viewControllers;
    if ([[viewControllers firstObject] isKindOfClass:[self class]]) {
        tabH = 50;
    }
    CGFloat h= 0;
    h  = APP_H - kTableViewContentH - kSearchViewH - 20 - 64 - tabH ;
    if (h > 0) {
        self.topSpace.constant = h;
    }else {
        self.topSpace.constant = 50;
    }
    _footview.frame = CGRectMake(0, 0, APP_W, 250 + self.topSpace.constant);
    //6条数据下
    return _footview;
}

-(void)setSearchList:(NSMutableArray *)searchList {
    _searchList = searchList;
    if (searchList.count >= 6) {
        return;
    }
    //不足6条数据下校正位置frame
    CGFloat h= 0;
    h  = APP_H - searchList.count * 30 - 100 - kSearchViewH - 20 - 64 - tabH ;
    if (h > 0) {
        self.topSpace.constant = h;
    }else {
        self.topSpace.constant = 50;
    }
    _footview.frame = CGRectMake(0, 0, APP_W, 250 + self.topSpace.constant);
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryData];
}

-(void)popVCAction:(id)sender {
    [QWGLOBALMANAGER statisticsEventId:@"自查_返回" withLable:nil withParams:nil];
    [super popVCAction:sender];
    [self.timer invalidate];
}

- (void)changeSearchPage{
    _isSearch = !_isSearch;
    _pageControl.currentPage = _isSearch?0:1;

    [UIView animateWithDuration:.36 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        if (_isSearch) {
            self.allSearch.text = @"大家都在搜";
        }else {
            self.allSearch.text = @"大家都在测";
        }
        if(!iOS7) {
            self.mainTableView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        }
//        self.mainTableView.alpha = 0.0;

    } completion:^(BOOL finished) {
        [self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [UIView animateWithDuration:.36 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
             if(!iOS7) {
                 self.mainTableView.transform = CGAffineTransformMakeScale(1, 1);
             }
//            self.mainTableView.alpha = 1.0;

        } completion:^(BOOL finished) {
            
        }];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)pushIntoSeachView:(id)sender {
    [QWGLOBALMANAGER statisticsEventId:@"自查_点击搜索框" withLable:nil withParams:nil];
    [QWGLOBALMANAGER statisticsEventId:@"x_fx_ssk" withLable:@"发现" withParams:nil];
    FinderSearchViewController * searchViewController = [[FinderSearchViewController alloc] initWithNibName:@"FinderSearchViewController" bundle:nil];
    searchViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)removeBlurView
{
    [self.blurView removeFromSuperview];
    self.blurView = nil;
}
- (IBAction)ClickAction:(UIButton *)sender {
    NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
    switch (sender.tag) {
        case 1://药品
        {
            [QWGLOBALMANAGER statisticsEventId:@"自查_药品" withLable:nil withParams:nil];
            QuickMedicineViewController *vc = [QuickMedicineViewController new];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            tdParams[@"工具名"]=@"药品";
        }
            break;
        case 2://疾病
        {
            [QWGLOBALMANAGER statisticsEventId:@"自查_疾病" withLable:nil withParams:nil];
            DiseaseViewController *vc = [DiseaseViewController new];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            tdParams[@"工具名"]=@"疾病";
        }
            break;
        case 3://症状
        {
            [QWGLOBALMANAGER statisticsEventId:@"自查_症状" withLable:nil withParams:nil];
            SymptomMainViewController *vc = [SymptomMainViewController new];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            tdParams[@"工具名"]=@"症状";
        }
            break;
        case 4://家庭药箱
        {
            [QWGLOBALMANAGER statisticsEventId:@"自查_家庭药箱" withLable:nil withParams:nil];
            if(!QWGLOBALMANAGER.loginStatus) {
                LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
                loginViewController.isPresentType = YES;
                [self presentViewController:navgationController animated:YES completion:NULL];
                __weak typeof(self) weakSelf = self;
                loginViewController.loginSuccessBlock = ^(){
                    [weakSelf enterFamily];
                };
            }else {
                [self enterFamily];
            }
        }
            break;
        case 5://健康评测
        {
            [QWGLOBALMANAGER statisticsEventId:@"自查_健康评测" withLable:nil withParams:nil];
            WebDirectViewController *vc = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
            WebDirectLocalModel *model = [WebDirectLocalModel new];
            model.typeLocalWeb = WebPageToWebTypeHealthCheckBegin;
            model.title=@"健康评测";
            [vc setWVWithLocalModel:model];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            tdParams[@"工具名"]=@"健康评测";
        }
            break;
        case 7://检测指标
        {
            [QWGLOBALMANAGER statisticsEventId:@"自查_检测指标" withLable:nil withParams:nil];
            HealthIndicatorViewController *vc = [HealthIndicatorViewController new];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            tdParams[@"工具名"]=@"检测指标";
        }
            break;
        case 6://健康方案
        {
            [QWGLOBALMANAGER statisticsEventId:@"自查_健康方案" withLable:nil withParams:nil];
            HealthyScenarioViewController * healthyScenario = [[HealthyScenarioViewController alloc] init];
            healthyScenario.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:healthyScenario animated:YES];
            tdParams[@"工具名"]=@"健康方案";
        }
            break;
        case 8://品牌
        {
            [QWGLOBALMANAGER statisticsEventId:@"自查_品牌" withLable:nil withParams:nil];
            FactoryListViewController *vc = [[FactoryListViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            tdParams[@"工具名"]=@"品牌";
        }
            break;
    }
    [QWGLOBALMANAGER statisticsEventId:@"x_fx_jkgj" withLable:@"发现" withParams:tdParams];
}

-(void)enterFamily {
    FamliyMedcineViewController *famliyMedcineViewController = [[UIStoryboard storyboardWithName:@"FamilyMedicineListViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FamliyMedcineViewController"];
    famliyMedcineViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:famliyMedcineViewController animated:YES];
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_isSearch) {
        return MIN(_searchList.count,5);
    }else {
        return MIN(_testList.count,5);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{    
    return 30.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]init];
    }
    for(UIView *v in cell.subviews){
        if ([v isKindOfClass:[UILabel class]]) {
            [v removeFromSuperview];
        }
    }
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, APP_W, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    if (_isSearch) {
        label.text = _searchList[indexPath.row]?_searchList[indexPath.row]:@"";
    }else {
        HotTestVO *vo = _testList[indexPath.row];
        label.text = vo.testName;
    }
    
    label.textColor = RGBHex(qwColor8);
    label.font = fontSystem(kFontS3);
    
    [cell.contentView addSubview:label];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isSearch) {
        [QWGLOBALMANAGER statisticsEventId:@"自查_大家都在搜" withLable:nil withParams:nil];
        FinderSearchViewController *vc = [[FinderSearchViewController alloc]initWithNibName:@"FinderSearchViewController" bundle:nil];
        vc.hidesBottomBarWhenPushed = YES;
        vc.searchWord = _searchList[indexPath.row];
        NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
        tdParams[@"搜索词"] = _searchList[indexPath.row];;
        [QWGLOBALMANAGER statisticsEventId:@"x_fx_ssc" withLable:@"发现" withParams:tdParams];
        
        //渠道统计 用户行为统计
        ChannerTypeModel *modelTwo=[ChannerTypeModel new];
        modelTwo.objRemark=_searchList[indexPath.row];
        modelTwo.objId=@"";
        modelTwo.cKey=@"everyone_search";
        [QWGLOBALMANAGER qwChannel:modelTwo];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [QWGLOBALMANAGER statisticsEventId:@"自查_大家都在测" withLable:nil withParams:nil];
        HotTestVO *vo = _testList[indexPath.row];
        WebDirectViewController *vc = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
        WebHealthCheckDetailModel *modelHealthCheck = [WebHealthCheckDetailModel new];
        modelHealthCheck.checkTestId = vo.testID;
        WebDirectLocalModel *model = [WebDirectLocalModel new];
        if ([vo.testID hasPrefixWithHTTPDomain]) {
            model.typeLocalWeb = WebLocalTypeOuterLink;
            model.url = [NSString stringWithFormat:@"%@",vo.testID];
        } else {
            model.typeLocalWeb = WebLocalTypeHealthCheckDetail;
        }
        model.title = vo.testName;
        model.modelHealthCheck = modelHealthCheck;
        vc.hidesBottomBarWhenPushed = YES;
        [vc setWVWithLocalModel:model];
        NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
        tdParams[@"标题"] = _testList[indexPath.row];;
        [QWGLOBALMANAGER statisticsEventId:@"x_fx_djdzc" withLable:@"发现" withParams:tdParams];
        
        //渠道统计 用户行为统计
        ChannerTypeModel *modelTwo=[ChannerTypeModel new];
        modelTwo.objRemark=vo.testName;
        modelTwo.objId=vo.testID;
        modelTwo.cKey=@"everyone_test";
        [QWGLOBALMANAGER qwChannel:modelTwo];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj {
    if (type == NotifRemoveHealthView) {
        if (_blurView) {
            [_blurView removeFromSuperview];
        }
        if (view) {
            [view removeFromSuperview];
        }
    }
}
#pragma mark - 数据请求
-(void)queryData {
    
    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        
        DiscoverR *modelR = [DiscoverR new];
        modelR.province = mapInfoModel.province;
        modelR.city = mapInfoModel.city;
        [Discover queryDiscover:modelR success:^(DiscoverModel *model) {
            self.searchList = [NSMutableArray arrayWithArray:model.hostWord];
            self.testList = [NSMutableArray arrayWithArray:model.hotTests];
            [self.mainTableView reloadData];
            
        } failure:^(HttpException *e) {
            
        }];
    }];
}

@end
