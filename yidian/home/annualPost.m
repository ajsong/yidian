//
//  recharge.m
//  imei
//
//  Created by ajsong on 15/11/18.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import "Global.h"
#import "annualPost.h"
#import "annualComplete.h"

@interface annualPost ()<AJCheckboxDelegate>{
	NSMutableDictionary *_ms;
	NSString *_pay_method;
	NSMutableArray *_payNames;
	NSMutableArray *_payValues;
}
@end

@implementation annualPost

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"支付年费";
	self.view.backgroundColor = BACKCOLOR;
	self.edgesForExtendedLayout = UIRectEdgeNone;
	
	_payNames = [[NSMutableArray alloc]init];
	_payValues = [[NSMutableArray alloc]init];
	NSArray *payNames = @[@"微信支付", @"支付宝支付"];
	NSArray *payValues = @[@"wxpay", @"alipay"];
	for (int i=0; i<payValues.count; i++) {
		if ([payValues[i] isEqualToString:@"wxpay"] && [ShareHelper isWXAppInstalled] && ![Common isAuditKey]) {
			[_payNames addObject:payNames[i]];
			[_payValues addObject:payValues[i]];
		}
		if ([payValues[i] isEqualToString:@"alipay"] && [ShareHelper isAlipayInstalled] && ![Common isAuditKey]) {
			[_payNames addObject:payNames[i]];
			[_payValues addObject:payValues[i]];
		}
	}
	
	[self loadData];
}

#pragma mark - loadData
- (void)loadData{
	_ms = [[NSMutableDictionary alloc]init];
	[Common getApiWithParams:@{@"app":@"annual", @"act":@"index"} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([json[@"data"] isDictionary]) {
			_ms = json[@"data"];
		}
		//NSLog(@"%@", _ms.descriptionASCII);
		[self loadViews];
	} fail:^(NSMutableDictionary *json) {
		[self loadViews];
	}];
}

- (void)loadViews{
	if (!_ms.isDictionary) return;
	
	UIFont *font = FONTBOLD(16);
	UIFont *font2 = FONTBOLD(28);
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMakeScale(0, 0, SCREEN_WIDTH, 94)];
	view.backgroundColor = WHITE;
	[self.view addSubview:view];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, view.width-15, font.lineHeight)];
	label.text = @"优必上商家服务年费";
	label.textColor = BLACK;
	label.font = FONT(13);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(label.left, label.bottom+25, 18, label.height)];
	label.text = @"￥";
	label.textColor = COLORRGB(@"d00c0c");
	label.font = FONTBOLD(17);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(label.right, label.bottom-font2.lineHeight+3, 0, font2.lineHeight)];
	price.text = STRINGFORMAT(@"%.2f", [_ms[@"price"]floatValue]);
	price.textColor = COLORRGB(@"d00c0c");
	price.font = font2;
	price.backgroundColor = [UIColor clearColor];
	[view addSubview:price];
	[price autoWidth];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(price.right+3, label.top-1, view.width-(price.right+3), label.height)];
	label.text = @"元/年";
	label.textColor = BLACK;
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom+8, SCREEN_WIDTH, 40)];
	view.backgroundColor = WHITE;
	[self.view addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15, view.height)];
	label.text = @"支付方式";
	label.textColor = MAINSUBCOLOR;
	label.font = FONTBOLD(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	CGFloat top = view.bottom;
	if (_payNames.count) {
		AJCheckbox *cb = [[AJCheckbox alloc]init];
		cb.delegate = self;
		cb.orderType = CheckboxOrderTypeRight;
		cb.image = IMG(@"checkbox");
		cb.selectedImage = IMG(@"checkbox-x");
		cb.size = CGSizeMake(42, 42);
		cb.textWidth = SCREEN_WIDTH - 42;
		cb.textHeight = 44;
		for (int i=0; i<_payNames.count; i++) {
			[cb addObject:_payNames[i]];
		}
		for (int i=0; i<cb.views.count; i++) {
			view = cb.views[i];
			view.top = top;
			view.backgroundColor = WHITE;
			[self.view addSubview:view];
			
			label = (UILabel*)[view viewWithTag:CHECKBOX_TAG+1];
			label.hidden = YES;
			
			CGFloat x = 10;
			if (i>=cb.views.count-1) x = 0;
			UIView *ge = [[UIView alloc]initWithFrame:CGRectMake(x, view.height-1, SCREEN_WIDTH-x, 1)];
			ge.backgroundColor = BACKCOLOR;
			[view addSubview:ge];
			
			UIImageView *ico = [[UIImageView alloc]initWithFrame:CGRectMakeScale(0, 0, 44, 44)];
			ico.image = IMGFORMAT(@"shopping-pay-%@", _payValues[i]);
			[view addSubview:ico];
			
			label = [[UILabel alloc]initWithFrame:CGRectMake(ico.right, 0, SCREEN_WIDTH-ico.right-42, view.height)];
			label.text = _payNames[i];
			label.textColor = COLOR333;
			label.font = FONT(12);
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			
			top = view.bottom;
		}
	} else {
		view = [[UIView alloc]initWithFrame:CGRectMake(0, top, SCREEN_WIDTH, 44)];
		view.backgroundColor = WHITE;
		[self.view addSubview:view];
		
		label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15, view.height)];
		label.text = @"当前没有任何支付方式";
		label.textColor = COLOR999;
		label.font = FONT(12);
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		
		top = view.bottom;
	}
	
	top += 10;
	
	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10, top, SCREEN_WIDTH-10*2, 40)];
	btn.titleLabel.font = FONT(15);
	btn.backgroundColor = MAINSUBCOLOR;
	[btn setTitle:@"立即支付" forState:UIControlStateNormal];
	[btn setTitleColor:WHITE forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchUpInside];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 4;
	[self.view addSubview:btn];
	
	label = [[UILabel alloc]initWithFrame:btn.frameBottom];
	label.text = @"点击查看优必上年费服务协议";
	label.textColor = COLOR777;
	label.font = FONT(13);
	label.backgroundColor = [UIColor clearColor];
	[self.view addSubview:label];
	[label click:^(UIView *view, UIGestureRecognizer *sender) {
		outlet *e = [[outlet alloc]init];
		e.title = @"年费服务协议";
		e.url = STRINGFORMAT(@"%@/wap.php?app=article&act=detail&id=5", API_URL);
		[self.navigationController pushViewController:e animated:YES];
	}];
}

