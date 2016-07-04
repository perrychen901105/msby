//
//  ShoppingCartViewController.m
//  APP
//  购物车列表 全量拉取   h5/mmall/cart
//
//  购物车同步           h5/mmall/cart/new/sync
//
//  购物车check接口      h5/mmall/cart/new/check
//
//  购物车非登录状态下拉取 h5/mmall/act/queryBranchs
//
//
//  Created by garfield on 16/1/4.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "ShoppingCartViewController.h"
#import "ShoppingCartTableViewCell.h"
#import "NewConfirmOrderViewController.h"
#import "MallCart.h"
#import "UITapGestureRecognizerExt.h"
#import "MGSwipeButton.h"
#import "SBJson.h"
#import "ConsultStoreModel.h"
#import "SVProgressHUD.h"
#import "MedicineDetailViewController.h"
#import "NoticeCustomView.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "ShoppingCartOverFlowView.h"
#import "BranchPromotionView.h"
#import "SubmitOrderSuccessViewController.h"
@interface ShoppingCartViewController ()<UITableViewDataSource,UITableViewDelegate,MGSwipeTableCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
//总价显示的Label
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;
//已减金额的Label
@property (weak, nonatomic) IBOutlet UILabel *minusPriceLabel;
//已选中的商品,套餐或者换购商品
@property (nonatomic, strong) NSMutableArray    *chooseList;
//缓存状态列表,只记录商品ID对应的数量,选中状态
@property (nonatomic, strong) NSMutableArray    *chooseStatus;
//待删除的IndexPath,方便找到删除的某一行,在AlertView回调中使用
@property (nonatomic, strong) NSIndexPath       *delIndexPath;
//待删除的套餐,由于套餐中包含多个商品,所以没办法指定删某一行,因此记录套餐Model
@property (nonatomic, strong) ComboProductVoModel   *delProductModel;
@property (weak, nonatomic) IBOutlet UIView     *footerView;

@property (weak, nonatomic) IBOutlet UIView     *headerHintView;
@property (weak, nonatomic) IBOutlet UIControl *bottomOverFlowView;
@property (nonatomic, strong) NSLock            *recursiveLock;
@end

@implementation ShoppingCartViewController{
    NSString *inputNumber;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        [self addObserverGlobal];
        self.title = @"购物车";
        self.pageType = 1;
        self.shoppingList = [NSMutableArray arrayWithCapacity:100];
        _chooseList = [NSMutableArray arrayWithCapacity:10];
        //读取上次的数量,选中状态等等,服务器不返回,不记录该参数
        _chooseStatus = [ChooseStatusModel getArrayFromDBWithWhere:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [self removeObserverGlobal];
    _recursiveLock = [[NSLock alloc] init];
    [_recursiveLock unlock];
    [QWGLOBALMANAGER statisticsEventId:@"购物车出现" withLable:nil withParams:nil];
    //如果未登录,需要取本地缓存数据
    if(QWGLOBALMANAGER.configure.userToken && ![QWGLOBALMANAGER.configure.userToken isEqualToString:@""]) {
        //此处不需要加载数据,因为登录成功后,此界面 可以自动接收登录成功通知,调用接口获取数据
    }else{
        NSArray *array = [CartBranchVoModel getArrayFromDBWithWhere:nil WithorderBy:@"timestamp desc"];
        if(array.count > 0) {
            
            [self.shoppingList addObjectsFromArray:array];
            //没登录,拉取3.1.0新接口,获取非登录状态下的商品列表
            [self queryOffLineBranchInfo];
            [self recoverModelStatusFromDB];
            //更新未读数
            [self syncUnreadNum];
        }else{
            [self checkBackGroundStatus];
        }
    }
    [super viewDidLoad];
    [self initializeUI];
}

//初始化UI控件
- (void)initializeUI
{
    [super initializeUI];
    [self.tableView setBackgroundColor:RGBHex(qwColor11)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"ShoppingCartTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"CombosTopCartTableViewCell" bundle:nil] forCellReuseIdentifier:CombosTopCartTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"CombosMiddleCartTableViewCell" bundle:nil] forCellReuseIdentifier:CombosMiddleCartTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"CombosBottomCartTableViewCell" bundle:nil] forCellReuseIdentifier:CombosBottomCartTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"CombosShowOneCartTableViewCell" bundle:nil] forCellReuseIdentifier:CombosShowOneCartTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"RedemptionCartTableViewCell" bundle:nil] forCellReuseIdentifier:RedemptionCartTableViewCellIdentifier];
    [self.tableView setBackgroundColor:RGBHex(qwColor11)];
}

//在非登录下状态获取药房换购信息
- (void)queryOffLineBranchInfo
{
    MMallRedemptionModelR *modelR = [MMallRedemptionModelR new];
    NSMutableArray *branchsId = [NSMutableArray array];
    for(CartBranchVoModel *branchModel in self.shoppingList) {
        [branchsId addObject:branchModel.branchId];
    }
    modelR.branchIds = [branchsId componentsJoinedByString:SeparateStr];
    [MallCart queryBranchsByMultiBranch:modelR success:^(CartVoModel *responseModel) {
        for(CartBranchVoModel *branchModel in responseModel.branchs) {
            for(CartBranchVoModel *subBranchModel in self.shoppingList) {
                if([branchModel.branchId isEqualToString:subBranchModel.branchId]) {
                    subBranchModel.branchName = branchModel.branchName;
                    subBranchModel.groupName = branchModel.groupName;
                    subBranchModel.supportOnlineTrading = branchModel.supportOnlineTrading;
                    subBranchModel.availableRedemptions = branchModel.availableRedemptions;
                }
            }
        }
        [self.tableView reloadData];
        [CartBranchVoModel deleteAllObjFromDB];
        [CartBranchVoModel saveObjToDBWithArray:self.shoppingList];
    } failure:NULL];
}

//以token 去刷新请求整个购物车数据
- (void)queryShoppingCart:(BOOL)clear
{
    MallCartModelR *modelR = [MallCartModelR new];
    modelR.token = QWGLOBALMANAGER.configure.userToken;
    [MallCart queryMMallCart:modelR success:^(CartVoModel *model) {
        if([model.apiStatus integerValue] == 1) {
            [self checkBackGroundStatus];
        }else{
            if(model.branchs.count > 0) {
                [self showShoppingCartBackgroundStatus:NormalShoppingCartStatus];
            }else{
                [self checkBackGroundStatus];
            }
        }
        if(clear) {
            [self.shoppingList removeAllObjects];
        }
        if(self.shoppingList.count > 0) {
            [self.shoppingList addObjectsFromArray:model.branchs];
            [self syncShoppingCart];
        }else{
            [self.shoppingList addObjectsFromArray:model.branchs];
            [self syncOnlineShoppingCart];
            [QWGLOBALMANAGER postNotif:NotifShoppingSyncAll data:nil object:nil];
        }
        [self.tableView reloadData];
    } failure:^(HttpException *e) {
        
    }];
}

//去结算,需要检测价格,库存是否有所变更
- (IBAction)calculateAction:(id)sender
{
    if (![QWGLOBALMANAGER checkLoginStatus:self]) {
        return;
    }
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"哪个页面"] = @"不带返回按钮的购物车";
    [QWGLOBALMANAGER statisticsEventId:@"x_gwc_qjs" withLable:@"购物车-去结算" withParams:setting];
    [QWGLOBALMANAGER statisticsEventId:@"购物车_立即预定" withLable:nil withParams:nil];
    
    
    NSMutableArray *chooseList = [NSMutableArray arrayWithCapacity:10];
    __block NSMutableArray *chooseModelList = [NSMutableArray arrayWithCapacity:10];
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithCapacity:5];
    __block CartBranchVoModel *branch;
    //统计当前选中的所有药品转成json并加入购物车
    for (CartBranchVoModel *branchModel in self.shoppingList) {
        for(CartProductVoModel *productModel in branchModel.products) {
            if(productModel.choose) {
                if(productModel.quantity > (productModel.stock + productModel.saleStock)) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"商品已经超过库存量,无法提交订单" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                    return;
                }
                branch = branchModel;
                [chooseModelList addObject:productModel];
                NSDictionary *dict = @{@"objId":productModel.id,@"quantity":[NSNumber numberWithInt:productModel.quantity],@"objType":[NSNumber numberWithInt:1]};
                [chooseList addObject:dict];
            }
        }
        for(CartComboVoModel *cartComboVoModel in branchModel.combos) {
            if(cartComboVoModel.choose) {
                branch = branchModel;
                [chooseModelList addObject:cartComboVoModel];
                NSDictionary *dict = @{@"objId":cartComboVoModel.packageId,@"quantity":[NSNumber numberWithInt:cartComboVoModel.quantity],@"objType":[NSNumber numberWithInt:2]};
                [chooseList addObject:dict];
            }
        }
        for(CartRedemptionVoModel *redemptionVoModel in branchModel.redemptions) {
            branch = branchModel;
            [chooseModelList addObject:redemptionVoModel];
            NSDictionary *dict = @{@"objId":redemptionVoModel.actId,@"quantity":[NSNumber numberWithInt:1],@"objType":[NSNumber numberWithInt:3]};
            [chooseList addObject:dict];
        }
        if(chooseList.count > 0) {
            jsonDict[@"items"] = chooseList;
            jsonDict[@"branchId"] = branchModel.branchId;
            break;
        }
    }
    if(chooseList.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"请先选择商品" duration:0.8f];
        return;
    }
    MMallCartCheckModelR *modelR = [MMallCartCheckModelR new];
    modelR.token = QWGLOBALMANAGER.configure.userToken;
    modelR.productsJson = [jsonDict JSONRepresentation];
    if(_totalPrice.text.length > 0)
        modelR.payableAccounts = [[_totalPrice.text substringFromIndex:0] doubleValue];

    [MallCart queryMallCartNewCheck:modelR success:^(BaseAPIModel *model) {
        if([model.apiStatus integerValue] == 0) {
            //成功的话,进入订单详情
            NewConfirmOrderViewController *confirmOrderViewController = [[NewConfirmOrderViewController alloc] initWithNibName:@"NewConfirmOrderViewController" bundle:nil];
            confirmOrderViewController.productsJson = modelR.productsJson;
//            confirmOrderViewController.chooseList = chooseModelList;
            confirmOrderViewController.branchModel = branch;
            confirmOrderViewController.invariableList = chooseModelList;
            confirmOrderViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:confirmOrderViewController animated:YES];
        }else if([model.apiStatus integerValue] == 2019001){
            //库存不足
            [self showDifferentAlertView:model.apiMessage cancelButton:@"知道了" confirmButton:nil alertTag:1117];
        }else if ([model.apiStatus integerValue] == 2019008) {
            //价格有变动
            [self showDifferentAlertView:model.apiMessage  cancelButton:@"取消" confirmButton:@"继续提交" alertTag:555];
        }else if ([model.apiStatus integerValue] == 2019010) {
            //选购的[商品名称]已下架
            [self showDifferentAlertView:[NSString stringWithFormat:@"%@,您确认要删除吗?",model.apiMessage] cancelButton:@"取消" confirmButton:@"删除" alertTag:999];
        }else{
            [SVProgressHUD showErrorWithStatus:model.apiMessage duration:0.8f];
        }
    } failure:NULL]; 
}

