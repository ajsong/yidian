//
//  withdrawEdit.m
//  yidian
//
//  Created by ajsong on 15/12/26.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import "Global.h"
#import "withdrawEdit.h"
#import "shopIncomeAction.h"

@interface withdrawEdit (){
	UIScrollView *_scroll;
	
	UITextField *_bank;
	SpecialTextField *_bank_card;
	UITextField *_subbank;
	UITextField *_name;
}
@end

@implementation withdrawEdit

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = STRINGFORMAT(@"%@提现账户", _data.isDictionary ? @"修改" : @"添加");
	self.view.backgroundColor = BACKCOLOR;
	
	_scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.height);
	[self.view addSubview:_scroll];
	
	[self performSelector:@selector(loadViews) withObject:nil afterDelay:0];
}

- (void)loadViews{
	[_scroll removeAllSubviews];
	
	UIFont *font = FONT(14);
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 94, view.height)];
	label.text = @"银行";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_bank = [[UITextField alloc]initWithFrame:CGRectMake(label.right, 0, view.width-label.right, view.height)];
	_bank.placeholder = @"请输入银行名称";
	if (_data.isDictionary) _bank.text = _data[@"bank_name"];
	_bank.textColor = COLOR666;
	_bank.font = font;
	_bank.backgroundColor = [UIColor clearColor];
	_bank.clearButtonMode = UITextFieldViewModeWhileEditing;
	[view addSubview:_bank];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"银行卡卡号";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_bank_card = [[SpecialTextField alloc]initWithFrame:_bank.frame];
	_bank_card.placeholder = @"请输入银行卡卡号";
	if (_data.isDictionary) _bank_card.text = _data[@"card_number"];
	_bank_card.textColor = COLOR666;
	_bank_card.font = font;
	_bank_card.backgroundColor = [UIColor clearColor];
	_bank_card.clearButtonMode = UITextFieldViewModeWhileEditing;
	[view addSubview:_bank_card];
	_bank_card.creditCard = YES;
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"开户支行";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_subbank = [[UITextField alloc]initWithFrame:_bank.frame];
	_subbank.placeholder = @"请输入开户支行";
	if (_data.isDictionary) _subbank.text = _data[@"branch_name"];
	_subbank.textColor = COLOR666;
	_subbank.font = font;
	_subbank.backgroundColor = [UIColor clearColor];
	_subbank.clearButtonMode = UITextFieldViewModeWhileEditing;
	[view addSubview:_subbank];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"开户名";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_name = [[UITextField alloc]initWithFrame:_bank.frame];
	_name.placeholder = @"请输入开户名";
	if (_data.isDictionary) _name.text = _data[@"name"];
	_name.textColor = COLOR666;
	_name.font = font;
	_name.backgroundColor = [UIColor clearColor];
	_name.clearButtonMode = UITextFieldViewModeWhileEditing;
	[view addSubview:_name];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, view.width, 60)];
	[_scroll addSubview:view];
	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, view.width-10*2, 40)];
	btn.titleLabel.font = [UIFont systemFontOfSize:15];
	btn.backgroundColor = MAINSUBCOLOR;
	[btn setTitle:@"提交" forState:UIControlStateNormal];
	[btn setTitleColor:WHITE forState:UIControlStateNormal];
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[self pass];
	}];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 4;
	[view addSubview:btn];
	
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.lastSubview.bottom);
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)pass{
	[self backgroundTap];
	if (!_bank.text.length || !_bank_card.text.length || !_subbank.text.length || !_name.text.length) {
		[ProgressHUD showError:@"所有项都必须填写"];
		return;
	}
	[ProgressHUD show:nil];
	NSMutableDictionary *postData = [NSMutableDictionary dictionary];
	if (_data.isDictionary) [postData setValue:_data[@"id"] forKey:@"id"];
	[postData setValue:_bank.text forKey:@"bank_name"];
	[postData setValue:[_bank_card.text replace:@" " to:@""] forKey:@"card_number"];
	[postData setValue:_subbank.text forKey:@"branch_name"];
	[postData setValue:_name.text forKey:@"name"];
	[Common postApiWithParams:@{@"app":@"bank", @"act":@"add"} data:postData feedback:STRINGFORMAT(@"%@成功", _data.isDictionary ? @"修改" : @"添加") success:^(NSMutableDictionary *json) {
		if (_delegate && [_delegate respondsToSelector:@selector(GlobalExecuteWithCaller:data:)]) {
			[_delegate GlobalExecuteWithCaller:self data:json[@"data"]];
			[self.navigationController popToViewControllerOfClass:[shopIncomeAction class] animated:YES];
		} else {
			[self.navigationController popViewControllerAnimated:YES];
		}
	} fail:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
