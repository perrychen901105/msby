//
//  LeveyPopListView.m
//  LeveyPopListViewDemo
//
//  Created by Levey on 2/21/12.
//  Copyright (c) 2012 Levey. All rights reserved.
//

#import "LeveyPopListViewNew.h"
#import "LeveyPopListViewCellNew.h"
#import "Constant.h"
#import "LeveyPopModel.h"
#import "FamilyMemberInfoViewController.h"
#import "AddNewMedicineViewController.h"
#define POPLISTVIEW_SCREENINSET 0
#define POPLISTVIEW_HEADER_HEIGHT 0
#define RADIUS 0.

@interface LeveyPopListViewNew (private)
- (void)fadeIn;
- (void)fadeOut;

@end

@implementation LeveyPopListViewNew
@synthesize delegate;
#pragma mark - initialization & cleaning up
- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.size.height -= 64;
    if (self = [super initWithFrame:rect])
    {
        _selectedIndex = -1;
        self.backgroundColor = [UIColor clearColor];
        _title = [aTitle copy];
        _options = aOptions ;
        
        
        CGFloat tableViewHeight = 0.0f;
        
        if(aOptions.count > 4) {
            tableViewHeight = 5 * 45+45;
        }else{
            tableViewHeight = aOptions.count * 45+45;
        }
 
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                   rect.size.height - tableViewHeight-74,
                                                                   rect.size.width - 2 * POPLISTVIEW_SCREENINSET,
                                                                   tableViewHeight)];
        _tableView.separatorColor = RGBHex(qwColor10);
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
          self.addMemberView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 45)];
               self.insertFootView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height -74, _tableView.frame.size.width, 74)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, _tableView.frame.size.width, 40);
         [button addTarget:self action:@selector(addMember:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *addMemberImg = [[UIImageView alloc]initWithFrame:CGRectMake(15, 11, 23, 23)];
        addMemberImg.image = [UIImage imageNamed:@"btn_img_add"];
        UILabel *addMemberLabel = [[UILabel alloc]initWithFrame:CGRectMake(addMemberImg.frame.origin.x+addMemberImg.frame.size.width+15, 15, 320, 17)];
        addMemberLabel.textColor = RGBHex(qwColor6);
        addMemberLabel.text = @"新建成员";
        [self.addMemberView addSubview:addMemberLabel];
        [self.addMemberView addSubview:addMemberImg];
        UIButton *confirm = [UIButton buttonWithType:UIButtonTypeCustom];
        confirm.frame = CGRectMake(15, 17, _tableView.frame.size.width-30, 40);
        confirm.backgroundColor = RGBHex(qwColor2);
         [confirm setTitle:@"确定" forState:UIControlStateNormal];
         [confirm addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
        [self.addMemberView addSubview:button];
        self.insertFootView.backgroundColor = RGBHex(qwColor11);
         [self.insertFootView addSubview:confirm];
//        [_tableView insertSubview:self.insertFootView belowSubview:_tableView];
         _tableView.tableFooterView = self.addMemberView;
      
        [self addSubview:_tableView];
          [self addSubview:self.insertFootView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:UPDATEUSER object:nil];
    }
    return self;    
}

-(void)addMember:(id)sender
{
    FamilyMemberInfoViewController *addFamMemViewController = [[UIStoryboard storyboardWithName:@"ConsultForFree" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FamilyMemberInfoViewController"];
    addFamMemViewController.enumTypeEdit = MemberViewTypeAdd;
    [((AddNewMedicineViewController *)self.delegate).navigationController pushViewController:addFamMemViewController animated:YES];
    ((AddNewMedicineViewController *)self.delegate).toAddMember = YES;;
    [self fadeOut];
}
-(void)confirm:(id)sender
{
    [self fadeOut];
    [((AddNewMedicineViewController *)self.delegate) removeUserInfo];
    for (LeveyPopModel *model in _options) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"memberId == %@",model.memberId];
        NSArray *array = [_options filteredArrayUsingPredicate:predicate];;
        LeveyPopModel *sub =array [0];
        if (sub.selected ) {
             [((AddNewMedicineViewController *)self.delegate).userArr addObject:sub];
        }
        
//        sub.selected = YES;
    }
   
    [self.delegate leveyPopListViewDidCancel];
}
- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    [_tableView reloadData];
}

