//
//  WYLocalNotifAddVC.m
//  wenyao
//
//  Created by Yan Qingyang on 15/4/2.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "WYLocalNotifEditVC.h"
#import "WYLNOtherCell.h"
#import "WYLNTimesCell.h"
#import "WYLNDayCell.h"
#import "WYLNInfoCell.h"


#import "AppDelegate.h"
#import "SearchMedicineViewController.h"
#import "ScanReaderViewController.h"
#import "ChooseHomeMedicineViewController.h"
#import "WYChooseMyDrugModel.h"
#import "QYPhotoAlbum.h"
#import "LeveyPopListView.h"

#import "QWLNActionSheet.h"
#import "QWDatePicker.h"
#import "LoginViewController.h"

@interface WYLocalNotifEditVC ()
<LeveyPopListViewDelegate,QWLNActionSheetDelegate,WYLNOtherCellDelegate>
{
    NSString *strRemark;
    NSMutableArray *arrTmpTimes;

    IBOutlet UIView *vShow;
    IBOutlet UIButton *btnShadow;
    
    NSString *productName,*productUser,*productId,*drugCycle,*intervalDay;
}
@end

@implementation WYLocalNotifEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self dataInit];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self closeMedicineAction:nil];
//    [self.tableMain reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self closeMedicineAction:nil];
}

- (void)setModLocalNotif:(WYLocalNotifModel *)modLocalNotif{
    _modLocalNotif=modLocalNotif;
    productUser=_modLocalNotif.productUser;
    productName=_modLocalNotif.productName;
    productId=_modLocalNotif.productId;
    
    intervalDay=_modLocalNotif.numCycle;
    drugCycle=_modLocalNotif.drugCycle;
    [self.tableMain reloadData];
}

#pragma mark - 数据初始化
- (void)dataInit{
    self.title=@"编辑提醒";
    self.isNew=NO;
    
    if (_modLocalNotif==nil) {
        self.title=@"添加提醒";
        
        _modLocalNotif=[WYLocalNotifModel new];
        _modLocalNotif.beginDate=[[QWLocalNotif instance] dateToString:[NSDate date] format:@"yyyy-MM-dd"];
        
        [self.tableMain reloadData];
        self.isNew=YES;
    }
    
    NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/%@",QWGLOBALMANAGER.configure.userName]];
    homePath = [NSString stringWithFormat:@"%@/UserNameList.plist",homePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:homePath])
    {
        self.useNameList = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserNameList" ofType:@"plist"]];
        [self.useNameList writeToFile:homePath atomically:YES];
    }else{
        self.useNameList = [NSMutableArray arrayWithContentsOfFile:homePath];
    }
    if (self.useNameList.count >= 2) {
        [self.useNameList removeObjectAtIndex:self.useNameList.count-2];
    }

    self.periodList = @[@"每日",@"每2日",@"每3日",@"每4日",@"每5日",@"每6日",@"每7日"];

}

#pragma mark - UI
- (void)UIGlobal{
    [super UIGlobal];
    
//    [self naviRightBotton];
    self.tableMain.backgroundColor=[UIColor clearColor];
    self.tableMain.footerHidden=YES;
//    [self naviRightBotton:@"保存" action:@selector(saveAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveAction:)];
    
    btnShadow.backgroundColor=RGBAHex(qwColor17, kShadowAlpha);
    btnShadow.hidden=YES;
    
    //等约束起作用后改大小
//    vShow.translatesAutoresizingMaskIntoConstraints = YES;
}

#pragma mark - fct
- (NSInteger)compareAdapter:(NSString *)adapter WithFilterArray:(NSArray *)array
{
    for(NSString *filter in array)
    {
        if([filter isEqualToString:adapter]) {
            return [array indexOfObject:filter];
        }
    }
    return -1;
}

- (BOOL)checkList{
    return NO;
}

- (NSString*)times:(NSArray*)arr{
    NSString *str=nil;
    BOOL fst=YES;
    for (id obj in arr) {
        if (fst) {
            fst=false;
            str=[NSString stringWithFormat:@"%@",obj];
        }
        else str=[NSString stringWithFormat:@"%@ %@",str,obj];
    }
    return str;
}



