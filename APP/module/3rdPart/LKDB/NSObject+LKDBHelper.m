//
//  NSObject+LKDBHelper.m
//  LKDBHelper
//
//  Created by LJH on 13-6-8.
//  Copyright (c) 2013年 ljh. All rights reserved.
//

#import "NSObject+LKDBHelper.h"
#import "BasePrivateModel.h"
#import "QWGlobalManager.h"

@implementation NSObject (LKDBHelper_Delegate)

+(void)dbDidCreateTable:(LKDBHelper *)helper tableName:(NSString*)tableName{}
+(void)dbDidAlterTable:(LKDBHelper*)helper tableName:(NSString*)tableName addColumns:(NSArray*)columns{}

+(void)dbDidInserted:(NSObject *)entity result:(BOOL)result{}
+(void)dbDidDeleted:(NSObject *)entity result:(BOOL)result{}
+(void)dbDidUpdated:(NSObject *)entity result:(BOOL)result{}
+(void)dbDidSeleted:(NSObject *)entity{}

+(BOOL)dbWillDelete:(NSObject *)entity{
    return YES;
}
+(BOOL)dbWillInsert:(NSObject *)entity{
    return YES;
}
+(BOOL)dbWillUpdate:(NSObject *)entity{
    return YES;
}
@end

@implementation NSObject(LKDBHelper)

- (LKDBHelper*)getUsingLKDBHelper
{
    NSString *resultPath = @"";
    if([[self class] isSubclassOfClass:[BasePrivateModel class]]) {
        
        NSString* ret = [QWGLOBALMANAGER getPrivateDBName];
        if ([ret length] > 0) {
            NSString* resultPath = [NSString stringWithFormat:@"private_%@",ret];
            static LKDBHelper* db=nil;
            static NSString* dbName = @"";
            static dispatch_once_t onceToken1;
            if (db) {
                if (![dbName isEqualToString:resultPath])
                {
                    db = nil;
                    dbName = resultPath;
                    NSString* dbpath = [LKDBHelper getDBPathWithDBName:resultPath];
                    db = [[LKDBHelper alloc] initWithDBPath:dbpath];
                }
                [db createTableWithModelClass:[self class] tableName:[[self class] getTableName]];
            }
            else
            {
                dbName = resultPath;
                dispatch_once(&onceToken1, ^{
                    NSString* dbpath = [LKDBHelper getDBPathWithDBName:resultPath];
                    db = [[LKDBHelper alloc] initWithDBPath:dbpath];
                });
                [db createTableWithModelClass:[self class] tableName:[[self class] getTableName]];
            }
            return db;
        }
        return nil;
        
    }else{
        
        resultPath = @"public";
        static LKDBHelper* db;
        
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            
            NSString* dbpath = [LKDBHelper getDBPathWithDBName:resultPath];
            
            db = [[LKDBHelper alloc] initWithDBPath:dbpath];
            
        });
        [db createTableWithModelClass:[self class] tableName:[[self class] getTableName]];
        return db;
    }
}

#pragma mark - simplify synchronous function
+(BOOL)checkModelClass:(NSObject*)model
{
    if([model isMemberOfClass:self])
        return YES;
    
    DDLogVerbose(@"%@ can not use %@",NSStringFromClass(self),NSStringFromClass(model.class));
    return NO;
}
+(NSInteger)rowCountWithWhereFormat:(id)where, ...
{
    if ([where isKindOfClass:[NSString class]])
    {
        va_list list;
        va_start(list, where);
        where = [[NSString alloc]initWithFormat:where arguments:list];
        va_end(list);
    }
    return [[self getUsingLKDBHelper] rowCount:self where:where];
}
+(NSInteger)rowCountWithWhere:(id)where, ...
{
    if ([where isKindOfClass:[NSString class]])
    {
        va_list list;
        va_start(list, where);
        where = [[NSString alloc]initWithFormat:where arguments:list];
        va_end(list);
    }
    return [[self getUsingLKDBHelper] rowCount:self where:where];
}
+(NSMutableArray *)searchColumn:(id)columns where:(id)where orderBy:(NSString *)orderBy offset:(NSInteger)offset count:(NSInteger)count
{
    return [[self getUsingLKDBHelper] search:self column:columns where:where orderBy:orderBy offset:offset count:count];
}
+(NSMutableArray*)searchWithWhere:(id)where orderBy:(NSString*)orderBy offset:(NSInteger)offset count:(NSInteger)count{
    return [[self getUsingLKDBHelper] search:self where:where orderBy:orderBy offset:offset count:count];
}
+(id)searchSingleWithWhere:(id)where orderBy:(NSString *)orderBy
{
    return [[self getUsingLKDBHelper] searchSingle:self where:where orderBy:orderBy];
}

