//
//  resellerSearch.m
//  yidian
//
//  Created by ajsong on 16/1/6.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "resellerSearch.h"
#import "resellerDetail.h"

@interface resellerSearch ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>{
	NSMutableArray *_ms;
	UITableView *_table;
	NSInteger _offset;
	UISearchBar *_search;
}
@end

@implementation resellerSearch

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = BACKCOLOR;
	
	_search = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
	_search.placeholder = @"输入渠道商名称/电话";
	_search.searchBarStyle = UISearchBarStyleMinimal;
	_search.delegate = self;
	[_search setImage:IMG(@"h-search-ico2") forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
	UITextField *searchField = [_search valueForKey:@"_searchField"];
	searchField.textColor = WHITE;
	[searchField setValue:WHITE forKeyPath:@"_placeholderLabel.textColor"];
	[self.navigationItem setItemWithCustomView:_search itemType:KKNavigationItemTypeCenter];
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"搜索" textColor:WHITE fontSize:14 itemType:KKNavigationItemTypeRight];
	item.offset = 0;
	item.contentBarItem.width = 38;
	[item addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
	
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
}

- (void)backgroundTap{
	[_search resignFirstResponder];
}

-(void)search{
	[self searchBarSearchButtonClicked:_search];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	[self backgroundTap];
	[_table headerBeginRefreshing];
}

#pragma mark - loadData
- (void)loadData{
	_ms = [[NSMutableArray alloc]init];
	_offset = 0;
	[Common getApiWithParams:@{@"app":@"eshop", @"act":@"resellers", @"keyword":_search.text} success:^(NSMutableDictionary *json) {
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
}

- (void)loadMore{
	[Common getApiWithParams:@{@"app":@"eshop", @"act":@"resellers", @"keyword":_search.text, @"offset":@(_offset)} success:^(NSMutableDictionary *json) {
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return tableView.height;
	return 57;
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
	
	if (_ms.count<=0 && _search.text.length) {
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
	
	NSString *string = STRINGFORMAT(@"下级渠道商 <p>%@</p>　订单数 <p>%@</p>　订单金额 <p>%@</p>", _ms[row][@"resellers"], _ms[row][@"orders"], _ms[row][@"total_income"]);
	NSDictionary *style = @{@"body":@[FONT(11), COLOR999], @"p":BLACK};
	label = [[UILabel alloc]initWithFrame:CGRectMake(label.left, label.bottom, label.width, avatar.height-label.height)];
	label.attributedText = [string attributedStyle:style];
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	return cell;
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return;
	NSInteger row = indexPath.row;
	resellerDetail *e = [[resellerDetail alloc]init];
	e.data = _ms[row];
	[self.navigationController pushViewController:e animated:YES];
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
