//
//  Message.h
//  APP
//
//  Created by qw on 15/2/22.
//  Copyright (c) 2015年 carret. All rights reserved.
//

#import "BasePrivateModel.h"
#import "BasePrivateModel+ExcludeORM.h"

//Message数据类型
//direction     1是incoming  0是outgoing
//timestamp     是当前发出消息的格林日志时间秒数
//UUID          每条消息的唯一标示符
//star          评价等级
//avatorUrl     头像地址
//sendname      对方的name
//recvname      本人名字
//issend        1是正在发送   2是发送成功   3发送失败
//messagetype   1文本信息    2图片信息    3语音信息   4位置信息  5评价信息
//unread        0已看    1未读  2语音信息已听
//richbody      存放的是富文本下载路径
//body          中存放的是消息的文本字段,如纯文本或者地址位置中描述信息

@interface QWMessage : BasePrivateModel

@property (nonatomic,strong) NSString           *direction;                 //营销活动
@property (nonatomic,strong) NSString           *timestamp;
@property (nonatomic,strong) NSString           *UUID;                      //聊天记录id 数据库关联
@property (nonatomic,strong) NSString           *star;                      //营销活动 title
@property (nonatomic,strong) NSString           *avatorUrl;
@property (nonatomic,strong) NSString           *spec;
@property (nonatomic,strong) NSString           *branchId;
@property (nonatomic,strong) NSString           *branchProId;
@property (nonatomic,strong) NSString           *imgUrl;                    //图片地址
@property (nonatomic,strong) NSString           *sendname;
@property (nonatomic,strong) NSString           *recvname;
@property (nonatomic,strong) NSString           *issend;
@property (nonatomic,strong) NSString           *messagetype;
@property (nonatomic,strong) NSString           *isRead;
@property (nonatomic,strong) NSString           *richbody;                  //营销活动 图片地址或者经纬度信息
@property (nonatomic,strong) NSString           *body;
@property (nonatomic,assign) NSInteger            fromTag;
@property (nonatomic,strong) NSString           *title;
@property (nonatomic,strong) NSString           *duration;
@property (nonatomic,strong) NSString           *fileUrl;
@property (nonatomic,strong) NSString           *download;
@property (nonatomic,strong) NSString           *list;
@property (nonatomic,assign) NSInteger            tags;
-(id)initWithMessage:(QWMessage*)msg;
@end

@interface QWXPMessage :QWMessage
@property (nonatomic,strong) NSString           *direction;                 //营销活动
@property (nonatomic,strong) NSString           *timestamp;
@property (nonatomic,strong) NSString           *UUID;                      //聊天记录id 数据库关联
@property (nonatomic,strong) NSString           *star;                      //营销活动 title
@property (nonatomic,strong) NSString           *avatorUrl;                 //头像
@property (nonatomic,strong) NSString           *imgUrl;                    //图片地址
@property (nonatomic,strong) NSString           *sendname;
@property (nonatomic,strong) NSString           *recvname;
@property (nonatomic,strong) NSString           *issend;
@property (nonatomic,strong) NSString           *messagetype;
@property (nonatomic,strong) NSString           *isRead;
@property (nonatomic,strong) NSString           *richbody;                  //营销活动 图片地址或者经纬度信息
@property (nonatomic,strong) NSString           *body;
@property (nonatomic,assign) NSInteger          fromTag;
@property (nonatomic,strong) NSString           *title;
@property (nonatomic,strong) NSString           *duration;
@property (nonatomic,strong) NSString           *fileUrl;
@property (nonatomic,strong) NSString           *download;
@property (nonatomic,strong) NSString           *list;
@property (nonatomic,assign) NSInteger            tags;
@end

@interface QWPTPMessage :QWMessage

@property (nonatomic,strong) NSString           *spec;
@property (nonatomic,strong) NSString           *branchId;
@property (nonatomic,strong) NSString           *branchProId;
@property (nonatomic,strong) NSString           *direction;                 //营销活动
@property (nonatomic,strong) NSString           *timestamp;
@property (nonatomic,strong) NSString           *UUID;                      //聊天记录id 数据库关联
@property (nonatomic,strong) NSString           *star;                      //营销活动 title
@property (nonatomic,strong) NSString           *avatorUrl;                 //头像
@property (nonatomic,strong) NSString           *imgUrl;                    //图片地址
@property (nonatomic,strong) NSString           *sendname;
@property (nonatomic,strong) NSString           *recvname;
@property (nonatomic,strong) NSString           *issend;
@property (nonatomic,strong) NSString           *messagetype;
@property (nonatomic,strong) NSString           *isRead;
@property (nonatomic,strong) NSString           *richbody;                  //营销活动 图片地址或者经纬度信息
@property (nonatomic,strong) NSString           *body;
@property (nonatomic,assign) NSInteger          fromTag;
@property (nonatomic,strong) NSString           *title;
@property (nonatomic,strong) NSString           *duration;
@property (nonatomic,strong) NSString           *fileUrl;
@property (nonatomic,strong) NSString           *download;
@property (nonatomic,strong) NSString           *list;
@property (nonatomic,assign) NSInteger            tags;
@end

