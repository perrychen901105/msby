//
//  WYLocalNotifDetailVC.m
//  wenyao
//
//  Created by Yan Qingyang on 15/4/2.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "WYLocalNotifDetailVC.h"
#import "WYLocalNotifModel.h"
#import "WYLNOtherCell.h"
#import "WYLNTimesCell.h"
#import "WYLNDayCell.h"
#import "WYLNInfoCell.h"


#import "AppDelegate.h"

@interface WYLocalNotifDetailVC ()

@end

@implementation WYLocalNotifDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"提醒详情";
//    [self dataInit];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tableMain reloadData];
}

//- (void)setModLocalNotif:(WYLocalNotifModel *)modLocalNotif{
//    _modLocalNotif=modLocalNotif;
//    productUser=_modLocalNotif.productUser;
//    productName=_modLocalNotif.productName;
//    productId=_modLocalNotif.productId;
//    
//    //    [self.tableMain reloadData];
//}
#pragma mark - UI
- (void)UIGlobal{
    [super UIGlobal];
    
//    [self naviRightBotton];
    self.tableMain.backgroundColor=[UIColor clearColor];
    self.tableMain.footerHidden=YES;
//    [self naviRightBotton:@"编辑" action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(editAction:)];
}

//- (void)naviRightBotton
//{
//    CGFloat ww=kTopBarItemWidth, hh=44;
//    
//    CGRect frm = CGRectMake(0,0,ww,hh);
//    UIButton* btn= [[UIButton alloc] initWithFrame:frm];
//    
//    
//    [btn setTitle:@"编辑" forState:UIControlStateNormal];
//    btn.titleLabel.font=fontSystem(14);
//    btn.titleLabel.textColor=
//    [btn addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
//    
//    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    btn.backgroundColor=[UIColor clearColor];
//    
//    
//    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    fixed.width = -16;
//    
//    UIBarButtonItem* btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
//    self.navigationItem.rightBarButtonItems = @[fixed,btnItem];
//}

- (IBAction)editAction:(id)sender{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"LocalNotif" bundle:nil];
    WYLocalNotifEditVC* vc = [sb instantiateViewControllerWithIdentifier:@"WYLocalNotifEditVC"];
    
    vc.modLocalNotif=_modLocalNotif;
    vc.listClock=_listClock;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (section==1) {
//        return self.modLocalNotif.listTimes.count;
//    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float hh=0;
    
    NSInteger section = indexPath.section;
    switch (section) {
        case 0:
            hh=[WYLNInfoCell getCellHeight:nil];
            break;
        case 1:
            hh=[WYLNDayCell getCellHeight:nil];
            break;
        case 2:
            hh=8;
            break;
            
        case 3:
            hh=[WYLNTimesCell getCellHeight:nil];
            break;
        default:
            break;
    }
    return hh;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    static NSString *tableID;
    if (section==0) {
        tableID = [NSString stringWithFormat:@"WYLNInfoCell%li",(long)row];
        
        WYLNInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:tableID];
        cell.delegate=self;
        [cell setCell:_modLocalNotif];
        //        cell.separatorHidden=YES;
        if (_modLocalNotif.productName.length) {
            cell.txtProductName.text=_modLocalNotif.productName;
        }
        if (_modLocalNotif.productUser.length) {
            cell.txtProductUser.text=_modLocalNotif.productUser;
        }
        return cell;
    }
    if (section==1) {
        tableID = @"WYLNDayCell";
        
        WYLNDayCell *cell = [tableView dequeueReusableCellWithIdentifier:tableID];
        cell.delegate=self;
        [cell setCell:_modLocalNotif];
        
        return cell;
    }
    if (section==3) {
        tableID = @"WYLNTimesCell";
        
        WYLNTimesCell *cell = [tableView dequeueReusableCellWithIdentifier:tableID];
        if (row<_modLocalNotif.listTimes.count) {
            cell.delegate=self;
            [cell setCell:_modLocalNotif];
//            if (row == (_modLocalNotif.listTimes.count-1))
//                cell.separatorHidden=YES;
//            else
//                cell.separatorHidden=NO;
//            [cell setCell:[_modLocalNotif.listTimes objectAtIndex:row]];
        }
        
        
        return cell;
    }
//    if (section==3) {
//        tableID = @"WYLNOtherCell";
//        
//        WYLNOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:tableID];
//        cell.delegate=self;
//        cell.txtRemark.editable=NO;
//        [cell setCell:_modLocalNotif];
//        
//        return cell;
//    }
    UITableViewCell *cc=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cc"];
    cc.backgroundColor=[UIColor clearColor];
    return cc;
}
@end
