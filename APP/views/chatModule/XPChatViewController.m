//
//  XPChatViewController.m
//  APP  群聊
//
//  Created by carret on 15/5/21.
//  Copyright (c) 2015年 carret. All rights reserved.
//

#import "XPChatViewController.h"

//系统库
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>

//控制器
#import "QuickSearchViewController.h"
#import "DFMultiPhotoSelectorViewController.h"
#import "PharmacySotreViewController.h"

#import "PatientListViewController.h"
#import "FamilyMemberInfoViewController.h"
//第三方UI控件
#import "XHShareMenuView.h"
#import "XHMessageInputView.h"
#import "XHEmotionManager.h"
#import "XHEmotionManagerView.h"
#import "ChatManagerDefs.h"
#import "ChatBubbleViewHeader.h"


//cell
#import "ChatTableViewCell.h"
#import "ChatOutgoingTableViewCell.h"

//第三方数据类
#import "XHMessage.h"
#import "XMPPStream.h"
#import "SVProgressHUD.h"
#import "SBJson.h"
#import "PopupMarketActivityView.h"

//相册
#import "QYImage.h"
#import "QYPhotoAlbum.h"
#import "PhotoAlbum.h"

//图片浏览
#import "PhotoPreView.h"

//扩展
#import "UIImage+Ex.h"
#import "UIScrollView+XHkeyboardControl.h"

#import "UIImageView+WebCache.h"
//消息中心
#import "XPMessageCenter.h"

#import "MessageModel.h"
#import "ChatIncomeTableViewCell.h"
#import "ChatOutgoingTableViewCell.h"
#import "SJAvatarBrowser.h"

#import "CouponModel.h"

#import "Favorite.h"
#import "QuickSearchDrugViewController.h"


#import "ConsultForFreeRootViewController.h"

#import "PhotoChatBubbleView.h"

//语音
#import "XHVoiceRecordHUD.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "XHAudioPlayerHelper.h"
#import "VoiceChatBubbleView.h"
#import "XHVoiceRecordHelper.h"
#import "ConsultForFreeRootViewController.h"
#import "EvaluateStoreViewController.h"
#import "Appraise.h"
#import "WebDirectViewController.h"
#import "CouponPharmacyDeailViewController.h"
#import "CenterCouponDetailViewController.h"
BOOL const XPallowsSendFace = YES;
BOOL const XPallowsSendVoice = YES;
BOOL const XPallowsSendMultiMedia = YES;
BOOL const XPallowsPanToDismissKeyboard = NO;//是否允许手势关闭键盘，默认是允许
const int XPalertResendIdentifier = 10000;
const int XPalertDeleteIdentifier = 10001;

#define kOffSet        45  //tableView偏移量
#define kInputViewHeight   45  //输入框的高度
#define kEmojiKeyboardHeight 216 //表情键盘的高度
#define kShareMenuHeight    95 //shareMenu键盘的高度
//self.view的高度  因为点击发送药品时，self.view的高度含导航栏，特此区别
#define kViewHeight  [UIScreen mainScreen].bounds.size.height - NAV_H - STATUS_H

@interface XPChatViewController ()<XHMessageInputViewDelegate,XHShareMenuViewDelegate,XHEmotionManagerViewDataSource,XHEmotionManagerViewDelegate,UITableViewDataSource,UITableViewDelegate,DFMultiPhotoSelectorViewControllerDelegate,UINavigationControllerDelegate,MLEmojiLabelDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate,MarketActivityViewDelegate,XHAudioPlayerHelperDelegate>
{
    
    UIImage * willsendimg;
    XPMessageCenter *msgCenter;
    
    UIMenuController    *_menuController;
    UIMenuItem          *_copyMenuItem;
    UIMenuItem          *_deleteMenuItem;
    NSIndexPath         *_longPressIndexPath;
    
    NSInteger           _recordingCount;
    
    dispatch_queue_t    _messageQueue;
    
    NSMutableArray      *_messages;
    
    BOOL                _isScrollToBottom;
    
    //浏览图片数组
    NSArray *arrPhotos;
    
    PhotoModel          *currentSendPhotoModel;
    MessageModel        *playingMessageModel;
}
@property (nonatomic, weak, readwrite) XHShareMenuView *shareMenuView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableFoot;
@property (nonatomic, assign) BOOL isUserScrolling;
/**
 *  第三方接入的功能，也包括系统自身的功能，比如拍照、发送地理位置
 */
@property (nonatomic, strong) NSArray *shareMenuItems;
/**
 *  管理第三方gif表情的控件
 */
@property (nonatomic, weak, readwrite) XHEmotionManagerView *emotionManagerView;
/**
 *  表情数据源
 */
@property (nonatomic, strong) NSArray *emotionManagers;

/**
 *  用于显示发送消息类型控制的工具条，在底部
 */
@property (nonatomic, strong, readonly) XHMessageInputView *messageInputView;
/**
 *  记录旧的textView contentSize Heigth
 */
@property (nonatomic, assign) CGFloat previousTextViewContentHeight;
//录音UI,按住说话,松开发送,拖拽出button 取消发送
@property (nonatomic, strong, readwrite) XHVoiceRecordHUD *voiceRecordHUD;

/**
 *  管理录音工具对象
 */
@property (nonatomic, strong) XHVoiceRecordHelper *voiceRecordHelper;
/**
 *  判断是不是超出了录音最大时长
 */
@property (nonatomic) BOOL isMaxTimeStop;
/**
 *  用来记录需要重发的字典对象
 */
@property (nonatomic, strong) NSDictionary *dicNeedResend;

/**
 *  用来记录需要删除的字典对象
 */
@property (nonatomic, strong) NSDictionary *dicNeedDelete;

@property (nonatomic, assign) XHInputViewType textViewInputViewType;

@property (nonatomic, strong) PopupMarketActivityView *popupMarketActivityView;
@property (nonatomic, strong) NSMutableArray *arrNeedAdded;
@property (nonatomic, assign) CGPoint rectHistory;
@property (nonatomic, strong) CustomerConsultDetailList     *detailList;
@property (nonatomic, strong) UIView    *headerHintView;
@property (nonatomic, strong) UILabel   *countDownLabel;
@property (nonatomic, strong) UIImageView      *alarmLogo;
@property (nonatomic, strong) UIView    *bottomView;


@property (nonatomic ,assign)BOOL  didScrollOrReload;

@property (nonatomic ,assign)BOOL  didScrollOrLoad;
/**
 *  动态改变TextView的高度
 *
 *  @param textView 被改变的textView对象
 */
- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView;
@end

#pragma mark
#pragma mark  ↑↑↑以上是声明部分↑↑↑
#pragma mark
@implementation XPChatViewController
@synthesize emotionManagerView = _emotionManagerView;

#pragma mark
#pragma mark self viewController init
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib {
    
}

//Changed By Cat V3.0.0 此处需要优化
- (void)UIGlobal
{
    [super UIGlobal];
    [self.tableMain setBackgroundColor:RGBHex(qwColor11)];
}

#pragma mark
#pragma mark view基本回调

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dicNeedDelete = @{};
    self.dicNeedResend = @{};
    self.arrNeedAdded = [@[] mutableCopy];
    
    self.tableMain.footerHidden = YES;
    
    self.popupMarketActivityView = [[[NSBundle mainBundle] loadNibNamed:@"PopupMarketActivityView" owner:self options:nil] objectAtIndex:0];
    
    self.popupMarketActivityView.delegate = self;

    
    [self initialzer];
    [self setUpSharedMenuItem];
    [self setUpEmojiManager];
    
    
    NSString *groupName = nil;
    if(!StrIsEmpty(self.consultInfo.storeModel.shortName))
    {
        groupName = self.consultInfo.storeModel.shortName;
    }
    else if (!StrIsEmpty(self.consultInfo.storeModel.name))
    {
        groupName = self.consultInfo.storeModel.name;
    }
    else if(!StrIsEmpty(self.historyMsg.groupName))
    {
        groupName = self.historyMsg.groupName;
    }
    else
    {
        groupName = @"咨询详情";
    }
    self.title = groupName;
    //if(self.branchId && ![self.branchId isEqualToString:@""])
//    if(!StrIsEmpty(self.branchId))
//    {
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"进店" style:UIBarButtonItemStylePlain target:self action:@selector(pushIntoDetailConsult:)];
//    }
    self.didScrollOrReload = YES;
    self.didScrollOrLoad = NO;
    
    [self messageCenterInit];
    [self messageCenterStart];
    [self.tableMain removeFooter];
    [self enableSimpleRefresh:self.tableMain block:^(SRRefreshView *sender) {
        [self headerRereshing];
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [QWGLOBALMANAGER updateUnreadCount:[NSString stringWithFormat:@"%ld",(long)[QWGLOBALMANAGER getAllUnreadCount]]];
    
    if(self.consultInfo.list.count > 0) {
        [self uploadPhotos];
        //        [self performSelector:@selector(uploadPhotos) withObject:nil afterDelay:.5];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //各种键盘通知
    [self.tableMain setupPanGestureControlKeyboardHide:allowsPanToDismissKeyboard];
    // KVO 检查contentSize
    [self.messageInputView.inputTextView addObserver:self
                                          forKeyPath:@"contentSize"
                                             options:NSKeyValueObservingOptionNew
                                             context:nil];
    
    //[self layoutOtherMenuViewHiden:NO];
    //不要删注释
    if (self.shareMenuView.alpha == 1 || self.emotionManagerView.alpha == 1) {
        //        [self layoutOtherMenuViewHiden:NO];
    }else{
        // 设置键盘通知或者手势控制键盘消失
        self.tableMain.contentInset = UIEdgeInsetsMake(0, 0, 0, 0); //UIEdgeInsets( top: t, left: l, bottom: b, right: r)
        self.tableMain.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0); //UIEdgeInsets( top: t, left: l, bottom: b, right: r)
    }
    [self initKeyboardBlock];
    [msgCenter restart];
    ((QWBaseNavigationController *)self.navigationController).canDragBack = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 取消输入框
    [self unLoadKeyboardBlock];
    [self.messageInputView.inputTextView resignFirstResponder];
    [self setEditing:NO animated:YES];
    
    // remove键盘通知或者手势
    [self.tableMain disSetupPanGestureControlKeyboardHide:NO];
    
    // remove KVO
    [self.messageInputView.inputTextView removeObserver:self forKeyPath:@"contentSize"];
    ((QWBaseNavigationController *)self.navigationController).canDragBack = YES;
    [self stopMusicInOtherBubblePressed];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //    [self showOrHideHeaderView];
}

- (void)dealloc{
    self.emotionManagers = nil;
    [[XHAudioPlayerHelper shareInstance] setDelegate:nil];
    [self closeMessageCenter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark
#pragma mark 图片相关逻辑

- (void)preparePhotos{
    for (int i = 0; i<self.consultInfo.list.count; i++) {
        currentSendPhotoModel = self.consultInfo.list[i];
        if (currentSendPhotoModel.fullImage) {
            NSString *UUID = [XMPPStream generateUUID];
            //                    UIImage *aimg=[currentSendPhotoModel.fullImage imageByScalingToMinSize];
            [[SDImageCache sharedImageCache] storeImage:currentSendPhotoModel.fullImage forKey:UUID toDisk:YES];
            
            MessageModel *model = [[MessageModel alloc] initWithPhoto:currentSendPhotoModel.fullImage thumbnailUrl:nil originPhotoUrl:nil sender:self.messageSender timestamp:[NSDate date] UUID:UUID richBody:nil];
            model.sended=MessageDeliveryState_Delivering;
            [msgCenter addMessagePre:model];
//            [self sendMessage:model messageBodyType:MessageMediaTypePhoto];
        }
        
    }
}
- (void)uploadPhotos{
    for (MessageModel *messageModel in msgCenter.arrPrepare) {
        [msgCenter sendPhotosMessage:messageModel success:^(id successObj) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                MessageModel *message = [msgCenter getMessageWithUUID:StrFromObj(successObj)];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[msgCenter getMessageIndex:message] inSection:0];
                ChatOutgoingTableViewCell *cell = (ChatOutgoingTableViewCell *)[self.tableMain cellForRowAtIndexPath:indexPath];
                ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.activeShow.hidden = YES;
                ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.hidden = YES;
                ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.progressLabel.text = [NSString stringWithFormat:@"%d%@",0,@"%"];
                [self messageToPharMsg:messageModel send:MessageDeliveryState_Delivered ];
                [self.tableMain reloadData];
                
            });
        } failure:^(id failureObj) {
            MessageModel *message = [msgCenter getMessageWithUUID:messageModel.UUID];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[msgCenter getMessageIndex:message] inSection:0];
            ChatOutgoingTableViewCell *cell = (ChatOutgoingTableViewCell *)[self.tableMain cellForRowAtIndexPath:indexPath];
            
            ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.activeShow.hidden = YES;
            ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.hidden = YES;
            ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.progressLabel.text = [NSString stringWithFormat:@"%d%@",0,@"%"];
            [self.tableMain reloadData];
            [self messageToPharMsg:messageModel  send:MessageDeliveryState_Failure];
        } uploadProgressBlock:^(MessageModel *target, float progress) {
            
            [self progressUpdate:messageModel.UUID progress:progress];
            
        }];
    }
    msgCenter.arrPrepare=nil;
}

