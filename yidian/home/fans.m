//
//  fans.m
//  yidian
//
//  Created by ajsong on 16/1/6.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "fans.h"
#import "bulkChat.h"

@interface fans ()<UITableViewDataSource,UITableViewDelegate>{
	NSMutableArray *_ms;
	UITableView *_table;
	NSInteger _offset;
}
@end

@implementation fans

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"我的粉丝";
	self.view.backgroundColor = BACKCOLOR;
	
	/*
	if ([PERSON[@"member_type"] integerValue]==3) {
		KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"群发" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
		[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
			bulkChat *e = [[bulkChat alloc]init];
			[self.navigationController pushViewController:e animated:YES];
		}];
	}
	 */
	
	_table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_table.estimatedSectionHeaderHeight = 0;
	_table.estimatedSectionFooterHeight = 0;
	_table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
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
	_ms = [[NSMutableArray alloc]init];
	_offset = 0;
	NSString *url = [Common getApiWithParams:@{@"app":@"eshop", @"act":@"followers", @"pagesize":@10} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([Global isArray:json[@"data"]]) {
			NSArray *list = json[@"data"];
			for (int i=0; i<list.count; i++) {
				NSDictionary *element = [NSDictionary dictionaryWithDictionary:list[i]];
				[_ms addObject:element];
				_offset++;
			}
		}
		//NSLog(@"%@", _ms);
		[self refreshTable];
	} fail:^(NSMutableDictionary *json) {
		[self refreshTable];
	}];
	NSLog(@"%@", url);
}

- (void)loadMore{
	[Common getApiWithParams:@{@"app":@"eshop", @"act":@"followers", @"offset":@(_offset)} success:^(NSMutableDictionary *json) {
		if ([Global isArray:json[@"data"]]) {
			NSArray *list = json[@"data"];
			for (int i=0; i<list.count; i++) {
				NSDictionary *element = [NSDictionary dictionaryWithDictionary:list[i]];
				[_ms addObject:element];
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
	if (!_ms.isArray) return tableView.height;
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
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width, 54)];
	[cell.contentView addSubview:view];
	
	UIImageView *avatar = [[UIImageView alloc]initWithFrame:CGRectMake(17, (view.height-32)/2, 32, 32)];
	avatar.image = IMG(@"avatar");
	avatar.url = _ms[row][@"avatar"];
	avatar.layer.masksToBounds = YES;
	avatar.layer.cornerRadius = 16;
	[view addSubview:avatar];
	
	UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(avatar.right+8, 0, view.width-(avatar.right+8), view.height)];
	name.text = _ms[row][@"name"];
	name.textColor = [UIColor blackColor];
	name.font = [UIFont systemFontOfSize:15];
	name.backgroundColor = [UIColor clearColor];
	[view addSubview:name];
	
	/*
	UILabel *time = [[UILabel alloc]initWithFrame:CGRectMake(view.width-100-20, 0, 100, view.height)];
	time.text = _ms[row][@"add_time"];
	time.textColor = COLOR777;
	time.textAlignment = NSTextAlignmentRight;
	time.font = [UIFont systemFontOfSize:14];
	time.backgroundColor = [UIColor clearColor];
	[view addSubview:time];
	 */
	
	return cell;
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (_ms.count<=0) return;
	NSInteger row = indexPath.row;
//	NSString *chatter = STRING(_ms[row][@"id"]);
//	if ([chatter isEqualToString:STRING(PERSON[@"id"])]) {
//		[ProgressHUD showError:@"不能与自己聊天"];
//		return;
//	}
//	talk *g = [[talk alloc]init];
//	g.title = _ms[row][@"nick_name"];
//	g.chatter = chatter;
//	[self.navigationController pushViewController:g animated:YES];
}

#pragma mark - TableView Cell Delete
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return NO;
	return YES;
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
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:_ms[row][@"id"] forKey:@"member_id"];
	[Common postApiWithParams:@{@"app":@"eshop", @"act":@"follower_delete"} data:postData feedback:nil success:nil fail:nil];
	[_ms removeObjectAtIndex:row];
	if (_ms.count>0) {
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
	} else {
		[tableView reloadData];
	}
	if (completionHandler) completionHandler(YES);
}

#pragma mark - Refresh and load more methods
- (void)refreshTable {
	[_table headerEndRefreshing];
	[_table reloadData];
}

- (void)refreshTableLoadMore {
	[_table footerEndRefreshing];
	[_table reloadData];
}

- (void)tableViewRefresh {
	if (![Global isNetwork:YES]) {
		[_table headerEndRefreshing];
		return;
	}
	_ms = [[NSMutableArray alloc]init];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self loadData];
	});
}

- (void)tableViewLoadMore {
	if (![Global isNetwork:YES]) {
		[_table footerEndRefreshing];
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