//    result = [_db executeUpdate:@"create table if not exists officialMessages(fromId text default '',toId text default '',timestamp text,body text,direction integer,messagetype integer,UUID text,issend integer,relatedid text,unique(UUID))"];

//officialMessages数据类型  官方

@interface OfficialMessages : BasePrivateModel

@property (nonatomic,strong) NSString           *relatedid;         //对方的qq号
@property (nonatomic,strong) NSString           *fromId;            //谁发的就是谁
@property (nonatomic,strong) NSString           *toId;              //谁收
@property (nonatomic,strong) NSString           *timestamp;
@property (nonatomic,strong) NSString           *body;
@property (nonatomic,strong) NSString           *direction;
@property (nonatomic,strong) NSString           *messagetype;
@property (nonatomic,strong) NSString           *UUID;              //聊天记录id 数据库关联
@property (nonatomic,strong) NSString           *issend;
@property (nonatomic,strong) NSString           *title;
@property (nonatomic,strong) NSString           *subTitle;
@property (nonatomic,assign) NSInteger           fromTag;
@end


//HistoryMessages数据类型
//relatedid     消息关联的对方jid
//timestamp     时间戳
//body          平文本
//direction     0是incoming  1是outgoing
//messagetype   0文本信息    1图片信息    2语音信息   3位置信息  4评价信息
//UUID          每条消息的唯一标示符
//issend        1是正在发送   2是发送成功   3发送失败
//avatarurl     机构的logo
//groupName     机构名称
//groupType     机构类型

@interface HistoryMessages : BasePrivateModel

@property (nonatomic,strong) NSString           *relatedid;             // 对应 ConsultId
@property (nonatomic,strong) NSString           *timestamp;             // 对应 consultLatestTime 最近回复时间
@property (nonatomic,strong) NSString           *body;                  // 对应 consultTitle
@property (nonatomic,strong) NSString           *direction;
@property (nonatomic,strong) NSString           *messagetype;
@property (nonatomic,strong) NSString           *UUID;
@property (nonatomic,strong) NSString           *issend;
@property (nonatomic,strong) NSString           *avatarurl;             // 对应 pharAvatarUrl
@property (nonatomic,strong) NSString           *groupName;             // 对应 pharShotName
@property (nonatomic,strong) NSString           *groupType;
@property (nonatomic,strong) NSString           *groupId;               //药店唯一标识
@property (nonatomic,assign) BOOL               diffusion;             //是否群发扩散消息,YES 代表群发扩散消息,NO代表指定药店
@property (nonatomic,strong) NSString           *isRead;
@property (nonatomic,strong) NSString           *stick;

@property (nonatomic, strong) NSString          *pharType;               // 对应PharType // 1是普通药师 2是明星药房
@property (nonatomic, strong) NSString          *consultStatus;          // 1等待药师回复、2药师已回复、3问题已过期、4问题已关闭
@property (nonatomic, strong) NSString          *unreadCounts;           // 未读数
@property (nonatomic, strong) NSString          *systemUnreadCounts;     // 系统未读数，如果过期，则为1

@property (nonatomic, strong) NSString          *consultMessage;         // 话术

// 新增
@property (nonatomic, strong) NSString          *isOutOfDate;             // 已过期
@property (nonatomic, strong) NSString          *isShowRedPoint;          // 过期问题显示小红点
@property (nonatomic, strong) NSString          *consultFormatShowTime;
//@property (nonatomic, strong) NSString          *isClosed;                // 问题已关闭
//@property (nonatomic, strong) NSString          *ClosedisRead;            // 关闭问题是否已读

// change by perry
// 弃用
//@property (nonatomic, strong) NSString          *spreadHasReaded;        // 该扩散是否已读
//@property (nonatomic, strong) NSString          *isSpreadMsg;            // 是否是扩散消息
//@property (nonatomic, strong) NSString          *isQizCloseOrOutDate;    // 该消息是否关闭或者过期
//@property (nonatomic, strong) NSString          *qizHasReadCloseOrOutDate;   // 该关闭消息是否读过

@end

@interface TagWithMessage : BasePrivateModel

@property (nonatomic,strong) NSString           *UUID;
@property (nonatomic,strong) NSString           *start;
@property (nonatomic,strong) NSString           *length;
@property (nonatomic,strong) NSString           *tagType;
@property (nonatomic,strong) NSString           *title;
@property (nonatomic,strong) NSString           *tagId;

@end