//同步本地购车列表至缓存
- (void)syncOnlineShoppingCart
{
    [CartBranchVoModel deleteAllObjFromDB];
    [self recoverModelStatusFromDB];
    [CartBranchVoModel saveObjToDBWithArray:self.shoppingList];
    [self syncUnreadNum];
}

- (void)recoverModelStatusFromDB
{
    for(CartBranchVoModel *branchModel in self.shoppingList) {
        //同步选中状态以及数量:TODO 待完成
        for(CartProductVoModel *productModel in branchModel.products)
        {
            for(ChooseStatusModel *statusModel in _chooseStatus) {
                if([productModel.id isEqualToString:statusModel.objId]) {
                    productModel.quantity = statusModel.quanity;
                    productModel.choose = statusModel.choose;
                    [self excludeAllProductExpecet:branchModel];
                }
            }
        }
        for(CartComboVoModel *comboVoModel in branchModel.combos) {
            for(ChooseStatusModel *statusModel in _chooseStatus) {
                if([comboVoModel.packageId isEqualToString:statusModel.objId]) {
                    comboVoModel.quantity = statusModel.quanity;
                    comboVoModel.choose = statusModel.choose;
                    [self excludeAllProductExpecet:branchModel];
                }
            }
        }
        
        for(CartRedemptionVoModel *redemption in branchModel.availableRedemptions) {
            for(ChooseStatusModel *statusModel in _chooseStatus) {
                if([redemption.actId isEqualToString:statusModel.objId]) {
                    double price = [self calculatePriceOnly:branchModel];
                    if(price >= redemption.limitPrice) {
                        redemption.quantity = statusModel.quanity;
                        redemption.choose = statusModel.choose;
                        branchModel.redemptions = [NSMutableArray arrayWithObject:redemption];
                        
                    }
                    [self excludeAllProductExpecet:branchModel];
                    break;
                }
            }
        }
        [self checkChooseAll:branchModel];
        
    }
    [self calculateTotalPrice];
}
#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CartBranchVoModel *model = self.shoppingList[section];
    //title显示  此药房支持互联网药品交易
    if(model.supportOnlineTrading) {
        return 39.0f + 29.0f;
    }else{
        return 39.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CartBranchVoModel *model = self.shoppingList[section];
    if(model.availableRedemptions.count > 0 && model.redemptions.count == 0) {
        CartRedemptionVoModel *showRedemption = nil;
        double price = [self calculatePriceOnly:model];
        for(CartRedemptionVoModel *subModel in model.availableRedemptions) {
            if(price >= subModel.limitPrice) {
                showRedemption = subModel;
            }
        }
        if(showRedemption) {
            return 38.0 + 8.0;
        }else{
            return 8.0;
        }
    }else{
        return 8.0;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CartBranchVoModel *model = self.shoppingList[section];
    CartRedemptionVoModel *showRedemption = nil;
    if(model.availableRedemptions.count > 0 && model.redemptions.count == 0) {
        double price = [self calculatePriceOnly:model];
        for(CartRedemptionVoModel *subModel in model.availableRedemptions) {
            if(price >= subModel.limitPrice) {
                showRedemption = subModel;
            }
        }
    }
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 8)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    if(!showRedemption) {
        return footerView;
    }else{
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 38.0 + 8.0)];
        UIView *topContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 38.0)];
        [topContainerView setBackgroundColor:RGBHex(qwColor19)];
        UIImageView *changeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 12, 14, 14)];
        changeImageView.image = [UIImage imageNamed:@"iocn_exchange_shoppingbig"];
        [topContainerView addSubview:changeImageView];
        UILabel *changeLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 12, 220, 14)];
        changeLabel.font = fontSystem(kFontS6);
        changeLabel.textColor = RGBHex(qwColor7);
        changeLabel.text = [NSString stringWithFormat:@"订单满%.2f元,可换购商品",showRedemption.limitPrice];
        [topContainerView addSubview:changeLabel];
        UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_btn_arrow_right"]];
        accessoryView.frame = CGRectMake(APP_W - 38, 12, 15, 15);
        [topContainerView addSubview:accessoryView];
        //[containerView addSubview:footerView];
        
        UITapGestureRecognizerExt *tapGesture = [[UITapGestureRecognizerExt alloc] initWithTarget:self action:@selector(showRedemptionList:)];
        tapGesture.obj = model;
        [topContainerView addGestureRecognizer:tapGesture];
        [containerView addSubview:topContainerView];
        
        return containerView;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self createDynamicHeaderView:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CartBranchVoModel *model = self.shoppingList[indexPath.section];
    NSMutableArray *combosArrays = [self sortCombosProdcut:model.combos];
    NSInteger combosCount = 0;
    for(CartComboVoModel *comboVoModel in model.combos) {
        combosCount += comboVoModel.druglist.count;
    }
    if(indexPath.row < model.products.count) {
        CartProductVoModel *productModel = model.products[indexPath.row];
        return [ShoppingCartTableViewCell getCellHeight:productModel];
    }else if(indexPath.row < model.products.count + combosCount){
        ComboProductVoModel *productModel = combosArrays[indexPath.row - model.products.count];
        switch (productModel.showType) {
            case 1:
                return [CombosTopCartTableViewCell getCellHeight:nil];
            case 2:
                return [CombosMiddleCartTableViewCell getCellHeight:nil];
            case 3:
                return [CombosBottomCartTableViewCell getCellHeight:nil];
            case 4:
                return [CombosShowOneCartTableViewCell getCellHeight:nil];
            default:
                break;
        }
        return 0;
    }else{
        return [RedemptionCartTableViewCell getCellHeight:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.shoppingList.count;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    CartBranchVoModel *model = self.shoppingList[section];
    NSInteger combosCount = 0;
    for(CartComboVoModel *comboVoModel in model.combos) {
        combosCount += comboVoModel.druglist.count;
    }
    return model.products.count + combosCount + model.redemptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CartBranchVoModel *model = self.shoppingList[indexPath.section];
    NSMutableArray *combosArrays = [self sortCombosProdcut:model.combos];
    NSInteger combosCount = 0;
    for(CartComboVoModel *comboVoModel in model.combos) {
        combosCount += comboVoModel.druglist.count;
    }
    for (CartComboVoModel *comboVoModel in model.combos) {
        [combosArrays addObjectsFromArray:comboVoModel.druglist];
    }
    if(indexPath.row < model.products.count) {
        CartProductVoModel *productModel = model.products[indexPath.row];
        
        ShoppingCartTableViewCell *shoppingCell = [atableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(shoppingCell == nil) {
            [atableView registerNib:[UINib nibWithNibName:@"ShoppingCartTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
            shoppingCell = [atableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
        shoppingCell.swipeDelegate = self;
        [shoppingCell setCell:productModel];
        shoppingCell.ProNumText.tag = indexPath.section *1000 + indexPath.row;
        [shoppingCell associateWithModel:model target:self indexPath:indexPath];
        return shoppingCell;
    }else if(indexPath.row < model.products.count + combosCount){
        ComboProductVoModel *productModel = combosArrays[indexPath.row - model.products.count];
        switch (productModel.showType) {
            case 1:
            {
                CombosTopCartTableViewCell *combosCell = [atableView dequeueReusableCellWithIdentifier:CombosTopCartTableViewCellIdentifier];
                [combosCell setCell:productModel];
                combosCell.swipeDelegate = self;
                return combosCell;
            }
            case 2:
            {
                CombosMiddleCartTableViewCell *combosCell = [atableView dequeueReusableCellWithIdentifier:CombosMiddleCartTableViewCellIdentifier];
                [combosCell setCell:productModel];
                combosCell.swipeDelegate = self;
                return combosCell;
            }
                
            case 3:
            {
                CombosBottomCartTableViewCell *combosCell = [atableView dequeueReusableCellWithIdentifier:CombosBottomCartTableViewCellIdentifier];
                [combosCell setCell:productModel];
                combosCell.swipeDelegate = self;
                combosCell.proNumText.tag = indexPath.section *1000 + indexPath.row;
                [combosCell associateWithModel:productModel target:self indexPath:indexPath];
                return combosCell;
            }
                
            case 4:
            {
                CombosShowOneCartTableViewCell *combosCell = [atableView dequeueReusableCellWithIdentifier:CombosShowOneCartTableViewCellIdentifier];
                [combosCell setCell:productModel];
                combosCell.proNumText.tag = indexPath.section *1000 + indexPath.row;
                [combosCell associateWithModel:productModel target:self indexPath:indexPath];
                combosCell.swipeDelegate = self;
                return combosCell;
            }
            default:
                return nil;
        }
        return 0;
    }else{
        //换购商品Cell,上半栏可以点击,重新弹出换购商品列表
        CartRedemptionVoModel *redemptionVoModel = model.redemptions[0];
        RedemptionCartTableViewCell *redemptionCell = [atableView dequeueReusableCellWithIdentifier:RedemptionCartTableViewCellIdentifier];
        redemptionCell.swipeDelegate = self;
        [redemptionCell.chooseButton addTarget:self action:@selector(cancelSelectedRedemption:) forControlEvents:UIControlEventTouchUpInside];
        redemptionCell.chooseButton.obj = model;
        [redemptionCell setCell:redemptionVoModel];
        
        UITapGestureRecognizerExt *tapGesture = [[UITapGestureRecognizerExt alloc] initWithTarget:self action:@selector(showRedemptionList:)];
        tapGesture.obj = model;
        [redemptionCell.touchCover addGestureRecognizer:tapGesture];
        [redemptionCell.contentView sendSubviewToBack:redemptionCell.touchCover];
        return redemptionCell;
    }
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    [QWGLOBALMANAGER statisticsEventId:@"购物车_点击商品" withLable:nil withParams:nil];
    //点击不同的Cell,进去商品详情界面
    MedicineDetailViewController *VC = [[MedicineDetailViewController alloc] initWithNibName:@"MedicineDetailViewController" bundle:nil];
    VC.lastPageName = @"购物车";
    VC.hidesBottomBarWhenPushed = YES;
    CartBranchVoModel *model = self.shoppingList[indexPath.section];
    NSMutableArray *combosArrays = [self sortCombosProdcut:model.combos];
    NSInteger combosCount = 0;
    for(CartComboVoModel *comboVoModel in model.combos) {
        combosCount += comboVoModel.druglist.count;
    }
    for (CartComboVoModel *comboVoModel in model.combos) {
        [combosArrays addObjectsFromArray:comboVoModel.druglist];
    }
    if(indexPath.row < model.products.count) {
        CartProductVoModel *productModel = model.products[indexPath.row];
        VC.proId = productModel.id;
    }else if(indexPath.row < model.products.count + combosCount){
        ComboProductVoModel *productModel = combosArrays[indexPath.row - model.products.count];
        VC.proId = productModel.branchProId;
    }else{
        CartRedemptionVoModel *productModel = model.redemptions[0];
        VC.proId = productModel.branchProId;
    }
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)cancelSelectedRedemption:(QWButton *)button
{
    CartBranchVoModel *model = button.obj;
    [self showDifferentAlertView:@"确定要放弃换购活动吗?" cancelButton:@"取消" confirmButton:@"确定" alertTag:1211];
    _delIndexPath = [NSIndexPath indexPathForRow:0 inSection:[self.shoppingList indexOfObject:model]];
}
//生成右滑删除按钮
-(NSArray *) createRightButtons: (int) number
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@"删除"};
    UIColor * colors[2] = {RGBHex(qwColor3)};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            return YES;
        }];
        if(i == 1) {
            [button setTitleColor:RGBHex(qwColor5) forState:UIControlStateNormal];
        }
        [result addObject:button];
    }
    return result;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 666) {
        if(buttonIndex == 1) {
            CartBranchVoModel *branchModel = self.shoppingList[_delIndexPath.section];
            [branchModel.products removeObjectAtIndex:_delIndexPath.row];
            if((branchModel.products.count + branchModel.combos.count) == 0) {
                [self.shoppingList removeObject:branchModel];
                if(self.shoppingList.count == 0) {
                    [self checkBackGroundStatus];
                }
            }
            [self checkExcludeRedemption:branchModel];
            [self.tableView reloadData];
            if(QWGLOBALMANAGER.loginStatus) {
                [self syncShoppingListOnly];
            }else{
                [CartBranchVoModel deleteAllObjFromDB];
                [CartBranchVoModel saveObjToDBWithArray:self.shoppingList];
                if(self.shoppingList.count == 0) {
                    [self checkBackGroundStatus];
                }
                [self syncUnreadNum];
            }
        }
        [self reloadNewInformation];
    }else if (alertView.tag == 777) {
        if(buttonIndex == 1) {
            CartBranchVoModel *branchModel = nil;
            for(CartBranchVoModel *branchVoModel in self.shoppingList) {
                for(CartComboVoModel *comboxModel in branchVoModel.combos) {
                    if([_delProductModel.packageId isEqualToString:comboxModel.packageId]) {
                        branchModel = branchVoModel;
                        [branchVoModel.combos removeObject:comboxModel];
                        break;
                    }
                }
            }
            if(branchModel.products.count == 0 && branchModel.combos.count == 0) {
                [self.shoppingList removeObject:branchModel];
                if(self.shoppingList.count == 0) {
                    [self checkBackGroundStatus];
                }
            }
            [self checkExcludeRedemption:branchModel];
            [self.tableView reloadData];
            if(QWGLOBALMANAGER.loginStatus) {
                [self syncShoppingListOnly];
            }else{
                [CartBranchVoModel deleteAllObjFromDB];
                [CartBranchVoModel saveObjToDBWithArray:self.shoppingList];
                if(self.shoppingList.count == 0) {
                    [self checkBackGroundStatus];
                }
                [self syncUnreadNum];
            }
        }
        [self reloadNewInformation];
    }else if (alertView.tag == 555) {
        //继续提交
        if(buttonIndex == 1) {
            NSMutableArray *chooseList = [NSMutableArray arrayWithCapacity:10];
            __block NSMutableArray *chooseModelList = [NSMutableArray arrayWithCapacity:10];
            NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithCapacity:5];
            __block CartBranchVoModel *branch;
            
            for (CartBranchVoModel *branchModel in self.shoppingList) {
                for(CartProductVoModel *productModel in branchModel.products) {
                    if(productModel.choose) {
                        if(productModel.quantity > (productModel.stock + productModel.saleStock)) {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"商品已经超过库存量,无法提交订单" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                            [alert show];
                            return;
                        }
                        branch = branchModel;
                        [chooseModelList addObject:productModel];
                        NSDictionary *dict = @{@"objId":productModel.id,@"quantity":[NSNumber numberWithInt:productModel.quantity],@"objType":[NSNumber numberWithInt:1]};
                        [chooseList addObject:dict];
                    }
                }
                for(CartComboVoModel *cartComboVoModel in branchModel.combos) {
                    if(cartComboVoModel.choose) {
                        branch = branchModel;
                        [chooseModelList addObject:cartComboVoModel];
                        NSDictionary *dict = @{@"objId":cartComboVoModel.packageId,@"quantity":[NSNumber numberWithInt:cartComboVoModel.quantity],@"objType":[NSNumber numberWithInt:2]};
                        [chooseList addObject:dict];
                    }
                }
                for(CartRedemptionVoModel *redemptionVoModel in branchModel.redemptions) {
                    if(redemptionVoModel.choose) {
                        branch = branchModel;
                        [chooseModelList addObject:redemptionVoModel];
                        NSDictionary *dict = @{@"objId":redemptionVoModel.actId,@"quantity":[NSNumber numberWithInt:1],@"objType":[NSNumber numberWithInt:3]};
                        [chooseList addObject:dict];
                    }
                }
                if(chooseList.count > 0) {
                    jsonDict[@"items"] = chooseList;
                    jsonDict[@"branchId"] = branchModel.branchId;
                    break;
                }
            }

            MMallCartCheckModelR *modelR = [MMallCartCheckModelR new];
            modelR.token = QWGLOBALMANAGER.configure.userToken;
            modelR.productsJson = [jsonDict JSONRepresentation];
            NewConfirmOrderViewController *confirmOrderViewController = [[NewConfirmOrderViewController alloc] initWithNibName:@"NewConfirmOrderViewController" bundle:nil];
            confirmOrderViewController.productsJson = modelR.productsJson;
            confirmOrderViewController.chooseList = chooseModelList;
            confirmOrderViewController.branchModel = branch;
            confirmOrderViewController.invariableList = chooseModelList;
            confirmOrderViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:confirmOrderViewController animated:YES];
        }else{
            [self queryShoppingCart:YES];
        }
    }else if (alertView.tag == 1117) {
        [self queryShoppingCart:YES];
    }else if(alertView.tag == 999) {
        if(buttonIndex == 1) {
            [self queryShoppingCart:YES];
        }
    }else if (alertView.tag == 1012) {
        if(buttonIndex == 1) {
            CartBranchVoModel *branchModel = self.shoppingList[_delIndexPath.section];
            branchModel.redemptions = nil;
            [self.tableView reloadData];
            [CartBranchVoModel deleteAllObjFromDB];
            [CartBranchVoModel saveObjToDBWithArray:self.shoppingList];
            [self syncUnreadNum];
            [self calculateTotalPrice];
        }
    }else if (1113 == alertView.tag) {
        CartBranchVoModel *branchModel = self.shoppingList[_delIndexPath.section];
        CartProductVoModel *productModel = branchModel.products[_delIndexPath.row];
        if(buttonIndex == 1) {
            branchModel.redemptions = nil;
            
        }else{
            productModel.quantity++;
        }
        [self reloadNewInformation];
    }else if (1114 == alertView.tag) {
        if(buttonIndex == 1) {
            CartBranchVoModel *branchModel = self.shoppingList[_delIndexPath.section];
            branchModel.redemptions = nil;
            
            
        }else{
            for(CartBranchVoModel *branchVoModel in self.shoppingList) {
                for(CartComboVoModel *comboxModel in branchVoModel.combos) {
                    if([_delProductModel.packageId isEqualToString:comboxModel.packageId]) {
                        comboxModel.quantity++;
                        break;
                    }
                }
            }
        }
        [self reloadNewInformation];
    }else if(1115 == alertView.tag) {
        CartBranchVoModel *branchModel = self.shoppingList[_delIndexPath.section];
        if(buttonIndex == 1) {
            branchModel.redemptions = nil;
        }else{
            CartProductVoModel *productModel = branchModel.products[_delIndexPath.row];
            productModel.choose = YES;
            [self checkChooseAll:branchModel];
        }
        [self calculateShoppingList];
        [self reloadNewInformation];
    }else if (1116 == alertView.tag) {
        CartBranchVoModel *branchModel = self.shoppingList[_delIndexPath.section];
        if(buttonIndex == 1) {
            branchModel.redemptions = nil;
        }else{
            for(CartComboVoModel *comboxModel in branchModel.combos) {
                if([_delProductModel.packageId isEqualToString:comboxModel.packageId]) {
                    comboxModel.choose = YES;
                    break;
                }
            }
            [self checkChooseAll:branchModel];
        }
        [self calculateShoppingList];
        [self reloadNewInformation];

    }else if (1119 == alertView.tag) {
        CartBranchVoModel *branchModel = self.shoppingList[_delIndexPath.section];
        CartProductVoModel *productModel = branchModel.products[_delIndexPath.row];
        if(buttonIndex == 1) {
            branchModel.redemptions = nil;
            CartBranchVoModel *branchModel = self.shoppingList[_delIndexPath.section];
            [branchModel.products removeObjectAtIndex:_delIndexPath.row];
            if((branchModel.products.count + branchModel.combos.count) == 0) {
                [self.shoppingList removeObject:branchModel];
                if(self.shoppingList.count == 0) {
                    [self checkBackGroundStatus];
                }
            }
            [self checkExcludeRedemption:branchModel];
            [self.tableView reloadData];
            if(QWGLOBALMANAGER.loginStatus) {
                [self syncShoppingListOnly];
            }else{
                [CartBranchVoModel deleteAllObjFromDB];
                [CartBranchVoModel saveObjToDBWithArray:self.shoppingList];
                if(self.shoppingList.count == 0) {
                    [self checkBackGroundStatus];
                }
                [self syncUnreadNum];
            }
        }
        [self reloadNewInformation];
    }else if (1200 == alertView.tag) {
        if(buttonIndex == 1) {
            CartBranchVoModel *branchModel = self.shoppingList[_delIndexPath.section];
            branchModel.redemptions = nil;
            for(CartBranchVoModel *branchVoModel in self.shoppingList) {
                for(CartComboVoModel *comboxModel in branchVoModel.combos) {
                    if([_delProductModel.packageId isEqualToString:comboxModel.packageId]) {
                        branchModel = branchVoModel;
                        [branchVoModel.combos removeObject:comboxModel];
                        break;
                    }
                }
            }
            if(branchModel.products.count == 0 && branchModel.combos.count == 0) {
                [self.shoppingList removeObject:branchModel];
                if(self.shoppingList.count == 0) {
                    [self checkBackGroundStatus];
                }
            }
            [self checkExcludeRedemption:branchModel];
            [self.tableView reloadData];
            if(QWGLOBALMANAGER.loginStatus) {
                [self syncShoppingListOnly];
            }else{
                [CartBranchVoModel deleteAllObjFromDB];
                [CartBranchVoModel saveObjToDBWithArray:self.shoppingList];
                if(self.shoppingList.count == 0) {
                    [self checkBackGroundStatus];
                }
                [self syncUnreadNum];
            }
            
        }
        [self reloadNewInformation];
    }else if (1211 == alertView.tag) {
        if(buttonIndex == 1) {
            CartBranchVoModel *model = self.shoppingList[_delIndexPath.section];
            model.redemptions = nil;
            [self calculateShoppingList];
            [self calculateTotalPrice];
            [self.tableView reloadData];
            [CartBranchVoModel deleteAllObjFromDB];
            [CartBranchVoModel saveObjToDBWithArray:self.shoppingList];
            [self syncUnreadNum];
        }
    }else if (alertView.tag == 123) {
        if (buttonIndex == 1) {
            [self _clearShoppingCart];
        }
    }
}

