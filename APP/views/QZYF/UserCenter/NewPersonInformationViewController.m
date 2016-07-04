//
//  NewPersonInformationViewController.m
//  APP
//
//  Created by Martin.Liu on 15/12/7.
//  Copyright © 2015年 carret. All rights reserved.
//

#import "NewPersonInformationViewController.h"
#import "Mbr.h"
#import "MADateTextField.h"
#import "secondCustomAlertView.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "uploadFile.h"
#import "NSString+MarCategory.h"
#import "UserInfoModel.h"
#import "QWProgressHUD.h"
#import "SJAvatarBrowser.h"
#import "AppDelegate.h"
#import "Forum.h"
#import "ChangePhoneNumberViewController.h"
#define CENTERHEADER @"ic_my_pepole"

static const NSInteger PersonInforRowHeight = 45;
static const NSInteger TAG_PersonInfo_NickNameTF = 1001;
static const NSInteger TAG_PersonInfo_BirthDateTF = 1002;
static const NSInteger TAG_PersonInfo_EmailTF = 1003;
static const NSInteger NickNameMaxNumber = 15;

@interface NewPersonInformationViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *tableHeaderView;
@property (strong, nonatomic) IBOutlet UIView *tableViewHeaderBackView;

@property (strong, nonatomic) IBOutlet UIImageView *headPicImageView;

@property (nonatomic ,strong) secondCustomAlertView     *customAlertView;
@property (nonatomic, strong) mbrMemberInfo* userInfo;
- (IBAction)headPicAction:(id)sender;

- (void)saveAction:(id)sender;
@end

@implementation NewPersonInformationViewController
{
    NSArray* titleArray;
    UIButton* maleBtn;
    UIButton* femaleBtn;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    
    self.title = @"个人资料";
    titleArray = @[@"昵称", @"性别", @"出生日期", @"电子邮箱",@"绑定手机号"];
    
    // 点击图片预览行为  3.0.0 去掉该功能
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] init];
//    [tap addTarget:self action:@selector(imageViewClick:)];
//    self.headPicImageView.userInteractionEnabled = YES;
//    [self.headPicImageView addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)imageViewClick:(UITapGestureRecognizer*)sender{
    [SJAvatarBrowser showImage:(UIImageView*)sender.view];
}

- (void)UIGlobal
{
    self.view.backgroundColor = RGBHex(qwColor11);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveAction:)];
//    if ([APPDelegate isMainTab]) {
//        self.tableViewHeaderBackView.backgroundColor = RGBHex(qwColor3);
//    }
//    else
//        self.tableViewHeaderBackView.backgroundColor = RGBHex(qwColor1);
    self.tableView.tableHeaderView = self.tableHeaderView;
    self.headPicImageView.layer.masksToBounds = YES;
    self.headPicImageView.layer.cornerRadius = self.headPicImageView.frame.size.height/2;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.headPicImageView.image = [UIImage imageNamed:@"ic_my_pepole"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark 键盘推出，隐藏动作
- (void)keyboardWillShow:(NSNotification*)notification
{
        NSValue* keyRectVal = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
        CGRect keyFrame = [keyRectVal CGRectValue];
        UIEdgeInsets tableViewInsets = UIEdgeInsetsZero;
        tableViewInsets.bottom += keyFrame.size.height;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _tableView.contentInset = tableViewInsets;
        } completion:nil];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _tableView.contentInset = UIEdgeInsetsZero;
    } completion:nil];
    
}

-(void)loadData
{
    if(QWGLOBALMANAGER.currentNetWork != kNotReachable) {
        
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[@"token"] = StrFromObj(QWGLOBALMANAGER.configure.userToken);
        __weak __typeof(self) weakself = self;
        [Mbr queryMemberDetailWithParams:setting success:^(id DFUserModel) {
            
            mbrMemberInfo * info = DFUserModel;
            if([info.apiStatus integerValue] == 0){
                weakself.userInfo = info;
                QWGLOBALMANAGER.configure.sex = info.sex;
                QWGLOBALMANAGER.configure.nickName = info.nickName;
//                QWGLOBALMANAGER.configure.avatarUrl = info.headImageUrl;
                
                [self.tableView reloadData];
            }
            
        } failure:^(HttpException *e) {
            
        }];
    }
}

