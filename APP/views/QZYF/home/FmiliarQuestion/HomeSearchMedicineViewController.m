//
//  HomeSearchMedicineViewController.m
//  APP
//  首页搜索
//  首页商品搜索，只能搜索药品，与店内药品搜索页面共享缓存数据，功能逻辑不冗余
//  Created by 李坚 on 16/1/8.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "HomeSearchMedicineViewController.h"
#import "KeyWordSearchTableViewCell.h"
#import "SVProgressHUD.h"
#import "MedicineDetailViewController.h"
#import "CouponPromotionTableViewCell.h"
#import "HomeSearchMedicineTableViewCell.h"
#import "WebDirectViewController.h"
#import "ConsultStore.h"
#import "PromotionModel.h"
#import "MedicineSearchResultViewController.h"
#import "PromotionDrugDetailViewController.h"
#import "HomeScanViewController.h"
#import "QYPhotoAlbum.h"

static NSString *const SearchCell = @"KeyWordSearchTableViewCell";
static NSString *const MedicineCell = @"HomeSearchMedicineTableViewCell";

typedef enum  Enum_Data_Types {
    Enum_Data_Branch_List = 1,
    Enum_Data_City_List = 2,
}Enum_Data_Type;

@interface HomeSearchMedicineViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    NSMutableArray *historyArray;
    
    UIView *HistoryHeaderView;
    UIView *HotWordHeaderView;
    
    UIButton *clearBtn;
    int currPage;
    BranchProductVo *searchModel;
    Enum_Data_Type dataType;
}
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *dreamWordList;
@property (nonatomic, strong) NSMutableArray *resultDataList;
@property (strong, nonatomic) IBOutlet UIView *emptyDataView;
@property (strong, nonatomic) IBOutlet UIView *branchNoDataView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLineHeightConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLineHeightConstant;

@end