//反选药房,取消全部药房下药品选中状态
- (void)excludeAllProductExpecet:(CartBranchVoModel *)model
{
    for (CartBranchVoModel *branchModel in self.shoppingList) {
        if (![branchModel.branchId isEqualToString:model.branchId])
        {
            branchModel.choose = NO;
            for(CartProductVoModel *productModel in branchModel.products) {
                productModel.choose = NO;
            }
            for(CartComboVoModel *comboVoModel in branchModel.combos) {
                comboVoModel.choose = NO;
            }
            for (CartRedemptionVoModel *redeptionModel in branchModel.redemptions) {
                redeptionModel.choose = NO;
            }
            branchModel.redemptions = nil;
        }
    }
}
//点击换购栏,弹出换购商品列表
- (void)showRedemptionList:(UITapGestureRecognizerExt *)gesture
{
    NSArray *redemptionList = ((CartBranchVoModel *)gesture.obj).availableRedemptions;
    CartRedemptionVoModel *redemptionModel = (((CartBranchVoModel *)gesture.obj).redemptions.count > 0)?((CartBranchVoModel *)gesture.obj).redemptions[0] :nil;
    
    double limitPrice = [self calculatePriceOnly:(CartBranchVoModel *)gesture.obj];
    for(CartRedemptionVoModel *redemptionVoModel in redemptionList) {
        redemptionVoModel.currentConsume = limitPrice;
    }
    NSInteger selectedIndex = -1;
    if(redemptionModel) {
        selectedIndex = [redemptionList indexOfObject:redemptionModel];
    }
    [BranchPromotionView showInView:APPDelegate.window withTitle:@"换购商品" message:@"只可选择一件商品,不支持多个商品换购" list:redemptionList withSelectedIndex:selectedIndex withType:Enum_Change andCallBack:^(NSInteger obj) {
        CartBranchVoModel *branchModel = (CartBranchVoModel *)gesture.obj;
        if(obj == -1) {
            branchModel.redemptions = nil;
        }else{
            CartRedemptionVoModel *redemptionModel = branchModel.availableRedemptions[obj];
            redemptionModel.quantity = 1;
            redemptionModel.choose = YES;
            branchModel.redemptions = [NSMutableArray arrayWithObject:redemptionModel];
        }
        [self calculateTotalPrice];
        [self.tableView reloadData];
        [CartBranchVoModel deleteAllObjFromDB];
        [CartBranchVoModel saveObjToDBWithArray:self.shoppingList];
    }];
}

