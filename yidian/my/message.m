//
//  message.m
//  xfb
//
//  Created by ajsong on 15/10/14.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import "Global.h"
#import "message.h"
@interface message ()<UITableViewDataSource,UITableViewDelegate>{
	NSMutableArray * _ms;
	UITableView *_table;
	NSInteger _offset;
	NSMutableArray * _cellHeight;
}
@end

@implementation message

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[_table headerBeginRefreshing];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"我的消息";
	self.view.backgroundColor = BACKCOLOR;
	
	_table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_table.estimatedSectionHeaderHeight = 0;
	_table.estimatedSectionFooterHeight = 0;
	_table.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarControllerKK.tabBarHeight, 0);
    _table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    _table.backgroundColor = [UIColor clearColor];
    _table.dataSource = self;
    _table.delegate = self;
    [_table addHeaderWithTarget:self action:@selector(tableViewRefresh)];
    [_table addFooterWithTarget:self action:@selector(tableViewLoadMore)];
    [self.view addSubview:_table];
}

#pragma mark - loadData
- (void)loadData{
	_ms = [[NSMutableArray alloc]init];
	_cellHeight = [[NSMutableArray alloc]init];
	_offset = 0;
	[Common getApiWithParams:@{@"app":@"message", @"act":@"index"} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json);
		if ([json[@"data"] isArray]) {
			NSArray *list = json[@"data"];
			for (int i=0; i<list.count; i++) {
				[_ms addObject:list[i]];
				[_cellHeight addObject:@0];
				_offset++;
			}
			if (_table.footer) _table.footerHidden = NO;
		}
		//NSLog(@"%@", _ms);
		[self refreshTable];
	} fail:^(NSMutableDictionary *json) {
		[self refreshTable];
	}];
}

- (void)loadMore{
	[Common getApiWithParams:@{@"app":@"message", @"act":@"index", @"offset":@(_offset)} success:^(NSMutableDictionary *json) {
		if ([json[@"data"] isArray]) {
			NSArray *list = json[@"data"];
			for (int i=0; i<list.count; i++) {
				[_ms addObject:list[i]];
				[_cellHeight addObject:@0];
				_offset++;
			}
		} else {
			if (_table.footer) _table.footerHidden = YES;
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
	if (![_ms isArray]) return tableView.height-self.tabBarControllerKK.tabBarHeight;
	NSInteger row = indexPath.row;
	if (IOS8) return [_cellHeight[row]floatValue];
	if ([_cellHeight[row]floatValue]==0) [self tableView:tableView cellForRowAtIndexPath:indexPath];
	return [_cellHeight[row]floatValue];
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
	
	if (!_ms) return cell;
	if (!_ms.count) {
		for (UIView *subview in cell.contentView.subviews) {
			[subview removeFromSuperview];
		}
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.width, tableView.height-self.tabBarControllerKK.tabBarHeight)];
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
	cell.backgroundColor = [UIColor whiteColor];
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
	[cell.contentView addSubview:view];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
        [self tableView:tableView didSelectRowAtIndexPath:indexPath];
        [self setReaded:view];
	}];
	
	UIView *ico = [[UIView alloc]initWithFrame:CGRectMake(15, 15, 8, 8)];
	if ([_ms[row][@"readed"]integerValue]==0) {
		ico.backgroundColor = COLORRGB(@"d00000");
	} else {
		ico.backgroundColor = COLORRGB(@"cecece");
	}
	ico.layer.masksToBounds = YES;
	ico.layer.cornerRadius = ico.height/2;
	ico.tag = 100;
	[view addSubview:ico];
	
	NSString *string = _ms[row][@"content"];
	CGSize s = [string autoHeight:FONT(14) width:view.width-(ico.right+10)-15];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(ico.right+10, ico.top-4, view.width-(ico.right+10)-15, s.height)];
	label.text = string;
	if ([_ms[row][@"readed"]integerValue]==0) {
		label.textColor = [UIColor blackColor];
	} else {
		label.textColor = COLORRGB(@"cecece");
	}
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 0;
	label.tag = 101;
	[view addSubview:label];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(label.left, label.bottom+5, label.width, 15)];
	label.text = _ms[row][@"add_time"];
	label.textColor = COLORCCC;
	label.textAlignment = NSTextAlignmentRight;
	label.font = FONT(11);
	[view addSubview:label];
	
	view.height = label.bottom + 10;
	[_cellHeight replaceObjectAtIndex:row withObject:@(view.bottom)];
	return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (![_ms isArray]) return;
	NSInteger row = indexPath.row;
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:_ms[row][@"id"] forKey:@"id"];
	[Common postApiWithParams:@{@"app":@"message", @"act":@"read"} data:postData feedback:nil success:^(NSMutableDictionary *json) {
		[@"notify" setUserDefaultsWithData:STRING(json[@"notify"])];
	} fail:nil];
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
	[postData setObject:_ms[row][@"id"] forKey:@"id"];
	[Common postApiWithParams:@{@"app":@"message", @"act":@"delete"} data:postData feedback:nil success:^(NSMutableDictionary *json) {
		[_ms removeObjectAtIndex:row];
		if (_ms.count) {
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
		} else {
			[tableView reloadData];
		}
		if (completionHandler) completionHandler(YES);
	} fail:^(NSMutableDictionary *json) {
		if (completionHandler) completionHandler(YES);
	}];
}

- (void)setReaded:(UIView*)view{
	UIImageView *ico = (UIImageView*)[view viewWithTag:100];
	UILabel *label = (UILabel*)[view viewWithTag:101];
	ico.backgroundColor = COLORRGB(@"cecece");
	label.textColor = COLORRGB(@"cecece");
}

#pragma mark - Refresh and load more methods
- (void)refreshTable{
	[_table headerEndRefreshing];
	[_table reloadData];
	if (_table.footer) {
		_table.footerHidden = _ms.count <= 0;
		[self performSelector:@selector(footerHandle) withObject:nil afterDelay:0.1];
	}
}
- (void)footerHandle{
	if (_table.contentSize.height+_table.contentInset.top+_table.contentInset.bottom <= _table.height) {
		_table.footerHidden = YES;
	}
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
