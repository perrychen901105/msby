//
//  ReciverAddressTableViewController.m
//  APP
//  更换地址页面  以及收获地址页面
//  Created by qw_imac on 15/12/30.
//  Copyright © 2015年 carret. All rights reserved.
//

#import "ReceiverAddressTableViewController.h"
#import "ReceiverAddressCell.h"
#import "AddOrChangeAddressInfoViewController.h"
#import "SearchAndChooseAddressViewController.h"
#import "Address.h"
#import "ReceiveAddressR.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"
#import "WebDirectViewController.h"
#import "NoAddrBKView.h"
#import "QWLocation.h"
@interface ReceiverAddressTableViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    MapInfoModel *mapInfo;
}
@property NSMutableArray    *dataSource;
@property NoAddrBKView      *bkView;
@end

@implementation ReceiverAddressTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [[NSMutableArray alloc]init];
    _bkView = [NoAddrBKView noAddressBkView];
    _bkView.frame = self.view.bounds;
    [self.view addSubview:_bkView];
    _bkView.hidden = YES;
    if(_pageType == PageComeFromHomePage || _pageType == PageComeFromStoreList || _pageType == PageComeFromSearch) {
        self.title = @"更换地址";
    }else {
        self.title = @"收货地址";
    }
    [self setupUI];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryData];
}

