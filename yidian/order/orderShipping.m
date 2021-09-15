//
//  orderShipping.m
//  ejdian
//
//  Created by ajsong on 15/6/16.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import "orderShipping.h"
#import "scaner.h"

@interface orderShipping ()<AJPickerViewDelegate,GlobalDelegate>{
	NSMutableArray *_ms;
	NSMutableArray *_mc;
	UIScrollView *_scroll;
	AJPickerView *_pickerView;
	
	UILabel *_company;
	NSString *_shipping_company;
	UITextField *_shipping_number;
	
	NSMutableArray *_order_goods_id_tags;
	NSMutableArray *_goods_ids;
	NSMutableArray *_order_goods_ids;
	NSMutableArray *_codes;
	NSMutableArray *_qrcodes_ids;
	NSMutableArray *_qrcodes_codes;
	NSInteger _index;
	NSInteger _quantity;
	NSInteger _quantityIndex;
	NSMutableArray *_codesArray;
}
@end

@implementation orderShipping

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"扫码发货";
	self.view.backgroundColor = BACKCOLOR;
	//NSLog(@"%@", _data.descriptionASCII);
	
	_shipping_company = @"";
	_order_goods_id_tags = [[NSMutableArray alloc]init];
	_goods_ids = [[NSMutableArray alloc]init];
	_order_goods_ids = [[NSMutableArray alloc]init];
	_codes = [[NSMutableArray alloc]init];
	_qrcodes_ids = [[NSMutableArray alloc]init];
	_qrcodes_codes = [[NSMutableArray alloc]init];
	_codesArray = [[NSMutableArray alloc]init];
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"确定" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchUpInside];
	
	_scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.height);
	[self.view addSubview:_scroll];
	
	_pickerView = [[AJPickerView alloc]init];
	_pickerView.delegate = self;
	
	[ProgressHUD show:nil];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self loadData];
	});
}

#pragma mark - loadData
- (void)loadData{
	_ms = [[NSMutableArray alloc]init];
	_mc = [[NSMutableArray alloc]init];
	[Common getApiWithParams:@{@"app":@"member", @"act":@"get_shipping_company_and_goods", @"order_id":_data[@"id"]} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([json[@"data"][@"shipping_company"] isArray]) {
			NSArray *list = json[@"data"][@"shipping_company"];
			for (int i=0; i<list.count; i++) {
				[_mc addObject:list[i][@"name"]];
			}
			_pickerView.data = _mc;
		}
		if ([json[@"data"][@"goods"] isArray]) {
			NSArray *list = json[@"data"][@"goods"];
			for (int i=0; i<list.count; i++) {
				[_ms addObject:list[i]];
			}
		}
		//NSLog(@"%@", _ms);
		[self loadViews];
	} fail:^(NSMutableDictionary *json) {
		[self loadViews];
	}];
}

