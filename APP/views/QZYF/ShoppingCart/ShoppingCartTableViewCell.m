//
//  ShoppingCartTableViewCell.m
//  APP
//
//  Created by garfield on 16/1/4.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "ShoppingCartTableViewCell.h"
#import "MallCartModel.h"
#import "UIImageView+WebCache.h"

@implementation ShoppingCartTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.productNum.layer.borderWidth = 1.0;
    self.productNum.layer.borderColor = RGB(210, 210, 210).CGColor;
    self.ProNumText.layer.borderWidth = 1.0;
    self.ProNumText.layer.borderColor = RGBHex(qwColor10).CGColor;
    self.giftLabel.layer.borderWidth = 1.0;
    self.giftLabel.layer.borderColor = RGBHex(qwColor10).CGColor;
    self.giftLabel.layer.masksToBounds = YES;
    self.giftLabel.layer.cornerRadius = 3.0f;
    
    _increaseButton.layer.borderWidth = 1;
    _increaseButton.layer.cornerRadius = 3.0f;
    _increaseButton.layer.masksToBounds = YES;
    _increaseButton.layer.borderColor = RGBHex(qwColor10).CGColor;
    _decreaseButton.layer.borderWidth = 1;
    _decreaseButton.layer.cornerRadius = 3.0f;
    _decreaseButton.layer.masksToBounds = YES;
    _decreaseButton.layer.borderColor = RGBHex(qwColor10).CGColor;
}

+ (CGFloat)getCellHeight:(id)data
{
    CGFloat height = 89.0f;
    CartProductVoModel *productModel = (CartProductVoModel *)data;
    if( productModel.promotions.count > 0 ) {
        CartPromotionVoModel *model = productModel.promotions[0];
        switch (model.type) {
            case 1: {
                //1.买赠
                height += 20;
                if(productModel.saleStock >= model.unitNum) {
                    if(productModel.quantity >= model.unitNum) {
                        height += 25+12;
                    }
                }
                if(productModel.quantity > productModel.saleStock) {
                    height += 15 + 12;
                }
                break;
            }
            case 2: {
                //2.折扣
                height += 20;
                if(productModel.saleStock >= model.unitNum) {
                    if(productModel.quantity >= model.unitNum) {
//                        height += 25+12;
                    }
                }
                if(productModel.quantity > productModel.saleStock) {
                    height += 15 + 12;
                }
                break;
            }
            case 3: {
                //3.立减
                height += 20;
                if(productModel.saleStock >= model.unitNum) {
                    if(productModel.quantity >= model.unitNum) {
//                        height += 25+12;
                    }
                }
                if(productModel.quantity > productModel.saleStock) {
                    height += 15 + 12;
                }
                break;
            }
            case 4: {
                //4.特价
                height += 20;
                if(productModel.saleStock >= model.unitNum) {
                    if(productModel.quantity >= model.unitNum) {
//                        height += 25+12;
                    }
                }
                if(productModel.quantity > productModel.saleStock) {
                    height += 15 + 12;
                }
                break;
            }
            case 5: {
                //5.抢购
                height += 20;
                if(productModel.saleStock >= model.unitNum) {
                    if(productModel.quantity >= model.unitNum) {
//                        height += 25+12;
                    }
                }
                if(productModel.quantity > productModel.saleStock) {
                    height += 15 + 12;
                }
                break;
            }
            default:
                if(productModel.quantity > productModel.stock) {
                    height += 15 + 12;
                }
                break;
        }
    }else{
        if(productModel.quantity > productModel.stock) {
            height += 15 + 12;
        }
    }
    return height;
}