#pragma mark - 修改闹钟数据
- (void)resetLN:(NSMutableArray*)arrList{
    [[QWLocalNotif instance] saveLNList:arrList];
//    [self setLocalNotifsList:arrList];
    [[QWLocalNotif instance] setLocalNotifications:arrList ok:^{
        
    }];
}

#pragma mark - action
- (IBAction)saveAction:(id)sender{
    [self.view endEditing:YES];
    
    if (productName.length==0) {
        [self showError:kWarningN5];
        return;
    }
    if (productName.length>40) {
        [self showError:kWarning220N61];
        return;
    }
    if (productUser.length == 0){
        [self showError:kWarningN6];
        return;
    }
    if (productUser.length > 10){
        [self showError:kWarning220N62];
        return;
    }
    
    _modLocalNotif.productName=productName;
    _modLocalNotif.productUser=productUser;
    _modLocalNotif.productId=productId;
    
    _modLocalNotif.numCycle=intervalDay;
    _modLocalNotif.drugCycle=drugCycle;
    
    if (arrTmpTimes.count) {
        _modLocalNotif.listTimes=[arrTmpTimes mutableCopy];
    }
//    _modLocalNotif.remark=strRemark;
    if (self.isNew) {
        id obj=[[QWLocalNotif instance] getLNList];
        //[QWUserDefault getObjectBy:kQWGlobalLocalNotification];//app.configureList[@"passportId"]
        if (obj==nil)  {
            obj=[NSMutableArray array];
        }
        _modLocalNotif.hashValue=StrFromInt((NSInteger)_modLocalNotif.hash);
//        _modLocalNotif.uid=app.configureList[@"passportId"];
        [obj insertObject:_modLocalNotif atIndex:0];
        
        [self resetLN:obj];
    }
    else if(self.listClock.count > 0){
//        _modLocalNotif.uid=app.configureList[@"passportId"];
        [self resetLN:self.listClock];
    }
    
    [self popVCAction:nil];
    
    
}

//- (IBAction)beginDateAction:(id)sender{
//    [self.view endEditing:YES];
//    self.tableMain.scrollEnabled=YES;
////    [self.tableMain setContentOffset:(CGPoint){0,256} animated:YES];
////    [self.tableMain setContentOffset:(CGPoint){0,0} animated:YES];
//    
//    [QWDatePicker instanceWithDate:[[QWLocalNotif instance] dateFromString:_modLocalNotif.beginDate] showInView:self.view callBack:^(NSDate *date) {
//        if (date) {
//            _modLocalNotif.beginDate=[[QWLocalNotif instance] dateToString:date];
//            [self.tableMain reloadData];
//        }
//        [self.tableMain setContentOffset:(CGPoint){0,0} animated:YES];
//    }];
//}

//- (IBAction)touchRemarkAction:(id)sender{
//    UITextView *tmp=[[UITextView alloc]init];
//    [tmp becomeFirstResponder];
//    [self textViewShouldBeginEditing:nil];
//    
////    [self]
//}

- (IBAction)cycleAction:(id)sender{
    [self.view endEditing:YES];
    //周期
    LeveyPopListView *vv = [[LeveyPopListView alloc] initWithTitle:@"请选择用法" options:self.periodList];
    vv.delegate = self;
    vv.tag = 3;
    vv.selectedIndex = [self compareAdapter:drugCycle WithFilterArray:self.periodList];
    [vv setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:kShadowAlpha]];
    [vv showInView:self.view animated:YES];

}

- (IBAction)userAction:(id)sender{
    [self.view endEditing:YES];
    //家人
    LeveyPopListView *vv = [[LeveyPopListView alloc] initWithTitle:@"请选择用法" options:self.useNameList];
    vv.delegate = self;
    vv.tag = 5;

    
    vv.selectedIndex = [self compareAdapter:productUser WithFilterArray:self.useNameList];
    [vv setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:kShadowAlpha]];
    [vv showInView:self.view animated:YES];

}


//家庭用药
- (IBAction)homeMedicineAction:(id)sender{
    if (QWGLOBALMANAGER.loginStatus) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"LocalNotif" bundle:nil];
        ChooseHomeMedicineViewController* vc = [sb instantiateViewControllerWithIdentifier:@"ChooseHomeMedicineViewController"];
        vc.selectBlock = ^(WYChooseMyDrugModel* model){
            productName=model.productName;
            productId=model.productId;
            
            NSIndexPath *tmpIndexpath=[NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableMain beginUpdates];
            [self.tableMain reloadRowsAtIndexPaths:[NSArray arrayWithObjects:tmpIndexpath, nil] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableMain endUpdates];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self loginButtonClick];
    }
}

