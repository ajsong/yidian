//
//  shopCommission.m
//  yidian
//
//  Created by ajsong on 16/1/4.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "shopCommission.h"
#import "shopCommissionEdit.h"

@interface shopCommission ()<UITableViewDataSource,UITableViewDelegate>{
	NSMutableArray *_ms;
	UITableView *_table;
	NSInteger _offset;
	//NSMutableArray *_cellHeight;
}
@end

@implementation shopCommission

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[_table headerBeginRefreshing];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"分利模板";
	self.view.backgroundColor = BACKCOLOR;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"新增" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		shopCommissionEdit *e = [[shopCommissionEdit alloc]init];
		e.delegate = _delegate;
		[self.navigationController pushViewController:e animated:YES];
	}];
	
	_table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
	_table.estimatedSectionHeaderHeight = 0;
	_table.estimatedSectionFooterHeight = 0;
	//_table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
	_table.separatorStyle = UITableViewCellSeparatorStyleNone;
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
	[Common getApiWithParams:@{@"app":@"commission", @"act":@"index"} success:^(NSMutableDictionary *json) {
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
	[Common getApiWithParams:@{@"app":@"commission", @"act":@"index", @"offset":@(_offset)} success:^(NSMutableDictionary *json) {
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
	return !_ms.isArray ? 1 : _ms.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return tableView.height;
	return 55;
	//NSInteger row = indexPath.row;
	//if (IOS8) return [_cellHeight[row]floatValue];
	//if ([_cellHeight[row]floatValue]==0) [self tableView:tableView cellForRowAtIndexPath:indexPath];
	//return [_cellHeight[row]floatValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	if (section==0) return 0.00001;
	return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 0.00001;
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
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width, 55)];
	view.backgroundColor = WHITE;
	[cell.contentView addSubview:view];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, view.width-15*2, 27)];
	label.text = _ms[section][@"name"];
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(label.left, label.bottom, label.width, 10)];
	label.text = STRINGFORMAT(@"直接销售场景:%@%%　　二级场景:%@%%　　三级场景:%@%%", _ms[section][@"commission1"], _ms[section][@"commission2"], _ms[section][@"commission3"]);
	label.textColor = COLOR999;
	label.font = FONT(10);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	//[_cellHeight replaceObjectAtIndex:row withObject:@(view.bottom)];
	return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (_delegate && [_delegate respondsToSelector:@selector(GlobalExecuteWithCaller:data:)]) {
		[_delegate GlobalExecuteWithCaller:self data:_ms[section]];
		[self.navigationController popViewControllerAnimated:YES];
		return;
	}
	shopCommissionEdit *e = [[shopCommissionEdit alloc]init];
	e.data = _ms[section];
	[self.navigationController pushViewController:e animated:YES];
}

#pragma mark - TableViewCell Delete
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return NO;
	return _delegate ? NO : YES;
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)){
	UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
		[self tableView:tableView deleteActionAtIndexPath:indexPath completionHandler:completionHandler];
	}];
	deleteAction.image = IMG(@"delete");
	deleteAction.backgroundColor = COLORRGB(@"f5475e");
	UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
	return config;
}
#else
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
	//*//
	UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault image:IMG(@"delete") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
		[self tableView:tableView deleteActionAtIndexPath:indexPath completionHandler:nil];
	}];
	/*//
	 UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
	 [self tableView:tableView deleteActionAtIndexPath:indexPath completionHandler:nil];
	 }];
	 //*/
	deleteAction.backgroundColor = COLORRGB(@"f5475e");
	return @[deleteAction];
}
#endif
- (void)tableView:(UITableView *)tableView deleteActionAtIndexPath:(NSIndexPath *)indexPath completionHandler:(void(^)(BOOL))completionHandler{
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	[UIAlertView alert:@"确定删除此模板？删除分利模板不影响已经绑定的商品。" block:^(NSInteger buttonIndex) {
		if (buttonIndex == 1) {
			NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
			[postData setValue:_ms[section][@"id"] forKey:@"id"];
			[Common postApiWithParams:@{@"app":@"commission", @"act":@"delete"} data:postData feedback:nil success:^(NSMutableDictionary *json) {
				[_ms removeObjectAtIndex:row];
				if (_ms.count) {
					//[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
					[tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
				} else {
					[tableView reloadData];
				}
				if (completionHandler) completionHandler(YES);
			} fail:^(NSMutableDictionary *json) {
				if (completionHandler) completionHandler(YES);
			}];
		}
	}];
}

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
