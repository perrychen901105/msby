//
//  AddNewMedicineViewController.m
//  wenyao
//
//  Created by Pan@QW on 14-9-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "AddNewMedicineViewController.h"
#import "Box.h"
#import "ScanReaderViewController.h"
#import "LeveyPopListViewNew.h"
#import "SearchMedicineViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"
#import "MyPharmacyViewController.h"
#import "Drug.h"
#import "NSObject+SBJson.h"
#import "QueryMyBoxModel.h"
#import "QYPhotoAlbum.h"

#import "FamilyMedicine.h"
#import "FamilyMedicineCell.h"
#import "FamilyMedicineModel.h"

#import "LeveyPopModel.h"

#import "LeveyPopListViewCUS.h"
@interface AddNewMedicineViewController ()<UITableViewDataSource,
UITableViewDelegate,UIActionSheetDelegate,LeveyPopListViewDelegate,
UITextFieldDelegate,UIAlertViewDelegate,ZHPickViewDelegate,UITextFieldDelegate,LeveyPopListViewCUSDelegate>
{
    AddMemberMedicineR *rmodel;
    NSArray *_nameArray;
    NSArray *_yongliang;
    NSMutableDictionary *unitDic;
     CompleteMemberMedicineR *completeMemberMedicineR;
    NSString *useName;
    BOOL  hasQueryUser;
}
//@property (nonatomic, strong) NSArray           *usageList;
@property (nonatomic, strong) NSArray           *unitList;
@property (nonatomic, strong) NSArray           *periodList;
@property (nonatomic, strong) NSMutableArray    *useNameList;
@property (nonatomic, strong) NSArray           *frequencyList;
@property (nonatomic, strong) UITextField       *alertViewTextField;

@end

@implementation AddNewMedicineViewController
@synthesize alertViewTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}
- (void)setupTableView
{
    CGRect rect = [UIScreen mainScreen].bounds;
    rect.origin.x = 10;
    rect.size.width = 300.0f;
    
    rect.size.height -= 74.0f;
    
//    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
//    [self.view addSubview:self.tableView];
}

- (void)UIGlobal{
    [super UIGlobal];
//    [self naviRightBotton:@"保存" action:@selector(saveAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveAction:)];
    
}
 
- (void)viewDidLoad
{
    [super viewDidLoad];
       rmodel = [AddMemberMedicineR new];
    rmodel.useMethod = @"口服";
       completeMemberMedicineR = [CompleteMemberMedicineR new];
//   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];
    [self setupTableView];
    self.tableView.tableFooterView = self.footerView;
    _nameArray = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",nil];
    _yongliang= [NSArray arrayWithObjects:@"g",@"ml",@"m",@"k",nil];
    NSArray *pickerOne = [[NSBundle mainBundle] loadNibNamed:@"ZHPickView" owner:self options:nil];
    self.yongliangPicker = [pickerOne objectAtIndex: 0];;
    NSArray *pickerTwo = [[NSBundle mainBundle] loadNibNamed:@"ZHPickView" owner:self options:nil];
    _yongfaPicker = [pickerTwo objectAtIndex: 0];;
    unitDic = [NSMutableDictionary dictionary];
    self.toAddMember = NO;
  _yongliangPicker.showed =NO;
     _yongfaPicker.showed =NO;
    _yongliangPicker.delegate = self;
    _yongfaPicker.delegate = self;
    _yongliangPicker.titleOne.text = @"重复";
    _yongliangPicker.titleTwo.text = @"次数";
    _yongfaPicker.pickerTag = 1;
    _yongliangPicker.pickerTag = 2;
    
    _yongfaPicker.titleOne.text = @"用量";
    _yongfaPicker.titleTwo.text = @"单位";
    _yongfaPicker.frame= CGRectMake(_yongfaPicker.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width ,249) ;
     _yongliangPicker.frame= CGRectMake(_yongliangPicker.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width ,249) ;
 
 //    self.usageList = @[@"口服",@"外用",@"其他"];
    self.unitList = @[@"粒",@"袋",@"包",@"瓶",@"克",@"毫克",@"毫升",@"片",@"支",@"滴",@"枚",@"块",@"盒",@"喷"];
    NSMutableArray *arrCount = [NSMutableArray array];
    for (int i = 1; i<10000; i++) {
        [arrCount addObject:[NSString stringWithFormat:@"%d",i]];
    }
    self.lineT.constant = 0.5;
    self.lineO.constant = 0.5;
     NSArray *yongliangArr = [NSArray arrayWithObjects:arrCount,self.unitList, nil];
      [_yongfaPicker initPickviewWithArray:yongliangArr];

    self.useNameList = [NSMutableArray array];

   
//
    NSArray *unitDays =@[@"1",@"2",@"3",@"4",@"5",@"6",@"7"];
    self.periodList = @[@"每日",@"每2日",@"每3日",@"每4日",@"每5日",@"每6日",@"每7日"];
    unitDic  = [[NSMutableDictionary alloc]initWithObjects:unitDays forKeys:self.periodList];
    self.frequencyList = @[@"1",@"2",@"3",@"4",@"5"];
    NSArray *arr = [NSArray arrayWithObjects:self.periodList,self.frequencyList, nil];
    
    [_yongliangPicker initPickviewWithArray:arr];
    if (self.editMode == 2) {
        self.title = @"编辑用药";
        self.checkMedcine.hidden = YES;
        self.chooseUser.hidden = YES;
        self.userLabel.text = self.queryMyBoxModel.useName;
        self.userLabel.textColor = RGBHex(qwColor8);
        self.medicinelabel.textColor = RGBHex(qwColor8);
        self.medicinelabel.text = self.queryMyBoxModel.productName;
        self.medcineView.backgroundColor = RGBHex(qwColor11);
        self.userViw.backgroundColor = RGBHex(qwColor11);
        self.irrowRightImg.hidden = YES;
        [self fillupDrug];
        [self adjustUseageDetailLabel];
    }
   else if(self.editMode == 1)
    {
        
//        self.infoDict = [NSMutableDictionary dictionaryWithDictionary:[QueryMyBoxModel dataTOdic:self.queryMyBoxModel]];
//        if(self.queryMyBoxModel.source && [self.queryMyBoxModel.source isEqualToString:@""]) {
//            [self.infoDict removeObjectForKey:@"source"];
//        }
        [self obtainDataSource];
        self.title = @"完善用药";
        [self fillupDrug];
        [self adjustUseageDetailLabel];
        self.medcineTextLeadingR.constant = 15;
        //////////////////事先判断/////////////////////
        self.checkMedcine.hidden = YES;
        self.medicinelabel.text = self.queryMyBoxModel.productName;
//        self.medicinelabel.enabled = NO;
        self.userLabel.text = @"选择使用者";
      
          self.medicinelabel.textColor = RGBHex(qwColor8);
        self.medcineView.backgroundColor = RGBHex(qwColor11);
    }else{
         self.userViw.backgroundColor = RGBHex(qwColor11);
        self.title = @"添加用药";
           self.userLabel.textColor = RGBHex(qwColor8);
        self.queryMyBoxModel = [QueryMyBoxModel new];
        self.chooseUser.hidden = YES;
        self.irrowRightImg.hidden = YES;
        self.userLabel.text = self.familyMembersVo.name;
//        self.medicinelabel.text = @"请添加用药";
     }

    [self.koufu setBackgroundImage:[UIImage imageNamed:@"btn_tag_normal"] forState:UIControlStateNormal];
    [self.koufu setBackgroundImage:[UIImage imageNamed:@"btn_tag_selected_blue"] forState:UIControlStateSelected];
    
    [self.waiyong setBackgroundImage:[UIImage imageNamed:@"btn_tag_normal"] forState:UIControlStateNormal];
    [self.waiyong setBackgroundImage:[UIImage imageNamed:@"btn_tag_selected_blue"] forState:UIControlStateSelected];
    [self.qita setBackgroundImage:[UIImage imageNamed:@"btn_tag_normal"] forState:UIControlStateNormal];
    [self.qita setBackgroundImage:[UIImage imageNamed:@"btn_tag_selected_blue"] forState:UIControlStateSelected];
    
    [self.view addSubview:self.yongfaPicker];
    [self.view addSubview:self.yongliangPicker];
    
    if ([self.queryMyBoxModel.useMethod isEqualToString:@"外用"]) {
        self.waiyong.selected = YES;
         rmodel.useMethod = @"外用";
    }else if ([self.queryMyBoxModel.useMethod isEqualToString:@"其他"])
    {
         rmodel.useMethod = @"其他";
         self.qita.selected = YES;
    }
    else
    {
         rmodel.useMethod = @"口服";
         self.koufu.selected = YES;
    }
    [self queryMemberInfo];
}

