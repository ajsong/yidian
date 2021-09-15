//
//  factoryEdit.m
//  yidian
//
//  Created by ajsong on 16/4/8.
//  Copyright © 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "factoryEdit.h"

@interface factoryEdit ()<UITableViewDataSource,UITableViewDelegate,GlobalDelegate>{
	NSMutableArray *_ms;
	UITableView *_table;
	NSInteger _offset;
	//NSMutableArray *_cellHeight;
	
	BOOL _tableLoaded;
	NSMutableArray *_listViews;
}
@end

@implementation factoryEdit

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"入库单";
	self.view.backgroundColor = BACKCOLOR;
	
	_ms = [@"scanDatas" getUserDefaultsArray];
	_listViews = [[NSMutableArray alloc]init];
	//NSLog(@"%@", _ms);
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithImage:IMG(@"return") size:CGSizeMake(44, 44) itemType:KKNavigationItemTypeLeft];
	[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		NSMutableArray *body = [[NSMutableArray alloc]init];
		for (int i=0; i<_ms.count; i++) {
			if ([_ms[i][@"codes"] isArray]) {
				[body addObject:@YES];
			}
		}
		if (body.count) {
			[UIAlertView alert:@"确认放弃生成入库单吗？" block:^(NSInteger buttonIndex) {
				if (buttonIndex==1) {
					[self.navigationController popViewControllerAnimated:YES];
				}
			}];
		} else {
			[self.navigationController popViewControllerAnimated:YES];
		}
	}];
	
	NSString *string = @"选择需要入库的商品";
	CGSize s = [string autoWidth:FONT(14) height:44];
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
	view.backgroundColor = WHITE;
	[self.view addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	UIView *subview = [[UIView alloc]initWithFrame:CGRectMake((view.width-(44+s.width))/2, (view.height-44)/2, 44+s.width, 44)];
	[view addSubview:subview];
	UIImageView *ico = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
	ico.image = IMG(@"plus-black");
	[subview addSubview:ico];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(ico.right, 0, s.width, subview.height)];
	label.text = string;
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[subview addSubview:label];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		factoryGoods *e = [[factoryGoods alloc]init];
		e.delegate = self;
		[self.navigationController pushViewController:e animated:YES];
	}];
	
	_table = [[UITableView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, self.height-view.bottom-(40+10*2))];
	_table.estimatedSectionHeaderHeight = 0;
	_table.estimatedSectionFooterHeight = 0;
	_table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
	_table.separatorStyle = UITableViewCellSeparatorStyleNone;
	//_table.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
	_table.backgroundColor = [UIColor clearColor];
	_table.dataSource = self;
	_table.delegate = self;
	[self.view addSubview:_table];
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(10, self.height-40-10, SCREEN_WIDTH-10*2, 40);
	btn.titleLabel.font = FONT(15);
	btn.backgroundColor = MAINCOLOR;
	[btn setTitle:@"生成入库单" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 3;
	[btn addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btn];
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
	return 10+42+10+30+10;
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
		label.text = @"当前没有选择商品";
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
	
	if (_listViews.count>=row+1) {
		[cell.contentView addSubview:_listViews[row]];
		return cell;
	}
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width, 10+42+10+30+10)];
	view.backgroundColor = WHITE;
	view.tag = 100 + row;
	[cell.contentView addSubview:view];
	
	UIImageView *pic = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 42, 42)];
	pic.image = IMG(@"nopic");
	pic.url = _ms[row][@"default_pic"];
	[view addSubview:pic];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(pic.right+10, pic.top, view.width-(pic.right+10)-10, pic.height-15)];
	label.text = STRINGFORMAT(@"%@ (编号:%@)", _ms[row][@"name"], _ms[row][@"id"]);
	label.textColor = [UIColor blackColor];
	label.font = FONT(13);
	label.backgroundColor = [UIColor clearColor];
	label.lineBreakMode = NSLineBreakByTruncatingMiddle;
	label.minimumScaleFactor = 0.8;
	label.adjustsFontSizeToFitWidth = YES;
	[view addSubview:label];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(label.left, pic.bottom-10, label.width, 10)];
	if ([_ms[row][@"codes"]isset]) {
		label.text = STRINGFORMAT(@"已扫描：%ld", (long)[_ms[row][@"codes"] count]);
	} else {
		label.text = @"已扫描：0";
	}
	label.textColor = COLOR999;
	label.font = FONT(10);
	label.backgroundColor = [UIColor clearColor];
	label.tag = 99;
	[view addSubview:label];
	
	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(15, pic.bottom+10, 65, 30)];
	btn.titleLabel.font = FONT(12);
	btn.backgroundColor = COLORRGB(@"ff788a");
	[btn setTitle:@"大中小标签" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 3;
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[self pushScaner:view data:_ms[row] type:PackageType3 subType:PackageSubType1];
	}];
	[view addSubview:btn];
	
	btn = [[UIButton alloc]initWithFrame:[btn frameRight:10]];
	btn.titleLabel.font = FONT(12);
	btn.backgroundColor = COLORRGB(@"ff788a");
	[btn setTitle:@"大中标签" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 3;
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[self pushScaner:view data:_ms[row] type:PackageType2 subType:PackageSubType2];
	}];
	[view addSubview:btn];
	
	btn = [[UIButton alloc]initWithFrame:[btn frameRight:10]];
	btn.titleLabel.font = FONT(12);
	btn.backgroundColor = COLORRGB(@"ff788a");
	[btn setTitle:@"中小标签" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 3;
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[self pushScaner:view data:_ms[row] type:PackageType2 subType:PackageSubType1];
	}];
	[view addSubview:btn];
	
	btn = [[UIButton alloc]initWithFrame:[btn frameRight:10]];
	btn.titleLabel.font = FONT(12);
	btn.backgroundColor = COLORRGB(@"ff788a");
	[btn setTitle:@"小标签" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 3;
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[self pushScaner:view data:_ms[row] type:PackageType1 subType:PackageSubType1];
	}];
	[view addSubview:btn];
	
	[_listViews addObject:view];
	
	if (row==_ms.count-1) {
		_tableLoaded = YES;
	}
	
	return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	
}
#pragma mark -

