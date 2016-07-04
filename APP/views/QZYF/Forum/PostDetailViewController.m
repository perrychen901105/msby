//
//  PostDetailViewController.m
//  APP
//  帖子详情页面
//  接口相关
//  获取帖子详情 h5/team/postDetails
//  （调用频率）下拉刷新、 上拉加载、删除评论、截获登录成功或抢登或发帖成功通知、回复行为、（取消）关注行为
//  获取该专家|药师置顶的帖子api/team/queryTopPostId (一个专家|药师只能置顶一个帖子)
//  检查用户是否收藏了帖子：h5/collection/checkCollection
//  函数名称：loadData
//  置顶帖子 api/team/topPost
//  删除帖子 api/team/delPostInfo
//  举报 api/complaint/complaint
//  （取消）关注圈子 api/team/attentionTeam
//  帖子点赞：api/team/upVote
//  取消帖子点赞 api/team/upVoteRepeal
//  帖子评论的点赞功能 api/team/replyUpVote
//  帖子评论的取消点赞功能：api/team/replyUpVoteRepeal
//  帖子回复功能 api/team/postReply
//  用户收藏帖子：h5/collection/mbrCollection
//  用户取消收藏帖子：h5/collection/cancelCollection
//  删除评论：api/team/delReply
//  Created by Martin.Liu on 15/12/30.
//  Copyright © 2015年 carret. All rights reserved.
//

#import "PostDetailViewController.h"
#import "PostCommentTableCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UILabel+MAAttributeString.h"
#import "Forum.h"
#import "CustomPopListView.h"
#import "LoginViewController.h"
#import "SVProgressHUD.h"
#import "SendPostViewController.h"
#import "DisplayPostImageTextTableCell.h"
#import "UIImage+Tint.h"
#import "ExpertPageViewController.h"
#import "UserPageViewController.h"
#import "CircleDetailViewController.h"
#import "QWProgressHUD.h"
#import "NSString+MarCategory.h"
#import "QWSpecailInfoView.h"      // 帖子被删除提示view
#import "ConstraintsUtility.h"
#import "PostCommentViewController.h"   // 评论页面
#import "MAUILabel.h"
#import "MLEmojiLabel.h"
#import "WebDirectViewController.h"


#define PostReplyPerPageSize 10

#define AlertViewTag_DeletePost 1001
#define AlertViewTag_TopPost 2001
#define AlertViewTag_DeleteComment 3001
#define AlertViewTag_EditPost 4001
#define ReplyMaxNumber 500

#define NewPostCommentStyle  // 新的回帖方式

@interface QWPostReplyTest : BaseModel
@property (nonatomic, strong) NSString* replyerId;
@property (nonatomic, strong) NSString* replyerName;
@property (nonatomic, strong) NSString* replyContent;
@end
@implementation QWPostReplyTest

@end

@interface PostDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CustomPopListViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate,MLEmojiLabelDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *tableHearderView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraint_tableViewWidth;
@property (strong, nonatomic) IBOutlet UITableView *detailTableView;
@property (strong, nonatomic) IBOutlet UIView *detailTableHeaderView;

@property (strong, nonatomic) IBOutlet MAButtonWithTouchBlock *userInfoBtn;
@property (strong, nonatomic) IBOutlet UIImageView *userHeadImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *userLevelLabel;
@property (strong, nonatomic) IBOutlet UILabel *userPositionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userPositionImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraint_userPositionImgLeading;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraint_userPositionImgTrailing;

@property (strong, nonatomic) IBOutlet MAUILabel *userRemarkLabel;
@property (strong, nonatomic) IBOutlet UILabel *postSourceTipLabel;
@property (strong, nonatomic) IBOutlet UILabel *postSourceLabel;
@property (strong, nonatomic) IBOutlet UIButton *careBtn;
@property (strong, nonatomic) IBOutlet UILabel *postTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *postSendTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *postViewCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *postCommentCountLabel;

@property (strong, nonatomic) IBOutlet UIView *praiseContainerView;
@property (strong, nonatomic) IBOutlet UILabel *praiseTipLabel;
@property (strong, nonatomic) IBOutlet UIImageView *praiseImageView;
@property (strong, nonatomic) IBOutlet UILabel *praiseCountLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraint_bottomViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_praiseImageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_praiseImageHeight;

@property (strong, nonatomic) IBOutlet UITextField *replyTextField;
@property (strong, nonatomic) IBOutlet UIButton *favoriteBtn;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;


@property (strong, nonatomic) IBOutlet UIView *resendView;
@property (strong, nonatomic) IBOutlet UIButton *reSendBtn;
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;

- (IBAction)gotoCircleDetailVCBtnAction:(id)sender;
- (IBAction)careBtnAction:(id)sender;
// 赞帖子
- (IBAction)praisePostBtnAction:(id)sender;
- (IBAction)favoriteBtnAciton:(UIButton*)sender;
- (IBAction)shareBtnAction:(id)sender;
- (IBAction)reSendBtnAction:(id)sender;
- (IBAction)deleteBtnAction:(id)sender;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraint_posttitleWidth;

@property (strong, nonatomic) CustomPopListView* rightBtns;
@property (nonatomic, strong) NSMutableArray* postReplyArray;   // 回帖队列
//@property (nonatomic, strong) QWPostDetailModel* postDetail;
@property (nonatomic, strong) QWSpecailInfoView* specailInfoView;   // 帖子被删除页面
@property (nonatomic, strong) UIView* defaultView;                  // 第一次加载的时候的默认视图，为了挡住在加载数据之前的tableview的一些无效数据

@end

@implementation PostDetailViewController
{
    NSMutableArray* postContentArray;
//    NSArray* postReplyArray;
    QWPostReplyTest* tmpReplyModel;

    NSInteger fromIndex;
    BOOL canloadMore;
    
    BOOL hasRegisterCellNib;
    
    NSString* cancelPostId; // 取消置顶帖子的ID
    NSInteger deleteCommentIndex;  // 删除回复的cell的index
    
    // 3.1.1 增加一属性，如果发送失败则下拉刷新，上啦加载不请求接口
    BOOL sendFailed;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _showLink = NO;
    self.constraint_tableViewWidth.constant = APP_W;
    [self.view layoutIfNeeded];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    UINib* postCommentCellNib = [UINib nibWithNibName:@"PostCommentTableCell" bundle:nil];
    [self.tableView registerNib:postCommentCellNib forCellReuseIdentifier:@"PostCommentTableCell"];
    UINib* displayPostImagecellNib = [UINib nibWithNibName:@"DisplayPostImageTextTableCell" bundle:nil];
    [self.detailTableView registerNib:displayPostImagecellNib forCellReuseIdentifier:@"DisplayPostImageTextTableCell"];
    hasRegisterCellNib = YES;
    if (_postDetail) {
        self.postDetail = _postDetail;
    }
    else
    {
//        [self addDefaultCoverView];
        [self loadData];
    }
    [self configTableviewLoadView];
    
    /**
     *  3.1增加的，从h5外链进来present帖子详情，加一个返回按钮
     */
    if (self.navigationController == nil || self.navigationController.topViewController == self) {
        [self naviBackBotton];
    }
    
    
}

// 增加一个默认的覆盖页面
- (void)addDefaultCoverView
{
    self.defaultView = [[UIView alloc] init];
    self.defaultView.backgroundColor = RGBHex(qwColor11);
    [self.view addSubview:self.defaultView];
    PREPCONSTRAINTS(self.defaultView);
    ALIGN_TOPLEFT(self.defaultView, 0);
    ALIGN_BOTTOMRIGHT(self.defaultView, 0);
    
    UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc] init];
    [self.defaultView addSubview:indicatorView];
    [indicatorView startAnimating];
    PREPCONSTRAINTS(indicatorView);
    CENTER(indicatorView);
}

- (void)popVCAction:(id)sender
{
    // 从外链进入
    if (self.isBackToDismiss) {
        if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    [super popVCAction:sender];
    [QWGLOBALMANAGER statisticsEventId:@"x_tzxq_fh" withLable:@"帖子详情-返回" withParams:nil];
}

- (void)loadData
{
    __weak __typeof(self) weakSelf = self;
    if (!self.isSending) {
        if (QWGLOBALMANAGER.loginStatus) {
            CheckCollectPostR* checkCollectPostR = [CheckCollectPostR new];
            checkCollectPostR.token = QWGLOBALMANAGER.configure.userToken;
            checkCollectPostR.objID = self.postId;
            [Forum checkCollcetPost:checkCollectPostR success:^(BaseAPIModel *baseAPIModel) {
                weakSelf.favoriteBtn.selected = [baseAPIModel.apiStatus integerValue] == 1;
            } failure:^(HttpException *e) {
                
            }];
        }
        [self.tableView.footer setCanLoadMore:YES];
    }
    
    [self.postReplyArray removeAllObjects];
    GetPostDetailsR* getPostDetailR = [GetPostDetailsR new];
    getPostDetailR.token = QWGLOBALMANAGER.configure.userToken;
    getPostDetailR.postId = self.postId;
    getPostDetailR.deviceCode = DEVICE_ID;
    getPostDetailR.page = 1; //fromIndex + 1;
    fromIndex = 0;
    getPostDetailR.pageSize = PostReplyPerPageSize;
    getPostDetailR.showLink = YES;
    [Forum getPostDetial:getPostDetailR success:^(QWPostDetailModel *postDetail) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if ([postDetail.apiStatus integerValue] == 0) {
            [strongSelf removeInfoView];
            [strongSelf.postReplyArray removeAllObjects];   // 删除评论队列
            strongSelf.postDetail = postDetail;
            if (strongSelf.postReplyArray.count > 0) {
                strongSelf->fromIndex++;
                strongSelf.tableView.footerNoDataText = kWarning44;
            }
            else
            {
                strongSelf.tableView.footerNoDataText = @"";
            }
            
            if (postDetail.postReplyList.count < PostReplyPerPageSize) {
                [strongSelf.tableView.footer setCanLoadMore:NO];
            }
        }
        else if ([postDetail.apiStatus integerValue] == 1)
        {
//            [self showInfoView:@"该帖子已被删除" image:@"ic_img_fail"];
            [strongSelf showSpecailInfoView:YES];
            strongSelf->_postDetail = nil;
//            _postDetail = nil;
        }else if ([postDetail.apiStatus integerValue] == 2){
            [strongSelf showInfoView:postDetail.apiMessage image:@"ic_img_cry"];
        }
        
        
        [strongSelf.tableView headerEndRefreshing];
        [strongSelf.tableView footerEndRefreshing];
        [strongSelf hiddenDefaultView];
    } failure:^(HttpException *e) {
        [weakSelf.tableView headerEndRefreshing];
        [weakSelf.tableView footerEndRefreshing];
        if (QWGLOBALMANAGER.currentNetWork == kNotReachable) {
            [weakSelf showInfoView:kWarning12 image:@"网络信号icon"];
        }else
        {
            if(e.errorCode!=-999){
                if(e.errorCode == -1001){
                    [weakSelf showInfoView:kWarning215N26 image:@"ic_img_fail"];
                }else{
                    [weakSelf showInfoView:kWarning39 image:@"ic_img_fail"];
                }
            }
        }
        DebugLog(@"get postDetail error : %@", e);
        [weakSelf hiddenDefaultView];
    }];
}

