//
//  shopCommissionEdit.m
//  yidian
//
//  Created by ajsong on 16/1/4.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "shopCommissionEdit.h"
#import "productEdit.h"

@interface shopCommissionEdit ()<UITextFieldDelegate>{
	UITextField *_name;
	SpecialTextField *_commission1;
	SpecialTextField *_commission2;
	SpecialTextField *_commission3;
}
@end

@implementation shopCommissionEdit

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	[self backgroundTap];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = _data.isDictionary ? @"编辑分利模板" : @"添加分利模板";
	self.view.backgroundColor = BACKCOLOR;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"保存" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchUpInside];
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[self.view addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 110, view.height)];
	label.text = @"模板名称";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[self.view addSubview:label];
	_name = [[UITextField alloc]initWithFrame:CGRectMake(label.right, 0, view.width-label.right-15, view.height)];
	_name.placeholder = @"请输入模板名称";
	if (_data.isDictionary) _name.text = _data[@"name"];
	_name.textColor = [UIColor blackColor];
	_name.textAlignment = NSTextAlignmentRight;
	_name.font = FONT(14);
	_name.backgroundColor = [UIColor clearColor];
	[view addSubview:_name];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[self.view addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"直接销售场景";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_commission1 = [[SpecialTextField alloc]initWithFrame:CGRectMake(label.right, 0, view.width-label.right-16-15, view.height)];
	if (_data.isDictionary) _commission1.text = _data[@"commission1"];
	_commission1.textColor = COLOR777;
	_commission1.textAlignment = NSTextAlignmentRight;
	_commission1.font = FONT(14);
	_commission1.backgroundColor = [UIColor clearColor];
	_commission1.keyboardType = UIKeyboardTypeDecimalPad;
	[view addSubview:_commission1];
	_commission1.decimalNum = 1;
	UILabel *unit = [[UILabel alloc]initWithFrame:CGRectMake(_commission1.right, 0, 16, view.height)];
	unit.text = @"%";
	unit.textColor = COLOR777;
	unit.textAlignment = NSTextAlignmentRight;
	unit.font = FONT(14);
	unit.backgroundColor = [UIColor clearColor];
	[view addSubview:unit];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[self.view addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"二级场景";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_commission2 = [[SpecialTextField alloc]initWithFrame:_commission1.frame];
	if (_data.isDictionary) _commission2.text = _data[@"commission2"];
	_commission2.textColor = COLOR777;
	_commission2.textAlignment = NSTextAlignmentRight;
	_commission2.font = FONT(14);
	_commission2.backgroundColor = [UIColor clearColor];
	_commission2.keyboardType = UIKeyboardTypeDecimalPad;
	[view addSubview:_commission2];
	_commission2.decimalNum = 1;
	unit = [[UILabel alloc]initWithFrame:unit.frame];
	unit.text = @"%";
	unit.textColor = COLOR777;
	unit.textAlignment = NSTextAlignmentRight;
	unit.font = FONT(14);
	unit.backgroundColor = [UIColor clearColor];
	[view addSubview:unit];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[self.view addSubview:view];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"三级场景";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_commission3 = [[SpecialTextField alloc]initWithFrame:_commission1.frame];
	if (_data.isDictionary) _commission3.text = _data[@"commission3"];
	_commission3.textColor = COLOR777;
	_commission3.textAlignment = NSTextAlignmentRight;
	_commission3.font = FONT(14);
	_commission3.backgroundColor = [UIColor clearColor];
	_commission3.keyboardType = UIKeyboardTypeDecimalPad;
	[view addSubview:_commission3];
	_commission3.decimalNum = 1;
	unit = [[UILabel alloc]initWithFrame:unit.frame];
	unit.text = @"%";
	unit.textColor = COLOR777;
	unit.textAlignment = NSTextAlignmentRight;
	unit.font = FONT(14);
	unit.backgroundColor = [UIColor clearColor];
	[view addSubview:unit];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, view.bottom+12, SCREEN_WIDTH-15*2, 0)];
	label.text = @"修改分利模板的佣金比例后，所有使用此模板的商品均采用新的佣金比例；已经产生的订单不受此影响。";
	label.textColor = COLOR777;
	label.font = FONT(12);
	label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 0;
	[self.view addSubview:label];
	[label autoHeight];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[self pass];
	return YES;
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)pass{
	[self backgroundTap];
	if (!_name.text.length || !_commission1.text.length || !_commission2.text.length || !_commission3.text.length) {
		[ProgressHUD showError:@"所有选项都必须填写"];
		return;
	}
	if (_commission1.text.floatValue + _commission2.text.floatValue + _commission3.text.floatValue > 100) {
		[ProgressHUD showError:@"三个模板之和不能大于100%"];
		return;
	}
	[ProgressHUD show:nil];
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	if (_data.isDictionary) [postData setValue:_data[@"id"] forKey:@"id"];
	[postData setValue:_name.text forKey:@"name"];
	[postData setValue:_commission1.text forKey:@"commission1"];
	[postData setValue:_commission2.text forKey:@"commission2"];
	[postData setValue:_commission3.text forKey:@"commission3"];
	[Common postApiWithParams:@{@"app":@"commission", @"act":@"add"} data:postData success:^(NSMutableDictionary *json) {
		if (_delegate && [_delegate respondsToSelector:@selector(GlobalExecuteWithCaller:data:)]) {
			[_delegate GlobalExecuteWithCaller:self data:json[@"data"]];
			[self.navigationController popToViewControllerOfClass:[productEdit class] animated:YES];
			return;
		}
		[self.navigationController popViewControllerAnimated:YES];
	} fail:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