#pragma mark 各种跳转
//进店咨询
- (void)pushIntoDetailConsult:(id)sender
{
    PharmacySotreViewController *VC = [[PharmacySotreViewController alloc]init];
    VC.branchId = self.branchId;
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}
//进入药品详情
- (void)pushToDrugDetailWithDrugID:(NSString *)drugId promotionId:(NSString *)promotionID{
    
    WebDirectViewController *vcWebMedicine = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
    
    if (promotionID==nil) {
        promotionID = @"";
    }
    MapInfoModel *modelMap = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
    WebDrugDetailModel *modelDrug = [WebDrugDetailModel new];
    modelDrug.modelMap = modelMap;
    modelDrug.proDrugID = drugId;
    modelDrug.promotionID = promotionID;
//    modelDrug.showDrug = @"1";
    WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
//    modelLocal.title = @"药品详情";
    modelLocal.modelDrug = modelDrug;
    modelLocal.typeLocalWeb = WebPageToWebTypeMedicine;
    [vcWebMedicine setWVWithLocalModel:modelLocal];
    [self.navigationController pushViewController:vcWebMedicine animated:YES];
}

- (void)headerRereshing
{
    //测试翻页历史数据
    self.rectHistory = self.tableMain.contentOffset;
    [self getHistory];
    //[self.tableMain headerEndRefreshing];
}

#pragma mark
#pragma mark 生成药品信息和优惠活动的固定类型
//仿阿里旺旺,通过药品进入,显示该药品的快捷发送链接,
//显示在当前消息列表最后一条,随便消息递增,会往上翻滚,
//点击一次发送链接,移除此链接,并发送出药品消息
- (MessageModel *)buildMedicineShowOnceMessage:(id)drugModel
{
    NSDate *lastTimeStamp = [NSDate date];
    if(msgCenter.count > 0) {
        MessageModel *lastMsg = [msgCenter getMessageByIndex: msgCenter.count -1];
        lastTimeStamp = [lastMsg.timestamp dateByAddingTimeInterval:1];
        
    }
    MessageModel *message = [[MessageModel alloc] initWithMedicineShowOnce:self.drugDetailModel.shortName
                                                                 productId:self.proId
                                                                  imageUrl:self.drugDetailModel.imgUrl
                                                                      spec:@""                          sender:self.messageSender
                                                                 timestamp:lastTimeStamp
                                                                      UUID:[XMPPStream generateUUID]];
    message.sended = Sended;
    message.messageDeliveryType = XHBubbleMessageTypeSending;
    message.avatorUrl = QWGLOBALMANAGER.configure.avatarUrl;
    
    return message;
}

//仿阿里旺旺,通过优惠活动进入,显示该活动的快捷发送链接,
//显示在当前消息列表最后一条,随便消息递增,会往上翻滚,
//点击一次发送链接,移除此链接,并发送出活动消息
- (MessageModel *)buildSpecialOffersShowOnceMessage:(id)drugModel
{
    NSDate *lastTimeStamp = [NSDate date];
    if(msgCenter.count > 0) {
        MessageModel *lastMsg = [msgCenter getMessageByIndex:msgCenter.count -1];;
        lastTimeStamp = [lastMsg.timestamp dateByAddingTimeInterval:1];
        
    }
    MessageModel *message = [[MessageModel alloc] initWithSpecialOffersShowOnce:self.coupnDetailModel.title
                                                                        content:self.coupnDetailModel.desc
                                                                    activityUrl:self.coupnDetailModel.url
                                                                     activityId:self.coupnDetailModel.id
                                                                         sender:self.messageSender
                                                                      timestamp:lastTimeStamp
                                                                           UUID:[XMPPStream generateUUID]];
    message.sended = Sended;
    message.messageDeliveryType = XHBubbleMessageTypeSending;
    message.avatorUrl = QWGLOBALMANAGER.configure.avatarUrl;
    
    return message;
}

#pragma mark - 消息中心
- (void)messageCenterInit{
    
    if (msgCenter == nil)
    {
        if (!self.messageSender)
        {
            self.messageSender = self.consultInfo.consultId;
        }
        
        if (self.messageCenter)
        {
            msgCenter = self.messageCenter;
        }
        else
        {
            msgCenter = [[XPMessageCenter alloc] initWithID:self.messageSender type:IMTypeXPClient];
        }
    }
}

- (void)messageCenterStart{
    [msgCenter start];
    
    //最新的消息回话，会实时刷新
    IMListBlock currentMsgBlock = ^(NSArray* list, IMListType gotType){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableMain reloadData];
            [self setTableViewInsetsWithBottomValue:self.view.frame.size.height
             - self.messageInputView.frame.origin.y - kOffSet];
            [self scrollToBottomAnimated:NO];
//            self.tableMain.hidden = NO;
        });
        
        if (gotType == IMListAll) {
            if(self.sendConsultType == Enum_SendConsult_Drug) {
                MessageModel *message = [self buildMedicineShowOnceMessage:nil];
                [msgCenter addMessage:message];
            }else if (self.sendConsultType == Enum_SendConsult_Coupn) {
                MessageModel *message = [self buildSpecialOffersShowOnceMessage:nil];
                [msgCenter addMessage:message];
            }
            if(self.consultInfo.list.count > 0) {
                [self preparePhotos];
            }
            
        }else if (gotType == IMListDelete)
        {
        }
        else
        {
            [self setTableViewInsetsWithBottomValue:self.view.frame.size.height - self.messageInputView.frame.origin.y - kOffSet];
            [self scrollToBottomAnimated:YES];
        }
    };
    
    [msgCenter getMessages:currentMsgBlock success:^(id successObj) {
        if (successObj !=nil)
        {
            if([successObj isKindOfClass:[CustomerConsultDetailList class]])
            {
                _detailList = successObj;
                if(self.showType == MessageShowTypeClosed && !_detailList.evaluated)
                {
                    self.showType = MessageShowTypeClosedWithoutEvaluate;
                    [self layoutDifferentMessageType];
                    [self.messageInputView.inputTextView addObserver:self
                                                          forKeyPath:@"contentSize"
                                                             options:NSKeyValueObservingOptionNew
                                                             context:nil];
                }
            }
        }
    } failure:^(id failureObj) {
        
    }];
    
    WEAKSELF
    [msgCenter setPharConsultBlock:^(CustomerConsultDetailList* model){
        if(model.consultMessage && model.consultMessage.length > 0)
        {
            [weakSelf setCountDownLabelText:model.consultMessage];
        }
        weakSelf.branchId = model.branchId;
        if([model.consultStatus integerValue] != 5 && [model.consultStatus integerValue] != 1 && [model.consultStatus integerValue] != 6 && [model.consultStatus integerValue] != 3) {
            weakSelf.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"进店" style:UIBarButtonItemStylePlain target:weakSelf action:@selector(pushIntoDetailConsult:)];
            if(model.pharShortName)
                weakSelf.title = model.pharShortName;
        }
    }];
}

- (void)getHistory{
    //根据页码翻上一页
    IMHistoryBlock historyMsgBlock = ^(BOOL hadHistory){
        if (hadHistory)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self tableMain] reloadData];
            });
        }
    };
    
    [msgCenter getHistory:historyMsgBlock success:^(id successObj){
        
    }failure:^(id failureObj) {
        
    }];
}

- (CGFloat) firstRowHeight
{
    return [self tableView:[self tableMain] heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}


- (void)deleteMessage:(MessageModel *)model{
    [msgCenter removeMessage:model success:^(id successObj) {
        //刷新table
    } failure:^(id failureObj) {
        //
    }];
}

- (void)closeMessageCenter{
    if (msgCenter) {
        [msgCenter close];
        msgCenter = nil;
    }
}

#pragma mark
#pragma mark 消息发送中心
- (void)sendMessage:(MessageModel *)messageModel messageBodyType:(MessageBodyType)messageType
{
    switch (messageType) {
        case MessageMediaTypeText:   //发送纯文本
        {
            [msgCenter sendMessage:messageModel success:^(id successObj) {
                [self messageToPharMsg:messageModel send:MessageDeliveryState_Delivered ];
                [self.tableMain reloadData];
            } failure:^(id failureObj) {
                [self.tableMain reloadData];
                [self messageToPharMsg:messageModel send:MessageDeliveryState_Failure ];
            }];
            break;
        }
        case MessageMediaTypePhoto:     //发送图片
        {
//            [self progressUpdate:messageModel.UUID progress:0];
            [msgCenter sendFileMessage:messageModel success:^(id successObj) {
                
                 dispatch_async(dispatch_get_main_queue(), ^{
                       MessageModel *message = [msgCenter getMessageWithUUID:StrFromObj(successObj)];

                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[msgCenter getMessageIndex:message] inSection:0];
                ChatOutgoingTableViewCell *cell = (ChatOutgoingTableViewCell *)[self.tableMain cellForRowAtIndexPath:indexPath];
                ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.activeShow.hidden = YES;
                ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.hidden = YES;
                ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.progressLabel.text = [NSString stringWithFormat:@"%d%@",0,@"%"];
                [self messageToPharMsg:messageModel send:MessageDeliveryState_Delivered ];
                [self.tableMain reloadData];
                     
                      });
            } failure:^(id failureObj) {
                       MessageModel *message = [msgCenter getMessageWithUUID:messageModel.UUID];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[msgCenter getMessageIndex:message] inSection:0];
                ChatOutgoingTableViewCell *cell = (ChatOutgoingTableViewCell *)[self.tableMain cellForRowAtIndexPath:indexPath];
                
                ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.activeShow.hidden = YES;
                ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.hidden = YES;
                ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.progressLabel.text = [NSString stringWithFormat:@"%d%@",0,@"%"];
                [self.tableMain reloadData];
                 [self messageToPharMsg:messageModel  send:MessageDeliveryState_Failure];
            } uploadProgressBlock:^(MessageModel *target, float progress) {
               
                [self progressUpdate:messageModel.UUID progress:progress];
                
            }];
            break;
        }
        case MessageMediaTypeMedicineSpecialOffers://发送优惠活动
        {
            [msgCenter sendMessage:messageModel success:^(id successObj) {
                [self messageToPharMsg:messageModel send:MessageDeliveryState_Delivered ];
                [self.tableMain reloadData];
            } failure:^(id failureObj) {
                [self.tableMain reloadData];
                [self messageToPharMsg:messageModel  send:MessageDeliveryState_Failure];
            }];
            break;
        }
        case MessageMediaTypeMedicine://发送普通药品
        {
            [msgCenter sendMessage:messageModel success:^(id successObj) {
                [self messageToPharMsg:messageModel  send:MessageDeliveryState_Delivered];
                [self.tableMain reloadData];
            } failure:^(id failureObj) {
                [self.tableMain reloadData];
                [self messageToPharMsg:messageModel  send:MessageDeliveryState_Failure];
            }];
            break;
        }
        case MessageMediaTypeVoice://发送语音文件，
        {
            //add by yqy
            [msgCenter sendFileMessage:messageModel success:^(id successObj) {
                [self messageToPharMsg:messageModel  send:MessageDeliveryState_Delivered];
                [self.tableMain reloadData];
            } failure:^(id failureObj) {
                [self.tableMain reloadData];
                [self messageToPharMsg:messageModel  send:MessageDeliveryState_Failure];
            } uploadProgressBlock:^(MessageModel *target, float progress) {
                
                
            }];
            //end yqy
            break;
        }
        break;
        default:
            break;
    }
}