//购物车没数据时,背景状态处理
- (void)showShoppingCartBackgroundStatus:(ShoppingCartStatus)status
{
    if(status == EmptyShoppingCartStatus && self.shoppingList.count > 0) {
        status = NormalShoppingCartStatus;
    }
    [super showShoppingCartBackgroundStatus:status];
    switch (status) {
        case NormalShoppingCartStatus:
        {
            self.tableView.hidden = NO;
            self.headerHintView.hidden = NO;
            self.footerView.hidden = NO;
            break;
        }
        case EmptyShoppingCartStatus:
        {
            self.tableView.hidden = YES;
            self.headerHintView.hidden = YES;
            self.footerView.hidden = YES;
            break;
        }
        case NotOpenNoReportedStatus:
        {
            self.tableView.hidden = YES;
            self.footerView.hidden = YES;
            self.headerHintView.hidden = YES;
            break;
        }
        case NotOpenReportedStatus:
        {
            self.tableView.hidden = YES;
            self.footerView.hidden = YES;
            self.headerHintView.hidden = YES;
            break;
        }
        default:
            break;
    }
}


//点击药房,选中当前药房下所有药品
- (void)chooseBranchAllProduct:(QWButton *)button
{
    CartBranchVoModel *model = (CartBranchVoModel *)button.obj;
    if(model.choose) {
        model.choose = NO;
        for(CartProductVoModel *carProductModel in model.products) {
            carProductModel.choose = NO;
        }
        for(CartComboVoModel *comboVoModel in model.combos) {
            comboVoModel.choose = NO;
        }
        model.redemptions = nil;
        
    }else{
        model.choose = YES;
        for(CartProductVoModel *carProductModel in model.products) {
            carProductModel.choose = YES;
        }
        for(CartComboVoModel *comboVoModel in model.combos) {
            comboVoModel.choose = YES;
        }
        for (CartRedemptionVoModel *redeptionModel in model.redemptions) {
            redeptionModel.choose = YES;
        }
        [self excludeAllProductExpecet:model];
    }
    [self.tableView reloadData];
    [self calculateShoppingList];
    [self calculateTotalPrice];
    [CartBranchVoModel deleteAllObjFromDB];
    [CartBranchVoModel saveObjToDBWithArray:self.shoppingList];
    
}