- (void)setCell:(id)data
{
    self.separatorLine.hidden = YES;
    CartProductVoModel *productModel = (CartProductVoModel *)data;
    
    [self.productImage setImageWithURL:[NSURL URLWithString:productModel.imgUrl] placeholderImage:[UIImage imageNamed:@"药品默认图片"]];
    self.productNameLabel.text = productModel.name;
    self.productPrice.text = [NSString stringWithFormat:@"￥%@",productModel.price];
//    self.productNum.text = [NSString stringWithFormat:@"%d",productModel.quantity];
    self.ProNumText.text = [NSString stringWithFormat:@"%d",productModel.quantity];
    if(productModel.choose) {
        [self.chooseButton setImage:[UIImage imageNamed:@"icon_shopping_selected"] forState:UIControlStateNormal];
    }else{
        [self.chooseButton setImage:[UIImage imageNamed:@"icon_shopping_rest"] forState:UIControlStateNormal];
    }
    self.specLabel.text = productModel.spec;
    NSString *hintString = nil;
    if( productModel.promotions.count > 0 ) {
        CartPromotionVoModel *model = productModel.promotions[0];
        
        switch (model.showType) {
            case 1:
                self.promotionLabel.text = model.title;
                self.promotionIcon.image = [UIImage imageNamed:@"label_vouchers"];
                break;
            case 2:
                self.promotionLabel.text = model.title;
                self.promotionIcon.image = [UIImage imageNamed:@"iocn_kindness_detailsbig"];
                break;
            case 3:
                self.promotionLabel.text = model.title;
                self.promotionIcon.image = [UIImage imageNamed:@"iocn_rob_shoppingbig"];
                break;
            default:
                break;
        }
        NSInteger presentNum = 0;
        
        if(model.type > 0) {
            if(productModel.quantity <= productModel.saleStock) {
                hintString = @"";
            }else{
                NSInteger saleStockNum = 0;
                NSInteger stockNum = 0;
                saleStockNum = floor(productModel.saleStock / model.unitNum) * model.unitNum;
                stockNum = productModel.quantity - saleStockNum;
                if(stockNum > productModel.stock) {
                    hintString = @"商品库存不足";
                }else{
                    hintString = @"优惠商品库存不足";
                }
            }
            if(productModel.quantity >= productModel.saleStock) {
                presentNum = floor(productModel.saleStock / model.unitNum);
            }else{
                presentNum = floor(productModel.quantity / model.unitNum);
            }
        }else{
            if(productModel.quantity >  productModel.stock){
                hintString = @"商品库存不足";
            }
        }
        if(model.type == 1) {
            if(productModel.quantity <= productModel.saleStock) {
                presentNum = floor(productModel.quantity / model.unitNum) * model.presentNum;
            }else{
                presentNum = floor(productModel.saleStock / model.unitNum) * model.presentNum;
            }
        }else if (model.type == 5) {
            if(productModel.quantity > model.limitQty){
                presentNum = model.limitQty;
            }else {
                presentNum = productModel.quantity;
            }
        }

        switch (model.type) {
            case 1: {
                //1.买赠
                if(productModel.quantity >= model.unitNum && productModel.saleStock > model.unitNum) {
                    [self setProductStatus:ProductShowPresentGift];
                    self.giftLabel.text = [NSString stringWithFormat:@"  【赠送】%@",model.presentName];
                    self.giftNumLabel.text = [NSString stringWithFormat:@"×%d",presentNum];
                }else{
                    [self setProductStatus:ProductNotShowPresentGift];
                }
                self.topConstraint.priority = 999;
                break;
            }
            case 2: {
                //2.折扣
                if(productModel.quantity >= model.unitNum && productModel.saleStock > model.unitNum) {
                    [self setProductStatus:ProductShowDiscount];
                    self.subtotalLabel.text = [NSString stringWithFormat:@"小计:￥%.2f",[productModel.price doubleValue] * productModel.quantity];
                    NSInteger count = presentNum;
                    double minusPrice = (count * model.unitNum) * (1 - model.value) * [productModel.price doubleValue];
                    self.promotionLabel.text = [NSString stringWithFormat:@"%@,已减:￥%.2f",self.promotionLabel.text,minusPrice];
                }else{
                    [self setProductStatus:ProductNotShowDiscount];
                }
                self.topConstraint.priority = 999;
                break;
            }
            case 3: {
                //3.立减

                if(productModel.quantity >= model.unitNum && productModel.saleStock > model.unitNum) {
                    self.subtotalLabel.text = [NSString stringWithFormat:@"小计:￥%.2f",[productModel.price doubleValue] * productModel.quantity];
                    NSInteger count = presentNum;
                    double minusPrice = count * model.value;
                    self.promotionLabel.text = [NSString stringWithFormat:@"%@,已减:￥%.2f",self.promotionLabel.text,minusPrice];
                    [self setProductStatus:ProductShowMinus];
                }else{
                    [self setProductStatus:ProductNotShowMinus];
                }
                self.topConstraint.priority = 999;
                break;
            }
            case 4: {
                //4.特价

                if(productModel.quantity >= model.unitNum && productModel.saleStock > model.unitNum) {
                    self.subtotalLabel.text = [NSString stringWithFormat:@"小计:￥%.2f",[productModel.price doubleValue] * productModel.quantity];
                    double minusPrice = presentNum * ([productModel.price doubleValue] - model.value);
                    self.promotionLabel.text = [NSString stringWithFormat:@"%@,已减:￥%.2f",self.promotionLabel.text,minusPrice];
                    [self setProductStatus:ProductShowSpecialoffer];
                }else{
                    [self setProductStatus:ProductShowNotShowSpecialoffer];
                }
                self.topConstraint.priority = 999;
                break;
            }
            case 5: {
                //5.抢购

                if(productModel.quantity >= model.unitNum && productModel.saleStock > model.unitNum) {
                    self.subtotalLabel.text = [NSString stringWithFormat:@"小计:￥%.2f",[productModel.price doubleValue] * productModel.quantity];
                    double minusPrice = ([productModel.price doubleValue] - model.value);
                    self.promotionLabel.text = [NSString stringWithFormat:@"%@,已减:￥%.2f",model.title,minusPrice * presentNum];
                    [self setProductStatus:ProductShowGrabActivity];
                }else{
                    [self setProductStatus:ProductShowNotGrabActivity];
                }
                self.topConstraint.priority = 999;
                break;
            }
            default:
                self.promotionIcon.hidden = YES;
                self.topColorCover.hidden = YES;
                self.promotionLabel.hidden = YES;
                self.subtotalLabel.hidden = YES;
                self.knockLabel.hidden = YES;
                self.topConstraint.priority = 788;
                break;
        }
    }else{
        self.topColorCover.hidden = YES;
        self.promotionIcon.hidden = YES;
        self.promotionLabel.hidden = YES;
        self.giftLabel.hidden = YES;
        self.giftNumLabel.hidden = YES;
        self.subtotalLabel.hidden = YES;
        self.knockLabel.hidden = YES;
        self.topConstraint.priority = 788;
        if(productModel.quantity > productModel.stock) {
            hintString = @"商品库存不足";
        }
    }
    
    if(hintString.length > 0) {
        self.insufficientLabel.hidden = NO;
        self.insufficientLabel.text = hintString;
    }else{
        self.insufficientLabel.hidden = YES;
        self.insufficientLabel.text = hintString;
    }
}

