//
//  CircleSquareTableCell.m
//  APP
//
//  Created by Martin.Liu on 16/6/21.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "CircleSquareTableCell.h"
#import "cssex.h"
#import "ForumModel.h"
#import "UIImageView+WebCache.h"
@interface CircleSquareTableCell()

@property (strong, nonatomic) IBOutlet UIImageView *circleImageView;
@property (strong, nonatomic) IBOutlet UILabel *circleNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *careAmmountLabel;
@property (strong, nonatomic) IBOutlet UILabel *postAmmountLabel;
@property (strong, nonatomic) IBOutlet UILabel *masterFlagLabel;

@end

@implementation CircleSquareTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = RGBHex(qwColor11);
    self.circleImageView.layer.masksToBounds = YES;
    self.circleImageView.layer.cornerRadius = 2;
    self.circleImageView.layer.borderWidth = 1.0f/[UIScreen mainScreen].scale;
    self.circleImageView.layer.borderColor = RGBHex(qwColor20).CGColor;
    self.circleImageView.image = ForumCircleImage;
    
    QWCSS(self.circleNameLabel, 1, 6);
    QWCSS(self.careAmmountLabel, 5, 8);
    QWCSS(self.postAmmountLabel, 5, 8);
    QWCSS(self.masterFlagLabel, 3, 8);
    
    self.careCircleBtn.backgroundColor = RGBHex(qwColor1);
    self.careCircleBtn.layer.masksToBounds = YES;
    self.careCircleBtn.layer.cornerRadius = 5;
    
    self.masterFlagLabel.hidden = YES;
    self.careCircleBtn.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCell:(id)obj
{
    if ([obj isKindOfClass:[QWCircleModel class]]) {
        QWCircleModel* model = obj;
        [self.circleImageView setImageWithURL:[NSURL URLWithString:model.teamLogo] placeholderImage:ForumCircleImage];
        self.circleNameLabel.text = model.teamName;
        self.careAmmountLabel.text = [NSString stringWithFormat:@"关注 %ld", (long)model.attnCount];
        self.postAmmountLabel.text = [NSString stringWithFormat:@"帖子 %ld", (long)model.postCount];
        self.masterFlagLabel.hidden = YES;
        if (model.flagMaster) {
            self.masterFlagLabel.hidden = NO;
            self.careCircleBtn.hidden = YES;
        }
        else if (model.flagAttn)
        {
            self.careCircleBtn.hidden = YES;
        }
        else
        {
            self.careCircleBtn.hidden = NO;
        }
    }
}

@end