- (void)hiddenDefaultView
{
    if (self.defaultView.alpha != 0) {
        [UIView animateWithDuration:0.25 animations:^{
            self.defaultView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.defaultView removeFromSuperview];
            self.defaultView = nil;
        }];
    }
}

- (void)viewInfoClickAction:(id)sender
{
    [self loadData];
}

- (QWSpecailInfoView *)specailInfoView
{
    if (!_specailInfoView) {
        _specailInfoView = [[QWSpecailInfoView alloc] init];
        _specailInfoView.imageName = @"ic_img_fail";
        _specailInfoView.title = @"该帖已被删除!";
        _specailInfoView.detail = @"可能原因如下：\n1.该帖被原作者删除\n2.该帖被管理员删除\n3.该帖作者被禁言\n4.该帖所属圈子被管理员下线";
    }
    return _specailInfoView;
}

- (void)showSpecailInfoView:(BOOL)show
{
    if (show) {
        [self.view addSubview:self.specailInfoView];
        PREPCONSTRAINTS(self.specailInfoView);
        ALIGN_TOPLEFT(self.specailInfoView, 0);
        ALIGN_BOTTOMRIGHT(self.specailInfoView, 0);
    }
    else
    {
        [_specailInfoView removeFromSuperview];
        _specailInfoView = nil;
    }
}

- (void)configTableviewLoadView
{
    __weak __typeof(self) weakSelf = self;
    [self enableSimpleRefresh:self.tableView block:^(SRRefreshView *sender) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (strongSelf->sendFailed) {
                return;
            }
            strongSelf->fromIndex = 0;
            [strongSelf.tableView.footer setCanLoadMore:YES];
            [strongSelf loadMorePostReply];
            
        }
    }];
    [self.tableView addFooterWithTarget:self action:@selector(loadMorePostReply)];
//    self.tableView.footer.noDataText = @"";
}

- (void)loadMorePostReply
{
    if (sendFailed) {
        return;
    }
    __weak __typeof(self)weakSelf = self;
    GetPostDetailsR* getPostDetailR = [GetPostDetailsR new];
    getPostDetailR.token = QWGLOBALMANAGER.configure.userToken;
    getPostDetailR.postId = self.postId;
    getPostDetailR.deviceCode = DEVICE_ID;
    getPostDetailR.page = fromIndex + 1;
    getPostDetailR.pageSize = PostReplyPerPageSize;
    getPostDetailR.showLink = YES;
    [Forum getPostDetialWithoutProgress:getPostDetailR success:^(QWPostDetailModel *postDetail) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if ([postDetail.apiStatus integerValue] == 0) {
            if (strongSelf->fromIndex == 0) {
                [strongSelf removeInfoView];
                [strongSelf.postReplyArray removeAllObjects];   // 删除评论队列
            }
            strongSelf.postDetail = postDetail;
            if (strongSelf.postReplyArray.count > 0) {
                strongSelf->fromIndex++;
                strongSelf.tableView.footerNoDataText = kWarning44;
            }
            else
            {
                strongSelf.tableView.footerNoDataText = @"";
            }
            
            if (postDetail.postReplyList.count < PostReplyPerPageSize) {
                [strongSelf.tableView.footer setCanLoadMore:NO];
            }
        }
        else if ([postDetail.apiStatus integerValue] == 1)
        {
            [strongSelf showSpecailInfoView:YES];
            strongSelf->_postDetail = nil;
//            _postDetail = nil;
//            [self showInfoView:@"该帖子已被删除" image:@"ic_img_fail"];
        }
        else if ([postDetail.apiStatus integerValue] == 2){
            [strongSelf showInfoView:postDetail.apiMessage image:@"ic_img_cry"];
        }
        [strongSelf.tableView headerEndRefreshing];
        [strongSelf.tableView footerEndRefreshing];
        [strongSelf hiddenDefaultView];
    } failure:^(HttpException *e) {
        [weakSelf.tableView headerEndRefreshing];
        [weakSelf.tableView footerEndRefreshing];
        DebugLog(@"get postDetail error : %@", e);
        [weakSelf hiddenDefaultView];
    }];
}

- (void)UIGlobal
{
    // 头像
    self.userHeadImageView.layer.masksToBounds = YES;
    self.userHeadImageView.layer.cornerRadius = CGRectGetHeight(self.userHeadImageView.frame)/2;
    self.userPositionImageView.hidden = YES;
    self.userPositionLabel.hidden = YES;
    self.userPositionLabel.text = nil;
    self.constraint_userPositionImgLeading.constant = self.constraint_userPositionImgTrailing.constant = 15;
    // 发帖人昵称
    self.userNameLabel.font = [UIFont systemFontOfSize:kFontS4];
    self.userNameLabel.textColor = RGBHex(qwColor7);
    // 药师 营养师
    self.userPositionLabel.font = [UIFont systemFontOfSize:kFontS4];
    self.userPositionLabel.textColor = RGBHex(qwColor3);
    // 用户等级
    self.userLevelLabel.layer.masksToBounds = YES;
    self.userLevelLabel.layer.cornerRadius = 4;
    // 所属药房
    self.userRemarkLabel.layer.masksToBounds = YES;
    self.userRemarkLabel.layer.cornerRadius = 4;
    self.userRemarkLabel.font = [UIFont systemFontOfSize:kFontS5];
    self.userRemarkLabel.textColor = RGBHex(qwColor4);
    self.userRemarkLabel.backgroundColor = RGBAHex(qwColor3, 0.6);
    
    /* 4.0 顶部的来源圈子去掉不显示
    self.postSourceTipLabel.font = [UIFont systemFontOfSize:kFontS4];
    self.postSourceTipLabel.textColor = RGBHex(qwColor8);

    // 所属圈子
    self.postSourceLabel.font = [UIFont systemFontOfSize:kFontS4];
    self.postSourceLabel.textColor = RGBHex(qwColor7);
    // 关注按钮
    self.careBtn.titleLabel.font = [UIFont systemFontOfSize:kFontS5];
    [self.careBtn setTitleColor:RGBHex(qwColor4) forState:UIControlStateNormal];
    self.careBtn.backgroundColor = RGBHex(qwColor1);
    self.careBtn.layer.masksToBounds = YES;
    self.careBtn.layer.cornerRadius = 4;
    */
     
    // 帖子标题
//    self.postTitleLabel.font = [UIFont systemFontOfSize:kFontS2];
    if (IS_IPHONE_6P) {
        self.postTitleLabel.font = [UIFont systemFontOfSize:kFontS10];
    }
    else
        self.postTitleLabel.font = [UIFont systemFontOfSize:AutoValue(kFontS2)];
    self.postTitleLabel.textColor = RGBHex(qwColor6);
    // 发帖时间
    self.postSendTimeLabel.font = [UIFont systemFontOfSize:kFontS5];
    self.postSendTimeLabel.textColor = RGBHex(qwColor7);
    // 帖子浏览数量
    self.postViewCountLabel.font = [UIFont systemFontOfSize:kFontS5];
    self.postViewCountLabel.textColor = RGBHex(qwColor7);
    // 帖子评论数量
    self.postCommentCountLabel.font = [UIFont systemFontOfSize:kFontS5];
    self.postCommentCountLabel.textColor = RGBHex(qwColor7);
    
    self.praiseContainerView.layer.masksToBounds = YES;
    self.praiseContainerView.layer.cornerRadius = CGRectGetHeight(self.praiseContainerView.frame)/2;
    self.praiseContainerView.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
    self.praiseContainerView.layer.borderColor = RGBHex(qwColor10).CGColor;
    self.praiseTipLabel.font = [UIFont systemFontOfSize:kFontS3];
    self.praiseTipLabel.textColor = RGBHex(qwColor6);
    self.praiseCountLabel.font = [UIFont systemFontOfSize:kFontS1];
    self.praiseCountLabel.textColor = RGBHex(qwColor8);
    
    self.detailTableView.scrollEnabled = NO;
//    self.detailTableView.scrollsToTop = NO;
    self.tableView.scrollsToTop = NO;
    //    self.detailTableView.tableFooterView = [UIView new];
    self.tableView.tableFooterView = [UIView new];
    self.replyTextField.delegate = self;
#ifndef NewPostCommentStyle
    [self.replyTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
#endif
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_more_slide_details"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(clickRightBtnAction:)];
    self.replyTextField.placeholder = @"发表评论";
    self.reSendBtn.layer.masksToBounds = YES;
    self.reSendBtn.layer.cornerRadius = 4;

    self.deleteBtn.layer.masksToBounds = YES;
    self.deleteBtn.layer.cornerRadius = 4;
    self.resendView.hidden = YES;
    self.postSendTimeLabel.hidden = NO;
    // 如果正在发送中 , 不可上啦加载
    if (self.isSending) {
        [self.tableView.footer setCanLoadMore:NO];
    }
    
    // 如果从发帖入口进来的，隐藏关注按钮
    if (self.isFromSendPostVC) {
        self.careBtn.hidden = YES;
    }
    
    self.userNameLabel.text = nil;
//    self.userRemarkLabel.text = nil;
    [self setuserRemarkLabelText:nil];
    self.postSourceLabel.text = nil;
    [self.postTitleLabel ma_setAttributeText:nil];
    
    self.constraint_posttitleWidth.constant = APP_W - 30;
    self.tableView.footerNoDataText = @"";
    self.tableView.backgroundColor = RGBHex(qwColor11);
    
}

- (void)setuserRemarkLabelText:(NSString*)userRemarkText
{
    self.userRemarkLabel.text = userRemarkText;
    self.userRemarkLabel.edgeInsets = StrIsEmpty(userRemarkText) ? UIEdgeInsetsZero : UIEdgeInsetsMake(3, 3, 3, 3);
}

- (NSMutableArray *)postReplyArray
{
    if (!_postReplyArray) {
        _postReplyArray = [NSMutableArray array];
    }
    return _postReplyArray;
}


#pragma mark - right memu   ---- start ----
- (void)clickRightBtnAction:(id)sender
{
    if (self.isSending) { return;}
    [self setupRightBtns];
}

- (void)setupRightBtns
{
    // 判断是否登录
    if(![self checkLogin]) { return;}
    if (QWGLOBALMANAGER.configure.flagSilenced) {
        [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
        return;
    }
    if (self.isSending) { return;}
    NSArray* menuArray;
    if (_postDetail) {
        if ([_postDetail.posterId isEqual:QWGLOBALMANAGER.configure.passPort]) {
            if (_postDetail.posterType == PosterType_YaoShi || _postDetail.posterType == PosterType_YingYangShi) {
                if(_showLink) {
                    menuArray = @[@"置顶帖子", @"删除帖子"];
                }else{
                    menuArray = @[@"置顶帖子", @"编辑帖子", @"删除帖子"];
                }
            }
            else{
                if(_showLink) {
                    menuArray = @[@"删除帖子"];
                }else{
                    menuArray = @[@"编辑帖子", @"删除帖子"];
                }
            }
        }
        else if (_postDetail.flagMaster)
        {
            menuArray = @[@"删除帖子"];
        }
        else
        {
            menuArray = @[@"举报该帖"];
        }
    }
    
    if (menuArray.count > 0) {
        self.rightBtns = [CustomPopListView sharedManagerWithtitleList:menuArray];
        _rightBtns.delegate = self;
        [_rightBtns show];
    }
}

- (void)customPopListView:(CustomPopListView *)ReturnIndexView didSelectedIndex:(NSIndexPath *)indexPath
{
    DDLogVerbose(@"click the index : %ld", indexPath.row);
    [ReturnIndexView hide];
    NSInteger row = indexPath.row;
    if (_postDetail) {
        if ([_postDetail.posterId isEqual:QWGLOBALMANAGER.configure.passPort]) {
            if (_postDetail.posterType == PosterType_YaoShi || _postDetail.posterType == PosterType_YingYangShi) {
                switch (row) {
                    case 0:
                        [self topPostAction];
                        break;
                    case 1:
                        [self editPostAction];
                        break;
                    case 2:
                        [self deletePostAction];
                        break;
                }
            }
            else
            {
                if (row == 0) {
                    [self editPostAction];
                }else if (row == 1)
                    [self deletePostAction];
            }
        }
        else if (_postDetail.flagMaster)
        {
            if (row == 0) {
                [self deletePostAction];
            }
        }
        else
        {
            if (row == 0) {
                [self reportPostAction];
            }
        }
    }
}
#pragma mark - right memu   ---- end ----

// 点击置顶帖子按钮
- (void)topPostAction
{
    __weak __typeof(self) weakSelf = self;
    GetTopPostIdR* getTopPostIdR = [GetTopPostIdR new];
    getTopPostIdR.token = QWGLOBALMANAGER.configure.userToken;
    [Forum GetTopPostId:getTopPostIdR success:^(QWTopPostId *topPostId) {
        if (!StrIsEmpty(topPostId.postId)) {
            if ([weakSelf.postDetail.postId isEqual:topPostId.postId]) {
                [SVProgressHUD showErrorWithStatus:@"当前帖子已是置顶帖，请勿重复置顶，谢谢！" duration:DURATION_LONG];
                return ;
            }
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                strongSelf->cancelPostId = topPostId.postId;
            }
//            cancelPostId = topPostId.postId;
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您已有一篇置顶帖，若继续操作，原有置顶帖将失效，由该帖替换，是否继续？" delegate:strongSelf cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
            alertView.tag = AlertViewTag_TopPost;
            [alertView show];
        }
        else
        {
            [weakSelf topPost];
        }
    } failure:^(HttpException *e) {
        DebugLog(@"get top postId error : %@", e);
    }];
}

#pragma mark 置顶帖子操作
- (void)topPost
{
    __weak __typeof(self) weakSelf = self;
    TopPostR* topPostR = [TopPostR new];
    topPostR.token = QWGLOBALMANAGER.configure.userToken;
    topPostR.postId = _postDetail.postId;
    topPostR.cancelPostId = cancelPostId;
    [Forum topPost:topPostR success:^(BaseAPIModel *baseAPIModel) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf->cancelPostId = nil;
        }
//        cancelPostId = nil;
        if ([baseAPIModel.apiStatus integerValue] == 0) {
            NSString* successMessage = StrIsEmpty(baseAPIModel.apiMessage) ? @"置顶成功!" : baseAPIModel.apiMessage;
            [SVProgressHUD showSuccessWithStatus:successMessage];
        }
        else
        {
            NSString* errorMessage = StrIsEmpty(baseAPIModel.apiMessage) ? @"置顶失败!" : baseAPIModel.apiMessage;
            [SVProgressHUD showErrorWithStatus:errorMessage];
        }
    } failure:^(HttpException *e) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf->cancelPostId = nil;
        }
