//
//  goods.m
//  yidian
//
//  Created by ajsong on 16/1/6.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "goods.h"
#import "goodsList.h"
#import "goodsSearch.h"
#import "scaner.h"
#import "shopOutlet.h"

#define TypeImageHeight 44
#define FirstRowHeight (15+(TypeImageHeight+20+10)*2)

@interface goods ()<UITableViewDataSource,UITableViewDelegate,KKNavigationControllerDelegate,OutletDelegate,GlobalDelegate>{
	NSMutableArray *_ms;
	UITableView *_table;
	NSInteger _offset;
	NSMutableArray *_cellHeight;
	
	NSMutableArray *_mt;
	BOOL _firstLoadImage;
}
@end

@implementation goods

- (void)navigationPushViewController:(KKNavigationController *)navigationController{
	[self.tabBarControllerKK setTabBarHidden:YES animated:YES];
}

- (void)navigationDidAppearFromPopAction:(KKNavigationController *)navigationController isGesture:(BOOL)flag{
	[self.tabBarControllerKK setTabBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"货源";
	self.view.backgroundColor = BACKCOLOR;
	[self.navigationController setBackgroundColor:NAVBGCOLOR textColor:NAVTEXTCOLOR];
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithImage:IMG(@"h-qrcode-ico") size:CGSizeMake(44, 44) itemType:KKNavigationItemTypeLeft];
	[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		scaner *e = [[scaner alloc]init];
		e.globalDelegate = self;
		[self.navigationController pushViewController:e animated:YES];
	}];
	
	item = [self.navigationItem setItemWithImage:IMG(@"h-search-ico") size:CGSizeMake(44, 44) itemType:KKNavigationItemTypeRight];
	[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		goodsSearch *e = [[goodsSearch alloc]init];
		[self.navigationController pushViewController:e animated:YES];
	}];
	
	_table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_table.estimatedSectionHeaderHeight = 0;
	_table.estimatedSectionFooterHeight = 0;
	_table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
	_table.separatorStyle = UITableViewCellSeparatorStyleNone;
	_table.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarControllerKK.tabBarHeight, 0);
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
	[Global removeAllCacheObjects];
	_mt = [[NSMutableArray alloc]init];
	_ms = [[NSMutableArray alloc]init];
	_cellHeight = [[NSMutableArray alloc]init];
	_offset = 0;
	[Common getApiWithParams:@{@"app":@"goods", @"act":@"index"} cachetime:3600*3 success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([json[@"data"][@"types"] isArray]) {
			NSArray *list = json[@"data"][@"types"];
			for (int i=0; i<list.count; i++) {
				[_mt addObject:list[i]];
			}
		}
		if ([json[@"data"][@"goods"] isArray]) {
			NSArray *list = json[@"data"][@"goods"];
			list = [list UpyunSuffix:@"!medium" forKeys:@[@"default_pic", @"pic"]];
			for (int i=0; i<list.count; i++) {
				[_ms addObject:list[i]];
				[_cellHeight addObject:@0];
				_offset++;
			}
		}
		//NSLog(@"%@", _mt);
		[self refreshTable];
	} fail:^(NSMutableDictionary *json) {
		[self refreshTable];
	}];
}