//更新进度条
-(void)progressUpdate:(NSString *)uuid progress:(float)newProgress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MessageModel *message = [msgCenter getMessageWithUUID:uuid];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[msgCenter getMessageIndex:message] inSection:0];
        ChatOutgoingTableViewCell *cell = (ChatOutgoingTableViewCell *)[self.tableMain cellForRowAtIndexPath:indexPath];
        if (cell) {
           ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.hidden = NO;
//           ((PhotoChatBubbleView *)cell.resendButton.hidden = YES;
            [((PhotoChatBubbleView *)cell.bubbleView).dpMeterView setProgress:newProgress];
        }
    });
}

- (void)messageToPharMsg:(MessageModel *)messageModel send:(NSInteger)sended
{
    
    PharMsgModel *history = [PharMsgModel getObjFromDBWithKey:self.branchId];
    if(!history) {
        history = [[PharMsgModel alloc] init];
    }
    
    history.branchId = self.branchId;
    history.title = self.title;
    history.latestTime =[NSString stringWithFormat:@"%@",messageModel.timestamp] ;
    history.timestamp =[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    history.formatShowTime = [QWGLOBALMANAGER updateFirstPageTimeDisplayer:[NSDate dateWithTimeIntervalSince1970:[history.timestamp doubleValue]]];
    history.issend = [NSString stringWithFormat:@"%ld",(long)sended];
//  history.type = @"2";
//  history.branchId = @"2";
    switch ( messageModel.messageMediaType ) {
        case MessageMediaTypeText:
        {
            history.content = messageModel.text;
            break;
        }
        case MessageMediaTypePhoto:
        {
            history.content = @"[图片]";
            break;
        }
        case MessageMediaTypeActivity:
        {
            history.content = @"[活动]";
            break;
        }
        case MessageMediaTypeLocation:
        {
            history.content = @"[位置]";
            break;
            
        }
        case MessageMediaTypeMedicine:
        {
            history.content = @"[药品]";
            break;
        }
        case MessageMediaTypeMedicineSpecialOffers:
        {
            history.content = @"[活动]";
            break;
            
        }
        default:
            break;
    }
    if (self.branchId.length > 0) {
        [PharMsgModel updateObjToDB:history WithKey:self.branchId];
    }
    
    [GLOBALMANAGER postNotif:NotimessageIMTabelUpdate data:nil object:nil];
}


/**
 *  点击发送时，做隐藏键盘操作
 */
- (void)finishSendMessageWithBubbleMessageType:(MessageBodyType)mediaType {
    switch (mediaType) {
        case MessageMediaTypeText:
        {
            [self.messageInputView.inputTextView setText:nil];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                self.messageInputView.inputTextView.enablesReturnKeyAutomatically = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.messageInputView.inputTextView.enablesReturnKeyAutomatically = YES;
                    [self.messageInputView.inputTextView reloadInputViews];
                });
            }
            break;
        }
        case MessageMediaTypePhoto:
        {
           break;
        }
        default:
            break;
    }
}

#pragma mark
#pragma mark （Action）点击发送文本
- (void)didSendTextAction:(NSString *)text
{
    if([QWGLOBALMANAGER removeSpace:text].length == 0)
    {
        [self.messageInputView.inputTextView  resignFirstResponder];
        [SVProgressHUD showErrorWithStatus:kWarning45 duration:DURATION_SHORT];
        return;
    }
    MessageModel *textModel = [[MessageModel alloc] initWithText:text
                                                          sender:self.messageSender
                                                       timestamp:[NSDate date]
                                                            UUID:[XMPPStream generateUUID]];

    [self sendMessage:textModel messageBodyType:MessageMediaTypeText];
    [self finishSendMessageWithBubbleMessageType:MessageMediaTypeText];
}

#pragma mark
#pragma mark （Action）点击表情键盘中的发送按钮
- (void)didSendEmojiTextMessage:(id)sender
{
    if([QWGLOBALMANAGER removeSpace:self.messageInputView.inputTextView.text].length == 0)
        return;
    MessageModel *emojiModel = [[MessageModel alloc] initWithText:self.messageInputView.inputTextView.text
                                                          sender:self.messageSender
                                                       timestamp:[NSDate date]
                                                            UUID:[XMPPStream generateUUID]];
    [self sendMessage:emojiModel messageBodyType:MessageMediaTypeText];
    [self finishSendMessageWithBubbleMessageType:MessageMediaTypeText];
}

#pragma mark
#pragma mark （Action）点击加号“+”
/**
 *  发送多媒体
 */
- (void)didSelectedMultipleMediaAction:(BOOL)selected
{
    DebugLog(@"%s",__FUNCTION__);
    self.textViewInputViewType = XHInputViewTypeShareMenu;
    if(self.shareMenuView.alpha == 1.0) {
        [self.messageInputView.inputTextView becomeFirstResponder];
    }else{
        [self layoutOtherMenuViewHiden:NO];
    }
}

#pragma mark
#pragma mark （Action）调出表情键盘
/**
 *  发送表情
 */
- (void)didSendFaceAction:(BOOL)sendFace
{
    DebugLog(@"%s",__FUNCTION__);
    [self scrollToBottomAnimated:YES];
    if (sendFace) {
        self.textViewInputViewType = XHInputViewTypeEmotion;
        [self layoutOtherMenuViewHide:NO fromInputView:NO];
        [self scrollToBottomAnimated:YES];
    } else {
        [self.messageInputView.inputTextView becomeFirstResponder];
    }
}

#pragma mark
#pragma mark 点击单个表情触发事件
- (void)didSelecteEmotion:(XHEmotion *)emotion atIndexPath:(NSIndexPath *)indexPath
{
    if (emotion.emotionPath) {
        NSString *text = self.messageInputView.inputTextView.text;
        if([emotion.emotionPath isEqualToString:@"删除"])
        {
            NSString *scanString = [NSString stringWithString:text];
            NSUInteger count = 0;
            while (scanString.length > 0)
            {
                NSString *lastString = [scanString substringWithRange:NSMakeRange(scanString.length - 1, 1)];
                if([lastString isEqualToString:@"["] && scanString.length >= 1)
                {
                    text = [scanString substringToIndex:scanString.length - 1];
                    self.messageInputView.inputTextView.text = text;
                    return;
                }
                count++;
                if(count >= 4)
                    break;
                scanString = [scanString substringToIndex:scanString.length - 1];
            }
            if(text.length > 0){
                text = [text substringToIndex:text.length - 1];
                self.messageInputView.inputTextView.text = text;
            }
        }else{
            text = [text stringByAppendingString:emotion.emotionPath];
            self.messageInputView.inputTextView.text = text;
        }
    }
}
- (void)layoutOtherMenuViewHiden:(BOOL)hide {
    [self layoutOtherMenuViewHide:hide fromInputView:YES];
    [self scrollToBottomAnimated:YES];
}

#pragma mark - XHEmotionManagerView DataSource

- (NSInteger)numberOfEmotionManagers
{
    return self.emotionManagers.count;
}
- (XHEmotionManager *)emotionManagerForColumn:(NSInteger)column
{
    return [self.emotionManagers objectAtIndex:column];
}
- (NSArray *)emotionManagersAtManager
{
    return self.emotionManagers;
}

#pragma mark - send Photo

- (void)LocalPhoto
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PhotoAlbum" bundle:nil];
    PhotoAlbum* vc = [sb instantiateViewControllerWithIdentifier:@"PhotoAlbum"];
    [vc selectPhotos:4 selected:nil block:^(NSMutableArray *list) {
        for (PhotoModel *mode in list) {
            if (mode.fullImage) {
                UIImage *image=mode.fullImage;
                [self didChoosePhoto:image];
            }
        }
    } failure:^(NSError *error) {
        DebugLog(@"%@",error);
        [vc closeAction:nil];
    }];
    
    UINavigationController *nav = [[QWBaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:^{
    }];
}

-(void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        [self performSelector:@selector(showcamera) withObject:nil afterDelay:0.3];
    }else{
        DDLogVerbose(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

-(void)showcamera
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:^{}];
}
-(void)didChoosePhoto:(UIImage *)img
{
    NSString *UUID = [XMPPStream generateUUID];
    [[SDImageCache sharedImageCache] storeImage:img forKey:UUID toDisk:YES];
    if (![[SDImageCache sharedImageCache] diskImageExistsWithKey:UUID]) {
        [[SDImageCache sharedImageCache] storeImage:img forKey:UUID toDisk:YES];
    }
    MessageModel *model = [[MessageModel alloc] initWithPhoto:img thumbnailUrl:nil originPhotoUrl:nil sender:self.messageSender timestamp:[NSDate date] UUID:UUID richBody:nil];
    [self sendMessage:model messageBodyType:MessageMediaTypePhoto];
}

#pragma mark
#pragma mark 照相机
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType ==     UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [image imageByScalingToMinSize];
    image = [UIImage scaleAndRotateImage:image];
    
    [self didChoosePhoto:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type
{
    if(type == MLEmojiLabelLinkTypeQuickSearch) {
        QuickSearchViewController *quickSearchViewController = [[QuickSearchViewController alloc] init];
        quickSearchViewController.backButtonEnabled = YES;
        [self.navigationController pushViewController:quickSearchViewController animated:YES];
    }
}

#pragma mark
#pragma mark - Scroll Message TableView Helper Method

- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
    self.tableMain.contentInset = insets;
    self.tableMain.scrollIndicatorInsets = insets;
    self.tableMain.header.scrollViewOriginalInset = insets;
    self.tableMain.footer.scrollViewOriginalInset = insets;
}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.bottom = bottom;
    return insets;
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    if(self.tableMain.tableFooterView == nil) {
        NSInteger rows = [self.tableMain numberOfRowsInSection:0];
        if (rows > 0) {


            [self.tableMain scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:animated];
        }
    }else{
        [self.tableMain scrollRectToVisible:self.tableMain.tableFooterView.frame animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isUserScrolling = YES;
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }
    
    if (self.textViewInputViewType != XHInputViewTypeNormal && self.textViewInputViewType != XHInputViewTypeText) {
//        [self layoutOtherMenuViewHiden:YES];
        [self hiddenKeyboard];
    }else if (self.textViewInputViewType == XHInputViewTypeText)
    {
        [self.messageInputView.inputTextView resignFirstResponder];
    }
    
     self.didScrollOrReload = NO;
}

- (void)hiddenKeyboard
{
    [self.messageInputView.inputTextView resignFirstResponder];
    [self.messageInputView.faceSendButton setSelected:NO];
    [self.messageInputView.multiMediaSendButton setSelected:NO];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGFloat item_Y = 0;
        CGRect otherMenuViewFrame;
        //表情键盘
        item_Y = self.emotionManagerView.frame.origin.y;
        otherMenuViewFrame = self.emotionManagerView.frame;
        if (item_Y < kViewHeight) { //显示在界面上，则隐藏
            otherMenuViewFrame.origin.y = kViewHeight;
            self.emotionManagerView.alpha = 0;
            self.emotionManagerView.frame = otherMenuViewFrame;
            [self setTableViewInsetsWithBottomValue:self.view.frame.size.height
             - self.messageInputView.frame.origin.y - kOffSet];
        }
        //shareMenuView键盘
        item_Y = self.shareMenuView.frame.origin.y;
        otherMenuViewFrame = self.shareMenuView.frame;
        if (item_Y < kViewHeight) { //显示在界面上，则隐藏
            otherMenuViewFrame.origin.y = kViewHeight;
            self.shareMenuView.alpha = 0;
            self.shareMenuView.frame = otherMenuViewFrame;
            [self setTableViewInsetsWithBottomValue:self.view.frame.size.height
             - self.messageInputView.frame.origin.y - kOffSet];
        }
        //输入键盘
        item_Y = self.messageInputView.frame.origin.y;
        otherMenuViewFrame = self.messageInputView.frame;
        if (item_Y < kViewHeight - kInputViewHeight) {
            otherMenuViewFrame.origin.y = kViewHeight - kInputViewHeight;
            self.messageInputView.frame = otherMenuViewFrame;
            [self setTableViewInsetsWithBottomValue:self.view.frame.size.height
             - self.messageInputView.frame.origin.y - kOffSet];
        }
        
    } completion:^(BOOL finished) {
        
    }];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isUserScrolling = NO;
    
    self.didScrollOrReload = YES;
    if (self.didScrollOrLoad) {
        [self.tableMain reloadData];
        self.didScrollOrLoad = NO;
    }
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