//选中单个商品,反选其他药房药品选中状态,并存入本地
- (void)chooseSingleProduct:(QWButton *)button
{
    CartBranchVoModel *model = (CartBranchVoModel *)button.obj;
    id unkonwnModel = model.products[button.tag];
    CartProductVoModel *productModel = unkonwnModel;
    if(productModel.choose) {
        productModel.choose = NO;
        model.choose = NO;
        
    }else{
        productModel.choose = YES;
        [self checkChooseAll:model];
        [self excludeAllProductExpecet:model];
    }
    if(model.redemptions.count > 0) {
        double price = [self calculatePriceOnly:model];
        CartRedemptionVoModel *redemptionModel = model.redemptions[0];
        if(price < redemptionModel.limitPrice) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"合计金额小于%.2f元,确定要放弃换购活动吗?",redemptionModel.limitPrice] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            _delIndexPath = [NSIndexPath indexPathForRow:button.tag inSection:[self.shoppingList indexOfObject:model]];
            
            alertView.tag = 1115;
            [alertView show];
        }else{
            
            [self calculateShoppingList];
            [self calculateTotalPrice];
            [self.tableView reloadData];
        }
    }else{
        
        [self calculateShoppingList];
        [self calculateTotalPrice];
        [self.tableView reloadData];
    }
    [self updateQuantityOnly];
    [self updateChooseStatus];
    [CartBranchVoModel deleteAllObjFromDB];
    [CartBranchVoModel saveObjToDBWithArray:self.shoppingList];
}
//选中单个套餐
- (void)chooseSingleCombos:(QWButton *)button
{
    ComboProductVoModel *productModel = (ComboProductVoModel *)button.obj;
    CartBranchVoModel *model = nil;
    for(CartBranchVoModel *branchVoModel in self.shoppingList) {
        for(CartComboVoModel *comboxModel in branchVoModel.combos) {
            if([productModel.packageId isEqualToString:comboxModel.packageId]) {
                model = branchVoModel;
                if(productModel.choose) {
                    comboxModel.choose = NO;
                    branchVoModel.choose = NO;
                }else{
                    comboxModel.choose = YES;
                    [self checkChooseAll:branchVoModel];
                    [self excludeAllProductExpecet:branchVoModel];
                }
                break;
            }
        }
    }
    if(model.redemptions.count > 0) {
        double price = [self calculatePriceOnly:model];
        CartRedemptionVoModel *redemptionModel = model.redemptions[0];
        if(price < redemptionModel.limitPrice) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"合计金额小于%.2f元,确定要放弃换购活动吗?",redemptionModel.limitPrice] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            _delIndexPath = [NSIndexPath indexPathForRow:button.tag inSection:[self.shoppingList indexOfObject:model]];
            _delProductModel = productModel;
            alertView.tag = 1116;
            [alertView show];
        }else{
            [self calculateShoppingList];
            [self calculateTotalPrice];
            [self.tableView reloadData];
        }
    }else{
        [self calculateShoppingList];
        [self calculateTotalPrice];
        [self.tableView reloadData];
    }
    [CartBranchVoModel deleteAllObjFromDB];
    [CartBranchVoModel saveObjToDBWithArray:self.shoppingList];
    [self updateQuantityOnly];
    [self updateChooseStatus];
}
//计算整个购物车商品的数量和选中状态
- (void)calculateShoppingList
{
    [_chooseList removeAllObjects];
    [_chooseStatus removeAllObjects];
    [ChooseStatusModel deleteAllObjFromDB];
    for(CartBranchVoModel *model in self.shoppingList) {
        for(CartProductVoModel *productModel in model.products) {
            if(productModel.choose) {
                [_chooseList addObject:productModel];
                ChooseStatusModel *statusModel = [ChooseStatusModel new];
                statusModel.quanity = productModel.quantity;
                statusModel.objId = productModel.id;
                statusModel.choose = productModel.choose;
                [_chooseStatus addObject:statusModel];
            }
        }
        for(CartComboVoModel *comboVoModel in model.combos) {
            if(comboVoModel.choose) {
                [_chooseList addObject:comboVoModel];
                ChooseStatusModel *statusModel = [ChooseStatusModel new];
                statusModel.quanity = comboVoModel.quantity;
                statusModel.objId = comboVoModel.packageId;
                statusModel.choose = comboVoModel.choose;
                [_chooseStatus addObject:statusModel];
            }
        }
        for(CartRedemptionVoModel *redemptionVoModel in model.redemptions) {
            if(redemptionVoModel.choose) {
                [_chooseList addObject:redemptionVoModel];
                ChooseStatusModel *statusModel = [ChooseStatusModel new];
                statusModel.quanity = redemptionVoModel.quantity;
                statusModel.objId = redemptionVoModel.actId;
                statusModel.choose = redemptionVoModel.choose;
                [_chooseStatus addObject:statusModel];
            }
        }
    }
    [ChooseStatusModel saveObjToDBWithArray:_chooseStatus];
}

- (void)updateQuantityOnly
{
    for(CartBranchVoModel *model in self.shoppingList) {
        for(CartProductVoModel *productModel in model.products) {

            ChooseStatusModel *statusModel = [ChooseStatusModel getObjFromDBWithWhere:[NSString stringWithFormat:@"objId = '%@'",productModel.id]];
            if(statusModel) {
                statusModel.quanity = productModel.quantity;
                [statusModel updateToDB];
            }
        }
        for(CartComboVoModel *comboVoModel in model.combos) {
            ChooseStatusModel *statusModel = [ChooseStatusModel getObjFromDBWithWhere:[NSString stringWithFormat:@"objId = %@",comboVoModel.packageId]];
            if(statusModel) {
                statusModel.quanity = comboVoModel.quantity;
                [statusModel updateToDB];
            }
        }
//        for(CartRedemptionVoModel *redemptionVoModel in model.redemptions) {
//            ChooseStatusModel *statusModel = [ChooseStatusModel getObjFromDBWithWhere:[NSString stringWithFormat:@"objId = %@",redemptionVoModel.actId]];
//            if(statusModel) {
//                statusModel.quanity = redemptionVoModel.quantity;
//                [statusModel updateToDB];
//            }
//        }
    }
    _chooseStatus = [ChooseStatusModel getArrayFromDBWithWhere:nil];
}

- (void)updateChooseStatus
{
    for(CartBranchVoModel *model in self.shoppingList) {
        for(CartProductVoModel *productModel in model.products) {
            
            ChooseStatusModel *statusModel = [ChooseStatusModel getObjFromDBWithWhere:[NSString stringWithFormat:@"objId = '%@'",productModel.id]];
            if(statusModel) {
                statusModel.choose = productModel.choose;
                [statusModel updateToDB];
            }
        }
        for(CartComboVoModel *comboVoModel in model.combos) {
            ChooseStatusModel *statusModel = [ChooseStatusModel getObjFromDBWithWhere:[NSString stringWithFormat:@"objId = %@",comboVoModel.packageId]];
            if(statusModel) {
                statusModel.choose = comboVoModel.choose;
                [statusModel updateToDB];
            }
        }
    }
    _chooseStatus = [ChooseStatusModel getArrayFromDBWithWhere:nil];
}


//计算总价
- (double)calculateTotalPrice
{
    double minusPrice = 0;
    double totalPrice = [self calculateTotalPrice:&minusPrice];
    _totalPrice.text = [NSString stringWithFormat:@"%.2f",totalPrice];
    _minusPriceLabel.text = [NSString stringWithFormat:@"￥%.2f",minusPrice];
    return totalPrice;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView)
    {
        CGFloat sectionHeaderHeight = 46.0;
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
    [super scrollViewDidScroll:scrollView];
    [self.view endEditing:YES];
    
}



#pragma mark -
#pragma mark MGSwipeTableCellDelegate
-(NSArray*) swipeTableCell:(MGSwipeTableCell*)cell
  swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*)swipeSettings
         expansionSettings:(MGSwipeExpansionSettings*)expansionSettings;
{
    if (direction == MGSwipeDirectionRightToLeft)
    {
        return [self createRightButtons:1];
    }
    return nil;
}