-(void)queryMemberInfo
{
    QueryFamilyMembersR *queryFamilyMembersR = [QueryFamilyMembersR new];
    queryFamilyMembersR.token = QWGLOBALMANAGER.configure.userToken;
 
    hasQueryUser = YES;
    [FamilyMedicine queryFamilyMembers:queryFamilyMembersR success:^(QueryFamilyMembersModel *modle ) {
   [LeveyPopModel deleteAllObjFromDB];
        for ( FamilyMembersVo *familyMembersVo in modle.list) {
            LeveyPopModel *popModel = [LeveyPopModel new];
 
            popModel.title = familyMembersVo.name;
            popModel.selected = NO;
            popModel.memberId = familyMembersVo.memberId;
              hasQueryUser = NO;
             if (![self filterUser:popModel]) {
                   [self.useNameList insertObject:popModel atIndex:[modle.list indexOfObject:familyMembersVo]];
            }
         }
        
//        
        [LeveyPopModel insertToDBWithArray:self.useNameList filter:^(id model, BOOL inseted, BOOL *rollback) {
            
        }];
        
//        if (self.toAddMember) {
        dispatch_async(dispatch_get_main_queue(), ^{
                  [[NSNotificationCenter defaultCenter] postNotificationName:UPDATEUSER object:nil];
        });


//        }
        
    } failure:^(HttpException *e) {
        
    }];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
}

-(BOOL)filterUser:(LeveyPopModel *)mod;
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"memberId == %@",mod.memberId];
     NSArray *array = [self.useNameList filteredArrayUsingPredicate:predicate];
    if (array.count >0) {
        return YES;
    }
    return NO;
}
- (void)obtainDataSource
{
    if(!self.queryMyBoxModel.proId){
        return;
    }
    
    DrugDetailModelR *modelR=[DrugDetailModelR new];
    modelR.proId=self.queryMyBoxModel.proId;
    [Drug queryProductDetailWithParam:modelR Success:^(id DFModel) {
        DebugLog(@"%@",DFModel);
    } failure:^(HttpException *e) {
        DebugLog(@"%@",e.Edescription);
    }];
}