/**
 *  是否显示时间轴Label的回调方法
 *  @param indexPath 目标消息的位置IndexPath
 *  @return 根据indexPath获取消息的Model的对象，从而判断返回YES or NO来控制是否显示时间轴Label
 */
- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageModel *message1 = [msgCenter getMessageByIndex:  indexPath.row];
    if(indexPath.row == 0) {
        return YES;
    }else{
        MessageModel *message0 = [msgCenter getMessageByIndex:indexPath.row - 1];
        NSTimeInterval offset = [message1.timestamp timeIntervalSinceDate:message0.timestamp];
        if(offset >= 300.0)
            return YES;
    }
    return NO;
}

#pragma mark - Table view delegate UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *obj = nil;
    //    [self.dataSource objectAtIndex:indexPath.row];
    obj=[msgCenter getMessageByIndex:indexPath.row];

    BOOL displayTimestamp = YES;
    displayTimestamp = [self shouldDisplayTimestampForRowAtIndexPath:indexPath];
    return [ChatTableViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(MessageModel *)obj hasTimeStamp:displayTimestamp];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (msgCenter) {
        return msgCenter.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel *model;
    model = [msgCenter getMessageByIndex:indexPath.row];
    
    if(model.messageDeliveryType == MessageTypeSending) {
        ChatOutgoingTableViewCell   *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatOutgoingTableViewCell"];
        cell.superParentViewController = self;
        cell.delegate = msgCenter;
        BOOL displayTimestamp = YES;
        displayTimestamp = [self shouldDisplayTimestampForRowAtIndexPath:indexPath];
        [cell setupSubviewsForMessageModel:model];
        cell.displayTimestamp = displayTimestamp;
        cell.messageModel = model;
        [cell updateBubbleViewConsTraint:model];
        
        if (model.messageDeliveryType == MessageTypeSending) {
            [cell.headImageView setImageWithURL:[NSURL URLWithString:QWGLOBALMANAGER.configure.avatarUrl] placeholderImage:[UIImage imageNamed:@"ic_img_notlogin"] options:SDWebImageRefreshCached];
        } else {
            [cell.headImageView setImageWithURL:[NSURL URLWithString:model.avatorUrl] placeholderImage:[UIImage imageNamed:@"药店默认头像"] options:SDWebImageHighPriority];
        }

        //    displayTimestamp = YES;
        if (displayTimestamp) {
            [cell configureTimeStampLabel:model];
        }
        [cell setupTheBubbleImageView:model];
        return cell;
        
    }else{
        ChatIncomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatIncomeTableViewCell"];   //[[ChatIncomeTableViewCell alloc] initWithMessageModel:model reuseIdentifier:@"ChatIncomeTableViewCell"];
        cell.superParentViewController = self;
        cell.delegate = msgCenter;
        BOOL displayTimestamp = YES;
        displayTimestamp = [self shouldDisplayTimestampForRowAtIndexPath:indexPath];
        
        [cell setupSubviewsForMessageModel:model];
        cell.displayTimestamp = displayTimestamp;
        cell.messageModel = model;
        
        [cell updateBubbleViewConsTraint:model];
        
        if (model.messageDeliveryType == MessageTypeSending) {
            [cell.headImageView setImageWithURL:[NSURL URLWithString:QWGLOBALMANAGER.configure.avatarUrl] placeholderImage:[UIImage imageNamed:@"ic_img_notlogin"] options:SDWebImageRefreshCached];

        } else {
            DDLogVerbose(@"the avator url is %@",model.avator);
            [cell.headImageView setImageWithURL:[NSURL URLWithString:model.avatorUrl] placeholderImage:[UIImage imageNamed:@"药店默认头像"] options:SDWebImageHighPriority];

        }

        //    displayTimestamp = YES;
        if (displayTimestamp) {
            [cell configureTimeStampLabel:model];
        }
        [cell setupTheBubbleImageView:model];
        return cell;
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    
}

- (void)reloadData{
    [self.tableMain reloadData];
}

//删除某一条记录
- (void)deleteOneMessageAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)stopMusicInOtherBubblePressed
{
    if(playingMessageModel) {
        playingMessageModel.audioPlaying = NO;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[msgCenter getMessageIndex:playingMessageModel] inSection:0];
        ChatTableViewCell *cell = (ChatTableViewCell *)[self.tableMain cellForRowAtIndexPath:indexPath];
        [cell stopVoicePlay];
        XHAudioPlayerHelper *playerHelper = [XHAudioPlayerHelper shareInstance];
        [playerHelper stopAudioWithOutDelegate];
        playingMessageModel = nil;
    }
}

#pragma mark - UIResponder actions

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    if(![eventName isEqualToString:kRouterEventOfVoice]) {
        [self stopMusicInOtherBubblePressed];
    }

    for (ChatTableViewCell *cell in self.tableMain.visibleCells) {
        [cell updateMenuControllerVisiable];
    }

    if([eventName isEqualToString:kRouterEventLocationChat]){
        [self.messageInputView.inputTextView resignFirstResponder];
        MessageModel *model=[userInfo objectForKey:KMESSAGEKEY];
        ShowLocationViewController *showLocationViewController = [[ShowLocationViewController alloc] init];
        showLocationViewController.coordinate =[model location].coordinate;
        showLocationViewController.address = [model text];
        [self.navigationController pushViewController:showLocationViewController animated:YES];
    }
    //yqy 优惠活动 PMT
    else if([eventName isEqualToString:kRouterEventCoupnChat]){
        MessageModel *model=[userInfo objectForKey:KMESSAGEKEY];
        CouponPharmacyDeailViewController *vc = [[CouponPharmacyDeailViewController alloc]initWithNibName:@"CouponPharmacyDeailViewController" bundle:nil];
        vc.storeId=self.branchId;//model.UUID;
        vc.activityId=model.richBody;
        [self.navigationController pushViewController:vc animated:YES];
//        //输入键盘隐藏
//        CGFloat item_Y = self.messageInputView.frame.origin.y;
//        CGRect otherMenuViewFrame = self.messageInputView.frame;
//        if ((item_Y < kViewHeight - kInputViewHeight) && (item_Y != kViewHeight - kInputViewHeight - kShareMenuHeight) && (item_Y != kViewHeight - kEmojiKeyboardHeight - kInputViewHeight)) { //如果是和键盘同时出现，则下降inPutView
//            otherMenuViewFrame.origin.y = kViewHeight - kInputViewHeight;
//            self.messageInputView.frame = otherMenuViewFrame;
//            [self setTableViewInsetsWithBottomValue:self.view.frame.size.height
//             - self.messageInputView.frame.origin.y - kOffSet];
//        }
    }else if ([eventName isEqualToString:kRouterEventNoImageActivityBubbleTapEventName] || [eventName isEqualToString:kRouterEventHaveImageActivityBubbleTapEventName] )
    {
        //发送营销活动
        
        MarketDetailViewController *marketDetailViewController = nil;
        MessageModel *model=[userInfo objectForKey:KMESSAGEKEY];
        marketDetailViewController = [[MarketDetailViewController alloc] initWithNibName:@"MarketDetailViewController" bundle:nil];
        NSString *richBody = model.richBody;
        NSDate *date = model.timestamp;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        
        NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
        infoDict[@"activityId"] = richBody;
        marketDetailViewController.infoDict = infoDict;
        marketDetailViewController.userType = 1;
        marketDetailViewController.imStatus = 2;
        
        if (!richBody)
        {
            marketDetailViewController.infoDict =[NSMutableDictionary dictionaryWithDictionary:@{@"title":StrFromObj(model.title),
                                                                                                 @"content":StrFromObj(model.text),
                                                                                                 @"imgUrl":(model.activityUrl ==nil)? @"":model.activityUrl,
                                                                                                 @"publishTime":StrFromObj([formatter stringFromDate:date])                                                             }];
        }
        
        marketDetailViewController.infoNewDict =[NSMutableDictionary dictionaryWithDictionary: @{@"title":StrFromObj(model.title),
                                                                                                 @"activityId":StrFromObj(model.richBody),
                                                                                                 @"content":StrFromObj(model.text),
                                                                                                 @"publishTime":StrFromObj([formatter stringFromDate:date])                                                             }];
        
        [self.navigationController pushViewController:marketDetailViewController animated:YES];
        
    }else if ([eventName isEqualToString:kRouterEventPhotoBubbleTapEventName])
    {
        //点击预览图片
        BubblePhotoImageView *bubble=[userInfo objectForKey:KMESSAGEKEY];
        MessageModel *mm=bubble.messageModel;
        NSString *uuid=StrFromObj(mm.UUID);
//        DebugLog(@"点击预览图片1 %@",uuid);
        arrPhotos=[msgCenter getImages];
        if (arrPhotos.count==0) {
            return;
        }
//        DebugLog(@"点击预览图片2 %@",arrPhotos);
        int i = 0;
        for (id obj in arrPhotos) {
            if ([obj isKindOfClass:[NSString class]]) {
                NSString *uid=obj;
                if ([uid isEqualToString:uuid]) {
                    break;
                }
            }
            i++;
        }
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PhotoAlbum" bundle:nil];
        PhotoPreView* vc = [sb instantiateViewControllerWithIdentifier:@"PhotoPreView"];
        
        vc.arrPhotos = arrPhotos;     //uiimage或者url数组，用全局数组，否则会crash
        vc.indexSelected = (i==arrPhotos.count)?0:i;   //[self currentSelectedImageIndex:self.photoArrays currentUUID:message.UUID];   //点击图片在数组里的index
        
        [self presentViewController:vc animated:YES completion:^{
            
        }];
        
//        BubblePhotoImageView *imageView=[userInfo objectForKey:@"message"];
//        [SJAvatarBrowser showImage:(UIImageView *)imageView];
        
    }else if ([eventName isEqualToString:kRouterEventOnceDrugBubbleTapEventName])
    {
        //发送药品链接
        MessageModel *model = [userInfo objectForKey:KMESSAGEKEY];
        
        [msgCenter deleteMessagesByType:MessageMediaTypeMedicineShowOnce];
        [msgCenter deleteMessagesByType:MessageMediaTypeMedicineSpecialOffersShowOnce];
        
        model.messageMediaType = MessageMediaTypeMedicine;
        [self sendMessage:model messageBodyType:MessageMediaTypeMedicine];
    }else if ([eventName isEqualToString:kRouterEventOnceCouponBubbleTapEventName])
    {
        //发送优惠活动链接
        MessageModel *model = [userInfo objectForKey:KMESSAGEKEY];
        
        [msgCenter deleteMessagesByType:MessageMediaTypeMedicineShowOnce];
        [msgCenter deleteMessagesByType:MessageMediaTypeMedicineSpecialOffersShowOnce];
        
        model.messageMediaType = MessageMediaTypeMedicineSpecialOffers;
        [self sendMessage:model messageBodyType:MessageMediaTypeMedicineSpecialOffers];
    }
    else if ([eventName isEqualToString:kRouterEventTeleChat]||[eventName isEqualToString:kRouterEventTeleAllChat])
    {
 
        
    }
    else if ([eventName isEqualToString:kRouterEventDrugChat])
    {
        //药品详情
        MessageModel *model=[userInfo objectForKey:KMESSAGEKEY];
        [self pushToDrugDetailWithDrugID:model.richBody promotionId:@""];
    }
    else if ([eventName isEqualToString:kRouterEventFootChat])
    {
        MessageModel *model=[userInfo objectForKey:KMESSAGEKEY];
        [msgCenter removeMessage:model success:^(id successObj) {
            
        } failure:^(id failureObj) {
            
        }];
        //优惠活动点击
        ConsultForFreeRootViewController *consultViewController = [[UIStoryboard storyboardWithName:@"ConsultForFree" bundle:nil] instantiateViewControllerWithIdentifier:@"ConsultForFreeRootViewController"];
        
        consultViewController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:consultViewController animated:YES];
    }
    else if ([eventName isEqualToString:kResendButtonTapEventName])
    {
        //重发
        self.dicNeedResend = userInfo;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"重发该消息?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = XPalertResendIdentifier;
        [alertView show];
        
        
    }else if ([eventName isEqualToString:kDeleteBtnTapEventName])
    {
        //删除
        self.dicNeedDelete = userInfo;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"你确定要删除吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = XPalertDeleteIdentifier;
        [alertView show];
    }else if ([eventName isEqualToString:kRouterEventOfVoice]) {

        MessageModel *model=[userInfo objectForKey:KMESSAGEKEY];
        XHAudioPlayerHelper *playerHelper = [XHAudioPlayerHelper shareInstance];
        [playerHelper setDelegate:self];
        if(playingMessageModel) {
            playingMessageModel.audioPlaying = NO;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[msgCenter getMessageIndex:playingMessageModel] inSection:0];
            ChatTableViewCell *cell = (ChatTableViewCell *)[self.tableMain cellForRowAtIndexPath:indexPath];
            [cell stopVoicePlay];
            if(model == playingMessageModel) {
                [playerHelper stopAudioWithOutDelegate];
                playingMessageModel = nil;
                return;
            }
        }
        if(model.download == MessageFileState_Downloading) {
            return;
        }else if(model.download == MessageFileState_Failure || model.download == MessageFileState_Pending) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[msgCenter getMessageIndex:model] inSection:0];
            ChatTableViewCell *cell = (ChatTableViewCell *)[self.tableMain cellForRowAtIndexPath:indexPath];
            [cell redownloadAudio:nil];
        }else{
            XHAudioPlayerHelper *playerHelper = [XHAudioPlayerHelper shareInstance];

            [playerHelper stopAudioWithOutDelegate];
            playingMessageModel = model;
            playingMessageModel.audioPlaying = YES;
            if(!model.voicePath || model.voicePath.length == 0)
            {
                return;
            }
            NSMutableArray *conpoment = [[model.voicePath componentsSeparatedByString:@"/"] mutableCopy];
            conpoment = [conpoment subarrayWithRange:NSMakeRange(conpoment.count - 4, 4)];
            NSString *amrPath = [NSHomeDirectory() stringByAppendingPathComponent:[conpoment componentsJoinedByString:@"/"]];
            NSData *amrData = [[NSData alloc] initWithContentsOfFile:amrPath];
            if(!amrData || amrData.length == 0)
                return;
            NSData *cafData = [self.voiceRecordHelper convertAmrToCaf:amrData];
            NSString *cafTempPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"tmp/temp.caf"]];
            [cafData writeToFile:cafTempPath atomically:YES];
            [playerHelper managerAudioWithFileName:cafTempPath toPlay:YES];
        }
    }
    //220 yqy 优惠券
    else if ([eventName isEqualToString:kCouponTickettBubbleView]) {
        MessageModel *mm=[userInfo objectForKey:KMESSAGEKEY];

        CenterCouponDetailViewController *vcDetail =[[CenterCouponDetailViewController alloc] initWithNibName:@"CenterCouponDetailViewController" bundle:nil];
        vcDetail.couponId=mm.otherID;
        [self.navigationController pushViewController:vcDetail animated:YES];
    }
    else if ([eventName isEqualToString:kCouponMedicineBubbleView]) {
        MessageModel *mm=[userInfo objectForKey:KMESSAGEKEY];
        WebDirectViewController *vcWebDirect = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
        WebDrugDetailModel *modelDrug = [WebDrugDetailModel new];
        MapInfoModel *modelMap = [QWUserDefault getObjectBy:APP_MAPINFOMODEL];
        modelDrug.modelMap = modelMap;
        modelDrug.proDrugID = mm.richBody;
        modelDrug.promotionID = mm.otherID;
//        modelDrug.showDrug = @"1";
        WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
//        modelLocal.title = @"商品详情";
        modelLocal.modelDrug = modelDrug;
        modelLocal.typeLocalWeb = WebPageToWebTypeMedicine;
        [vcWebDirect setWVWithLocalModel:modelLocal];
        vcWebDirect.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vcWebDirect animated:YES];
    }
}


