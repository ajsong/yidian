//
//  shopVerify.m
//  yidian
//
//  Created by ajsong on 16/1/5.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "shopVerify.h"
#import "shopVerifyDetail.h"

@interface shopVerify ()<UITableViewDataSource,UITableViewDelegate>{
	NSMutableArray *_ms;
	UITableView *_table;
	NSInteger _offset;
	//NSMutableArray *_cellHeight;
}
@end

@implementation shopVerify

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[_table headerBeginRefreshing];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"渠道商审核";
	self.view.backgroundColor = BACKCOLOR;
	
	_table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
	_table.estimatedSectionHeaderHeight = 0;
	_table.estimatedSectionFooterHeight = 0;
	_table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
	//_table.separatorStyle = UITableViewCellSeparatorStyleNone;
	//_table.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
	_table.backgroundColor = [UIColor clearColor];
	_table.dataSource = self;
	_table.delegate = self;
	[_table addHeaderWithTarget:self action:@selector(tableViewRefresh)];
	[_table addFooterWithTarget:self action:@selector(tableViewLoadMore)];
	[self.view addSubview:_table];
}

#pragma mark - loadData
- (void)loadData{
	//[Global removeAllCacheObjects];
	_ms = [[NSMutableArray alloc]init];
	//_cellHeight = [[NSMutableArray alloc]init];
	_offset = 0;
	[Common getApiWithParams:@{@"app":@"eshop", @"act":@"reseller_apply_list"} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([json[@"data"] isArray]) {
			NSArray *list = json[@"data"];
			for (int i=0; i<list.count; i++) {
				[_ms addObject:list[i]];
				//[_cellHeight addObject:@0];
				_offset++;
			}
		}
		//NSLog(@"%@", _ms);
		[self refreshTable];
	} fail:^(NSMutableDictionary *json) {
		[self refreshTable];
	}];
}

- (void)loadMore{
	[Common getApiWithParams:@{@"app":@"eshop", @"act":@"reseller_apply_list", @"offset":@(_offset)} success:^(NSMutableDictionary *json) {
		if ([json[@"data"] isArray]) {
			NSArray *list = json[@"data"];
			for (int i=0; i<list.count; i++) {
				[_ms addObject:list[i]];
				//[_cellHeight addObject:@0];
				_offset++;
			}
		}
		[self refreshTableLoadMore];
	} fail:^(NSMutableDictionary *json) {
		[self refreshTableLoadMore];
	}];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return !_ms.isArray ? 1 : _ms.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return tableView.height;
	return 54;
	//NSInteger row = indexPath.row;
	//if (IOS8) return [_cellHeight[row]floatValue];
	//if ([_cellHeight[row]floatValue]==0) [self tableView:tableView cellForRowAtIndexPath:indexPath];
	//return [_cellHeight[row]floatValue];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	cell.backgroundColor = [UIColor clearColor];
	cell.imageView.image = nil;
	cell.textLabel.text = nil;
	cell.textLabel.font = [UIFont systemFontOfSize:14.f];
	cell.detailTextLabel.text = nil;
	cell.detailTextLabel.font = [UIFont systemFontOfSize:13.f];
	cell.detailTextLabel.textColor = COLOR999;
	cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
	cell.detailTextLabel.minimumScaleFactor = 0.8;
	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	//cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
	//cell.selectedBackgroundView.backgroundColor = [UIColor blackColor];
	
	if (_ms==nil) return cell;
	if (!_ms.count) {
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
	for (UIView *subview in cell.contentView.subviews) {
		[subview removeFromSuperview];
	}
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width, 54)];
	view.backgroundColor = WHITE;
	[cell.contentView addSubview:view];
	
	UIImageView *avatar = [[UIImageView alloc]initWithFrame:CGRectMake(17, (view.height-32)/2, 32, 32)];
	avatar.image = IMG(@"avatar");
	avatar.url = _ms[row][@"avatar"];
	avatar.layer.masksToBounds = YES;
	avatar.layer.cornerRadius = 16;
	[view addSubview:avatar];
	
	UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(avatar.right+8, 0, view.width-(avatar.right+8), view.height)];
	name.text = _ms[row][@"nick_name"];
	name.textColor = [UIColor blackColor];
	name.font = [UIFont systemFontOfSize:15];
	name.backgroundColor = [UIColor clearColor];
	[view addSubview:name];
	
	UILabel *time = [[UILabel alloc]initWithFrame:CGRectMake(view.width-100-20, 0, 100, view.height)];
	time.text = _ms[row][@"add_time"];
	time.textColor = COLOR999;
	time.textAlignment = NSTextAlignmentRight;
	time.font = [UIFont systemFontOfSize:14];
	time.backgroundColor = [UIColor clearColor];
	[view addSubview:time];
	
	//[_cellHeight replaceObjectAtIndex:row withObject:@(view.bottom)];
	return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	shopVerifyDetail *e = [[shopVerifyDetail alloc]init];
	e.data = _ms[row];
	[self.navigationController pushViewController:e animated:YES];
}
#pragma mark -

#pragma mark - Refresh and load more methods
- (void)refreshTable{
	[_table headerEndRefreshing];
	[_table reloadData];
}

- (void)refreshTableLoadMore{
	[_table footerEndRefreshing];
	[_table reloadData];
}

- (void)tableViewRefresh{
	if (![Global isNetwork:YES]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[_table headerEndRefreshing];
		});
		return;
	}
	_ms = [[NSMutableArray alloc]init];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self loadData];
	});
}

- (void)tableViewLoadMore{
	if (![Global isNetwork:YES]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[_table footerEndRefreshing];
		});
		return;
	}
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self loadMore];
	});
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
