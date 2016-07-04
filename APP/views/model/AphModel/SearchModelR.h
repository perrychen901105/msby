//
//  SearchModelR.h
//  APP
//
//  Created by 李坚 on 15/8/19.
//  Copyright (c) 2015年 carret. All rights reserved.
//

#import "BaseModel.h"

@interface SearchModelR : BaseModel

@end

@interface ScanSearchModelR : BaseModel
@property (nonatomic, strong) NSString *barCode;
@end

@interface DreamWordModelR : BaseModel

@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) NSString *cityName;

@property (nonatomic, strong) NSNumber *currPage;
@property (nonatomic, strong) NSNumber *pageSize;
@end

@interface KeywordModelR : BaseModel

@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;

@end

@interface QueryProductByKwIdModelR : BaseModel

@property (nonatomic, copy) NSString *kwId;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *branchId;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *currPage;
@property (nonatomic, copy) NSString *pageSize;
@property (nonatomic, copy) NSString *v;

@end

@interface HomeSearInBranchModelR : BaseModel

@property (nonatomic, strong) NSString *branchId;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSString *pageSize;

@end

@interface QueryHotKeyR : BaseModel
@property (nonatomic, strong) NSString *city;
@property (nonatomic, assign) NSInteger pos;
@end

@interface QueryTeamListR : BaseModel
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pageSize;
@end