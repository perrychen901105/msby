//
//  MyPharmacyViewController.m
//  wenyao
//
//  Created by Pan@QW on 14-9-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "MyPharmacyViewController.h"
#import "MyPharmacyTableViewCell.h"
#import "AddNewMedicineViewController.h"
//#import "TagCollectionViewController.h"
#import "Box.h"
#import "AppDelegate.h"
#import "Constant.h"
#import "SVProgressHUD.h"
#import "MGSwipeButton.h"
//#import "AlarmClockViewController.h"
#import "PopTagView.h"
#import "SubSearchPharmacyViewController.h"
#import "PharmacyDetailViewController.h"
#import "SearchViewController.h"
#import "UIImageView+WebCache.h"
#import "QueryMyBoxModel.h"
#import "FamilyMemberInfoViewController.h"
#import "AddMedcineViewController.h"

#import "LeveyPopListViewCUS.h"
#import "LeveyPopListView.h"
#import "CustomSheetView.h"
@interface MyPharmacyViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UITabBarControllerDelegate,MGSwipeTableCellDelegate,PopTagViewDelegate,UIAlertViewDelegate,LeveyPopListViewDelegate,LeveyPopListViewCUSDelegate>
{
    NSIndexPath             *firstIndexPath;
    NSString                *boid;
    CustomSheetView *customSheet;
    NSInteger biaoji;
    NSInteger delteMedcineId;
}

 
@property (nonatomic, strong) UISearchBar   *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDisplay;
@property (nonatomic, strong) PopTagView                *popTagView;
@property (nonatomic, strong) NSMutableArray            *filterMedicineList;
@property (nonatomic, strong) UIImageView               *hintImageView;
@property (nonatomic, strong) UILabel                   *hintLabel;
@property (nonatomic, assign) BOOL                      showSearchResult;
@property (nonatomic ,strong)NSArray  *periodList;

@end

@implementation MyPharmacyViewController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
     
    }
    return self;
}

- (void)setupTableView
{
//    CGRect rect = self.view.frame;
//    if (self.subType) {
//        rect.size.height -= 64;
//        self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
//    } else {
//        rect.size.height -= 108;
//        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width,rect.size.height) style:UITableViewStylePlain];
//    }
    
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.tableView setBackgroundColor:[UIColor clearColor]];
//    self.tableView.footer
//    [self.view addSubview:self.tableView];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
        [self.searchBar removeFromSuperview];
}

- (void)setupSearchBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(60, 0, self.view.bounds.size.width-2*60 , 40)];
    self.searchBar.barTintColor = RGBHex(qwColor1);
    
//    UITextField * textField = (UITextField *)[[self.searchBar subviews] objectAtIndex:0];
    self.searchBar.backgroundColor = [UIColor whiteColor];
    
    self.searchBar.placeholder = @"搜索用药";
    UITextField *m_searchField;
    if (iOSv7) {
        UIView* barView = [self.searchBar.subviews objectAtIndex:0];
        [[barView.subviews objectAtIndex:0] removeFromSuperview];
        UITextField* searchField = [barView.subviews objectAtIndex:0];
        searchField.font = [UIFont systemFontOfSize:13.0f];
        [searchField setReturnKeyType:UIReturnKeySearch];
        m_searchField = searchField;
    } else {
        [[self.searchBar.subviews objectAtIndex:0] removeFromSuperview];
        UITextField* searchField = [self.searchBar.subviews objectAtIndex:0];
        searchField.delegate = self;
        searchField.font = [UIFont systemFontOfSize:13.0f];
        [searchField setReturnKeyType:UIReturnKeySearch];
        m_searchField = searchField;
    }
    
    m_searchField.backgroundColor = RGBHex(0xf0f0f0);
    self.searchBar.delegate = self;
    [self.navigationController.navigationBar addSubview:self.searchBar];
    self.searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplay.searchBar.layer.masksToBounds = YES;