- (void)loadViews{
	[_scroll removeAllSubviews];
	UIFont *font = FONT(13);
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15, view.height)];
	label.text = @"选择快递公司";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	UIImageView *push = [[UIImageView alloc]initWithFrame:CGRectMake(view.width-44, 0, 44, 44)];
	push.image = IMG(@"push");
	[view addSubview:push];
	_company = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, push.left, view.height)];
	_company.textColor = COLOR777;
	_company.textAlignment = NSTextAlignmentRight;
	_company.font = font;
	_company.backgroundColor = [UIColor clearColor];
	[view addSubview:_company];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self backgroundTap];
		[_pickerView show];
	}];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	_shipping_number = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, view.width-15-44, view.height)];
	_shipping_number.placeholder = @"快递单号";
	_shipping_number.textColor = [UIColor blackColor];
	_shipping_number.font = font;
	_shipping_number.backgroundColor = [UIColor clearColor];
	_shipping_number.keyboardType = UIKeyboardTypeASCIICapable;
	[view addSubview:_shipping_number];
	
	UIImageView *ico = [[UIImageView alloc]initWithFrame:CGRectMake(view.width-44, 0, 44, 44)];
	ico.image = IMG(@"d-qrcode");
	ico.alpha = 0.3;
	[view addSubview:ico];
	[ico click:^(UIView *view, UIGestureRecognizer *sender) {
		[self backgroundTap];
		scaner *e = [[scaner alloc]init];
		e.globalDelegate = self;
		e.from = ScanerFromShipping;
		[self.navigationController pushViewController:e animated:YES];
	}];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, view.bottom, view.width-15, view.height)];
	label.text = @"发货商品";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[_scroll addSubview:label];
	
	CGFloat top = label.bottom;
	
	if (_ms.isArray) {
		for (int i=0; i<_ms.count; i++) {
			[_goods_ids addObject:STRING(_ms[i][@"goods_id"])];
			[_order_goods_id_tags addObject:STRING(_ms[i][@"id"])];
			
			view = [[UIView alloc]initWithFrame:CGRectMake(0, top, SCREEN_WIDTH, 75)];
			view.backgroundColor = WHITE;
			view.element[@"id"] = STRING(_ms[i][@"id"]);
			view.element[@"title"] = STRINGFORMAT(@"%@ (%@)", _ms[i][@"goods_name"], _ms[i][@"spec"]);
			view.element[@"quantity"] = STRING(_ms[i][@"quantity"]);
			view.element[@"packages"] = _ms[i][@"packages"];
			view.element[@"packages_goods_id"] = STRING(_ms[i][@"packages_goods_id"]);
			view.tag = [_ms[i][@"id"] integerValue] + 10000;
			[_scroll addSubview:view];
			
			UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 55, 55)];
			img.image = IMG(@"nopic");
			img.url = _ms[i][@"goods_pic"];
			[view addSubview:img];
			
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(view.width-64-10, (view.height-25)/2, 64, 25)];
			label.text = @"扫码";
			label.textColor = [UIColor whiteColor];
			label.textAlignment = NSTextAlignmentCenter;
			label.font = font;
			label.backgroundColor = MAINSUBCOLOR;
			label.layer.masksToBounds = YES;
			label.layer.cornerRadius = 3;
			label.tag = 101;
			[view addSubview:label];
			
			label = [[UILabel alloc]initWithFrame:CGRectMake(img.right+6, img.top, label.left-(img.right+6)-10, 17)];
			label.text = _ms[i][@"goods_name"];
			label.textColor = [UIColor blackColor];
			label.font = font;
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			
			label = [[UILabel alloc]initWithFrame:CGRectMake(label.left, label.bottom, label.width, 20)];
			label.text = STRINGFORMAT(@"规格：%@　× %@", _ms[i][@"spec"], STRING(_ms[i][@"quantity"]));
			label.textColor = COLOR999;
			label.font = FONT(11);
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			
			label = [[UILabel alloc]initWithFrame:label.frameBottom];
			label.textColor = COLOR777;
			label.font = [UIFont fontWithName:@"TamilSangamMN" size:13];
			label.backgroundColor = [UIColor clearColor];
			label.tag = 100;
			label.numberOfLines = 0;
			[view addSubview:label];
			
			[view click:^(UIView *view, UIGestureRecognizer *sender) {
				_index = i;
				_quantity = [_ms[i][@"quantity"] integerValue];
				_quantityIndex = 0;
				_codesArray = [[NSMutableArray alloc]init];
				scaner *e = [[scaner alloc]init];
				e.globalDelegate = self;
				e.from = ScanerFromOrder;
				e.data = @{
						   @"id":([_ms[i][@"packages_goods_id"]intValue]>0?STRING(_ms[i][@"packages_goods_id"]):STRING(_ms[i][@"goods_id"])),
						   @"title":STRINGFORMAT(@"%@ 第1件", view.element[@"title"])
						   };
				[self.navigationController pushViewController:e animated:YES];
			}];
			
			top = view.bottom + 8;
		}
	}
	
	_scroll.contentSize = CGSizeMake(_scroll.width, top);
}

- (void)GlobalExecuteShippingNumberWithData:(NSDictionary *)data{
	_shipping_number.text = data[@"code"];
}

- (NSString*)GlobalExecuteGroupWithData:(NSDictionary *)data{
	NSString *goods_id = _goods_ids[_index];
	NSString *order_goods_id_tags = _order_goods_id_tags[_index];
	UIView *view = [self.view viewWithTag:order_goods_id_tags.integerValue+10000];
	NSString *packages_goods_id = view.element[@"packages_goods_id"];
	
	if (packages_goods_id.intValue>0 && [[data[@"code"] substr:8 length:1] isEqualToString:@"0"]) {
		return @"unsametype";
	}
	
	if ([data[@"packages"]isArray]) {
		NSArray *list = data[@"packages"];
		if (list.count != [view.element[@"packages"]intValue]) {
			return @"unsamepackages";
		}
	}
	
	for (NSArray *codes in _qrcodes_codes) {
		if ([data[@"code"] inArray:codes] != NSNotFound) {
			return @"repeat";
			break;
		}
	}
	
	NSInteger index = [_qrcodes_ids indexOfObject:packages_goods_id.intValue>0?packages_goods_id:goods_id];
	if (index == NSNotFound) {
		[_qrcodes_ids addObject:packages_goods_id.intValue>0?packages_goods_id:goods_id];
		NSMutableArray *codes = [[NSMutableArray alloc]init];
		[codes addObject:data[@"code"]];
		[_qrcodes_codes addObject:codes];
		/*
		if ([data[@"packages"]isset] && packages_goods_id.intValue>0) {
			codes = [[NSMutableArray alloc]init];
			NSArray *list = data[@"packages"];
			for (NSString *code in list) {
				[codes addObject:code];
			}
			[_qrcodes_ids addObject:packages_goods_id];
			[_qrcodes_codes addObject:codes];
		}
		 */
		
		NSString *order_goods_id = view.element[@"id"];
		[_order_goods_ids addObject:order_goods_id];
		
		codes = [[NSMutableArray alloc]init];
		[codes addObject:@{@"goods_id":goods_id, @"code":data[@"code"]}];
		if ([data[@"packages"]isArray] && packages_goods_id.intValue>0) {
			NSArray *list = data[@"packages"];
			for (NSString *code in list) {
				[codes addObject:@{@"goods_id":packages_goods_id, @"code":code}];
			}
		}
		[_codes addObject:codes];
	} else {
		NSMutableArray *codes = [NSMutableArray arrayWithArray:_qrcodes_codes[index]];
		if ([data[@"code"] inArray:codes] == NSNotFound) {
			[codes addObject:data[@"code"]];
			[_qrcodes_codes replaceObjectAtIndex:index withObject:codes];
		}
		
		codes = [NSMutableArray arrayWithArray:_codes[index]];
		[codes addObject:@{@"goods_id":goods_id, @"code":data[@"code"]}];
		if ([data[@"packages"]isArray] && packages_goods_id.intValue>0) {
			NSArray *list = data[@"packages"];
			for (NSString *code in list) {
				[codes addObject:@{@"goods_id":packages_goods_id, @"code":code}];
			}
		}
		[_codes replaceObjectAtIndex:index withObject:codes];
	}
	
	[_codesArray addObject:data[@"code"]];
	if (_quantityIndex < _quantity-1) {
		_quantityIndex++;
		return STRINGFORMAT(@"%@ 第%ld件", view.element[@"title"], (long)(_quantityIndex+1));
	} else {
		UILabel *label = (UILabel*)[view viewWithTag:101];
		label.text = @"重新扫描";
		
		label = (UILabel*)[view viewWithTag:100];
		label.text = [_codesArray implode:@"\n"];
		[label autoHeight];
		view.height = label.bottom + 10;
		for (UIView *subview in view.nextViews) {
			subview.top = subview.prevView.bottom + 8;
		}
		_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.lastSubview.bottom+8);
	}
	
	_index++;
	if (_index < _goods_ids.count) {
		order_goods_id_tags = _order_goods_id_tags[_index];
		view = [self.view viewWithTag:order_goods_id_tags.integerValue+10000];
		_quantity = [view.element[@"quantity"] integerValue];
		_quantityIndex = 0;
		_codesArray = [[NSMutableArray alloc]init];
		return STRINGFORMAT(@"%@ 第1件", view.element[@"title"]);
	}
	
	return nil;
}