@implementation HomeSearchMedicineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _branchNoDataView.frame = CGRectMake(0, 0, APP_W, 268);
    _rightLineHeightConstant.constant = 0.5f;
    _leftLineHeightConstant.constant = 0.5f;
    self.scanBtn.hidden = NO;
    [self.scanBtn addTarget:self action:@selector(scanAction) forControlEvents:UIControlEventTouchUpInside];
    
    if(StrIsEmpty(QWGLOBALMANAGER.hotWord.searchHintMsg)){
        self.searchBarView.placeholder = @"输入商品名称和条形码";
    }else{
        self.searchBarView.placeholder = QWGLOBALMANAGER.hotWord.searchHintMsg;
    }
    [self.cancelButton removeTarget:self action:@selector(popAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    
    currPage = 1;
    
    self.searchBarView.delegate = self;
    _dreamWordList = [NSMutableArray array];
    _resultDataList = [NSMutableArray array];
    _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H - NAV_H)];
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mainTableView.backgroundColor = RGBHex(qwColor11);
    [_mainTableView registerNib:[UINib nibWithNibName:SearchCell bundle:nil] forCellReuseIdentifier:SearchCell];
    [_mainTableView registerNib:[UINib nibWithNibName:MedicineCell bundle:nil] forCellReuseIdentifier:MedicineCell];
    [_mainTableView addFooterWithTarget:self action:@selector(loadMoreData)];
    [_mainTableView setFooterHidden:YES];
    [self.view addSubview:_mainTableView];
    
    [self getHistoryWord];
    [self setupHotWordHeaderView:QWGLOBALMANAGER.hotWord.searchWords];
    
    if(historyArray.count == 0 && QWGLOBALMANAGER.hotWord.searchWords.count == 0){
        [self showInfoView:@"暂无搜索历史" image:@""];
    }
    //搜索输入框置为焦点
    [self.searchBarView becomeFirstResponder];
    
    //统计事件
    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        NSString *historyEnable;
        NSString *cityEnable;
        if(mapInfoModel.status == 3){//启用微商,商品搜索
            cityEnable = @"开通";
        }else{
            cityEnable = @"未开通";
        }
        if(historyArray.count > 0){
            historyEnable = @"有";
        }else{
            historyEnable = @"无";
        }
        
        [QWGLOBALMANAGER statisticsEventId:@"x_syss_jmcx" withLable:@"首页搜索" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"是否有搜索历史":historyEnable,@"是否开通微商":cityEnable}]];
    }];
    [self enableSimpleRefresh:self.mainTableView block:^(SRRefreshView *sender) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [QWGLOBALMANAGER checkEventId:@"首页搜索_搜索界面出现" withLable:nil withParams:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 扫码按钮点击Action
- (void)scanAction{
    
    if (![QYPhotoAlbum checkCameraAuthorizationStatus]) {
        [QWGLOBALMANAGER getCramePrivate];
        return;
    }
    HomeScanViewController *scanVC = [[HomeScanViewController alloc] initWithNibName:@"HomeScanViewController" bundle:nil];
    scanVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scanVC animated:NO];
}

#pragma mark - 热搜词汇HeaderView
- (void)setupHotWordHeaderView:(NSArray *)array{
    
    if(array == nil || array.count == 0){
        HotWordHeaderView = nil;
        self.mainTableView.tableHeaderView = nil;
        return;
    }
    HotWordHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 150)];
    HotWordHeaderView.backgroundColor = RGBHex(qwColor4);
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15.0f, 9, 100, 21)];
    label.font = fontSystem(kFontS4);
    label.text = @"热门搜索";
    label.textColor = RGBHex(qwColor8);
    [HotWordHeaderView addSubview:label];
    
    UIView *seperate = [[UIView alloc]initWithFrame:CGRectMake(0, 39, APP_W, 0.5)];
    seperate.backgroundColor = RGBHex(qwColor10);
    [HotWordHeaderView addSubview:seperate];
    
    int count = 0;
    float FrameOfY = 40;
    float Kfont = kFontS4;
    float btnX = 15.0f;
    
    
    for(hotKeyword *word in array){
        
        if(APP_W - btnX < Kfont * (word.word.length + 1)){
//            UIView *seperate = [[UIView alloc]initWithFrame:CGRectMake(0, FrameOfY + 41.0f, APP_W, 0.5)];
//            seperate.backgroundColor = RGBHex(qwColor10);
//            [HotWordHeaderView addSubview:seperate];
         
            FrameOfY += 41.0f;
            btnX = 15.0f;
        }
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(btnX, FrameOfY, Kfont * (word.word.length), 41.0f)];
        
        btnX += Kfont * (word.word.length) + 14;
        [btn setTitle:word.word forState:UIControlStateNormal];
        [btn setTitleColor:RGBHex(qwColor7) forState:UIControlStateNormal];
        btn.titleLabel.font = fontSystem(Kfont);
        [btn addTarget:self action:@selector(hotBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        btn.layer.masksToBounds = YES;
//        btn.layer.borderWidth = 0.5f;
//        btn.layer.cornerRadius = 2.0f;
        btn.layer.borderColor = RGBHex(qwColor7).CGColor;
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(btnX, btn.frame.origin.y + 9, 0.5, 23.0f)];
        line.backgroundColor = RGBHex(qwColor10);
        
        btnX += 14;
        [HotWordHeaderView addSubview:btn];
        
        if(count + 1 != array.count){
            hotKeyword *kw = array[count + 1];
            if(APP_W - btnX > Kfont * (kw.word.length + 1)){
                if(count + 1 != array.count){
                    [HotWordHeaderView addSubview:line];
                }
            }
        }
        count ++;
    }
    CGRect ret = HotWordHeaderView.frame;
    ret.size.height = FrameOfY + 40.5;
    HotWordHeaderView.frame = ret;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0,HotWordHeaderView.frame.size.height - 0.5, APP_W, 0.5)];
    line.backgroundColor = RGBHex(qwColor10);
    [HotWordHeaderView addSubview:line];
    _mainTableView.tableHeaderView = HotWordHeaderView;
}