//        cancelPostId = nil;
        DebugLog(@"top post error : %@", e);
    }];
}

#pragma mark 编辑帖子，跳转到发帖页面
- (void)editPostAction
{
    if ([self postContentHavePicDescription]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"再次编辑会导致图片描述内容被删除，确认要继续编辑该帖吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"编辑", nil];
        alertView.tag = AlertViewTag_EditPost;
        [alertView show];
    }
    else
    {
        [self editPost];
    }
}

// 4.0.0 增加
- (BOOL)postContentHavePicDescription
{
    NSArray* tempPostContentArray= _postDetail.postContentList;
    for (QWPostContentInfo* contentInfo in tempPostContentArray) {
        if (contentInfo.postContentType == 2 && !StrIsEmpty(contentInfo.postContentDesc)) {
            return YES;
        }
    }
    return NO;
}

- (void)editPost
{
    if (!StrIsEmpty(_postDetail.postId)) {
        SendPostViewController* sendPostVC = [[UIStoryboard storyboardWithName:@"Forum" bundle:nil] instantiateViewControllerWithIdentifier:@"SendPostViewController"];
        sendPostVC.hidesBottomBarWhenPushed = YES;
        //        sendPostVC.needChooseCircle = NO;
        sendPostVC.postStatusType = PostStatusType_Editing;
        sendPostVC.postDetail = _postDetail;
        sendPostVC.preVCNameStr = @"帖子详情";
        [self.navigationController pushViewController:sendPostVC animated:YES];
    }
}

// 删除帖子 alert
- (void)deletePostAction
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要删除该帖子吗？一经删除，不可恢复哦" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    alertView.tag = AlertViewTag_DeletePost;
    [alertView show];
}