//    self.searchDisplay.searchBar.layer.borderWidth = 0.5;
//    self.searchDisplay.searchBar.layer.cornerRadius = 20.0f;
    self.searchDisplay.searchBar.layer.borderColor = RGBHex(qwColor10).CGColor;
    self.searchDisplay.searchResultsDataSource = self;
    self.searchDisplay.searchResultsDelegate = self;
    self.searchDisplay.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.showSearchResult = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.filterMedicineList removeAllObjects];
    for(NSDictionary *dict in self.myMedicineList)
    {
        NSRange range = [dict[@"productName"] rangeOfString:searchText];
        if(range.location != NSNotFound){
            [self.filterMedicineList addObject:dict];
        }
        
        
    }
    
    
    [self.searchDisplay.searchResultsTableView reloadData];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    self.showSearchResult = NO;
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    
    SubSearchPharmacyViewController *subSearchPharmacyViewController = [[UIStoryboard storyboardWithName:@"FamilyMedicineListViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SubSearchPharmacyViewController"];
//       SubSearchPharmacyViewController *subSearchPharmacyViewController = [[SubSearchPharmacyViewController alloc] init];
    subSearchPharmacyViewController.hidesBottomBarWhenPushed = YES;
    subSearchPharmacyViewController.memberId = self.familyMembersVo.memberId;
    subSearchPharmacyViewController.familyMembersVo = self.familyMembersVo;
    [self.navigationController pushViewController:subSearchPharmacyViewController animated:YES];
    return NO;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
     self.periodList = @[@"药效好",@"药效一般",@"药效差",@"删除标记" ];
    
    [self.view setBackgroundColor:RGBHex(qwColor11)];
    self.popTagView = [[[NSBundle mainBundle] loadNibNamed:@"PopTagView" owner:self options:nil] objectAtIndex:0];
    self.popTagView.delegate = self;
    [self setupTableView];
 
    self.hintImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-45, 180, 80, 82)];
    
     self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-90,280, 180, 25)];
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.textColor = RGBHex(qwColor8);
    self.hintLabel.font = [UIFont systemFontOfSize:15.0f];
     if(!self.subType) {
        [self.tableView addSubview:self.hintLabel];
        [self.tableView addSubview:self.hintImageView];
        
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePharmacy) name:PHARMACY_NEED_UPDATE object:nil];

    self.myMedicineList = [NSMutableArray arrayWithCapacity:15];
    self.filterMedicineList = [NSMutableArray arrayWithCapacity:15];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    lblTitle.font = [UIFont systemFontOfSize:18.0f];
    if (self.subType) {
       lblTitle.text = @"搜索结果";
//        self.subHeadView.hidden = YES;
        self.footerView.hidden = YES;
        [self.myHeaderView removeFromSuperview];
        self.tableView.tableHeaderView.frame = CGRectZero;
        
    }else
    {
        self.footerView.hidden = NO;
//        self.subHeadView.hidden = NO;
    lblTitle.text = @"我的用药";
    }
    [lblTitle setFont:font(kFont2, kFontS2)];//[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]
    lblTitle.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = lblTitle;

}
-(void)editMedcine:(id)sender
{
    
}
- (IBAction)pushIntoSearch:(id)sender
{
    SearchViewController *searchView = [[SearchViewController alloc]initWithNibName:@"SearchViewController" bundle:nil];
    searchView.isHideBranchList = YES;
    [self.navigationController pushViewController:searchView animated:YES];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PHARMACY_NEED_UPDATE object:nil];
}