@interface PharMsgModel : BasePrivateModel
//4的优惠通知在224版本改成消息通知
@property (nonatomic, strong) NSString *type;       // 消息类型：1全维药事 2咨询 3即时聊天 4优惠券通知 5系统通知 6订单通知
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imgUrl;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *formatShowTime;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *latestTime;
@property (nonatomic, strong) NSString *unreadCounts;           // 未读数
@property (nonatomic, strong) NSString *systemUnreadCounts;     // 系统未读数。=> 若>1，则表示有扩散提醒
@property (nonatomic, strong) NSString *branchId;   // 会话药师所属门店ID
@property (nonatomic, strong) NSString *branchName;
@property (nonatomic, strong) NSString *branchPassport;         // 会话药师所属门店账号ID
@property (nonatomic, strong) NSString *pharType;               // 1普通药师、2明星药师
@property (nonatomic, strong) NSString *sessionId;  // 会话编号
@property (nonatomic, strong) NSString *isRead;
@property (nonatomic,strong) NSString  *UUID;
@property (nonatomic,strong) NSString  *issend;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) NSString *spec;

//@property (nonatomic, strong) NSString *sessionLatestContent;   // 会话内容
//@property (nonatomic, strong) NSString *sessionCreateTime;      // 会话创建时间
//@property (nonatomic, strong) NSString *sessionFormatShowTime;  // 会话显示时间 - 已格式化的创建时间
//@property (nonatomic, strong) NSString *sessionLatestTime;      // 最新一条回复时间
//@property (nonatomic, strong) NSString *pharAvatarUrl;          // 会话药师头像
//@property (nonatomic, strong) NSString *branchShortName;        // 会话药师所属门店简称
//@property (nonatomic, strong) NSString *body;

@end

@interface MsgNotifyListModel : BasePrivateModel
@property (nonatomic, strong) NSString *relatedid;
@property (nonatomic, strong) NSString *branchId;
@property (nonatomic, strong) NSString *branchName;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *formatShowTime;
@property (nonatomic, strong) NSString *consultLatestTime;
@property (nonatomic, strong) NSString *showRedPoint;
@property (nonatomic, strong) NSString *consultStatus;
@property (nonatomic, strong) NSString *pharShortName;
@property (nonatomic, strong) NSString *unreadCounts;
@property (nonatomic, strong) NSString *systemUnreadCounts;
@property (nonatomic, strong) NSString *pharPassport;
@property (nonatomic, strong) NSString *pharAvatarUrl;
@property (nonatomic, strong) NSString *consultShowTitle;
@end


#pragma mark - 消息中心 新

typedef NS_ENUM(NSUInteger, MsgBoxListMsgType) {
    MsgBoxListMsgTypeNotice = 1,
    MsgBoxListMsgTypeOrder = 2,
    MsgBoxListMsgTypeCredit = 3,
    MsgBoxListMsgTypeHealth = 101,
    MsgBoxListMsgTypeShopConsult = 102,
    MsgBoxListMsgTypeExpertPTP = 103,
    MsgBoxListMsgTypeCircle = 104,
};

typedef NS_ENUM(NSUInteger, MsgBoxNoticeType) {
    MsgBoxNoticeTypeHealth = 1000,//健康指南
    MsgBoxNoticeTypeCoupon = 1001,//券
    MsgBoxNoticeTypeReport = 1002,//意见反馈
    MsgBoxNoticeTypeRebindPhone = 1003,//手机号换绑
    MsgBoxNoticeTypeCreditStore = 1004,//积分商城
    MsgBoxNoticeTypeGoodsCredit = 1005,//商品积分
    MsgBoxNoticeTypeOPOutLink = 100601,//运营通知：外链
    MsgBoxNoticeTypeOPShopSales = 100602,//运营通知：商家优惠活动
    MsgBoxNoticeTypeOPNews = 100603,//运营通知：资讯
    MsgBoxNoticeTypeOPTopic = 100606,//运营通知：专题
    MsgBoxNoticeTypeOPCoupon = 100607,//运营通知：优惠券
    MsgBoxNoticeTypeOPGoodsSales = 100608,//运营通知：优惠商品
    MsgBoxNoticeTypeOPText = 100609,//运营通知：无链接
    MsgBoxNoticeTypeOPNewsTopic = 100610,//运营通知：资讯专题
    MsgBoxNoticeTypeOPPostDetail = 100611, //运营通知：圈帖
    MsgBoxNoticeTypeCreditChanged = 1007,//商品积分
};


