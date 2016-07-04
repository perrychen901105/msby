//
//  MsgNotiListViewController.m
//  APP
//
//  Created by PerryChen on 6/16/15.
//  Copyright (c) 2015 carret. All rights reserved.
//

#import "MsgNotiListViewController.h"
#import "MsgNotifyListCell.h"
#import "ConsultPTP.h"
#import "ConsultPTPR.h"
#import "ConsultPTPModel.h"
#import "SVProgressHUD.h"
#import "QWGlobalManager.h"
#import "QWUnreadCountModel.h"
#import "ReturnIndexView.h"
#import "XPChatViewController.h"
#import "EvaluateStoreViewController.h"
#import "MGSwipeButton.h"
#import "Consult.h"
@interface MsgNotiListViewController ()<UITableViewDataSource, UITableViewDelegate,MGSwipeTableCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tbViewContent;
@property (strong, nonatomic) NSMutableArray *arrNotiList;
@property (strong, nonatomic) NSMutableArray *arrServer;
@property (nonatomic, assign) BOOL isScrolling;
@property (strong ,nonatomic) NSMutableDictionary *controllerArr;
@property (nonatomic, strong) ReturnIndexView *indexView;
@property (nonatomic, assign) BOOL isClickedCell;
@end

@implementation MsgNotiListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof (self) weakSelf = self;
    self.arrNotiList = [@[] mutableCopy];
//    [self setUpRightItem];
//    [self.tbViewContent addHeaderWithCallback:^{
//        
//        if(QWGLOBALMANAGER.currentNetWork == NotReachable)
//        {
//            [SVProgressHUD showErrorWithStatus:@"网络未连接，请稍后再试" duration:0.8f];
//            return;
//        }
//        [weakSelf refreshConsultList];
//    }];
    [self enableSimpleRefresh:self.tbViewContent block:^(SRRefreshView *sender) {
        if(QWGLOBALMANAGER.currentNetWork == NotReachable)
        {
            [SVProgressHUD showErrorWithStatus:@"网络未连接，请稍后再试" duration:0.8f];
            return;
        }
        [weakSelf refreshConsultList];
    }];
    
    
    [self getCachedMessages];
    [self.tbViewContent reloadData];
    
    self.navigationItem.title = @"免费咨询通知列表";
    self.controllerArr = [NSMutableDictionary dictionary];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self getCachedMessages];
    [self.tbViewContent reloadData];
//    [self.tbViewContent headerBeginRefreshing];
    [self refreshConsultList];
    self.isClickedCell = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpRightItem
{
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -6;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-unfold.PNG"] style:UIBarButtonItemStylePlain target:self action:@selector(returnIndex)];
    self.navigationItem.rightBarButtonItems = @[fixed,rightItem];
}
- (void)returnIndex
{
    self.indexView = [ReturnIndexView sharedManagerWithImage:@[@"icon home.PNG"] title:@[@"首页"] passValue:-1];
    self.indexView.delegate = self;
    [self.indexView show];
}
- (void)RetunIndexView:(ReturnIndexView *)ReturnIndexView didSelectedIndex:(NSIndexPath *)indexPath
{
    [self.indexView hide];
    if (indexPath.row == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self performSelector:@selector(delayPopToHome) withObject:nil afterDelay:0.01];
    }
}

- (void)delayPopToHome
{
    [QWGLOBALMANAGER.tabBar setSelectedIndex:0];
}

#pragma mark - cache methods
- (void)getCachedMessages
{
    self.arrNotiList = [NSMutableArray arrayWithArray:[MsgNotifyListModel getArrayFromDBWithWhere:nil WithorderBy:@" consultLatestTime desc"]];
}

#pragma mark - Http service
- (void)refreshConsultList
{
    //全量拉取消息盒子数据
    ConsultCustomerModelR *modelR = [ConsultCustomerModelR new];
    modelR.token = QWGLOBALMANAGER.configure.userToken;
    [Consult getNoticeListByCustomerWithParam:modelR success:^(ConsultCustomerListModel *responModel) {
        [self.tbViewContent headerEndRefreshing];
        ConsultCustomerListModel *listModel = (ConsultCustomerListModel *)responModel;
        [self removeInfoView];
        if (listModel.consults.count > 0) {
            [self.arrServer removeAllObjects];
            self.arrServer = [listModel.consults mutableCopy];
            
            [self syncDBtoLatest:listModel];
        } else {
            [self showInfoView:@"暂无咨询问题" image:@"ic_img_fail"];
        }
        
    } failure:^(HttpException *e) {
        [self.tbViewContent headerEndRefreshing];
    }];
}

