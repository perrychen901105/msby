//
//  SettingCell.m
//  wenyao
//
//  Created by Meng on 14/11/6.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "SettingCell.h"

@implementation SettingCell

- (void)awakeFromNib {
    self.titleLabel.font = [UIFont systemFontOfSize:kFontS1];
    self.titleLabel.textColor = RGBHex(qwColor6);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end