-(BOOL)swipeTableCell:(MGSwipeTableCell*)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    UIAlertView *alertView = nil;
    if([cell isKindOfClass:[ShoppingCartTableViewCell class]]) {
        CartBranchVoModel *branchModel = self.shoppingList[indexPath.section];
        if(branchModel.redemptions.count > 0){
            CartProductVoModel *productModel = branchModel.products[indexPath.row];
            BOOL oroginalStatus = productModel.choose;
            productModel.choose = NO;
            double price = [self calculatePriceOnly:branchModel];
            productModel.choose = oroginalStatus;
            CartRedemptionVoModel *redemption = branchModel.redemptions[0];
            if(price < redemption.limitPrice) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"删除商品后合计金额小于%.2f元,确定要放弃换购活动吗?",redemption.limitPrice] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
                alertView.tag = 666;
                _delIndexPath = indexPath;
                [alertView show];
            }else{
                alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确认要删除此商品吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
                alertView.tag = 666;
                _delIndexPath = indexPath;
            }
        }else{
            alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确认要删除此商品吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
            alertView.tag = 666;
            _delIndexPath = indexPath;
        }
    }else if ([cell isKindOfClass:[RedemptionCartTableViewCell class]]) {
        alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确认要删除此商品吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
        alertView.tag = 1012;
        _delIndexPath = indexPath;
    }else{
        CartBranchVoModel *branchModel = self.shoppingList[indexPath.section];
        if(branchModel.redemptions.count > 0){
            ComboProductVoModel *comboProduct = (ComboProductVoModel *)[(CombosBottomCartTableViewCell *)cell obj];
            CartComboVoModel *selectedComboVoModel = nil;
            for(CartComboVoModel *comboVoModel in branchModel.combos) {
                if([comboProduct.packageId isEqualToString:comboVoModel.packageId]) {
                    selectedComboVoModel = comboVoModel;
                    break;
                }
            }
            BOOL oroginalStatus = selectedComboVoModel.choose;
            selectedComboVoModel.choose = NO;
            double price = [self calculatePriceOnly:branchModel];
            selectedComboVoModel.choose = oroginalStatus;
            CartRedemptionVoModel *redemption = branchModel.redemptions[0];
            if(price < redemption.limitPrice) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"删除商品后合计金额小于%.2f元,确定要放弃换购活动吗?",redemption.limitPrice] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
                alertView.tag = 777;
                _delProductModel = [(CombosBottomCartTableViewCell *)cell obj];
                [alertView show];
            }else{
                alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确认要删除此套餐吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
                alertView.tag = 777;
                _delProductModel = [(CombosBottomCartTableViewCell *)cell obj];
            }
            
        }else{
            alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确认要删除此套餐吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
            alertView.tag = 777;
            _delProductModel = [(CombosBottomCartTableViewCell *)cell obj];
        }
    }
    [alertView show];
    return YES;
}

- (void)getNotifType:(Enum_Notification_Type)type data:(id)data target:(id)obj
{
    if(type == NotifLoginSuccess) {
        //登录成功刷新数据
        [self queryShoppingCart:NO];
    }else if (type == NotifShoppingCartSync) {
        //同步购物车数据,分为登录前和登陆后
        CartBranchVoModel *bracnhVomodel = (CartBranchVoModel *)data;
        CartBranchVoModel *chooseBranchModel = nil;
        if(QWGLOBALMANAGER.loginStatus) {
            //登录后,直接把当前药品同步到服务器
            [self syncSingleCart:bracnhVomodel];
        }else{
            //登录前,保存到本地,登录成功后,同步到该账号
            CartProductVoModel *productModel = nil;
            CartComboVoModel   *comboVoModel = nil;
            if(bracnhVomodel.products.count > 0) {
                productModel = bracnhVomodel.products[0];
            }else if (bracnhVomodel.combos.count > 0) {
                comboVoModel = bracnhVomodel.combos[0];
                
            }
            NSMutableArray *array = [CartBranchVoModel getArrayFromDBWithWhere:nil WithorderBy:@"timestamp desc"];
            BOOL existed = NO;
            
            for(CartBranchVoModel *branchModel in array) {
                if([branchModel.branchId isEqualToString:bracnhVomodel.branchId]) {
                    chooseBranchModel = branchModel;
                    if(!branchModel.combos)
                        branchModel.combos = [NSMutableArray array];
                    if(!branchModel.products)
                        branchModel.products = [NSMutableArray array];
                    if(!branchModel.redemptions)
                        branchModel.redemptions = [NSMutableArray array];

                    BOOL sameProduct = NO;
                    [array removeObject:branchModel];
                    existed = YES;
                    if(productModel) {
                        for(CartProductVoModel *subProductModel in branchModel.products) {
                            if([subProductModel.id isEqualToString:productModel.id]) {
                                productModel.quantity = subProductModel.quantity + 1;
                                productModel.sync = NO;
                                productModel.choose = YES;
                                [branchModel.products removeObject:subProductModel];
                                [branchModel.products insertObject:productModel atIndex:0];
                                sameProduct = YES;
                                break;
                            }
                        }
                        
                        branchModel.timeStamp = bracnhVomodel.timeStamp;
                        if(!sameProduct) {
                            [branchModel.products insertObject:productModel atIndex:0];
                        }
                    }
                    if(comboVoModel) {
                        for(CartComboVoModel *subProductModel in branchModel.combos) {
                            if([subProductModel.packageId isEqualToString:comboVoModel.packageId]) {
                                comboVoModel.quantity = subProductModel.quantity + 1;
                                comboVoModel.choose = YES;
                                [branchModel.combos removeObject:subProductModel];
                                [branchModel.combos insertObject:comboVoModel atIndex:0];
                                sameProduct = YES;
                                break;
                            }
                        }
                        
                        branchModel.timeStamp = bracnhVomodel.timeStamp;
                        if(!sameProduct) {
                            [branchModel.combos insertObject:comboVoModel atIndex:0];
                        }
                    }
                    break;
                }
            }
            if(!existed) {
                
                [array insertObject:bracnhVomodel atIndex:0];
            }else{
                [array insertObject:chooseBranchModel atIndex:0];
            }
            
            [CartBranchVoModel deleteAllObjFromDB];
            [CartBranchVoModel saveObjToDBWithArray:array];
            [self.shoppingList removeAllObjects];
            if(array.count > 0) {
                [self showShoppingCartBackgroundStatus:NormalShoppingCartStatus];
                [self.shoppingList addObjectsFromArray:array];
                
            }else{
                [self checkBackGroundStatus];
            }
            if(chooseBranchModel == nil) {
                chooseBranchModel = bracnhVomodel;
            }
            [self checkChooseAll:chooseBranchModel];
            [self excludeAllProductExpecet:chooseBranchModel];
            [self calculateShoppingList];
            [self calculateTotalPrice];
            [self queryOffLineBranchInfo];
            [QWGLOBALMANAGER postNotif:NotifShoppingSyncAll data:nil object:nil];
        }
        
        [self.tableView reloadData];
        [self syncUnreadNum];
    }else if (type == NotifQuitOut || type == NotifKickOff) {
        [self clearShoppingCart];
    }else if(type == NotifShoppingCartShouldClear) {
        //结算成功后,需要将该药品列表移除购物车
        NSArray *chooseList = (NSArray *)data;
        CartBranchVoModel *buyBranchModel = (CartBranchVoModel *)obj;
        for(NSInteger index = 0; index < self.shoppingList.count; ++index) {
            CartBranchVoModel *branchModel = self.shoppingList[index];
            if([branchModel.branchId isEqualToString:buyBranchModel.branchId]) {
                
                for (id unKonwnModel in chooseList) {
                    if([unKonwnModel isKindOfClass:[CartProductVoModel class]]) {
                        for(CartProductVoModel *innerModel in branchModel.products) {
                            if([innerModel.id isEqualToString:((CartProductVoModel *)unKonwnModel).id]) {
                                [branchModel.products removeObject:innerModel];
                                break;
                            }
                        }
                        
                    }else if ([unKonwnModel isKindOfClass:[CartComboVoModel class]]) {
                        for(CartComboVoModel *innerModel in branchModel.combos) {
                            if([innerModel.packageId isEqualToString:((CartComboVoModel *)unKonwnModel).packageId]) {
                                [branchModel.combos removeObject:innerModel];
                                break;
                            }
                        }
                    }else if ([unKonwnModel isKindOfClass:[CartRedemptionVoModel class]]) {
                        branchModel.redemptions = nil;
                    }
                }
                [self checkExcludeRedemption:branchModel];
                if(branchModel.combos.count + branchModel.products.count == 0) {
                    [self.shoppingList removeObject:branchModel];
                }
                break;
            }
        }
        [CartBranchVoModel deleteAllObjFromDB];
        [CartBranchVoModel saveObjToDBWithArray:self.shoppingList];
        [self syncShoppingListOnly];
        [self calculateTotalPrice];
        [QWGLOBALMANAGER postNotif:NotifShoppingSyncAll data:nil object:nil];
    }else if (type == NotifNetworkDisconnectWhenStart) {
        NSArray *array = [CartBranchVoModel getArrayFromDBWithWhere:nil WithorderBy:@"timestamp desc"];
        if(array.count > 0) {
            [self showShoppingCartBackgroundStatus:NormalShoppingCartStatus];
            [self.shoppingList removeAllObjects];
            [self.shoppingList addObjectsFromArray:array];
            [self syncUnreadNum];
        }else{
            [self checkBackGroundStatus];
        }
    }else if (type == NotifShoppingCartUpdateEveryTime) {

        BOOL result = [_recursiveLock tryLock];
        if(result) {
            [self syncShoppingListOnly];
        }else{
            DebugLog(@"!!!!!!!!!!!!!!!已经锁住了 不能同步!!!!!!!!!!!!!!!! -----%hhd",result);
        }
    }else if (type == NotifUpdateUnreadNum) {
        [self syncUnreadNum];
    }else if (type == NotifShoppingCartDelete) {
        _chooseStatus = [ChooseStatusModel getArrayFromDBWithWhere:nil];
        NSArray *array = [CartBranchVoModel getArrayFromDBWithWhere:nil WithorderBy:@"timestamp desc"];
        [self.shoppingList removeAllObjects];
        [self.shoppingList addObjectsFromArray:array];
        [self syncUnreadNum];
        [self calculateTotalPrice];
        [self.tableView reloadData];
    }else if (type == NotifShoppingCartForcedClear) {
        [self.shoppingList removeAllObjects];
        [CartBranchVoModel deleteAllObjFromDB];
        [self syncUnreadNum];
        [self calculateTotalPrice];
        [self.tableView reloadData];
    }
}

