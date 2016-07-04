//
//  MsgBoxHealthCell.m
//  APP
//
//  Created by  ChenTaiyu on 16/6/23.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "MsgBoxHealthCell.h"
#import "QWMessage.h"
#import "UITableView+FDTemplateLayoutCellCustomed.h"

#pragma mark - MsgBoxHealthBaseCell
@interface MsgBoxHealthBaseCell ()

@end
@implementation MsgBoxHealthBaseCell

+ (instancetype)cell
{
    return nil;
}

- (void)setCell:(id)obj
{
    [self setCell:nil tableView:nil indexPath:nil];
}

+ (CGFloat)getCellHeightWithModel:(MsgBoxHealthItemModel *)model
{
    return 0;
}

+ (CGFloat)getCachedCellHeightWithModel:(MsgBoxHealthItemModel *)model tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [tableView fd_heightForCellCacheByIndexPath:indexPath];
    if (height == FDTemplateLayoutCellHeightCacheNone) {
        height = [self getCellHeightWithModel:model];
        [tableView fd_cacheHeiht:height byIndexPath:indexPath];
    }
    return height;
}

- (void)setCell:(id)obj indexPath:(NSIndexPath *)indexPath
{

}

- (void)setCell:(id)obj tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{

}

@end

#pragma mark - MsgBoxHealthDietTipsCell

@interface MsgBoxHealthDietTipsCell ()
+ (MsgBoxHealthCell *)_reusableCell1;
+ (MsgBoxHealthCell2 *)_reusableCell2;
+ (void)_reuseCell1:(MsgBoxHealthCell *)cell;
+ (void)_reuseCell2:(MsgBoxHealthCell2 *)cell;

@property (nonatomic, strong) UIView *contentWrapper;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation MsgBoxHealthDietTipsCell

static NSMutableSet *_reusableCellSet1;
static NSMutableSet *_reusableCellSet2;

const CGFloat kMsgBoxHealthCellIndentX = 12.0;

+ (void)load
{
    _reusableCellSet1 = [NSMutableSet set];
    _reusableCellSet2 = [NSMutableSet set];
}

