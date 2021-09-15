//
//  goodsSearch.m
//  yidian
//
//  Created by ajsong on 16/1/6.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "goodsSearch.h"
#import "shopOutlet.h"

#define TypeImageHeight 44
#define FirstRowHeight (15+(TypeImageHeight+20+10)*2)

@interface goodsSearch ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,OutletDelegate>{
	NSMutableArray *_ms;
	UITableView *_table;
	NSInteger _offset;
	NSMutableArray *_cellHeight;
	UISearchBar *_search;
	
	BOOL _firstLoadImage;
}
@end

@implementation goodsSearch

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = BACKCOLOR;
	
	_search = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
	_search.placeholder = @"请输入商品关键字";
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
	_table.separatorStyle = UITableViewCellSeparatorStyleNone;
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
	[Global removeAllCacheObjects];
	_ms = [[NSMutableArray alloc]init];
	_cellHeight = [[NSMutableArray alloc]init];
	_offset = 0;
	[Common getApiWithParams:@{@"app":@"goods", @"act":@"search", @"keyword":_search.text, @"offset":@(_offset)} success:^(NSMutableDictionary *json) {
		if ([Global isArray:json[@"data"]]) {
			NSArray *list = json[@"data"];
			list = [list UpyunSuffix:@"!medium" forKeys:@[@"default_pic", @"pic"]];
			for (int i=0; i<list.count; i++) {
				[_ms addObject:list[i]];
				[_cellHeight addObject:@0];
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
	[Common getApiWithParams:@{@"app":@"goods", @"act":@"search", @"keyword":_search.text, @"offset":@(_offset)} success:^(NSMutableDictionary *json) {
		if ([Global isArray:json[@"data"]]) {
			NSArray *list = json[@"data"];
			list = [list UpyunSuffix:@"!medium" forKeys:@[@"default_pic", @"pic"]];
			for (int i=0; i<list.count; i++) {
				[_ms addObject:list[i]];
				[_cellHeight addObject:@0];
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
	NSInteger row = indexPath.row;
	if (IOS8) return [_cellHeight[row]floatValue];
	if ([_cellHeight[row]floatValue]==0) [self tableView:tableView cellForRowAtIndexPath:indexPath];
	return [_cellHeight[row]floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	cell.textLabel.font = [UIFont systemFontOfSize:14.f];
	cell.backgroundColor = [UIColor clearColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
	
	NSString *imageKey = STRINGFORMAT(@"%@%ld%ld", [self class], (long)indexPath.section, (long)indexPath.row);
	UIView *viewer = [Global cacheObjectForKey:imageKey];
	if (viewer) {
		[cell.contentView addSubview:viewer];
		return cell;
	}
	
	viewer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width, 0)];
	viewer.backgroundColor = WHITE;
	[cell.contentView addSubview:viewer];
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10, 10, viewer.width-10, 40)];
	[viewer addSubview:view];
	
	UIImageView *avatar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
	avatar.image = IMG(@"avatar");
	avatar.url = _ms[row][@"shop_avatar"];
	avatar.layer.masksToBounds = YES;
	avatar.layer.cornerRadius = 20;
	[view addSubview:avatar];
	
	UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(avatar.right+10, 0, view.width-(avatar.right+10), 24)];
	name.text = _ms[row][@"shop_name"];
	name.textColor = [UIColor blackColor];
	name.font = [UIFont systemFontOfSize:13];
	name.backgroundColor = [UIColor clearColor];
	[view addSubview:name];
	
	UILabel *time = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.width-10, name.height)];
	time.text = _ms[row][@"add_time"];
	time.textColor = COLOR666;
	time.textAlignment = NSTextAlignmentRight;
	time.font = [UIFont systemFontOfSize:12];
	time.backgroundColor = [UIColor clearColor];
	[view addSubview:time];
	
	UILabel *address = [[UILabel alloc]initWithFrame:CGRectMake(name.left, name.bottom, name.width, 15)];
	address.text = STRINGFORMAT(@"地址：%@%@", [AreaPickerView comboWithProvince:_ms[row][@"province"] city:_ms[row][@"city"] district:_ms[row][@"district"]], _ms[row][@"address"]);
	address.textColor = COLOR666;
	address.font = [UIFont systemFontOfSize:11];
	address.backgroundColor = [UIColor clearColor];
	[view addSubview:address];
	
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		shopOutlet *e = [[shopOutlet alloc]init];
		e.url = STRINGFORMAT(@"%@/wap.php?app=eshop&act=other_shop_index&shop_id=%@", API_URL, _ms[row][@"shop_id"]);
		[self.navigationController pushViewController:e animated:YES];
	}];
	
	UIView *ge = [[UIView alloc]initWithFrame:CGRectMake(view.left, view.bottom+10, view.width, 1.5)];
	ge.backgroundColor = BACKCOLOR;
	[viewer addSubview:ge];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(10, ge.bottom+10, viewer.width-10*2, 0)];
	[viewer addSubview:view];
	
	NSString *string = _ms[row][@"name"];
	CGSize s = [string autoHeight:name.font width:view.width];
	UILabel *content = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.width, 0)];
	content.text = string;
	content.textColor = BLACK;
	content.font = name.font;
	content.backgroundColor = [UIColor clearColor];
	content.numberOfLines = 2;
	[view addSubview:content];
	[content autoHeight];
	
	UIView *imgView = [[UIView alloc]initWithFrame:CGRectMake(0, content.bottom+13, view.width, 0)];
	[view addSubview:imgView];
	
	if ([_ms[row][@"pics"] isArray]) {
		NSArray *list = _ms[row][@"pics"];
		CGFloat w = 0;
		switch (list.count) {
			case 1:{
				w = view.width;
				break;
			}
			case 2:{
				w = (view.width-10) / 2;
				break;
			}
			default:{
				w = (view.width-10*2) / 3;
				break;
			}
		}
		NSMutableArray *subviews = [[NSMutableArray alloc]init];
		for (int i=0; i<list.count; i++) {
			UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, w, w)];
			img.indicator = YES;
			//img.url = list[i][@"pic"];
			img.tag = section*100+row*10+i+1000;
			[subviews addObject:img];
		}
		[imgView autoLayoutSubviews:subviews marginPT:0 marginPL:0 marginPR:0];
		imgView.height = imgView.lastSubview.bottom;
	}
	
	UIFont *font = [UIFont systemFontOfSize:11];
	UIView *infoView = [[UIView alloc]initWithFrame:CGRectMake(0, imgView.bottom+15, view.width/4, 40)];
	[view addSubview:infoView];
	UILabel *infoName = [[UILabel alloc]initWithFrame:CGRectMake(0, 7, infoView.width, 14)];
	infoName.text = @"价格";
	infoName.textColor = COLOR666;
	infoName.textAlignment = NSTextAlignmentCenter;
	infoName.font = font;
	infoName.backgroundColor = [UIColor clearColor];
	[infoView addSubview:infoName];
	UILabel *infoValue = [[UILabel alloc]initWithFrame:CGRectMake(0, infoName.bottom, infoView.width, 14)];
	infoValue.text = STRINGFORMAT(@"￥%.2f", [_ms[row][@"price"]floatValue]);
	infoValue.textColor = COLORCCC;
	infoValue.textAlignment = NSTextAlignmentCenter;
	infoValue.font = font;
	infoValue.backgroundColor = [UIColor clearColor];
	[infoView addSubview:infoValue];
	ge = [[UIView alloc]initWithFrame:CGRectMake(infoView.width, 0, 0.5, infoView.height)];
	ge.backgroundColor = COLOR_GE;
	[infoView addSubview:ge];
	
	infoView = [[UIView alloc]initWithFrame:CGRectMake(infoView.right, infoView.top, infoView.width, infoView.height)];
	[view addSubview:infoView];
	infoName = [[UILabel alloc]initWithFrame:infoName.frame];
	infoName.text = @"促销价";
	infoName.textColor = COLOR666;
	infoName.textAlignment = NSTextAlignmentCenter;
	infoName.font = font;
	infoName.backgroundColor = [UIColor clearColor];
	[infoView addSubview:infoName];
	infoValue = [[UILabel alloc]initWithFrame:infoValue.frame];
	if ([_ms[row][@"special_price"]floatValue]>0) {
		infoValue.text = STRINGFORMAT(@"￥%.2f", [_ms[row][@"special_price"]floatValue]);
		infoValue.textColor = MAINSUBCOLOR;
	} else {
		infoValue.text = @"-";
		infoValue.textColor = COLORCCC;
	}
	infoValue.textAlignment = NSTextAlignmentCenter;
	infoValue.font = font;
	infoValue.backgroundColor = [UIColor clearColor];
	[infoView addSubview:infoValue];
	ge = [[UIView alloc]initWithFrame:ge.frame];
	ge.backgroundColor = COLOR_GE;
	[infoView addSubview:ge];
	
	infoView = [[UIView alloc]initWithFrame:CGRectMake(infoView.right, infoView.top, infoView.width, infoView.height)];
	[view addSubview:infoView];
	infoName = [[UILabel alloc]initWithFrame:infoName.frame];
	infoName.text = @"销量";
	infoName.textColor = COLOR666;
	infoName.textAlignment = NSTextAlignmentCenter;
	infoName.font = font;
	infoName.backgroundColor = [UIColor clearColor];
	[infoView addSubview:infoName];
	infoValue = [[UILabel alloc]initWithFrame:infoValue.frame];
	infoValue.text = _ms[row][@"sales"];
	infoValue.textColor = COLORCCC;
	infoValue.textAlignment = NSTextAlignmentCenter;
	infoValue.font = font;
	infoValue.backgroundColor = [UIColor clearColor];
	[infoView addSubview:infoValue];
	ge = [[UIView alloc]initWithFrame:ge.frame];
	ge.backgroundColor = COLOR_GE;
	[infoView addSubview:ge];
	
	infoView = [[UIView alloc]initWithFrame:CGRectMake(infoView.right, infoView.top, infoView.width, infoView.height)];
	[view addSubview:infoView];
	infoName = [[UILabel alloc]initWithFrame:infoName.frame];
	infoName.text = @"人气";
	infoName.textColor = COLOR666;
	infoName.textAlignment = NSTextAlignmentCenter;
	infoName.font = font;
	infoName.backgroundColor = [UIColor clearColor];
	[infoView addSubview:infoName];
	infoValue = [[UILabel alloc]initWithFrame:infoValue.frame];
	infoValue.text = _ms[row][@"clicks"];
	infoValue.textColor = COLORCCC;
	infoValue.textAlignment = NSTextAlignmentCenter;
	infoValue.font = font;
	infoValue.backgroundColor = [UIColor clearColor];
	[infoView addSubview:infoValue];
	
	view.height = infoView.bottom + 12;
	viewer.height = view.bottom;
	
	[_cellHeight replaceObjectAtIndex:row withObject:@(viewer.bottom+10)];
	[Global setCacheObject:viewer forKey:imageKey];
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray || indexPath.row==0) return;
	if (tableView.dragging || tableView.decelerating || _firstLoadImage) return;
	NSInteger rows = indexPath.row;
	NSArray *indexPaths = [_table indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in indexPaths) {
		NSInteger section = indexPath.section;
		NSInteger row = indexPath.row;
		if (row == rows){
			dispatch_async(dispatch_get_main_queue(), ^{
				if ([_ms[row][@"pics"] isArray]) {
					NSArray *list = _ms[row][@"pics"];
					for (int i=0; i<list.count; i++) {
						UIImageView *img = (UIImageView*)[_table viewWithTag:section*100+row*10+i+1000];
						img.url = list[i][@"pic"];
					}
				}
			});
		}
		if (rows == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row) _firstLoadImage = YES;
	}
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return;
	NSInteger row = indexPath.row;
	shopOutlet *e = [[shopOutlet alloc]init];
	e.url = STRINGFORMAT(@"%@/wap.php?app=goods&act=detail&goods_id=%@", API_URL, _ms[row][@"id"]);
	[self.navigationController pushViewController:e animated:YES];
}
#pragma mark -

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (!decelerate) {
		[self loadImagesForVisibleRows];
	}
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	[self loadImagesForVisibleRows];
}
- (void)loadImagesForVisibleRows{
	if (!_ms.isArray) return;
	NSArray *indexPaths = [_table indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in indexPaths) {
		NSInteger section = indexPath.section;
		NSInteger row = indexPath.row;
		if ([_ms[row][@"pics"] isArray]) {
			NSArray *list = _ms[row][@"pics"];
			for (int i=0; i<list.count; i++) {
				UIImageView *img = (UIImageView*)[_table viewWithTag:section*100+row*10+i+1000];
				img.url = list[i][@"pic"];
			}
		}
	}
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