#pragma mark 删除评论操作
- (void)deleteComment
{
    if (deleteCommentIndex < self.postReplyArray.count) {
        __weak __typeof(self) weakSelf = self;
        QWPostReply* postReply = self.postReplyArray[deleteCommentIndex];
        DeletePostReplyR* deletePostReplyR = [DeletePostReplyR new];
        deletePostReplyR.token = QWGLOBALMANAGER.configure.userToken;
        deletePostReplyR.replyID = postReply.id;
        deletePostReplyR.replyerID = postReply.replier;
        deletePostReplyR.teamID = _postDetail.teamId;
        [Forum deletePostReply:deletePostReplyR success:^(BaseAPIModel *baseAPIModel) {
            if ([baseAPIModel.apiStatus integerValue] == 0) {
                NSString* successMessage = StrIsEmpty(baseAPIModel.apiMessage) ? @"删除回帖成功!" : baseAPIModel.apiMessage;
                [SVProgressHUD showSuccessWithStatus:successMessage];
                [weakSelf loadData];
            }
            else
            {
                NSString* errorMessage = StrIsEmpty(baseAPIModel.apiMessage) ? @"删除回帖失败!" : baseAPIModel.apiMessage;
                [SVProgressHUD showErrorWithStatus:errorMessage];
            }
        } failure:^(HttpException *e) {
            DebugLog(@"delete post error : %@", e);
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == AlertViewTag_DeletePost) {
        if (buttonIndex == 1) {
            [self deletePost];
        }
    }
    if (alertView.tag == AlertViewTag_TopPost) {
        if (buttonIndex == 1) {
            [self topPost];
        }
    }
    if (alertView.tag == AlertViewTag_DeleteComment) {
        if (buttonIndex == 1) {
            [self deleteComment];
        }
    }
    if (alertView.tag == AlertViewTag_EditPost) {
        if (buttonIndex == 1) {
            [self editPost];
        }
    }
}

#pragma mark 删除帖子操作
- (void)deletePost
{
    __weak __typeof(self) weakSelf = self;
    DeletePostInfoR* deletePostInfoR = [DeletePostInfoR new];
    deletePostInfoR.token = QWGLOBALMANAGER.configure.userToken;
    deletePostInfoR.poster = _postDetail.posterId;
    deletePostInfoR.postId = _postDetail.postId;
    deletePostInfoR.teamId = _postDetail.teamId;
    deletePostInfoR.postTitle = _postDetail.postTitle;
    
    [Forum delPostInfo:deletePostInfoR success:^(BaseAPIModel *baseAPIModel) {
        if ([baseAPIModel.apiStatus integerValue] == 0) {
            [QWGLOBALMANAGER postNotif:NotifDeletePostSuccess data:nil object:nil];
            NSString* successMessage = StrIsEmpty(baseAPIModel.apiMessage) ? @"帖子删除成功!" : baseAPIModel.apiMessage;
            [SVProgressHUD showSuccessWithStatus:successMessage];
            [QWUserDefault setObject:@"OK" key:@"deletePostTopicSuccess"];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            NSString* errorMessage = StrIsEmpty(baseAPIModel.apiMessage) ? @"删除失败!" : baseAPIModel.apiMessage;
            [SVProgressHUD showErrorWithStatus:errorMessage];
        }
    } failure:^(HttpException *e) {
        DebugLog(@"delete post error : %@", e);
    }];
}

#pragma mark 举报帖子操作
- (void)reportPostAction
{
    [self.view endEditing:YES];
    NSArray* reasonArray = @[@"广告", @"侵权", @"淫秽色情", @"隐私信息收集", @"其他理由", @"取消"];
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSString* reason in reasonArray) {
        [actionSheet addButtonWithTitle:reason];
    }
    [actionSheet showInView:self.view];
    
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSArray* reasonArray = @[@"广告", @"侵权", @"淫秽色情", @"隐私信息收集", @"其他理由", @"取消"];
    if (buttonIndex < reasonArray.count - 1) {
        QWComplaintR* compliantR = [QWComplaintR new];
        compliantR.objType = 4;
        compliantR.objId = self.postId;
        compliantR.token = QWGLOBALMANAGER.configure.userToken;
        compliantR.reason = reasonArray[buttonIndex];
        //    compliantR.reasonRemark =
        compliantR.title = _postDetail.postTitle;
        [Forum complaint:compliantR success:^(BaseAPIModel *baseAPIModel) {
            if ([baseAPIModel.apiStatus integerValue] == 0) {
                [SVProgressHUD showSuccessWithStatus:@"举报成功，系统会对该举报进行核实，谢谢！"];
            }
            else
            {
                NSString* errorMessage = StrIsEmpty(baseAPIModel.apiMessage) ? @"举报失败!" : baseAPIModel.apiMessage;
                [SVProgressHUD showErrorWithStatus:errorMessage];
                
            }
        } failure:^(HttpException *e) {
            DebugLog(@"report post error : %@", e);
        }];
    }
}

- (void)setPostDetail:(QWPostDetailModel *)postDetail
{
    _postDetail = postDetail;
    if (!hasRegisterCellNib) {
        return;
    }
    if (_postDetail) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_more_slide_details"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(clickRightBtnAction:)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.postId = postDetail.postId;
    if (postDetail.flagAnon) {
        [self.userHeadImageView setImage:ForumDefaultImage];
        self.userNameLabel.text = @"匿名用户";
        [self setuserRemarkLabelText:nil];
    }
    else
    {
        [self.userHeadImageView setImageWithURL:[NSURL URLWithString:_postDetail.headUrl] placeholderImage:ForumDefaultImage];
        self.userNameLabel.text = _postDetail.nickname;
        [self setuserRemarkLabelText:_postDetail.brandName];
    }
//    self.userRemarkLabel.text = _postDetail.brandName;
    self.postSourceLabel.text = _postDetail.teamName;
    
    self.praiseCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_postDetail.upVoteCount];
    [self setPostPraiseFlagZan:_postDetail.flagZan];
    switch (_postDetail.posterType) {
        case PosterType_Nomal:
        case PosterType_MaJia:
            self.userLevelLabel.hidden = NO;
            self.userPositionImageView.hidden = YES;
            self.userPositionLabel.hidden = YES;
            self.userPositionLabel.text = nil;
            self.constraint_userPositionImgLeading.constant = self.constraint_userPositionImgTrailing.constant = 15;
            self.userLevelLabel.text = [NSString stringWithFormat:@"V%ld", (long)_postDetail.mbrLvl];
            self.praiseTipLabel.text = @"给帖子点赞";
            self.praiseCountLabel.textColor = RGBHex(qwColor2);
            [self changePraiseImageSize:NO];
        break;
        case PosterType_YaoShi:
            self.userLevelLabel.hidden = YES;
            self.userPositionImageView.hidden = NO;
            self.userPositionLabel.hidden = NO;
            self.userPositionLabel.text = @"药师";
            self.constraint_userPositionImgLeading.constant = 4;
            self.constraint_userPositionImgTrailing.constant = 11;
            self.userPositionImageView.image = [UIImage imageNamed:@"pharmacist"];
//            self.userRemarkLabel.text = _postDetail.brandName;
            [self setuserRemarkLabelText:_postDetail.brandName];
            self.praiseTipLabel.text = @"给专家送鲜花";
            self.praiseCountLabel.textColor = RGBHex(qwColor3);
            [self changePraiseImageSize:YES];
            break;
        case PosterType_YingYangShi:
            self.userLevelLabel.hidden = YES;
            self.userPositionImageView.hidden = NO;
            self.userPositionLabel.hidden = NO;
            self.userPositionLabel.text = @"营养师";
            self.constraint_userPositionImgLeading.constant = 4;
            self.constraint_userPositionImgTrailing.constant = 11;
            self.userPositionImageView.image = [UIImage imageNamed:@"ic_expert"];
//            self.userRemarkLabel.text = @"营养师";
            [self setuserRemarkLabelText:nil];
            self.praiseTipLabel.text = @"给专家送鲜花";
            self.praiseCountLabel.textColor = RGBHex(qwColor3);
            [self changePraiseImageSize:YES];
            break;
        default:
            self.userLevelLabel.hidden = NO;
            self.userPositionImageView.hidden = YES;
            self.userPositionLabel.hidden = YES;
            self.userPositionLabel.text = nil;
            self.constraint_userPositionImgLeading.constant = self.constraint_userPositionImgTrailing.constant = 15;
            self.userLevelLabel.text = [NSString stringWithFormat:@"V%ld", (long)_postDetail.mbrLvl];
//            self.userRemarkLabel.text = nil;
            [self setuserRemarkLabelText:nil];
            self.praiseTipLabel.text = @"给帖子点赞";
            self.praiseCountLabel.textColor = RGBHex(qwColor2);
            [self changePraiseImageSize:NO];
            break;
    }
    
    [self.postTitleLabel ma_setAttributeText:_postDetail.postTitle];
    
    if (_postDetail.posterType == PosterType_YaoShi) {
            }
    else if (_postDetail.posterType == PosterType_YingYangShi)
    {
        
    }
    
    if (postDetail.flagMaster) {
        [self.careBtn setTitleColor:RGBHex(qwColor8) forState:UIControlStateNormal];
        self.careBtn.titleLabel.font = [UIFont systemFontOfSize:kFontS5];
        self.careBtn.backgroundColor = [UIColor clearColor];
        [self.careBtn setTitle:@"我是圈主" forState:UIControlStateNormal];
    }
    else if (postDetail.flagAttn)
    {
        [self.careBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.careBtn.titleLabel.font = [UIFont systemFontOfSize:kFontS5];
        self.careBtn.backgroundColor = RGBHex(qwColor9);
        [self.careBtn setTitle:@"取消关注" forState:UIControlStateNormal];
    }
    else
    {
        [self.careBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.careBtn.titleLabel.font = [UIFont systemFontOfSize:kFontS5];
        self.careBtn.backgroundColor = RGBHex(qwColor1);
        [self.careBtn setTitle:@"关注" forState:UIControlStateNormal];
    }

    
    self.postSendTimeLabel.text = postDetail.postStrDate;
    self.postViewCountLabel.text = [NSString stringWithFormat:@"%ld", (long)postDetail.readCount];
    self.postCommentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)postDetail.replyCount];
    
//    self.favoriteBtn.selected = _postDetail.flagFavorite;
    
    CGRect frame = self.detailTableHeaderView.frame;
    frame.size.height = [self.detailTableHeaderView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    self.detailTableHeaderView.frame = frame;
    self.detailTableView.tableHeaderView = self.detailTableHeaderView;
    
    postContentArray= [NSMutableArray arrayWithArray:[postDetail.postContentList sortedArrayUsingSelector:@selector(compare:)]];
    
    for(NSInteger index = 0; index< postContentArray.count ; ++index) {
        QWPostContentInfo *contentInfo = postContentArray[index];
        //如果当前是type = 3是外链,4是帖子详情,需要处理
        if(contentInfo.postContentType == 3 || contentInfo.postContentType == 4) {
            _showLink = YES;
            QWPostContentInfo *lastContent = nil;
            QWPostContentInfo *nextContent = nil;
            //判断前后是否也是文本,需要合并
            if(index > 0) {
                lastContent = postContentArray[index - 1];
            }
            
            if(index + 1 < postContentArray.count) {
                nextContent = postContentArray[index + 1];
            }
            //如果前一项也是文本,则合并
            if(lastContent.postContentType == 1) {
                if(lastContent.tagList == nil) {
                    lastContent.tagList = [NSMutableArray arrayWithCapacity:5];
                }
                TagWithMessage *tagMsg = [self createTagMessage:contentInfo];
                tagMsg.start = [NSString stringWithFormat:@"%d",[lastContent.postContent stringByReplacingOccurrencesOfString:@"[链接]" withString:@"1"].length + 1];
                tagMsg.length = [NSString stringWithFormat:@"%d",contentInfo.postContentDesc.length];
                lastContent.postContent = [lastContent.postContent stringByAppendingFormat:@"[链接]%@",contentInfo.postContentDesc];
                [lastContent.tagList addObject:tagMsg];
    
            }else{
                lastContent = nil;
            }
            //如果后一项也是文本,需要合并
            if(nextContent.postContentType == 1) {
                if(lastContent) {
                    lastContent.postContent = [lastContent.postContent stringByAppendingString:nextContent.postContent];
                    [postContentArray removeObject:nextContent];
                    --index;
                }else{
                    if(nextContent.tagList == nil) {
                        nextContent.tagList = [NSMutableArray arrayWithCapacity:5];
                    }
                    nextContent.postContent = [NSString stringWithFormat:@"[链接]%@%@",contentInfo.postContentDesc,nextContent.postContent];
                    TagWithMessage *tagMsg = [self createTagMessage:contentInfo];
                    tagMsg.start = @"1";
                    tagMsg.length = [NSString stringWithFormat:@"%d",[contentInfo.postContentDesc stringByReplacingOccurrencesOfString:@"[链接]" withString:@"1"].length];
                    [nextContent.tagList addObject:tagMsg];
                }
            }else{
                nextContent = nil;
            }
            //合并完成后,需要删除当前项
            if(nextContent.postContentType == 1 || lastContent.postContentType == 1) {
                [postContentArray removeObject:contentInfo];
                --index;
            }else{
                //如果前后都是图片,则该超链接自成一段
                if(contentInfo.tagList == nil) {
                    contentInfo.tagList = [NSMutableArray arrayWithCapacity:5];
                }
                TagWithMessage *tagMsg = [self createTagMessage:contentInfo];
                tagMsg.start = @"1";
                tagMsg.length = [NSString stringWithFormat:@"%d",[contentInfo.postContentDesc stringByReplacingOccurrencesOfString:@"[链接]" withString:@"1"].length];
                contentInfo.postContent = [NSString stringWithFormat:@"[链接]%@",contentInfo.postContentDesc];
                contentInfo.postContentType = 1;
                [contentInfo.tagList addObject:tagMsg];
            }
        }
    }
    
    [self.postReplyArray addObjectsFromArray:postDetail.postReplyList];
    [self.tableView reloadData];
    [self p_reloadTableView];
    [self performSelector:@selector(p_delayRestTableHeight) withObject:nil afterDelay:0.01];
    __weak typeof(self)weakSelf = self;
    if (!self.userInfoBtn.touchUpInsideBlock) {
        self.userInfoBtn.touchUpInsideBlock = ^{
            [QWGLOBALMANAGER statisticsEventId:@"帖子详情_发帖人信息列表" withLable:@"帖子详情_发帖人信息列表" withParams:nil];
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                // 自己发帖或者匿名发帖，点击头像无效
                if ([strongSelf.postDetail.posterId isEqualToString:QWGLOBALMANAGER.configure.passPort] || strongSelf.postDetail.flagAnon) {
                    return ;
                }
                
                if (strongSelf.postDetail.posterType == PosterType_YaoShi || strongSelf.postDetail.posterType == PosterType_YingYangShi) {
                    ExpertPageViewController *vc = [[UIStoryboard storyboardWithName:@"ExpertPage" bundle:nil] instantiateViewControllerWithIdentifier:@"ExpertPageViewController"];
                    vc.hidesBottomBarWhenPushed = YES;
                    vc.posterId = strongSelf.postDetail.posterId;
                    vc.expertType = (int)strongSelf.postDetail.posterType;
                    vc.preVCNameStr = @"帖子详情";
                    vc.nickName = strongSelf.postDetail.nickname;
                    [strongSelf.navigationController pushViewController:vc animated:YES];
                }
                else
                {
                    UserPageViewController *vc = [[UIStoryboard storyboardWithName:@"UserPage" bundle:nil] instantiateViewControllerWithIdentifier:@"UserPageViewController"];
                    vc.hidesBottomBarWhenPushed = YES;
                    vc.mbrId = strongSelf.postDetail.posterId;
                    [strongSelf.navigationController pushViewController:vc animated:YES];
                }
            }
        };
    }
}