- (void)updatePharmacy
{
    if (self.subType)
    {
        [self.tableView reloadData];
    } else {
        [self queryMyBox:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
-(void)netDate
{
    GetMemberInfoR *modelR = [GetMemberInfoR new];
    modelR.memberId = self.familyMembersVo.memberId;
    [FamilyMedicine getMemberInfo:modelR success:^(id member) {
        FamilyMemberDetailVo *modleF = (FamilyMemberDetailVo *)member;
        NSMutableArray *disArr = [NSMutableArray array];
        if (modleF.slowDiseases.count > 0) {
            for (SlowDiseaseVo *modelVo in modleF.slowDiseases) {
                [disArr addObject:modelVo.name];
            }
        }
        else {
            
        }
        
        self.familyMembersVo.sex = modleF.sex;
        self.familyMembersVo.age = modleF.age;
        self.familyMembersVo.slowDiseases = disArr;
        self.familyMembersVo.name = modleF.name ;
        self.familyMembersVo.allergy = modleF.allergy;
        self.familyMembersVo.pregnant = modleF.pregnancy;
        self.familyMembersVo.unit = modleF.unit;
        
        
        
        
        NSMutableString *slowDiseasesStr = [NSMutableString string];
        if (self.familyMembersVo.slowDiseases.count >0) {
            
            for (NSString *modelVo in self.familyMembersVo.slowDiseases) {
                [slowDiseasesStr appendFormat:@"、%@",modelVo];
                
            }
        }else
        {
            [slowDiseasesStr appendString:@""];
        }
        
        NSString *allergy = @"";
        if ([self.familyMembersVo.allergy isEqualToString:@"Y"]) {
            allergy = [NSString stringWithFormat:@"、有药物过敏史"];
        }else if ([self.familyMembersVo.allergy isEqualToString:@"N"])
        {
            
        }else
        {
            
        }
        NSString *pregnant = @"";
        if ([self.familyMembersVo.pregnant isEqualToString:@"Y"]) {
            pregnant = [NSString stringWithFormat:@"、孕妇"];
        }else if ([self.familyMembersVo.pregnant isEqualToString:@"N"])
        {
            
        }else
        {
            
        }
        
        NSString *age = [NSString stringWithFormat:@"、%@%@",self.familyMembersVo.age,self.familyMembersVo.unit];
        if ([self.familyMembersVo.age integerValue]==0) {
            age =@"";
            self.familyMembersVo.age = @"";
            self.familyMembersVo.unit = @"";
        }
        
        if (self.familyMembersVo) {
            if ([self.familyMembersVo.sex isEqualToString:@"F"]) {
                
                self.memberDetail.text = [NSString stringWithFormat:@"%@：女%@%@%@%@",self.familyMembersVo.name   ,age,slowDiseasesStr,pregnant,allergy];
                
            }else if ([self.familyMembersVo.sex isEqualToString:@"M"])
            {
                
                self.memberDetail.text = [NSString stringWithFormat:@"%@：男%@%@%@%@",self.familyMembersVo.name   ,age,slowDiseasesStr,pregnant,allergy];
                
            }else
            {
                NSString *complete = @"";
                if ([self.familyMembersVo.isComplete isEqualToString:@"N"]) {
                    complete = @"请完善资料";
                    
                    self.memberDetail.text = [NSString stringWithFormat:@"%@：%@",self.familyMembersVo.name  ,complete];
                    
                }else
                {
                    
                    self.memberDetail.text = [NSString stringWithFormat:@"%@：%@%@%@",self.familyMembersVo.name    ,self.familyMembersVo.age,self.familyMembersVo.unit,slowDiseasesStr];
                    
                }
            }
            
        }
        
    } failure:^(HttpException *e) {
        
    }];
    if(!self.subType)
    {
        [self setupSearchBar];
        self.searchBar.hidden = YES;
        if(self.myMedicineList.count > 0)
        {
            self.searchBar.hidden = NO;
            return;
        }
        [self queryMyBox:NO];
    }else{
        self.headerView.frame = CGRectMake(0, 0, 0, 0);
        [self queryMyBoxWithTagName:self.title];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if(!self.subType)
//    {
    
        //        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editMedcine:)];
        
//    }
    [self netDate];
}

- (void)queryMyBoxWithTagName:(NSString *)tagName
{
    if(self.myMedicineList.count != 0)
        return;
    
 
    SearchByTagR * moderR = [SearchByTagR new];
    moderR.memberId = self.memberId;
    moderR.tag = tagName;
    [FamilyMedicine searchByTag:moderR success:^(id array) {
        [self.myMedicineList removeAllObjects];
        for(QueryMyBoxModel *myboxModel in array)
        {
            if([myboxModel.drugTime integerValue] == -99) {
                myboxModel.drugTime = nil;
            }
            if([myboxModel.intervalDay integerValue] == -99) {
                myboxModel.intervalDay = nil;
            }
            if([myboxModel.accType integerValue] == -99) {
                myboxModel.accType = nil;
            }
            [self.myMedicineList addObject:myboxModel];
        }
        
        [self.tableView reloadData];
    } failure:NULL];
    
 

}

- (void)loadMyBoxMedicineCache
{
    NSArray *array = [QueryMyBoxModel getArrayFromDBWithWhere:nil];
//    if(array.count == 0)
//        return;
    [self.myMedicineList removeAllObjects];
    for(QueryMyBoxModel *myboxModel in array)
    {
        [self.myMedicineList addObject:myboxModel];
     //   if(myboxModel.useMethod && ![myboxModel.useMethod isEqualToString:@""] && myboxModel.perCount && ![myboxModel.perCount isEqualToString:@""] && myboxModel.unit && ![myboxModel.unit isEqualToString:@""] && myboxModel.useName && ![myboxModel.useName isEqualToString:@""])
        if(!StrIsEmpty(myboxModel.useMethod) && !StrIsEmpty(myboxModel.perCount) && !StrIsEmpty(myboxModel.unit) && !StrIsEmpty(myboxModel.useName))
        {
            
        }else{
            if(firstIndexPath == nil) {
                NSUInteger index = [array indexOfObject:myboxModel];
                firstIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
            }
        }
    }
    if(array.count == 0) {
        self.searchBar.hidden = YES;
        self.hintImageView.hidden = NO;
        self.hintImageView.image = [UIImage imageNamed:@"网络信号icon"];
        self.hintLabel.hidden = NO;
        self.hintLabel.text = kWarning12;
    }else{
        self.searchBar.hidden = NO;
        self.hintImageView.hidden = YES;
        self.hintLabel.hidden = YES;
    }
    [self.tableView reloadData];
    if(_shouldScrollToUncomplete)
    {
        [self performSelector:@selector(scrollToAssignIndexPath) withObject:nil afterDelay:0.8];
    }
    
}

- (void)cacheMyBoxMedicine:(NSArray *)array
{
    for(NSDictionary *dict in array)
    {
//        NSString *boxId = dict[@"boxId"];
        NSString *productName = @"";
        if(dict[@"productName"])
            productName = dict[@"productName"];
//        NSString *productId = dict[@"productId"];
        NSString *source = @"";
        if(dict[@"source"])
        {
            source = dict[@"source"];
        }
        NSString *useName = @"";
        if(dict[@"useName"])
        {
            useName = dict[@"useName"];
        }
        NSString *createtime = @"";
        if(dict[@"createtime"]) {
            createtime = dict[@"createtime"];
        }
        NSString *effect = @"";
        if(dict[@"effect"]) {
            effect = dict[@"effect"];
        }
        NSString *useMethod = @"";
        if(dict[@"useMethod"]){
            useMethod = dict[@"useMethod"];
        }
        NSString *perCount = @"";
        if(dict[@"perCount"]) {
            perCount = [NSString stringWithFormat:@"%@",dict[@"perCount"]];
        }
        NSString *unit = @"";
        if(dict[@"unit"]) {
            unit = dict[@"unit"];
        }
        
        NSString *intervalDay = @"";
        if(dict[@"intervalDay"]) {
            intervalDay = [NSString stringWithFormat:@"%@",dict[@"intervalDay"]];
        }
        NSString *drugTime = @"";
        if(dict[@"drugTime"]){
            drugTime = [NSString stringWithFormat:@"%@",dict[@"drugTime"]];
        }
        NSString *drugTag = @"";
        if(dict[@"drugTag"]) {
            drugTag = dict[@"drugTag"];
        }
        NSString *productEffect = @"";
        if(dict[@"productEffect"]) {
            productEffect = dict[@"productEffect"];
        }
    }
}

- (void)queryMyBox:(BOOL)force
{
    if(self.myMedicineList.count != 0 && !force)
    {
      
        return;
    }
    QueryMemberMedicinesR * model = [QueryMemberMedicinesR new];

    model.memberId = self.familyMembersVo.memberId;

    [FamilyMedicine queryMemberMedicines:model  success:^(id obj) {
        NSArray *array = (NSArray *)obj;
        if(array.count > 0)
        {
            [QueryMyBoxModel deleteAllObjFromDB];
            [QueryMyBoxModel saveObjToDBWithArray:array];
            self.hintLabel.hidden = YES;
            self.hintImageView.hidden = YES;
        }else{
            self.hintLabel.hidden = NO;
            self.hintImageView.hidden = NO;
            self.hintImageView.image = [UIImage imageNamed:@"ic_img_fail"];
            self.hintLabel.text = @"您还没有添加用药哦";
        }
        [self.myMedicineList removeAllObjects];
        
        for(QueryMyBoxModel *myboxModel in array)
        {
            if([myboxModel.drugTime integerValue] == -99) {
                myboxModel.drugTime = nil;
            }
   
            if([myboxModel.intervalDay integerValue] == -99 ||[myboxModel.intervalDay integerValue] == -1) {
                myboxModel.intervalDay = nil;
            }
            if([myboxModel.accType integerValue] == -99) {
                myboxModel.accType = nil;
            }
            [self.myMedicineList addObject:myboxModel];
          //  if(myboxModel.useMethod && ![myboxModel.useMethod isEqualToString:@""] && myboxModel.perCount && ![myboxModel.perCount isEqualToString:@""] && myboxModel.unit && ![myboxModel.unit isEqualToString:@""] && myboxModel.useName && ![myboxModel.useName isEqualToString:@""])
            if(!StrIsEmpty(myboxModel.useMethod) && !StrIsEmpty(myboxModel.perCount) && !StrIsEmpty(myboxModel.unit) && !StrIsEmpty(myboxModel.useName))
            {
                
                
            }else{
                if(firstIndexPath == nil) {
                    NSUInteger index = [array indexOfObject:myboxModel];
                    firstIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
                }
            }
        }
        if(array.count == 0) {
            self.searchBar.hidden = YES;
        }else{
            self.searchBar.hidden = NO;
        }
        [self.tableView reloadData];
        if(_shouldScrollToUncomplete)
        {
            [self performSelector:@selector(scrollToAssignIndexPath) withObject:nil afterDelay:0.8];
        }
    } failure:^(HttpException *e) {
     [self loadMyBoxMedicineCache];
    }];

}

- (void)scrollToAssignIndexPath
{
    [self.tableView scrollToRowAtIndexPath:firstIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    _shouldScrollToUncomplete = NO;
}



-(NSArray *) createRightButtons: (int) number
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@"删除"};
    UIColor * colors[2] = {RGBHex(qwColor2)};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            return YES;
        }];
        if(i == 1) {
            [button setTitleColor:RGBHex(qwColor5) forState:UIControlStateNormal];
        }
        [result addObject:button];
    }
    return result;
}


