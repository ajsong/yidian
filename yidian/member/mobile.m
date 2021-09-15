//
//  mobile.m
//
//  Created by ajsong on 15/6/5.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "AppDelegate+EaseMob.h"
#import "mobile.h"
#import "login.h"

@interface mobile ()<UITextFieldDelegate>{
	SpecialTextField *_mobile;
	SpecialTextField *_code;
	SpecialTextField *_name;
	SpecialTextField *_password;
	
	UIButton *_countBtn;
	NSString *_mobileText;
	NSString *_codeText;
	NSTimer *_timer;
	NSInteger _count;
	BOOL _getCode;
	UIActivityIndicatorView *_activity;
}
@end

@implementation mobile

- (void)pushReturn{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pushLogin{
	login *e = [[login alloc]init];
	e.isFromMobile = YES;
	[self.navigationController pushViewController:e animated:YES];
}

- (void)returnLogin{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	[ProgressHUD dismiss:1.0];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"注册";
	self.view.backgroundColor = BACKCOLOR;
	[self.navigationController setBackgroundColor:NAVBGCOLOR textColor:NAVTEXTCOLOR];
	
	if (_isFirst) {
		KKNavigationBarItem *item = [self.navigationItem setItemWithImage:IMG(@"return-white") size:CGSizeMake(44, 44) itemType:KKNavigationItemTypeLeft];
		[item addTarget:self action:@selector(pushReturn) forControlEvents:UIControlEventTouchUpInside];
		
		item = [self.navigationItem setItemWithTitle:@"登录" textColor:WHITE fontSize:14 itemType:KKNavigationItemTypeRight];
		[item addTarget:self action:@selector(pushLogin) forControlEvents:UIControlEventTouchUpInside];
	}
	
	_timer = nil;
	
	_mobile = [[SpecialTextField alloc]initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH-15*2, 44)];
	_mobile.placeholder = @"手机号码";
	_mobile.textColor = [UIColor blackColor];
	_mobile.font = [UIFont systemFontOfSize:14];
	_mobile.backgroundColor = WHITE;
	_mobile.layer.borderColor = COLORRGB(@"e1e1e1").CGColor;
	_mobile.layer.borderWidth = 1;
	_mobile.layer.masksToBounds = YES;
	_mobile.layer.cornerRadius = 4;
	_mobile.keyboardType = UIKeyboardTypePhonePad;
	_mobile.clearButtonMode = UITextFieldViewModeWhileEditing;
	[self.view addSubview:_mobile];
	_mobile.padding = UIEdgeInsetsMake(0, 39, 0, 0);
	UIImageView *leftView = [[UIImageView alloc]initWithFrame:CGRectMake(_mobile.left, _mobile.top, 39, 44)];
	leftView.image = [UIImage imageNamed:@"m-mobile-ico"];
	[self.view addSubview:leftView];
	
	_code = [[SpecialTextField alloc]initWithFrame:CGRectMake(_mobile.left, _mobile.bottom+10, 160, _mobile.height)];
	_code.placeholder = @"验证码";
	_code.textColor = [UIColor blackColor];
	_code.font = [UIFont systemFontOfSize:14];
	_code.backgroundColor = WHITE;
	_code.layer.borderColor = COLORRGB(@"e1e1e1").CGColor;
	_code.layer.borderWidth = 1;
	_code.layer.masksToBounds = YES;
	_code.layer.cornerRadius = 4;
	_code.keyboardType = UIKeyboardTypeNumberPad;
	_code.clearButtonMode = UITextFieldViewModeWhileEditing;
	[self.view addSubview:_code];
	_code.padding = UIEdgeInsetsMake(0, 39, 0, 0);
	leftView = [[UIImageView alloc]initWithFrame:CGRectMake(_code.left, _code.top, 39, 44)];
	leftView.image = [UIImage imageNamed:@"m-code-ico"];
	[self.view addSubview:leftView];
	
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
	_activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	_activity.center = CGPointMake(_countBtn.width/2, _countBtn.height/2);
	_activity.hidesWhenStopped = YES;
	[_countBtn addSubview:_activity];
	
	_name = [[SpecialTextField alloc]initWithFrame:CGRectMake(_mobile.left, _code.bottom+10, _mobile.width, _mobile.height)];
	_name.placeholder = @"用户名 (注册后不可更改)";
	_name.textColor = [UIColor blackColor];
	_name.font = [UIFont systemFontOfSize:14];
	_name.backgroundColor = WHITE;
	_name.layer.borderColor = COLORRGB(@"e1e1e1").CGColor;
	_name.layer.borderWidth = 1;
	_name.layer.masksToBounds = YES;
	_name.layer.cornerRadius = 4;
	_name.clearButtonMode = UITextFieldViewModeWhileEditing;
	[self.view addSubview:_name];
	_name.padding = UIEdgeInsetsMake(0, 39, 0, 0);
	leftView = [[UIImageView alloc]initWithFrame:CGRectMake(_name.left, _name.top, 39, 44)];
	leftView.image = [UIImage imageNamed:@"m-username-ico"];
	[self.view addSubview:leftView];
	
	_password = [[SpecialTextField alloc]initWithFrame:CGRectMake(_mobile.left, _name.bottom+10, _mobile.width, _mobile.height)];
	_password.placeholder = @"密码";
	_password.textColor = [UIColor blackColor];
	_password.font = [UIFont systemFontOfSize:14];
	_password.backgroundColor = WHITE;
	_password.layer.borderColor = COLORRGB(@"e1e1e1").CGColor;
	_password.layer.borderWidth = 1;
	_password.layer.masksToBounds = YES;
	_password.layer.cornerRadius = 4;
	_password.secureTextEntry = YES;
	_password.delegate = self;
	[self.view addSubview:_password];
	_password.padding = UIEdgeInsetsMake(0, 39, 0, 0);
	leftView = [[UIImageView alloc]initWithFrame:CGRectMake(_password.left, _password.top, 39, 44)];
	leftView.image = [UIImage imageNamed:@"m-password-ico"];
	[self.view addSubview:leftView];
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(_mobile.left, _password.bottom+10, _mobile.width, 40);
	btn.titleLabel.font = [UIFont systemFontOfSize:15];
	btn.backgroundColor = MAINSUBCOLOR;
	[btn setTitle:@"注册" forState:UIControlStateNormal];
	[btn setTitleColor:WHITE forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchUpInside];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 4;
	[self.view addSubview:btn];
	
	SpecialLabel *agress = [[SpecialLabel alloc]initWithFrame:CGRectMake(btn.left, btn.bottom+10, btn.width, 20)];
	agress.text = @"点击注册表示已同意优必上用户服务协议";
	agress.textColor = SYSTEM_BLUE;
	agress.font = [UIFont systemFontOfSize:13];
	agress.backgroundColor = [UIColor clearColor];
	[agress click:^(UIView *view, UIGestureRecognizer *sender) {
		outlet *e = [[outlet alloc]init];
		e.title = @"用户协议";
		e.url = STRINGFORMAT(@"%@/wap.php?app=article&act=detail&id=3", API_URL);
		e.leftImage = IMG(@"return-white");
		[self.navigationController pushViewController:e animated:YES];
	}];
	[self.view addSubview:agress];
	//agress.lineType = LineTypeBottom;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[self pass];
	return YES;
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
	[_countBtn setTitle:@"" forState:UIControlStateNormal];
	[_activity startAnimating];
	NSMutableDictionary *postData = [NSMutableDictionary dictionary];
	[postData setValue:_mobile.text forKey:@"mobile"];
	[Common postApiWithParams:@{@"app":@"passport", @"act":@"check_mobile"} data:postData feedback:nil success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		_mobileText = STRING(json[@"data"][@"mobile"]);
		_codeText = STRING(json[@"data"][@"code"]);
		NSLog(@"%@", _codeText);
		_count = 60;
		_countBtn.backgroundColor = COLOR999;
		[_countBtn setTitle:STRINGFORMAT(@"%lds后重新获取",(long)_count) forState:UIControlStateNormal];
		[_activity stopAnimating];
		[_code becomeFirstResponder];
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
	} fail:^(NSMutableDictionary *json) {
		if (json.isDictionary) [ProgressHUD showError:json[@"msg"]];
		_getCode = NO;
		[_countBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
		[_activity stopAnimating];
	}];
}