- (void)AJCheckbox:(AJCheckbox *)checkbox didSelectObject:(UIView *)view withStatus:(CheckboxStatus)status atIndex:(NSInteger)index{
	_pay_method = _payValues[index];
}

- (void)pass{
	if (!_pay_method.length) {
		[ProgressHUD showError:@"请选择支付方式"];
		return;
	}
	[@"annual" deleteUserDefaults];
	[ProgressHUD show:nil];
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:_pay_method forKey:@"pay_method"];
	[Common postApiWithParams:@{@"app":@"annual", @"act":@"buy"} data:postData feedback:nil success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json);
		if ([json[@"data"] isDictionary]) {
			NSDictionary *data = @{
								   @"ordernum":json[@"data"][@"order_sn"],
								   @"totalprice":json[@"data"][@"total_price"],
								   @"paymethod":_pay_method
								   };
			[@"order" setUserDefaultsWithData:data];
			[@"annual" setUserDefaultsWithData:@"YES"];
			NSString *orderTitle = STRINGFORMAT(@"%@-年费", APP_NAME);
			NSInteger index = [_payValues indexOfObject:_pay_method];
			switch (index) {
				case 0:{
					WechatPay *pay = [[WechatPay alloc]init];
					[pay wechatPayWithTradeNO:data[@"ordernum"] productName:orderTitle totalprice:data[@"totalprice"] notifyURL:STRINGFORMAT(@"%@/wx_notify_url.php", API_URL)];
					break;
				}
				case 1:{
					Alipay *alipay = [[Alipay alloc]init];
					[alipay payWithTradeNO:data[@"ordernum"] productName:orderTitle description:orderTitle totalprice:data[@"totalprice"] notifyURL:STRINGFORMAT(@"%@/ali_notify_url.php", API_URL) completion:^{
						NSDictionary *data = [@"order" getUserDefaultsDictionary];
						[@"order" deleteUserDefaults];
						[@"annual" deleteUserDefaults];
						annualComplete *e = [[annualComplete alloc]init];
						e.data = data;
						[self.navigationController pushViewController:e animated:YES];
					} fail:^(int statusCode) {
						[ProgressHUD showError:@"支付失败"];
						[self.navigationController popViewControllerAnimated:YES];
					}];
					break;
				}
				default:{
					[ProgressHUD showError:@"数据错误"];
					break;
				}
			}
		}
	} fail:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