//热搜词汇点击触发函数
- (void)hotBtnClick:(UIButton *)btn{
    self.searchBarView.text = btn.titleLabel.text;
    currPage = 1;
    [QWGLOBALMANAGER checkEventId:@"首页搜索_点击热门词" withLable:nil withParams:nil];

    [self searchResultByKeyWord:self.searchBarView.text];
}

#pragma mark - 搜索历史HeaderView
- (UIView *)setupHistoryHeaderView{
    
    HistoryHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 39.0f)];
    HistoryHeaderView.backgroundColor = RGBHex(qwColor4);
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 39.0f)];
    label.font = fontSystem(kFontS4);
    label.textColor = RGBHex(qwColor8);
    label.text = @"搜索历史";
    [HistoryHeaderView addSubview:label];
    
    clearBtn = [[UIButton alloc]initWithFrame:CGRectMake(APP_W - 64.5f, 0, 50, 39.0f)];
    [clearBtn setTitle:@"清空" forState:UIControlStateNormal];
    [clearBtn setTitleColor:RGBHex(qwColor7) forState:UIControlStateNormal];
    clearBtn.titleLabel.font = fontSystem(kFontS4);
    clearBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [clearBtn addTarget:self action:@selector(cleanHistoryWord) forControlEvents:UIControlEventTouchDown];
    [HistoryHeaderView addSubview:clearBtn];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 38.5, APP_W, 0.5)];
    line.backgroundColor = RGBHex(qwColor11);
    [HistoryHeaderView addSubview:line];
    
    return HistoryHeaderView;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self.searchBarView resignFirstResponder];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(!StrIsEmpty(self.searchBarView.text)){
        return 0.0f;
    }
    if(historyArray.count > 0){
        return 39.0f;
    }else{
        return 0.0f;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(!StrIsEmpty(self.searchBarView.text)){
        return nil;
    }
    if(historyArray.count > 0){
        return [self setupHistoryHeaderView];
    }else{
        return nil;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(!StrIsEmpty(self.searchBarView.text)){//searchBar用户有填写内容
        if(_resultDataList.count > 0){
            return _resultDataList.count;
        }else{
            if(_dreamWordList.count > 0){
                return _dreamWordList.count;
            }else{
                return 1;
            }
        }
    }else{//searchBar用户未填写内容
        return historyArray.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(_resultDataList.count > 0){
        id obj = _resultDataList[indexPath.row];
        if([obj isKindOfClass:[MicroMallSearchProVo class]]){
            return [HomeSearchMedicineTableViewCell getCellHeight:nil];
        }else{
            return [CouponPromotionTableViewCell getCellHeight:nil];
        }
    }else{
        return 45.0f;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *attributeDict = [NSDictionary dictionaryWithObjects:@[fontSystem(kFontS1),RGBHex(qwColor1)] forKeys:@[NSFontAttributeName,NSForegroundColorAttributeName]];
    
    if(!StrIsEmpty(self.searchBarView.text)){//searchBar用户有填写内容
        if(_resultDataList.count > 0){
            MicroMallSearchProVo *vo = _resultDataList[indexPath.row];
           
            //价格区间Cell
            HomeSearchMedicineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MedicineCell];

            [cell.imgUrl setImageWithURL:[NSURL URLWithString:vo.imgUrl] placeholderImage:[UIImage imageNamed:@"药品默认图片"]];
            
            cell.proName.text   = vo.proName;
            cell.purpose.text   = vo.content;
            cell.specLable.text = vo.spec;
            
            //V3.2新增逻辑 add by lijian
            if(StrIsEmpty(vo.showPrice)){
                cell.priceLabel.font = fontSystem(kFontS4);
                cell.priceLabel.textColor = RGBHex(qwColor7);
                cell.priceLabel.text = @"暂无门店销售此药";
            }else{
                cell.priceLabel.font = fontSystem(kFontS3);
                cell.priceLabel.textColor = RGBHex(qwColor2);
                cell.priceLabel.text = [NSString stringWithFormat:@"%@",vo.showPrice];
            }
            
            return cell;
         
        }else{
            KeyWordSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCell];
            cell.VoucherImage.hidden = YES;
            if(_dreamWordList.count > 0){
                HighlightAssociateVO *vo = _dreamWordList[indexPath.row];
                NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:vo.content];
                for(HighlightPosition *HL in vo.highlightPositionList){
                    NSRange range;
                    range.location = [HL.start intValue];
                    range.length = [HL.length intValue];
                    [AttributedStr setAttributes:attributeDict range:range];
                }
                if(AttributedStr.length > 20){
                    [AttributedStr replaceCharactersInRange:NSMakeRange(20, AttributedStr.length - 20) withString:@"..."];
                    cell.mainLabel.attributedText = AttributedStr;
                }else{
                    cell.mainLabel.attributedText = AttributedStr;
                }
            }else{
                NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"搜：%@",self.searchBarView.text]];
                NSRange range;
                range.location = 2;
                range.length = self.searchBarView.text.length;
                
                [AttributedStr setAttributes:attributeDict range:range];
                
                if(AttributedStr.length > 22){
                    [AttributedStr replaceCharactersInRange:NSMakeRange(22, AttributedStr.length - 22) withString:@"..."];
                    cell.mainLabel.attributedText = AttributedStr;
                }else{
                    cell.mainLabel.attributedText = AttributedStr;
                }
            }
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 44.5, APP_W, 0.5)];
            line.backgroundColor = RGBHex(qwColor11);
            [cell addSubview:line];
            return cell;
        }
    }else{//searchBar用户未填写内容
        KeyWordSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCell];
        cell.VoucherImage.hidden = YES;

        NSString *historyStr = historyArray[historyArray.count - 1 - indexPath.row];
        
        if(historyStr.length > 20){
            cell.mainLabel.text = [NSString stringWithFormat:@"%@...",[historyStr substringToIndex:20]];
        }else{
            cell.mainLabel.text = historyStr;
        }
        
        
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 44.5, APP_W, 0.5)];
        line.backgroundColor = RGBHex(qwColor11);
        [cell addSubview:line];
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(!StrIsEmpty(self.searchBarView.text)){//searchBar用户有填写内容
        
        if(_resultDataList.count > 0){
            [QWGLOBALMANAGER checkEventId:@"首页搜索_搜索结果_点击某个药品" withLable:nil withParams:nil];

            MicroMallSearchProVo *vo = _resultDataList[indexPath.row];

            //店内搜索，直接跳商品详情
            if(!StrIsEmpty(vo.branchProId)){
                
                MedicineDetailViewController *VC = [[MedicineDetailViewController alloc]initWithNibName:@"MedicineDetailViewController" bundle:nil];
                VC.lastPageName = @"首页搜索";
                VC.proId = vo.branchProId;
                [self.navigationController pushViewController:VC animated:YES];
                return;
            }
            
            //暂无门店销售此药，跳转H5
            if(StrIsEmpty(vo.showPrice)){
                [self pushH5Detail:vo.proId];
                return;
            }
            
            //请求，如果只有一家药房销售，直接跳转商品详情，如果不止一家则跳转比价页面
            [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
                ProductByCodeModelR *modelR = [ProductByCodeModelR new];
                modelR.city = mapInfoModel.city;
                modelR.code = vo.proId;
                modelR.longitude = @(mapInfoModel.location.coordinate.longitude);
                modelR.latitude = @(mapInfoModel.location.coordinate.latitude);
                
                [ConsultStore MedicineDetailByCode:modelR success:^(BranchProductVo *model) {
                    if([model.apiStatus intValue] == 0){
                        searchModel=model;
                        if(searchModel){
                                if(searchModel.branchs.count==1){
                                    //新药品详情界面
                                    MicroMallBranchVo *VO = searchModel.branchs[0];
                                    if(StrIsEmpty(VO.branchProId)){
                                        [tableView deselectRowAtIndexPath:indexPath animated:NO];
                                        return;
                                    }
                                    NSMutableDictionary *tdParams = [NSMutableDictionary dictionary];
                                    tdParams[@"药品名"] = VO.name;
                                    [QWGLOBALMANAGER statisticsEventId:@"x_pd_ypxq" withLable:@"频道药品比价" withParams:tdParams];
                                    [QWGLOBALMANAGER statisticsEventId:@"x_sy_yf" withLable:@"定位" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"药房名":VO.branchName}]];
                                    MedicineDetailViewController *VC = [[MedicineDetailViewController alloc]initWithNibName:@"MedicineDetailViewController" bundle:nil];
                                    VC.lastPageName = @"首页搜索";
                                    VC.proId = VO.branchProId;
                                    [self.navigationController pushViewController:VC animated:YES];
                                }else{
                                    //跳详情
                                    [self drugDetail:vo];
                                    [QWGLOBALMANAGER statisticsEventId:@"x_syss_djyp" withLable:@"首页搜索" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"药品名字":vo.proName}]];
                                }
                        }else{
                            [tableView deselectRowAtIndexPath:indexPath animated:NO];
                            return;
                        }

                    }
                } failure:^(HttpException *e) {
                    [SVProgressHUD showErrorWithStatus:kWarning12];
                    [tableView deselectRowAtIndexPath:indexPath animated:NO];
                    return;
                }];
            }];

        }else{
            currPage = 1;
            
            if(_dreamWordList.count > 0){
                [QWGLOBALMANAGER checkEventId:@"首页搜索_搜索界面_点击某个联想词" withLable:nil withParams:nil];

                HighlightAssociateVO *vo = _dreamWordList[indexPath.row];
                self.searchBarView.text = vo.content;

            }
            
            [self searchResultByKeyWord:self.searchBarView.text];
        }
    }else{//searchBar用户未填写内容
        [QWGLOBALMANAGER checkEventId:@"首页搜索_搜索历史词" withLable:nil withParams:nil];

        self.searchBarView.text = historyArray[historyArray.count - 1 - indexPath.row];
        currPage = 1;
        [self searchResultByKeyWord:self.searchBarView.text];
    }
}