- (void)dealloc
{
    [_title release];
//    [_options release];
    [_tableView release];
      [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark - Private Methods
- (void)fadeIn
{
    __block CGRect rect = _tableView.frame;
    rect.origin.y += rect.size.height;
    _tableView.frame = rect;
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        rect = _tableView.frame;
        rect.origin.y -= rect.size.height;
        _tableView.frame = rect;
    }];
}

- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 0.0;
        CGRect rect = _tableView.frame;
        rect.origin.y += rect.size.height;
        _tableView.frame = rect;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Instance Methods
- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

#pragma mark - Tableview datasource & delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"PopListViewCell";

    LeveyPopListViewCellNew *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (cell ==  nil) {
        cell = [[[LeveyPopListViewCellNew alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity] autorelease];

    }
    LeveyPopModel *popModel =_options[indexPath.row];
//    NSString *title =popModel.title;
    
   
    cell.addMemberLabel.text = popModel.title;
   
//    cell.textLabel.text = title;
//    cell.textLabel.textAlignment = NSTextAlignmentCenter;
//       cell.textLabel.textColor = [UIColor blackColor];
    if (popModel.selected) {
         cell.selectImg.image = [UIImage imageNamed:@"icon_shopping_selected"];
    }else
    {
         cell.selectImg.image = [UIImage imageNamed:@"btn_img_uncheck"];
    }
    
//        cell.textLabel.textColor = RGBHex(qwColor1);
   
    cell.bgBtn.tag = indexPath.row;
    [cell.bgBtn addTarget:self action:@selector(touchSlect:) forControlEvents:UIControlEventTouchUpInside];
//    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
//    cell.selectedBackgroundView.backgroundColor = RGBHex(qwColor10);
    return cell;
}
-(void)touchSlect:(id)sender
{
    UIButton *btn = (UIButton *)sender;
           NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
     LeveyPopListViewCellNew *cell = (LeveyPopListViewCellNew *)[_tableView cellForRowAtIndexPath:indexPath];
       LeveyPopModel *popModel =_options[indexPath.row];
    if (popModel.selected) {
          cell.selectImg.image = [UIImage imageNamed:@"btn_img_uncheck"];
        
        popModel.selected = NO;
        
    }else
    {
   cell.selectImg.image = [UIImage imageNamed:@"icon_shopping_selected"];
        popModel.selected = YES;
   
    }
    
    // tell the delegate the selection
    if (self.delegate && [self.delegate respondsToSelector:@selector(leveyPopListView:didSelectedIndex:select:)]) {
        [self.delegate leveyPopListView:self didSelectedIndex:[indexPath row] select:popModel.selected ];
    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  //    [_tableView reloadData];
    // dismiss self
//    [self fadeOut];
}
#pragma mark - TouchTouchTouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    // tell the delegate the cancellation
//    if (self.delegate && [self.delegate respondsToSelector:@selector(leveyPopListViewDidCancel)]) {
//        [self.delegate leveyPopListViewDidCancel];
//    }
    
    // dismiss self
//    [(AddNewMedicineViewController *)self.delegate removeUserInfo];
    [self fadeOut];
//      [self.delegate leveyPopListViewDidCancel];
}

-(void)reloadTable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        CGFloat tableViewHeight = 0.0f;
        
        if(_options.count > 4) {
            tableViewHeight = 5 * 45+45;
        }else{
            tableViewHeight = _options.count * 45+45;
        }
        CGRect rect = [[UIScreen mainScreen] bounds];
        rect.size.height -= 64;
        _tableView.frame =CGRectMake(0,
                                     rect.size.height - tableViewHeight-74,
                                     rect.size.width - 2 * POPLISTVIEW_SCREENINSET,
                                     tableViewHeight);
         [_tableView reloadData];
    });
    
}
@end
