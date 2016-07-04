//
//  ComboProductCell.h
//  APP
//
//  Created by garfield on 16/6/15.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "QWBaseCell.h"
#import "PackageScrollView.h"

@interface ComboProductCell : QWBaseCell


@property (nonatomic, strong)   IBOutlet    UILabel                 *couponTitleLabel;
@property (nonatomic, strong)   IBOutlet    UIButton                *moreButton;
@property (nonatomic, strong)   PackageScrollView                   *packageScrollView;
@property (weak, nonatomic) IBOutlet UIView                         *backgroundConatiner;


@end