- (void)fillupDrug
{
    if([self.queryMyBoxModel.drugTime integerValue] == -99) {
        self.queryMyBoxModel.drugTime = @"";
    }
    
    if(self.queryMyBoxModel.useMethod){}
        if(self.queryMyBoxModel.unit){}
     
    
    rmodel.intervalDay = self.queryMyBoxModel.intervalDay;
    rmodel.unit = self.queryMyBoxModel.unit;
    rmodel.drugTime = self.queryMyBoxModel.drugTime;
//    if(self.queryMyBoxModel.useMethod && ![self.queryMyBoxModel.useMethod isEqualToString:@""]){
//        rmodel.useMethod = self.queryMyBoxModel.useMethod;
//    }
    if (!StrIsEmpty(self.queryMyBoxModel.useMethod)) {
        rmodel.useMethod = self.queryMyBoxModel.useMethod;
    }
    rmodel.perCount = self.queryMyBoxModel.perCount;
  NSString *yongliang = @"";
    NSString *times = @"";
//  
//    if ( ![StrFromObj(self.queryMyBoxModel.intervalDay)   isEqualToString:@""]) {
////        times = self.queryMyBoxModel.drugTime;
//         yongliang =[NSString stringWithFormat:@"%@%@",yongliang,self.queryMyBoxModel.unit];
//    }
//    if ( ![StrFromObj(self.queryMyBoxModel.drugTime) isEqualToString:@""]) {
//      
//        times =[NSString stringWithFormat:@"%@%@",times,self.queryMyBoxModel.drugTime];
//        
//    }
    if ( ![StrFromObj(self.queryMyBoxModel.perCount) isEqualToString:@""]&&self.queryMyBoxModel.perCount !=nil) {
        if ([self.queryMyBoxModel.perCount integerValue] !=-99) {
              yongliang =[NSString stringWithFormat:@"%@%@",yongliang,self.queryMyBoxModel.perCount];
        }
      
    }
    
    if ( ![StrFromObj(self.queryMyBoxModel.unit) isEqualToString:@""]&&self.queryMyBoxModel.unit !=nil) {
      yongliang =[NSString stringWithFormat:@"%@%@",yongliang,self.queryMyBoxModel.unit];
    }
    self.yongliangLable.text =yongliang;
    NSUInteger intervalDay = [self.queryMyBoxModel.intervalDay integerValue];
//    if ([self.queryMyBoxModel.intervalDay isKindOfClass:[NSNumber class]]) {
// 
//    }
    if([StrFromObj(self.queryMyBoxModel.intervalDay) isEqualToString:@""]|| self.queryMyBoxModel.intervalDay ==nil)
    {
        
    }else if(intervalDay == 0) {
 
        self.queryMyBoxModel.drugTime = @"";
  
             self.timesLable.text =[NSString stringWithFormat:@""];
    }else if (intervalDay == 1) {
 
        if(self.queryMyBoxModel.drugTime && ![[NSString stringWithFormat:@"%@",self.queryMyBoxModel.drugTime] isEqualToString:@""]){
             self.timesLable.text =[NSString stringWithFormat:@"%@%@次",[NSString stringWithFormat:@"每日"],self.queryMyBoxModel.drugTime];
        }
    }else{
        
            if ([self.queryMyBoxModel.drugTime integerValue] !=-99 && [self.queryMyBoxModel.drugTime integerValue] !=-99) {
//        [self.periodButton setTitle:[NSString stringWithFormat:@"每%@日",self.queryMyBoxModel.intervalDay] forState:UIControlStateNormal];
        if(self.queryMyBoxModel.drugTime && ![[NSString stringWithFormat:@"%@",self.queryMyBoxModel.drugTime] isEqualToString:@""]){
             self.timesLable.text =[NSString stringWithFormat:@"%@%@次",[NSString stringWithFormat:@"每%@日",self.queryMyBoxModel.intervalDay],self.queryMyBoxModel.drugTime];
        }
            }
    }
 
}
- (void)dealloc
{
 
}

#pragma mark - LeveyPopListView delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

}

- (void)adjustUseageDetailLabel
{
    NSString *str1 = nil;//用法
    NSString *str2 = nil;//用量
    NSString *str3 = nil;//次数
    //第一行填满
    if(self.queryMyBoxModel.useMethod){
        str1 = self.queryMyBoxModel.useMethod;
    }
    //第二行填满
//    if(self.queryMyBoxModel.perCount && ![self.queryMyBoxModel.perCount isEqualToString:@""] && [self.queryMyBoxModel.perCount integerValue] != -99 && self.queryMyBoxModel.unit && ![self.queryMyBoxModel.unit isEqualToString:@""]){
//        str2 = [NSString stringWithFormat:@"一次%@%@",self.queryMyBoxModel.perCount,self.queryMyBoxModel.unit];
//    }
    if (!StrIsEmpty(self.queryMyBoxModel.perCount) && [self.queryMyBoxModel.perCount integerValue] != -99 && !StrIsEmpty(self.queryMyBoxModel.unit)) {
        str2 = [NSString stringWithFormat:@"一次%@%@",self.queryMyBoxModel.perCount,self.queryMyBoxModel.unit];
    }
    //第三行填满
    if(self.queryMyBoxModel.intervalDay && self.queryMyBoxModel.drugTime && [self.queryMyBoxModel.intervalDay integerValue] != -99 && [self.queryMyBoxModel.drugTime integerValue] != -99){
        NSUInteger intervalDay = [self.queryMyBoxModel.intervalDay integerValue];
        if(intervalDay == 0) {
//            str3 = @"即需即用";
        }else{
            str3 = [NSString stringWithFormat:@"%@日%@次",self.queryMyBoxModel.intervalDay,self.queryMyBoxModel.drugTime];
        }
    }
    _usageDetailLabel.textColor = RGBHex(qwColor6);
    if(str1)
        _usageDetailLabel.text = [NSString stringWithFormat:@"%@",str1];
    if(str2)
        _usageDetailLabel.text = [NSString stringWithFormat:@"%@",str2];
    if(str3)
        _usageDetailLabel.text = [NSString stringWithFormat:@"%@",str3];
    if(str1 && str2)
        _usageDetailLabel.text = [NSString stringWithFormat:@"%@，%@",str1,str2];
    if(str1 && str3)
        _usageDetailLabel.text = [NSString stringWithFormat:@"%@，%@",str1,str3];
    if(str2 && str3)
        _usageDetailLabel.text = [NSString stringWithFormat:@"%@，%@",str2,str3];
    if(str1 && str2 && str3)
        _usageDetailLabel.text = [NSString stringWithFormat:@"%@，%@，%@",str1,str2,str3];
    
}

