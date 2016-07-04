//
//  AddAddressInfoViewController.m
//  APP
//  添加或修改地址页面
//  Created by qw_imac on 15/12/31.
//  Copyright © 2015年 carret. All rights reserved.
//

#import "AddOrChangeAddressInfoViewController.h"
#import "SearchLocationViewController.h"
#import <AMapSearchKit/AMapSearchAPI.h>
#import "Address.h"
#import "ReceiveAddress.h"
#import "ReceiveAddressR.h"
#import "SVProgressHUD.h"
#import "ShippingAdrModel.h"
#import "NewEditAddressCell.h"
#import "NewConfirmOrderViewController.h"
@interface AddOrChangeAddressInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIAlertViewDelegate>

@property (nonatomic,strong)ShippingAdrModel *modelAdr;
@property (nonatomic,strong)UIView *footerView;
@end

@implementation AddOrChangeAddressInfoViewController{
    BOOL isDefault;//是否是默认地址
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.footerView];
    isDefault = NO;
    if (!self.isChange) {
        self.title = @"添加地址";
        self.footerView.hidden = YES;
    }else {
        self.title = @"修改地址";
        self.footerView.hidden = NO;
    }
    self.modelAdr = [ShippingAdrModel new];
    if (self.styleEdit == StyleEdit) {  // 是编辑状态
        [self convertToLoaclModel];
    }else {
        self.modelAdr.city = [QWGLOBALMANAGER getMapInfoModel].city;
    }
    [self setupUI];
    // Do any additional setup after loading the view.
}

-(UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 104, APP_W, 40)];
        _footerView.backgroundColor = [UIColor whiteColor];
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, APP_W, 40)];
        [btn addTarget:self action:@selector(showAlertView) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"删除地址" forState:UIControlStateNormal];
        [btn setTitleColor:RGBHex(qwColor1) forState:UIControlStateNormal];
        [_footerView addSubview:btn];
    }
    return _footerView;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //城市栏从定位信息里取，且不可更改
//    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) { //add by jxb
//        self.modelAdr.city = mapInfoModel.city;
//        [self.tableMain reloadData];
//    }];
}
//记录用户输入信息，因为选择区域后返回会重载数据
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NewEditAddressCell *cell = (NewEditAddressCell *)[self.view viewWithTag:101];
    self.modelAdr.name = cell.nameTX.text;
    self.modelAdr.addressDetail = cell.addressTX.text;
    self.modelAdr.tel = cell.telTX.text;
    if (cell.manBtn.isSelected) {
        self.modelAdr.gender = @"M";
    }
    if (cell.womenBtn.isSelected) {
        self.modelAdr.gender = @"F";
    }
    self.modelAdr.city = cell.cityName.text;
    self.modelAdr.village = cell.locationTx.text;
}

- (void)convertToLoaclModel {
    self.modelAdr.name = self.vo.nick;
    self.modelAdr.tel = self.vo.mobile;
    self.modelAdr.city = self.vo.cityName;
    self.modelAdr.addressDetail = self.vo.address;
    self.modelAdr.county = self.vo.countyName;
    self.modelAdr.latitude = self.vo.lat;
    self.modelAdr.longitude = self.vo.lng;
    self.modelAdr.village = self.vo.village;
    self.modelAdr.gender = self.vo.sex;
    isDefault = [self.vo.flagDefault isEqualToString:@"Y"];
}