- (void)loadMore{
	[Common getApiWithParams:@{@"app":@"goods", @"act":@"index", @"offset":@(_offset)} success:^(NSMutableDictionary *json) {
		if ([json[@"data"][@"goods"] isArray]) {
			NSArray *list = json[@"data"][@"goods"];
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
	return !_ms.isArray ? 2 : _ms.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSInteger rows = indexPath.row;
	if (rows == 0) {
		return FirstRowHeight+8;
	}
	if (!_ms.isArray) return tableView.height-(FirstRowHeight+8)-tableView.contentInset.bottom;
	NSInteger row = rows - 1;
	if (IOS8) return [_cellHeight[row]floatValue];
	if ([_cellHeight[row]floatValue]==0) [self tableView:tableView cellForRowAtIndexPath:indexPath];
	return [_cellHeight[row]floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSInteger section = indexPath.section;
	NSInteger rows = indexPath.row;
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
	if (rows == 0) {
		for (UIView *subview in cell.contentView.subviews) {
			[subview removeFromSuperview];
		}
		
		NSString *imageKey = STRINGFORMAT(@"%@%ld%ld", [self class], (long)indexPath.section, (long)indexPath.row);
		UIView *view = [Global cacheObjectForKey:imageKey];
		if (view) {
			[cell.contentView addSubview:view];
			return cell;
		}
		
		view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width, FirstRowHeight)];
		view.backgroundColor = WHITE;
		view.clipsToBounds = YES;
		[cell.contentView addSubview:view];
		
		CGFloat g = floor((SCREEN_WIDTH-(TypeImageHeight*4)-20*2)/3);
		NSMutableArray *subviews = [[NSMutableArray alloc]init];
		for (int i=0; i<_mt.count; i++) {
			UIView *subview = [[UIView alloc]initWithFrame:CGRectMake(g, 10, TypeImageHeight, TypeImageHeight+20)];
			UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, TypeImageHeight, TypeImageHeight)];
			img.image = IMG(@"nopic");
			img.url = _mt[i][@"pic"];
			[subview addSubview:img];
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, img.bottom, subview.width, 20)];
			label.text = _mt[i][@"name"];
			label.textColor = [UIColor blackColor];
			label.textAlignment = NSTextAlignmentCenter;
			label.font = FONT(10);
			label.backgroundColor = [UIColor clearColor];
			[subview addSubview:label];
			[subview click:^(UIView *view, UIGestureRecognizer *sender) {
				goodsList *e = [[goodsList alloc]init];
				e.title = _mt[i][@"name"];
				e.type_id = _mt[i][@"id"];
				[self.navigationController pushViewController:e animated:YES];
			}];
			[subviews addObject:subview];
		}
		[view autoLayoutSubviews:subviews marginPT:15 marginPL:20 marginPR:0];
		
		[Global setCacheObject:view forKey:imageKey];
		return cell;
	}
	if (!_ms.count) {
		for (UIView *subview in cell.contentView.subviews) {
			[subview removeFromSuperview];
		}
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.width, tableView.height-(FirstRowHeight+8)-tableView.contentInset.bottom)];
		label.text = @"当前没有任何记录";
		label.textColor = COLOR999;
		label.textAlignment = NSTextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:14];
		label.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:label];
		return cell;
	}
	NSInteger row = rows - 1;
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
			img.tag = section*100+rows*10+i+1000;
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
	NSInteger section = indexPath.section;
	NSInteger rows = indexPath.row;
	if (rows == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
		_firstLoadImage = YES;
		dispatch_async(dispatch_get_main_queue(), ^{
			NSInteger row = rows - 1;
			if ([_ms[row][@"pics"] isArray]) {
				NSArray *list = _ms[row][@"pics"];
				for (int i=0; i<list.count; i++) {
					UIImageView *img = (UIImageView*)[_table viewWithTag:section*100+rows*10+i+1000];
					img.url = list[i][@"pic"];
				}
			}
		});
	}
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray || indexPath.row==0) return;
	NSInteger section = indexPath.section;
	NSInteger rows = indexPath.row;
	NSInteger row = rows - 1;
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
		NSInteger rows = indexPath.row;
		if (rows==0) continue;
		NSInteger row = rows - 1;
		if ([_ms[row][@"pics"] isArray]) {
			NSArray *list = _ms[row][@"pics"];
			for (int i=0; i<list.count; i++) {
				UIImageView *img = (UIImageView*)[_table viewWithTag:section*100+rows*10+i+1000];
				img.url = list[i][@"pic"];
			}
		}
	}
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
	_mt = [[NSMutableArray alloc]init];
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