- (void)syncDBtoLatest:(ConsultCustomerListModel *)listModel
{
    __weak typeof (self) weakSelf = self;
    NSMutableArray *arrLoaded = [NSMutableArray arrayWithArray:listModel.consults];
    NSMutableArray *arrCached = [NSMutableArray arrayWithArray:[MsgNotifyListModel getArrayFromDBWithWhere:nil]];
    NSMutableArray *arrNeedAdded = [@[] mutableCopy];
    NSMutableArray *arrNeedDeleted = [@[] mutableCopy];
    // 删除服务器上没有，本地有的缓存数据
    [arrCached enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MsgNotifyListModel *modelHis = (MsgNotifyListModel *)obj;
        BOOL isExist = NO;
        for (CustomerConsultVoModel *modelConsult in arrLoaded) {
            if ([modelConsult.consultId intValue] == [modelHis.relatedid intValue]) {
                isExist = YES;
                break;
            }
        }
        if (!isExist) {
            [arrNeedDeleted addObject:modelHis];
        }
    }];
    for (MsgNotifyListModel *modelHis in arrNeedDeleted) {
        [MsgNotifyListModel deleteObjFromDBWithKey:[NSString stringWithFormat:@"%@",modelHis.relatedid]];
    }
    // 更新数据问题
    arrCached = [NSMutableArray arrayWithArray:[MsgNotifyListModel getArrayFromDBWithWhere:nil WithorderBy:@" consultLatestTime desc"]];
    __block NSInteger count = 0;
    [arrLoaded enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CustomerConsultVoModel *modelConsult = (CustomerConsultVoModel *)obj;
        NSUInteger indexFound = [weakSelf valueExists:@"relatedid" withValue:[NSString stringWithFormat:@"%@",modelConsult.consultId] withArr:arrCached];
        if (indexFound != NSNotFound) {
            // 更新Model
            MsgNotifyListModel *modelMessage = [arrCached objectAtIndex:indexFound];
            [QWGLOBALMANAGER convertConsultModelToNotifyList:modelConsult withModelMessage:&modelMessage];
        } else {
            MsgNotifyListModel *modelMessage = [QWGLOBALMANAGER createNewMsgNotifyList:modelConsult];
            [arrNeedAdded addObject:modelMessage];
        }
    }];
    [arrCached addObjectsFromArray:arrNeedAdded];
    for (int i = 0; i < arrCached.count; i++) {
        MsgNotifyListModel *model = (MsgNotifyListModel *)arrCached[i];
        if (([model.unreadCounts intValue]>0)||([model.systemUnreadCounts intValue]>0)) {
            model.showRedPoint = @"1";
            count++;
        }
        [MsgNotifyListModel updateObjToDB:model WithKey:model.relatedid];
    }
//    PharMsgModel *modelConsultList = [PharMsgModel getobj]
//    if (<#condition#>) {
//        <#statements#>
//    }
//    QWUnreadCountModel *modelUnread = [QWGLOBALMANAGER getUnreadModel];
//    modelUnread.count_NotifyListUnread = [NSString stringWithFormat:@"%d",count];
//    [QWUnreadCountModel updateObjToDB:modelUnread WithKey:QWGLOBALMANAGER.configure.passPort];
//    
//    [QWGLOBALMANAGER updateRedPoint];
    
    [self getCachedMessages];
    [self.tbViewContent reloadData];
}

