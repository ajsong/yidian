//
//  orderList.m
//  syoker
//
//  Created by ajsong on 15/4/10.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import "orderList.h"
#import "orderDetail.h"
#import "orderShipping.h"

@interface orderList ()<UITableViewDataSource,UITableViewDelegate,KKNavigationControllerDelegate>{
	NSMutableDictionary *_person;
	NSMutableArray *_ms;
	NSMutableArray *_cellHeight;
	UITableView *_table;
	NSInteger _offset;
	
	CGFloat _h;
	NSInteger _originPersonID;
	BOOL _firstLoadImage;
}
@end

@implementation orderList

- (void)navigationPushViewController:(KKNavigationController *)navigationController{
	if (self.navigationController.viewControllers.count==1) [self.tabBarControllerKK setTabBarHidden:YES animated:YES];
}

- (void)navigationDidAppearFromPopAction:(KKNavigationController *)navigationController isGesture:(BOOL)flag{
	if (self.navigationController.viewControllers.count==1) [self.tabBarControllerKK setTabBarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	_person = PERSON;
	if (_table && _person.isDictionary && _originPersonID!=[_person[@"id"]integerValue]) [_table headerBeginRefreshing];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = BACKCOLOR;
	
	_person = PERSON;
	if (!_status) _status = @"";
	_cellHeight = [[NSMutableArray alloc]init];
	if (_person.isDictionary) _originPersonID = [_person[@"id"]integerValue];
	
	[self performSelector:@selector(loadViews) withObject:nil afterDelay:0];
}

- (void)loadViews{
	_h = 0;
	if (self.view.parentViewController.navigationController.viewControllers.count==1) {
		_h = self.view.parentViewController.tabBarControllerKK.tabBarHeight;
	}
	_table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.height)];
	_table.estimatedSectionHeaderHeight = 0;
	_table.estimatedSectionFooterHeight = 0;
	_table.contentInset = UIEdgeInsetsMake(0, 0, _h, 0);
	_table.separatorStyle = UITableViewCellSeparatorStyleNone;
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
	_firstLoadImage = NO;
	_ms = [[NSMutableArray alloc]init];
	[_cellHeight removeAllObjects];
	_offset = 0;
	[Common getApiWithParams:@{@"app":@"shop_order", @"act":@"index", @"status":_status} feedback:@"nomsg" success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([Global isArray:json[@"data"]]) {
			NSArray *list = json[@"data"];
			list = [list UpyunSuffix:@"!small" forKeys:@[@"goods_pic"]];
			for (int i=0; i<list.count; i++) {
				[_ms addObject:list[i]];
				[_cellHeight addObject:@0];
				_offset++;
			}
		}
		//NSLog(@"%@", _ms.descriptionASCII);
		[self refreshTable];
	} fail:^(NSMutableDictionary *json) {
		[self refreshTable];
	}];
}

