//
//  BranchChangeViewController.h
//  APP
//
//  Created by 李坚 on 16/6/13.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "QWBaseVC.h"


typedef enum  Enum_ComFromPage_type{
    Enum_ComFrome_Homepage      = 1,//从首页进入
    Enum_ComFrome_GoodList      = 2,//从分类进入
    
}Enum_ComFromPage_type;

@interface BranchChangeViewController : QWBaseVC

@property (nonatomic, assign) Enum_ComFromPage_type pageType;
@property (nonatomic, strong) MapInfoModel          *currentMapInfo;

@end