- (void)setUserInfo:(mbrMemberInfo *)userInfo
{
    _userInfo = userInfo;
    
    QWGLOBALMANAGER.configure.sex = userInfo.sex;
    QWGLOBALMANAGER.configure.nickName = _userInfo.nickName;
//    QWGLOBALMANAGER.configure.avatarUrl = _userInfo.headImageUrl;
    
    [self.headPicImageView setImageWithURL:[NSURL URLWithString:_userInfo.headImageUrl] placeholderImage:[UIImage imageNamed:CENTERHEADER] options:SDWebImageRetryFailed];
    
    [self.tableView reloadData];
    
}

#pragma mark UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PersonInforRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"personInfoTablecellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        for (UIView *viewSub in cell.contentView.subviews) {
            [viewSub removeFromSuperview];
        }
    }
    NSInteger row = indexPath.row;
    cell.textLabel.text = titleArray[row];
    cell.textLabel.font = [UIFont systemFontOfSize:kFontS1];
    cell.textLabel.textColor = RGBHex(qwColor6);
    
    [self makeAccessoryViewForCell:cell indexPath:indexPath];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0,PersonInforRowHeight -0.5, APP_W, 0.5)];
    [separator setBackgroundColor:RGBHex(qwColor10)];
    [cell addSubview:separator];
    return cell;
}

