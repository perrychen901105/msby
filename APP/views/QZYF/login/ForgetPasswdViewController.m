
#import "ForgetPasswdViewController.h"
#import "SVProgressHUD.h"
#import "HttpClient.h"
#import "ZhPMethod.h"
#import "LoginViewController.h"
#import "Mbr.h"
/**
 *  未处理的对象
 */

@interface ForgetPasswdViewController ()
{
    NSTimer *_reGetVerifyTimer;
}

@property (strong, nonatomic) IBOutlet UIView *phoneNumberContainerView;
@property (strong, nonatomic) IBOutlet UIView *verificationCodeContainerView;
@property (strong, nonatomic) IBOutlet UIView *passwordContainerView;

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeField;
@property (weak, nonatomic) IBOutlet UITextField *passwdField;
@property (weak, nonatomic) IBOutlet UIButton *verificationCodeButton;
@property (weak, nonatomic) IBOutlet UILabel *verificationCodeLabel;
@property (strong, nonatomic) NSTimer *reGetVerifyTimer;

@property (strong, nonatomic) IBOutlet UIButton *commitBtn;
@property (strong, nonatomic) IBOutlet UILabel *tipLabel;
@property (strong, nonatomic) IBOutlet UIButton *phoneBtn;
@property (strong, nonatomic) IBOutlet UIView *underLineView;



- (IBAction)verificationCodeButtonClick:(id)sender;
- (IBAction)commitButtonClick:(id)sender;
- (IBAction)phonButtonClick:(id)sender;

@end

@implementation ForgetPasswdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)UIGlobal
{
    self.view.backgroundColor = RGBHex(qwColor11);
    
    UIColor* borderColor = RGBHex(qwColor10);
    CGFloat cornerRadius = 4;
    CGFloat borderWidth = 1.f / [[UIScreen mainScreen] scale];
    
    // 边框样式
    self.phoneNumberContainerView.layer.masksToBounds = YES;
    self.phoneNumberContainerView.layer.cornerRadius = cornerRadius;
    self.phoneNumberContainerView.layer.borderWidth = borderWidth;
    self.phoneNumberContainerView.layer.borderColor = borderColor.CGColor;
    
    self.verificationCodeContainerView.layer.masksToBounds = YES;
    self.verificationCodeContainerView.layer.cornerRadius = cornerRadius;
    self.verificationCodeContainerView.layer.borderWidth = borderWidth;
    self.verificationCodeContainerView.layer.borderColor = borderColor.CGColor;
    
    self.passwordContainerView.layer.masksToBounds = YES;
    self.passwordContainerView.layer.cornerRadius = cornerRadius;
    self.passwordContainerView.layer.borderWidth = borderWidth;
    self.passwordContainerView.layer.borderColor = borderColor.CGColor;
    
    // 背景色
    self.commitBtn.backgroundColor = RGBHex(qwColor2);
    self.commitBtn.layer.masksToBounds = YES;
    self.commitBtn.layer.cornerRadius = 4;
    
    // 文字颜色 文字大小
    [self.verificationCodeButton setTitleColor:RGBHex(qwColor4) forState:UIControlStateNormal];
    [self.verificationCodeButton.titleLabel setFont:[UIFont systemFontOfSize:kFontS4]];
    
    self.phoneNumberField.font = [UIFont systemFontOfSize:kFontS1];
    self.phoneNumberField.textColor = RGBHex(qwColor6);
    
    self.verificationCodeField.font = [UIFont systemFontOfSize:kFontS1];
    self.verificationCodeField.textColor = RGBHex(qwColor6);
    
    self.passwdField.font = [UIFont systemFontOfSize:kFontS1];
    self.passwdField.textColor = RGBHex(qwColor6);
    
    [self.tipLabel setFont:[UIFont systemFontOfSize:kFontS4]];
    self.tipLabel.textColor = RGBHex(qwColor8);
    
    [self.phoneBtn.titleLabel setFont:[UIFont systemFontOfSize:kFontS4]];
    [self.phoneBtn setTitleColor:RGBHex(qwColor5) forState:UIControlStateNormal];
    self.underLineView.backgroundColor = RGBHex(qwColor5);
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(QWGLOBALMANAGER.getForgetPasswordTimer) {
        NSMutableDictionary *userInfo = QWGLOBALMANAGER.getForgetPasswordTimer.userInfo;
        NSInteger countDonw = [userInfo[@"countDown"] integerValue];
        [self.verificationCodeButton setBackgroundColor:[UIColor lightGrayColor]];
        self.verificationCodeButton.enabled = NO;
        [self.verificationCodeButton setTitle:[NSString stringWithFormat:@"%d秒后重试",countDonw] forState:UIControlStateDisabled];
        self.verificationCodeButton.backgroundColor = RGBHex(qwColor9);
//        self.verificationCodeLabel.text = [NSString stringWithFormat:@"%d秒后重试",countDonw];
    }else{
        self.verificationCodeButton.enabled = YES;
        [self.verificationCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.verificationCodeButton setBackgroundColor:RGBHex(qwColor1)];
//        self.verificationCodeLabel.text = @"获取验证码";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"重置密码";
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    self.verificationCodeButton.layer.masksToBounds =YES;
    self.verificationCodeButton.layer.cornerRadius = 5.0f;
    self.passwdField.secureTextEntry = YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*小提示:
 ChangePasswordViewController 代表忘记密码
 
 ForgetPasswordViewController 代表修改密码
 */

//当获取验证码按钮被点击时
- (IBAction)verificationCodeButtonClick:(id)sender {
    
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }

    if (self.phoneNumberField.text.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"手机号不能为空" duration:1];
    }else if ((self.phoneNumberField.text.length > 0 && self.phoneNumberField.text.length < 11)||self.phoneNumberField.text.length > 11)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号" duration:1];
    }else if (self.phoneNumberField.text.length == 11)
    {
        if (isPhoneNumber(self.phoneNumberField.text))//如果是手机号
        {
            //校验手机号是否注册过
            [Mbr registerValidWithParams:@{@"mobile":self.phoneNumberField.text} success:^(id DFUserModel) {
                BaseAPIModel *model = [BaseAPIModel parse:DFUserModel];
                
                //change by yang
                
                if ([model.apiStatus integerValue] == 2) {
                    [QWGLOBALMANAGER startForgetPasswordVerifyCode:self.phoneNumberField.text];
                }else
                {
                    [SVProgressHUD showErrorWithStatus:@"手机号未注册" duration:DURATION_SHORT];
                }
            } failure:^(HttpException *e) {
                
            }];
            
        }else
        {
            [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号" duration:1];
        }
    }

    
}
//计时器执行方法
- (void)reGetVerifyCodeControl:(NSInteger)count
{
    if (count == 0) {
        self.verificationCodeButton.enabled = YES;
        [self.verificationCodeButton setBackgroundColor:RGBHex(qwColor1)];
        self.verificationCodeLabel.text = @"获取验证码";
        self.verificationCodeButton.enabled = YES;
    }else{
        self.verificationCodeButton.enabled = NO;
        [self.verificationCodeButton setBackgroundColor:RGBHex(qwColor9)];
        [self.verificationCodeButton setTitle:[NSString stringWithFormat:@"%d秒后重试",count] forState:UIControlStateDisabled];
//        self.verificationCodeLabel.text = [NSString stringWithFormat:@"%d秒后重试",count];
    }
}