#pragma mark -
#pragma mark MGSwipeTableCellDelegate
-(NSArray*) swipeTableCell:(MGSwipeTableCell*)cell
  swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*)swipeSettings
         expansionSettings:(MGSwipeExpansionSettings*)expansionSettings;
{

    if (direction == MGSwipeDirectionRightToLeft)
    {
        BOOL showAlarm = NO;
        if(showAlarm) {
            return [self createRightButtons:2];
        }else{
            return [self createRightButtons:1];
        }
    }
    return nil;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{   QueryMyBoxModel *boxModel = nil;
       boxModel =   [self.myMedicineList objectAtIndex:alertView.tag];
    if (buttonIndex == 1) {
        
     
            //删除事件
            if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
                
                [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
                
                return ;
            }
  
            [self.myMedicineList removeObject:boxModel];
            [self.filterMedicineList removeObject:boxModel];
            [self.tableView reloadData];
            if(delteMedcineId >= 2000)
            {
                //            NSMutableDictionary *setting = [NSMutableDictionary dictionary];
                DeleteBoxProductR *deleteBoxProductR = [DeleteBoxProductR new];
                deleteBoxProductR.token = QWGLOBALMANAGER.configure.userToken;
                deleteBoxProductR.boxId = boxModel.boxId;
                [QueryMyBoxModel deleteObjFromDBWithKey:boxModel.boxId];
                //            [Box DeleteBoxProductWithParams:deleteBoxProductR success:NULL failure:NULL];
                
                DeleteMemberMedicineR *deleteMemberMedicineR = [DeleteMemberMedicineR new];
                deleteMemberMedicineR.boId =boxModel.boxId;
                [FamilyMedicine deleteMemberMedicine:deleteMemberMedicineR success:^(id obj) {
                    
                } failure:^(HttpException *e) {
                    
                }];
                
                NSArray *notificationList = [[UIApplication sharedApplication] scheduledLocalNotifications];
                [notificationList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    UILocalNotification *localNotification = (UILocalNotification *)obj;
                    NSDictionary *userInfo = [localNotification userInfo];
                    if([userInfo[@"boxId"] isEqualToString:boxModel.boxId])
                    {
                        [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
                    }
                }];
                if(self.myMedicineList.count == 0) {
                    //                self.tableView.tableHeaderView = nil;
                    self.searchBar.hidden = YES;
                    self.hintLabel.hidden = NO;
                    self.hintImageView.hidden = NO;
                    self.hintImageView.image = [UIImage imageNamed:@"ic_img_fail"];
                    self.hintLabel.text = @"您还没有添加用药哦";
                }
                if (self.subType) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:PHARMACY_NEED_UPDATE object:nil];
                } else {
                    
                }
            }else{
                
                     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.myMedicineList indexOfObject:boxModel] inSection:0];
                [self.searchDisplay.searchResultsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView reloadData];
            }
      
    
    }
    
}
-(BOOL) swipeTableCell:(MGSwipeTableCell*)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    
    
    
    NSIndexPath *indexPath = nil;
 
    if(cell.tag >= 2000)
    {
        indexPath = [self.tableView indexPathForCell:cell];
   
    }else{
        indexPath = [self.searchDisplay.searchResultsTableView indexPathForCell:cell];
     }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否删除该用药" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.delegate = self;
    alertView.tag = indexPath.row;
    [alertView show];
    delteMedcineId = cell.tag;
    return YES;
}