- (void)associateWithModel:(id)model
                    target:(id)target
                 indexPath:(NSIndexPath *)indexPath
{
    self.chooseButton.obj = model;
    self.increaseButton.obj = model;
    self.decreaseButton.obj = model;
    self.ProNumText.delegate = target;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.chooseButton addTarget:target action:@selector(chooseSingleProduct:) forControlEvents:UIControlEventTouchUpInside];
    [self.increaseButton addTarget:target action:@selector(increaseProductNum:) forControlEvents:UIControlEventTouchUpInside];
    [self.decreaseButton addTarget:target action:@selector(decreaseProductNum:) forControlEvents:UIControlEventTouchUpInside];
    [self.ProNumText addTarget:target action:@selector(inputProNum:) forControlEvents:UIControlEventEditingChanged];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 50)];
    view.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:241.0/255.0 blue:242.0/255.0 alpha:1];
    UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, 0, 40, 50)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:RGBHex(qwColor6) forState:UIControlStateNormal];
    [cancelBtn addTarget:target action:@selector(endEdit) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cancelBtn];
    QWButton *ensureBtn = [[QWButton alloc]initWithFrame:CGRectMake(APP_W - 55, 0, 40, 50)];
    ensureBtn.obj = model;
    ensureBtn.tag = indexPath.row;
    [ensureBtn setTitle:@"完成" forState:UIControlStateNormal];
    [ensureBtn setTitleColor:RGBHex(qwColor12) forState:UIControlStateNormal];
    [ensureBtn addTarget:target action:@selector(confirmEdit:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:ensureBtn];
    self.ProNumText.inputAccessoryView = view;
    self.decreaseButton.tag = indexPath.row;
    self.increaseButton.tag = indexPath.row;
    self.chooseButton.tag = indexPath.row;
    
    [self.increaseBigButton addTarget:target action:@selector(increaseProductNum:) forControlEvents:UIControlEventTouchUpInside];
    [self.decreaseBigButton addTarget:target action:@selector(decreaseProductNum:) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
    self.increaseBigButton.obj = model;
    self.decreaseBigButton.obj = model;
    self.decreaseBigButton.tag = indexPath.row;
    self.increaseBigButton.tag = indexPath.row;
}

- (void)setProductStatus:(ShoppingProductPromotion)status
{
    switch (status) {
        case ProductShowPresentGift: {
            self.promotionIcon.hidden = NO;
            self.topColorCover.hidden = NO;
            self.promotionLabel.hidden = NO;
            self.giftLabel.hidden = NO;
            self.giftNumLabel.hidden = NO;
            self.subtotalLabel.hidden = YES;
            self.knockLabel.hidden = YES;
            
            break;
        }
        case ProductNotShowPresentGift: {
            self.promotionIcon.hidden = NO;
            self.topColorCover.hidden = NO;
            self.promotionLabel.hidden = NO;
            self.giftLabel.hidden = YES;
            self.giftNumLabel.hidden = YES;
            self.subtotalLabel.hidden = YES;
            self.knockLabel.hidden = YES;
            
            break;
        }
        case ProductShowDiscount: {
            self.promotionIcon.hidden = NO;
            self.topColorCover.hidden = NO;
            self.promotionLabel.hidden = NO;
            self.giftLabel.hidden = YES;
            self.giftNumLabel.hidden = YES;
            self.subtotalLabel.hidden = NO;
            self.knockLabel.hidden = NO;
            break;
        }
        case ProductNotShowDiscount: {
            self.promotionIcon.hidden = NO;
            self.topColorCover.hidden = NO;
            self.promotionLabel.hidden = NO;
            self.giftLabel.hidden = YES;
            self.giftNumLabel.hidden = YES;
            self.subtotalLabel.hidden = YES;
            self.knockLabel.hidden = YES;
            break;
        }
        case ProductNotShowMinus: {
            self.promotionIcon.hidden = NO;
            self.topColorCover.hidden = NO;
            self.promotionLabel.hidden = NO;
            self.giftLabel.hidden = YES;
            self.giftNumLabel.hidden = YES;
            self.subtotalLabel.hidden = YES;
            self.knockLabel.hidden = YES;
            break;
        }
        case ProductShowMinus: {
            self.promotionIcon.hidden = NO;
            self.topColorCover.hidden = NO;
            self.promotionLabel.hidden = NO;
            self.giftLabel.hidden = YES;
            self.giftNumLabel.hidden = YES;
            self.subtotalLabel.hidden = NO;
            self.knockLabel.hidden = NO;
            break;
        }
        case ProductShowNotShowSpecialoffer: {
            self.promotionIcon.hidden = NO;
            self.topColorCover.hidden = NO;
            self.promotionLabel.hidden = NO;
            self.giftLabel.hidden = YES;
            self.giftNumLabel.hidden = YES;
            self.subtotalLabel.hidden = YES;
            self.knockLabel.hidden = YES;
            break;
        }
        case ProductShowSpecialoffer: {
            self.promotionIcon.hidden = NO;
            self.topColorCover.hidden = NO;
            self.promotionLabel.hidden = NO;
            self.giftLabel.hidden = YES;
            self.giftNumLabel.hidden = YES;
            self.subtotalLabel.hidden = NO;
            self.knockLabel.hidden = NO;
            break;
        }
        case ProductShowNotGrabActivity: {
            self.promotionIcon.hidden = NO;
            self.topColorCover.hidden = NO;
            self.promotionLabel.hidden = NO;
            self.giftLabel.hidden = YES;
            self.giftNumLabel.hidden = YES;
            self.subtotalLabel.hidden = NO;
            self.knockLabel.hidden = NO;
            break;
        }
        case ProductShowGrabActivity: {
            self.promotionIcon.hidden = NO;
            self.topColorCover.hidden = NO;
            self.promotionLabel.hidden = NO;
            self.giftLabel.hidden = YES;
            self.giftNumLabel.hidden = YES;
            self.subtotalLabel.hidden = NO;
            self.knockLabel.hidden = NO;
            break;
        }
        default:
            break;
    }
    [self.contentView sendSubviewToBack:self.topColorCover];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
