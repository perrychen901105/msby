//
//  ComboxViewCell.m
//  APP
//
//  Created by Meng on 15/3/24.
//  Copyright (c) 2015年 carret. All rights reserved.
//

#import "ComboxViewCell.h"

@implementation ComboxViewCell

+ (CGFloat)getCellHeight:(id)sender{
    return 46.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithContent:(NSString *)content showImage:(BOOL)show
{
    if(self.mainLabel == nil){
        self.mainLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0,APP_W - 15, [ComboxViewCell getCellHeight:nil])];
        self.mainLabel.font = fontSystem(kFontS4);
        self.mainLabel.textColor = RGBHex(qwColor9);
        [self addSubview:self.mainLabel];
        self.successImage = [[UIImageView alloc] initWithFrame:CGRectMake(APP_W - 29, ([ComboxViewCell getCellHeight:nil] - 14)/2.0f, 14, 14)];
        self.successImage.image = [UIImage imageNamed:@"ic_btn_success"];
        [self addSubview:self.successImage];
        self.textLabel.font = [UIFont systemFontOfSize:14.0f];
        self.textLabel.textColor = RGBHex(qwColor9);
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 0.5)];
        line.backgroundColor = RGBHex(qwColor10);
        [self addSubview:line];
    }
    if(show) {
        self.mainLabel.textColor = RGBHex(qwColor1);
        self.successImage.hidden = NO;
    }else{
        self.successImage.hidden = YES;
        self.mainLabel.textColor = RGBHex(qwColor6);
    }
    self.mainLabel.text = content;
    [self.separatorLine removeFromSuperview];
}

@end