- (void)clearShoppingCart
{
    [CartBranchVoModel deleteAllObjFromDB];
    [self.shoppingList removeAllObjects];
    [self.tableView reloadData];
    self.totalPrice.text = @"0.00";
    self.minusPriceLabel.text = @"￥0.00";
    self.navigationController.tabBarItem.badgeValue = nil;
    [self showShoppingCartBackgroundStatus:EmptyShoppingCartStatus];
}

//清空操作
- (void)_clearShoppingCart
{
    [CartBranchVoModel deleteAllObjFromDB];
    [ChooseStatusModel deleteAllObjFromDB];
    
    [self.shoppingList removeAllObjects];
    [self.tableView reloadData];
    self.totalPrice.text = @"0.00";
    self.minusPriceLabel.text = @"￥0.00";
    self.navigationController.tabBarItem.badgeValue = nil;
    [self syncShoppingListOnly];
    [QWGLOBALMANAGER postNotif:NotifShoppingCartDelete data:nil object:nil];
    [self showShoppingCartBackgroundStatus:EmptyShoppingCartStatus];
}


- (void)checkExcludeRedemption:(CartBranchVoModel *)branchModel
{
    if(branchModel.redemptions.count > 0) {
        double price = [self calculatePriceOnly:branchModel];
        CartRedemptionVoModel *redemption = branchModel.redemptions[0];
        if(price < redemption.limitPrice) {
            branchModel.redemptions = nil;
        }
    }
}

//将本地购物车数据,全量同步至服务器
- (void)syncShoppingListOnly
{
    NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity:10];
    [self jointProductModel:self.shoppingList addArray:jsonArray];
    MMallCartSyncModelR *modelR = [MMallCartSyncModelR new];
    modelR.token = QWGLOBALMANAGER.configure.userToken;
    if(modelR.token.length == 0)
        return;
    NSDictionary *jsonDict = @{@"items":jsonArray};
    modelR.proJson = [jsonDict JSONRepresentation];
    [MallCart queryMallCartNewSync:modelR success:^(CartVoModel *responseModel) {
        [CartBranchVoModel deleteAllObjFromDB];
        [self.shoppingList removeAllObjects];
        //如果有数据 同步 add by jxb 3.0.0
        if(responseModel.branchs.count > 0) {
            [self showShoppingCartBackgroundStatus:NormalShoppingCartStatus];
            [self.shoppingList addObjectsFromArray:responseModel.branchs];
            
        }else{
            //如果没有数据 显示购物车状态 add by jxb 3.0.0
            [self checkBackGroundStatus];
        }
        [self updateQuantityOnly];
        _chooseStatus = [ChooseStatusModel getArrayFromDBWithWhere:nil];
        self.totalPrice.text = @"0.00";
        self.minusPriceLabel.text = @"￥0.00";
        [self recoverModelStatusFromDB];
        [self.tableView reloadData];
        [self syncOnlineShoppingCart];
        [_recursiveLock unlock];
    } failure:^(HttpException *e) {
        //异常情况 显示购物车状态 add by jxb 3.0.0
        [self checkBackGroundStatus];
        [_recursiveLock unlock];
    }];
    [self syncUnreadNum];
}

//同步指定的某一家药房下的要药品至服务器
- (void)syncSingleCart:(CartBranchVoModel *)branchModel
{
    NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity:10];
    CartProductVoModel *productModel = nil;
    CartComboVoModel *comboVoModel = nil;
    for(CartProductVoModel *subProductModel in branchModel.products)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"quantity"] = [NSNumber numberWithInteger:subProductModel.quantity];
        dict[@"objId"] = subProductModel.id;
        dict[@"objType"] = [NSNumber numberWithInt:1];
        [jsonArray addObject:dict];
        productModel = subProductModel;
    }
    
    for (CartComboVoModel *subComboVoModel in branchModel.combos) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"quantity"] = [NSNumber numberWithInt:subComboVoModel.quantity];
        dict[@"objId"] = subComboVoModel.packageId;
        dict[@"objType"] = [NSNumber numberWithInt:2];
        [jsonArray addObject:dict];
        comboVoModel = subComboVoModel;
    }
    [self jointProductModel:self.shoppingList addArray:jsonArray];
    MMallCartSyncModelR *modelR = [MMallCartSyncModelR new];
    modelR.token = QWGLOBALMANAGER.configure.userToken;
    NSDictionary *jsonDict = @{@"items":jsonArray};
    modelR.proJson = [jsonDict JSONRepresentation];
    [MallCart queryMallCartNewSync:modelR success:^(CartVoModel *responseModel) {
        [CartBranchVoModel deleteAllObjFromDB];
        [self.shoppingList removeAllObjects];
        if(responseModel.branchs.count > 0) {
            [self showShoppingCartBackgroundStatus:NormalShoppingCartStatus];
            [self.shoppingList addObjectsFromArray:responseModel.branchs];
            
        }else{
            [self checkBackGroundStatus];
        }
        
        for(CartBranchVoModel *branchModel in self.shoppingList) {
            //同步选中状态以及数量:TODO 待完成
            for(CartProductVoModel *productModel in branchModel.products)
            {
                for(ChooseStatusModel *statusModel in _chooseStatus) {
                    if([productModel.id isEqualToString:statusModel.objId]) {
                        productModel.choose = statusModel.choose;
                    }
                }
            }
            for(CartComboVoModel *comboVoModel in branchModel.combos) {
                for(ChooseStatusModel *statusModel in _chooseStatus) {
                    if([comboVoModel.packageId isEqualToString:statusModel.objId]) {
                        comboVoModel.choose = statusModel.choose;
                    }
                }
            }
            
            for(CartRedemptionVoModel *redemption in branchModel.availableRedemptions) {
                for(ChooseStatusModel *statusModel in _chooseStatus) {
                    if([redemption.actId isEqualToString:statusModel.objId]) {
                        double price = [self calculatePriceOnly:branchModel];
                        if(price >= redemption.limitPrice) {
                            redemption.choose = statusModel.choose;
                            branchModel.redemptions = [NSMutableArray arrayWithObject:redemption];
                        }
                        break;
                    }
                }
            }
            [self checkChooseAll:branchModel];
        }
        
        [self calculateTotalPrice];
        
        CartBranchVoModel *chooseBranchModel = nil;
        for(CartBranchVoModel *subBranchModel in responseModel.branchs)
        {
            if(productModel) {
                for(CartProductVoModel *subProductModel in subBranchModel.products) {
                    if([productModel.id isEqualToString:subProductModel.id]) {
                        subProductModel.choose = YES;
                        chooseBranchModel = subBranchModel;
                    }
                }
            }
            if(comboVoModel) {
                for(CartComboVoModel *subComboVoMdeol in subBranchModel.combos) {
                    if([comboVoModel.packageId isEqualToString:subComboVoMdeol.packageId]) {
                        subComboVoMdeol.choose = YES;
                        chooseBranchModel = subBranchModel;
                    }
                }
            }
        }
        [self checkChooseAll:chooseBranchModel];
        [self excludeAllProductExpecet:chooseBranchModel];
        [self calculateShoppingList];
        [self syncOnlineShoppingCart];
        [QWGLOBALMANAGER postNotif:NotifShoppingSyncAll data:nil object:nil];
        [self.tableView reloadData];
    } failure:NULL];
    
}

//仅同步本地缓存至服务器
- (void)syncShoppingCart
{
    NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity:10];
    [self jointProductModel:self.shoppingList addArray:jsonArray];
    MMallCartSyncModelR *modelR = [MMallCartSyncModelR new];
    modelR.token = QWGLOBALMANAGER.configure.userToken;
    NSDictionary *jsonDict = @{@"items":jsonArray};
    modelR.proJson = [jsonDict JSONRepresentation];
    [MallCart queryMallCartNewSync:modelR success:^(CartVoModel *responseModel) {
        [CartBranchVoModel deleteAllObjFromDB];
        [self.shoppingList removeAllObjects];
        if(responseModel.branchs.count > 0) {
            [self showShoppingCartBackgroundStatus:NormalShoppingCartStatus];
            [self.shoppingList addObjectsFromArray:responseModel.branchs];
            [self updateQuantityOnly];
        }else{
            [self checkBackGroundStatus];
        }
        _chooseStatus = [ChooseStatusModel getArrayFromDBWithWhere:nil];
        [self syncOnlineShoppingCart];
        [self recoverModelStatusFromDB];
        [QWGLOBALMANAGER postNotif:NotifShoppingSyncAll data:nil object:nil];
        [self.tableView reloadData];
    } failure:NULL];
}

//数量加1 按钮
- (void)increaseProductNum:(QWButton *)button
{
    [QWGLOBALMANAGER statisticsEventId:@"x_gwc_jj" withLable:@"购物车-加减商品" withParams:nil];
    id unknowModel = button.obj;
    if([unknowModel isKindOfClass:[CartBranchVoModel class]]) {
        CartBranchVoModel *model = (CartBranchVoModel *)unknowModel;
        CartProductVoModel *productModel = model.products[button.tag];
        NSInteger max = 99;
        if (productModel.quantity == max) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"最多只能买%ld件哦！",(long)max]];
        }else {
            productModel.quantity++;
        }
    }else{
        ComboProductVoModel *model = (ComboProductVoModel *)unknowModel;
        if (model.quantity == 99) {
            [SVProgressHUD showErrorWithStatus:@"最多只能买99件哦！"];
        }else {
            model.quantity++;
        }
        for(CartBranchVoModel *branchVoModel in self.shoppingList) {
            for(CartComboVoModel *comboxModel in branchVoModel.combos) {
                if([model.packageId isEqualToString:comboxModel.packageId]) {
                    comboxModel.quantity = model.quantity;
                    break;
                }
            }
        }
    }
    [self reloadNewInformation];
}