+(BOOL)insertToDB:(NSObject*)model{
    
    if([self checkModelClass:model])
    {
        return [[self getUsingLKDBHelper] insertToDB:model];
    }
    return NO;
    
}
+(BOOL)insertWhenNotExists:(NSObject*)model{
    if([self checkModelClass:model])
    {
        return [[self getUsingLKDBHelper] insertWhenNotExists:model];
    }
    return NO;
}
+(BOOL)updateToDB:(NSObject *)model where:(id)where,...
{
    if([self checkModelClass:model])
    {
        if ([where isKindOfClass:[NSString class]])
        {
            va_list list;
            va_start(list, where);
            where = [[NSString alloc]initWithFormat:where arguments:list];
            va_end(list);
        }
        return [[self getUsingLKDBHelper] updateToDB:model where:where];
    }
    return NO;
}
+(BOOL)updateToDBWithSet:(NSString *)sets where:(id)where,...
{
    if ([where isKindOfClass:[NSString class]])
    {
        va_list list;
        va_start(list, where);
        where = [[NSString alloc]initWithFormat:where arguments:list];
        va_end(list);
    }
    return [[self getUsingLKDBHelper] updateToDB:self set:sets where:where];
}
+(BOOL)deleteToDB:(NSObject*)model
{
    if([self checkModelClass:model])
    {
        return [[self getUsingLKDBHelper] deleteToDB:model];
    }
    return NO;
}
+(BOOL)deleteWithWhere:(id)where,...
{
    if ([where isKindOfClass:[NSString class]])
    {
        va_list list;
        va_start(list, where);
        where = [[NSString alloc]initWithFormat:where arguments:list];
        va_end(list);
    }
    return [[self getUsingLKDBHelper] deleteWithClass:self where:where];
}
+(BOOL)isExistsWithModel:(NSObject *)model
{
    if([self checkModelClass:model])
    {
        return [[self getUsingLKDBHelper] isExistsModel:model];
    }
    return NO;
}

-(BOOL)updateToDB
{
    if(self.rowid > 0)
    {
        return [self.class updateToDB:self where:nil];
    }
    else
    {
        return [self saveToDB];
    }
}
- (BOOL)saveToDB
{
    return [self.class insertToDB:self];
}
- (BOOL)deleteToDB
{
    return [self.class deleteToDB:self];
}
-(BOOL)isExistsFromDB
{
    return [self.class isExistsWithModel:self];
}

+(void)insertArrayByAsyncToDB:(NSArray *)models
{
    if(models.count > 0)
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            for (id model in models)
            {
                [model saveToDB];
            }
        });
    }
}

+(void)insertToDBWithArray:(NSArray *)models filter:(void (^)(id model, BOOL inseted, BOOL * rollback))filter
{
    [[self getUsingLKDBHelper] executeForTransaction:^BOOL(LKDBHelper *helper) {
        
        BOOL isRollback = NO;
        for (int i=0; i<models.count; i++)
        {
            id obj = [models objectAtIndex:i];
            BOOL inseted = [helper insertToDB:obj];
            if(filter)
            {
                filter(obj,inseted,&isRollback);
            }
            if(isRollback)
            {
                break;
            }
        }
        return (isRollback == NO);
    }];
}

@end