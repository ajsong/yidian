//
//  shopIncomeAction.m
//  yidian
//
//  Created by ajsong on 16/1/5.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "shopIncomeAction.h"
#import "GlobalDelegate.h"
#import "withdraw.h"

@interface shopIncomeAction ()<GlobalDelegate,AJPickerViewDelegate>{
	NSMutableDictionary *_person;
	UIScrollView *_scroll;
	
	SpecialTextField *_withdraw_money;
	UILabel *_labelBank;
	NSString *_bank_id;
	
	UISwitch *_switch;
	UILabel *_labelShipping;
	UITextField *_invoice_number;
	UITextField *_shipping_number;
	NSString *_shipping_company;
	AJPickerView *_pickerView;
	NSMutableArray *_ms;
	
	NSString *_can_withdraw_money;
	NSString *_freeze_money;
	NSString *_ok_income;
	NSString *_notok_income;
	NSString *_total_income;
}
@end

@implementation shopIncomeAction

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"申请提现";
	self.view.backgroundColor = BACKCOLOR;
	
	_person = PERSON;
	_bank_id = @"";
	_shipping_company = @"";
	
	_scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.height);
	[self.view addSubview:_scroll];
	
	[self loadData];
}

#pragma mark - loadData
- (void)loadData{
	[Common getApiWithParams:@{@"app":@"income", @"act":@"index"} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([json[@"data"] isDictionary]) {
			_can_withdraw_money = json[@"data"][@"can_withdraw_money"];
			_freeze_money = json[@"data"][@"freeze_money"];
			_ok_income = json[@"data"][@"ok_income"];
			_notok_income = json[@"data"][@"notok_income"];
			_total_income= json[@"data"][@"total_income"];
		}
		//NSLog(@"%@", _ms);
		if ([_person[@"member_type"]intValue]==2 && [_person[@"shop"][@"reseller_type"]intValue]==1) {
			[self loadShipping];
		} else {
			[self loadViews];
		}
	} fail:nil];
}
- (void)loadShipping{
	_ms = [[NSMutableArray alloc]init];
	[Common getApiWithParams:@{@"app":@"member", @"act":@"shipping_company"} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([json[@"data"] isArray]) {
			NSArray *list = json[@"data"];
			for (int i=0; i<list.count; i++) {
				[_ms addObject:list[i][@"name"]];
			}
			_pickerView = [[AJPickerView alloc]init];
			_pickerView.delegate = self;
			_pickerView.data = _ms;
			[self loadViews];
		}
	} fail:nil];
}