- (void)makeAccessoryViewForCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    CGFloat tfWidth = 150;
    switch (indexPath.row) {
            // 昵称
        case 0:
        {
            UITextField* nickNameTF = [[UITextField alloc] initWithFrame:CGRectMake(APP_W - 35 - 250, 0, 250, PersonInforRowHeight)];
            nickNameTF.textAlignment = NSTextAlignmentRight;
            nickNameTF.placeholder = @"请输入昵称";
            nickNameTF.tag = TAG_PersonInfo_NickNameTF;
            nickNameTF.text = self.userInfo.nickName;
            nickNameTF.delegate = self;
            nickNameTF.textColor=RGBHex(qwColor6);
            nickNameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
            [cell.contentView addSubview:nickNameTF];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [nickNameTF addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        }
            break;
            // 性别
        case 1:
        {
            maleBtn = [[UIButton alloc]initWithFrame:CGRectMake(APP_W - 95, 5, 60, 30)];
            maleBtn.tag = 0;
            [maleBtn setImage:[UIImage imageNamed:@"icon_male_data_rest"] forState:UIControlStateNormal];
            [maleBtn setImage:[UIImage imageNamed:@"icon_male_data_selected"] forState:UIControlStateSelected];
            [maleBtn addTarget:self action:@selector(changeSex:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:maleBtn];
            femaleBtn = [[UIButton alloc]initWithFrame:CGRectMake(APP_W - 165, 5, 60, 30)];
            femaleBtn.tag = 1;
            [femaleBtn setImage:[UIImage imageNamed:@"icon_female_data_rest"] forState:UIControlStateNormal];
            [femaleBtn setImage:[UIImage imageNamed:@"icon_female_data_selected"] forState:UIControlStateSelected];
            [femaleBtn addTarget:self action:@selector(changeSex:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:femaleBtn];
            
            if([self.userInfo.sex isEqualToString:@"0"]){
                maleBtn.selected = YES;
                femaleBtn.selected = NO;
            }else if([self.userInfo.sex isEqualToString:@"1"]){
                maleBtn.selected = NO;
                femaleBtn.selected = YES;
            }
        }
            break;
            // 出生日期
        case 2:
        {
            MADateTextField* dateTF = [[MADateTextField alloc] initWithFrame:CGRectMake(APP_W - 35- tfWidth, 0, tfWidth, PersonInforRowHeight)];
            dateTF.maximumDate = [NSDate new];
            dateTF.textAlignment = NSTextAlignmentRight;
            dateTF.placeholder = @"请选择出生年月";
            dateTF.text = self.userInfo.birthday;
            dateTF.tag = TAG_PersonInfo_BirthDateTF;
            dateTF.delegate = self;
            dateTF.textColor=RGBHex(qwColor6);
            [cell.contentView addSubview:dateTF];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            NSDate* date = [dateTF.dateFormatter dateFromString:self.userInfo.birthday];
            if (!date) {
                // 若没有生日日期，默认时间1985年10月1日
                date = [dateTF.dateFormatter dateFromString:@"1985-10-01"];
            }
            if (date) {
                dateTF.date = date;
            }
            else
            {
                dateTF.text = @"1985-10-01";
            }

            
        }
            break;
            // 电子邮箱
        case 3:
        {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            UITextField* emailTF = [[UITextField alloc] initWithFrame:CGRectMake(APP_W - 35 - tfWidth, 0, tfWidth, PersonInforRowHeight)];
            emailTF.textAlignment = NSTextAlignmentRight;
            emailTF.placeholder = @"请输入电子邮箱";
            emailTF.text = self.userInfo.email;
            emailTF.tag = TAG_PersonInfo_EmailTF;
            emailTF.delegate = self;
            emailTF.font = fontSystem(kFontS4);
            emailTF.textColor=RGBHex(qwColor6);
            emailTF.clearButtonMode = UITextFieldViewModeWhileEditing;
            [cell.contentView addSubview:emailTF];
        }
            break;
        case 4:
        {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            UIButton *telBtn = [[UIButton alloc]initWithFrame:CGRectMake(APP_W - 20 - 150, 0, 150, 44)];
            if (!StrIsEmpty(self.userInfo.mobile)) {
                telBtn.frame = CGRectMake(APP_W - 30 - 100, 0, 100, 44);
                [telBtn setTitle:self.userInfo.mobile forState:UIControlStateNormal];
                [telBtn setTitleColor:RGBHex(qwColor6) forState:UIControlStateNormal];
            }else {
                [telBtn setTitle:@"绑定手机号送50积分" forState:UIControlStateNormal];
                [telBtn setTitleColor:RGBHex(qwColor8) forState:UIControlStateNormal];
            }
            telBtn.titleLabel.textAlignment = NSTextAlignmentRight;
            telBtn.titleLabel.font = fontSystem(kFontS4);
            [telBtn addTarget:self action:@selector(gotoBindOrChangePhone) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:telBtn];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITextFeild delegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == TAG_PersonInfo_NickNameTF) {
        self.userInfo.nickName = textField.text;
    }
    else if (textField.tag == TAG_PersonInfo_BirthDateTF) {
        self.userInfo.birthday = textField.text;
    }
    else if (textField.tag == TAG_PersonInfo_EmailTF)
    {
        self.userInfo.email = textField.text;
    }
}

#pragma mark UITextField textchanged event
- (void)textFieldChanged:(UITextField*)textField
{
    // 昵称超过30个字符自动截取前30个字符
    if (textField.tag == TAG_PersonInfo_NickNameTF) {
        if (textField.text.length > NickNameMaxNumber) {
            textField.text = [textField.text substringToIndex:NickNameMaxNumber];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0) {
        return YES;
    }
    DDLogVerbose(@"textfield test : %@", textField.text);
    if (textField.tag == TAG_PersonInfo_NickNameTF) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8) {
            if (textField.text.length + string.length >= NickNameMaxNumber) {
                return NO;
            }
        }
        else if (textField.text.length >= NickNameMaxNumber) {
            return NO;
        }
    }
    return YES;
}

- (void)resignTFS
{
    [self becomeFirstResponder];
}

#pragma mark - 更改昵称HTTP请求
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    
    if (buttonIndex == 0) {
        //取消
        return;
    }else if (buttonIndex == 1){
        
        //确定
        // 昵称为空的时候不能提交
        [QWGLOBALMANAGER replaceSpecialStringWith:self.customAlertView.textField.text];
        //两边去空后进行判断
        NSString *str= [self.customAlertView.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (StrIsEmpty(str)) {
            [SVProgressHUD showErrorWithStatus:@"请输入昵称" duration:DURATION_SHORT];
            return;
        }
        
        //中间不去空  ---changeby  cj
        //        NSString *strUserName = self.customAlertView.textField.text;
        //        strUserName = [strUserName stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (str.length <= 30 ) {
            
            NSMutableDictionary * setting = [NSMutableDictionary dictionary];
            
            setting[@"token"] = QWGLOBALMANAGER.configure.userToken;
            setting[@"nickName"] = str;
            
            [[HttpClient sharedInstance]put:NW_saveMemberInfo params:setting success:^(id responseObj) {
                
                BaseAPIModel *model = [BaseAPIModel parse:responseObj];
                if([model.apiStatus intValue] == 0){
                    [SVProgressHUD showSuccessWithStatus:@"设置昵称成功" duration:DURATION_SHORT];
                    [self loadData];
                    [self.tableView reloadData];
                }else{
                    [SVProgressHUD showErrorWithStatus:model.apiMessage duration:DURATION_SHORT];
                }
            } failure:^(HttpException *e) {
                [SVProgressHUD showErrorWithStatus:e.Edescription duration:DURATION_SHORT];
            }];
            
        }else{
            if (str.length > 30) {
                [SVProgressHUD showErrorWithStatus:@"设置昵称失败,昵称长度不能超过三十个字符" duration:DURATION_LONG];
            }
            
            return;
        }
    }
}

#pragma mark - 更改性别HTTP请求
- (void)changeSex:(UIButton *)button{
    
//    if([QWGLOBALMANAGER.configure.sex integerValue] == button.tag){
//        return;
//    }
    if([button isEqual:maleBtn]){
        maleBtn.selected = !maleBtn.selected;
        femaleBtn.selected = NO;
    }else{
        maleBtn.selected = NO;
        femaleBtn.selected = !femaleBtn.selected;
    }

    if (button.tag == 0) {
        self.userInfo.sex = @"0";
    } else {
        self.userInfo.sex = @"1";
    }
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

- (IBAction)headPicAction:(id)sender {
    //设置头像
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照设置头像", @"从相册选择头像", nil];
    actionSheet.tag = 100;
    [self.view endEditing:YES];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag == 100) {//设置头像
        UIImagePickerControllerSourceType sourceType;
        if (buttonIndex == 0) {
            //拍照
            sourceType = UIImagePickerControllerSourceTypeCamera;
        }else if (buttonIndex == 1){
            //相册
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }else if (buttonIndex == 2){
            //取消
            return;
        }
        if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"Sorry,您的设备不支持该功能!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
        
    }
}

#pragma mark 绑定或者修改手机号码
- (void) gotoBindOrChangePhone
{
    if (StrIsEmpty(QWGLOBALMANAGER.configure.mobile)) {
        [QWGLOBALMANAGER statisticsEventId:@"个人资料_绑定手机号" withLable:@"个人资料_绑定手机号" withParams:nil];
        // 绑定手机号
        ChangePhoneNumberViewController * changeNumber = [[ChangePhoneNumberViewController alloc] initWithNibName:@"ChangePhoneNumberViewController" bundle:nil];
        changeNumber.changePhoneType = ChangePhoneType_BindPhoneNumber;
        changeNumber.hidesBottomBarWhenPushed = YES;
        changeNumber.isFromeSetting = YES;
        [self.navigationController pushViewController:changeNumber animated:YES];
    }
    else
    {
        // 修改手机号
        ChangePhoneNumberViewController * changeNumber = [[ChangePhoneNumberViewController alloc] initWithNibName:@"ChangePhoneNumberViewController" bundle:nil];
        changeNumber.hidesBottomBarWhenPushed = YES;
        changeNumber.changePhoneType = ChangePhoneType_ChangePhoneNumber;
        changeNumber.isFromeSetting = YES;
        [self.navigationController pushViewController:changeNumber animated:YES];
        // 修改手机号 提示actionsheet
        //        UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"修改手机号?", nil];
        //        [actionSheet showInView:self.view];
    }
}


#pragma mark - UIImagePicker回调上传图片请求
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    /**
     *1.通过相册和相机获取的图片都在此代理中
     *
     *2.图片选择已完成,在此处选择传送至服务器
     */
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        [picker dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    CGRect bounds = CGRectMake(0, 0, APP_W, APP_W);
    UIGraphicsBeginImageContext(bounds.size);
    [image drawInRect:bounds];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //    UIImageView * imageView = (UIImageView *)[self.view viewWithTag:9999];
    //imageView.image = image;
    if (image) {
        
        NSData * imageData = UIImageJPEGRepresentation(image, 0.5);
        
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[@"token"] = QWGLOBALMANAGER.configure.userToken;
        setting[@"type"] = @(1);
        
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:imageData];
        
        [[HttpClient sharedInstance]uploaderImg:array params:setting withUrl:NW_uploadFile success:^(id responseObj) {
            
            uploadFile *file = [uploadFile parse:responseObj];
            
            if([file.apiStatus intValue] == 0){
                [self changeImageUrl:file.url];
            }else{
                [SVProgressHUD showSuccessWithStatus:file.apiMessage duration:DURATION_LONG];
            }
            
        } failure:^(HttpException *e) {
            
            DDLogVerbose(@"%@",e.description);
            [SVProgressHUD showSuccessWithStatus:@"图片上传失败!" duration:DURATION_SHORT];
            
        } uploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            
            DDLogVerbose(@"进度条====>>>%d,%lld,%lld",bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
        }];
        
        
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeImageUrl:(NSString *)url{
    
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    
    setting[@"token"] = QWGLOBALMANAGER.configure.userToken;
    setting[@"headImageUrl"] = url;
    
    [[HttpClient sharedInstance]put:NW_saveMemberInfo params:setting success:^(id responseObj) {
        BaseAPIModel *model = [BaseAPIModel parse:responseObj];
        if([model.apiStatus intValue] == 0){
            [SVProgressHUD showSuccessWithStatus:@"头像更换成功！" duration:DURATION_SHORT];
            QWGLOBALMANAGER.configure.avatarUrl = url;
            [self loadData];
            [QWGLOBALMANAGER postNotif:NotifDidModifyUserInfo data:nil object:nil];
        }else{
            [SVProgressHUD showSuccessWithStatus:model.apiMessage duration:DURATION_SHORT];
        }
    } failure:^(HttpException *e) {
        [SVProgressHUD showSuccessWithStatus:@"头像更换失败！" duration:DURATION_SHORT];
        DDLogVerbose(@"%@",e.description);
        
    }];
}


- (void)saveAction:(id)sender {
    [self.view endEditing:YES];
//    if (StrIsEmpty(self.userInfo.birthday)) {
//        [SVProgressHUD showErrorWithStatus:@"请选择出生年月" duration:DURATION_SHORT];
//        return;
//    }
//    if (StrIsEmpty(self.userInfo.email)) {
//        [SVProgressHUD showErrorWithStatus:@"请输入电子邮箱" duration:DURATION_SHORT];
//        return;
//    }
    
    
    if (StrIsEmpty([self.userInfo.nickName mar_trim])) {
        [SVProgressHUD showErrorWithStatus:@"请输入昵称" duration:DURATION_SHORT];
        return;
    }
    
    if (self.userInfo.nickName.length > 30) {
        [SVProgressHUD showErrorWithStatus:@"设置昵称失败,昵称长度不能超过三十个字符" duration:DURATION_LONG];
        return;
    }
    
    if (!StrIsEmpty(self.userInfo.email) && ![QWGLOBALMANAGER isEmailAddress:self.userInfo.email]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确地电子邮箱格式" duration:DURATION_LONG];
        return;
    }
    
    if (self.userInfo.email.length > 30) {
        [SVProgressHUD showErrorWithStatus:@"设置电子邮箱失败,邮箱长度不能超过三十个字符" duration:DURATION_LONG];
        return;
    }
    
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    
    setting[@"token"] = QWGLOBALMANAGER.configure.userToken;
    if (!StrIsEmpty(self.userInfo.nickName)) {
        setting[@"nickName"] = self.userInfo.nickName;
    }
    
    if (!StrIsEmpty(self.userInfo.sex)) {
        setting[@"sex"] = self.userInfo.sex;
    }

    if (!StrIsEmpty(self.userInfo.birthday)) {
        setting[@"birthday"] = self.userInfo.birthday;
    }
    else
    {
        setting[@"birthday"] = @"1985-10-01";
    }
    
    if (!StrIsEmpty(self.userInfo.email)) {
        setting[@"email"] = self.userInfo.email;
    }
    else
    {
        setting[@"email"] = @"";
    }
    
    __weak __typeof(self) weakSelf = self;
    [[HttpClient sharedInstance]put:NW_saveMemberInfo params:setting success:^(id responseObj) {
        SaveMemberInfo* model = [SaveMemberInfo parse:responseObj];
        if([model.apiStatus intValue] == 0){
            if (model.taskChanged) {
                [QWProgressHUD showSuccessWithStatus:@"完善资料" hintString:[NSString stringWithFormat:@"+%ld", [QWGLOBALMANAGER rewardScoreWithTaskKey:@"FULL"]] duration:DURATION_CREDITREWORD];
            }
            else
            {
                [SVProgressHUD showSuccessWithStatus:@"保存成功" duration:DURATION_LONG];
            }
            QWGLOBALMANAGER.configure.sex = weakSelf.userInfo.sex;
            QWGLOBALMANAGER.configure.nickName = weakSelf.userInfo.nickName;
            [self.navigationController popViewControllerAnimated:YES];
            [QWGLOBALMANAGER postNotif:NotifDidModifyUserInfo data:nil object:nil];
//            [self loadData];
//            [self.tableView reloadData];
        }else{
            [SVProgressHUD showErrorWithStatus:model.apiMessage duration:DURATION_SHORT];
        }
    } failure:^(HttpException *e) {
        [SVProgressHUD showErrorWithStatus:e.Edescription duration:DURATION_SHORT];
    }];
    
//    UpDateMbrInfoR* mbrInfoR = [UpDateMbrInfoR new];
//    mbrInfoR.token = QWGLOBALMANAGER.configure.userToken;
//    mbrInfoR.name = self.userInfo.nickName;
//    mbrInfoR.headImageUrl = self.userInfo.headImageUrl;
//    mbrInfoR.status = @"-1";
//    [Forum updateMbrInfo:mbrInfoR success:^(BaseAPIModel *baseAPIModel) {
//        DebugLog(@"new update mbr info : %@", baseAPIModel);
//    } failure:^(HttpException *e) {
//        ;
//    }];

}

#pragma mark UIScrollView Delegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (scrollView.contentOffset.y < 0) {
//        CGFloat scale = (self.tableHeaderView.frame.size.height - scrollView.contentOffset.y)/self.tableHeaderView.frame.size.height;
//        scale = scale > 1.2 ? 1.2 : scale;
//        self.headPicImageView.transform = CGAffineTransformMakeScale(scale, scale);
//    }
//}

@end
