//
//  PackageListShower.m
//  APP
//
//  Created by 李坚 on 16/6/15.
//  Copyright © 2016年 carret. All rights reserved.
//

#import "PackageListShower.h"

#import "StoreGoodTableViewCell.h"
#define TableViewCellHeight 96.0f

static NSString *const storeGoodCellIdentifier = @"StoreGoodTableViewCell";
@implementation PackageListShower

+ (PackageListShower *)showPackageContent:(NSString *)content andDataList:(NSArray *)array callBack:(AddCallback)callBack{
    
    CartComboVoModel *model=(CartComboVoModel*)array;
    NSArray *drugList=model.druglist;
    
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"PackageListShower" owner:self options:nil];
    PackageListShower *PKView = [nibView objectAtIndex:0];
    CGFloat PKHeight = 157 + (TableViewCellHeight * (drugList.count > 3?3:drugList.count));
    PKView.frame = CGRectMake(0, 0, APP_W, PKHeight);
    
    PKView.callback = callBack;
    PKView.headLabel.text = content;
    PKView.dataArr = drugList;
    PKView.mainPriceLabel.text=[NSString stringWithFormat:@"¥%.2f",model.price];
    PKView.lessPriceLabel.text=[NSString stringWithFormat:@"立减¥%.2f",model.reduce];
    [PKView.PKTableView reloadData];

    return PKView;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.countLabel.text = @"1";
    self.countLabel.layer.borderColor = RGBHex(qwColor10).CGColor;
    self.countLabel.layer.borderWidth = 0.5f;
    self.countLabel.layer.masksToBounds = YES;
    self.dataArr = [[NSArray alloc]init];
    self.headView.layer.masksToBounds = YES;
    self.headView.layer.borderColor = RGBHex(qwColor10).CGColor;
    self.headView.layer.borderWidth = 0.5f;
    self.headView.layer.cornerRadius = 2.0f;
    
    self.PKTableView.dataSource = self;
    self.PKTableView.delegate = self;
    [self.PKTableView registerNib:[UINib nibWithNibName:storeGoodCellIdentifier bundle:nil] forCellReuseIdentifier:storeGoodCellIdentifier];
    self.PKTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (IBAction)closeAction:(id)sender {
    
    if(self.callback){
        
        self.callback(-1);
    }
}

- (IBAction)AddAction:(id)sender {
    
    self.countLabel.text = [NSString stringWithFormat:@"%d",[self.countLabel.text intValue] + 1];
}
- (IBAction)ReduceAction:(id)sender {
    
    if([self.countLabel.text intValue] == 1){
        return;
    }else{
        self.countLabel.text = [NSString stringWithFormat:@"%d",[self.countLabel.text intValue] - 1];
    }
}

- (IBAction)addToShoppingCar:(id)sender {
    
    if(self.callback){
        
        self.callback([self.countLabel.text integerValue]);
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return TableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    StoreGoodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:storeGoodCellIdentifier];
    cell.line.hidden = YES;
    cell.scoreLabel.hidden = YES;
    cell.ticketImage.hidden = YES;
    cell.proName.numberOfLines = 1;
    [cell setPackageCell:self.dataArr[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

@end