#pragma mark - UISearchBarViewDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *) searchBar
{
    UITextField *searchBarTextField = nil;
    NSArray *views = ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) ? searchBar.subviews : [[searchBar.subviews objectAtIndex:0] subviews];
    for (UIView *subview in views)
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            searchBarTextField = (UITextField *)subview;
            break;
        }
    }
    searchBarTextField.enablesReturnKeyAutomatically = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [_mainTableView setFooterHidden:YES];
    if(!StrIsEmpty(searchBar.text)){
        
        [QWGLOBALMANAGER checkEventId:@"首页搜索_输入内容" withLable:nil withParams:nil];

        [_resultDataList removeAllObjects];
        [_dreamWordList removeAllObjects];
        //fixed at V3.1
        NSString *replaceWord = [QWGLOBALMANAGER replaceSymbolStringWith:searchBar.text];
        if(replaceWord.length > 0){
            [self searchDreamWord:replaceWord];
        }
    }else{
        [self cancelAction:nil];
    }
}

//用户点击键盘搜索，主要用于搜索默认词汇
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if(StrIsEmpty(searchBar.text) && StrIsEmpty(QWGLOBALMANAGER.hotWord.searchHintMsg)){
        [SVProgressHUD showErrorWithStatus:@"搜索内容不能为空" duration:DURATION_SHORT];
        return;
    }
    
    [super searchBarSearchButtonClicked:searchBar];
    
    currPage = 1;
    if(StrIsEmpty(searchBar.text)){
        self.searchBarView.text = QWGLOBALMANAGER.hotWord.searchHintMsg;
        [self searchResultByKeyWord:QWGLOBALMANAGER.hotWord.searchHintMsg];
    }else{
        //fixed at V3.1
        NSString *replaceWord = [QWGLOBALMANAGER replaceSymbolStringWith:searchBar.text];
        
        if(replaceWord.length == 0){
            self.searchBarView.text = QWGLOBALMANAGER.hotWord.searchHintMsg;
            [self searchResultByKeyWord:QWGLOBALMANAGER.hotWord.searchHintMsg];
        }else{
            [self searchResultByKeyWord:replaceWord];
        }
        
    }

}