- (void)loadMore{
	[Common getApiWithParams:@{@"app":@"shop_order", @"act":@"index", @"status":_status, @"offset":@(_offset)} feedback:@"nomsg" success:^(NSMutableDictionary *json) {
		if ([Global isArray:json[@"data"]]) {
			NSArray *list = json[@"data"];
			list = [list UpyunSuffix:@"!small" forKeys:@[@"goods_pic"]];
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
	if (!_ms.isArray) return tableView.height-_h;
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
	cell.backgroundColor = [UIColor clearColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	//cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
	//cell.selectedBackgroundView.backgroundColor = [UIColor blackColor];
	
	if (!_ms) return cell;
	if (_ms.count<=0) {
		for (UIView *subview in cell.contentView.subviews) {
			[subview removeFromSuperview];
		}
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.width, tableView.height-_h)];
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
	
	//NSString *imageKey = STRINGFORMAT(@"%@%ld%ld", self.class, (long)indexPath.section, (long)indexPath.row);
	//UIView *view = [Global cacheObjectForKey:imageKey];
	//if (view) {
	//	[cell.contentView addSubview:view];
	//	return cell;
	//}
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-10*2, 0)];
	view.backgroundColor = WHITE;
	view.layer.borderColor = COLOR_GE.CGColor;
	view.layer.borderWidth = 0.5;
	view.layer.masksToBounds = YES;
	view.layer.cornerRadius = 3;
	[cell.contentView addSubview:view];
	
	NSInteger orderstatus = [_ms[row][@"status"]integerValue];
	
	UIView *ce = [[UIView alloc]initWithFrame:CGRectMake(9, 0, view.width-9*2, 40)];
	[view addSubview:ce];
	
	NSString *string = [self statusName:orderstatus];
	CGSize s = [string autoWidth:FONT(15) height:40];
	UILabel *status = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, s.width, 40)];
	status.text = string;
	status.textColor = [self statusColor:orderstatus];
	status.font = FONT(14);
	status.backgroundColor = [UIColor clearColor];
	[ce addSubview:status];
	
	if (orderstatus>0 && [_ms[row][@"ask_refund_time"]integerValue]>0) {
		string = @"(退货退款中)";
		s = [string autoWidth:FONT(12) height:40];
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(status.right+5, 0, s.width, 40)];
		label.text = string;
		label.textColor = COLOR999;
		label.font = FONT(12);
		label.backgroundColor = [UIColor clearColor];
		[ce addSubview:label];
	}
	
	string = STRINGFORMAT(@"订单号：%@", _ms[row][@"order_sn"]);
	s = [string autoWidth:FONT(11) height:40];
	UILabel *no = [[UILabel alloc]initWithFrame:CGRectMake(ce.width-s.width, 0, s.width, 40)];
	no.text = string;
	no.textColor = COLORRGB(@"666");
	no.font = FONT(11);
	no.backgroundColor = [UIColor clearColor];
	[ce addSubview:no];
	UIView *ge = [[UIView alloc]initWithFrame:CGRectMake(0, ce.height-0.5, ce.width, 0.5)];
	ge.backgroundColor = COLORRGB(@"e5e5e5");
	[ce addSubview:ge];
	
	if ([_ms[row][@"readed"]intValue]==0) {
		UIImageView *new = [[UIImageView alloc]initWithFrame:CGRectMake(view.width-16-8, 0, 16, 14)];
		new.image = IMG(@"o-new");
		new.tag = 55;
		[view addSubview:new];
	}
	
	if ([_person[@"member_type"]integerValue]==3 && [_ms[row][@"shop_id"]integerValue]!=[_ms[row][@"factory_shop_id"]integerValue]) {
		ce = [[UIView alloc]initWithFrame:CGRectMake(9, ce.bottom, view.width-9*2, 30)];
		[view addSubview:ce];
		UILabel *label = [[UILabel alloc]initWithFrame:ce.bounds];
		label.text = STRINGFORMAT(@"%@(ID:%@)", _ms[row][@"shop_name"], _ms[row][@"shop_id"]);
		label.textColor = [UIColor blackColor];
		label.textAlignment = NSTextAlignmentRight;
		label.font = FONT(13);
		label.backgroundColor = [UIColor clearColor];
		[ce addSubview:label];
		ge = [[UIView alloc]initWithFrame:CGRectMake(0, ce.height-0.5, ce.width, 0.5)];
		ge.backgroundColor = COLORRGB(@"e5e5e5");
		[ce addSubview:ge];
	}
	
	CGFloat bottom = ce.bottom;
	if ([_ms[row][@"goods"] isArray]) {
		NSArray *prolist = _ms[row][@"goods"];
		for (int i=0; i<prolist.count; i++) {
			ce = [[UIView alloc]initWithFrame:CGRectMake(ce.left, bottom, ce.width, 86)];
			[view addSubview:ce];
			
			UIImageView *pic = [[UIImageView alloc]initWithFrame:CGRectMake(0, (ce.height-60)/2, 60, 60)];
			pic.indicator = YES;
			//pic.url = prolist[i][@"goods_pic"];
			pic.layer.borderColor = COLOR_GE.CGColor;
			pic.layer.borderWidth = 0.5;
			pic.tag = section*100+row*10+i+1000;
			[ce addSubview:pic];
			
			SpecialLabel *title = [[SpecialLabel alloc]initWithFrame:CGRectMake(pic.right+8, pic.top, ce.width-pic.right-8-65, pic.height-15)];
			title.text = [prolist[i][@"goods_name"] trim];
			title.textColor = COLORRGB(@"333");
			title.font = [UIFont systemFontOfSize:13];
			title.backgroundColor = [UIColor clearColor];
			title.numberOfLines = 2;
			[ce addSubview:title];
			title.verticalAlignment = VerticalAlignmentTop;
			
			CGSize s;
			CGFloat x = title.left;
			CGFloat y = pic.bottom - 15;
			if (![prolist[i][@"spec"] isEqualToString:@""]) {
				s = [Global autoWidth:STRINGFORMAT(@"规格：%@", prolist[i][@"spec"]) font:[UIFont systemFontOfSize:12] height:15];
				UILabel *color = [[UILabel alloc]initWithFrame:CGRectMake(x, y, s.width, 15)];
				color.text = STRINGFORMAT(@"规格:%@", prolist[i][@"spec"]);
				color.textColor = COLOR999;
				color.font = [UIFont systemFontOfSize:12];
				color.backgroundColor = [UIColor clearColor];
				[ce addSubview:color];
				x = color.right + 10;
			}
			
			UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(ce.width-65, title.top, 65, 15)];
			price.text = STRINGFORMAT(@"￥%.2f", [prolist[i][@"price"]floatValue]);
			price.textColor = COLORRGB(@"333");
			price.textAlignment = NSTextAlignmentRight;
			price.font = [UIFont systemFontOfSize:13];
			price.backgroundColor = [UIColor clearColor];
			[ce addSubview:price];
			
			if ([prolist[i][@"quantity"]integerValue]>0) {
				UILabel *quantity = [[UILabel alloc]initWithFrame:CGRectMake(price.left, price.bottom, price.width, 15)];
				quantity.text = STRINGFORMAT(@"× %@", prolist[i][@"quantity"]);
				quantity.textColor = COLOR999;
				quantity.textAlignment = NSTextAlignmentRight;
				quantity.font = [UIFont systemFontOfSize:12];
				quantity.backgroundColor = [UIColor clearColor];
				[ce addSubview:quantity];
			}
			
			ge = [[UIView alloc]initWithFrame:CGRectMake(0, ce.height-0.5, ce.width, 0.5)];
			ge.backgroundColor = COLORRGB(@"e5e5e5");
			[ce addSubview:ge];
			
			bottom = ce.bottom;
		}
	}
	
	ce = [[UIView alloc]initWithFrame:CGRectMake(ce.left, bottom, ge.width, 40)];
	[view addSubview:ce];
	NSString *fanli = @"";
	if ([_person[@"member_type"]integerValue]==3) fanli = STRINGFORMAT(@"　分利: ￥-%.2f", [_ms[row][@"commission_total_money"]floatValue]);
	UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ce.width, ce.height)];
	price.text = STRINGFORMAT(@"总计: ￥%.2f%@", [_ms[row][@"total_price"]floatValue], fanli);
	price.textColor = COLORRGB(@"8d8d8d");
	price.font = [UIFont systemFontOfSize:12];
	price.backgroundColor = [UIColor clearColor];
	[ce addSubview:price];
	
	if (orderstatus==1 && [_person[@"member_type"]integerValue]==3) {
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.frame = CGRectMake(ce.width-70, (ce.height-25)/2, 70, 25);
		btn.titleLabel.font = [UIFont systemFontOfSize:13];
		btn.backgroundColor = MAINSUBCOLOR;
		[btn setTitleColor:WHITE forState:UIControlStateNormal];
		btn.layer.masksToBounds = YES;
		btn.layer.cornerRadius = 3;
		btn.tag = 100 + row;
		[btn setTitle:@"扫码发货" forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(shipping:) forControlEvents:UIControlEventTouchUpInside];
		[ce addSubview:btn];
	}
	
	view.height = ce.bottom;
	
	CGFloat h = row==_ms.count-1 ? view.bottom+10 : view.bottom;
	[_cellHeight replaceObjectAtIndex:row withObject:@(h)];
	//[Global setCacheObject:view forKey:imageKey];
	
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[[view viewWithTag:55] removeFromSuperview];
		orderDetail *e = [[orderDetail alloc]init];
		e.data = _ms[row];
		UINavigationController *nav = self.navigationController;
		if (!nav) nav = self.view.parentViewController.navigationController;
		[nav pushViewController:e animated:YES];
	}];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return;
	if (tableView.dragging || tableView.decelerating || _firstLoadImage) return;
	NSInteger rows = indexPath.row;
	NSArray *indexPaths = [_table indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in indexPaths) {
		NSInteger section = indexPath.section;
		NSInteger row = indexPath.row;
		if (row == rows){
			dispatch_async(dispatch_get_main_queue(), ^{
				if ([_ms[row][@"goods"] isArray]) {
					NSArray *list = _ms[row][@"goods"];
					for (int i=0; i<list.count; i++) {
						UIImageView *img = (UIImageView*)[_table viewWithTag:section*100+row*10+i+1000];
						img.url = list[i][@"goods_pic"];
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
	/*
	NSString *imageKey = STRINGFORMAT(@"%@%ld%ld", self.class, (long)indexPath.section, (long)indexPath.row);
	UIView *view = [Global cacheObjectForKey:imageKey];
	if (view) {
		[[view viewWithTag:55] removeFromSuperview];
		[Global setCacheObject:view forKey:imageKey];
	}
	NSInteger row = indexPath.row;
	orderDetail *e = [[orderDetail alloc]init];
	e.data = _ms[row];
	UINavigationController *nav = self.navigationController;
	if (!nav) nav = self.view.parentViewController.navigationController;
	[nav pushViewController:e animated:YES];
	 */
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
		if ([_ms[row][@"goods"] isArray]) {
			NSArray *list = _ms[row][@"goods"];
			for (int i=0; i<list.count; i++) {
				UIImageView *img = (UIImageView*)[_table viewWithTag:section*100+row*10+i+1000];
				img.url = list[i][@"goods_pic"];
			}
		}
	}
}

- (void)shipping:(UIButton*)sender{
	NSInteger row = sender.tag - 100;
	orderShipping *e = [[orderShipping alloc]init];
	e.data = _ms[row];
	[self.view.parentViewController.navigationController pushViewController:e animated:YES];
}

- (void)getTrans:(UIButton*)sender{
	NSInteger row = sender.tag - 100;
//	orderTrans *g = [[orderTrans alloc]init];
//	g.url = STRINGFORMAT(@"http://m.kuaidi100.com/index_all.html?type=%@&postid=%@", [_ms[row][@"shipping_company"] URLEncode], _ms[row][@"shipping_number"]);
//	[self.view.parentViewController.navigationController pushViewController:g animated:YES];
}

- (UIColor*)statusColor:(NSInteger)status{
	UIColor *color = COLOR999;
	switch (status) {
		case 0:{
			color = MAINSUBCOLOR;
			break;
		}
		case 1:{
			color = ORANGE;
			break;
		}
		case 2:{
			color = BLUE;
			break;
		}
		case 3:
		case 4:{
			color = GREEN;
			break;
		}
	}
	return color;
}

- (NSString*)statusName:(NSInteger)status{
	NSString *name = @"";
	switch (status) {
		case -3:{
			name = @"已退货";
			break;
		}
		case -2:{
			name = @"已退款";
			break;
		}
		case -1:{
			name = @"取消";
			break;
		}
		case 0:{
			name = @"未支付";
			break;
		}
		case 1:{
			name = @"未发货";
			break;
		}
		case 2:{
			name = @"已发货";
			break;
		}
		case 3:
		case 4:{
			name = @"完成";
			break;
		}
	}
	return name;
}

#pragma mark - Refresh and load more methods
- (void)refreshTable {
	[_table headerEndRefreshing];
	[_table reloadData];
	if (_table.footer) {
		_table.footerHidden = _ms.count<=0;
		[self performSelector:@selector(footerHandle) withObject:nil afterDelay:0.1];
	}
}
- (void)footerHandle{
	if (_table.contentSize.height<=_table.height) {
		_table.footerHidden = YES;
	}
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
	if (self.view.window==nil) self.view = nil;
}

@end