-(void)setupUI {
    self.tableMain =[[UITableView alloc] initWithFrame:CGRectMake(0, 0 , APP_W, [[UIScreen mainScreen] bounds].size.height - (QWGLOBALMANAGER.loginStatus?112:64)) style:UITableViewStylePlain];
    self.tableMain.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableMain.delegate = self;
    self.tableMain.dataSource = self;
    self.tableMain.backgroundColor = [UIColor clearColor];
    //从首页 药店列表和搜索进入的是更换地址 另外的是新增地址
    if (self.pageType != PageComeFromReceiveAddress && self.pageType != PageComeFromMall && self.pageType != PageComeFromH5) {
//        UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 88)];
//        headView.backgroundColor = RGBHex(qwColor10);
//        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(15, 5, APP_W-30 , 30)];
//        [btn addTarget:self action:@selector(searchAndChoose) forControlEvents:UIControlEventTouchUpInside];
//        UIView *bkview = [[UIView alloc]initWithFrame:CGRectMake(15, 7, APP_W - 30, 28)];
//        bkview.layer.cornerRadius = 4.0;
//        bkview.layer.masksToBounds = YES;
//        bkview.backgroundColor = [UIColor whiteColor];
//        float scale = APP_W /320;
//        
//        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(60*scale, 7, 15, 15)];
//        imgView.image = [UIImage imageNamed:@"icon_adr_search"];
//        
//        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, APP_W - 30 , 28)];
//        label1.text = @"     输入您想要查询的地址";
//        label1.textAlignment = NSTextAlignmentCenter;
//        label1.textColor = RGBHex(qwColor9);
//        label1.font = fontSystem(kFontS4);
//        [bkview addSubview:label1];
//        [bkview addSubview:imgView];
//        [headView addSubview:bkview];
//        [headView addSubview:btn];
//        
//        
//        UIView *locationView = [[UIView alloc]initWithFrame:CGRectMake(0,44, APP_W, 44)];
//        locationView.backgroundColor = [UIColor whiteColor];
//        UIButton *btn2 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, APP_W , 44)];
//        [btn2 addTarget:self action:@selector(relocation) forControlEvents:UIControlEventTouchUpInside];
//        
//        UIImageView *Img = [[UIImageView alloc]initWithFrame:CGRectMake(90* scale, 12, 20, 20)];
//        Img.image = [UIImage imageNamed:@"icon_address_positioning"];
//        [locationView addSubview:Img];
//        
//        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, APP_W , 44)];
//        label2.text = @"   定位到当前地址";
//        label2.textAlignment = NSTextAlignmentCenter;
//        label2.textColor = RGBHex(qwColor6);
//        label2.font = fontSystem(kFontS1);
//        [locationView addSubview:label2];
//        [locationView addSubview:btn2];
//        [headView addSubview:locationView];
//        self.tableMain.tableHeaderView = headView;
    }else {
        self.tableMain.tableHeaderView = nil;
    }
    [self.view addSubview:self.tableMain];
    //未登录不显示添加新地址按钮
    if (QWGLOBALMANAGER.loginStatus) {
//        float scale = APP_W / 320;
        UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 106, APP_W, 50)];
        footView.backgroundColor = RGBHex(qwColor4);
        
        UIButton *addBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,APP_W, 50)];
        [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        addBtn.backgroundColor = RGBHex(qwColor2);
        [addBtn setTitle:@" 添加新地址" forState:UIControlStateNormal];
        [addBtn setImage:[UIImage imageNamed:@"icon_add_personal"] forState:UIControlStateNormal];
        addBtn.titleLabel.font = fontSystem(kFontS3);
        addBtn.tintColor = RGBHex(qwColor4);
        [addBtn addTarget:self action:@selector(addAddress) forControlEvents:UIControlEventTouchUpInside];
        [footView addSubview:addBtn];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 0.5)];
        view.backgroundColor = RGBHex(qwColor10);
        [footView addSubview:view];
        
        [self.view addSubview:footView];
    }
}
-(void)popVCAction:(id)sender {
    if (self.refresh) {
        self.refresh();
    }
    [super popVCAction:sender];
}
//添加地址
-(void)addAddress {
    [QWGLOBALMANAGER statisticsEventId:@"我的_收货地址_添加新地址" withLable:nil withParams:nil];

    if (self.dataSource.count >= 5) {
        [self showAlertViewWithMessage:@"收货地址最多只能添加五个哦~" With:nil];
    }else {
        [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
            if ([mapInfoModel.city isEqualToString:@"苏州市"] && mapInfoModel.status == 1) {//定位不成功
                [self locationAlert];
            }else {
                AddOrChangeAddressInfoViewController *vc = [AddOrChangeAddressInfoViewController new];
                vc.isChange = NO;
                vc.styleEdit = StyleAdd;
                vc.pageType = _pageType;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
        //	点击添加新地址时需要判断用户是否已经有过定位地址。若是那种第一次启动app过后一直没有定位成功过的用户，点击时需弹出提示框：点击重新定位。定位成功后进入到添加收货地址页面，定位失败则继续弹出此框
    }
}

-(void)locationAlert {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"获取定位地址失败，暂时无法添加" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新定位", nil];
    alertView.tag = 101;
    [alertView show];
}
//修改地址
-(void)gotoChangeAddress:(UIButton *)sender {
    
    AddOrChangeAddressInfoViewController *vc = [AddOrChangeAddressInfoViewController new];
    vc.isChange = YES;
    vc.styleEdit = StyleEdit;
    vc.pageType = _pageType;
    vc.vo = self.dataSource[sender.tag];
    [self.navigationController pushViewController:vc animated:YES];
}

//输入想要查询的地址
-(void)searchAndChoose {
    SearchAndChooseAddressViewController *vc = [SearchAndChooseAddressViewController new];
    vc.pageType = self.pageType;
    [self.navigationController pushViewController:vc animated:YES];
}

////重新定位(点击上方重新定位按钮逻辑)
//-(void)relocation {
//    //将是否是手动设置为no
//    MapInfoModel *modified = [QWUserDefault getObjectBy:kModifiedCityModel];
//    if(modified) {
//        modified.manual = NO;
//        [QWUserDefault setObject:modified key:kModifiedCityModel];
//    }
//    [QWGLOBALMANAGER resetLocationInformation:^(MapInfoModel *mapInfoModel) {
//        if(mapInfoModel.locationStatus == LocationError){
//            [SVProgressHUD showErrorWithStatus:@"定位失败" duration:0.8];
//            return;
//        }
//        MapInfoModel *model = [QWUserDefault getObjectBy:kModifiedCityModel];
//        if ([model.city isEqualToString:mapInfoModel.city]) {
//            model.status = mapInfoModel.status;
//            [QWUserDefault setObject:mapInfoModel key:kModifiedCityModel];
//            [QWGLOBALMANAGER postNotif:NotifManualUpdateAddress data:nil object:nil];
//            [self popVCAction:nil];
//        }else {
//            [self showAlertViewWithMessage:@"只可更换当前城市下的地址" With:nil];
//        }
//        
//    }];
//}

-(void)showAlertViewWithMessage:(NSString *)message With:(id<UIAlertViewDelegate>)delegate{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:message delegate:delegate cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
    alertView.tag = 100;
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 100) {
        [self popVCAction:nil];
    }else {
        if (buttonIndex == 1) {//重新定位（首次定位未成功，添加地址需重新定位，成功之后才能添加地址，否则一直走这套逻辑）
            [QWGLOBALMANAGER readLocationWhetherReLocation:YES block:^(MapInfoModel *mapInfoModel) {
                if (![mapInfoModel.city isEqualToString:@"苏州市"] || mapInfoModel.status != 1) {//定位成功
                    AddOrChangeAddressInfoViewController *vc = [AddOrChangeAddressInfoViewController new];
                    vc.isChange = NO;
                    vc.styleEdit = StyleAdd;
                    [self.navigationController pushViewController:vc animated:YES];
                }else {
                    [self locationAlert];
                }
            }];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count > 5?5:self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReceiverAddressCell *cell = (ReceiverAddressCell *)[self.tableMain dequeueReusableCellWithIdentifier:@"ReceiverAddressCell"];
    
    if (!cell) {
        cell =[[NSBundle mainBundle] loadNibNamed:@"ReceiverAddressCell" owner:self options:nil][0];
    }
    AddressVo *address = self.dataSource[indexPath.row];
    [cell setCellWith:address];
    cell.changeBtn.tag = indexPath.row;
    [cell.changeBtn addTarget:self action:@selector(gotoChangeAddress:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AddressVo *addressModel = self.dataSource[indexPath.row];
    if (self.pageType == PageComeFromH5) {
        if ([addressModel.cityName isEqualToString:[QWGLOBALMANAGER getMapInfoModel].city]) {
            //判断选中地址与当前城市是否一致，一致重存本地地址并返给H5
            MapInfoModel *model = [MapInfoModel new];
            model.city = addressModel.cityName;
            model.id = addressModel.id;
            model.formattedAddress = [NSString stringWithFormat:@"%@%@",addressModel.village,addressModel.address];
            model.name = addressModel.nick;
            model.tel = addressModel.mobile;
            model.location = [[CLLocation alloc]initWithLatitude:[addressModel.lat floatValue] longitude:[addressModel.lng floatValue]];
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"lat"] = addressModel.lat;
            params[@"lng"] = addressModel.lng;
            params[@"address"] = addressModel.address;
            params[@"cityName"] = addressModel.cityName;
            params[@"countyName"] = addressModel.countyName;
            params[@"nick"] = addressModel.nick;
            params[@"mobile"] = addressModel.mobile;
            params[@"sex"] = addressModel.sex;
            params[@"id"] = addressModel.id;
            params[@"village"] = addressModel.village;
            
            if (self.extCallback) {
                NSString *jsonString = nil;
                NSError *error = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
                if([jsonData length] > 0 && error == nil) {
                    jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
                    self.extCallback(jsonString);
                }
            }
            [self popVCAction:nil];
        }
        else {
            //选中地址与当前城市不一致时，不让选！
            [self showAlertViewWithMessage:@"只可更换当前城市下的地址" With:nil];
            return;
        }
    } else {
        //页面类型为我的收货地址，进入编辑页面
        if (_pageType == PageComeFromReceiveAddress) {
            AddOrChangeAddressInfoViewController *vc = [AddOrChangeAddressInfoViewController new];
            vc.isChange = YES;
            vc.styleEdit = StyleEdit;
            vc.pageType = _pageType;
            vc.vo = self.dataSource[indexPath.row];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        //除了从确认订单过来的切换地址均需判断城市是否一致（订单地址可以选择其他城市）
        if(_pageType != PageComeFromMall){
            if ([addressModel.cityName isEqualToString:[QWGLOBALMANAGER QWGetLocation].city]) {//一致返回更新数据
                [self popVCAction:nil];
            }else {//不一致弹alert
                [self showAlertViewWithMessage:@"只可更换当前城市下的地址" With:self];
            }
        }else {
            //确认订单block地址信息
            if([addressModel.cityName rangeOfString:_branchCity].location !=NSNotFound){
                //选择地址跟药房城市一致
                if(self.chooseAddress) {
                    self.chooseAddress(addressModel);
                }
            }else {
                [SVProgressHUD showErrorWithStatus:@"收货地址所在城市与药房城市不一致！"];
                return;
            }
            [self popVCAction:nil];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(_pageType == PageComeFromHomePage || _pageType == PageComeFromStoreList || _pageType == PageComeFromSearch) {
        return 7.0;
    }else {
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 7.0)];
    bgView.backgroundColor = [UIColor clearColor];
    
    return bgView;
}
#pragma mark - networking
//请求地址列表
-(void)queryData {
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:kWarning12 duration:0.8];
        return;
    }
    ReceiveAddressR *modelR = [ReceiveAddressR new];
    if (QWGLOBALMANAGER.loginStatus) {
        modelR.token = QWGLOBALMANAGER.configure.userToken;
    }
    [Address receiveAddress:modelR success:^(ReceiveAddress *response) {
        if(response.address.count > 0){
            _bkView.hidden = YES;
            [_dataSource removeAllObjects];
            [_dataSource addObjectsFromArray:response.address];
        }else {
            [_dataSource removeAllObjects];
            _bkView.hidden = NO;
        }
        [self.tableMain reloadData];
    } failure:^(HttpException *e) {
    }];
}

@end