- (void)pass{
	[self backgroundTap];
	if (!_mobile.text.length || !_code.text.length || !_name.text.length || !_password.text.length) {
		[ProgressHUD showError:@"请输入手机号码、验证码、用户名、密码"];
		return;
	}
	if (![_mobile.text isEqualToString:_mobileText]) {
		[ProgressHUD showError:@"手机号码不正确"];
		return;
	}
	if ([_code.text integerValue] != [_codeText integerValue]) {
		[ProgressHUD showError:@"验证码不正确"];
		return;
	}
	[ProgressHUD show:nil];
	NSMutableDictionary *postData = [NSMutableDictionary dictionary];
	[postData setValue:[@"udid" getUserDefaultsString] forKey:@"udid"];
	[postData setValue:_mobile.text forKey:@"mobile"];
	[postData setValue:_code.text forKey:@"code"];
	[postData setValue:_name.text forKey:@"name"];
	[postData setValue:_password.text forKey:@"password"];
	[Common postApiWithParams:@{@"app":@"passport", @"act":@"register"} data:postData feedback:@"注册成功" success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		[@"person" setUserDefaultsWithData:json[@"data"]];
		//直接登录, 注册由接口完成
		[EaseSDKHelper loginWithUsername:STRING(json[@"data"][@"id"]) password:_password.text success:^{
			[EaseSDKHelper updateNickname:_name.text];
		}];
		[self dismissViewControllerAnimated:YES completion:nil];
	} fail:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
