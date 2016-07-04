//
//  Search.m
//  APP
//
//  Created by 李坚 on 15/8/19.
//  Copyright (c) 2015年 carret. All rights reserved.
//

#import "Search.h"
#import "PromotionModel.h"
#import "DrugModel.h"
#import "Activity.h"

@implementation Search

/**
 *  首页扫码搜门店
 *  V4.0
 */
+ (void)homeScanSearchInBranch:(HomeSearInBranchModelR *)model success:(void (^)(MicroMallSearchProArrayVo *))success failure:(void (^)(HttpException *))failure{
    [[HttpClient sharedInstance] get:SearchByBarCodeInBranch params:[model dictionaryModel] success:^(id obj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([MicroMallSearchProVo class])];
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"products"];
        
        MicroMallSearchProArrayVo *productVo = [MicroMallSearchProArrayVo parse:obj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(productVo);
        }
    } failure:^(HttpException *e) {
        DebugLog(@"%@",e);
        if (failure) {
            failure(e);
        }
    }];
}
/**
 *  首页商品搜索(用于药房内搜索)
 *  V4.0
 */
+ (void)homeSearchInBranch:(HomeSearInBranchModelR *)model success:(void (^)(MicroMallSearchProArrayVo *))success failure:(void (^)(HttpException *))failure{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] get:MallIndexSearchInBranch params:[model dictionaryModel] success:^(id obj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([MicroMallSearchProVo class])];
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"products"];
        
        MicroMallSearchProArrayVo *productVo = [MicroMallSearchProArrayVo parse:obj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(productVo);
        }
    } failure:^(HttpException *e) {
        DebugLog(@"%@",e);
        if (failure) {
            failure(e);
        }
    }];
}
/**
 *  首页商品搜索(用于城市内搜索)
 *  V4.0
 */
+ (void)homeSearchInCity:(DreamWordModelR *)model success:(void (^)(MicroMallSearchProArrayVo *))success failure:(void (^)(HttpException *))failure{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] get:MallIndexSearchInCity params:[model dictionaryModel] success:^(id obj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([MicroMallSearchProVo class])];
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"products"];
        
        MicroMallSearchProArrayVo *productVo = [MicroMallSearchProArrayVo parse:obj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(productVo);
        }
    } failure:^(HttpException *e) {
        DebugLog(@"%@",e);
        if (failure) {
            failure(e);
        }
    }];
}
/**
 *  首页商品搜索联想词
 *  V3.0
 */
+ (void)homeDreamWord:(DreamWordModelR *)model success:(void (^)(KeywordModel *))success failure:(void (^)(HttpException *))failure{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] get:SearchAssociate params:[model dictionaryModel] success:^(id obj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([HighlightAssociateVO class])];
        [keyArray addObject:NSStringFromClass([HighlightPosition class])];
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"list"];
        [valueArray addObject:@"highlightPositionList"];
        
        KeywordModel *dreamWordList = [KeywordModel parse:obj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(dreamWordList);
        }
    } failure:^(HttpException *e) {
        DebugLog(@"%@",e);
        if (failure) {
            failure(e);
        }
    }];
}

/**
 *  药病症，关键字搜索2.2.0
 *
*/
+ (void)searchByKeyword:(KeywordModelR *)model success:(void (^)(id))success failure:(void (^)(HttpException *))failure{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] get:SearchByKeyWord params:[model dictionaryModel] success:^(id obj) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        [keyArray addObject:NSStringFromClass([KeywordVO class])];
        [keyArray addObject:NSStringFromClass([Keyword class])];
        NSMutableArray *valueArray = [NSMutableArray array];
        [valueArray addObject:@"list"];
        [valueArray addObject:@"keywords"];
        
        KeywordModel *keywordList = [KeywordModel parse:obj ClassArr:keyArray Elements:valueArray];
        
        if (success) {
            success(keywordList);
        }
    } failure:^(HttpException *e) {
        DebugLog(@"%@",e);
        if (failure) {
            failure(e);
        }
    }];
}

/**
 *  热门搜索关键词2.2.0
 *
 */
+ (void)searchHotKeyword:(hotKeywordList *)model
                 success:(void (^)(id))success
                 failure:(void (^)(HttpException *))failure{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] get:SearchHotKeyWord params:[model dictionaryModel] success:^(id obj) {
        hotKeywordList *keywordList = [hotKeywordList parse:obj Elements:[hotKeyword class] forAttribute:@"searchWords"];
        if (success) {
            success(keywordList);
        }
    } failure:^(HttpException *e) {
        DebugLog(@"%@",e);
        if (failure) {
            failure(e);
        }
    }];
}

+ (void)searchOpencityChecknew:(KeywordModelR *)model
                       success:(void (^)(OpenCityCheckVoModel *))success
                       failure:(void (^)(HttpException *))failure
{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] get:OpencityCheckNew params:[model dictionaryModel] success:^(id obj) {
        OpenCityCheckVoModel *keywordList = [OpenCityCheckVoModel parse:obj];
        if (success) {
            success(keywordList);
        }
    } failure:^(HttpException *e) {
        DebugLog(@"%@",e);
        if (failure) {
            failure(e);
        }
    }];
}

//按照字母分组且排序。数据格式为Map
+ (void)searchOpenCity:(BaseModel *)model
               success:(void (^)(id))success
               failure:(void (^)(HttpException *))failure
{
    HttpClientMgr.progressEnabled = NO;
    [[HttpClient sharedInstance] get:SearchOpenCity params:[model dictionaryModel] success:^(id obj) {
        if (success) {
            success(obj);
        }
    } failure:^(HttpException *e) {
        DebugLog(@"%@",e);
        if (failure) {
            failure(e);
        }
    }];
}

/**
 *  根据关键字查询商品 add by lijian 2.2.0
 *
 */
+ (void)queryProductByKeyword:(QueryProductByKwIdModelR *)model
                 success:(void (^)(id))success
                 failure:(void (^)(HttpException *))failure{
    
    [[HttpClient sharedInstance] get:QueryProductByKwId params:[model dictionaryModel] success:^(id obj) {
        
        KeywordModel *keywordList = [KeywordModel parse:obj Elements:[DrugVo class] forAttribute:@"list"];
        
        if (success) {
            success(keywordList);
        }
    } failure:^(HttpException *e) {
        DebugLog(@"%@",e);
        if (failure) {
            failure(e);
        }
    }];
}

/**
 *  圈贴热词搜索
 *  V4.0
 */

+(void)queryPostHotKeyWord:(QueryHotKeyR *)modelR success:(void(^)(HotkeyListVo *model))success failure:(void (^)(HttpException *))failure {
    [[HttpClient sharedInstance] get:QueryHotKeyWordInfo params:[modelR dictionaryModel] success:^(id responseObj) {
        HotkeyListVo *list = [HotkeyListVo parse:responseObj Elements:[HotKeyVo class] forAttribute:@"keys"];
        if (success) {
            success(list);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}

/**
 *  圈贴搜索
 *  V4.0
 */

+(void)queryTeamListInfo:(QueryTeamListR *)modelR success:(void(^)(PostSearchListVo *model))success failure:(void (^)(HttpException *e))failure {
    [[HttpClient sharedInstance] get:QueryPostListInfo params:[modelR dictionaryModel] success:^(id responseObj) {
        PostSearchListVo *listVo = [PostSearchListVo parse:responseObj Elements:[PostSearchVo class] forAttribute:@"posts"];
        if (success) {
            success(listVo);
        }
    } failure:^(HttpException *e) {
        if (failure) {
            failure(e);
        }
    }];
}
@end