#pragma mark - 关键字搜索结果请求
- (void)searchResultByKeyWord:(NSString *)word{
    
    [self.searchBarView resignFirstResponder];
    
    [QWGLOBALMANAGER statisticsEventId:@"首页搜索_搜索结果页" withLable:nil withParams:nil];

    //渠道统计    首页
    ChannerTypeModel *modelTwo=[ChannerTypeModel new];
    modelTwo.objRemark=word;
    modelTwo.objId=@"";
    modelTwo.cKey=@"keywords_search";
    [QWGLOBALMANAGER qwChannel:modelTwo];
    
    //正则表达式判断，条件：全数字，并且8位以上
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[0-9]{8,}.*"];
    
    if ([pred evaluateWithObject:word]) {
       
        [self searchResultBarCode:word];
        
    }else{
        [self historyWordSave:word];
        HttpClientMgr.progressEnabled = YES;

        dataType = Enum_Data_Branch_List;
        [self searchResultInBranch:word];
    }
}

//条形码搜索
- (void)searchResultBarCode:(NSString *)code{

    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        
        HomeSearInBranchModelR *modelR = [HomeSearInBranchModelR new];
        modelR.branchId = [QWGLOBALMANAGER getMapBranchId];
        modelR.key = code;
        
        [Search homeScanSearchInBranch:modelR success:^(MicroMallSearchProArrayVo *model) {
            
            [self refreshTableView:model.products keyWord:code Type:0];
            
        } failure:^(HttpException *e) {
            
        }];
    }];
}