#pragma mark -
#pragma mark XHAudioPlayerHelperDelegate
- (void)didAudioPlayerBeginPlay:(AVAudioPlayer*)audioPlayer
{
    
}

- (void)didAudioPlayerStopPlay:(AVAudioPlayer*)audioPlayer
{
    [self stopMusicInOtherBubblePressed];
}

- (void)didAudioPlayerPausePlay:(AVAudioPlayer*)audioPlayer
{
    
}

//链接被点击
- (void)chatTextCellUrlPressed:(NSURL *)url
{
    if (url) {
        //[[UIApplication sharedApplication] openURL:url];
    }
}

- (void)unLoadKeyboardBlock
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardDidHideNotification object:nil];
    self.tableMain.keyboardDidScrollToPoint = NULL;
    self.tableMain.keyboardWillSnapBackToPoint = NULL;
    self.tableMain.keyboardWillBeDismissed = NULL;
    self.tableMain.keyboardWillChange = NULL;
    self.tableMain.keyboardDidChange = NULL;
    self.tableMain.keyboardDidHide = NULL;
}

#pragma mark
#pragma mark 初始化工具
/**
 *  初始化消息界面布局
 */
- (void)initialzer
{
    // 初始化输入工具条
    [self layoutDifferentMessageType];
    // 设置手势滑动，默认添加一个bar的高度值
    self.tableMain.messageInputBarHeight = CGRectGetHeight(_messageInputView.bounds);
}
/**
 *  初始化输入工具条
 */
- (void)layoutDifferentMessageType
{
    CGRect inputFrame = CGRectMake(0.0f,
                                   self.view.frame.size.height - kInputViewHeight,
                                   self.view.frame.size.width,
                                   kInputViewHeight);;
    
    if (!_messageInputView) {
        _messageInputView = [self setupMessageInputView:inputFrame];
    }
    if(_bottomView) {
        [_bottomView removeFromSuperview];
    }
    switch (self.showType) {
        case MessageShowTypeNewCreate:
        {
            _bottomView = _messageInputView;
            break;
        }
        case MessageShowTypeAnswering:
        {
            self.headerHintView = [self setupCountDownHeaderView];
            [self.view addSubview:self.headerHintView];
            CGRect rect = self.tableMain.frame;
            rect.origin.y = 0;
            rect.size.height = self.view.frame.size.height  - 64;
            self.tableMain.frame = rect;
            
            [self performSelector:@selector(delayDismissHeaderHint) withObject:nil afterDelay:5.0];
            _bottomView = _messageInputView;
            break;
        }
        case MessageShowTypeClosed:
        {
            _bottomView = [self setupClosedBottomView:inputFrame];
            _messageInputView.hidden = YES;

            self.constraintTableFoot.constant = 80;
            break;
        }
        case MessageShowTypeClosedWithoutEvaluate:
        {
            _bottomView = [self setupClosedBottomWithoutEvaluateView:inputFrame];
            _messageInputView.hidden = YES;
            [self.view addSubview:_messageInputView];
            CGRect rect = self.view.frame;
            rect.origin.y = 0;
            self.constraintTableFoot.constant = 50;
            self.tableMain.frame = rect;
            break;
        }
        case MessageShowTypeTimeout:
        {
            _bottomView = [self setupTimeoutBottomView:inputFrame];
            _messageInputView.hidden = YES;
            [self.view addSubview:_messageInputView];
            CGRect rect = self.tableMain.frame;
            rect.origin.y = 0;
            rect.size.height = self.view.frame.size.height;
            self.tableMain.frame = rect;
            
            break;
        }
        case MessageShowTypeDiffusion:
        {
            CGRect rect = self.tableMain.frame;
            rect.origin.y = 0;
            rect.size.height = self.view.frame.size.height;
            self.tableMain.frame = rect;
            break;
        }
        default:
            break;
    }
    if(_bottomView) {
        [self.view addSubview:_bottomView];
        [self.view bringSubviewToFront:_bottomView];
    }
}
/**
 *  单例初始化输入工具条XHMessageInputView
 */
- (XHMessageInputView *)setupMessageInputView:(CGRect)inputFrame
{
    XHMessageInputView *inputView = [[XHMessageInputView alloc] initWithFrame:inputFrame];
    inputView.allowsSendFace = allowsSendFace;
    inputView.allowsSendVoice = allowsSendVoice;
    inputView.allowsSendMultiMedia = allowsSendMultiMedia;
    inputView.delegate = self;
    return inputView;
}


- (UIView *)setupClosedBottomWithoutEvaluateView:(CGRect)inputFrame
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_H - 50 - 64, APP_W, 50)];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *closeTitle = [[UILabel alloc] init];
    [closeTitle setText:@"您的咨询服务已结束"];
    closeTitle.font = [UIFont systemFontOfSize:15.0f];
    closeTitle.numberOfLines = 1;
    closeTitle.textColor = RGBHex(qwColor6);
    closeTitle.tag = 888;
    closeTitle.frame = CGRectMake(10, 5, APP_W-120, 20);
    closeTitle.textAlignment = NSTextAlignmentLeft;
    [bottomView addSubview:closeTitle];
    
    UILabel *closeContent = [[UILabel alloc] init];
    [closeContent setText:@"请为本次服务评价吧"];
    closeContent.font = [UIFont systemFontOfSize:12.0f];
    closeContent.numberOfLines = 3;
    closeContent.textColor = RGBHex(qwColor6);
    closeContent.tag = 999;
    closeContent.frame = CGRectMake(10, 25, APP_W-120, 20);
    closeContent.textAlignment = NSTextAlignmentLeft;
    [bottomView addSubview:closeContent];
    
    UIButton *reopenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [reopenButton setTitle:@"评价" forState:UIControlStateNormal];
    [reopenButton addTarget:self action:@selector(pushIntoEvaluateViewController:) forControlEvents:UIControlEventTouchDown];
    reopenButton.frame = CGRectMake(APP_W-100, 13, 86, 30);
    [reopenButton setBackgroundImage:[UIImage imageNamed:@"ic_btn_zixun1.png"] forState:UIControlStateNormal];
    [reopenButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    
    UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 0.5)];
    [separatorLine setBackgroundColor:RGBHex(qwColor10)];
    [bottomView addSubview:separatorLine];
    [bottomView addSubview:reopenButton];
    return bottomView;
}

- (void)pushIntoEvaluateViewController:(id)sender
{
//    __block EvaluateStoreViewController *viewController = nil;
//    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if([obj isKindOfClass:[EvaluateStoreViewController class]]) {
//            viewController = (EvaluateStoreViewController *)obj;
//            if([viewController.modelR.consultId isEqualToString:_detailList.consultId]) {
//                *stop = YES;
//            }
//        }
//    }];
//    if(viewController) {
//        [self.navigationController popToViewController:viewController animated:YES];
//        return;
//    }
    
    EvaluateStoreViewController *evaluateStoreViewController = [[EvaluateStoreViewController alloc] initWithNibName:@"EvaluateStoreViewController" bundle:nil];
    evaluateStoreViewController.shouldHideTop = YES;
    AppraiseByConsultModelR *modelR = [AppraiseByConsultModelR new];
    modelR.branchId = _detailList.branchId;
    modelR.consultId = _detailList.consultId;
    modelR.consultMessage = _detailList.consultMessage;
    modelR.branchName = _detailList.pharShortName;
    evaluateStoreViewController.modelR = modelR;
    __weak typeof(self) weakSelf = self;
    evaluateStoreViewController.successBlock = ^{
        weakSelf.showType = MessageShowTypeClosed;
        [weakSelf layoutDifferentMessageType];
    };
    evaluateStoreViewController.title = self.title;
    [self.navigationController pushViewController:evaluateStoreViewController animated:YES];
}