#pragma mark - UIAlertViewDelegate
- (void)leveyPopListView:(LeveyPopListViewNew *)popListView didSelectedIndex:(NSInteger)anIndex select:(BOOL)select{
    
    switch (popListView.tag)
    {
        case 2:{
            NSString *title = self.unitList[anIndex];
            self.queryMyBoxModel.unit = title;
            
            break;
        }
        case 3:{
            NSString *title = self.periodList[anIndex];
            NSString *intervalDay = [title substringWithRange:NSMakeRange(1, 1)];
            if([intervalDay isEqualToString:@"日"]) {
                intervalDay = @"1";
            }
//            if([title isEqualToString:@"即需即用"]){
//                intervalDay = @"0";
//                 NSString *title = self.frequencyList[0];
//                NSString *drugTime = [title substringWithRange:NSMakeRange(0, 1)];
//                self.queryMyBoxModel.drugTime = [NSNumber numberWithInt:[drugTime integerValue]];
//             }else{
//             }
        
            self.queryMyBoxModel.intervalDay = [NSNumber numberWithInt:[intervalDay integerValue]];
             break;
        }
        case 4:{
            NSString *title = self.frequencyList[anIndex];
            NSString *drugTime = [title substringWithRange:NSMakeRange(0, 1)];
            self.queryMyBoxModel.drugTime = [NSNumber numberWithInt:[drugTime integerValue]];
             break;
        }
        case 5:
        {
            if (popListView.selectedIndex == anIndex) {
                popListView.selectedIndex = -1;
            }
        
            
                if (select) {
//                      [_userArr addObject:self.useNameList[anIndex]];
                }else
                {
//                    [_userArr removeObject:self.useNameList[anIndex]];
                }
    
          
            break;
        }
        default:
            break;
    }
    [self adjustUseageDetailLabel];
}

- (void)leveyPopListViewDidCancel
{
    
    NSMutableArray *arrItems = [@[] mutableCopy];
  

  
    for (LeveyPopModel *model in _userArr) {
             [arrItems addObject:model.memberId];
    }
        NSString *strItems = [arrItems componentsJoinedByString:SeparateStr];
    
    if (![strItems isEqualToString:@""]) {
          completeMemberMedicineR.memberIds = strItems;
    }else
    {
        completeMemberMedicineR.memberIds = nil;
    }
  
    
    NSMutableArray *names = [@[] mutableCopy];
    for (LeveyPopModel *model in _userArr) {
        [names addObject:model.title];
    }
    useName = [names componentsJoinedByString:@"，"];
    if (_userArr.count >0) {
          self.userLabel.text = useName;
    }else
    {
        self.userLabel.text = @"选择使用者";
    }
  
//    [_tableView reloadData];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        SearchMedicineViewController *searchMedicineViewController = [[SearchMedicineViewController alloc] init];
        searchMedicineViewController.selectBlock = ^(NSMutableDictionary* dataRow){
            self.queryMyBoxModel.productName = dataRow[@"productName"];
            if(dataRow[@"productId"])
                self.queryMyBoxModel.proId = dataRow[@"productId"];
             if(!dataRow[@"intervalDay"]) {
              self.queryMyBoxModel.intervalDay = @"";
            }
//            if(self.queryMyBoxModel.drugTime && ![self.queryMyBoxModel.drugTime isEqualToString:@""] && !self.queryMyBoxModel.intervalDay) {
//                self.queryMyBoxModel.intervalDay = @"1";
//            }
            if (!StrIsEmpty(self.queryMyBoxModel.drugTime) && !self.queryMyBoxModel.intervalDay) {
                self.queryMyBoxModel.intervalDay = @"1";
            }
            [self fillupDrug];
            [self adjustUseageDetailLabel];
            self.medicinelabel.text = self.queryMyBoxModel.productName;
        };
        [self.navigationController pushViewController:searchMedicineViewController animated:NO];
    }else if (buttonIndex == 1){
        if (![QYPhotoAlbum checkCameraAuthorizationStatus]) {
            [QWGLOBALMANAGER getCramePrivate];
            return;
        }
        
        
        ScanReaderViewController *vc = [[ScanReaderViewController alloc] initWithNibName:@"ScanReaderViewController" bundle:nil];
        vc.useType = Enum_Scan_Items_Add;
        vc.addMedicineUsageBolck = ^(ProductModel *productModel,ProductUsage *productUsage){
            self.queryMyBoxModel.productName = productModel.proName;
            self.queryMyBoxModel.proId = productModel.proId;
            self.queryMyBoxModel.imgUrl = productModel.imgUrl;
//            [self.infoDict addEntriesFromDictionary:[productUsage dictionaryModel]];
            if(self.queryMyBoxModel.intervalDay) {
                self.queryMyBoxModel.intervalDay = @"";
            }
//            if(self.queryMyBoxModel.drugTime"] && ![self.queryMyBoxModel.drugTime"] isEqualToString:@""] && !self.queryMyBoxModel.intervalDay"]) {
//                self.queryMyBoxModel.intervalDay"] = @"1";
//            }
            if(productUsage.perCount && [productUsage.perCount integerValue] != 0) {
                self.queryMyBoxModel.intervalDay = [NSString stringWithFormat:@"%@",productUsage.perCount];
            }
            if(productUsage.dayPerCount && [productUsage.dayPerCount integerValue] != 0) {
                self.queryMyBoxModel.drugTime = [NSString stringWithFormat:@"%@",productUsage.dayPerCount];
                if(productUsage.drugTime && [productUsage.drugTime integerValue] == 0) {
                    self.queryMyBoxModel.intervalDay = [NSString stringWithFormat:@"%@",@"1"];
                }
            }
            
            
            [self fillupDrug];
            [self adjustUseageDetailLabel];
//            [self.tableView reloadData];
            self.medicinelabel.text = self.queryMyBoxModel.productName;
        };
        
//        ScanReaderViewController *vc = [[ScanReaderViewController alloc] initWithNibName:@"ScanReaderViewController" bundle:nil];
//        vc.useType = Enum_Scan_Items_Add;
//        vc.completionBolck = ^(ProductModel *mode){
//            DebugLog(@"%@",[mode dictionaryModel]);
////            _modLocalNotif.productName=mode.proName;//StrFromObj(dict[@"proName"]);
////            _modLocalNotif.productId=mode.proId;//StrFromObj(dict[@"proId"]);
//            
//            [self fillupDrug];
//            [self adjustUseageDetailLabel];
//            [self.tableView reloadData];
//        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)compareAdapter:(NSString *)adapter WithFilterArray:(NSArray *)array
{
    for(NSString *filter in array)
    {
        if([filter isEqualToString:adapter]) {
            [_userArr addObject:filter];
            return [array indexOfObject:filter];
        }
    }
    return -1;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}




- (IBAction)useMeather:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = YES;
    if (btn.tag == 0) {
         rmodel.useMethod = @"口服";
        self.queryMyBoxModel.useMethod =@"口服";
    }else if (btn.tag == 1)
    {
          rmodel.useMethod = @"外用";
         self.queryMyBoxModel.useMethod =@"外用";;
    }else
    {
          rmodel.useMethod = @"其他";
         self.queryMyBoxModel.useMethod =@"其他";
    }
    
    NSInteger buttonTag=btn.tag;
    
    if (self.waiyong.selected && self.waiyong.tag!=buttonTag) {
        
        self.waiyong.selected=NO;
        
    }
    else if (self.koufu.selected && self.koufu.tag!=buttonTag) {
        
        self.koufu.selected=NO;
    }
    else if (self.qita.selected && self.qita.tag!=buttonTag) {
        
        self.qita.selected=NO;
    }
  
    

   
}