+ (instancetype)cell;
{
    MsgBoxHealthDietTipsCell *cell = [[MsgBoxHealthDietTipsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MsgBoxHealthDietTipsCell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundView = nil;
    cell.selectedBackgroundView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.bounds = CGRectMake(0, 0, SCREEN_W, CGRectGetHeight(cell.bounds));
    
    UILabel *time = [UILabel new];
    time.textColor = RGBHex(qwColor8);
    time.font = fontSystem(kFontS5);
    time.frame = CGRectMake(0, 15.0, SCREEN_W, 15);
    time.textAlignment = NSTextAlignmentCenter;
    time.numberOfLines = 1;
    [cell.contentView addSubview:time];
    cell.timeLabel = time;

    UIView *wrapper = [UIView new];
    [cell.contentView addSubview:wrapper];
    wrapper.layer.borderColor = RGBHex(0xc8c7cc).CGColor;
    wrapper.layer.borderWidth = 0.5;
    wrapper.layer.cornerRadius = 3.0f;
    wrapper.clipsToBounds = YES;
    cell.contentWrapper = wrapper;
    return cell;
}

- (void)setCell:(MsgBoxHealthItemModel *)model tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    CGFloat offsetByTime = 0;
    if (model.formatShowTime.length) {
        if (!self.timeLabel) {
            UILabel *time = [UILabel new];
            self.timeLabel = time;
            time.textColor = RGBHex(qwColor8);
            time.font = fontSystem(kFontS5);
            time.frame = CGRectMake(0, 15.0, SCREEN_W, 15);
            time.text = model.formatShowTime;
            time.textAlignment = NSTextAlignmentCenter;
            time.numberOfLines = 1;
            [self.contentView addSubview:time];
        }
        self.timeLabel.text = model.formatShowTime;
        offsetByTime = 40.0;
    } else {
        [self.timeLabel removeFromSuperview];
        offsetByTime = 15.0;
    }
    
    UIView *wrapper = self.contentWrapper;
    if (!wrapper) {
        [self.contentView addSubview:wrapper];
        self.contentWrapper = wrapper;
        wrapper.layer.borderColor = RGBHex(0xc8c7cc).CGColor;
        wrapper.layer.borderWidth = 0.5;
        wrapper.layer.cornerRadius = 3.0f;
        wrapper.clipsToBounds = YES;
    }
    wrapper.frame = CGRectMake(kMsgBoxHealthCellIndentX, offsetByTime, SCREEN_W - 2*kMsgBoxHealthCellIndentX, [MsgBoxHealthDietTipsCell getCachedCellHeightWithModel:model tableView:tableView indexPath:indexPath] - 40.0);
    
    // 可能的优化
    MsgBoxHealthCell *headCell = [MsgBoxHealthDietTipsCell _reusableCell1];
    headCell.titleLabel.text = model.title;
    headCell.subTitleLabel.text = model.content;
    headCell.midSeperator.hidden = model.tags.count == 0;
    [self reLayoutCell:headCell];
    CGSize size = [headCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    headCell.frame = CGRectMake(0, 0, SCREEN_W - 2*kMsgBoxHealthCellIndentX, size.height);
    [wrapper addSubview:headCell];
//    wrapper.backgroundColor = [UIColor redColor];
    CGFloat offsetY = size.height;
    
    NSInteger idx = 0;
    for (NSDictionary *taboo in model.tags) {
        MsgBoxHealthCell2 *itemCell = [MsgBoxHealthDietTipsCell _reusableCell2];
        itemCell.contentTitleLabel.text = taboo[@"proName"];
        itemCell.contentLabel.text = taboo[@"taboo"];
        [self reLayoutCell:itemCell];
        itemCell.contentLabel.preferredMaxLayoutWidth = CGRectGetWidth(itemCell.contentLabel.bounds);
        CGSize itemSize = [itemCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        itemCell.frame = CGRectMake(0, offsetY, SCREEN_W - 2*kMsgBoxHealthCellIndentX, itemSize.height);
        [wrapper addSubview:itemCell];
        offsetY += itemSize.height;
        if (idx == model.tags.count - 1) {
            itemCell.bottomSeperator.hidden = YES;
        } else {
            itemCell.bottomSeperator.hidden = NO;
        }
        idx++;
    }
}

- (void)reLayoutCell:(UITableViewCell *)cell
{
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    cell.bounds = CGRectMake(0.0f, 0.0f, SCREEN_W - 2 * kMsgBoxHealthCellIndentX, CGRectGetHeight(cell.bounds));
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
}

+ (CGFloat)getCellHeightWithModel:(MsgBoxHealthItemModel *)model
{
    CGFloat timeHeight = model.formatShowTime.length ? 15.0 + 15.0 + 10.0 : 15.0;
    CGFloat headCellHeight = [self calculateHeadCellHeightWithArg1:model.title arg2:@"您购买的药品含有饮食禁忌"];
    CGFloat itemCellHeightSum = 0.0;
    for (NSDictionary *taboo in model.tags) {
        itemCellHeightSum += [self calculateItemCellHeightWithArg1:taboo[@"proName"] arg2:taboo[@"taboo"]];
    }
    return timeHeight + headCellHeight + itemCellHeightSum;
}

+ (NSMutableDictionary *)offscreenCells
{
    static NSMutableDictionary *offscreenCells = nil;
    if (!offscreenCells) {
        offscreenCells = [NSMutableDictionary dictionary];
    }
    return offscreenCells;
}

+ (CGFloat)calculateHeadCellHeightWithArg1:(NSString *)arg1 arg2:(NSString *)arg2
{
    NSString *reuseIdentifier = @"MsgBoxHealthCell";
    ;
    MsgBoxHealthCell *cell = [self.offscreenCells objectForKey:reuseIdentifier];
    if (!cell) {
        cell = [MsgBoxHealthCell cell];
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
    }
    cell.titleLabel.text = arg1;
    cell.subTitleLabel.text = arg2;
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    // height?
    cell.bounds = CGRectMake(0.0f, 0.0f, SCREEN_W - 2 * kMsgBoxHealthCellIndentX, CGRectGetHeight(cell.bounds));
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

+ (CGFloat)calculateItemCellHeightWithArg1:(NSString *)arg1 arg2:(NSString *)arg2
{
    NSString *reuseIdentifier = @"MsgBoxHealthCell2";
    ;
    MsgBoxHealthCell2 *cell = [self.offscreenCells objectForKey:reuseIdentifier];
    if (!cell) {
        cell = [MsgBoxHealthCell2 cell];
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
    }
    cell.contentTitleLabel.text = arg1;
    cell.contentLabel.text = arg2;
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    // height?
    cell.bounds = CGRectMake(0.0f, 0.0f, SCREEN_W - 2 * kMsgBoxHealthCellIndentX, CGRectGetHeight(cell.bounds));
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    cell.contentLabel.preferredMaxLayoutWidth = CGRectGetWidth(cell.contentLabel.bounds);
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    for (id view in self.contentWrapper.subviews) {
        if ([view isMemberOfClass:[MsgBoxHealthCell class]]) {
            [MsgBoxHealthDietTipsCell _reuseCell1:view];
            [view removeFromSuperview];
        } else if ([view isMemberOfClass:[MsgBoxHealthCell2 class]]) {
            [MsgBoxHealthDietTipsCell _reuseCell2:view];
            [view removeFromSuperview];
        }
    }
}

+ (void)_reuseCell1:(MsgBoxHealthCell *)cell
{
    if (cell) {
        [_reusableCellSet1 addObject:cell];
    }
}

+ (void)_reuseCell2:(MsgBoxHealthCell2 *)cell
{
    if (cell) {
        [_reusableCellSet2 addObject:cell];
    }
}

+ (MsgBoxHealthCell *)_reusableCell1
{
    MsgBoxHealthCell *cell = [_reusableCellSet1 anyObject];
    if (!cell) {
        cell = [MsgBoxHealthCell cell];
        DDLogVerbose(@"----- cell1 created");
    } else {
        [_reusableCellSet1 removeObject:cell];
    }
    return cell;
}

+ (MsgBoxHealthCell2 *)_reusableCell2
{
    MsgBoxHealthCell2 *cell = [_reusableCellSet2 anyObject];
    if (!cell) {
        cell = [MsgBoxHealthCell2 cell];
        DDLogVerbose(@"----- cell2 created");
    } else {
        [_reusableCellSet2 removeObject:cell];
    }
    return cell;
}

@end


#pragma mark - MsgBoxHealthCell
@interface MsgBoxHealthCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeight;

@end

@implementation MsgBoxHealthCell

+ (instancetype)cell
{
    MsgBoxHealthCell *cell;
    NSArray *cellArr = [[NSBundle mainBundle] loadNibNamed:@"MsgBoxHealthCell" owner:nil options:nil];
    for (UITableViewCell *nibCell in cellArr) {
        if ([nibCell isKindOfClass:[MsgBoxHealthCell class]]) {
            cell = (MsgBoxHealthCell *)nibCell;
            break;
        }
    }
    return cell;
}

- (void)awakeFromNib {
    // Initialization code
//    self.timeLabel.textColor = RGBHex(qwColor8);
//    self.timeLabel.font = fontSystem(kFontS5);
    self.titleLabel.textColor = RGBHex(qwColor6);
    self.titleLabel.font = fontSystem(kFontS3);
    self.subTitleLabel.textColor = RGBHex(qwColor24);
    self.subTitleLabel.font = fontSystem(kFontS5);
    self.midSeperator.backgroundColor = RGBHex(0xc8c7cc);
    self.separatorHeight.constant = 0.5;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setCell:(id)model
{
    MsgBoxHealthItemModel *item = (MsgBoxHealthItemModel *)model;
    switch (item.source.integerValue) {
        case MsgBoxHealthItemSourceTypeBuyMedicine:
            self.subTitleLabel.text = @"根据您的用药为您推送";
            break;
        case MsgBoxHealthItemSourceTypeMedicineUsage:
            self.subTitleLabel.text = @"根据您的用药为您推送";
            break;
        case MsgBoxHealthItemSourceTypeDietTips:
            self.subTitleLabel.text = @"根据您的用药为您推送";
            break;
        default:
            break;
    }
}

@end


#pragma mark - MsgBoxHealthCell2
@interface MsgBoxHealthCell2 ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeight;

@end
@implementation MsgBoxHealthCell2


+ (instancetype)cell
{
    MsgBoxHealthCell2 *cell;
    NSArray *cellArr = [[NSBundle mainBundle] loadNibNamed:@"MsgBoxHealthCell" owner:nil options:nil];
    for (UITableViewCell *nibCell in cellArr) {
        if ([nibCell isKindOfClass:[MsgBoxHealthCell2 class]]) {
            cell = (MsgBoxHealthCell2 *)nibCell;
            break;
        }
    }
    return cell;
}


- (void)awakeFromNib
{
    self.contentTitleLabel.textColor = RGBHex(qwColor6);
    self.contentTitleLabel.font = fontSystem(kFontS4);
    self.contentLabel.textColor = RGBHex(qwColor8);
    self.contentLabel.font = fontSystem(kFontS4);
    self.bottomSeperator.backgroundColor = RGBHex(0xc8c7cc);
    self.separatorHeight.constant = 0.5;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end

NSString *const kRouterEventMsgBoxHealthCellLink = @"kRouterEventMsgBoxHealthCellLink";
NSString *const kRouterEventMsgBoxHealthCellActionBtn = @"kRouterEventMsgBoxHealthCellActionBtn";


#pragma mark - MsgBoxHealthCell3
@interface MsgBoxHealthCell3 () <MLEmojiLabelDelegate>
@property (weak, nonatomic) IBOutlet UIView *cellWrapper;
@property (weak, nonatomic) IBOutlet MLEmojiLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *midSeperator;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelTopMargin;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeight;

@end
@implementation MsgBoxHealthCell3

+ (instancetype)cell
{
    MsgBoxHealthCell3 *cell;
    NSArray *cellArr = [[NSBundle mainBundle] loadNibNamed:@"MsgBoxHealthCell" owner:nil options:nil];
    for (UITableViewCell *nibCell in cellArr) {
        if ([nibCell isKindOfClass:[MsgBoxHealthCell3 class]]) {
            cell = (MsgBoxHealthCell3 *)nibCell;
            break;
        }
    }
    return cell;
}

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;
    self.selectedBackgroundView = nil;
    self.timeLabel.textColor = RGBHex(qwColor8);
    self.timeLabel.font = fontSystem(kFontS5);
    self.contentLabel.textColor = RGBHex(qwColor8);
    self.contentLabel.font = fontSystem(kFontS4);
    self.actionBtn.titleLabel.font = fontSystem(kFontS4);
    [self.actionBtn setTitleColor:RGBHex(qwColor5) forState:UIControlStateNormal];
    [self.actionBtn addTarget:self action:@selector(actionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.midSeperator.backgroundColor = RGBHex(0xc8c7cc);
    self.separatorHeight.constant = 0.5;
    self.cellWrapper.layer.borderColor = RGBHex(0xc8c7cc).CGColor;
    self.cellWrapper.layer.borderWidth = 0.5;
    self.cellWrapper.layer.cornerRadius = 3.0f;
    self.cellWrapper.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    self.autoresizingMask = UIViewAutoresizingNone;
//    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentLabel.disableEmoji = NO;
    self.contentLabel.emojiDelegate = self;
    self.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
//    self.contentLabel.lineSpacing = 7.0;
//    self.contentLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
//    self.contentLabel.disableThreeCommon = NO;
//    self.contentLabel.numberOfLines=0;
//    self.contentLabel.customEmojiPlistName = @"expressionImage_custom.plist";
//    self.contentLabel.isNeedAtAndPoundSign = NO;
}

- (void)setCell:(id)obj tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    MsgBoxHealthItemModel *model = obj;
    BOOL hasTime = model.formatShowTime.length > 0;
    if (!hasTime) {
        self.timeLabelHeight.constant = 0;
        self.timeLabelTopMargin.constant = 0;
    } else {
        self.timeLabelHeight.constant = 15.0;
        self.timeLabelHeight.constant = 15.0;
    }
    self.timeLabel.text = model.formatShowTime;
    [self.actionBtn setTitle:@"立即查看" forState:UIControlStateNormal];
    self.contentLabel.emojiText=  model.content;
    if(model.tags){
        [self.contentLabel addLinkTags:model.tags];
    }
}


+ (CGFloat)getCellHeightWithModel:(MsgBoxHealthItemModel *)model
{
    MsgBoxHealthCell3 *cell = [self cell];
    [cell setCell:model tableView:nil indexPath:nil];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    cell.bounds = CGRectMake(0.0f, 0.0f, SCREEN_W, CGRectGetHeight(cell.bounds));
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    cell.contentLabel.preferredMaxLayoutWidth = CGRectGetWidth(cell.contentLabel.bounds);
//    CGFloat maxWidth = SCREEN_W - 2 * kMsgBoxHealthCellIndentX;
//    CGFloat contentLabelHeight = [cell.contentLabel systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//    CGSize textSize = [MLEmojiLabel needSizeWithText:model.content WithConstrainSize:CGSizeMake(maxWidth, MAXFLOAT) FontSize:kFontS4];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;// - contentLabelHeight + textSize.height;
    return height;
}

- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type
{
    [self routerEventWithName:kRouterEventMsgBoxHealthCellLink userInfo:@{@"link":link,@"type":@(type), @"source": emojiLabel}];
}

- (void)actionBtnClicked:(UIButton *)btn
{
    [self routerEventWithName:kRouterEventMsgBoxHealthCellActionBtn userInfo:@{@"source": btn}];
}

@end

#pragma mark - MsgBoxHealthCell4
@interface MsgBoxHealthCell4 () <MLEmojiLabelDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelHeight;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *cellTopWrapper;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *cellBottomWrapper;
@property (weak, nonatomic) IBOutlet MLEmojiLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomSeperator;
@property (weak, nonatomic) IBOutlet UIView *midSeperator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeight;
@property (weak, nonatomic) IBOutlet UIView *cellWrapper;

@end
@implementation MsgBoxHealthCell4

+ (instancetype)cell
{
    MsgBoxHealthCell4 *cell;
    NSArray *cellArr = [[NSBundle mainBundle] loadNibNamed:@"MsgBoxHealthCell" owner:nil options:nil];
    for (UITableViewCell *nibCell in cellArr) {
        if ([nibCell isKindOfClass:[self class]]) {
            cell = (MsgBoxHealthCell4 *)nibCell;
            break;
        }
    }
    return cell;
}

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;
    self.selectedBackgroundView = nil;
    self.timeLabel.textColor = RGBHex(qwColor8);
    self.timeLabel.font = fontSystem(kFontS5);
    self.titleLabel.textColor = RGBHex(qwColor6);
    self.titleLabel.font = fontSystem(kFontS3);
    self.subTitleLabel.textColor = RGBHex(qwColor24);
    self.subTitleLabel.font = fontSystem(kFontS5);
    self.contentLabel.textColor = RGBHex(qwColor7);
    self.contentLabel.font = fontSystem(kFontS4);
    self.midSeperator.backgroundColor = RGBHex(0xc8c7cc);
    self.separatorHeight.constant = 0.5;
    self.cellWrapper.layer.borderColor = RGBHex(0xc8c7cc).CGColor;
    self.cellWrapper.layer.borderWidth = 0.5;
    self.cellWrapper.layer.cornerRadius = 3.0f;
    self.cellWrapper.clipsToBounds = YES;
    self.bottomSeperator.hidden = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentLabel.disableEmoji = YES;
    self.contentLabel.emojiDelegate = self;
    self.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
}

- (void)setCell:(id)obj tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    MsgBoxHealthItemModel *model = obj;
    BOOL hasTime = model.formatShowTime.length > 0;
    if (!hasTime) {
        self.timeLabelHeight.constant = 0;
        self.timeLabelTopMargin.constant = 0;
    } else {
        self.timeLabelHeight.constant = 15.0;
        self.timeLabelHeight.constant = 15.0;
    }
    self.timeLabel.text = model.formatShowTime;
    self.titleLabel.text = model.title;
    self.subTitleLabel.text = @"根据您的用药为您推送";
    self.contentLabel.text = model.content;
    self.contentLabel.emojiText= model.content;
    if(model.tags){
        [self.contentLabel addLinkTags:model.tags];
    }
}

+ (CGFloat)getCellHeightWithModel:(MsgBoxHealthItemModel *)model
{
    MsgBoxHealthCell4 *cell = [self cell];
    [cell setCell:model tableView:nil indexPath:nil];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    cell.bounds = CGRectMake(0.0f, 0.0f, SCREEN_W, CGRectGetHeight(cell.bounds));
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    cell.contentLabel.preferredMaxLayoutWidth = CGRectGetWidth(cell.contentLabel.bounds);
    //    CGFloat maxWidth = SCREEN_W - 2 * kMsgBoxHealthCellIndentX;
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type
{
    [self routerEventWithName:kRouterEventMsgBoxHealthCellLink userInfo:@{@"link":link,@"type":@(type), @"source": emojiLabel}];
}

@end

#pragma mark - MsgBoxHealthCell5
@interface MsgBoxHealthCell5 () <MLEmojiLabelDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelHeight;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *cellTopWrapper;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *cellBottomWrapper;
@property (weak, nonatomic) IBOutlet MLEmojiLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomSeperator;
@property (weak, nonatomic) IBOutlet UIView *midSeperator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeight;
@property (weak, nonatomic) IBOutlet UILabel *contentTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *cellWrapper;

@end
@implementation MsgBoxHealthCell5

+ (instancetype)cell
{
    MsgBoxHealthCell5 *cell;
    NSArray *cellArr = [[NSBundle mainBundle] loadNibNamed:@"MsgBoxHealthCell" owner:nil options:nil];
    for (UITableViewCell *nibCell in cellArr) {
        if ([nibCell isKindOfClass:[self class]]) {
            cell = (MsgBoxHealthCell5 *)nibCell;
            break;
        }
    }
    return cell;
}

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;
    self.selectedBackgroundView = nil;
    self.timeLabel.textColor = RGBHex(qwColor8);
    self.timeLabel.font = fontSystem(kFontS5);
    self.titleLabel.textColor = RGBHex(qwColor6);
    self.titleLabel.font = fontSystem(kFontS3);
    self.subTitleLabel.textColor = RGBHex(qwColor24);
    self.subTitleLabel.font = fontSystem(kFontS5);
    self.contentLabel.textColor = RGBHex(qwColor7);
    self.contentLabel.font = fontSystem(kFontS4);
    self.contentTitleLabel.textColor = RGBHex(qwColor6);
    self.contentTitleLabel.font = fontSystem(kFontS4);
    self.midSeperator.backgroundColor = RGBHex(0xc8c7cc);
    self.bottomSeperator.hidden = YES;
    self.separatorHeight.constant = 0.5;
    self.cellWrapper.layer.borderColor = RGBHex(0xc8c7cc).CGColor;
    self.cellWrapper.layer.borderWidth = 0.5;
    self.cellWrapper.layer.cornerRadius = 3.0f;
    self.cellWrapper.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentLabel.disableEmoji = YES;
    self.contentLabel.emojiDelegate = self;
    self.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
}

- (void)setCell:(id)obj tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    MsgBoxHealthItemModel *model = obj;
    BOOL hasTime = model.formatShowTime.length > 0;
    if (!hasTime) {
        self.timeLabelHeight.constant = 0;
        self.timeLabelTopMargin.constant = 0;
    } else {
        self.timeLabelHeight.constant = 15.0;
        self.timeLabelHeight.constant = 15.0;
    }
    self.timeLabel.text = model.formatShowTime;
    self.titleLabel.text = model.title;
    self.subTitleLabel.text = @"根据您的用药为您推送";
    
    self.contentLabel.emojiText= model.content;
    if(model.tags){
        TagWithMessage *tag = model.tags.firstObject;
        self.contentTitleLabel.text = tag.title;
        [self.contentLabel addLinkTags:model.tags];
    }
}

+ (CGFloat)getCellHeightWithModel:(MsgBoxHealthItemModel *)model
{
    MsgBoxHealthCell5 *cell = [self cell];
    [cell setCell:model tableView:nil indexPath:nil];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    cell.bounds = CGRectMake(0.0f, 0.0f, SCREEN_W, CGRectGetHeight(cell.bounds));
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    cell.contentLabel.preferredMaxLayoutWidth = CGRectGetWidth(cell.contentLabel.bounds);
    //    CGFloat maxWidth = SCREEN_W - 2 * kMsgBoxHealthCellIndentX;
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type
{
    [self routerEventWithName:kRouterEventMsgBoxHealthCellLink userInfo:@{@"link":link,@"type":@(type), @"source": emojiLabel}];
}

@end