#pragma mark - UITableView methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MsgNotifyListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MsgNotifyListCell"];
    MsgNotifyListModel *msgModel = self.arrNotiList[indexPath.row];
       cell.swipeDelegate = self;
    [cell setCell:msgModel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static MsgNotifyListCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [tableView dequeueReusableCellWithIdentifier:@"MsgNotifyListCell"];
    });
    MsgNotifyListModel *model = [self.arrNotiList objectAtIndex:indexPath.row];
    [sizingCell setCell:model];
   
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(sizingCell.bounds));
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    CGSize sizeFinal = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return sizeFinal.height+1.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrNotiList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isClickedCell) {
        return;
    }
    if (QWGLOBALMANAGER.loginStatus) {
        MsgNotifyListModel* msg = self.arrNotiList[indexPath.row];

        XPChatViewController *messageViewController = [[UIStoryboard storyboardWithName:@"XPChatViewController" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"XPChatViewController"];
        if(msg) {
            // 更新红点逻辑
//            QWGLOBALMANAGER.unReadCount = QWGLOBALMANAGER.unReadCount - [msg.showRedPoint intValue];
//            QWUnreadCountModel *modelUnread = [QWGLOBALMANAGER getUnreadModel];
//            NSInteger intTotalUnread = [modelUnread.count_NotifyListUnread intValue];
//            intTotalUnread -= [msg.showRedPoint intValue];
            
            PharMsgModel *modelMsg = [PharMsgModel getObjFromDBWithWhere:@"type = 2"];
            modelMsg.unreadCounts = [NSString stringWithFormat:@"%d",[modelMsg.unreadCounts intValue]-[msg.showRedPoint intValue]];
            if ([modelMsg.unreadCounts intValue] < 0) {
                modelMsg.unreadCounts = @"0";
            }
            [PharMsgModel updateToDB:modelMsg where:@"type = 2"];
            msg.showRedPoint = @"0";
            [MsgNotifyListModel updateObjToDB:msg WithKey:msg.relatedid];
            HistoryMessages *hisModel = [HistoryMessages getObjFromDBWithKey:msg.relatedid];
            if (hisModel) {
                hisModel.unreadCounts = @"0";
                hisModel.systemUnreadCounts = @"0";
                hisModel.isShowRedPoint = @"0";
                [HistoryMessages updateObjToDB:hisModel WithKey:hisModel.relatedid];
            }

 
//            modelUnread.count_NotifyListUnread = [NSString stringWithFormat:@"%d",intTotalUnread];
//            [QWUnreadCountModel updateObjToDB:modelUnread WithKey:QWGLOBALMANAGER.configure.passPort];
//            [QWGLOBALMANAGER updateRedPoint];
        }
        HistoryMessages *historyMsg = [HistoryMessages new];
        historyMsg.relatedid = msg.relatedid;
        historyMsg.body = msg.title;
        historyMsg.timestamp = msg.consultLatestTime;
        historyMsg.consultStatus = msg.consultStatus;
        historyMsg.groupName = msg.pharShortName;
        historyMsg.unreadCounts = msg.unreadCounts;
        historyMsg.consultMessage = msg.consultShowTitle;
        historyMsg.systemUnreadCounts = msg.systemUnreadCounts;
        historyMsg.avatarurl = msg.pharAvatarUrl;
        messageViewController.historyMsg = historyMsg;
        if ([msg.consultStatus intValue] == 1) {
            messageViewController.showType = MessageShowTypeNewCreate;
        }else if ([msg.consultStatus intValue] == 2) {
            messageViewController.showType = MessageShowTypeAnswering;
        } else if ([msg.consultStatus intValue] == 3) {
            messageViewController.showType = MessageShowTypeTimeout;
        } else {
            messageViewController.showType = MessageShowTypeClosed;
            ConsultItemReadModelR *modelReadR = [ConsultItemReadModelR new];
            modelReadR.token = QWGLOBALMANAGER.configure.userToken;
            modelReadR.consultId = msg.relatedid;
            modelReadR.detailIds = @"";
            [Consult updateConsultItemRead:modelReadR success:^(ConsultModel *responModel) {
                
            } failure:^(HttpException *e) {
                
            }];

            EvaluateStoreViewController *vcStore = [[EvaluateStoreViewController alloc] initWithNibName:@"EvaluateStoreViewController" bundle:nil];
            vcStore.hidesBottomBarWhenPushed = YES;
            vcStore.historyMsg = historyMsg;
            AppraiseByConsultModelR *modelR = [AppraiseByConsultModelR new];
            modelR.token = QWGLOBALMANAGER.configure.userToken;
            modelR.consultId = msg.relatedid;
            modelR.branchId = msg.branchId;
            modelR.branchName = msg.branchName;
            modelR.consultMessage = [NSString stringWithFormat:@"问题: %@",msg.title];
            vcStore.modelR = modelR;
            self.isClickedCell = YES;
            [self.navigationController pushViewController:vcStore animated:YES];
            return;
        }
        messageViewController.hidesBottomBarWhenPushed = YES;
        messageViewController.messageSender = [NSString stringWithFormat:@"%@",msg.relatedid];
        messageViewController.avatarUrl = msg.pharAvatarUrl;
        self.isClickedCell = YES;
        [self.navigationController pushViewController:messageViewController animated:YES];
    }
}

- (void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj
{
    if (type == NotiMessageUpdateMsgNotiList) {
        [self getCachedMessages];
        [self.tbViewContent reloadData];
    } else if (type == NotiReleaseTimer) {
        [self.controllerArr removeAllObjects];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//  add  by sehn

-(NSArray *) createRightButtons: (int) number
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@"删除"};
    UIColor * colors[2] = {[UIColor redColor]};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            return YES;
        }];
        if(i == 1) {
            [button setTitleColor:RGBHex(qwColor5) forState:UIControlStateNormal];
        }
        [result addObject:button];
    }
    return result;
}



#pragma mark -
#pragma mark MGSwipeTableCellDelegate
-(NSArray*) swipeTableCell:(MGSwipeTableCell*)cell
  swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*)swipeSettings
         expansionSettings:(MGSwipeExpansionSettings*)expansionSettings;
{
    
    if (direction == MGSwipeDirectionRightToLeft)
    {
        
        return [self createRightButtons:1];
        
    }
    return nil;
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
                NSIndexPath *  indexPath = [self.tbViewContent indexPathForCell:cell];
    
    //删除事件
    if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
        
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        
        return NO;
    }
    
    MsgNotifyListModel  *boxModel = nil;
    
    boxModel = self.arrNotiList[indexPath.row];
    
    [MsgNotifyListModel deleteObjFromDBWithKey:[NSString stringWithFormat:@"%@",boxModel.relatedid]];
    [ self.arrNotiList removeObject:boxModel];
    
    [self.tbViewContent reloadData];
    RemoveByCustomerR * model = [RemoveByCustomerR new];
    model.consultId = boxModel.relatedid;
    model.token = QWGLOBALMANAGER.configure.userToken;
    
    [Consult removeByCustomer:model success:^(id ResModel) {
        
    } failure:^(HttpException *e) {
        
    }];
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否删除" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    alertView.delegate = self;
//    alertView.tag = indexPath.row;
//    [alertView show];
    
    
    
    return YES;
}

@end
