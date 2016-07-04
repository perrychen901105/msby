//
//  XPChatViewController.h
//  APP
//
//  Created by carret on 15/5/21.
//  Copyright (c) 2015年 carret. All rights reserved.
//

#import "QWBaseVC.h"
#import "ConsultDoctorModel.h"
#import "DrugModel.h"
#import "CouponModel.h"
#import "XPMessageCenter.h"


typedef enum XPEnum_SendConsult{
    XPEnum_SendConsult_Common = 0,              //普通点对点
    XPEnum_SendConsult_Drug   = 1,              //商品咨询
    XPEnum_SendConsult_Coupn = 2,               //优惠活动咨询
}XPSendConsult;

extern BOOL const XPallowsSendFace;             //是否支持发送表情
extern BOOL const XPallowsSendVoice;            //是否支持发送声音
extern BOOL const XPallowsSendMultiMedia;       //是否支持发送多媒体
extern BOOL const XPallowsPanToDismissKeyboard; //是否允许手势关闭键盘，默认是允许
extern BOOL const XPshouldPreventAutoScrolling;

@interface XPChatViewController : QWBaseVC

@property (nonatomic, strong) ConsultInfoModel  *consultInfo;
@property (nonatomic, assign) XPSendConsult      sendConsultType;
@property (nonatomic, strong) NSString          *avatarUrl;
@property (nonatomic, strong) CouponDetailModel *coupnDetailModel;
@property (nonatomic ,strong) NSString          *messageSender;
@property (nonatomic ,strong) DrugDetailModel   *drugDetailModel;
@property (nonatomic ,copy)   NSString          *branchId;
@property (nonatomic ,copy)   NSString          *branchName;
//@property (nonatomic ,strong) PharMsgModel *pharMsgModel;

@property (nonatomic ,copy)   NSString          *sessionID;
@property (nonatomic ,strong) NSString          *proId;
@property (nonatomic ,strong) XPMessageCenter   *messageCenter;

@property (nonatomic, strong) HistoryMessages   *historyMsg;
/**
 *  消息的类型
 */
@property (nonatomic, assign) MessageShowType  showType;

/**
 *  隐藏键盘
 */
- (void)hiddenKeyboard;
- (void)reloadData;

- (void)messageCenterInit;
- (void)uploadPhotos;
@end
