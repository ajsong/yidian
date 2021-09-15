//
//  shopFreeShipping.m
//  yidian
//
//  Created by ajsong on 2016/10/19.
//  Copyright © 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "shopFreeShipping.h"

@interface shopFreeShipping ()<UITextFieldDelegate>{
	UIScrollView *_scrollView;
	SpecialTextField *_free_shipping_price;
}
@end

@implementation shopFreeShipping

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	[self backgroundTap];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"包邮设置";
	self.view.backgroundColor = BACKCOLOR;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"保存" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
	
	_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	[self.view addSubview:_scrollView];
	
	[self performSelector:@selector(loadViews) withObject:nil afterDelay:0];
}

- (void)loadViews{
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[_scrollView addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15, view.height)];
	label.text = @"订单满　　　　　　元包邮";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_free_shipping_price = [[SpecialTextField alloc]initWithFrame:CGRectMake(62, (view.height-24)/2, 75, 24)];
	_free_shipping_price.text = _price;
	_free_shipping_price.textColor = [UIColor blackColor];
	_free_shipping_price.textAlignment = NSTextAlignmentCenter;
	_free_shipping_price.font = FONT(14);
	_free_shipping_price.backgroundColor = [UIColor clearColor];
	_free_shipping_price.keyboardType = UIKeyboardTypeDecimalPad;
	[view addSubview:_free_shipping_price];
	[_free_shipping_price addGeWithType:GeLineTypeBottom color:COLOR_GE];
	
	[_free_shipping_price performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:1.0];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[self submit];
	return YES;
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)submit{
	[self backgroundTap];
	if (!_free_shipping_price.text.length) {
		[ProgressHUD showError:@"请输入价格"];
		return;
	}
	[ProgressHUD show:nil];
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:_free_shipping_price.text forKey:@"free_shipping_price"];
	[Common postApiWithParams:@{@"app":@"eshop", @"act":@"free_shipping_price"} data:postData success:^(NSMutableDictionary *json) {
		if (_delegate && [_delegate respondsToSelector:@selector(GlobalExecuteWithCaller:data:)]) {
			[_delegate GlobalExecuteWithCaller:nil data:@{@"value":_free_shipping_price.text}];
		}
		[self.navigationController popViewControllerAnimated:YES];
	} fail:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