- (void)pushScaner:(UIView*)curView data:(NSDictionary*)data type:(FactoryScanerType)type subType:(FactoryScanerSubType)subType{
	[@"scanGoodsData" setUserDefaultsWithData:@{@"goods":data, @"listIndex":@(curView.tag-100), @"scanType":@(type), @"scanSubType":@(subType)}];
	_currentView = curView;
	factoryScaner *e = [[factoryScaner alloc]init];
	e.data = data;
	e.globalDelegate = self;
	e.type = type;
	e.subType = subType;
	[self.navigationController pushViewController:e animated:YES];
}

- (void)pushScanerWithIndex:(NSInteger)listIndex data:(NSDictionary*)data type:(FactoryScanerType)type subType:(FactoryScanerSubType)subType{
	if (_tableLoaded) {
		_currentView = _listViews[listIndex];
		factoryScaner *e = [[factoryScaner alloc]init];
		e.data = data;
		e.globalDelegate = self;
		e.type = type;
		e.subType = subType;
		[self.navigationController pushViewController:e animated:YES];
	} else {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				[self pushScanerWithIndex:listIndex data:data type:type subType:subType];
			});
		});
	}
}

//多选产品后返回
- (void)GlobalExecuteWithDatas:(NSArray *)datas{
	NSMutableArray *ms = [[NSMutableArray alloc]init];
	for (int i=0; i<datas.count; i++) {
		if ([datas[i] inArray:_ms]==NSNotFound) {
			[ms addObject:datas[i]];
		}
	}
	if (!ms.count) return;
	for (int i=0; i<ms.count; i++) {
		[_ms addObject:ms[i]];
	}
	[@"scanDatas" setUserDefaultsWithData:_ms];
	_table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	[_table reloadData];
}

//扫描得到数据体后返回
- (void)GlobalExecuteWithData:(NSDictionary *)data{
	NSInteger row = _currentView.tag - 100;
	NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:_ms[row]];
	
	NSMutableArray *codes = [[NSMutableArray alloc]init];
	if ([d[@"codes"]isset]) codes = [NSMutableArray arrayWithArray:d[@"codes"]];
	if ([data[@"codes"] isArray]) {
		for (int i=0; i<[data[@"codes"] count]; i++) {
			[codes addObject:data[@"codes"][i]];
		}
	}
	[d setObject:codes forKey:@"codes"];
	
	NSMutableArray *codeDatas = [[NSMutableArray alloc]init];
	if ([d[@"codeDatas"]isArray]) codeDatas = [NSMutableArray arrayWithArray:d[@"codeDatas"]];
	if ([data[@"codeDatas"]isArray]) {
		for (int i=0; i<[data[@"codeDatas"] count]; i++) {
			[codeDatas addObject:data[@"codeDatas"][i]];
		}
	}
	[d setObject:codeDatas forKey:@"codeDatas"];
	
	[_ms replaceObjectAtIndex:row withObject:d];
	[@"scanDatas" setUserDefaultsWithData:_ms];
	
	UILabel *label = (UILabel*)[_currentView viewWithTag:99];
	label.text = STRINGFORMAT(@"已扫描：%ld", (long)codes.count);
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)pass{
	[self backgroundTap];
	NSMutableArray *body = [[NSMutableArray alloc]init];
	for (int i=0; i<_ms.count; i++) {
		if ([_ms[i][@"codes"] isArray]) {
			NSDictionary *data = @{@"goods_id":_ms[i][@"id"], @"num":@([_ms[i][@"codes"] count]), @"package":_ms[i][@"codeDatas"]};
			[body addObject:data];
		}
	}
	
	if (!body.count) {
		[ProgressHUD showError:@"请选择需要入库的商品后进行标签扫描绑定操作"];
		return;
	}
	
	[ProgressHUD show:nil];
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:body.jsonString forKey:@"body"];
	//NSLog(@"%@", postData.descriptionASCII);
	[Common postApiWithParams:@{@"app":@"member", @"act":@"factory_order_save"} data:postData success:^(NSMutableDictionary *json) {
		[self emptyHistory];
		[self.navigationController popViewControllerAnimated:YES];
	} fail:nil];
}

- (void)emptyHistory{
	[@"scanDatas" deleteUserDefaults];
	[@"scanGoodsData" deleteUserDefaults];
	[@"capacity" deleteUserDefaults];
	[@"capacity2" deleteUserDefaults];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