- (NSString *)getCurDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strCur = [dateFormatter stringFromDate:[NSDate date]];
    return strCur;
}

- (void)saveAction:(id)sender
{
    [self.medicinelabel resignFirstResponder];
    if(!QWGLOBALMANAGER.loginStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        return;
    }
    
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
         
        return;
         
    }

    self.queryMyBoxModel.perCount = rmodel.perCount;
//    if(!rmodel.perCount){
//        [SVProgressHUD showErrorWithStatus:@"请添加药品!" duration:0.8f];
//        return;
//    }
//    if(!self.queryMyBoxModel.useName){
//        [SVProgressHUD showErrorWithStatus:@"请选择使用者!" duration:0.8f];
//        return;
//    }

    

    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if(!StrIsEmpty(self.queryMyBoxModel.boxId)){
        completeMemberMedicineR.boId = self.queryMyBoxModel.boxId;
    }
     if(!StrIsEmpty(self.queryMyBoxModel.proId)){
        rmodel.proId = self.queryMyBoxModel.proId;
    }
    if(!StrIsEmpty(self.queryMyBoxModel.proId)) {
       rmodel.proId = self.queryMyBoxModel.proId;
    }else{
        //渠道统计
        if(!StrIsEmpty(self.queryMyBoxModel.productName)){
        ChannerTypeModel *modelTwo=[ChannerTypeModel new];
        modelTwo.objRemark=self.queryMyBoxModel.productName;
        modelTwo.objId=@"";
        modelTwo.cKey=@"e_jy";
        [QWGLOBALMANAGER qwChannel:modelTwo];
        }
    }
    if(!StrIsEmpty(self.queryMyBoxModel.productName)){
       rmodel.proName = self.queryMyBoxModel.productName;
    }
    
    if(!StrIsEmpty(self.queryMyBoxModel.useName)){
//        setting[@"useName"] = self.queryMyBoxModel.useName"];
    }
    
    if(!StrIsEmpty(self.queryMyBoxModel.useMethod)){
        rmodel.useMethod = self.queryMyBoxModel.useMethod;
    }
    
    if(self.queryMyBoxModel.perCount){
        rmodel.perCount = self.queryMyBoxModel.perCount;
    }
    
    if(self.queryMyBoxModel.unit){
        rmodel.unit = self.queryMyBoxModel.unit;
    }
    
    if([self.queryMyBoxModel.intervalDay integerValue] != 0)
       rmodel.intervalDay = [NSString stringWithFormat:@"%@",self.queryMyBoxModel.intervalDay];
    
    if([self.queryMyBoxModel.drugTime integerValue] != 0)
        rmodel.drugTime = [NSString stringWithFormat:@"%@",self.queryMyBoxModel.drugTime];
    
    if(self.queryMyBoxModel.source){
//        setting[@"source"] = self.queryMyBoxModel.source"];
    }
    if (completeMemberMedicineR.memberIds ==nil ) {
        completeMemberMedicineR.memberIds = self.memberId;
    }
    rmodel.token = QWGLOBALMANAGER.configure.userToken;

    if (self.editMode == 1 ||self.editMode == 2) {
   
        completeMemberMedicineR.proName = rmodel.proName;
        completeMemberMedicineR.token = rmodel.token;
        completeMemberMedicineR.proId = rmodel.proId;
        completeMemberMedicineR.perCount = rmodel.perCount;
        completeMemberMedicineR.proName = rmodel.proName;
        completeMemberMedicineR.intervalDay = rmodel.intervalDay;
        completeMemberMedicineR.drugTime = rmodel.drugTime;
        completeMemberMedicineR.unit = rmodel.unit;
        completeMemberMedicineR.useMethod = rmodel.useMethod;
      
        if (!completeMemberMedicineR.memberIds) {
            [SVProgressHUD showErrorWithStatus:@"请添加使用者" duration:0.8f];
            return;
        }
        
        [FamilyMedicine completeMemberMedicine:completeMemberMedicineR success:^(id obj ) {
            self.queryMyBoxModel.perCount = rmodel.perCount;
            self.queryMyBoxModel.unit = rmodel.unit;
            self.queryMyBoxModel.intervalDay = rmodel.intervalDay;
            self.queryMyBoxModel.drugTime = rmodel.drugTime;
            self.queryMyBoxModel.useMethod = rmodel.useMethod;
            if (self.boxModelDidChange) {
                     self.boxModelDidChange(self.queryMyBoxModel);
            }
        
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(HttpException *e) {
            
        }];
    }
    else
    {
        
        if (!rmodel.proName) {
            [SVProgressHUD showErrorWithStatus:@"请添加药品" duration:0.8f];
            return;
        }
        rmodel.memberId = self.familyMembersVo.memberId;
    [FamilyMedicine addMemberMedicine:rmodel success:^(id obj ) {//SaveOrUpdateMyBoxModel
        
        
        SaveOrUpdateMyBoxModel *saveOrUpdateMyBoxModel = [SaveOrUpdateMyBoxModel parse:obj];
         self.queryMyBoxModel.boxId = saveOrUpdateMyBoxModel.boId;
       
        if (saveOrUpdateMyBoxModel.proId)
           self.queryMyBoxModel.proId= saveOrUpdateMyBoxModel.proId;
        
        saveOrUpdateMyBoxModel.proId = StrFromObj(self.queryMyBoxModel.boxId);
 
        if(self.InsertNewPharmacy) {
            self.queryMyBoxModel.createTime = [self getCurDate];
       
            self.InsertNewPharmacy(self.queryMyBoxModel);
        }
        if(self.editMode == 1)
        {
            //编辑模式,需要发出通知,更新用药列表
            
            self.boxModelDidChange(self.queryMyBoxModel);
            [[NSNotificationCenter defaultCenter] postNotificationName:PHARMACY_NEED_UPDATE object:nil];
        }
        [self.navigationController popViewControllerAnimated:NO];
        if (self.blockPush != nil) {
            self.blockPush();
        }
    } failure:^(HttpException *e ) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
    
    }
//    SaveOrUpdateMyBoxModelR *saveOrUpdateMyboxModelR = [SaveOrUpdateMyBoxModelR parse:setting Elements:[SaveOrUpdateMyBoxModelR class]];
//    [Box saveOrUpdateMyBoxWithParams:saveOrUpdateMyboxModelR success:^(id updateBoxId) {//SaveOrUpdateMyBoxModel
//        SaveOrUpdateMyBoxModel *saveOrUpdateMyBoxModel = (SaveOrUpdateMyBoxModel *)updateBoxId;
//        self.queryMyBoxModel.boxId"] = saveOrUpdateMyBoxModel.boxId;
//        if (saveOrUpdateMyBoxModel.proId)
//            self.queryMyBoxModel.proId"] = saveOrUpdateMyBoxModel.proId;
//
//        saveOrUpdateMyBoxModel.proId = StrFromObj(self.queryMyBoxModel.boxId"]);
//        [self.originDict addEntriesFromDictionary:self.infoDict];
//        if(self.InsertNewPharmacy) {
//            self.queryMyBoxModel.createTime"] = [self getCurDate];
//            if (self.queryMyBoxModel.productId"])
//                self.queryMyBoxModel.proId"] = self.queryMyBoxModel.productId"];
//            self.InsertNewPharmacy([QueryMyBoxModel parse:self.infoDict]);
//        }
//        if(self.editMode == 1)
//        {
//            //编辑模式,需要发出通知,更新用药列表
//
//            self.boxModelDidChange([QueryMyBoxModel parse:self.originDict Elements:[QueryMyBoxModel class]]);
//            [[NSNotificationCenter defaultCenter] postNotificationName:PHARMACY_NEED_UPDATE object:nil];
//        }
//        [self.navigationController popViewControllerAnimated:NO];
//        if (self.blockPush != nil) {
//            self.blockPush();
//        }
//    } failure:^(HttpException *e) {
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    }];
}