- (UIView *)setupClosedBottomView:(CGRect)inputFrame
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_H - 80 - 64, APP_W, 80)];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *closeLabel = [[UILabel alloc] init];
    if(self.historyMsg && self.historyMsg.consultMessage)
        [closeLabel setText:self.historyMsg.consultMessage];
    closeLabel.font = [UIFont systemFontOfSize:14.0f];
    closeLabel.numberOfLines = 3;
    closeLabel.textColor = RGBHex(qwColor6);
    closeLabel.tag = 888;
    closeLabel.frame = CGRectMake(10, 10, APP_W-120, 60);
    closeLabel.textAlignment = NSTextAlignmentLeft;
    [bottomView addSubview:closeLabel];
    
    UIButton *reopenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [reopenButton setTitle:@"进店咨询" forState:UIControlStateNormal];
    [reopenButton addTarget:self action:@selector(pushIntoDetailConsult:) forControlEvents:UIControlEventTouchDown];
    reopenButton.frame = CGRectMake(APP_W-100, 22, 86, 36);
    [reopenButton setBackgroundImage:[UIImage imageNamed:@"ic_btn_zixun1.png"] forState:UIControlStateNormal];
    [reopenButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    
    UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 0.5)];
    [separatorLine setBackgroundColor:RGBHex(qwColor10)];
    [bottomView addSubview:separatorLine];
    [bottomView addSubview:reopenButton];
    return bottomView;
}

- (void)delayDismissHeaderHint
{
    [UIView animateWithDuration:0.35 animations:^{
        self.headerHintView.alpha = 0.0;
        CGRect rect = self.tableMain.frame;
        rect.origin.y = 0;
        rect.size.height = self.view.frame.size.height - 64;
        self.tableMain.frame = rect;
    } completion:^(BOOL finished) {
        [self.headerHintView removeFromSuperview];
    }];
}

- (UIView *)setupCountDownHeaderView
{
    UIView *headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 45)];
    UIColor *backGroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_header_answer"]];
    backGroundColor = [backGroundColor colorWithAlphaComponent:0.8];
    [headerView setBackgroundColor:backGroundColor];
    self.countDownLabel = [[UILabel alloc] init];
    [_countDownLabel setText:@"该问题24小时后过期"];
    _countDownLabel.font = [UIFont systemFontOfSize:14.0f];
    _countDownLabel.textColor = RGBHex(qwColor3);
    _countDownLabel.alpha = 0.6f;
    _countDownLabel.frame = CGRectMake(65, 4.5, APP_W-130, 36);
    _countDownLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:_countDownLabel];
    
    _alarmLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, (45.0 - 18 ) / 2.0f, 18, 18)];
    _alarmLogo.image = [UIImage imageNamed:@"icon_clock.png"];
    [headerView addSubview:_alarmLogo];
    [self setCountDownLabelText:_countDownLabel.text];
    return headerView;
}

- (void)setCountDownLabelText:(NSString *)text
{
    _countDownLabel.text = text;
    
    CGFloat width = [text sizeWithFont:[UIFont systemFontOfSize:14.0f]].width;
    CGRect rect = _countDownLabel.frame;
    rect.size.width = width;
    rect.origin.x = (APP_W - width ) / 2.0 + 13.5f;
    _countDownLabel.frame = rect;
    
    rect = _alarmLogo.frame;
    rect.origin.x = (APP_W - width ) / 2.0 - 13.5;
    _alarmLogo.frame = rect;
}

- (UIView *)setupTimeoutBottomView:(CGRect)inputFrame
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_H - 80 - 64, APP_W, 80)];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *closeLabel = [[UILabel alloc] init];
    if(self.historyMsg && self.historyMsg.consultMessage)
        [closeLabel setText:self.historyMsg.consultMessage];
    closeLabel.font = [UIFont systemFontOfSize:14.0f];
    closeLabel.numberOfLines = 3;
    closeLabel.tag = 888;
    closeLabel.textColor = RGBHex(qwColor6);
    closeLabel.frame = CGRectMake(10, 10, APP_W-120, 60);
    closeLabel.textAlignment = NSTextAlignmentLeft;
    [bottomView addSubview:closeLabel];
    
    UIButton *reopenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [reopenButton setTitle:@"     咨询" forState:UIControlStateNormal];
    [reopenButton addTarget:self action:@selector(reopenConsultQuestion:) forControlEvents:UIControlEventTouchDown];
    reopenButton.frame = CGRectMake(APP_W-100, 22, 86, 36);
    [reopenButton setBackgroundImage:[UIImage imageNamed:@"ic_btn_zixun2.png"] forState:UIControlStateNormal];
    [reopenButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [bottomView addSubview:reopenButton];
    
    UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 0.5)];
    [separatorLine setBackgroundColor:RGBHex(qwColor10)];
    [bottomView addSubview:separatorLine];
    
    return bottomView;
}

//重新打开该问题
- (void)reopenConsultQuestion:(id)sender
{
    ConsultSpreadModelR *consultSpreadModelR = [ConsultSpreadModelR new];
    consultSpreadModelR.consultId = self.messageSender;
    [Consult consultSpreadWithParam:consultSpreadModelR success:^(BaseAPIModel *model) {
        if([model.apiStatus integerValue] == 0) {
            [SVProgressHUD showSuccessWithStatus:model.apiMessage duration:0.8];
            self.bottomView.hidden = YES;
            CGRect rect = self.tableMain.frame;
            rect.size.height = self.view.frame.size.height - 45;
            self.tableMain.frame = rect;
            self.messageInputView.hidden = NO;
            self.messageInputView.frame = CGRectMake(0,self.view.frame.size.height - 45, self.messageInputView.frame.size.width, self.messageInputView.frame.size.height);
            [CustomerConsultVoModel deleteObjFromDBWithKey:self.messageSender];
        }else{
            [SVProgressHUD showErrorWithStatus:model.apiMessage duration:0.8f];
        }
    } failure:NULL];
}


#pragma mark
#pragma mark 初始化shareMenu 及回调方法
- (void)setUpSharedMenuItem
{
    // 添加第三方接入数据
    NSMutableArray *shareMenuItems = [NSMutableArray array];
    //V3.0.0
    //    NSArray *plugIcons = @[@"photo_image.png",@"take_photo_image.png",@"ic_btn_medical.png"];//,@"ic_btn_collect_sale.png"
    //    NSArray *plugTitle = @[@"图片",@"拍照",@"药品"];//,@"我收藏的优惠"
    //fixed at 3.0.1 by lijian
    NSArray *plugIcons = @[@"photo_image.png",@"take_photo_image.png"];//,@"ic_btn_collect_sale.png"
    NSArray *plugTitle = @[@"图片",@"拍照"];//,@"我收藏的优惠"
    for (NSString *plugIcon in plugIcons) {
        XHShareMenuItem *shareMenuItem = [[XHShareMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:plugIcon] title:[plugTitle objectAtIndex:[plugIcons indexOfObject:plugIcon]]];
        [shareMenuItems addObject:shareMenuItem];
    }
    self.shareMenuItems = shareMenuItems;
    [self.shareMenuView reloadData];
}

/**
 *  单例初始化shareMenuView
 */
- (XHShareMenuView *)shareMenuView {
    if (!_shareMenuView) {
        XHShareMenuView *shareMenuView = [[XHShareMenuView alloc] initWithFrame:CGRectMake(0, kViewHeight, CGRectGetWidth(self.view.bounds), kShareMenuHeight)];
        shareMenuView.delegate = self;
        shareMenuView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        shareMenuView.alpha = 0.0;
        shareMenuView.shareMenuItems = self.shareMenuItems;
        [self.view addSubview:shareMenuView];
        _shareMenuView = shareMenuView;
    }
//    [self.view bringSubviewToFront:_shareMenuView];
    return _shareMenuView;
}

#pragma mark
#pragma mark （action）点击“+”号键盘里地单个功能触发的事件
- (void)didSelecteShareMenuItem:(XHShareMenuItem *)shareMenuItem atIndex:(NSInteger)index {
    switch (index) {
        case 0: {
            ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
            if(author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
                [SVProgressHUD showErrorWithStatus:@"当前程序未开启相册使用权限" duration:0.8];
                return;
            }
            [self LocalPhoto];
            break;
        }
        case 1: {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
                [SVProgressHUD showErrorWithStatus:@"当前程序未开启相机使用权限" duration:0.8];
                return;
            }
            [self takePhoto];
            break;
        }
        case 2: {
            //发送药品
            
            QuickSearchDrugViewController *quickSearchDrugViewController = [QuickSearchDrugViewController new];
            quickSearchDrugViewController.returnValueBlock = ^(productclassBykwId *model){
                
                MessageModel *medicineModel = [[MessageModel alloc] initWithMedicine:model.proName
                                                                           productId:model.proId
                                                                            imageUrl:model.imgUrl
                                                                              sender:self.messageSender
                                                                           timestamp:[NSDate date]
                                                                                UUID:[XMPPStream generateUUID]];
                [self sendMessage:medicineModel messageBodyType:MessageMediaTypeMedicine];
            };
            [self.navigationController pushViewController:quickSearchDrugViewController animated:NO];
            break;
        }
        default:
            break;
    }
}

- (void)showPopMarkActivityDetail:(CouponNewListModel *)model
{
    [self.popupMarketActivityView setContent:model.desc avatarUrl:model.imgUrl];
    self.popupMarketActivityView.infoDict = [NSMutableDictionary dictionaryWithDictionary:[model dictionaryModel]];
    [self.popupMarketActivityView showInView:self.view animated:YES];
    [self.view addSubview:self.popupMarketActivityView];
}

- (void)didSendMarketActivityWithDict:(NSDictionary *)dict
{
    CouponNewListModel *model = [CouponNewListModel parse:dict];
    MessageModel *activityModel = [[MessageModel alloc] initWithSpecialOffers:model.title
                                                                      content:model.desc
                                                                  activityUrl:model.imgUrl
                                                                   activityId:model.id
                                                                      groupId:nil//QWGLOBALMANAGER.configure.groupId
                                                                   branchLogo:nil//QWGLOBALMANAGER.configure.avatarUrl
                                                                       sender:self.messageSender
                                                                    timestamp:[NSDate date]
                                                                         UUID:[XMPPStream generateUUID]];
    [self sendMessage:activityModel messageBodyType:MessageMediaTypeMedicineSpecialOffers];
    NSString *replyText = [QWGLOBALMANAGER removeSpace:dict[@"replyText"]];
    if(!StrIsEmpty(replyText)){ //如果有备注信息，则新发一个文本消息
        MessageModel *replyTextMessageModel = [[MessageModel alloc] initWithText:replyText
                                                                          sender:self.messageSender
                                                                       timestamp:[NSDate date]
                                                                            UUID:[XMPPStream generateUUID]];
        replyTextMessageModel.sended = MessageDeliveryState_Delivering;
        [msgCenter addMessage:replyTextMessageModel];
        [self performSelector:@selector(sendMarketActivityTextMessageWithHTTP:) withObject:replyTextMessageModel afterDelay:2.0f];
    }
}
//发送营销活动时，如果有备注，则新发一个备注文本消息
- (void)sendMarketActivityTextMessageWithHTTP:(MessageModel *)model
{
    [msgCenter sendMessageWithoutMessageQueue:model success:^(id successObj) {
        [self messageToPharMsg:model send:MessageDeliveryState_Delivered ];
        [self.tableMain reloadData];
    } failure:^(id failureObj) {
        [self.tableMain reloadData];
        [self messageToPharMsg:model send:MessageDeliveryState_Failure ];
    }];
    
}