- (IBAction)commitButtonClick:(id)sender
{
    
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    
    if (self.phoneNumberField.text.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号" duration:1];
    }else if ((self.phoneNumberField.text.length > 0 && self.phoneNumberField.text.length < 11)||self.phoneNumberField.text.length > 11)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号" duration:1];
    }else if (self.phoneNumberField.text.length == 11)
    {
        if (isPhoneNumber(self.phoneNumberField.text))//如果是手机号
        {
            if (self.verificationCodeField.text.length == 0) {
                [SVProgressHUD showErrorWithStatus:@"请输入验证码" duration:DURATION_SHORT];
            }else{
                if (self.passwdField.text.length >= 6 && self.passwdField.text.length < 16){
                    //开始重置密码
                    //                   校验密码是否含有特殊字符
                    NSCharacterSet *nameCharacters = [[NSCharacterSet
                                                       characterSetWithCharactersInString:@"_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
                    NSRange userNameRange = [self.passwdField.text rangeOfCharacterFromSet:nameCharacters];
                    if (userNameRange.length == 1) {
                        [SVProgressHUD showErrorWithStatus:@"请设置新密码，6~16位数字或字母" duration:DURATION_SHORT];
                        return;
                    }else{
                        if ([@"123456" isEqualToString:self.passwdField.text]) {
                            [SVProgressHUD showErrorWithStatus:kWarning30001];
                            return;
                        }
                        [self resetPassword];
                        
                    }
                }else if (self.passwdField.text.length == 0)
                {
                    [SVProgressHUD showErrorWithStatus:@"请输入新密码" duration:DURATION_SHORT];
                }else if (self.passwdField.text.length > 0 && self.passwdField.text.length < 6)
                {
                    [SVProgressHUD showErrorWithStatus:@"密码长度应大于六位" duration:DURATION_SHORT];
                }else if (self.passwdField.text.length > 16){
                    [SVProgressHUD showErrorWithStatus:@"密码长度应小于十六位" duration:DURATION_SHORT];
                }
            }
            
        }else
        {
            [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号" duration:1];
        }
    }

}

- (IBAction)phonButtonClick:(id)sender {
    NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", @"051287661737"]];
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:kWarning22302 duration:DURATION_SHORT];
    }
}

- (void)resetPassword{
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"mobile"] = self.phoneNumberField.text;
    setting[@"code"] = self.verificationCodeField.text;
    setting[@"newPwd"] = self.passwdField.text;
    setting[@"newCredentials"]=[AESUtil encryptAESData:self.passwdField.text app_key:AES_KEY];
    [[HttpClient sharedInstance]put:NW_resetPassword params:setting success:^(id responseObj) {
        
        BaseAPIModel *model = [BaseAPIModel parse:responseObj];
        
        if([model.apiStatus intValue] == 0){
            // 重置获取验证码倒计时
            [QWGLOBALMANAGER.getForgetPasswordTimer invalidate];
            QWGLOBALMANAGER.getForgetPasswordTimer = nil;
            [SVProgressHUD showSuccessWithStatus:@"密码修改成功" duration:DURATION_SHORT];
            
            [self.navigationController popViewControllerAnimated:YES];
//            LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bun dle:nil];
//            UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
//            loginViewController.isPresentType = YES;
//            [QWGLOBALMANAGER.tabBar.tabBarController presentViewController:navgationController animated:YES completion:NULL];
        }else{
            [SVProgressHUD showErrorWithStatus:model.apiMessage duration:DURATION_SHORT];
        }
        
    } failure:^(HttpException *e) {

        [SVProgressHUD showErrorWithStatus:e.Edescription duration:DURATION_SHORT];
    }];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.phoneNumberField resignFirstResponder];
    [self.verificationCodeField resignFirstResponder];
    [self.passwdField resignFirstResponder];
}

- (void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj
{
    if(type == NotiCountDonwForgetPassword) {
        [self reGetVerifyCodeControl:[data integerValue]];
    }
}

@end