- (TagWithMessage *)createTagMessage:(QWPostContentInfo *)contentInfo
{
    TagWithMessage *tagMsg = [[TagWithMessage alloc] init];
    if(contentInfo.postContentType == 4) {
        tagMsg.tagType = @"outerLink";
        tagMsg.tagId = contentInfo.postContent;
    }else if (contentInfo.postContentType == 3) {
        tagMsg.tagId = contentInfo.postContent;
        tagMsg.tagType = @"postDetail";
    }
    return tagMsg;
}



// 点赞图片大小适配
- (void)changePraiseImageSize:(BOOL)isExpert
{
    if (isExpert) {
        // 小花
        if (IS_IPHONE_6P) {
            self.constraint_praiseImageWidth.constant = 25;
            self.constraint_praiseImageHeight.constant = 30;
        }
        else
        {
            self.constraint_praiseImageWidth.constant = 16.6;
            self.constraint_praiseImageHeight.constant = 20;
        }
    }
    else
    {
        // 手点赞
        if (IS_IPHONE_6P) {
            self.constraint_praiseImageHeight.constant = self.constraint_praiseImageWidth.constant = 25;
        }
        else
        {
            self.constraint_praiseImageHeight.constant = self.constraint_praiseImageWidth.constant = 20;
        }
    }
}

#pragma mark 刷新UI， 两个tableview嵌套的，所以需要设置frame
- (void)p_reloadTableView
{
    [self.detailTableView reloadData];
    CGRect tableHeaderViewFrame = self.tableHearderView.frame;
    tableHeaderViewFrame.size.height = self.detailTableView.contentSize.height;
    self.tableHearderView.frame = tableHeaderViewFrame;
    self.tableView.tableHeaderView = self.tableHearderView;
}

#pragma mark 偶尔的一个bug，里面的tableview会显示不全，延时更新高度（渲染完页面重新设置里面tableview的高度）
- (void)p_delayRestTableHeight
{
    CGRect tableHeaderViewFrame = self.tableHearderView.frame;
    tableHeaderViewFrame.size.height = self.detailTableView.contentSize.height;
    self.tableHearderView.frame = tableHeaderViewFrame;
    self.tableView.tableHeaderView = self.tableHearderView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// 用户专家 评论上限500字
- (void)textFieldChanged:(UITextField*)textField
{
    if (textField == self.replyTextField) {
        if (textField.text.length > ReplyMaxNumber) {
            textField.text = [textField.text substringToIndex:ReplyMaxNumber];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0) {
        return YES;
    }
    if (textField == self.replyTextField) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8) {
            if (textField.text.length + string.length >= ReplyMaxNumber) {
                return NO;
            }
        }
        else
        {
            if (textField.text.length >= ReplyMaxNumber) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.replyTextField) {
        if (self.isSending) {
            return NO;
        }
        // 判断是否登录
        if(![self checkLogin]) { return NO;}
        if (QWGLOBALMANAGER.configure.flagSilenced) {
            [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
            return NO;
        }
    }
    [QWGLOBALMANAGER statisticsEventId:@"帖子详情_发表评论按键" withLable:@"帖子详情_发表评论按键" withParams:nil];
    
    [QWGLOBALMANAGER statisticsEventId:@"x_tzxq_pl" withLable:@"帖子详情-评论" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl),@"帖子名":StrDFString(_postDetail.postTitle, @"帖子名"),@"圈子名":StrDFString(_postDetail.teamName, @"圈子名"),@"发帖人名字":StrDFString(QWGLOBALMANAGER.configure.nickName, @"发帖人名字"),@"发帖人类型":QWGLOBALMANAGER.configure.userType == PosterType_YaoShi ? @"药师" : (QWGLOBALMANAGER.configure.userType == PosterType_YingYangShi ? @"营养师" : @"普通用户"),@"点击时间":[QWGLOBALMANAGER timeStrNow]}]];
    
    // 3.1.1 评论更改， 跳到一个新页面
    PostCommentViewController* postCommentVC = [[PostCommentViewController alloc] init];
    postCommentVC.teamId = _postDetail.teamId;
    postCommentVC.postId = _postDetail.postId;
    postCommentVC.postTitle = _postDetail.postTitle;
    [self.navigationController pushViewController:postCommentVC animated:YES];
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [QWGLOBALMANAGER statisticsEventId:@"x_tzxq_plqd" withLable:@"帖子详情-评论确定" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl),@"帖子名":StrDFString(_postDetail.postTitle, @"帖子名"),@"圈子名":StrDFString(_postDetail.teamName, @"圈子名"),@"发帖人名字":StrDFString(QWGLOBALMANAGER.configure.nickName, @"发帖人名字"),@"发帖人类型":QWGLOBALMANAGER.configure.userType == PosterType_YaoShi ? @"药师" : (QWGLOBALMANAGER.configure.userType == PosterType_YingYangShi ? @"营养师" : @"普通用户")}]];
    
    // 判断是否登录
    if(![self checkLogin]) { return NO ;}
    if (self.isSending) { return NO;}
    if (QWGLOBALMANAGER.configure.flagSilenced) {
        [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
        return NO;
    }
    [textField resignFirstResponder];
    if (StrIsEmpty([textField.text mar_trim])) {
        return NO;
    }
    [self replyPostAction];
    return NO;
}

#pragma mark 回帖操作
- (void)replyPostAction
{
    ReplyPostR* replyPostR = [ReplyPostR new];
    replyPostR.token = QWGLOBALMANAGER.configure.userToken;
    replyPostR.posterId = QWGLOBALMANAGER.configure.passPort;
    replyPostR.teamId = _postDetail.teamId;
    replyPostR.postId = self.postId;
    replyPostR.postTitle = _postDetail.postTitle;
    replyPostR.content = self.replyTextField.text;
    replyPostR.replyId = tmpReplyModel.replyerId;
    __weak __typeof(self) weakSelf = self;
    [Forum replyPost:replyPostR success:^(QWCircleCreditModel *circleCreditModel) {
        if ([circleCreditModel.apiStatus integerValue] ==0) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                NSString* successMessage = StrIsEmpty(circleCreditModel.apiMessage) ? @"回复成功!" : circleCreditModel.apiMessage;
                if (circleCreditModel.rewardScore > 0) {
                    [QWProgressHUD showSuccessWithStatus:@"回帖" hintString:[NSString stringWithFormat:@"+%ld", (long)circleCreditModel.rewardScore] duration:DURATION_CREDITREWORD];
                }
                else
                    [SVProgressHUD showSuccessWithStatus:successMessage];
                [strongSelf loadData];
#ifndef NewPostCommentStyle
                strongSelf.replyTextField.text = nil;
                [strongSelf.replyTextField resignFirstResponder];
                strongSelf->tmpReplyModel = nil;
//                tmpReplyModel = nil;
                strongSelf.replyTextField.placeholder = @"回复楼主:";
#endif
            }
        }
        else
        {
            NSString* errorMessage = StrIsEmpty(circleCreditModel.apiMessage) ? @"回复失败！" : circleCreditModel.apiMessage;
            [SVProgressHUD showErrorWithStatus:errorMessage];
        }
    } failure:^(HttpException *e) {
        DebugLog(@"reply post error : %@", e);
    }];
}

#pragma mark 键盘推出，隐藏动作
- (void)keyboardWillShow:(NSNotification*)notification
{
    NSValue* keyRectVal = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyFrame = [keyRectVal CGRectValue];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.constraint_bottomViewBottom.constant = keyFrame.size.height;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.constraint_bottomViewBottom.constant = 0;
        [self.view layoutIfNeeded];
    } completion:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.preVCNameStr isEqualToString:@"药师专栏"]) {
    }if ([self.preVCNameStr isEqualToString:@"圈子详情"])
    {
    }
    else
    {
    }
    
    [QWGLOBALMANAGER statisticsEventId:@"x_tzxq_cx" withLable:@"帖子详情-出现" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"上级页面":StrDFString(self.preVCNameStr, @"上级页面")}]];
    
    if ([self.jumpType isEqualToString:@"sendPost"]) {
        [QWUserDefault setObject:@"OK" key:@"sendPostToCircleDetail"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return 8 + 35 + (self.postReplyArray.count > 0 ? 0 : 120);
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.tableView == tableView) {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, [self tableView:tableView heightForHeaderInSection:section])];
        view.backgroundColor = RGBHex(qwColor4);
        
        UIView* hrLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), 8)];
        hrLineView.backgroundColor = RGBHex(qwColor11);
        [view addSubview:hrLineView];
        
        UIView* topView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(hrLineView.frame), CGRectGetWidth(view.frame), 35)];
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(topView.frame) - 15*2, CGRectGetHeight(topView.frame))];
        label.textColor = RGBHex(qwColor6);
        label.font = [UIFont systemFontOfSize:kFontS1];
        label.text = @"评论";
        [topView addSubview:label];
        
        UIView* hrLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(topView.frame) - 1, APP_W, 1.0f/[UIScreen mainScreen].scale)];
        hrLine.backgroundColor = RGBHex(qwColor10);
        [topView addSubview:hrLine];
        
        if (self.postReplyArray.count == 0) {
            UIView* nextView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(topView.frame), CGRectGetWidth(view.frame), CGRectGetHeight(view.frame) - CGRectGetHeight(topView.frame))];
            UILabel* tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(nextView.frame), CGRectGetHeight(nextView.frame))];
            tipLabel.textAlignment= NSTextAlignmentCenter;
            tipLabel.font = [UIFont systemFontOfSize:kFontS4];
            tipLabel.textColor = RGBHex(qwColor7);
            tipLabel.text = @"快来发表你的评论吧";
            [nextView addSubview:tipLabel];
            [view addSubview:nextView];
        }
        
        [view addSubview:topView];
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollToFirstComment:)];
        tapGesture.numberOfTapsRequired = 2;
        [view addGestureRecognizer:tapGesture];
        
        return view;
    }
    return nil;
}

