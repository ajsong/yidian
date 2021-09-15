//
//  product.m
//  yidian
//
//  Created by ajsong on 16/1/5.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "product.h"
#import "productEdit.h"
#import "shopOutlet.h"

@interface product ()<UITableViewDataSource,UITableViewDelegate,OutletDelegate>{
	NSMutableArray *_ms;
	UITableView *_table;
	NSInteger _offset;
	NSMutableArray *_cellHeight;
	
	ShareHelper *_shareView;
}
@end

@implementation product

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[_table headerBeginRefreshing];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"商品管理";
	self.view.backgroundColor = BACKCOLOR;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"添加" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		productEdit *e = [[productEdit alloc]init];
		[self.navigationController pushViewController:e animated:YES];
	}];
	
	_shareView = [[ShareHelper alloc]init];
	
	_table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_table.estimatedSectionHeaderHeight = 0;
	_table.estimatedSectionFooterHeight = 0;
	_table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
	_table.separatorStyle = UITableViewCellSeparatorStyleNone;
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
	_cellHeight = [[NSMutableArray alloc]init];
	_offset = 0;
	[Common getApiWithParams:@{@"app":@"eshop", @"act":@"my_goods"} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([json[@"data"] isArray]) {
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
	[Common getApiWithParams:@{@"app":@"eshop", @"act":@"my_goods", @"offset":@(_offset)} success:^(NSMutableDictionary *json) {
		if ([json[@"data"] isArray]) {
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
		UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 320)];
		img.image = IMG(@"p-logo");
		[cell.contentView addSubview:img];
		return cell;
	}
	if (_ms.count<=row) return cell;
	for (UIView *subview in cell.contentView.subviews) {
		[subview removeFromSuperview];
	}
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width, 0)];
	view.backgroundColor = WHITE;
	[cell.contentView addSubview:view];
	
	NSString *time = STRINGFORMAT(@"<big>%@</big> <sm>%@</sm>", _ms[row][@"day"], _ms[row][@"month"]);
	NSDictionary *style = @{@"big":FONT(26), @"sm":FONT(13)};
	UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, view.width-10, 44)];
	timeLabel.attributedText = [time attributedStyle:style];
	timeLabel.backgroundColor = [UIColor clearColor];
	[view addSubview:timeLabel];
	
	UIView *ge = [[UIView alloc]initWithFrame:CGRectMake(10, timeLabel.bottom, timeLabel.width, 0.5)];
	ge.backgroundColor = COLOR_GE;
	[view addSubview:ge];
	
	NSString *string = _ms[row][@"name"];
	CGSize s = [string autoHeight:FONT(13) width:view.width];
	UILabel *content = [[UILabel alloc]initWithFrame:CGRectMake(10, ge.bottom+10, view.width-10*2, 0)];
	content.text = string;
	content.textColor = BLACK;
	content.font = FONT(13);
	content.backgroundColor = [UIColor clearColor];
	content.numberOfLines = 1;
	[view addSubview:content];
	[content sizeToFit];
	content.width = view.width-10*2;
	
	UIView *imgView = [[UIView alloc]initWithFrame:CGRectMake(10, content.bottom+10, view.width-10*2, 0)];
	[view addSubview:imgView];
	
	NSArray *list = _ms[row][@"pics"];
	if (list.isArray) {
		CGFloat w = 0;
		switch (list.count) {
			case 1:{
				w = imgView.width;
				break;
			}
			case 2:{
				w = (imgView.width-10) / 2;
				break;
			}
			default:{
				w = (imgView.width-10*2) / 3;
				break;
			}
		}
		NSMutableArray *subviews = [[NSMutableArray alloc]init];
		for (int i=0; i<list.count; i++) {
			UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, w, w)];
			img.image = IMG(@"nopic");
			img.url = list[i][@"pic"];
			img.tag = i;
			[subviews addObject:img];
		}
		[imgView autoLayoutSubviews:subviews marginPT:0 marginPL:0 marginPR:0];
		imgView.height = imgView.lastSubview.bottom;
	}
	
	UIFont *font = [UIFont systemFontOfSize:11];
	UIView *infoView = [[UIView alloc]initWithFrame:CGRectMake(0, imgView.bottom+8, view.width/4, 40)];
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
	
	NSInteger status = [_ms[row][@"status"]integerValue];
	view.element[@"status"] = @(status);
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(view.width-49-10, infoView.bottom+12, 49, 22);
	btn.backgroundColor = [UIColor clearColor];
	[btn setBackgroundImage:IMG(@"h-share") forState:UIControlStateNormal];
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		if ([view.element[@"status"]integerValue]!=1) {
			[ProgressHUD showError:@"商品已下架"];
			return;
		}
		NSString *url = STRINGFORMAT(@"%@/wap.php?app=goods&act=detail&goods_id=%@&reseller=%@", API_URL, _ms[row][@"id"], PERSON[@"shop"][@"id"]);
		if (list.isArray) {
			[Global cacheImageWithUrl:list[0][@"pic"] completion:^(UIImage *image, NSData *data, BOOL exist, BOOL isCache) {
				_shareView.title = _ms[row][@"name"];
				_shareView.image = image;
				_shareView.url = url;
				[_shareView show];
			}];
		} else {
			_shareView.title = _ms[row][@"name"];
			_shareView.image = IMG(@"AppIcon60x60");
			_shareView.url = url;
			[_shareView show];
		}
	}];
	[view addSubview:btn];
	
	CGRect frame = btn.frame;
	frame.origin.x -= frame.size.width + 20;
	btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = frame;
	btn.backgroundColor = [UIColor clearColor];
	[btn setBackgroundImage:IMG(@"h-delete") forState:UIControlStateNormal];
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[Global alert:@"真的要删除吗？" block:^(NSInteger buttonIndex) {
			if (buttonIndex==1) {
				NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
				[postData setValue:_ms[row][@"id"] forKey:@"goods_id"];
				[Common postApiWithParams:@{@"app":@"goods", @"act":@"delete"} data:postData feedback:nil success:^(NSMutableDictionary *json) {
					[_ms removeObjectAtIndex:row];
					[_cellHeight removeObjectAtIndex:row];
					[_table reloadData];
				} fail:nil];
			}
		}];
	}];
	[view addSubview:btn];
	
	frame = btn.frame;
	frame.origin.x -= frame.size.width + 20;
	btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = frame;
	btn.backgroundColor = [UIColor clearColor];
	if (status==1) {
		[btn setBackgroundImage:IMG(@"h-shelves") forState:UIControlStateNormal];
	} else {
		[btn setBackgroundImage:IMG(@"h-added") forState:UIControlStateNormal];
	}
	btn.element[@"origin_stocks"] = @([_ms[row][@"stocks"]integerValue]);
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		UIButton *btn = (UIButton*)sender;
		if ([btn.element[@"origin_stocks"]integerValue]<=0 && [view.element[@"status"]integerValue]!=1) {
			UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-20*2, 0)];
			view.backgroundColor = WHITE;
			view.layer.masksToBounds = YES;
			view.layer.cornerRadius = 4;
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.width, 30)];
			label.text = @"请设置库存数";
			label.textColor = COLOR999;
			label.textAlignment = NSTextAlignmentCenter;
			label.font = [UIFont systemFontOfSize:11];
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			UITextField *input = [[UITextField alloc]initWithFrame:CGRectMake((view.width-150)/2, label.bottom+5, 150, 35)];
			input.placeholder = @"库存数";
			input.textColor = [UIColor blackColor];
			input.textAlignment = NSTextAlignmentCenter;
			input.font = [UIFont systemFontOfSize:14];
			input.backgroundColor = [UIColor clearColor];
			input.layer.borderColor = COLOR999.CGColor;
			input.layer.borderWidth = 0.5;
			input.layer.masksToBounds = YES;
			input.layer.cornerRadius = 4;
			[view addSubview:input];
			UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
			btn.frame = CGRectMake((view.width-85)/2, input.bottom+10, 85, 35);
			btn.titleLabel.font = [UIFont systemFontOfSize:14];
			btn.backgroundColor = MAINSUBCOLOR;
			[btn setTitle:@"确定" forState:UIControlStateNormal];
			[btn setTitleColor:WHITE forState:UIControlStateNormal];
			[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id b) {
				NSString *stocks = ((UITextField*)((UIButton*)b).prevView).text;
				if (!stocks.length || stocks.intValue<=0) {
					[ProgressHUD showError:@"请填写正确的库存数量"];
					return;
				}
				((UIButton*)sender).element[@"stocks"] = stocks;
				[self setSX:sender view:view row:row];
			}];
			btn.layer.masksToBounds = YES;
			btn.layer.cornerRadius = 4;
			[view addSubview:btn];
			view.height = btn.bottom + 10;
			[self presentAlertView:view animation:DYAlertViewDown];
		} else {
			[self setSX:sender view:view row:row];
		}
	}];
	[view addSubview:btn];
	
	frame = btn.frame;
	frame.origin.x -= frame.size.width + 20;
	btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = frame;
	btn.backgroundColor = [UIColor clearColor];
	[btn setBackgroundImage:IMG(@"h-edit") forState:UIControlStateNormal];
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		productEdit *e = [[productEdit alloc]init];
		e.data = _ms[row];
		[self.navigationController pushViewController:e animated:YES];
	}];
	[view addSubview:btn];
	
	view.height = btn.bottom + 12;
	
	[_cellHeight replaceObjectAtIndex:row withObject:@(view.bottom+8)];
	return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	shopOutlet *e = [[shopOutlet alloc]init];
	e.url = STRINGFORMAT(@"%@/wap.php?app=goods&act=detail&goods_id=%@", API_URL, _ms[row][@"id"]);
	[self.navigationController pushViewController:e animated:YES];
}
#pragma mark -

- (void)setSX:(UIButton*)btn view:(UIView*)view row:(NSInteger)row{
	[self dismissAlertView:DYAlertViewDown];
	NSInteger status = [view.element[@"status"]integerValue];
	NSString *act = @"";
	if (status==1) {
		act = @"off_sale";
	} else {
		act = @"on_sale";
	}
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:_ms[row][@"id"] forKey:@"goods_id"];
	if (btn.element[@"stocks"]) [postData setValue:btn.element[@"stocks"] forKey:@"stocks"];
	[Common postApiWithParams:@{@"app":@"goods", @"act":act} data:postData feedback:@"设置成功" success:^(NSMutableDictionary *json) {
		if (status==1) {
			view.element[@"status"] = @(0);
			[btn setBackgroundImage:IMG(@"h-added") forState:UIControlStateNormal];
		} else {
			view.element[@"status"] = @(1);
			[btn setBackgroundImage:IMG(@"h-shelves") forState:UIControlStateNormal];
		}
		if (btn.element[@"stocks"]) btn.element[@"origin_stocks"] = btn.element[@"stocks"];
		btn.removeElement = @"stocks";
	} fail:nil];
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