typedef NS_ENUM(NSUInteger, MsgBoxNoticeOldType) {
    MsgBoxNoticeOldTypeCoupon = 1, //优惠券
    MsgBoxNoticeOldTypeGoodsSales = 2, //优惠商品
    MsgBoxNoticeOldTypeMemberPromote = 3, //会员营销
    MsgBoxNoticeOldTypeOPOutLink = 4, //外链
    MsgBoxNoticeOldTypeOPNews = 5, //资讯
    MsgBoxNoticeOldTypeOPTopic = 6, ////专题
    MsgBoxNoticeOldTypeOPShopSales = 7, //优惠活动
    MsgBoxNoticeOldTypeOPCoupon = 8, //优惠券
    MsgBoxNoticeOldTypeOPGoodsSales = 9, //优惠商品
    MsgBoxNoticeOldTypeSlowDiease = 10, //慢病订阅
    MsgBoxNoticeOldTypeOPTopicDetail = 28, //专题详情
    MsgBoxNoticeOldTypeOPPostDetail = 29, //帖子详情
    MsgBoxNoticeOldTypeDietDetail = 30 //饮食小贴士详情
};

@interface MsgBoxListModel : BaseAPIModel
@property (nonatomic, strong) NSArray *notices;
@end

@interface MsgBoxListItemModel : BasePrivateModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *formatShowTime;
@property (nonatomic, strong) NSString *type; //类型：1.消息中心 2.订单通知 3.积分通知 101.健康指南 102.店长咨询 103.专家私聊 104.圈子消息,
@property (nonatomic, strong) NSString *unread;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, copy) NSString *logo;
@property (nonatomic, copy) NSString *msgType;
@property (nonatomic, copy) NSString *msgClass; // 消息分类(1:评论 2:赞 (鲜花) 3:＠我的 99：系统消息),

@property (nonatomic, copy) NSString *sessionId; // == id
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, assign) NSInteger unreadCount;
@property (nonatomic, copy) NSString *isSend;


- (void)getAdditionInfo; // 根据sessionId补全相关信息

@end


@interface MsgBoxListModelR : BaseModel ///h5/notice/mbr/index
@property (nonatomic, copy) NSString *token;
@end

@interface MsgBoxNoticeListModel : BaseAPIModel
@property (nonatomic, copy) NSString *lastTimestamp;
@property (nonatomic, strong) NSArray *messages;
@end

#warning  旧的类型保留?
@interface MsgBoxNoticeItemModel : BasePrivateModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *formatShowTime;
@property (nonatomic, strong) NSString *unread;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *objId;
@property (nonatomic, strong) NSString *objType;
@property (nonatomic, strong) NSString *imgUrl;

// 兼容CouponNotiModel的旧字段
@property (nonatomic, strong) NSString *couponId; // 券id
@property (nonatomic, strong) NSString *myCouponId; // 领用券id
@property (nonatomic, strong) NSString *showTitle;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *unreadCounts;
@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *href;
@property (nonatomic, strong) NSString *branchId; // 新接口也包含
@property (nonatomic, strong) NSString *contentType; // 新接口也包含
@property (nonatomic, strong) NSString *drugGuideId;
@property (nonatomic, strong) NSString *attentionName;

@property (nonatomic, strong) NSString *couponValue; // 券值   1~6
@property (nonatomic, strong) NSString *begin;
@property (nonatomic, strong) NSString *end;
@property (nonatomic, strong) NSString *scope; // 类型:1通用，2慢病，4礼品，5商品，6这口，7优惠商品，8兑换
@property (nonatomic, strong) NSString *giftImgUrl;
@property (nonatomic, strong) NSString *couponRemark;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *priceInfo; // 价值信息  7,8

@end

@interface MsgBoxNoticeListModelR : BaseModel ///h5/notice/mbr/queryNormalNotices 消息中心列表
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *view;
@end

@interface MsgBoxHealthListModel : BaseAPIModel
@property (nonatomic, copy) NSString *lastTimestamp;
@property (nonatomic, strong) NSArray *notices;
@end

typedef NS_ENUM(NSUInteger, MsgBoxHealthItemSourceType) {
    MsgBoxHealthItemSourceTypeSlowDisease = 7,
    MsgBoxHealthItemSourceTypeMedicineUsage = 8,
    MsgBoxHealthItemSourceTypeBuyMedicine = 9,
    MsgBoxHealthItemSourceTypeDietTips = 10
};

@interface MsgBoxHealthItemModel : BasePrivateModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *formatShowTime;
@property (nonatomic, strong) NSString *unread;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSArray *tags; // tag array mapped from self.tagsStr
@property (nonatomic, strong) NSString *source; //来源：7.慢病订阅 8.用药指导 9.购药提醒 10.食物禁忌
@property (nonatomic, strong) NSString *tagsStr; // string..

- (void)fixTags;

@end

@interface MsgBoxHealthListModelR : BaseModel ///h5/notice/mbr/queryQwNotices
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *view;
@end

@interface MsgBoxListSetReadTypeModelR : BaseModel ///h5/notice/mbr/clear
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *type;
@end

@interface MsgBoxListRemoveByTypeModelR : BaseModel //h5/notice/mbr/removeByType
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *id;
@end