#pragma mark - 滑动到第一个评论cell
- (void)scrollToFirstComment:(id)sender
{
    if (self.postReplyArray.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.detailTableView) {
        return postContentArray.count;
    }
    else if (tableView == self.tableView)
    {
        return self.postReplyArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (tableView == self.detailTableView) {
        QWPostContentInfo* postContentInfo = postContentArray[row];
        if (postContentInfo.postContentType == 1) {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"postDetailText" forIndexPath:indexPath];
            [self configure:cell tableView:tableView indexPath:indexPath];
            return cell;
        }
        else if (postContentInfo.postContentType == 2)
        {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DisplayPostImageTextTableCell" forIndexPath:indexPath];
            [self configure:cell tableView:tableView indexPath:indexPath];
            return cell;
        }
        else
        {
            UITableViewCell* cell = [UITableViewCell new];
            return cell;
        }
    }
    else if (tableView == self.tableView)
    {
        PostCommentTableCell* postCommentCell = [tableView dequeueReusableCellWithIdentifier:@"PostCommentTableCell" forIndexPath:indexPath];
        [self configure:postCommentCell tableView:tableView indexPath:indexPath];
        return postCommentCell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = nil;
    NSInteger row = indexPath.row;
    if (tableView == self.detailTableView) {
        QWPostContentInfo* postContentInfo = postContentArray[row];
        if (postContentInfo.postContentType == 1) {
            identifier = @"postDetailText";
        }
        else if (postContentInfo.postContentType == 2)
        {
            identifier = @"DisplayPostImageTextTableCell";
        }
        else
        {
            
        }
    }
    else if (tableView == self.tableView)
    {
        identifier = @"PostCommentTableCell";
    }
    if (!StrIsEmpty(identifier)) {
        return  [tableView fd_heightForCellWithIdentifier:identifier configuration:^(id cell) {
            [self configure:cell tableView:tableView indexPath:indexPath];
        }];
    }
    
    return 0;
}

#pragma mark 配置cell以及逻辑都在这里
- (void)configure:(id)cell tableView:(UITableView*)tableView  indexPath:(NSIndexPath*)indexPath
{
    NSInteger row = indexPath.row;
    if (tableView == self.detailTableView) {
        QWPostContentInfo* postContent = postContentArray[row];
        if (postContent.postContentType == 1) {
            MLEmojiLabel* label = (MLEmojiLabel*)[cell viewWithTag:1];
            label.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
            label.disableThreeCommon = YES;
            label.customEmojiPlistName = @"expressionImage_link.plist";
            label.lineSpacing = 7;
            if (IS_IPHONE_6P) {
                label.font = [UIFont systemFontOfSize:kFontS2];
            }
            else
                label.font = [UIFont systemFontOfSize:AutoValue(kFontS1)];
            label.textColor = RGBHex(qwColor7);
            label.emojiDelegate = self;
            label.lineBreakMode = NSLineBreakByCharWrapping;
            label.isNeedAtAndPoundSign = YES;
            label.emojiText = postContent.postContent;
            //如果有超链,则生成显示
            if(postContent.tagList.count > 0) {
                [label addLinkTags:postContent.tagList];
            }
            
        }
        else if (postContent.postContentType == 2)
        {
            // 图片
            [cell setCell:postContent];
        }
        else
        {
        
        }
    }
    else if (tableView == self.tableView)
    {
        if (row >= self.postReplyArray.count) {
            return;
        }
        __block QWPostReply* postReply = self.postReplyArray[row];
        if ([cell respondsToSelector:@selector(setCell:)]) {
            [cell setCell:postReply];
        }
        
        if ([cell isKindOfClass:[PostCommentTableCell class]]) {
            PostCommentTableCell* commentTableCell = cell;
            __weak PostCommentTableCell* weakCommentTableCell = commentTableCell;
            __weak __typeof(self) weakSelf = self;
            commentTableCell.userInfoBtn.touchUpInsideBlock = ^{
                
                if ([postReply.replier isEqualToString:QWGLOBALMANAGER.configure.passPort]) {
                    return ;
                }
                
                if (postReply.replierType == PosterType_YaoShi || postReply.replierType == PosterType_YingYangShi) {
                    ExpertPageViewController *vc = [[UIStoryboard storyboardWithName:@"ExpertPage" bundle:nil] instantiateViewControllerWithIdentifier:@"ExpertPageViewController"];
                    vc.hidesBottomBarWhenPushed = YES;
                    vc.posterId = postReply.replier;
                    vc.expertType = (int)postReply.replierType;
                    vc.preVCNameStr = @"帖子详情";
                    vc.nickName = postReply.nickName;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
                else
                {
                    UserPageViewController *vc = [[UIStoryboard storyboardWithName:@"UserPage" bundle:nil] instantiateViewControllerWithIdentifier:@"UserPageViewController"];
                    vc.hidesBottomBarWhenPushed = YES;
                    vc.mbrId = postReply.replier;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
            };
            
            commentTableCell.praiseBtn.touchUpInsideBlock = ^{
                [QWGLOBALMANAGER statisticsEventId:@"帖子详情_给专家送鲜花按键" withLable:@"帖子详情_给专家送鲜花按键" withParams:nil];
                [weakCommentTableCell showExpertActionView:NO animate:YES];
                [QWGLOBALMANAGER statisticsEventId:@"x_tzxq_sxh" withLable:@"帖子详情-送鲜花" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl),@"帖子名":StrDFString(weakSelf.postDetail.postTitle, @"帖子名"),@"药师名":StrDFString(postReply.nickName, @"药师名")}]];
                if (weakSelf.isSending) { return;}
                if (QWGLOBALMANAGER.configure.flagSilenced && QWGLOBALMANAGER.loginStatus) {
                    [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
                    return;
                }
//                // 专家不能对自己的评论点赞或取消点赞
//                if ([postReply.replier isEqualToString:QWGLOBALMANAGER.configure.passPort]) {
//                    return;
//                }
                if (postReply.flagZan) {
                    // 取消点赞
                    PraisePostComment* praisePostComment = [PraisePostComment new];
                    praisePostComment.token = StrIsEmpty(QWGLOBALMANAGER.configure.userToken) ? nil : QWGLOBALMANAGER.configure.userToken;
                    praisePostComment.replyUserId = postReply.replier;
                    praisePostComment.postTitle = postReply.postTitle;
                    praisePostComment.deviceCode = DEVICE_ID;
                    praisePostComment.postId = weakSelf.postDetail.postId;
                    praisePostComment.replyId = postReply.id;
                    [Forum cancelPraisePostComment:praisePostComment success:^(BaseAPIModel *baseAPIModel) {
                        if ([baseAPIModel.apiStatus integerValue] == 0) {
                            weakCommentTableCell.praiseCountImageView.image = [UIImage imageNamed:@"ic_xiangqingpinglun_flower"];
                            postReply.flagZan = NO;
                            postReply.upVoteCount = MAX(0, postReply.upVoteCount - 1);
                            NSString* successMessage = StrIsEmpty(baseAPIModel.apiMessage) ? @"取消送花成功" : baseAPIModel.apiMessage;
//                            [SVProgressHUD showSuccessWithStatus:successMessage];
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        }
                        else
                        {
                            NSString* errorMessage = StrIsEmpty(baseAPIModel.apiMessage) ? @"取消送花失败" : baseAPIModel.apiMessage;
                            [SVProgressHUD showErrorWithStatus:errorMessage];
                        }
                    } failure:^(HttpException *e) {
                        DebugLog(@"praise post comment error : %@", e);
                    }];
                }
                else
                {
                    // 点赞
                    PraisePostComment* praisePostComment = [PraisePostComment new];
                    praisePostComment.token = StrIsEmpty(QWGLOBALMANAGER.configure.userToken) ? nil : QWGLOBALMANAGER.configure.userToken;
                    praisePostComment.replyUserId = postReply.replier;
                    praisePostComment.postTitle = postReply.postTitle;
                    praisePostComment.deviceCode = DEVICE_ID;
                    praisePostComment.postId = weakSelf.postDetail.postId;
                    praisePostComment.replyId = postReply.id;
                    [Forum praisePostComment:praisePostComment success:^(QWCircleCreditModel *circleCreditModel) {
                        if ([circleCreditModel.apiStatus integerValue] == 0) {
                            postReply.flagZan = YES;
                            postReply.upVoteCount += 1;
                            weakCommentTableCell.praiseCountImageView.image = [UIImage imageNamed:@"ic_xiangqingpinglun_flowerpressed"];
                            NSString* successMessage = StrIsEmpty(circleCreditModel.apiMessage) ? @"送花成功" : circleCreditModel.apiMessage;
//                            [SVProgressHUD showSuccessWithStatus:successMessage];
                            if (circleCreditModel.rewardScore > 0) {
                                [QWProgressHUD showSuccessWithStatus:@"鲜花" hintString:[NSString stringWithFormat:@"+%ld", (long)circleCreditModel.rewardScore] duration:DURATION_CREDITREWORD];
                            }
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        }
                        else
                        {
                            NSString* errorMessage = StrIsEmpty(circleCreditModel.apiMessage) ? @"送花失败" : circleCreditModel.apiMessage;
                            [SVProgressHUD showErrorWithStatus:errorMessage];
                        }
                    } failure:^(HttpException *e) {
                        DebugLog(@"praise post comment error : %@", e);
                    }];

                }
            };
            
            commentTableCell.commentBtn.touchUpInsideBlock = ^{
                [QWGLOBALMANAGER statisticsEventId:@"帖子详情_回复按键" withLable:nil withParams:nil];
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                if (strongSelf.isSending) { return;}
                // 判断是否登录
                if(![strongSelf checkLogin]) { return;}
                if (QWGLOBALMANAGER.configure.flagSilenced) {
                    [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
                    return;
                }
                // 不能对自己评论进行评论
                if ([postReply.replier isEqualToString:QWGLOBALMANAGER.configure.passPort]) {
                    return;
                }

#ifndef NewPostCommentStyle
                if (strongSelf->tmpReplyModel == nil) {
                    strongSelf->tmpReplyModel = [QWPostReplyTest new];
                }
                strongSelf->tmpReplyModel.replyerId = postReply.id;
                strongSelf->tmpReplyModel.replyerName = postReply.nickName;
                strongSelf.replyTextField.placeholder = [NSString stringWithFormat:@"回复%@:", strongSelf->tmpReplyModel.replyerName];
#endif
                PostCommentViewController* postCommentVC = [[PostCommentViewController alloc] init];
                postCommentVC.teamId = strongSelf.postDetail.teamId;
                postCommentVC.postId = strongSelf.postDetail.postId;
                postCommentVC.postTitle = strongSelf.postDetail.postTitle;
                postCommentVC.replyId = postReply.id;
                postCommentVC.postCommentType = QWPostCommentTypeReplyComment;
                [strongSelf.navigationController pushViewController:postCommentVC animated:YES];
                
//                weakSelf.replyTextField.text = tmpReplyModel.replyContent;  不用
//                [weakSelf.replyTextField becomeFirstResponder];
//                [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            };
            
            // 回复专家的按钮
            commentTableCell.expertCommentBtn.touchUpInsideBlock = ^{
                [QWGLOBALMANAGER statisticsEventId:@"帖子详情_回复按键" withLable:nil withParams:nil];
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                [weakCommentTableCell showExpertActionView:NO animate:YES];
                if (strongSelf.isSending) { return;}
                // 判断是否登录
                if(![strongSelf checkLogin]) { return;}
                if (QWGLOBALMANAGER.configure.flagSilenced) {
                    [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
                    return;
                }
                // 不能对自己评论进行评论
                if ([postReply.replier isEqualToString:QWGLOBALMANAGER.configure.passPort]) {
                    return;
                }
                
#ifndef NewPostCommentStyle
                if (strongSelf->tmpReplyModel == nil) {
                    strongSelf->tmpReplyModel = [QWPostReplyTest new];
                }
                strongSelf->tmpReplyModel.replyerId = postReply.id;
                strongSelf->tmpReplyModel.replyerName = postReply.nickName;
                strongSelf.replyTextField.placeholder = [NSString stringWithFormat:@"回复%@:", strongSelf->tmpReplyModel.replyerName];
#endif
                PostCommentViewController* postCommentVC = [[PostCommentViewController alloc] init];
                postCommentVC.teamId = strongSelf.postDetail.teamId;
                postCommentVC.postId = strongSelf.postDetail.postId;
                postCommentVC.postTitle = strongSelf.postDetail.postTitle;
                postCommentVC.replyId = postReply.id;
                postCommentVC.postCommentType = QWPostCommentTypeReplyComment;
                [strongSelf.navigationController pushViewController:postCommentVC animated:YES];
            };
            
            // 长按删除
            commentTableCell.deleteBtn.longTouchUpInsideBlock = ^{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                if (strongSelf.isSending) { return;}
                if (!QWGLOBALMANAGER.loginStatus) {
                    return;
                }
                if (QWGLOBALMANAGER.configure.flagSilenced) {
                    [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
                    return;
                }
                // 已经删除的不提示，不是圈主而且不是自己的不可删除
                if (postReply.status != 2) {
                    if (strongSelf.postDetail.flagMaster || [postReply.replier isEqualToString:QWGLOBALMANAGER.configure.passPort]) {
                        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否确定删除该评论" delegate:strongSelf cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
                        alertView.tag = AlertViewTag_DeleteComment;
                        strongSelf->deleteCommentIndex = indexPath.row;
                        [alertView show];
                    }
                }
            };
            // 点击展开评论的按钮
            commentTableCell.expandCommentBtn.touchUpInsideBlock = ^{
                postReply.isExpandComment = YES;
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            };
            // 点击展开回复的按钮
            commentTableCell.expandReplyBtn.touchUpInsideBlock = ^{
                postReply.isExpandReply = YES;
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            };
        }
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
#ifndef NewPostCommentStyle
    if (scrollView == self.tableView && scrollView.isDragging) {
        if (scrollView.isDragging && self.replyTextField.isFirstResponder) {
            [self.replyTextField resignFirstResponder];
            if (StrIsEmpty(self.replyTextField.text)) {
                tmpReplyModel.replyerId = nil;
                self.replyTextField.placeholder = @"回复楼主:";
            }
        }
    }
#else
    [self hiddenVisibelCellExpertActionView];
#endif
}

- (void)hiddenVisibelCellExpertActionView
{
    NSArray* indexPaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath* indexPath in indexPaths) {
        PostCommentTableCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[PostCommentTableCell class]]) {
            [cell showExpertActionView:NO animate:NO];
        }
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

- (void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj
{
    if (type == NotifSendPostResult) {
        if ([_postDetail.postId isEqual:obj[@"postId"]]) {
            [self sendSuccess:([obj[@"apiStatus"] integerValue] == 0)];
        }
    }
    if (type == NotifSendPostCheckResult) {
        // 如果校验失败也设置成重发状态
        if ([_postDetail.postId isEqual:obj[@"postId"]] && [obj[@"apiStatus"] integerValue] != 0) {
            [self sendSuccess:NO];
        }
    }
    if (type == NotifLoginSuccess || type == NotifQuitOut || type == NotiPostCommentSuccess) {
        [self loadData];
    }
    if (type == NotifKickOff) {
        [self.rightBtns hide];
    }
    if (type == NotifHiddenPostdetailExpertActionView) {
        [self hiddenVisibelCellExpertActionView];
    }
}

#pragma mark 发送帖子接口请求的操作
- (void)sendSuccess:(BOOL)success
{
    if (success) {
        self.postSendTimeLabel.text = @"发送成功";
        self.postSendTimeLabel.hidden = NO;
        self.resendView.hidden = YES;
        self.isSending = NO;
        [self.tableView.footer setCanLoadMore:YES];
        sendFailed = NO;
//        DebugLog(@"删除草稿 : %d", [QWPostDrafts deleteWIthPostId:self.postId]);
        [self loadData];
    }
    else
    {
        self.postSendTimeLabel.text = @"发送失败";
        self.postSendTimeLabel.hidden = YES;
        self.resendView.hidden = NO;
        [SVProgressHUD showErrorWithStatus:@"有内容发送失败，已存入草稿箱" duration:DURATION_LONG];
        sendFailed = YES;
        [self.tableView.footer setCanLoadMore:NO];
    }
}

#pragma mark 点击圈子来源，进入圈子详情
- (IBAction)gotoCircleDetailVCBtnAction:(id)sender {
    if (self.isSending) { return;}
    if (_postDetail && !StrIsEmpty(_postDetail.teamId)) {
        CircleDetailViewController *vc = [[UIStoryboard storyboardWithName:@"Circle" bundle:nil] instantiateViewControllerWithIdentifier:@"CircleDetailViewController"];
        vc.hidesBottomBarWhenPushed = YES;
        vc.teamId = _postDetail.teamId;
        vc.title = [NSString stringWithFormat:@"%@圈",_postDetail.teamName];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark 点击（取消）关注按钮的行为
- (IBAction)careBtnAction:(id)sender {
    [QWGLOBALMANAGER statisticsEventId:@"帖子详情_收藏按键" withLable:nil withParams:nil];
    // 判断是否登录
    if(![self checkLogin]) { return;}
    if (self.isSending) { return;}
    
    if (_postDetail.flagMaster) {
        // 我是圈主 不可点击
        return;
    }
    
    if (QWGLOBALMANAGER.configure.flagSilenced) {
        [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
        return;
    }
    
    if (_postDetail.posterType == PosterType_YaoShi || _postDetail.posterType == PosterType_YingYangShi) {
       [QWGLOBALMANAGER statisticsEventId:@"x_tzxq_gz" withLable:@"帖子详情-关注" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl),@"帖子名":StrDFString(_postDetail.postTitle, @"帖子名"),@"圈子名":StrDFString(_postDetail.teamName, @"圈子名"),@"类型":_postDetail.flagAttn ? @"取消关注" : @"关注",@"点击时间":[QWGLOBALMANAGER timeStrNow],@"药师名":StrDFString(_postDetail.nickname, @"药师名")}]];
    }
    else
    {
        [QWGLOBALMANAGER statisticsEventId:@"x_tzxq_gz" withLable:@"帖子详情-关注" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl),@"帖子名":StrDFString(_postDetail.postTitle, @"帖子名"),@"圈子名":StrDFString(_postDetail.teamName, @"圈子名"),@"类型":_postDetail.flagAttn ? @"取消关注" : @"关注",@"点击时间":[QWGLOBALMANAGER timeStrNow]}]];
    }
    [QWGLOBALMANAGER statisticsEventId:@"x_tzxq_gz" withLable:@"帖子详情-关注" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl),@"帖子名":StrDFString(_postDetail.postTitle, @"帖子名"),@"圈子名":StrDFString(_postDetail.teamName, @"圈子名"),@"类型":_postDetail.flagAttn ? @"取消关注" : @"关注",@"点击时间":[QWGLOBALMANAGER timeStrNow]}]];
    
    AttentionCircleR* attentionCircleR = [AttentionCircleR new];
    attentionCircleR.teamId = _postDetail.teamId;
    attentionCircleR.isAttentionTeam = _postDetail.flagAttn ? 1 : 0;
    attentionCircleR.token = QWGLOBALMANAGER.configure.userToken;
    NSString* successMessage = _postDetail.flagAttn ? @"取消关注" : @"关注成功";
    __weak __typeof(self) weakSelf = self;
    [Forum attentionCircle:attentionCircleR success:^(QWAttentionCircleModel *attentionCircleModel) {
        [SVProgressHUD showSuccessWithStatus:successMessage];
        [weakSelf loadData];
        if (attentionCircleModel.rewardScore > 0) {
            [QWProgressHUD showSuccessWithStatus:@"关注成功" hintString:[NSString stringWithFormat:@"+%ld", (long)attentionCircleModel.rewardScore] duration:DURATION_CREDITREWORD];
        }
    } failure:^(HttpException *e) {
        DebugLog(@"attention circle error : %@", e);
    }];
}