//店内搜索
- (void)searchResultInBranch:(NSString *)word{
    
    //先搜索当下店内
    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        
        HomeSearInBranchModelR *branchModelR = [HomeSearInBranchModelR new];
        branchModelR.branchId = [QWGLOBALMANAGER getMapBranchId];
        branchModelR.key = word;
        branchModelR.page = [NSString stringWithFormat:@"%d",currPage];
        branchModelR.pageSize = @"10";
        
        [QWLOADING showLoading];
        
        [Search homeSearchInBranch:branchModelR success:^(MicroMallSearchProArrayVo *branchModel) {
            
            [self refreshTableView:branchModel.products keyWord:word Type:1];
            
        } failure:^(HttpException *e) {
            
        }];
    }];
}

//城市搜索
- (void)searchResultInCity:(NSString *)word{
    
    DreamWordModelR *modelR = [DreamWordModelR new];
    modelR.keyword = word;
    modelR.currPage = @(currPage);
    modelR.pageSize = @(10);
    
    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        
        modelR.cityName = mapInfoModel.city;
        
        [Search homeSearchInCity:modelR success:^(MicroMallSearchProArrayVo *branchModel) {
            
            dataType = Enum_Data_City_List;
            [self refreshTableView:branchModel.products keyWord:word Type:1];
            
        } failure:^(HttpException *e) {
            
        }];
        
    }];
}

