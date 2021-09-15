//
//  forget.m
//  xytao
//
//  Created by ajsong on 15/5/28.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import "forget.h"
#import "forgetPassword.h"

@interface forget (){
	SpecialTextField *_mobile;
	SpecialTextField *_code;
	UIButton *_countBtn;
	
	NSString *_mobileText;
	NSString *_codeText;
	NSTimer *_timer;
	NSInteger _count;
	BOOL _getCode;
}
@end

@implementation forget

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"忘记密码";
	self.view.backgroundColor = BACKCOLOR;
	
	UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backBtn;
	
	_timer = nil;
	
	UILabel *tip = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-16*2, 48)];
	tip.text = @"请输入您在优必上注册时的手机号码";
	tip.textColor = COLOR999;
	tip.font = [UIFont systemFontOfSize:13];
	tip.backgroundColor = [UIColor clearColor];
	[self.view addSubview:tip];
	
	_mobile = [[SpecialTextField alloc]initWithFrame:CGRectMake(15, tip.bottom, tip.width, 44)];
	_mobile.placeholder = @"手机号码";
	_mobile.textColor = [UIColor blackColor];
	_mobile.font = [UIFont systemFontOfSize:14];
	_mobile.backgroundColor = WHITE;
	_mobile.layer.borderColor = COLORRGB(@"e1e1e1").CGColor;
	_mobile.layer.borderWidth = 1;
	_mobile.layer.masksToBounds = YES;
	_mobile.layer.cornerRadius = 4;
	_mobile.clearButtonMode = UITextFieldViewModeWhileEditing;
	[self.view addSubview:_mobile];
	_mobile.padding = UIEdgeInsetsMake(0, 39, 0, 0);
	
	UIImageView *leftView = [[UIImageView alloc]initWithFrame:CGRectMake(_mobile.left, _mobile.top, 39, 44)];
	leftView.image = [UIImage imageNamed:@"m-mobile-ico"];
	[self.view addSubview:leftView];
	
	_code = [[SpecialTextField alloc]initWithFrame:CGRectMake(_mobile.left, _mobile.bottom+15, 160, _mobile.height)];
	_code.placeholder = @"验证码";
	_code.textColor = [UIColor blackColor];
	_code.font = [UIFont systemFontOfSize:14];
	_code.backgroundColor = WHITE;
	_code.layer.borderColor = COLORRGB(@"e1e1e1").CGColor;
	_code.layer.borderWidth = 1;
	_code.layer.masksToBounds = YES;
	_code.layer.cornerRadius = 4;
	_code.clearButtonMode = UITextFieldViewModeWhileEditing;
	[self.view addSubview:_code];
	_code.padding = UIEdgeInsetsMake(0, 10, 0, 10);
	
	_countBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	_countBtn.frame = CGRectMake(_code.right+15, _code.top, _mobile.right-_code.right-15, _mobile.height);
	_countBtn.titleLabel.font = [UIFont systemFontOfSize:14];
	_countBtn.backgroundColor = MAINSUBCOLOR;
	[_countBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
	[_countBtn setTitleColor:WHITE forState:UIControlStateNormal];
	[_countBtn addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
	_countBtn.layer.masksToBounds = YES;
	_countBtn.layer.cornerRadius = 4;
	[self.view addSubview:_countBtn];
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(_mobile.left, _code.bottom+15, _mobile.width, 40);
	btn.titleLabel.font = [UIFont systemFontOfSize:15];
	btn.backgroundColor = MAINSUBCOLOR;
	[btn setTitle:@"下一步" forState:UIControlStateNormal];
	[btn setTitleColor:WHITE forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchUpInside];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 4;
	[self.view addSubview:btn];
}

- (void)returnLogin{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)getCode{
	[self backgroundTap];
	if (_getCode) return;
	if (!_mobile.text.length) {
		[ProgressHUD showError:@"请输入手机号码"];
		return;
	}
	_getCode = YES;
	_mobileText = @"";
	_codeText = @"";
	NSMutableDictionary *postData = [NSMutableDictionary dictionary];
	[postData setValue:_mobile.text forKey:@"mobile"];
	[Common postApiWithParams:@{@"app":@"passport", @"act":@"forget_send_sms"} data:postData feedback:nil success:^(NSMutableDictionary *json) {
		_mobileText = STRING(json[@"data"][@"mobile"]);
		_codeText = STRING(json[@"data"][@"code"]);
		NSLog(@"%@", _codeText);
		[_code becomeFirstResponder];
		_count = 60;
		_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 block:^{
			_count--;
			if (_count<=0) {
				[_timer invalidate];
				_timer = nil;
				_countBtn.backgroundColor = MAINSUBCOLOR;
				[_countBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
				_getCode = NO;
			} else {
				_countBtn.backgroundColor = COLOR999;
				[_countBtn setTitle:STRINGFORMAT(@"%lds后重新获取",(long)_count) forState:UIControlStateNormal];
			}
		} repeats:YES];
	} fail:nil];
}

- (void)pass{
	[self backgroundTap];
	if (!_mobile.text.length || !_code.text.length) {
		[ProgressHUD showError:@"请输入手机号码与验证码"];
		return;
	}
	if (![_mobile.text isEqualToString:_mobileText]) {
		[ProgressHUD showError:@"手机号码不正确"];
		return;
	}
	if (![_code.text isEqualToString:_codeText]) {
		[ProgressHUD showError:@"验证码不正确"];
		return;
	}
	forgetPassword *g = [[forgetPassword alloc]init];
	g.mobile = _mobile.text;
	g.code = _code.text;
	[self.navigationController pushViewController:g animated:YES];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