#pragma mark - 点击（取消）点赞帖子按钮
- (IBAction)praisePostBtnAction:(id)sender {
    if (self.isSending) { return;}
    if (QWGLOBALMANAGER.configure.flagSilenced && QWGLOBALMANAGER.loginStatus) {
        [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
        return;
    }
    NSString* zanString = @"点赞";
    [QWGLOBALMANAGER statisticsEventId:@"帖子详情_点赞按键" withLable:nil withParams:nil];
    if (_postDetail.posterType == PosterType_YaoShi || _postDetail.posterType == PosterType_YingYangShi) {
        zanString = @"鲜花";
        
        [QWGLOBALMANAGER statisticsEventId:@"x_tzxq_dz" withLable:@"帖子详情-送鲜花" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl),@"帖子名":StrDFString(_postDetail.postTitle, @"帖子名"),@"圈子名":StrDFString(_postDetail.teamName, @"圈子名"),@"点击时间":[QWGLOBALMANAGER timeStrNow],@"药师名":StrDFString(_postDetail.nickname, @"药师名")}]];
    }
    else
    {
        [QWGLOBALMANAGER statisticsEventId:@"x_tzxq_sxh" withLable:@"帖子详情-送鲜花" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl),@"帖子名":StrDFString(_postDetail.postTitle, @"帖子名"),@"圈子名":StrDFString(_postDetail.teamName, @"圈子名"),@"点击时间":[QWGLOBALMANAGER timeStrNow]}]];
    }
    
    if (_postDetail.flagZan)
    {
        // 取消点赞 ~
        PraisePostR* praisePostR = [PraisePostR new];
        praisePostR.token = StrIsEmpty(QWGLOBALMANAGER.configure.userToken) ? @"" : QWGLOBALMANAGER.configure.userToken;
        praisePostR.posterId = _postDetail.posterId;
        praisePostR.postTitle = _postDetail.postTitle;
        praisePostR.deviceCode = DEVICE_ID;
        praisePostR.postId = _postDetail.postId;
        __weak __typeof(self) weakSelf = self;
        [Forum cancelPraisePost:praisePostR success:^(BaseAPIModel *baseAPIModel) {
            if ([baseAPIModel.apiStatus integerValue] == 0) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    NSString* successMessage = StrIsEmpty(baseAPIModel.apiMessage) ? [NSString stringWithFormat:@"取消%@成功！", zanString] : baseAPIModel.apiMessage;
                    strongSelf.postDetail.upVoteCount -= 1;
                    strongSelf.postDetail.flagZan = NO;
                    [strongSelf setPostPraiseFlagZan:strongSelf.postDetail.flagZan];
                    strongSelf.praiseCountLabel.text = [NSString stringWithFormat:@"%ld", (long)strongSelf.postDetail.upVoteCount];
//                    [SVProgressHUD showSuccessWithStatus:successMessage];
                }
            }
            else
            {
                NSString* errorMessage = StrIsEmpty(baseAPIModel.apiMessage) ? [NSString stringWithFormat:@"取消%@失败！", zanString] :baseAPIModel.apiMessage;
                [SVProgressHUD showErrorWithStatus:errorMessage];
            }
        } failure:^(HttpException *e) {
            DebugLog(@"praise post error : %@", e);
        }];

