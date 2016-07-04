//
//  SetPasswordViewController.m
//  APP
//
//  Created by Martin.Liu on 15/11/12.
//  Copyright © 2015年 carret. All rights reserved.
//

#import "SetPasswordViewController.h"
#import "SVProgressHUD.h"
#import "Mbr.h"
@interface SetPasswordViewController ()
@property (strong, nonatomic) IBOutlet UIView *passwordContainerView;
@property (strong, nonatomic) IBOutlet UITextField *passwordTF;
@property (strong, nonatomic) IBOutlet UIButton *submitBtn;
- (IBAction)passwordVisibleClick:(UIButton *)sender;
- (IBAction)submitClick:(id)sender;

@end

@implementation SetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置登陆密码";
    self.view.backgroundColor = RGBHex(qwColor11);
    self.submitBtn.enabled = NO;
    // 密码文本框绑定监听文本改变事件来控制提交按钮的样式和交互
    [self.passwordTF addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self.passwordTF becomeFirstResponder];
}

- (void)UIGlobal
{
    self.passwordContainerView.layer.masksToBounds = YES;
    self.passwordContainerView.layer.borderColor = RGBHex(qwColor10).CGColor;
    self.passwordContainerView.layer.borderWidth = 1.f/[[UIScreen mainScreen] scale];
    self.passwordContainerView.layer.cornerRadius = 4;
    
    self.submitBtn.layer.masksToBounds = YES;
    self.submitBtn.layer.cornerRadius = 4;
    self.submitBtn.backgroundColor = RGBHex(qwColor9);
    [self.submitBtn setTitleColor:RGBHex(qwColor4) forState:UIControlStateNormal];

}

- (void)textFieldChanged:(UITextField*)textField
{
    if (textField == self.passwordTF) {
        // 密码需要6-16个数字或字母
        if (self.passwordTF.text.length >= 6 && self.passwordTF.text.length <= 16) {
            if (!self.submitBtn.enabled) {
                self.submitBtn.enabled = YES;
                [UIView animateWithDuration:0.3 animations:^{
                    self.submitBtn.backgroundColor = RGBHex(qwColor2);
                }];
            }
        }
        else
        {
            if (self.submitBtn.enabled) {
                self.submitBtn.enabled = NO;
                [UIView animateWithDuration:0.3 animations:^{
                    self.submitBtn.backgroundColor = RGBHex(qwColor9);
                }];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)passwordVisibleClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.passwordTF.secureTextEntry = !sender.selected;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.passwordTF resignFirstResponder];
}

- (IBAction)submitClick:(id)sender {
    if (self.passwordTF.text.length >= 6 && self.passwordTF.text.length <=16) {
        if ([@"123456" isEqualToString:self.passwordTF.text]) {
            [SVProgressHUD showErrorWithStatus:kWarning30001];
            return;
        }
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[@"token"] = QWGLOBALMANAGER.configure.userToken;
        param[@"newPwd"] = self.passwordTF.text;
//        param[@"oldCredentials"]=[AESUtil encryptAESData:@"123456" app_key:AES_KEY];
        param[@"newCredentials"]=[AESUtil encryptAESData:self.passwordTF.text app_key:AES_KEY];
        [Mbr updatePasswordWithParams:param
                              success:^(id resultObj){
                                  
                                  BaseAPIModel *model = (BaseAPIModel *)resultObj;
                                  
                                  if([model.apiStatus intValue] == 0){

                                      [QWUserDefault setString:self.passwordTF.text key:APP_PASSWORD_KEY];
                                      QWGLOBALMANAGER.configure.passWord = self.passwordTF.text;
                                      QWGLOBALMANAGER.configure.setPwd = YES;
                                      [QWGLOBALMANAGER saveAppConfigure];
                                      [SVProgressHUD showSuccessWithStatus:@"设置成功" duration:DURATION_SHORT];
                                      [self.navigationController popViewControllerAnimated:YES];
                                  }else{
                                      [SVProgressHUD showErrorWithStatus:model.apiMessage duration:DURATION_SHORT];
                                      
                                  }
                                  
                              }
                              failure:^(HttpException *e){
                                  [SVProgressHUD showErrorWithStatus:e.Edescription duration:DURATION_SHORT];
                              }];
        
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"请输入6-16位数字或字母密码"];
    }
}
@end