#pragma mark - 联想词请求
- (void)searchDreamWord:(NSString *)word{
    
    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        [_mainTableView removeHeader];
        DreamWordModelR *modelR = [DreamWordModelR new];
        modelR.keyword = word;
        modelR.cityName = mapInfoModel.city;
        
        _mainTableView.tableHeaderView = nil;
        
        [Search homeDreamWord:modelR success:^(KeywordModel *model) {
            [self.emptyDataView removeFromSuperview];
            [QWGLOBALMANAGER statisticsEventId:@"x_sy_srnr" withLable:@"首页搜索" withParams:[NSMutableDictionary dictionaryWithDictionary:@{@"内容":word,@"是否出现关键词":model.list.count > 0?@"是":@"否"}]];
            if([model.apiStatus intValue] == 0){

                [self removeInfoView];
                [self.emptyDataView removeFromSuperview];
                [_dreamWordList removeAllObjects];
                [_dreamWordList addObjectsFromArray:model.list];
                [_mainTableView reloadData];
                
            }else{
                [_dreamWordList removeAllObjects];
                [_mainTableView reloadData];
            }
            
        } failure:^(HttpException *e) {
            
            
        }];

    }];
        
}

#pragma mark - 获取缓存
- (void)getHistoryWord{
    self.mainTableView.tableHeaderView = HotWordHeaderView;
    [_mainTableView removeHeader];
    historyArray = [[NSMutableArray alloc] initWithArray:getHistoryConfig(@"SearchHistory")];
    [_mainTableView reloadData];
}

#pragma mark - 清除缓存
- (void)cleanHistoryWord{

    [QWGLOBALMANAGER statisticsEventId:@"首页搜索_清空搜索历史" withLable:nil withParams:nil];
    
    [historyArray removeAllObjects];
    setHistoryConfig(@"SearchHistory", nil);
    [SearchHistoryVo deleteAllObjFromDB];
    [_mainTableView reloadData];
    if(QWGLOBALMANAGER.hotWord.searchWords.count == 0){
        [self showInfoView:@"暂无搜索历史" image:@""];
    }
}


#pragma mark - 存储历史搜索信息
- (void)historyWordSave:(NSString *)keyWord{
    
    for(NSString *wo in historyArray){
        if([keyWord isEqualToString:wo]){
            [historyArray removeObject:wo];
            break;
        }
    }
    
    [historyArray addObject:keyWord];
    if(historyArray.count > 10){
        [historyArray removeObjectAtIndex:0];
    }
    setHistoryConfig(@"SearchHistory", historyArray);
}

- (void)refreshTableView:(NSArray *)dataArray keyWord:(NSString *)word Type:(NSInteger)type{

    [QWLOADING removeLoading];
    [self removeInfoView];
    
    if(type == 0){//条形码搜索
        if(dataArray && dataArray.count > 0){
            [_resultDataList removeAllObjects];
            [_resultDataList addObjectsFromArray:dataArray];
            [_mainTableView reloadData];
        }else{
            self.emptyDataView.frame = CGRectMake(0, 0, APP_W, APP_H - NAV_H);
            [self.view addSubview:self.emptyDataView];
        }
        return;
    }
    
    //文字搜索
    if(dataArray && dataArray.count > 0){
        //表示该药房下有数据，刷新TableView

        if(currPage == 1){
            [QWGLOBALMANAGER statisticsEventId:@"x_sy_jg" withLable:@"首页搜索-搜索结果页" withParams:nil];
            [_resultDataList removeAllObjects];
            [_mainTableView setFooterHidden:NO];
            [_mainTableView.footer setCanLoadMore:YES];
            if(dataType == Enum_Data_City_List){
                //第一次拉取到城市内数据，则需要给他一个TableHeaderView
                _mainTableView.tableHeaderView = self.branchNoDataView;
            }else{
                _mainTableView.tableHeaderView = nil;
            }
        }else{
            [_mainTableView.footer endRefreshing];
        }
        
        [_resultDataList addObjectsFromArray:dataArray];
        [_mainTableView reloadData];
        
    }else{
        if(currPage == 1){
            //药房第一页没数据，请求城市下数据
            if(dataType == Enum_Data_Branch_List){
                
                dataType = Enum_Data_City_List;
                currPage = 1;
                [self searchResultInCity:word];
            }else{
                self.emptyDataView.frame = CGRectMake(0, 0, APP_W, APP_H - NAV_H);
                [self.view addSubview:self.emptyDataView];
            }
            
        }else{
            //否则显示没有更多结果
            [_mainTableView.footer endRefreshing];
            [_mainTableView.footer setCanLoadMore:NO];
        }
    }
}