//药品库
- (IBAction)searchMedicineAction:(id)sender{
    SearchMedicineViewController *vc = [[SearchMedicineViewController alloc] init];
    vc.selectBlock = ^(NSMutableDictionary* dataRow){
        productName=StrFromObj(dataRow[@"productName"]);
        productId=StrFromObj(dataRow[@"productId"]);
        NSIndexPath *tmpIndexpath=[NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableMain beginUpdates];
        [self.tableMain reloadRowsAtIndexPaths:[NSArray arrayWithObjects:tmpIndexpath, nil] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableMain endUpdates];
    };
    
    
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)scanAction:(id)sender
{
    if (![QYPhotoAlbum checkCameraAuthorizationStatus]) {
        [QWGLOBALMANAGER getCramePrivate];
        return;
    }
    ScanReaderViewController *vc = [[ScanReaderViewController alloc] initWithNibName:@"ScanReaderViewController" bundle:nil];
    vc.useType = Enum_Scan_Items_Add;
    vc.addMedicineUsageBolck = ^(ProductModel *productModel,ProductUsage *productUsage){
        
        productName=productModel.proName;
        productId=productModel.proId;
        NSIndexPath *tmpIndexpath=[NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableMain beginUpdates];
        [self.tableMain reloadRowsAtIndexPaths:[NSArray arrayWithObjects:tmpIndexpath, nil] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableMain endUpdates];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)showMedicineAction:(id)sender{
    [self.view endEditing:YES];
    btnShadow.hidden=NO;
    btnShadow.alpha=0;
    [UIView animateWithDuration:.25 animations:^{
        btnShadow.alpha=1;
        CGRect frm;
        frm=vShow.frame;
        frm.origin.y=CGRectGetHeight(self.view.frame)-CGRectGetHeight(vShow.frame);
        vShow.frame=frm;
    } completion:^(BOOL finished) {
        //
    }];
}

- (IBAction)closeMedicineAction:(id)sender{
    if (btnShadow.hidden) {
        return;
    }
    
    
    [UIView animateWithDuration:.15 animations:^{
        btnShadow.alpha=0;
        
        CGRect frm;
        frm=vShow.frame;
        frm.origin.y=CGRectGetHeight(self.view.frame);
        vShow.frame=frm;
    } completion:^(BOOL finished) {
        btnShadow.hidden=YES;
    }];
}

#pragma mark - 关闭所有编辑
- (void)endEdit{
    [self.view endEditing:YES];

}
#pragma mark - table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float hh=0;
    NSInteger row = indexPath.row;
    switch (row) {
        case 0:
            hh=[WYLNInfoCell getCellHeight:nil];
            break;
        case 1:
            hh=[WYLNDayCell getCellHeight:nil];
            break;
//        case 1:
//            hh=[WYLNTimesCell getCellHeight:nil];
//            break;
        case 2:
            hh=[WYLNOtherCell getCellHeight:nil];
            break;
        default:
            break;
    }
    return hh;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;

    static NSString *tableID;
    if (row==0) {
        tableID = [NSString stringWithFormat:@"WYLNInfoCell%li",(long)row];
      
        WYLNInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:tableID];
        cell.delegate=self;
        [cell setCell:_modLocalNotif];
        if (productName.length) {
            cell.txtProductName.text=productName;
        }
        if (productUser.length) {
            cell.txtProductUser.text=productUser;
        }
        return cell;
    }
    if (row==1) {
        tableID = @"WYLNDayCell";
        
        WYLNDayCell *cell = [tableView dequeueReusableCellWithIdentifier:tableID];
        cell.delegate=self;
//        [cell setCell:_modLocalNotif];
        if (drugCycle==nil) {
            drugCycle=_modLocalNotif.drugCycle;
            intervalDay=_modLocalNotif.numCycle;
        }
        cell.drugCycle.text=drugCycle;
     
        return cell;
    }
    if (row==2) {
        tableID = @"WYLNOtherCell";
        
        WYLNOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:tableID];
        cell.delegate=self;
        [cell setCell:_modLocalNotif];
        
        return cell;
    }
    
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