#pragma mark
#pragma mark 初始化表情emotionManagerView
- (XHEmotionManagerView *)emotionManagerView {
    if (!_emotionManagerView) {
        XHEmotionManagerView *emotionManagerView = [[XHEmotionManagerView alloc] initWithFrame:CGRectMake(0, kViewHeight, CGRectGetWidth(self.view.bounds), kEmojiKeyboardHeight)];
        emotionManagerView.delegate = self;
        emotionManagerView.dataSource = self;
        emotionManagerView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        emotionManagerView.alpha = 0.0;
        [self.view addSubview:emotionManagerView];
        [emotionManagerView.emotionSectionBar.storeManagerItemButton addTarget:self action:@selector(didSendEmojiTextMessage:) forControlEvents:UIControlEventTouchDown];
        _emotionManagerView.userInteractionEnabled = YES;
        _emotionManagerView = emotionManagerView;
        
    }
    [self.view bringSubviewToFront:_emotionManagerView];
    return _emotionManagerView;
}
/**
 *  初始化表情manager,最好能做成异步(暂时不处理)
 */
- (void)setUpEmojiManager
{
    NSString *emojiPath = [[NSBundle mainBundle] pathForResource:@"expressionImage_custom" ofType:@"plist"];
    NSMutableDictionary *emotionDict = [[NSMutableDictionary alloc] initWithContentsOfFile:emojiPath];
    NSArray *allKeys = [emotionDict allKeys];
    XHEmotionManager *emotionManager = [[XHEmotionManager alloc] init];
    NSMutableArray *emotionManagers = [NSMutableArray arrayWithCapacity:100];
    
#define ROW_NUM     3
#define COLUMN_NUM  7
    for(NSUInteger index = 0; index < [allKeys count]; ++index)
    {
        NSString *key = allKeys[index];
        if(index != 0 && (index % (ROW_NUM * COLUMN_NUM - 1)) == 0){
            [emotionManager.emotions addObject:[self addDeleteItem]];
        }
        XHEmotionManager *subEmotion = [[XHEmotionManager alloc] init];
        subEmotion.emotionName = key;
        subEmotion.imageName = emotionDict[key];
        [emotionManager.emotions addObject:subEmotion];
        if (index == [allKeys count] - 1)
        {
            [emotionManager.emotions addObject:[self addDeleteItem]];
        }
    }
    [emotionManagers addObject:emotionManager];
    self.emotionManagers = emotionManagers;
    [self.emotionManagerView reloadData];
}

- (XHEmotionManager *)addDeleteItem
{
    XHEmotionManager *subEmotion = [[XHEmotionManager alloc] init];
    subEmotion.emotionName = @"删除";
    subEmotion.imageName = @"backFaceSelect";
    return subEmotion;
}

#pragma mark - XHVoiceRecordHUD Helper Method
- (void)didChangeSendVoiceAction:(BOOL)changed
{
    DebugLog(@"%s",__FUNCTION__);
    [self scrollToBottomAnimated:YES];
    if (changed) {
        self.textViewInputViewType = XHInputViewTypeVoice;
        [self layoutOtherMenuViewHide:NO fromInputView:NO];
        [self scrollToBottomAnimated:YES];
    } else {
        [self.messageInputView.inputTextView becomeFirstResponder];
    }
}

- (XHVoiceRecordHelper *)voiceRecordHelper {
    if (!_voiceRecordHelper) {
        _isMaxTimeStop = NO;
        
        WEAKSELF
        _voiceRecordHelper = [[XHVoiceRecordHelper alloc] init];
        _voiceRecordHelper.maxTimeStopRecorderCompletion = ^{
            DLog(@"已经达到最大限制时间了，进入下一步的提示");
            
            // Unselect and unhilight the hold down button, and set isMaxTimeStop to YES.
            UIButton *holdDown = weakSelf.messageInputView.holdDownButton;
            holdDown.selected = NO;
            holdDown.highlighted = NO;
            weakSelf.isMaxTimeStop = YES;
            
            [weakSelf finishRecorded];
        };
        _voiceRecordHelper.peakPowerForChannel = ^(float peakPowerForChannel,float remainTime) {
            [weakSelf.voiceRecordHUD setPeakPower:peakPowerForChannel remainTime:remainTime];
        };
        _voiceRecordHelper.maxRecordTime = kVoiceRecorderTotalTime;
    }
    return _voiceRecordHelper;
}

- (XHVoiceRecordHUD *)voiceRecordHUD {
    if (!_voiceRecordHUD) {
        _voiceRecordHUD = [[XHVoiceRecordHUD alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
    }
    return _voiceRecordHUD;
}

#pragma mark - Voice Recording Helper Method

- (NSString *)getRecorderPath {
    NSString *recorderPath = nil;
    recorderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    recorderPath = [recorderPath stringByAppendingFormat:@"%@-MySound.caf", [dateFormatter stringFromDate:now]];
    return recorderPath;
}

#pragma mark - XHVoiceRecordHUD Helper Method

#pragma mark - Voice Recording Helper Method

- (void)prepareRecordWithCompletion:(XHPrepareRecorderCompletion)completion {
    [self.voiceRecordHelper prepareRecordingWithPath:[self getRecorderPath] prepareRecorderCompletion:completion];
}

- (void)startRecord {
    [self.voiceRecordHUD startRecordingHUDAtView:self.view];
    [self.voiceRecordHelper startRecordingWithStartRecorderCompletion:^{
        if(playingMessageModel) {
            playingMessageModel.audioPlaying = NO;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[msgCenter getMessageIndex:playingMessageModel] inSection:0];
            ChatTableViewCell *cell = (ChatTableViewCell *)[self.tableMain cellForRowAtIndexPath:indexPath];
            [cell stopVoicePlay];
            [[XHAudioPlayerHelper shareInstance] stopAudio];
            playingMessageModel = nil;
        }
    }];
}

- (void)finishRecorded {
    WEAKSELF
    [self.voiceRecordHUD stopRecordCompled:^(BOOL fnished) {
        weakSelf.voiceRecordHUD = nil;
    }];
    [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
        if([weakSelf.voiceRecordHelper.recordDuration doubleValue] < 1.0) {
            [SVProgressHUD showErrorWithStatus:@"录音时间过短!" duration:0.8];
            return;
        }
        NSString *UUID = [XMPPStream generateUUID];
        NSData *amrData = [weakSelf.voiceRecordHelper convertCafToAmr:[NSData dataWithContentsOfFile:weakSelf.voiceRecordHelper.recordPath]];
        NSString *audioPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/%@/Voice/%@.amr",QWGLOBALMANAGER.configure.userName,UUID]];
        [amrData writeToFile:audioPath atomically:YES];
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:weakSelf.voiceRecordHelper.recordPath error:nil];
        [self didSendAudio:@"[语音]"
                 voicePath:audioPath
                  audioUrl:nil
                  duartion:weakSelf.voiceRecordHelper.recordDuration
                fromSender:self.messageSender
                    onDate:[NSDate date]
                      UUID:UUID];
    }];
}

/**
 *  发送语音的回调方法
 *
 *  @param text              语音文本
 *  @param audioUrl          语音地址
 *  @param duartion          语音长度
 *  @param sender            发送者
 *  @param date              发送时间
 */
- (void)didSendAudio:(NSString *)text
           voicePath:(NSString *)voicePath
            audioUrl:(NSString *)audioUrl
            duartion:(NSString *)duartion
          fromSender:(NSString *)sender
              onDate:(NSDate *)date
                UUID:(NSString *)UUID
{
    MessageModel *messageModel = [[MessageModel alloc] initWithVoicePath:voicePath
                                                                voiceUrl:audioUrl
                                                           voiceDuration:duartion
                                                                  sender:sender
                                                               timestamp:date UUID:UUID];
    [self sendMessage:messageModel messageBodyType:MessageMediaTypeVoice];
}
- (void)pauseRecord {
    [self.voiceRecordHUD pauseRecord];
}

- (void)resumeRecord {
    [self.voiceRecordHUD resaueRecord];
}

- (void)cancelRecord {
    WEAKSELF
    [self.voiceRecordHUD cancelRecordCompled:^(BOOL fnished) {
        weakSelf.voiceRecordHUD = nil;
    }];
    [self.voiceRecordHelper cancelledDeleteWithCompletion:^{
        
    }];
}
- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion {
    [self prepareRecordWithCompletion:completion];
}

- (void)didStartRecordingVoiceAction {
    [self startRecord];
}

- (void)didCancelRecordingVoiceAction {
    [self cancelRecord];
}

- (void)didFinishRecoingVoiceAction {
    if (self.isMaxTimeStop == NO) {
        [self finishRecorded];
    } else {
        self.isMaxTimeStop = NO;
    }
}

- (void)didDragOutsideAction {
    [self resumeRecord];
}

- (void)didDragInsideAction {
    [self pauseRecord];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == XPalertResendIdentifier) {
        if (buttonIndex == 0) {
            
        } else if (buttonIndex == 1) {
            // 重发
            if (self.dicNeedResend) {
                MessageModel *model=[self.dicNeedResend objectForKey:@"kShouldResendModel"];
                switch (model.messageMediaType) {
                    case MessageMediaTypeText:
                    {
                        [msgCenter resendMessage:model success:^(id successObj) {
                            [self messageToPharMsg:model send:MessageDeliveryState_Delivered];
                            [self.tableMain reloadData];
                        } failure:^(id failureObj) {
                            [self messageToPharMsg:model send:MessageDeliveryState_Failure];
                        [self.tableMain reloadData];
                        }];
                        break;
                    }
                    case MessageMediaTypePhoto:
                    {
                        [msgCenter resendFileMessage:model success:^(id successObj) {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[msgCenter getMessageIndex:model] inSection:0];
                            ChatOutgoingTableViewCell *cell = (ChatOutgoingTableViewCell *)[self.tableMain cellForRowAtIndexPath:indexPath];
                            ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.activeShow.hidden = YES;
                            ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.hidden = YES;
                            ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.progressLabel.text = [NSString stringWithFormat:@"%d%@",0,@"%"];
                            [self messageToPharMsg:model send:MessageDeliveryState_Delivered];
                            [self.tableMain reloadData];

                        } failure:^(id failureObj) {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[msgCenter getMessageIndex:model] inSection:0];
                            ChatOutgoingTableViewCell *cell = (ChatOutgoingTableViewCell *)[self.tableMain cellForRowAtIndexPath:indexPath];
                            
                            ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.activeShow.hidden = YES;
                            ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.hidden = YES;
                            ((PhotoChatBubbleView *)cell.bubbleView).dpMeterView.progressLabel.text = [NSString stringWithFormat:@"%d%@",0,@"%"];
                            [self.tableMain reloadData];
                            [self messageToPharMsg:model  send:MessageDeliveryState_Failure];
                        } uploadProgressBlock:^(MessageModel *target, float progress) {
                            
                            [self progressUpdate:model.UUID progress:progress];
                            
                        }];
                        break;
                    }
                    case MessageMediaTypeVoice:
                    {
                        [msgCenter resendFileMessage:model success:^(id successObj) {
                            [self messageToPharMsg:model send:MessageDeliveryState_Delivered];
                            [self.tableMain reloadData];
                        } failure:^(id failureObj) {
                            [self messageToPharMsg:model send:MessageDeliveryState_Failure];
                            [self.tableMain reloadData];
                        } uploadProgressBlock:NULL];
                        break;
                    }
                    default:
                    {
                        [msgCenter resendMessage:model success:^(id successObj) {
                            [self messageToPharMsg:model send:MessageDeliveryState_Delivered];
                            [self.tableMain reloadData];
                        } failure:^(id failureObj) {
                            [self messageToPharMsg:model send:MessageDeliveryState_Failure];
                            [self.tableMain reloadData];
                        }];
                        break;
                    }
                }
            }
        }
    } else if (alertView.tag == XPalertDeleteIdentifier) {
        if (buttonIndex == 1) {
            // 删除
            if (self.dicNeedDelete) {
                MessageModel *model=[self.dicNeedDelete objectForKey:@"kShouldDeleteModel"];
                
                if(playingMessageModel && (model == playingMessageModel))
                    [self stopMusicInOtherBubblePressed];
                [msgCenter removeMessage:model success:^(id successObj) {
                    //
                } failure:^(id failureObj) {
                    //
                }];
            }
        }
    }
}