#pragma mark - 上拉加载调用方法
- (void)loadMoreData{
    
    currPage += 1;
    if(dataType == Enum_Data_Branch_List){
        [self searchResultInBranch:[QWGLOBALMANAGER replaceSymbolStringWith:self.searchBarView.text]];
    }else{
        [self searchResultInCity:[QWGLOBALMANAGER replaceSymbolStringWith:self.searchBarView.text]];
    }
}

#pragma mark - 未启用微商，跳转营销也商品详情
- (void)pushIntoH5Detail:(NSString *)proId withPromotionId:(NSString *)promotionId{
    
    WebDirectViewController *vcWebMedicine = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];

    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        WebDrugDetailModel *modelDrug = [WebDrugDetailModel new];
        modelDrug.modelMap = mapInfoModel;
        modelDrug.proDrugID = proId;
        modelDrug.promotionID = promotionId;
        WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
        modelLocal.modelDrug = modelDrug;
        modelLocal.typeLocalWeb = WebPageToWebTypeMedicine;
        [vcWebMedicine setWVWithLocalModel:modelLocal];
        [self.navigationController pushViewController:vcWebMedicine animated:YES];
            
    }];
}

#pragma mark - 启用微商，跳转内容页药品详情
- (void)pushH5Detail:(NSString *)proId{
    
    WebDirectViewController *vcWebMedicine = [[UIStoryboard storyboardWithName:@"WebDirect" bundle:nil] instantiateViewControllerWithIdentifier:@"WebDirectViewController"];
    
    [QWGLOBALMANAGER readLocationWhetherReLocation:NO block:^(MapInfoModel *mapInfoModel) {
        WebDrugDetailModel *modelDrug = [WebDrugDetailModel new];
        modelDrug.modelMap = mapInfoModel;
        modelDrug.proDrugID = proId;
        modelDrug.promotionID = proId;
        WebDirectLocalModel *modelLocal = [WebDirectLocalModel new];
        modelLocal.modelDrug = modelDrug;
        modelLocal.typeLocalWeb = WebPageToWebTypeMedicine;
        vcWebMedicine.NeedTwoTab = YES;
        [vcWebMedicine setWVWithLocalModel:modelLocal];
        [self.navigationController pushViewController:vcWebMedicine animated:YES];
        
    }];
}

#pragma mark - 启用微商，点击跳转中间页面
- (void)drugDetail:(MicroMallSearchProVo *)result{

    MedicineSearchResultViewController *VC = [[MedicineSearchResultViewController alloc]initWithNibName:@"MedicineSearchResultViewController" bundle:nil];
    VC.productCode = result.proId;
    VC.lastPageName = @"首页搜索";
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 点击取消调用Action
//根据产品需求：
//当处于联想词和结果页面时，点击取消返回搜索历史
//当处于搜索历史页面时   ，点击取消返回上一页
- (void)cancelAction:(id)sender{
    
    if(sender){
        [QWGLOBALMANAGER statisticsEventId:@"首页搜索_搜索界面_取消" withLable:nil withParams:nil];
    }

    if(!StrIsEmpty(self.searchBarView.text)){
        
        [_dreamWordList removeAllObjects];
        [_resultDataList removeAllObjects];
        [self.emptyDataView removeFromSuperview];
        [_mainTableView setFooterHidden:YES];
        self.searchBarView.text = @"";
        [self getHistoryWord];
        if(historyArray.count == 0 && QWGLOBALMANAGER.hotWord.searchWords.count == 0){
            [self showInfoView:@"暂无搜索历史" image:@""];
        }else{
            [self removeInfoView];
        }
        [_mainTableView reloadData];
        [self.searchBarView becomeFirstResponder];
    }else{
        if(sender){
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