//数量减1 按钮 
- (void)decreaseProductNum:(QWButton *)button
{
    [QWGLOBALMANAGER statisticsEventId:@"x_gwc_jj" withLable:@"购物车-加减商品" withParams:nil];
    id unknowModel = button.obj;
    if([unknowModel isKindOfClass:[CartBranchVoModel class]]) {
        CartBranchVoModel *model = (CartBranchVoModel *)unknowModel;
        CartProductVoModel *productModel = model.products[button.tag];
        if(--productModel.quantity <= 0) {
            if(productModel.quantity <= 0) {
                productModel.quantity = 1;
            }
            if(model.redemptions.count > 0){
                BOOL originStatus = productModel.choose;
                productModel.choose = NO;
                double price = [self calculatePriceOnly:model];
                productModel.choose = originStatus;
                CartRedemptionVoModel *redemption = model.redemptions[0];
                if(price < redemption.limitPrice) {
                    [self showDifferentAlertView:[NSString stringWithFormat:@"合计金额小于%.2f元,确定要放弃换购活动吗?",redemption.limitPrice] cancelButton:@"取消" confirmButton:@"确定" alertTag:1119];
                }else{
                    [self showDifferentAlertView:@"确认要删除此商品吗？" cancelButton:@"取消" confirmButton:@"删除" alertTag:666];
                }
            }else{
                [self showDifferentAlertView:@"确认要删除此商品吗？" cancelButton:@"取消" confirmButton:@"删除" alertTag:666];
            }
            _delIndexPath = [NSIndexPath indexPathForRow:button.tag inSection:[self.shoppingList indexOfObject:model]];
        }else if(model.redemptions.count > 0){
            double price = [self calculatePriceOnly:model];
            CartRedemptionVoModel *redemption = model.redemptions[0];
            if(price < redemption.limitPrice) {
                [self showDifferentAlertView:[NSString stringWithFormat:@"合计金额小于%.2f元,确定要放弃换购活动吗?",redemption.limitPrice] cancelButton:@"取消" confirmButton:@"确定" alertTag:1113];
                _delIndexPath = [NSIndexPath indexPathForRow:button.tag inSection:[self.shoppingList indexOfObject:model]];
            }else{
                [self calculateTotalPrice];
                [self reloadNewInformation];
            }
        }else{
            [self calculateTotalPrice];
            [self reloadNewInformation];
        }
        
    }else{
        ComboProductVoModel *model = (ComboProductVoModel *)unknowModel;
        CartBranchVoModel *branchModel = nil;
        for(CartBranchVoModel *branchVoModel in self.shoppingList) {
            for(CartComboVoModel *comboxModel in branchVoModel.combos) {
                if([model.packageId isEqualToString:comboxModel.packageId]) {
                    branchModel = branchVoModel;
                    break;
                }
            }
        }
        if(--model.quantity <= 0) {
            if(model.quantity <= 0) {
                model.quantity = 1;
            }
            CartComboVoModel *comboVoModel = nil;
            if (branchModel.redemptions.count > 0) {
                for(CartBranchVoModel *branchVoModel in self.shoppingList) {
                    for(CartComboVoModel *comboxModel in branchVoModel.combos) {
                        if([model.packageId isEqualToString:comboxModel.packageId]) {
                            comboxModel.quantity = model.quantity;
                            comboVoModel = comboxModel;
                        }
                    }
                }
                BOOL originStatus = comboVoModel.choose;
                comboVoModel.choose = NO;
                double price = [self calculatePriceOnly:branchModel];
                comboVoModel.choose = originStatus;
                CartRedemptionVoModel *redemption = branchModel.redemptions[0];
                if(price < redemption.limitPrice) {
                    
                    [self showDifferentAlertView:[NSString stringWithFormat:@"合计金额小于%.2f元,确定要放弃换购活动吗?",redemption.limitPrice] cancelButton:@"取消" confirmButton:@"确定" alertTag:1200];
                    _delProductModel = model;
                    _delIndexPath = [NSIndexPath indexPathForRow:button.tag inSection:[self.shoppingList indexOfObject:branchModel]];
                }else{
                    [self showDifferentAlertView:@"确认要删除此套餐吗？" cancelButton:@"取消" confirmButton:@"删除" alertTag:777];
                    _delProductModel = model;
                }
            }else{
                [self showDifferentAlertView:@"确认要删除此套餐吗？" cancelButton:@"取消" confirmButton:@"删除" alertTag:777];
                _delProductModel = model;
            }
        }else if (branchModel.redemptions.count > 0) {
            for(CartBranchVoModel *branchVoModel in self.shoppingList) {
                for(CartComboVoModel *comboxModel in branchVoModel.combos) {
                    if([model.packageId isEqualToString:comboxModel.packageId]) {
                        comboxModel.quantity = model.quantity;
                    }
                }
            }
            double price = [self calculatePriceOnly:branchModel];
            CartRedemptionVoModel *redemption = branchModel.redemptions[0];
            if(price < redemption.limitPrice) {
                [self showDifferentAlertView:[NSString stringWithFormat:@"合计金额小于%.2f元,确定要放弃换购活动吗?",redemption.limitPrice] cancelButton:@"取消" confirmButton:@"确定" alertTag:1114];
                _delProductModel = model;
                _delIndexPath = [NSIndexPath indexPathForRow:button.tag inSection:[self.shoppingList indexOfObject:branchModel]];
            }else{
                [self reloadNewInformation];
            }
        }else{
            for(CartBranchVoModel *branchVoModel in self.shoppingList) {
                for(CartComboVoModel *comboxModel in branchVoModel.combos) {
                    if([model.packageId isEqualToString:comboxModel.packageId]) {
                        comboxModel.quantity = model.quantity;
                    }
                }
            }
            [self reloadNewInformation];
        }
    }
}

- (void)showDifferentAlertView:(NSString *)alertMsg
                  cancelButton:(NSString *)cancelButton
                 confirmButton:(NSString *)confirmButton
                      alertTag:(NSInteger)tag
{
    UIAlertView *alertView = nil;
    if(confirmButton) {
        alertView = [[UIAlertView alloc] initWithTitle:nil message:alertMsg delegate:self cancelButtonTitle:cancelButton otherButtonTitles:confirmButton,nil];
    }else{
        alertView = [[UIAlertView alloc] initWithTitle:nil message:alertMsg delegate:self cancelButtonTitle:cancelButton otherButtonTitles: nil];
    }
    alertView.tag = tag;
    [alertView show];
}

- (void)reloadNewInformation
{
    [self.tableView reloadData];
    [CartBranchVoModel deleteAllObjFromDB];
    [CartBranchVoModel saveObjToDBWithArray:self.shoppingList];
    [self calculateTotalPrice];
    [self calculateShoppingList];
    [self syncUnreadNum];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//根据textfield的位置，滑动view，以免键盘盖住当前cell
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    inputNumber = textField.text;
    NSInteger section = textField.tag / 1000;
    NSInteger row = textField.tag % 1000;
    NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    CGRect rect = [win convertRect:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height) fromView:cell];
    DebugLog(@"-----------%f",rect.origin.y);

    CGFloat offset = APP_H - 260 - 50 - rect.origin.y - rect.size.height;
    DebugLog(@"-_______--%f",offset);
    if (offset <= 0) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.view.frame;
            DebugLog(@"-----________-----%f",frame.origin.y);
            frame.origin.y += offset;
            self.view.frame = frame;
        }];
    }
    return YES;
}


-(void)inputProNum:(UITextField *)textField {
    inputNumber = textField.text;
    DebugLog(@"-------inputNumber ------%@",inputNumber);
}

-(void)confirmEdit:(QWButton *)sender {
    [self.view endEditing:YES];
    NSUInteger number = 0;
    if (StrIsEmpty(inputNumber) || inputNumber.integerValue == 0) {
        number = 1;
        [SVProgressHUD showErrorWithStatus:@"最少要买1件哦！"];
    }else {
        number = inputNumber.integerValue;
    }
    
    id unknowModel = sender.obj;
    if([unknowModel isKindOfClass:[CartBranchVoModel class]]) {
        CartBranchVoModel *model = (CartBranchVoModel *)unknowModel;
        CartProductVoModel *productModel = model.products[sender.tag];
        if (number <= 99) {
            productModel.quantity = number;
        }else {
            productModel.quantity = 99;
            [SVProgressHUD showErrorWithStatus:@"最多只能买99件哦！"];
        }
    }else{
        ComboProductVoModel *model = (ComboProductVoModel *)unknowModel;
        if (number > 100) {
            model.quantity = 99;
            [SVProgressHUD showErrorWithStatus:@"最多只能买99件哦！"];
        }else {
            model.quantity = number;
        }
        for(CartBranchVoModel *branchVoModel in self.shoppingList) {
            for(CartComboVoModel *comboxModel in branchVoModel.combos) {
                if([model.packageId isEqualToString:comboxModel.packageId]) {
                    comboxModel.quantity = model.quantity;
                    break;
                }
            }
        }
    }
    [self reloadNewInformation];
}

-(void)endEdit {
    [self.view endEditing:YES];
    [self reloadNewInformation];
}
@end