#pragma mark -
#pragma mark UITableViewDelegate
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 120.0f;
//}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return self.myMedicineList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyPharmacyIdentifier = @"MyPharmacyIdentifier";
    MyPharmacyTableViewCell *cell = (MyPharmacyTableViewCell *)[atableView dequeueReusableCellWithIdentifier:MyPharmacyIdentifier];
    if (self.subType) {
        cell.biaoji.hidden = YES;
    } else
    {
        cell.biaoji.hidden = NO;
    }
    [cell.biaoji addTarget:self action:@selector(markMedcine:) forControlEvents:UIControlEventTouchUpInside];
    cell.biaoji.tag = indexPath.row;
        cell.selectedBackgroundView = [[UIView alloc]init];
        cell.selectedBackgroundView.backgroundColor = RGBHex(qwColor10);
    
    QueryMyBoxModel *boxModel = nil;
  
    boxModel = self.myMedicineList[indexPath.row];
    
    cell.tag = indexPath.row + 2000;
      boxModel.useName = self.familyMembersVo.name;

    [cell setCell:boxModel];
    cell.alarmClockImage.tag = indexPath.row;
    [self layoutTableView:atableView withTableViewCell:cell WithTag:boxModel];
 
//    [cell.avatar setImageURL:PORID_IMAGE(boxModel.proId)];
    cell.swipeDelegate = self;
    return cell;
}
-(void)markMedcine:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    QueryMyBoxModel *boxModel = nil;
    boxModel = self.myMedicineList[btn.tag];
   // if(boxModel.effect && ![boxModel.effect isEqualToString:@""])
    if (!StrIsEmpty(boxModel.effect))
    {
        biaoji = -1;
    }else
    {
        biaoji = 3;
    }
    boid = boxModel.boxId;
    LeveyPopListViewCUS *vv = [[LeveyPopListViewCUS alloc] initWithTitle:@"请选择用法" options:self.periodList];
    vv.delegate = self;
    vv.tag = 3;
     vv.selectedIndex =biaoji;
    [vv setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:kShadowAlpha]];
    [vv showInView:self.view animated:YES];

}