-(void)setupUI {
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btn setTitle:@"保存" forState:UIControlStateNormal];
    btn.titleLabel.font = fontSystem(kFontS4);
    [btn setTitleColor:RGBHex(qwColor1) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *save = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = save;
    
    self.tableMain =[[UITableView alloc] initWithFrame:CGRectMake(0, 0 , APP_W, [[UIScreen mainScreen] bounds].size.height - 104 ) style:UITableViewStylePlain];
    self.tableMain.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableMain.delegate = self;
    self.tableMain.dataSource = self;
    self.tableMain.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tableMain];
}
//保存或修改地址
-(void)save {
    [self.view endEditing:YES];
    UpdateAddressR *modelR = [UpdateAddressR new];
    //set modelr
    NewEditAddressCell *cell = (NewEditAddressCell *)[self.view viewWithTag:101];
    if (StrIsEmpty(cell.nameTX.text)) {
        [self showMessageWith:@"请填写姓名"];
        return;
    }
    if (StrIsEmpty(cell.telTX.text)) {
        [self showMessageWith:@"请填写手机号码"];
        return;
    }
    if (cell.telTX.text.length < 11) {
        [self showMessageWith:@"请填写11位手机号码"];
        return;
    }
    if (StrIsEmpty(cell.locationTx.text)) {
        [self showMessageWith:@"请选择所在地区"];
        return;
    }
    if (StrIsEmpty(cell.addressTX.text)) {
        [self showMessageWith:@"请填写详细地址"];
        return;
    }
//    DebugLog(@"------------%@",[QWGLOBALMANAGER getMapInfoModel].city);
    if (![cell.cityName.text isEqualToString:[QWGLOBALMANAGER getMapInfoModel].city]) {
        [self showMessageWith:@"城市与地区不匹配，请重新填写!"];
        return;
    }
    if (QWGLOBALMANAGER.loginStatus) {
        modelR.token = QWGLOBALMANAGER.configure.userToken;
    }
    if (cell.manBtn.isSelected) {
        modelR.sex = @"M";
    }
    if (cell.womenBtn.isSelected) {
        modelR.sex = @"F";
    }
    modelR.nick = cell.nameTX.text;
    modelR.city = cell.cityName.text;
    modelR.flagDefault = isDefault?@"Y":@"N";
    modelR.county = self.modelAdr.county;
    
    modelR.village = cell.locationTx.text;
    modelR.address = cell.addressTX.text;
    modelR.mobile = cell.telTX.text;
    modelR.longitude = self.modelAdr.longitude;
    modelR.latitude = self.modelAdr.latitude;
    if (self.styleEdit == StyleEdit) {
        modelR.id = self.vo.id;
    } else {
        
    }
    [Address updateAddress:modelR success:^(AddressVo *respons) {
//        //存本地默认收货地址逻辑 4.0
//        if ([respons.flagDefault isEqualToString:@"Y"]) {
//            MapInfoModel *model = [MapInfoModel new];
//            model.name = respons.nick;
//            model.tel = respons.mobile;
//            model.city = respons.cityName;
//            model.formattedAddress = [NSString stringWithFormat:@"%@%@",respons.village,respons.address];
//            model.location = [[CLLocation alloc]initWithLatitude:[respons.lat floatValue] longitude:[respons.lng floatValue]];
//            model.id = respons.id;
//            [QWUserDefault setObject:model key:kDefaultRecieveAddressModel];
//        }else {
//            MapInfoModel *model = [QWUserDefault getObjectBy:kDefaultRecieveAddressModel];
//            if ([model.id isEqualToString:respons.id]) {
//                 [QWUserDefault setObject:nil key:kDefaultRecieveAddressModel];
//            }
//        }
        //3.xx逻辑
        if (self.pageType == PageComeFromH5) {//H5过来的添加地址，完成之后进入地址列表页
            if (self.extCallback) {
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                params[@"lat"] = modelR.latitude;
                params[@"lng"] = modelR.longitude;
                params[@"address"] = modelR.address;
                params[@"cityName"] = modelR.city;
                params[@"countyName"] = modelR.county;
                params[@"nick"] = modelR.nick;
                params[@"mobile"] = modelR.mobile;
                params[@"sex"] = modelR.sex;
                params[@"village"] = modelR.village;
                params[@"id"] = respons.id;
                NSString *jsonString = nil;
                NSError *error = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
                if([jsonData length] > 0 && error == nil) {
                    jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
                    self.extCallback(jsonString);
                }
            }
            [self popVCAction:nil];
        }else if(_pageType == PageComeFromMall){//确认订单过来的修改地址直接返回确认订单
            [QWGLOBALMANAGER postNotif:NotifMallAddressAddOrEdit data:respons object:nil];
            NewConfirmOrderViewController *vc = nil;
            for (QWBaseVC *viewController in self.navigationController.viewControllers) {
                if ([viewController isKindOfClass:[NewConfirmOrderViewController class]]) {
                    vc = (NewConfirmOrderViewController *)viewController;
                    break;
                }
            }
            if (vc) {
                [self.navigationController popToViewController:vc animated:YES];
            }else {
                [self popVCAction:nil];
            }
        }else {
            [self popVCAction:nil];
        }
    } failure:^(HttpException *e) {
        
    }];
}

-(void)popVCAction:(id)sender {
    //这个block是用来通知H5地址页面刷新用的
    if (self.refresh) {
        self.refresh();
    }
    [super popVCAction:sender];
}