- (void)setPushToMyMedicineBlock:(PushToMyMedicineList)block
{
    self.blockPush = block;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}


#pragma mark ZhpickVIewDelegate

-(void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString arr:(NSMutableArray *)arr{
    self.bgBtn.hidden = YES;

    if (pickView.pickerTag ==1) {
        [UIView animateWithDuration:.3 animations:^{
            _yongfaPicker.frame= CGRectMake(_yongfaPicker.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width ,249) ;  ;
            _yongfaPicker.showed =NO;
        } completion:^(BOOL finished) {
            
        }];
        rmodel.perCount = arr[0];
        rmodel.unit = arr[1];
        self.queryMyBoxModel.unit = arr[1];
        self.queryMyBoxModel.perCount = arr[0];
        self.yongliangLable.text = resultString;
    }else
    {
        [UIView animateWithDuration:.3 animations:^{
            
            _yongliangPicker.showed =NO;
            _yongliangPicker.frame= CGRectMake(_yongliangPicker.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width ,249) ;
        } completion:^(BOOL finished) {
            
        }];
//        if ([[unitDic objectForKey:arr[0]]  isEqualToString:@"0" ]) {
//             self.timesLable.text =[NSString stringWithFormat:@"即需即用"];
//        }else
//        {
        self.timesLable.text =[NSString stringWithFormat:@"%@次", resultString];
//        }
            rmodel.intervalDay = [unitDic objectForKey:arr[0]];
//        if ([arr[1] isEqualToString:@"即需即用"]) {
//            rmodel.drugTime = 0;
//        }else
//        {
        rmodel.drugTime =arr[1];
//        }
        self.queryMyBoxModel.intervalDay = [unitDic objectForKey:arr[0]];
        self.queryMyBoxModel.drugTime =arr[1];
        
    
    }

 }
- (IBAction)timesBtn:(id)sender {
    self.bgBtn.hidden = NO;
        [self.medicinelabel resignFirstResponder];
    if (!_yongfaPicker.showed && !_yongliangPicker.showed) {
        [UIView animateWithDuration:.3 animations:^{
            
            
            _yongliangPicker.frame= CGRectMake(_yongliangPicker.frame.origin.x, self.view.frame.size.height-249, self.view.frame.size.width ,249) ;
            _yongliangPicker.showed =YES;
        } completion:^(BOOL finished) {
            
        }];
    }
   

}

- (IBAction)yongliangBtn:(id)sender {
    self.bgBtn.hidden = NO;
    [self.medicinelabel resignFirstResponder];
    if (!_yongfaPicker.showed && !_yongliangPicker.showed) {
         [UIView animateWithDuration:.3 animations:^{
        _yongfaPicker.frame= CGRectMake(_yongfaPicker.frame.origin.x, self.view.frame.size.height-249, self.view.frame.size.width ,249) ;  ;
        _yongfaPicker.showed =YES;
 
    } completion:^(BOOL finished) {
        
    }];
     }
}

- (IBAction)chooseUser:(id)sender {
       [LeveyPopModel updateSetToDB:@"selected = '0'" WithWhere:nil];
      self.useNameList    = [NSMutableArray arrayWithArray:[LeveyPopModel getArrayFromDBWithWhere:nil]];
    for (LeveyPopModel *model in _userArr) {
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"memberId == %@",model.memberId];
        NSArray *array = [self.useNameList filteredArrayUsingPredicate:predicate];;
        LeveyPopModel *sub =array [0];
        sub.selected = YES;
    }
    
      [self.medicinelabel resignFirstResponder];
    if (self.useNameList.count ==0  && hasQueryUser == NO) {
        QueryFamilyMembersR *queryFamilyMembersR = [QueryFamilyMembersR new];
        queryFamilyMembersR.token = QWGLOBALMANAGER.configure.userToken;
        [LeveyPopModel deleteAllObjFromDB];
        [FamilyMedicine queryFamilyMembers:queryFamilyMembersR success:^(QueryFamilyMembersModel *modle ) {
 
            for ( FamilyMembersVo *familyMembersVo in modle.list) {
                LeveyPopModel *popModel = [LeveyPopModel new];
 
                popModel.title = familyMembersVo.name;
                popModel.selected = NO;
                popModel.memberId = familyMembersVo.memberId;
 
                if (![self filterUser:popModel]) {
                    [self.useNameList addObject:popModel];
                }            }
            [LeveyPopModel insertToDBWithArray:self.useNameList filter:^(id model, BOOL inseted, BOOL *rollback) {
                
            }];
            [self popUserView];
        } failure:^(HttpException *e) {
            
        }];
    }
    else
    {
        [self popUserView];
    }
}
-(void)popVCAction:(id)sender
{
    [super popVCAction:sender];
}
-(void)popUserView
{
    LeveyPopListViewNew *popListView = [[LeveyPopListViewNew alloc] initWithTitle:@"添加成员" options:self.useNameList];
    if (!_userArr) {
        _userArr = [NSMutableArray array];
    }
    [popListView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:kShadowAlpha]];
    popListView.delegate = self;
    popListView.tag = 5;
    [popListView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
    [popListView showInView:self.view animated:YES];
}
-(void)canclePicker:(NSInteger)tag
{
    self.bgBtn.hidden = YES;
    [self.medicinelabel resignFirstResponder];
    if (tag ==1) {
        [UIView animateWithDuration:.3 animations:^{
            _yongfaPicker.frame= CGRectMake(_yongfaPicker.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width ,249) ;  ;
              _yongfaPicker.showed =NO;
        } completion:^(BOOL finished) {
            
        }];
    }else
    {
        [UIView animateWithDuration:.3 animations:^{
            
              _yongliangPicker.showed =NO;
            _yongliangPicker.frame= CGRectMake(_yongliangPicker.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width ,249) ;
        } completion:^(BOOL finished) {
            
        }];
    }
}
- (IBAction)bgBtn:(id)sender {
      [self.medicinelabel resignFirstResponder];
    if (_yongfaPicker.showed) {
        [UIView animateWithDuration:.3 animations:^{
            _yongfaPicker.frame= CGRectMake(_yongfaPicker.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width ,249) ;  ;
            _yongfaPicker.showed =NO;
        } completion:^(BOOL finished) {
               self.bgBtn.hidden = YES;
        }];
    }
    
    if (_yongliangPicker.showed) {
        [UIView animateWithDuration:.3 animations:^{
            
            _yongliangPicker.showed =NO;
            _yongliangPicker.frame= CGRectMake(_yongliangPicker.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width ,249) ;
        } completion:^(BOOL finished) {
               self.bgBtn.hidden = YES;
        }];

    }

}
- (IBAction)chooseMedcine:(id)sender {
    [self.medicinelabel resignFirstResponder];
    NSArray *arr = @[@"请选择药品来源",@"从药品库搜索",@"扫描条形码",@"取消"];
    LeveyPopListViewCUS *vv = [[LeveyPopListViewCUS alloc] initWithTitle:@"" options:arr];
    vv.delegate = self;
    vv.tag = 10;
    vv.type = 1;
    vv.selectedIndex =3;
    [vv setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:kShadowAlpha]];
    [vv showInView:self.view animated:YES];
}
#pragma mark - UIAlertViewDelegate
- (void)leveyPopListViewCUS:(LeveyPopListViewCUS *)popListView didSelectedIndex:(NSInteger)anIndex {
    if (popListView.tag == 10) {
 
        if(anIndex == 1) {
            SearchMedicineViewController *searchMedicineViewController = [[SearchMedicineViewController alloc] init];
            searchMedicineViewController.selectBlock = ^(NSMutableDictionary* dataRow){
                self.queryMyBoxModel.productName = dataRow[@"productName"];
                if(dataRow[@"productId"])
                    self.queryMyBoxModel.proId = dataRow[@"productId"];
                if(!dataRow[@"intervalDay"]) {
                    self.queryMyBoxModel.intervalDay = @"";
                }
//                if(self.queryMyBoxModel.drugTime && ![self.queryMyBoxModel.drugTime isEqualToString:@""] && !self.queryMyBoxModel.intervalDay) {
//                    self.queryMyBoxModel.intervalDay = @"1";
//                }
                if (!StrIsEmpty(self.queryMyBoxModel.drugTime) && !self.queryMyBoxModel.intervalDay) {
                    self.queryMyBoxModel.intervalDay = @"1";
                }
                [self fillupDrug];
                [self adjustUseageDetailLabel];
                self.medicinelabel.text = self.queryMyBoxModel.productName;
            };
            [self.navigationController pushViewController:searchMedicineViewController animated:NO];
        }else if (anIndex == 2){
            if (![QYPhotoAlbum checkCameraAuthorizationStatus]) {
               [QWGLOBALMANAGER getCramePrivate];
                return;
            }
            ScanReaderViewController *vc = [[ScanReaderViewController alloc] initWithNibName:@"ScanReaderViewController" bundle:nil];
            vc.useType = Enum_Scan_Items_Add;
            vc.addMedicineUsageBolck = ^(ProductModel *productModel,ProductUsage *productUsage){
                self.queryMyBoxModel.productName = productModel.proName;
                self.queryMyBoxModel.proId = productModel.proId;
                self.queryMyBoxModel.imgUrl = productModel.imgUrl;
                 if(self.queryMyBoxModel.intervalDay) {
                    self.queryMyBoxModel.intervalDay = @"";
                }

                if(productUsage.perCount && [productUsage.perCount integerValue] != 0) {
                    self.queryMyBoxModel.intervalDay = [NSString stringWithFormat:@"%@",productUsage.perCount];
                }
                if(productUsage.dayPerCount && [productUsage.dayPerCount integerValue] != 0) {
                    self.queryMyBoxModel.drugTime = [NSString stringWithFormat:@"%@",productUsage.dayPerCount];
                    if(productUsage.drugTime && [productUsage.drugTime integerValue] == 0) {
                        self.queryMyBoxModel.intervalDay = [NSString stringWithFormat:@"%@",@"1"];
                    }
                }
                
                
                [self fillupDrug];
                [self adjustUseageDetailLabel];
                //            [self.tableView reloadData];
                self.medicinelabel.text = self.queryMyBoxModel.productName;
                
                //渠道统计
                ChannerTypeModel *modelTwo=[ChannerTypeModel new];
                modelTwo.objRemark=productModel.proName;
                modelTwo.objId=productModel.proId;
                modelTwo.cKey=@"e_family_add_product";
                [QWGLOBALMANAGER qwChannel:modelTwo];
                
            };

            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
}

- (void)leveyPopListViewCUSDidCancel
{
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     FamilyMedicineCell   *cell = [tableView dequeueReusableCellWithIdentifier:@"FamilyMedicineCell"];
 
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField == self.medicinelabel){
        
        if(![string isEqualToString:@""]){
            if(textField.text.length == 20){
                return NO;
            }
            else{
                return YES;
            }
        }
    }
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{

 //   if (![textField.text isEqualToString:@""]  && textField.text !=nil ) {
    if (!StrIsEmpty(textField.text)) {
        NSString *textStr = textField.text;
//              textStr = [textStr substringToIndex:0];
        if (textStr.length >20) {
            textStr = [textStr substringToIndex:20];
        }
        textField.text = textStr;
        rmodel.proName = textStr;
    }
   
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.medicinelabel resignFirstResponder];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.editMode == 2 ||self.editMode == 1) {
        return NO;
    }
    return YES;
}
-(void)removeUserInfo
{
    [_userArr removeAllObjects];
}

-(void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj
{
    if (type == NOtifSaveFamilyInfo) {
             [self queryMemberInfo];
 
    }
}
@end