#pragma mark - UIAlertViewDelegate
- (void)leveyPopListViewCUS:(LeveyPopListViewCUS *)popListView didSelectedIndex:(NSInteger)anIndex {
    if (popListView.tag == 3) {
        
        UpdateTagR *updateTag  = [UpdateTagR new];
        
        updateTag.boxId = boid;
        if ([self.periodList[anIndex] isEqualToString:@"删除标记"]) {
            updateTag.tag =@"";
        }else
        {
        updateTag.tag = self.periodList[anIndex];
        }
        [FamilyMedicine updateTag:updateTag success:^(id obj) {
                     [[NSNotificationCenter defaultCenter] postNotificationName:PHARMACY_NEED_UPDATE object:nil];
        } failure:^(HttpException *e) {
            
        }];
    }

 
}

- (void)leveyPopListViewCUSDidCancel
{
    
 
}

- (void)UIGlobal{
    //    [super UIGlobal];
}


- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    QueryMyBoxModel *myBoxModel = self.myMedicineList[indexPath.row];
    
//    if(myBoxModel.useName && ![myBoxModel.useName isEqualToString:@""])
//    {
    
            PharmacyDetailViewController *pharmacyDetailViewController = [[UIStoryboard storyboardWithName:@"FamilyMedicineListViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PharmacyDetailViewController"];
    pharmacyDetailViewController.memberId = self.familyMembersVo.memberId;
        pharmacyDetailViewController.boxModel = myBoxModel;
        pharmacyDetailViewController.changeMedicineInformation = ^(QueryMyBoxModel *boxModel)
        {
            [self.myMedicineList replaceObjectAtIndex:indexPath.row withObject:boxModel];
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:pharmacyDetailViewController animated:YES];

//    }else{
//        __weak __typeof(self) weakSelf = self;
//    AddNewMedicineViewController *addNewMedicineViewController = [[UIStoryboard storyboardWithName:@"FamilyMedicineListViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"AddNewMedicineViewController"];
//        addNewMedicineViewController.editMode = 1;
//        addNewMedicineViewController.boxModelDidChange = ^(QueryMyBoxModel *myBoxModel) {
//            [self.myMedicineList replaceObjectAtIndex:indexPath.row withObject:myBoxModel];
//            [weakSelf.tableView reloadData];
//        };
//        addNewMedicineViewController.queryMyBoxModel =  myBoxModel ;
//        [self.navigationController pushViewController:addNewMedicineViewController animated:YES];
//        return;
//    }
//    MedicineDetailViewController *medicineDetailViewControler = [[MedicineDetailViewController alloc] initWithNibName:@"MedicineDetailViewController" bundle:nil];
//    medicineDetailViewControler.proId = dict[@"productId"];
//    medicineDetailViewControler.showRightBarButton = YES;
//    [self.navigationController pushViewController:medicineDetailViewControler animated:YES];
}