-(void)showMessageWith:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}
//删除地址
-(void)deleteAddress {
    DeleteAddressR *modelR = [DeleteAddressR new];
    modelR.id = self.vo.id;
    if (QWGLOBALMANAGER.loginStatus) {
        modelR.token = QWGLOBALMANAGER.configure.userToken;
    }
    [Address deleteAddress:modelR success:^(DeleteAddress *respons) {
        if ([respons.apiStatus integerValue] == 0) {
            [self popVCAction:nil];
        }else {
            [SVProgressHUD showErrorWithStatus:@"删除失败" duration:0.5];
            [self performSelector:@selector(popVCAction:) withObject:nil afterDelay:1];
        }
    } failure:^(HttpException *e) {
        
    }];
    
}
//选择小区/学校等
-(void)chooseLocation {
    SearchLocationViewController *vc = [[SearchLocationViewController alloc]init];
    vc.vo = _vo;
    vc.pagetype = _pageType;
    __weak typeof(self) weakSelf = self;
    vc.selectAddress = ^(UpdateAddressR *model){
        weakSelf.modelAdr.city = model.city;
        weakSelf.modelAdr.latitude = model.latitude;
        weakSelf.modelAdr.longitude = model.longitude;
        weakSelf.modelAdr.county = model.county;
        weakSelf.modelAdr.village = model.village;
        
        NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
        tdParams[@"地区"]=model.village;
        [QWGLOBALMANAGER statisticsEventId:@"x_tjdz_dq" withLable:@"添加地址" withParams:tdParams];
        [weakSelf.tableMain reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)showAlertView {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"您确定要删除收货地址吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    [alertView show];
}

#pragma mark - alertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self deleteAddress];
    }
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NewEditAddressCell *cell = [[NSBundle mainBundle] loadNibNamed:@"NewEditAddressCell" owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = 101;
        cell.nameTX.delegate = self;
        cell.telTX.delegate = self;
        cell.addressTX.delegate = self;
        [cell.chooseLocationBtn addTarget:self action:@selector(chooseLocation) forControlEvents:UIControlEventTouchUpInside];
        [cell setCell:self.modelAdr];
        return cell;
    }else {
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, APP_W/2, 44)];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = RGBHex(qwColor7);
        label.font = fontSystem(kFontS1);
        label.text = @"设为默认";
        
        UISwitch *sw = [[UISwitch alloc]initWithFrame:CGRectMake(APP_W - 15 - 50, 6, 50, 32)];
        sw.on = isDefault;
        [sw addTarget:self action:@selector(setDefaultAddress:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:sw];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(void)setDefaultAddress:(UISwitch *)sw {
    isDefault = sw.on;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 8)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }else {
        return 8.0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 350;
    }else {
        return 44;
    }
}

#pragma mark - uitextfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NewEditAddressCell *cell = (NewEditAddressCell *)[self.view viewWithTag:101];
    if (textField == cell.nameTX) {
        [cell.telTX becomeFirstResponder];
        return YES;
    }else if (textField == cell.telTX){
        
        return YES;
    }else {
        [self.view endEditing:YES];
        [UIView animateWithDuration:0.4 animations:^{
            self.tableMain.contentOffset = CGPointMake(0, 0);
        } completion:^(BOOL finished) {
            
        }];
        return YES;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NewEditAddressCell *cell = (NewEditAddressCell *)[self.view viewWithTag:101];
    if (textField == cell.addressTX ) {
        [UIView animateWithDuration:0.4 animations:^{
            self.tableMain.contentOffset = CGPointMake(0,100);
        } completion:^(BOOL finished) {
            
        }];
    }
    if(textField == cell.nameTX && _styleEdit == StyleAdd){
        [QWGLOBALMANAGER statisticsEventId:@"x_tjdz_xx" withLable:@"添加地址" withParams:nil];
    }else if (textField == cell.telTX && _styleEdit == StyleAdd){
        [QWGLOBALMANAGER statisticsEventId:@"x_tjdz_hm" withLable:@"添加地址" withParams:nil];
    }else if (textField == cell.addressTX && _styleEdit == StyleAdd){
        [QWGLOBALMANAGER statisticsEventId:@"x_tjdz_xxdz" withLable:@"添加地址" withParams:nil];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NewEditAddressCell *cell = (NewEditAddressCell *)[self.view viewWithTag:101];
    DebugLog(@"%@",string);
    if (textField != cell.telTX) {
        return YES;
    }else {
        if (range.location < 11) {
            NSString *number = @"^[0-9]*$";
            NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
            if ([regextestmobile evaluateWithObject:string] == YES) {
                return YES;
            }else {
                [self showError:@"请输入数字！"];
                [cell.telTX becomeFirstResponder];
                return NO;
            }
        }else {
            [self showError:@"只可输入11位手机号！"];
            [cell.addressTX becomeFirstResponder];
            return NO;
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - 通知
//从搜索地址tip带回来的地址信息
-(void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj {
    if (type == NotifAddressRefreshOne) {
        self.modelAdr.village = data[@"village"];
        self.modelAdr.county = data[@"district"];
        self.modelAdr.city = data[@"city"];
        self.modelAdr.latitude = data[@"latitude"];
        self.modelAdr.longitude = data[@"longitude"];
        [self.tableMain reloadData];
    }
}

@end