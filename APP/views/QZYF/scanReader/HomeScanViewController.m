//
//  HomeScanViewController.m
//  APP
//
//  Created by 李坚 on 16/6/24.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "HomeScanViewController.h"

#import "WebDirectViewController.h"
#import "MallScanDrugViewController.h"
#import "QYPhotoAlbum.h"

@interface HomeScanViewController ()
{
    IOSScanView *   iosScanView;
    NSTimer* timer;
}

@end

@implementation HomeScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.readerView setBackgroundColor:[UIColor clearColor]];
    
    self.title = @"扫一扫";
    
    //默认关闭闪光灯
    self.torchMode = NO;
    
    iosScanView = [[IOSScanView alloc] initWithFrame:CGRectMake(0, 0, APP_W, APP_H)];
    iosScanView.delegate = self;
    [self.view addSubview:iosScanView];
    
    [self setupTorchBarButton];
    [self setupDynamicScanFrame];
    [self configureReadView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![QYPhotoAlbum checkCameraAuthorizationStatus]) {
        return;
    }
    
    if (iosScanView) {
        [iosScanView startRunning];
    }
    
    ((QWBaseNavigationController *)self.navigationController).canDragBack = NO;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
    if (iosScanView) {
        [iosScanView stopRunning];
    }
    
    ((QWBaseNavigationController *)self.navigationController).canDragBack = YES;
}

#pragma mark -
#pragma mark  初始化界面布局

- (void)configureReadView
{
    UILabel *desrciption = [[UILabel alloc] initWithFrame:CGRectMake(0,0, APP_W, 14)];
    CGPoint point = CGPointMake(APP_W/2, 441);
    desrciption.center = point;
    desrciption.textColor = RGBHex(qwColor4);
    desrciption.font = fontSystem(kFontS4);
    desrciption.textAlignment = NSTextAlignmentCenter;
    desrciption.text = @"将药品条形码/二维码放到框内,即可自动扫描";
    [self.view addSubview:desrciption];
}

- (void)setupDynamicScanFrame
{
    float backalpha = 0.4;
    
    CGFloat scanWidth = 295;
    
    //左半透明View
    CGRect viewRect1 = CGRectMake(0,0, (APP_W - scanWidth )/ 2, APP_H);
    UIView* view1 = [[UIView alloc] initWithFrame:viewRect1];
    [view1 setBackgroundColor:[UIColor blackColor]];
    view1.alpha = backalpha;
    [self.view addSubview:view1];
    
    //上半透明View
    CGRect viewRect2 = CGRectMake((APP_W - scanWidth )/ 2,0, scanWidth, 75);
    UIView* view2 = [[UIView alloc] initWithFrame:viewRect2];
    [view2 setBackgroundColor:[UIColor blackColor]];
    view2.alpha = backalpha;
    [self.view addSubview:view2];
    
    //右半透明View
    CGRect viewRect3 = CGRectMake((APP_W + scanWidth )/2,0, (APP_W - scanWidth )/ 2, APP_H);
    UIView* view3 = [[UIView alloc] initWithFrame:viewRect3];
    [view3 setBackgroundColor:[UIColor blackColor]];
    view3.alpha = backalpha;
    [self.view addSubview:view3];
    
    //下半透明View
    CGRect viewRect4 = CGRectMake((APP_W - scanWidth )/ 2,370, scanWidth, (APP_H-370));
    UIView* view4 = [[UIView alloc] initWithFrame:viewRect4];
    [view4 setBackgroundColor:[UIColor blackColor]];
    view4.alpha = backalpha;
    [self.view addSubview:view4];
    
    //取景框
    CGRect scanMaskRect = CGRectMake((APP_W - scanWidth )/ 2 - 7.0f,68, scanWidth + 14.0f, scanWidth + 14.0f);
    UIImageView *scanImage = [[UIImageView alloc] initWithFrame:scanMaskRect];
    [scanImage setImage:[UIImage imageNamed:@"line_normal"]];
    [self.view addSubview:scanImage];
    
    //上下移动的线条
    UIImageView *scanLineImage = [[UIImageView alloc] initWithFrame:CGRectMake((APP_W - scanWidth)/ 2,75, scanWidth, 6)];
    [scanLineImage setImage:[UIImage imageNamed:@"line_two"]];
    scanLineImage.center = CGPointMake(APP_W/2, 82);
    [self.view addSubview:scanLineImage];
    
    [self runSpinAnimationOnView:scanLineImage duration:3 positionY:scanWidth repeat:CGFLOAT_MAX];
}

- (void)runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration positionY:(CGFloat)positionY repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: positionY];
    rotationAnimation.duration = duration;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    rotationAnimation.autoreverses = YES;
    [view.layer addAnimation:rotationAnimation forKey:@"position"];
}

#pragma mark -
#pragma mark  右上角按钮 闪光灯
- (void)setupTorchBarButton
{
    [self naviRightBottonImage:@"btn_navigation_rest" action:@selector(toggleTorch:)];
}

- (void)toggleTorch:(id)sender
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (!self.torchMode) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                self.torchMode = YES;
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                self.torchMode = NO;
            }
            [device unlockForConfiguration];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark -
#pragma mark  扫码结果回调

- (void) IOSScanResult: (NSString*) scanCode WithType:(NSString *)type
{
    if (([scanCode hasPrefix:@"http://"])||([scanCode hasPrefix:@"https://"])) {
        
        WebDirectViewController *vcWebDirect = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
        WebDirectLocalModel *modelLocal = [[WebDirectLocalModel alloc] init];
        modelLocal.url = scanCode;
        modelLocal.typeLocalWeb = WebLocalTypeOuterLink;
        //此外链不要分享
        modelLocal.typeTitle = WebTitleTypeNone;
        [vcWebDirect setWVWithLocalModel:modelLocal];
        vcWebDirect.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vcWebDirect animated:YES];
    }else{
        MallScanDrugViewController *VC = [[MallScanDrugViewController alloc]initWithNibName:@"MallScanDrugViewController" bundle:nil];
        VC.scanCode = scanCode;
        [self.navigationController pushViewController:VC animated:YES];
    }
}

@end