- (void)AJPickerView:(AJPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	_company.text = _mc[row];
	_shipping_company = _mc[row];
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)pass{
	[self backgroundTap];
	if (!_shipping_company.length) {
		[ProgressHUD showError:@"请选择快递公司"];
		return;
	}
	if (!_shipping_number.text.length) {
		[ProgressHUD showError:@"请输入快递单号"];
		return;
	}
	if (!_qrcodes_ids.count) {
		[ProgressHUD showError:@"请扫描需发货的商品的二维码"];
		return;
	}
	if (_ms.isArray) {
		NSInteger quantity = 0;
		NSInteger count = 0;
		for (int i=0; i<_ms.count; i++) {
			quantity += [_ms[i][@"quantity"] integerValue];
		}
		for (int i=0; i<_qrcodes_ids.count; i++) {
			count += [_qrcodes_codes[i] count];
		}
		if (quantity>count) {
			[ProgressHUD showError:@"需发货的商品的扫描的二维码不完整"];
			return;
		}
	}
	[ProgressHUD show:nil];
	NSMutableArray *data = [[NSMutableArray alloc]init];
	for (int i=0; i<_qrcodes_ids.count; i++) {
		[data addObject:@{@"productId":_qrcodes_ids[i], @"codes":_qrcodes_codes[i]}];
	}
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:PERSON[@"shop"][@"id"] forKey:@"clientId"];
	[postData setValue:_data[@"id"] forKey:@"orderId"];
	[postData setValue:@"true" forKey:@"bind"];
	[postData setValue:data.jsonString forKey:@"body"];
	//NSLog(@"%@", postData.descriptionASCII);
	[Common postApiWithParams:@{@"app":@"member", @"act":@"factory_orders"} data:postData feedback:@"nomsg" success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([json[@"error"]intValue]==0) {
			[ProgressHUD show:nil];
			NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
			[postData setValue:_data[@"id"] forKey:@"order_id"];
			[postData setValue:_shipping_company forKey:@"shipping_company"];
			[postData setValue:_shipping_number.text forKey:@"shipping_number"];
			NSMutableArray *codes = [[NSMutableArray alloc]init];
			for (int i=0; i<_order_goods_ids.count; i++) {
				[codes addObject:@{@"order_goods_id":_order_goods_ids[i], @"goods_codes":_codes[i]}];
			}
			[postData setValue:codes.jsonString forKey:@"qrcodes"];
			//NSLog(@"postData: %@", postData.descriptionASCII);
			[Common postApiWithParams:@{@"app":@"member", @"act":@"shop_order_fahuo"} data:postData success:^(NSMutableDictionary *json) {
				//NSLog(@"json: %@", json.descriptionASCII);
				if (_delegate && [_delegate respondsToSelector:@selector(refreshDetail)]) {
					[_delegate refreshDetail];
				}
				[self.navigationController popViewControllerAnimated:YES];
			} fail:nil];
		} else {
			[ProgressHUD showError:json[@"msg"]];
		}
	} fail:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