- (void)loadViews{
	[_scroll removeAllSubviews];
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15*2, view.height)];
	label.text = @"零钱包余额";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = STRINGFORMAT(@"￥%.2f", [_total_income floatValue]);
	label.textColor = COLOR999;
	label.textAlignment = NSTextAlignmentRight;
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"可提现金额";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = STRINGFORMAT(@"￥%.2f", [_can_withdraw_money floatValue]);
	label.textColor = COLOR999;
	label.textAlignment = NSTextAlignmentRight;
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"本次提现";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_withdraw_money = [[SpecialTextField alloc]initWithFrame:CGRectMake(view.width-200-15, 0, 200, view.height)];
	_withdraw_money.placeholder = @"请输入提现金额";
	_withdraw_money.textColor = [UIColor blackColor];
	_withdraw_money.textAlignment = NSTextAlignmentRight;
	_withdraw_money.font = FONT(14);
	_withdraw_money.backgroundColor = [UIColor clearColor];
	_withdraw_money.keyboardType = UIKeyboardTypeDecimalPad;
	[view addSubview:_withdraw_money];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 85, view.height)];
	label.text = @"提现账户";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	UIImageView *push = [[UIImageView alloc]initWithFrame:CGRectMake(view.width-44, 0, 44, 44)];
	push.image = IMG(@"push-small");
	[view addSubview:push];
	_labelBank = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, push.left+10, view.height)];
	_labelBank.text = @"请选择提现账户";
	_labelBank.textColor = BLACK;
	_labelBank.textAlignment = NSTextAlignmentRight;
	_labelBank.font = FONT(14);
	_labelBank.backgroundColor = [UIColor clearColor];
	[view addSubview:_labelBank];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self backgroundTap];
		withdraw *e = [[withdraw alloc]init];
		e.delegate = self;
		[self.navigationController pushViewController:e animated:YES];
	}];
	
	if ([_person[@"member_type"]intValue]==2) {
		if ([_person[@"shop"][@"reseller_type"]intValue]==1) {
			view = [[UIView alloc]initWithFrame:[view frameBottom:10]];
			view.backgroundColor = WHITE;
			[_scroll addSubview:view];
			[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
			label = [[UILabel alloc]initWithFrame:label.frame];
			label.text = @"发票单号";
			label.textColor = [UIColor blackColor];
			label.font = FONT(14);
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			_invoice_number = [[UITextField alloc]initWithFrame:CGRectMake(view.width-200-15, 0, 200, view.height)];
			_invoice_number.placeholder = @"请开具与提现金额等额的发票";
			_invoice_number.textColor = [UIColor blackColor];
			_invoice_number.textAlignment = NSTextAlignmentRight;
			_invoice_number.font = FONT(14);
			_invoice_number.backgroundColor = [UIColor clearColor];
			[view addSubview:_invoice_number];
			
			view = [[UIView alloc]initWithFrame:view.frameBottom];
			view.backgroundColor = WHITE;
			[_scroll addSubview:view];
			[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
			label = [[UILabel alloc]initWithFrame:label.frame];
			label.text = @"快递单号";
			label.textColor = [UIColor blackColor];
			label.font = FONT(14);
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			_shipping_number = [[UITextField alloc]initWithFrame:CGRectMake(view.width-200-15, 0, 200, view.height)];
			_shipping_number.placeholder = @"发送发票给我司的快递单号";
			_shipping_number.textColor = [UIColor blackColor];
			_shipping_number.textAlignment = NSTextAlignmentRight;
			_shipping_number.font = FONT(14);
			_shipping_number.backgroundColor = [UIColor clearColor];
			[view addSubview:_shipping_number];
			
			view = [[UIView alloc]initWithFrame:view.frameBottom];
			view.backgroundColor = WHITE;
			[_scroll addSubview:view];
			label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 85, view.height)];
			label.text = @"快递公司";
			label.textColor = [UIColor blackColor];
			label.font = FONT(14);
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			UIImageView *push = [[UIImageView alloc]initWithFrame:CGRectMake(view.width-44, 0, 44, 44)];
			push.image = IMG(@"push-small");
			[view addSubview:push];
			_labelShipping = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, push.left+10, view.height)];
			_labelShipping.text = @"请选择快递公司";
			_labelShipping.textColor = BLACK;
			_labelShipping.textAlignment = NSTextAlignmentRight;
			_labelShipping.font = FONT(14);
			_labelShipping.backgroundColor = [UIColor clearColor];
			[view addSubview:_labelShipping];
			[view click:^(UIView *view, UIGestureRecognizer *sender) {
				[self backgroundTap];
				[_pickerView show];
			}];
		} else {
			view = [[UIView alloc]initWithFrame:[view frameBottom:10]];
			view.backgroundColor = WHITE;
			[_scroll addSubview:view];
			label = [[UILabel alloc]initWithFrame:label.frame];
			label.text = @"个人所得税票";
			label.textColor = [UIColor blackColor];
			label.font = FONT(14);
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			_switch = [[UISwitch alloc]init];
			[_switch addTarget:self action:@selector(backgroundTap) forControlEvents:UIControlEventValueChanged];
			[view addSubview:_switch];
			_switch.top = (view.height-_switch.height)/2;
			_switch.right = 15;
		}
	}
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, view.width, 60)];
	[_scroll addSubview:view];
	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, view.width-10*2, 40)];
	btn.titleLabel.font = [UIFont systemFontOfSize:15];
	btn.backgroundColor = MAINSUBCOLOR;
	[btn setTitle:@"马上提现" forState:UIControlStateNormal];
	[btn setTitleColor:WHITE forState:UIControlStateNormal];
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[self pass];
	}];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 4;
	[view addSubview:btn];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(10, view.bottom, SCREEN_WIDTH-10*2, 44)];
	label.text = @"注：提现金额一次不少于100元";
	label.textColor = COLOR999;
	label.font = FONT(13);
	label.backgroundColor = [UIColor clearColor];
	[_scroll addSubview:label];
	
	if ([_person[@"member_type"]intValue]==2) {
		if ([_person[@"shop"][@"reseller_type"]intValue]!=1) {
			label = [[UILabel alloc]initWithFrame:CGRectMake(10, label.bottom, SCREEN_WIDTH-10*2, 0)];
			label.text = @"注：每年1~3月邮寄上年全年税票";
			label.textColor = COLOR999;
			label.font = FONT(13);
			label.backgroundColor = [UIColor clearColor];
			[_scroll addSubview:label];
			[label autoHeight];
		}
	}
	
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.lastSubview.bottom);
}

- (void)GlobalExecuteWithCaller:(UIViewController*)caller data:(NSDictionary*)data{
	_labelBank.text = STRINGFORMAT(@"%@ 尾号%@ %@", data[@"bank_name"], [STRING(data[@"card_number"]) right:4], data[@"name"]);
	_bank_id = data[@"id"];
}

- (void)AJPickerView:(AJPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	_labelShipping.text = _ms[row];
	_shipping_company = _ms[row];
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)pass{
	[self backgroundTap];
	if (!_withdraw_money.text.length) {
		[ProgressHUD showError:@"请输入提现金额"];
		return;
	}
	if (_withdraw_money.text.floatValue<100) {
		[ProgressHUD showError:@"提现金额一次不少于100元"];
		return;
	}
	if (_withdraw_money.text.floatValue>[_can_withdraw_money floatValue]) {
		[ProgressHUD showError:@"提现金额不合法"];
		return;
	}
	if (!_bank_id.length) {
		[ProgressHUD showError:@"请选择提现账户"];
		return;
	}
	[ProgressHUD show:nil];
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:_withdraw_money.text forKey:@"withdraw_money"];
	[postData setValue:_bank_id forKey:@"bank_account_id"];
	if ([_person[@"member_type"]intValue]==2) {
		if ([_person[@"shop"][@"reseller_type"]intValue]==1) {
			[postData setValue:_invoice_number.text forKey:@"invoice_number"];
			[postData setValue:_shipping_number.text forKey:@"shipping_number"];
			[postData setValue:_shipping_company forKey:@"shipping_company"];
		} else {
			[postData setValue:@(_switch.on) forKey:@"person_income"];
		}
	}
	[Common postApiWithParams:@{@"app":@"withdraw", @"act":@"apply"} data:postData feedback:@"提交成功，我们将会尽快审核" success:^(NSMutableDictionary *json) {
		[self.navigationController popViewControllerAnimated:YES];
	} fail:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
