//
//  factoryGoods.m
//  yidian
//
//  Created by ajsong on 16/4/8.
//  Copyright © 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "factoryGoods.h"

@interface factoryGoods ()<UITableViewDataSource,UITableViewDelegate>{
	NSMutableArray *_ms;
	UITableView *_table;
	NSInteger _offset;
	//NSMutableArray *_cellHeight;
	
	NSMutableArray *_selectedPaths;
}
@end

@implementation factoryGoods

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"商品列表";
	self.view.backgroundColor = BACKCOLOR;
	
	_selectedPaths = [[NSMutableArray alloc]init];
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"确定" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		NSMutableArray *ms = [[NSMutableArray alloc]init];
		for (int i=0; i<_selectedPaths.count; i++) {
			NSIndexPath *indexPath = _selectedPaths[i];
			[ms addObject:_ms[indexPath.row]];
		}
		[_delegate GlobalExecuteWithDatas:ms];
		[self.navigationController popViewControllerAnimated:YES];
	}];
	
	_table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
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
	[_table headerBeginRefreshing];
}

#pragma mark - loadData
- (void)loadData{
	//[Global removeAllCacheObjects];
	_ms = [[NSMutableArray alloc]init];
	//_cellHeight = [[NSMutableArray alloc]init];
	_offset = 0;
	[Common getApiWithParams:@{@"app":@"eshop", @"act":@"my_goods", @"factory":@"yes"} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([json[@"data"] isArray]) {
			NSArray *list = json[@"data"];
			list = [list UpyunSuffix:@"!small" forKeys:@[@"default_pic"]];
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
	[Common getApiWithParams:@{@"app":@"eshop", @"act":@"my_goods", @"factory":@"yes", @"offset":@(_offset)} success:^(NSMutableDictionary *json) {
		if ([json[@"data"] isArray]) {
			NSArray *list = json[@"data"];
			list = [list UpyunSuffix:@"!small" forKeys:@[@"default_pic"]];
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
	return 62;
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
	cell.accessoryView = nil;
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
		label.textColor = COLOR999;
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
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width, 62)];
	view.backgroundColor = WHITE;
	[cell.contentView addSubview:view];
	
	UIImageView *pic = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 42, 42)];
	pic.image = IMG(@"nopic");
	pic.url = _ms[row][@"default_pic"];
	[view addSubview:pic];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(pic.right+10, pic.top, view.width-(pic.right+10)-44, pic.height)];
	label.text = STRINGFORMAT(@"%@ (编号:%@)", _ms[row][@"name"], _ms[row][@"id"]);
	label.textColor = [UIColor blackColor];
	label.font = FONT(13);
	label.backgroundColor = [UIColor clearColor];
	//label.lineBreakMode = NSLineBreakByTruncatingMiddle;
	//label.minimumScaleFactor = 0.8;
	//label.adjustsFontSizeToFitWidth = YES;
	[view addSubview:label];
	
	if ([_selectedPaths containsObject:indexPath]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
	//[_cellHeight replaceObjectAtIndex:row withObject:@(view.bottom)];
	return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if ([_selectedPaths containsObject:indexPath]) {
		[_selectedPaths removeObject:indexPath];
	} else {
		[_selectedPaths addObject:indexPath];
	}
	[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
