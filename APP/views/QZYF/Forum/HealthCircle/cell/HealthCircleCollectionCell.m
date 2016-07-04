//
//  HealthCircleCollectionCell.m
//  APP
//
//  Created by Martin.Liu on 16/6/20.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "HealthCircleCollectionCell.h"
#import "Forum.h"
#import "UIImageView+WebCache.h"
@interface HealthCircleCollectionCell()
@property (strong, nonatomic) IBOutlet UIView *circleContainerView;
@property (strong, nonatomic) IBOutlet UIImageView *circleImageView;
@property (strong, nonatomic) IBOutlet UILabel *circleTitleLabel;

@end
@implementation HealthCircleCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.circleContainerView.backgroundColor = RGBHex(qwColor11);
    self.circleContainerView.layer.masksToBounds = YES;
    self.circleContainerView.layer.cornerRadius = 4;
    self.circleImageView.layer.masksToBounds = YES;
    self.circleImageView.layer.cornerRadius = 4;
    self.circleTitleLabel.font = [UIFont systemFontOfSize:kFontS4];
    self.circleTitleLabel.textColor = RGBHex(qwColor6);
    self.circleImageView.image = ForumCircleImage;
}

- (void)setCell:(id)obj
{
    if ([obj isKindOfClass:[QWCircleModel class]]) {
        QWCircleModel* model = obj;
        [self.circleImageView setImageWithURL:[NSURL URLWithString:model.teamLogo] placeholderImage:ForumCircleImage];
        self.circleTitleLabel.text = model.teamName;
        
    }
}

@end
