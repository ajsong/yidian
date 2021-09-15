//
//  reseller.m
//  yidian
//
//  Created by ajsong on 16/1/6.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "reseller.h"
#import "shopVerify.h"
#import "resellerSearch.h"
#import "resellerDetail.h"

@interface reseller ()<UITableViewDataSource,UITableViewDelegate,SimpleSwitchViewDelegate>{
	NSMutableArray *_ms;
	UITableView *_table;
	NSInteger _offset;
	//NSMutableArray *_cellHeight;
	NSString *_type;
	ShareHelper *_shareView;
}
@end

@implementation reseller

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"渠道商管理";
	self.view.backgroundColor = BACKCOLOR;
	
	_type = @"";
	_shareView = [[ShareHelper alloc]init];
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"查找" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		resellerSearch *e = [[resellerSearch alloc]init];
		[self.navigationController pushViewController:e animated:YES];
	}];
	
	SimpleSwitchView *switchView = [[SimpleSwitchView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
	switchView.backgroundColor = WHITE;
	switchView.nameArray = @[@"最新", @"渠道商数", @"订单数", @"订单金额"];
	switchView.valueArray = @[@"s.id", @"resellers", @"orders", @"total_income"];
	switchView.textColor = COLOR777;
	switchView.selectedTextColor = MAINCOLOR;
	switchView.selectedBgColor = COLORRGB(@"e5e5e5");
	switchView.font = FONT(13);
	switchView.delegate = self;
	[self.view addSubview:switchView];
	
	_table = [[UITableView alloc]initWithFrame:CGRectMake(0, switchView.height, SCREEN_WIDTH, self.height-switchView.height)];
	_table.estimatedSectionHeaderHeight = 0;
	_table.estimatedSectionFooterHeight = 0;
	_table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
	//_table.separatorStyle = UITableViewCellSeparatorStyleNone;
	_table.contentInset = UIEdgeInsetsMake(8, 0, 42, 0);
	_table.backgroundColor = [UIColor clearColor];
	_table.dataSource = self;
	_table.delegate = self;
	[_table addHeaderWithTarget:self action:@selector(tableViewRefresh)];
	[_table addFooterWithTarget:self action:@selector(tableViewLoadMore)];
	[self.view addSubview:_table];
	[_table headerBeginRefreshing];
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, self.height-42, SCREEN_WIDTH, 42)];
	[self.view addSubview:view];
	CGFloat width = view.width;
	if ([PERSON[@"member_type"]intValue]==3) width = view.width/2;
	
	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, view.height)];
	btn.titleLabel.font = FONT(15);
	btn.backgroundColor = COLORRGB(@"ff788a");
	[btn setTitle:@"邀请" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		_shareView.title = STRINGFORMAT(@"邀请您成为【%@】的优必上渠道商", PERSON[@"shop"][@"name"]);
		_shareView.image = IMG(@"AppIcon60x60");
		_shareView.url = STRINGFORMAT(@"%@/wap.php?tpl=invite.code&code=%@", API_URL, PERSON[@"shop"][@"id"]);
		[_shareView show];
	}];
	[view addSubview:btn];
	
	if ([PERSON[@"member_type"]intValue]==3) {
		btn = [[UIButton alloc]initWithFrame:CGRectMake(btn.right, 0, btn.width, view.height)];
		btn.titleLabel.font = FONT(15);
		btn.backgroundColor = COLORRGB(@"ffb478");
		[btn setTitle:@"审核" forState:UIControlStateNormal];
		[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
			shopVerify *e = [[shopVerify alloc]init];
			[self.navigationController pushViewController:e animated:YES];
		}];
		[view addSubview:btn];
		if ([@"index_notify" getUserDefaultsInt]>0) {
			NSString *notify = [@"index_notify" getUserDefaultsString];
			CGSize s = [notify autoWidth:FONT(11) height:16];
			s.width += 4.5*2;
			UILabel *dot = [[UILabel alloc]initWithFrame:CGRectMake(btn.left+btn.width/2+20, 5, s.width, 16)];
			dot.text = notify;
			dot.textColor = WHITE;
			dot.textAlignment = NSTextAlignmentCenter;
			dot.font = FONT(11);
			dot.backgroundColor = COLORRGB(@"ea0617");
			dot.layer.masksToBounds = YES;
			dot.layer.cornerRadius = dot.height/2;
			[view addSubview:dot];
		}
	}
}

- (void)SimpleSwitchView:(SimpleSwitchView *)simpleSwitchView didSelectAtIndex:(NSInteger)index value:(NSString *)value{
	_type = value;
	[_table headerBeginRefreshing];
}

#pragma mark - loadData
- (void)loadData{
	_ms = [[NSMutableArray alloc]init];
	//_cellHeight = [[NSMutableArray alloc]init];
	_offset = 0;
	[Common getApiWithParams:@{@"app":@"eshop", @"act":@"resellers", @"orderby":_type} success:^(NSMutableDictionary *json) {
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
	[Common getApiWithParams:@{@"app":@"eshop", @"act":@"resellers", @"orderby":_type, @"offset":@(_offset)} success:^(NSMutableDictionary *json) {
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
	if (!_ms.isArray) return tableView.height-8;
	return 57;
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
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.width, tableView.height-8)];
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
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width, 57)];
	view.backgroundColor = WHITE;
	[cell.contentView addSubview:view];
	
	UIImageView *avatar = [[UIImageView alloc]initWithFrame:CGRectMake(17, (view.height-40)/2, 40, 40)];
	avatar.image = IMG(@"avatar");
	avatar.url = _ms[row][@"avatar"];
	avatar.layer.masksToBounds = YES;
	avatar.layer.cornerRadius = avatar.height/2;
	[view addSubview:avatar];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(avatar.right+5, avatar.top, view.width-(avatar.right+5), 27)];
	label.text = _ms[row][@"member_name"];
	label.textColor = [UIColor blackColor];
	label.font = FONTBOLD(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	NSString *factory = @"";
	if ([PERSON[@"member_type"]intValue]==2) factory = STRINGFORMAT(@"厂家 <p>%@</p>　", _ms[row][@"factory_shop_name"]);
	NSString *string = STRINGFORMAT(@"%@订单数 <p>%@</p>　下级渠道商 <p>%@</p>", factory, _ms[row][@"orders"], _ms[row][@"resellers"]);
	NSDictionary *style = @{@"body":@[FONT(11), COLOR999], @"p":BLACK};
	label = [[UILabel alloc]initWithFrame:CGRectMake(label.left, label.bottom, label.width, avatar.height-label.height)];
	label.attributedText = [string attributedStyle:style];
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
	resellerDetail *e = [[resellerDetail alloc]init];
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