#pragma mark - leveyPopListView delegate
- (void)leveyPopListView:(LeveyPopListView *)popListView didSelectedIndex:(NSInteger)anIndex
{
    ;
    switch (popListView.tag)
    {
        case 1:{
            
            break;
        }
        case 2:{
            
            break;
        }
        case 3:{
            drugCycle = self.periodList[anIndex];
            intervalDay = [drugCycle substringWithRange:NSMakeRange(1, 1)];
            if(drugCycle.length==2) {
                intervalDay = @"1";
            }
            

            NSIndexPath *tmpIndexpath=[NSIndexPath indexPathForRow:1 inSection:0];
            [self.tableMain beginUpdates];
            [self.tableMain reloadRowsAtIndexPaths:[NSArray arrayWithObjects:tmpIndexpath, nil] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableMain endUpdates];
            
            break;
        }
        case 4:{
            
            break;
        }
        case 5:
        {
            if(anIndex == (self.useNameList.count - 1)) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.tag = 999;
                NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"secondCustomAlertView" owner:self options:nil];
                self.customAlertView = [nibViews objectAtIndex: 0];
                self.customAlertView.textField.frame = CGRectMake(self.customAlertView.textField.frame.origin.x, self.customAlertView.textField.frame.origin.y, self.customAlertView.textField.frame.size.width, 40);
                self.customAlertView.textField.placeholder = @"";
                self.customAlertView.textField.font = fontSystem(kFontS1);
                self.customAlertView.textField.textColor = RGBHex(qwColor6);
                
                self.customAlertView.textField.layer.masksToBounds = YES;
                self.customAlertView.textField.layer.borderWidth = 0.5;
                self.customAlertView.textField.layer.borderColor = RGBHex(qwColor10).CGColor;
                self.customAlertView.textField.layer.cornerRadius = 5.0f;
                UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
                self.customAlertView.textField.leftView = paddingView;
                self.customAlertView.textField.leftViewMode = UITextFieldViewModeAlways;
                if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
                    [alertView setValue:self.customAlertView forKey:@"accessoryView"];
                }else{
                    [alertView addSubview:self.customAlertView];
                }
                
                //                self.customAlertView.textField.keyboardType = UIKeyboardTypeDefault;// 设置键盘样式
                [alertView show];
                
            }
            else{
                productUser = self.useNameList[anIndex];
            }
            
            NSIndexPath *tmpIndexpath=[NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableMain beginUpdates];
            [self.tableMain reloadRowsAtIndexPaths:[NSArray arrayWithObjects:tmpIndexpath, nil] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableMain endUpdates];
//            [self.tableMain reloadData];
            break;
        }
        default:
            break;
    }
//    [self adjustUseageDetailLabel];
}

- (void)leveyPopListViewDidCancel
{
    
}

#pragma mark - 自定义使用者 alertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        if(self.customAlertView.textField.text.length == 0) {
            return;
        }else if(self.customAlertView.textField.text.length > 10){
            [self showText:@"自定义姓名不能超过十位!"];
//            [SVProgressHUD showErrorWithStatus:@"自定义姓名不能超过十位!" duration:0.8f];
            return;
        }
        NSString *userName = self.customAlertView.textField.text;
        [self.useNameList insertObject:userName atIndex:0];

        NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/%@",QWGLOBALMANAGER.configure.userName]];
        homePath = [NSString stringWithFormat:@"%@/UserNameList.plist",homePath];
        [self.useNameList writeToFile:homePath atomically:YES];
        productUser = userName;

        //刷新界面
        NSIndexPath *tmpIndexpath=[NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableMain beginUpdates];
        [self.tableMain reloadRowsAtIndexPaths:[NSArray arrayWithObjects:tmpIndexpath, nil] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableMain endUpdates];
    }
}

#pragma mark - 登录
- (void)loginButtonClick
{
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:loginViewController animated:YES];
}


#pragma mark - WYLNOtherCellDelegate
- (void)WYLNOtherCellDelegateTimes:(NSMutableArray*)list{

    arrTmpTimes=[list mutableCopy];
}


#pragma mark - delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag==1) {
        productName=textField.text;
        productId=@"";
    }
    else if (textField.tag==2){
        productUser=textField.text;
    }
    
}

@end