- (void)initKeyboardBlock
{
    WEAKSELF
    if (allowsPanToDismissKeyboard) {
        // 控制输入工具条的位置块
        void (^AnimationForMessageInputViewAtPoint)(CGPoint point) = ^(CGPoint point) {
            CGRect inputViewFrame = weakSelf.messageInputView.frame;
            CGPoint keyboardOrigin = [weakSelf.view convertPoint:point fromView:nil];
            inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
            weakSelf.messageInputView.frame = inputViewFrame;
        };
        
        self.tableMain.keyboardDidScrollToPoint = ^(CGPoint point) {
            if (weakSelf.textViewInputViewType == XHInputViewTypeText)
                AnimationForMessageInputViewAtPoint(point);
        };
        
        self.tableMain.keyboardWillSnapBackToPoint = ^(CGPoint point) {
            if (weakSelf.textViewInputViewType == XHInputViewTypeText)
                AnimationForMessageInputViewAtPoint(point);
        };
        
        self.tableMain.keyboardWillBeDismissed = ^() {
            CGRect inputViewFrame = weakSelf.messageInputView.frame;
            inputViewFrame.origin.y = weakSelf.view.bounds.size.height - inputViewFrame.size.height;
            weakSelf.messageInputView.frame = inputViewFrame;
        };
    }
    
    // block回调键盘通知
    self.tableMain.keyboardWillChange = ^(CGRect keyboardRect, UIViewAnimationOptions options, double duration, BOOL showKeyborad) {
        if (weakSelf.textViewInputViewType == XHInputViewTypeText) {
            [UIView animateWithDuration:duration
                                  delay:0.0
                                options:options
                             animations:^{
                                 CGFloat keyboardY = [weakSelf.view convertRect:keyboardRect fromView:nil].origin.y;
                                 
                                 CGRect inputViewFrame = weakSelf.messageInputView.frame;
                                 CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
                                 
                                 // for ipad modal form presentations
                                 CGFloat messageViewFrameBottom = weakSelf.view.frame.size.height - inputViewFrame.size.height;
                                 if (inputViewFrameY > messageViewFrameBottom)
                                     inputViewFrameY = messageViewFrameBottom;
                                 
                                 weakSelf.messageInputView.frame = CGRectMake(inputViewFrame.origin.x,
                                                                              inputViewFrameY,
                                                                              inputViewFrame.size.width,
                                                                              inputViewFrame.size.height);
                                 //ok
                                 [weakSelf setTableViewInsetsWithBottomValue:weakSelf.view.frame.size.height
                                  - weakSelf.messageInputView.frame.origin.y - kOffSet];
                                 if (showKeyborad)
                                     [weakSelf scrollToBottomAnimated:NO];
                             }
                             completion:nil];
        }
    };
    
    self.tableMain.keyboardDidChange = ^(BOOL didShowed) {
        if ([weakSelf.messageInputView.inputTextView isFirstResponder]) {
            if (didShowed) {
                if (weakSelf.textViewInputViewType == XHInputViewTypeText) {
                    weakSelf.shareMenuView.alpha = 0.0;
                    weakSelf.emotionManagerView.alpha = 0.0;
                }
            }
        }
    };
    
    self.tableMain.keyboardDidHide = ^() {
        [weakSelf.messageInputView.inputTextView resignFirstResponder];
    };
}
//- (void)resendMessage:(MessageModel*)model success:(IMSuccessBlock)success failure:(IMFailureBlock)failure;

#pragma mark - Other Menu View Frame Helper Mehtod
/**
 *  Description
 *
 *  @param hide 是否隐藏
 *  @param from
 */
- (void)layoutOtherMenuViewHide:(BOOL)hide fromInputView:(BOOL)from {
    [self.messageInputView.inputTextView resignFirstResponder];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __block CGRect inputViewFrame = self.messageInputView.frame;
        __block CGRect otherMenuViewFrame;
        
        void (^InputViewAnimation)(BOOL hide) = ^(BOOL hide) {
            inputViewFrame.origin.y = (hide ? (CGRectGetHeight(self.view.bounds) - CGRectGetHeight(inputViewFrame)) : (CGRectGetMinY(otherMenuViewFrame) - CGRectGetHeight(inputViewFrame)));
            self.messageInputView.frame = inputViewFrame;
        };
        
        void (^EmotionManagerViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = self.emotionManagerView.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.view.frame) : (CGRectGetHeight(self.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
            self.emotionManagerView.alpha = !hide;
            self.emotionManagerView.frame = otherMenuViewFrame;
        };
        
        void (^ShareMenuViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = self.shareMenuView.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.view.frame) : (CGRectGetHeight(self.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
            self.shareMenuView.alpha = !hide;
            self.shareMenuView.frame = otherMenuViewFrame;
        };
        
        if (hide) {
            switch (self.textViewInputViewType) {
                case XHInputViewTypeEmotion: {
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case XHInputViewTypeShareMenu: {
                    ShareMenuViewAnimation(hide);
                    break;
                }
                default:
                    break;
            }
        } else {
            
            // 这里需要注意block的执行顺序，因为otherMenuViewFrame是公用的对象，所以对于被隐藏的Menu的frame的origin的y会是最大值
            switch (self.textViewInputViewType) {
                case XHInputViewTypeEmotion: {
                    // 1、先隐藏和自己无关的View
                    ShareMenuViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case XHInputViewTypeShareMenu: {
                    // 1、先隐藏和自己无关的View
                    EmotionManagerViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    ShareMenuViewAnimation(hide);
                    break;
                }
                case XHInputViewTypeVoice:{
                    ShareMenuViewAnimation(!hide);
                    EmotionManagerViewAnimation(!hide);
                    break;
                }
                default:
                    break;
            }
        }
        
        InputViewAnimation(hide);
        //        CGFloat offset = self.view.frame.size.height - self.messageInputView.frame.origin.y - kOffSet;
        CGFloat offset = self.view.frame.size.height - self.messageInputView.frame.origin.y - 42;
        DDLogVerbose(@"offset = %f",offset);
        [self setTableViewInsetsWithBottomValue:offset];
        
        [self scrollToBottomAnimated:NO];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Key-value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.messageInputView.inputTextView && [keyPath isEqualToString:@"contentSize"])
    {
        [self layoutAndAnimateMessageInputTextView:object];
    }
}

#pragma mark - Layout Message Input View Helper Method

- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView {
    CGFloat maxHeight = [XHMessageInputView maxHeight];
    
    CGFloat contentH = [self getTextViewContentH:textView];
    
    BOOL isShrinking = contentH < self.previousTextViewContentHeight;
    CGFloat changeInHeight = contentH - _previousTextViewContentHeight;
    
    if (!isShrinking && (self.previousTextViewContentHeight == maxHeight || textView.text.length == 0)) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    
    if (changeInHeight != 0.0f) {
        [UIView animateWithDuration:0.25f animations:^{
                             [self setTableViewInsetsWithBottomValue:self.tableMain.contentInset.bottom + changeInHeight];
                             [self scrollToBottomAnimated:NO];
                             
                             if (isShrinking) {
                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                                     self.previousTextViewContentHeight = MIN(contentH, maxHeight);
                                 }
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [self.messageInputView adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             CGRect inputViewFrame = self.messageInputView.frame;
                             self.messageInputView.frame = CGRectMake(0.0f,
                                                                      inputViewFrame.origin.y - changeInHeight,
                                                                      inputViewFrame.size.width,
                                                                      inputViewFrame.size.height + changeInHeight);
                             if (!isShrinking) {
                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                                     self.previousTextViewContentHeight = MIN(contentH, maxHeight);
                                 }
                                 // growing the view, animate the text view frame AFTER input view frame
                                 [self.messageInputView adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
        
        self.previousTextViewContentHeight = MIN(contentH, maxHeight);
    }
    
    // Once we reached the max height, we have to consider the bottom offset for the text view.
    // To make visible the last line, again we have to set the content offset.
    if (self.previousTextViewContentHeight == maxHeight) {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime,
                       dispatch_get_main_queue(),
                       ^(void) {
//                           CGPoint bottomOffset = CGPointMake(0.0f, );
                           CGPoint bottomOffset = CGPointMake(0.0f, contentH - textView.bounds.size.height/2 - 13);
                           [textView setContentOffset:bottomOffset animated:YES];
                       });
    }
}

#pragma mark - XHMessageInputView Delegate
- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView
{
    self.textViewInputViewType = XHInputViewTypeText;
}

- (void)inputTextViewDidBeginEditing:(XHMessageTextView *)messageInputTextView
{
    if (!self.previousTextViewContentHeight)
        self.previousTextViewContentHeight = [self getTextViewContentH:messageInputTextView];
}
//获取textView的高度
- (CGFloat)getTextViewContentH:(UITextView *)textView {
    if (iOSv7) {
//        return ceilf([textView sizeThatFits:textView.frame.size].height);
        CGRect textFrame=[[textView layoutManager] usedRectForTextContainer:[textView textContainer]];
        return textFrame.size.height - 18;
    } else {
        return textView.contentSize.height;
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
}

- (void)removeShowOnceMessage
{
    NSString *where = [NSString stringWithFormat:@"messagetype = '%ld' or messagetype = '%ld'",(long)MessageMediaTypeMedicineShowOnce,(long)MessageMediaTypeMedicineSpecialOffersShowOnce];
    [QWXPMessage deleteObjFromDBWithWhere:where];
}

#pragma mark
#pragma mark 点击返回
- (IBAction)popVCAction:(id)sender{
    
    [[XHAudioPlayerHelper shareInstance] setDelegate:nil];
    
    [QWXPMessage updateSetToDB:@"issend = '3'" WithWhere:@"issend = '1'"];
    [self removeShowOnceMessage];
    __block UIViewController *popViewController = nil;
    __block NSArray *viewControllers = self.navigationController.viewControllers;
    [viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        if ([vc isKindOfClass:[ConsultForFreeRootViewController class]]) {
            *stop = YES;
            if (idx > 0) {
                popViewController = viewControllers[idx - 1];
            }
        }
    }];
    
    if(popViewController) {
        [self.navigationController popToViewController:popViewController animated:YES];
    }else{
        [super popVCAction:sender];
    }

    [msgCenter deleteMessagesByType:MessageMediaTypeMedicineShowOnce];
    [msgCenter deleteMessagesByType:MessageMediaTypeMedicineSpecialOffersShowOnce];
    [msgCenter stop];
    
 }

#pragma mark
#pragma mark 接收通知
-(void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj
{
    if (type == NotimessageIMTabelUpdate) {
        if (self.didScrollOrReload)
        {
            [self.tableMain reloadData];
        }
        else
        {
            self.didScrollOrLoad = YES;
        }
//        MessageModel  *model =  data;
//        model = [msgCenter getMessageWithUUID:model.UUID];
//        NSInteger index = [msgCenter getMessageIndex:model];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
// 
//            if (indexPath) {
////                 dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableMain beginUpdates];
//                [self.tableMain reloadRowsAtIndexPaths:@[indexPath]
//                                      withRowAnimation:UITableViewRowAnimationNone];
//                [self.tableMain endUpdates];
//           
////                });
//         }
    }else if (type == NotifAppDidEnterBackground || type == NOtifAppversionNew) {
        [self stopMusicInOtherBubblePressed];
        if(self.voiceRecordHelper.recorder.isRecording) {
            WEAKSELF
            [self.voiceRecordHUD stopRecordCompled:^(BOOL fnished) {
                weakSelf.voiceRecordHUD = nil;
            }];
            [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
                
            }];
        }
    }
}
@end
