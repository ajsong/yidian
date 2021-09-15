//
//  bulkChat.m
//  ejdian
//
//  Created by ajsong on 15/9/7.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import "bulkChat.h"
#import "bulkChatPost.h"

@interface bulkChat ()<UITableViewDataSource,UITableViewDelegate,AJCheckboxDelegate>{
	NSMutableArray *_ms;
	UITableView *_table;
	AJCheckbox *_checkbox;
}
@end

@implementation bulkChat

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"群发消息";
	self.view.backgroundColor = BACKCOLOR;
	self.navigationController.navigationBar.translucent = NO;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"确定" textColor:WHITE fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		if (!_checkbox.selectedTexts.count) {
			[ProgressHUD showError:@"请选择需要发送的会员"];
			return;
		}
		bulkChatPost *e = [[bulkChatPost alloc]init];
		e.userID = _checkbox.selectedTexts;
		[self.navigationController pushViewController:e animated:YES];
	}];
	
	_table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_table.estimatedSectionHeaderHeight = 0;
	_table.estimatedSectionFooterHeight = 0;
	_table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
	_table.backgroundColor = [UIColor clearColor];
	_table.dataSource = self;
	_table.delegate = self;
	[self.view addSubview:_table];
	
	_checkbox = [[AJCheckbox alloc]init];
	_checkbox.delegate = self;
	_checkbox.orderType = CheckboxOrderTypeRight;
	_checkbox.type = CheckboxTypeCheckbox;
	_checkbox.image = IMG(@"s-post-add-checkbox1");
	_checkbox.selectedImage = IMG(@"s-post-add-checkbox2");
	_checkbox.font = FONT(14);
	_checkbox.size = CGSizeMake(25, 25);
	_checkbox.textWidth = SCREEN_WIDTH - 25 - 24;
	_checkbox.textHeight = 54;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self loadData];
	});
}

#pragma mark - loadData
- (void)loadData{
	_ms = [[NSMutableArray alloc]init];
	[Common getApiWithParams:@{@"app":@"eshop", @"act":@"followers", @"pagesize":@1000} success:^(NSMutableDictionary *json) {
		if ([Global isArray:json[@"data"]]) {
			NSArray *list = json[@"data"];
			for (int i=0; i<list.count; i++) {
				NSDictionary *element = [NSDictionary dictionaryWithDictionary:list[i]];
				[_ms addObject:element];
				[_checkbox addObject:STRING(element[@"id"])];
			}
		}
		//NSLog(@"%@", _ms);
		[_table reloadData];
	} fail:^(NSMutableDictionary *json) {
		[_table reloadData];
	}];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return _ms.count<=0 ? 1 : _ms.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
		[cell setSeparatorInset:UIEdgeInsetsZero];
	}
	if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
		[cell setLayoutMargins:UIEdgeInsetsZero];
	}
	if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
		[cell setPreservesSuperviewLayoutMargins:NO];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if (_ms.count<=0) return tableView.height;
	return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSInteger row = indexPath.row;
	NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	cell.textLabel.font = [UIFont systemFontOfSize:14.f];
	cell.backgroundColor = [UIColor clearColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	//cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
	//cell.selectedBackgroundView.backgroundColor = [UIColor blackColor];
	
	if (!_ms) return cell;
	if (_ms.count<=0) {
		for (UIView *subview in cell.contentView.subviews) {
			[subview removeFromSuperview];
		}
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.width, tableView.height)];
		label.text = @"当前没有任何记录";
		label.textColor = [UIColor blackColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:14];
		label.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:label];
		return cell;
	}
	if (_ms.count<=row) return cell;
	cell.backgroundColor = [UIColor whiteColor];
	for (UIView *subview in cell.contentView.subviews) {
		[subview removeFromSuperview];
	}
	
	UIView *view = _checkbox.views[row];
	view.width = tableView.width;
	[cell.contentView addSubview:view];
	((UILabel*)[view subviewsOfClass:[UILabel class]].firstObject).hidden = YES;
	UIImageView *box = (UIImageView*)[view subviewsOfClass:[UIImageView class]].firstObject;
	box.right = 24;
	
	UIImageView *avatar = [[UIImageView alloc]initWithFrame:CGRectMake(22, (view.height-32)/2, 32, 32)];
	avatar.image = IMG(@"avatar");
	avatar.url = _ms[row][@"avatar"];
	avatar.layer.masksToBounds = YES;
	avatar.layer.cornerRadius = 16;
	[view addSubview:avatar];
	
	UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(avatar.right+12, 0, view.width-(avatar.right+8), view.height)];
	name.text = _ms[row][@"nick_name"];
	name.textColor = [UIColor blackColor];
	name.font = [UIFont systemFontOfSize:15];
	name.backgroundColor = [UIColor clearColor];
	[view addSubview:name];
	
	return cell;
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (_ms.count<=0) return;
	NSInteger row = indexPath.row;
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
