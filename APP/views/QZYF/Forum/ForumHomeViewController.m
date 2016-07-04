//
//  ForumHomeViewController.m
//  APP
//
//  Created by Martin.Liu on 15/12/29.
//  Copyright © 2015年 carret. All rights reserved.
//

#import "ForumHomeViewController.h"
#import "ConstraintsUtility.h"
#import "HotPostViewController.h"           // 热议页面
#import "CarePharmacistViewController.h"    // 专家页面

@interface ForumHomeViewController ()
@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segment;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraint_underLineCenterX;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIView *containerView1;
@property (strong, nonatomic) IBOutlet UIView *containerView2;

@property (nonatomic, strong) UIScrollView* hotScollView;
@property (nonatomic, strong) UIScrollView* expertScrollView;
@property (nonatomic, strong) UIScrollView* currentScrollView;
// 热议按钮行为
- (IBAction)hotPostBtnAction:(id)sender;
// 药师按钮行为
- (IBAction)pharmacistBtnAction:(id)sender;

@end

@implementation ForumHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.scrollView addObserver:self  forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (UISegmentedControl *)segment
{
    if (!_segment) {
        _segment = [[UISegmentedControl alloc]initWithItems:@[@"热议", @"专家"]];
        _segment.frame = CGRectMake(0, 0, 150, 30);
        _segment.tintColor = RGBHex(qwColor1);
        _segment.backgroundColor = RGBHex(qwColor10);
        NSShadow *shadow = [[NSShadow alloc]init];
        shadow.shadowBlurRadius = 1;
        shadow.shadowColor = [UIColor clearColor];
        shadow.shadowOffset = CGSizeMake(1, 1);
        NSDictionary *dicSelected = [NSDictionary dictionaryWithObjectsAndKeys:RGBHex(qwColor4),NSForegroundColorAttributeName,  fontSystem(13.0f),NSFontAttributeName ,shadow,NSShadowAttributeName ,@(0),NSVerticalGlyphFormAttributeName,nil];
        [_segment setTitleTextAttributes:dicSelected forState:UIControlStateSelected];
        
        
        NSDictionary *dicNormal = [NSDictionary dictionaryWithObjectsAndKeys:RGBHex(qwColor7),NSForegroundColorAttributeName,  fontSystem(13.0f),NSFontAttributeName ,shadow,NSShadowAttributeName ,@(0),NSVerticalGlyphFormAttributeName,nil];
        [_segment setTitleTextAttributes:dicNormal forState:UIControlStateNormal];
        
        [_segment addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
        _segment.selectedSegmentIndex = 0;
//        self.navigationItem.titleView = _segment;
    }
    return _segment;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.currentScrollView == self.hotScollView) {
        [QWGLOBALMANAGER statisticsEventId:@"x_qz_rycx" withLable:@"圈子-首页（热议）出现" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl)}]];
    }
    
//    [QWGLOBALMANAGER statisticsEventId:@"x_sy_qz" withLable:@"首页-圈子" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl)}]];
}

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self.scrollView && [keyPath isEqualToString:@"contentOffset"]) {
        CGPoint point = [change[@"new"] CGPointValue];
        float p = point.x / self.scrollView.bounds.size.width;
        self.constraint_underLineCenterX.constant = p*CGRectGetWidth(self.navigationItem.titleView.frame)/2;
        if (p < 0.5) {
            self.currentScrollView = self.hotScollView;
            if (self.scrollView.isDragging || self.scrollView.isDecelerating) {
                self.segment.selectedSegmentIndex = 0;
            }
        }
        else
        {
            self.currentScrollView = self.expertScrollView;
            if (self.scrollView.isDragging || self.scrollView.isDecelerating) {
                self.segment.selectedSegmentIndex = 1;
            }
        }
    }
}

- (void)clickStatusBar
{
    [self.currentScrollView setContentOffset:CGPointZero animated:YES];
}

- (void)UIGlobal
{
    self.navigationItem.titleView = self.segment;
    HotPostViewController* hotPostVC = [[UIStoryboard storyboardWithName:@"Forum" bundle:nil] instantiateViewControllerWithIdentifier:@"HotPostViewController"];
    [self addChildViewController:hotPostVC];
    [self.containerView1 addSubview:hotPostVC.view];
    
    CarePharmacistViewController* carePharmacisVC = [[UIStoryboard storyboardWithName:@"Forum" bundle:nil] instantiateViewControllerWithIdentifier:@"CarePharmacistViewController"];
    [self addChildViewController:carePharmacisVC];
    [self.containerView2 addSubview:carePharmacisVC.view];
    
    PREPCONSTRAINTS(hotPostVC.view);
    ALIGN_TOPLEFT(hotPostVC.view, 0);
    ALIGN_BOTTOMRIGHT(hotPostVC.view, 0);
    
    PREPCONSTRAINTS(carePharmacisVC.view);
    ALIGN_TOPLEFT(carePharmacisVC.view, 0);
    ALIGN_BOTTOMRIGHT(carePharmacisVC.view, 0);
    self.hotScollView = hotPostVC.tableView;
    self.expertScrollView = carePharmacisVC.collectionView;
    self.currentScrollView = self.hotScollView;
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

- (void)segmentChanged:(UISegmentedControl*)segmentControl
{
    switch (segmentControl.selectedSegmentIndex) {
        case 0:
        {
            [QWGLOBALMANAGER statisticsEventId:@"x_qz_ry" withLable:@"圈子-热议" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl)}]];
            [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentOffset.y) animated:YES];

        }
            break;
        case 1:
        {
            [QWGLOBALMANAGER statisticsEventId:@"x_qz_zj" withLable:@"圈子-专家" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl)}]];
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, self.scrollView.contentOffset.y) animated:YES];
        }
            break;
        default:
            break;
    }
}

- (IBAction)hotPostBtnAction:(id)sender {
    [QWGLOBALMANAGER statisticsEventId:@"x_qz_ry" withLable:@"圈子-热议" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl)}]];
    [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentOffset.y) animated:YES];
}

- (IBAction)pharmacistBtnAction:(id)sender {
    [QWGLOBALMANAGER statisticsEventId:@"x_qz_zj" withLable:@"圈子-专家" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl)}]];
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, self.scrollView.contentOffset.y) animated:YES];
}

- (void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj
{
    if (type == NotifGotoCareExpertFromCredit) {
        if (self.currentScrollView && self.currentScrollView != self.expertScrollView) {
            self.currentScrollView = self.expertScrollView;
            [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.frame), 0) animated:NO];
        }
    }
}
@end