- (UIButton *)createTagButtonWithTitle:(NSString *)title WithIndex:(NSUInteger)index tagType:(TagType)tagType withOffset:(CGFloat)offset
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:RGBHex(qwColor3) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:11.0];
    UIImage *resizeImage = nil;
    if([title isEqualToString:self.title]) {
        resizeImage = [UIImage imageNamed:@"btn_bg_tag"];
        [button setTitleColor:RGBHex(qwColor1) forState:UIControlStateNormal];
        resizeImage = [resizeImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    }else{
        resizeImage = [UIImage imageNamed:@"btn_bg_tag"];
        //        DDLogVerbose(@"%@",NSStringFromCGSize(resizeImage.size));
        resizeImage = [resizeImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10,10, 10) resizingMode:UIImageResizingModeStretch];
    }
    CGSize size = [title sizeWithFont:button.titleLabel.font constrainedToSize:CGSizeMake(300, 20)];
    button.frame = CGRectMake(offset, 67, size.width + 2 * 10, 20);
    button.tag = index * 1000 + tagType;
    [button setBackgroundImage:resizeImage forState:UIControlStateNormal];
     button.enabled = NO;
    return button;
}

- (void)layoutTableView:(UITableView *)atableView withTableViewCell:(UITableViewCell *)cell WithTag:(QueryMyBoxModel *)tagsDict
{
    for(UIView *button in cell.contentView.subviews) {
        if(button.frame.origin.y == 67.0)
            [button removeFromSuperview];
    }
    CGFloat offset = 84;
    UIButton *button = nil;
    NSUInteger index = 0;

    index = [self.myMedicineList indexOfObject:tagsDict];

    //if(tagsDict.drugTag && ![tagsDict.drugTag isEqualToString:@""])
    if(!StrIsEmpty(tagsDict.drugTag))
    {
        NSString *strDrugTag = tagsDict.drugTag;
        DDLogVerbose(@"the drug tag is %@",strDrugTag);
        if (strDrugTag.length > 6) {
            strDrugTag = [strDrugTag substringToIndex:6];
        }

        button = [self createTagButtonWithTitle:strDrugTag WithIndex:index tagType:DrugTag withOffset:offset];
        [cell.contentView addSubview:button];
        offset += button.frame.size.width + 5;
        if(![atableView isEqual:self.tableView]) {
            button.tag *= -1;
        }
    }
//    if(tagsDict.useName && ![tagsDict.useName isEqualToString:@""])
//    {
//        NSString *strUseName = tagsDict.useName;
//        if (strUseName.length > 3) {
//            strUseName = [strUseName substringToIndex:3];
//        }
//
//        button = [self createTagButtonWithTitle:strUseName WithIndex:index tagType:UseNameTag withOffset:offset];
//        //[button addTarget:self action:@selector(pushIntoFilterViewController:) forControlEvents:UIControlEventTouchDown];
//        [cell.contentView addSubview:button];
//        if(![atableView isEqual:self.tableView]) {
//            button.tag *= -1;
//        }
//        offset += button.frame.size.width + 5;
//    }
    //if(tagsDict.effect && ![tagsDict.effect isEqualToString:@""])
    if(!StrIsEmpty(tagsDict.effect))
    {
        NSString *strEffect = tagsDict.effect;
        if (strEffect.length > 4) {
            strEffect = [strEffect substringToIndex:4];
        }
        button = [self createTagButtonWithTitle:strEffect WithIndex:index tagType:EffectTag withOffset:offset];
        [cell.contentView addSubview:button];
        if(![atableView isEqual:self.tableView]) {
            button.tag *= -1;
        }
        offset += button.frame.size.width + 5;
    }

    if(self.subType)
        return;
//    button = [self createTagButtonWithTitle:@"添加标签" WithIndex:index tagType:AddTag withOffset:offset];
    if(![atableView isEqual:self.tableView])
    {
        button.tag *= -1;
    }
//    [button addTarget:self action:@selector(showTagDetail:) forControlEvents:UIControlEventTouchDown];
   
    [cell.contentView addSubview:button];
}

//- (void)pushIntoFilterViewController:(UIButton *)sender
//{
//    TagType tagType = sender.tag % 1000;
//    NSUInteger index = sender.tag  / 1000;
//    NSDictionary *dict = self.myMedicineList[index];
//    NSString *tagName = nil;
//    NSString *keyName = nil;
//    switch (tagType) {
//        case DrugTag:{
//            tagName = dict[@"drugTag"];
//            keyName = @"drugTag";
//            break;
//        }
//        case UseNameTag:{
//            tagName = dict[@"drugTag"];
//            keyName = @"drugTag";
//            break;
//        }
//        case EffectTag:{
//            tagName = dict[@"useName"];
//            keyName = @"useName";
//            break;
//        }
//        default:
//            break;
//    }
//    NSMutableArray *convertArray = nil;
//    if(sender.tag > 0){
//        //表视图搜索
//        convertArray = self.myMedicineList;
//    }else{
//        //结果视图搜索
//        convertArray = self.filterMedicineList;
//    }
//    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:10];
//    for(NSDictionary *dict in convertArray)
//    {
//        NSString *tagValue = dict[keyName];
//        if(tagValue && [tagValue isEqualToString:tagName]) {
//            [resultArray addObject:dict];
//        }
//    }
//    MyPharmacyViewController *myPharmacyViewController = [[MyPharmacyViewController alloc] init];
//    myPharmacyViewController.myMedicineList = resultArray;
//    myPharmacyViewController.subType = YES;
//    [self.navigationController pushViewController:myPharmacyViewController animated:YES];
//    myPharmacyViewController.title = tagName;
//}

