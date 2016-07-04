//
//  ConsultPTP.m
//  APP
//
//  Created by carret on 15/6/4.
//  Copyright (c) 2015年 carret. All rights reserved.
//

#import "ConsultPTP.h"

@implementation ConsultPTP

+ (void)getByPhar:(GetByPharModelR *)param
                                success:(void (^)(CustomerSessionDetailList *responModel))succsee
                                failure:(void (^)(HttpException *e))failure
{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] get:GetByPhar params:[param dictionaryModel] success:^(id responseObj) {
        CustomerSessionDetailList *listModel = [CustomerSessionDetailList parse:responseObj Elements:[SessionDetailVo class] forAttribute:@"details"];
        if (succsee) {
            succsee(listModel);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+ (void)getAllSessionList:(GetAllSessionModelR *)param
                  success:(void (^)(MessageList *responModel))success
                  failure:(void (^)(HttpException *e))failure
{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] get:P2PCustomerSessionGetALL params:[param dictionaryModel] success:^(id responseObj) {
        MessageList *listModel = [MessageList parse:responseObj Elements:[MessageItemVo class] forAttribute:@"messages"];
        DDLogVerbose(@"the message is %@",listModel.messages);
        if (success) {
            success(listModel);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+ (void)getNewSessionList:(GetNewSessionModelR *)param
                  success:(void (^)(CustomerSessionList *responModel))success
                  failure:(void (^)(HttpException *e))failure
{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] getWithoutProgress:P2PCustomerSessionPollNew params:[param dictionaryModel] success:^(id responseObj) {
        CustomerSessionList *listModel = [CustomerSessionList parse:responseObj Elements:[CustomerSessionVo class] forAttribute:@"sessions"];
        if (success) {
            success(listModel);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+ (void)pollBySessionId:(PollBySessionidModelR *)param
                                success:(void (^)(CustomerSessionDetailList *responModel))succsee
                                failure:(void (^)(HttpException *e))failure
{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] get:PollBySessionId params:[param dictionaryModel] success:^(id responseObj) {
        CustomerSessionDetailList *listModel = [CustomerSessionDetailList parse:responseObj Elements:[SessionDetailVo class] forAttribute:@"details"];
        if (succsee) {
            succsee(listModel);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

+ (void)ptpMessagetCreate:(PTPCreate *)param
                success:(void (^)(DetailCreateResult *responModel))succsee
                failure:(void (^)(HttpException *e))failure
{
    DebugLog(@"ptp Create:%@",param);
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] post:PTPDetailCreate params:[param dictionaryModel] success:^(id responseObj) {
        DetailCreateResult *listModel = [DetailCreateResult parse:responseObj ];
        if (succsee) {
            succsee(listModel);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

// 没调用
+ (void)ptpMessagetRead:(PTPRead *)param
                success:(void (^)(ApiBody *responModel))succsee
                failure:(void (^)(HttpException *e))failure
{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] put:PTPDetailRead params:[param dictionaryModel] success:^(id responseObj) {
        ApiBody *listModel = [ApiBody parse:responseObj ];
        if (succsee) {
            succsee(listModel);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

// 没调用
+ (void)ptpMessagetRemove:(PTPRemove *)param
                success:(void (^)(ApiBody *responModel))succsee
                failure:(void (^)(HttpException *e))failure
{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] put:PTPDetailRemove params:[param dictionaryModel] success:^(id responseObj) {
        ApiBody *listModel = [ApiBody parse:responseObj  ];
        if (succsee) {
            succsee(listModel);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}
+ (void)removeByType:(RemoveByTypeR *)param
             success:(void (^)(ApiBody *responModel))succsee
             failure:(void (^)(HttpException *e))failure

{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] put:RemoveByType params:[param dictionaryModel] success:^(id responseObj) {
        ApiBody *listModel = [ApiBody parse:responseObj  ];
        if (succsee) {
            succsee(listModel);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}
@end