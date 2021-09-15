//
//  factory.m
//  yidian
//
//  Created by ajsong on 16/4/1.
//  Copyright © 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "factory.h"
#import "factoryEdit.h"
#import "factoryUnbind.h"
#import "UIImageView+EMWebCache.h"

@interface factory ()<UITableViewDataSource,UITableViewDelegate>{
	NSMutableArray *_ms;
	UITableView *_table;
	NSInteger _offset;
	//NSMutableArray *_cellHeight;
}
@end

@implementation factory

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[_table headerBeginRefreshing];
}

- (void)pushEdit{
	factoryEdit *e = [[factoryEdit alloc]init];
	[self.navigationController pushViewController:e animated:YES];
}

- (void)pushUnbind{
	factoryUnbind *e = [[factoryUnbind alloc]init];
	[self.navigationController pushViewController:e animated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"入库管理";
	self.view.backgroundColor = BACKCOLOR;
	
	AJPopView *popView = [[AJPopView alloc]initInView:KEYWINDOW fromPoint:CGPointMake(270, 64+7)];
	popView.isFullscreen = YES;
	popView.animateType = AJPopViewAnimateTypeAlpha;
	popView.backgroundAlpha = 0.3;
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 0)];
	view.layer.masksToBounds = YES;
	view.layer.cornerRadius = 6;
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15, 44)];
	label.text = @"新建入库单";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	[label addGeWithType:GeLineTypeBottom color:COLORCCC];
	[label click:^(UIView *view, UIGestureRecognizer *sender) {
		NSMutableArray *datas = [@"scanDatas" getUserDefaultsArray];
		[popView close];
		factoryEdit *e = [[factoryEdit alloc]init];
		if (datas.isArray) {
			[self.navigationController pushViewController:e animated:YES];
		} else {
			[self.navigationController pushViewController:e animated:NO completion:^{
				factoryGoods *e2 = [[factoryGoods alloc]init];
				e2.delegate = (id<GlobalDelegate>)e;
				[e.navigationController pushViewController:e2 animated:YES];
			}];
		}
	}];
	label = [[UILabel alloc]initWithFrame:label.frameBottom];
	label.text = @"解绑标签";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	[label click:^(UIView *view, UIGestureRecognizer *sender) {
		[popView close];
		[self pushUnbind];
	}];
	view.height = label.bottom;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			NSInteger tag = 785623753;
			[[view viewWithTag:tag] removeFromSuperview];
			UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:view.bounds];
			toolbar.barStyle = UIBarStyleDefault;
			toolbar.tag = tag;
			[view insertSubview:toolbar atIndex:0];
		});
	});
	
	popView.view = view;
	
	UIButton *itemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
	itemBtn.backgroundColor = [UIColor clearColor];
	[itemBtn setBackgroundImage:IMG(@"plus") forState:UIControlStateNormal];
	[itemBtn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[popView show];
	}];
	[self.navigationItem setItemWithCustomView:itemBtn itemType:KKNavigationItemTypeRight];
	
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
	
	NSArray *scanDatas = [@"scanDatas" getUserDefaultsArray];
	//NSLog(@"%@", scanDatas.descriptionASCII);
	if (scanDatas.isArray && [scanDatas[0][@"scanDatas"]isset]) {
		[UIAlertView alert:@"检测到上一次未完成的入库操作，是否恢复？" block:^(NSInteger buttonIndex) {
			if (buttonIndex==1) {
				NSDictionary *d = [@"scanGoodsData" getUserDefaultsDictionary];
				factoryEdit *e = [[factoryEdit alloc]init];
				[self.navigationController pushViewController:e animated:NO completion:^{
					[e pushScanerWithIndex:[d[@"listIndex"]integerValue] data:d[@"goods"] type:[d[@"scanType"]integerValue] subType:[d[@"scanSubType"]integerValue]];
				}];
			} else {
				[self emptyHistory];
			}
		}];
	} else {
		[self emptyHistory];
	}
}

- (void)emptyHistory{
	[@"scanDatas" deleteUserDefaults];
	[@"scanGoodsData" deleteUserDefaults];
	[@"capacity" deleteUserDefaults];
	[@"capacity2" deleteUserDefaults];
}

#pragma mark - loadData
- (void)loadData{
	//[Global removeAllCacheObjects];
	_ms = [[NSMutableArray alloc]init];
	_offset = 0;
	[Common getApiWithParams:@{@"app":@"member", @"act":@"factory_order"} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([json[@"data"] isArray]) {
			NSArray *list = json[@"data"];
			list = [list UpyunSuffix:@"!small" forKeys:@[@"default_pic"]];
			for (int i=0; i<list.count; i++) {
				[_ms addObject:list[i]];
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
	[Common getApiWithParams:@{@"app":@"member", @"act":@"factory_order", @"offset":@(_offset)} success:^(NSMutableDictionary *json) {
		if ([json[@"data"] isArray]) {
			NSArray *list = json[@"data"];
			list = [list UpyunSuffix:@"!small" forKeys:@[@"default_pic"]];
			for (int i=0; i<list.count; i++) {
				[_ms addObject:list[i]];
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
	cell.backgroundColor = [UIColor whiteColor];
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width, 62)];
	view.backgroundColor = WHITE;
	[cell.contentView addSubview:view];
	
	UIImageView *pic = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 42, 42)];
	pic.image = IMG(@"nopic");
	[pic em_setImageWithURL:_ms[row][@"default_pic"]];
	[view addSubview:pic];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(pic.right+10, pic.top, view.width-(pic.right+10)-15, pic.height-15)];
	label.text = STRINGFORMAT(@"%@ (编号:%@)", _ms[row][@"name"], _ms[row][@"goods_id"]);
	label.textColor = [UIColor blackColor];
	label.font = FONT(13);
	label.backgroundColor = [UIColor clearColor];
	label.lineBreakMode = NSLineBreakByTruncatingMiddle;
	label.minimumScaleFactor = 0.8;
	label.adjustsFontSizeToFitWidth = YES;
	[view addSubview:label];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(label.left, pic.bottom-10, label.width, 10)];
	label.text = STRINGFORMAT(@"已扫描：%@", _ms[row][@"num"]);
	label.textColor = COLOR999;
	label.font = FONT(10);
	label.backgroundColor = [UIColor clearColor];
	label.tag = 99;
	[view addSubview:label];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(pic.right+10, pic.bottom-10, view.width-(pic.right+10)-15, 10)];
	label.text = _ms[row][@"add_time"];
	label.textColor = COLORCCC;
	label.textAlignment = NSTextAlignmentRight;
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
	[postData setValue:_ms[row][@"id"] forKey:@"id"];
	[Common postApiWithParams:@{@"app":@"member", @"act":@"factory_order_delete"} data:postData feedback:nil success:^(NSMutableDictionary *json) {
		[_ms removeObjectAtIndex:row];
		//[_cellHeight removeObjectAtIndex:row];
		if (_ms.count) {
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
			//[tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
		} else {
			[tableView reloadData];
		}
		if (completionHandler) completionHandler(YES);
	} fail:^(NSMutableDictionary *json) {
		if (completionHandler) completionHandler(YES);
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
