//
//  OnceCouponChatBubbleView.m
//  APP
//
//  Created by YYX on 15/6/25.
//  Copyright (c) 2015年 carret. All rights reserved.
//

#import "OnceCouponChatBubbleView.h"
#import "UIImageView+WebCache.h"

NSString *const kRouterEventOnceCouponBubbleTapEventName = @"kRouterEventOnceCouponBubbleTapEventName";

@implementation OnceCouponChatBubbleView

- (void)awakeFromNib
{
    self.autoresizingMask = UIViewAutoresizingNone;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.sendButton.layer.borderColor = RGBHex(qwColor5).CGColor;
    self.sendButton.layer.borderWidth = 1.0;
    self.sendButton.layer.cornerRadius = 4.0;
    self.sendButton.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
//     [self.sendButton setBackgroundImage:[UIImage imageNamed:@"ic_btn_send.png"] forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewPressed:)];
    [self addGestureRecognizer:tap];
    
    UIView * topSeparateLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 0.5)];
    topSeparateLine.backgroundColor = RGBHex(qwColor10);
    [self addSubview:topSeparateLine];
    
    UIView * bottomSeparateLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 0.5, APP_W, 0.5)];
    bottomSeparateLine.backgroundColor = RGBHex(qwColor10);
    [self addSubview:bottomSeparateLine];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - setter
-(void)setMessageModel:(MessageModel *)messageModel
{
    [super setMessageModel:messageModel];
    [self.couponImageView setImageWithURL:[NSURL URLWithString:messageModel.activityUrl] placeholderImage:[UIImage imageNamed:@"药品默认图片"] completed:nil];
    self.couponTitle.text = messageModel.title;
    self.couponContent.text = messageModel.text;
}

#pragma mark - public
-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventOnceCouponBubbleTapEventName userInfo:@{KMESSAGEKEY:self.messageModel}];
}

+(CGSize)sizeForBubbleWithObject:(MessageModel *)model
{
    CGSize bubbleSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 150);
    return bubbleSize;
}

- (IBAction)sendCouponAction:(id)sender
{
    [self bubbleViewPressed:nil];
}
@end