- (void)showTagDetail:(UIButton *)sender
{
    if(QWGLOBALMANAGER.currentNetWork == kNotReachable)
    {
        [SVProgressHUD showErrorWithStatus:kWarning12 duration:0.8f];
        return;
    }
    NSUInteger index = sender.tag / 1000;
    QueryMyBoxModel *boxModel = self.myMedicineList[index];
    NSMutableArray *tagsArray = [NSMutableArray arrayWithCapacity:15];
    //if(boxModel.drugTag && ![boxModel.drugTag isEqualToString:@""])
    if(!StrIsEmpty(boxModel.drugTag))
    {
        NSMutableDictionary *subDict = [@{@"drugTitle":@"主治",
                                  @"drugName":boxModel.drugTag} mutableCopy];
        [tagsArray addObject:subDict];
    }
    //if(boxModel.useName && ![boxModel.useName isEqualToString:@""])
    if(!StrIsEmpty(boxModel.useName))
    {
        NSMutableDictionary *subDict = [@{@"drugTitle":@"使用者",
                                  @"drugName":boxModel.useName} mutableCopy];
        [tagsArray addObject:subDict];
    }
    //if(boxModel.effect && ![boxModel.effect isEqualToString:@""])
    if(!StrIsEmpty(boxModel.effect))
    {
        NSMutableDictionary *subDict = [@{@"drugTitle":@"药效",
                                  @"drugName":boxModel.effect} mutableCopy];
        [tagsArray addObject:subDict];
    }else{
        NSMutableDictionary *subDict = [@{@"drugTitle":@"药效",
                                  @"drugName":@""} mutableCopy];
        [tagsArray addObject:subDict];
    }
    [self.popTagView setExistTagList:tagsArray];
    self.popTagView.tag = index;
    [self.popTagView showInView:self.view animated:YES];
}

#pragma mark -
#pragma mark PopTagViewDelegate
- (void)popTagDidSelectedIndexPath:(NSIndexPath *)indexPath
                        newTagName:(NSString *)tagName
{
    __block QueryMyBoxModel *boxModel = self.myMedicineList[indexPath.row];
    boxModel.effect = tagName;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    UpdateBoxProductTagR *updateBoxProductTagR = [UpdateBoxProductTagR new];
    updateBoxProductTagR.token = QWGLOBALMANAGER.configure.userToken;
    updateBoxProductTagR.boxId = boxModel.boxId;
    updateBoxProductTagR.tag = tagName;
    
    [Box UpdateBoxProductTagWithParams:updateBoxProductTagR success:NULL failure:NULL];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}


- (IBAction)addMedcine:(id)sender {
    if(QWGLOBALMANAGER.currentNetWork == kNotReachable){
        [self showError:kWarning12];
        return;
    }

    AddNewMedicineViewController *addFamMemViewController = [[UIStoryboard storyboardWithName:@"FamilyMedicineListViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"AddNewMedicineViewController"];
    addFamMemViewController.familyMembersVo = self.familyMembersVo;
 
    addFamMemViewController.InsertNewPharmacy = ^(QueryMyBoxModel *myboxModel)
    {
        self.hintLabel.hidden = YES;
        self.hintImageView.hidden = YES;
        self.searchBar.hidden = NO;
        //        myboxModel.imgUrl =
//        [self.myMedicineList insertObject:myboxModel atIndex:0];
        
              [self queryMyBox:YES];
//        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:addFamMemViewController animated:YES];
}
- (IBAction)editMemberInfo:(id)sender {
    
    FamilyMemberInfoViewController *vcInfo = [[UIStoryboard storyboardWithName:@"ConsultForFree" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FamilyMemberInfoViewController"];
    
     vcInfo.strMemID =self.familyMembersVo.memberId;
//    if ([self.familyMembersVo.isComplete isEqualToString:@"Y"]) {
        vcInfo.isFromConsultDoctor = NO;
//    } else {
//        vcInfo.isNeedCompleteInfo = YES;
//    }
    vcInfo.enumTypeEdit = MemberViewTypeEdit;
    [self.navigationController pushViewController:vcInfo animated:YES];

}
-(void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj
{
    if (type == NotifUpdateMyPh) {
             [self queryMyBox:YES];
    }
}
@end