//        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"您已经%@了！", zanString]];
    }
    else
    {
        // 点赞 ~
        PraisePostR* praisePostR = [PraisePostR new];
        praisePostR.token = StrIsEmpty(QWGLOBALMANAGER.configure.userToken) ? @"" : QWGLOBALMANAGER.configure.userToken;
        praisePostR.posterId = _postDetail.posterId;
        praisePostR.postTitle = _postDetail.postTitle;
        praisePostR.deviceCode = DEVICE_ID;
        praisePostR.postId = _postDetail.postId;
        __weak __typeof(self) weakSelf = self;
        [Forum praisePost:praisePostR success:^(QWCircleCreditModel *cricleCreiditModel) {
            if ([cricleCreiditModel.apiStatus integerValue] == 0) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    NSString* successMessage = StrIsEmpty(cricleCreiditModel.apiMessage) ? [NSString stringWithFormat:@"%@成功！", zanString] : cricleCreiditModel.apiMessage;
                    strongSelf.postDetail.upVoteCount += 1;
                    strongSelf.postDetail.flagZan = YES;
                    [strongSelf setPostPraiseFlagZan:_postDetail.flagZan];
                    strongSelf.praiseCountLabel.text = [NSString stringWithFormat:@"%ld", (long)strongSelf.postDetail.upVoteCount];
                    if (cricleCreiditModel.rewardScore > 0) {
                        [QWProgressHUD showSuccessWithStatus:zanString hintString:[NSString stringWithFormat:@"+%ld", (long)cricleCreiditModel.rewardScore] duration:DURATION_CREDITREWORD];
                    }
//                    [SVProgressHUD showSuccessWithStatus:successMessage];
                }
            }
            else
            {
                NSString* errorMessage = StrIsEmpty(cricleCreiditModel.apiMessage) ? [NSString stringWithFormat:@"%@失败！", zanString] :cricleCreiditModel.apiMessage;
                [SVProgressHUD showErrorWithStatus:errorMessage];
            }
        } failure:^(HttpException *e) {
            DebugLog(@"praise post error : %@", e);
        }];
    }
}

#pragma mark 帖子点赞显示UI
- (void)setPostPraiseFlagZan:(BOOL)flagZan
{
    switch (_postDetail.posterType) {
        case PosterType_Nomal:
        case PosterType_MaJia:
            if (flagZan) {
                self.praiseImageView.image = [UIImage imageNamed:@"post_ic_zan_pressed"];
            }
            else
            {
                self.praiseImageView.image = [UIImage imageNamed:@"post_ic_zan"];
            }
            break;
        case PosterType_YaoShi:
        case PosterType_YingYangShi:
            if (flagZan) {
                self.praiseImageView.image = [UIImage imageNamed:@"ic_xiangqing_flowerpressed"];
            }
            else
                self.praiseImageView.image = [UIImage imageNamed:@"ic_xiangqing_flower"];
            break;
        default:
            if (flagZan) {
                self.praiseImageView.image = [UIImage imageNamed:@"post_ic_zan_pressed"];
            }
            else
            {
                self.praiseImageView.image = [UIImage imageNamed:@"post_ic_zan"];
            }
            break;

            break;
    }

}

#pragma mark 收藏按钮行为
- (IBAction)favoriteBtnAciton:(UIButton*)sender {
    [QWGLOBALMANAGER statisticsEventId:@"帖子详情_收藏按键" withLable:nil withParams:nil];
    if (![self checkLogin]) { return; }
    if (self.isSending) { return; }
    if (QWGLOBALMANAGER.configure.flagSilenced) {
        [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
        return;
    }
    if (sender.selected) {
        CancelCollectOBJR* cancelCollectoR = [CancelCollectOBJR new];
        cancelCollectoR.token = QWGLOBALMANAGER.configure.userToken;
        cancelCollectoR.objID = self.postId;
        cancelCollectoR.objType = 10;
        __weak __typeof(self) weakSelf = self;
        [Forum cancelCollectOBJ:cancelCollectoR success:^(BaseAPIModel *baseAPIModel) {
            if ([baseAPIModel.apiStatus integerValue] == 0) {
//                _postDetail.flagFavorite = NO;
                weakSelf.favoriteBtn.selected =  NO;
                NSString* successMessage = StrIsEmpty(baseAPIModel.apiMessage) ? @"收藏取消" : baseAPIModel.apiMessage;
                [SVProgressHUD showSuccessWithStatus:successMessage];
            }
            else
            {
                NSString* errorMessage = StrIsEmpty(baseAPIModel.apiMessage) ? @"取消收藏失败" : baseAPIModel.apiMessage;
                [SVProgressHUD showErrorWithStatus:errorMessage];
            }
        } failure:^(HttpException *e) {
            DebugLog(@"cancel collect post error : %@", e);
        }];
    }
    else
    {
        CollectOBJR* collectR = [CollectOBJR new];
        collectR.token = QWGLOBALMANAGER.configure.userToken;
        collectR.objID = self.postId;
        collectR.objType = 10;
        __weak __typeof(self) weakSelf = self;
        [Forum collectOBJ:collectR success:^(BaseAPIModel *baseAPIModel) {
            if ([baseAPIModel.apiStatus integerValue] == 0) {
//                _postDetail.flagFavorite = YES;
                weakSelf.favoriteBtn.selected = YES;
                NSString* successMessage = StrIsEmpty(baseAPIModel.apiMessage) ? @"收藏成功" : baseAPIModel.apiMessage;
                [SVProgressHUD showSuccessWithStatus:successMessage];
            }
            else
            {
                NSString* errorMessage = StrIsEmpty(baseAPIModel.apiMessage) ? @"收藏失败" : baseAPIModel.apiMessage;
                [SVProgressHUD showErrorWithStatus:errorMessage];
            }
        } failure:^(HttpException *e) {
            DebugLog(@"collect post error : %@", e);
        }];
    }
    sender.selected = !sender.selected;
}

#pragma mark 点击分享按钮
- (IBAction)shareBtnAction:(id)sender {
    [QWGLOBALMANAGER statisticsEventId:@"帖子详情_分享按键" withLable:@"帖子详情_分享按键" withParams:nil];
    
    [QWGLOBALMANAGER statisticsEventId:@"x_tzxq_fx" withLable:@"帖子详情-分享" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否登录":StrFromInt(QWGLOBALMANAGER.loginStatus),@"用户等级":StrFromInt(QWGLOBALMANAGER.configure.mbrLvl),@"帖子名":StrDFString(_postDetail.postTitle, @"帖子名"),@"发帖人名字":StrDFString(QWGLOBALMANAGER.configure.nickName, @"发帖人名字"),@"发帖人类型":QWGLOBALMANAGER.configure.userType == PosterType_YaoShi ? @"药师" : (QWGLOBALMANAGER.configure.userType == PosterType_YingYangShi ? @"营养师" : @"普通用户"),@"d点击时间":[QWGLOBALMANAGER timeStrNow],@"圈子名":StrDFString(_postDetail.teamName, @"圈子名")}]];
    
    if (self.isSending) { return;}
    if (QWGLOBALMANAGER.configure.flagSilenced) {
        [SVProgressHUD showErrorWithStatus:@"您已被禁言"];
        return;
    }
    ShareContentModel *modelShare = [[ShareContentModel alloc] init];
    modelShare.typeShare = ShareTypePostDetail;
    modelShare.imgURL = _postDetail.teamLogo;
    modelShare.shareID = _postDetail.postId;
    modelShare.title = _postDetail.postTitle;
    modelShare.content = StrDFString(_postDetail.postContent, _postDetail.postTitle);
    [self popUpShareView:modelShare];
}

#pragma mark 发送失败的情况下 ， 点击重发的按钮行为
- (IBAction)reSendBtnAction:(id)sender {
    // 判断是否登录
    if(![self checkLogin]) { return;}
    self.postSendTimeLabel.hidden = NO;
    self.resendView.hidden = YES;
    self.postSendTimeLabel.text = @"发布中...";
    [Forum sendPostWithPostDetail:self.postDetail isEditing:YES reminderExperts:self.reminderExperts];
}

#pragma mark 发送失败的情况下 ，点击删除按钮的行为。 从草稿箱中把数据删除，并返回上一页
- (IBAction)deleteBtnAction:(id)sender {
    self.postSendTimeLabel.hidden = NO;
    self.resendView.hidden = YES;
    if ([QWPostDrafts deleteWIthPostId:self.postId]) {
        [SVProgressHUD showSuccessWithStatus:@"删除成功!"];
        DebugLog(@"删除草稿 : 1");
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 登录验证
- (BOOL)checkLogin
{
    if (!QWGLOBALMANAGER.loginStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[QWBaseNavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark MLEmojiLabelDelegate
- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type
{
    [QWGLOBALMANAGER statisticsEventId:@"x_tz_clj" withLable:@"帖子详情-超链接点击" withParams:nil];
    //新增一种超链接形式,帖子跳帖子
    if(type ==  MLEmojiLabelLinkTypePostDetail) {
        
        PostDetailViewController* postDetailVC = (PostDetailViewController*)[[UIStoryboard storyboardWithName:@"Forum" bundle:nil] instantiateViewControllerWithIdentifier:@"PostDetailViewController"];
        postDetailVC.hidesBottomBarWhenPushed = YES;
        postDetailVC.postId = link;
        [self.navigationController pushViewController:postDetailVC animated:YES];
    }else if(type == MLEmojiLabelLinkTypeOuterLink){
        WebDirectViewController *vcWebDirect = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
        WebDirectLocalModel *modelLocal = [[WebDirectLocalModel alloc] init];
        modelLocal.url = link;
        NSArray *tagList = [emojiLabel getTagList];
        TagWithMessage *tag = tagList[0];
        modelLocal.title = [[[emojiLabel emojiText] stringByReplacingOccurrencesOfString:@"[链接]" withString:@"1"] substringWithRange:NSMakeRange([tag.start integerValue], [tag.length integerValue])];
//        vcWebDirect.isOtherLinks = YES;
        modelLocal.typeLocalWeb = WebLocalTypeOuterLink;
        modelLocal.typeTitle = WebTitleTypeNone;
        vcWebDirect.didSetShare = YES;
        [vcWebDirect setWVWithLocalModel:modelLocal];
        [self.navigationController pushViewController:vcWebDirect animated:YES];
    }
}

- (void)clickStatusBar
{
    [self.tableView setContentOffset:CGPointZero animated:YES];
//    NSInteger row = [self tableView:self.tableView numberOfRowsInSection:0];
//    if (row == 0) {
//        return;
//    }
//    row = MAX(1, row - 2);
//    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:row inSection:0];
//    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


@end