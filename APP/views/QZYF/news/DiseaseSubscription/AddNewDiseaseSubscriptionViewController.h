//
//  AddNewDiseaseSubscriptionViewController.h
//  wenyao
//
//  Created by Pan@QW on 14-9-25.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QWBasePage.h"
#import "DiseaseSubscriptionViewController.h"

@interface AddNewDiseaseSubscriptionViewController : QWBasePage<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) DiseaseSubscriptionViewController      *diseaseSubscriptionViewController;

@end