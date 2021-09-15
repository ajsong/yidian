//
//  login.m
//
//  Created by ajsong on 15/6/4.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "AppDelegate+EaseMob.h"
#import "login.h"
#import "mobile.h"
#import "forget.h"

@interface login ()<UITextFieldDelegate>{
	UITextField *_name;
	UITextField *_password;
}
@end

@implementation login

- (void)pushReturn{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pushMobile{
	mobile *e = [[mobile alloc]init];
	[self.navigationController pushViewController:e animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	[ProgressHUD dismiss:1.0];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"登录";
	self.view.backgroundColor = BACKCOLOR;
	[self.navigationController setBackgroundColor:NAVBGCOLOR textColor:NAVTEXTCOLOR];
	
	if (!_isFromMobile) {
		KKNavigationBarItem *item;
		
		//item = [self.navigationItem setItemWithImage:IMG(@"return-white") size:CGSizeMake(44, 44) itemType:KKNavigationItemTypeLeft];
		//[item addTarget:self action:@selector(pushReturn) forControlEvents:UIControlEventTouchUpInside];
		
		item = [self.navigationItem setItemWithTitle:@"注册" textColor:WHITE fontSize:14 itemType:KKNavigationItemTypeRight];
		[item addTarget:self action:@selector(pushMobile) forControlEvents:UIControlEventTouchUpInside];
	}
	
	UIImageView *input = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-302)/2, 15, 302, 93)];
	input.image = [UIImage imageNamed:@"m-login-input"];
	[self.view addSubview:input];
	
	_name = [[UITextField alloc]initWithFrame:CGRectMake(input.left+42, input.top+2, input.width-42, 47)];
	_name.placeholder = @"用户名或手机号码";
	_name.textColor = [UIColor blackColor];
	_name.font = [UIFont systemFontOfSize:14];
	_name.backgroundColor = [UIColor clearColor];
	_name.clearButtonMode = UITextFieldViewModeWhileEditing;
	//_name.keyboardType = UIKeyboardTypeASCIICapable;
	[self.view addSubview:_name];
	
	_password = [[UITextField alloc]initWithFrame:CGRectMake(_name.left, _name.bottom, _name.width, _name.height)];
	_password.placeholder = @"请输入密码";
	_password.textColor = [UIColor blackColor];
	_password.font = [UIFont systemFontOfSize:14];
	_password.backgroundColor = [UIColor clearColor];
	_password.secureTextEntry = YES;
	_password.clearsOnBeginEditing = YES;
	_password.returnKeyType = UIReturnKeyDone;
	_password.delegate = self;
	[self.view addSubview:_password];
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(input.left, input.bottom+18, input.width, 41);
	btn.titleLabel.font = [UIFont systemFontOfSize:15];
	btn.backgroundColor = MAINSUBCOLOR;
	[btn setTitle:@"登 录" forState:UIControlStateNormal];
	[btn setTitleColor:WHITE forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchUpInside];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 4;
	[self.view addSubview:btn];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(btn.right-btn.width/2, btn.bottom+15, btn.width/2, 20)];
	label.text = @"忘记密码";
	label.textColor = COLORRGB(@"666");
	label.textAlignment = NSTextAlignmentRight;
	label.font = [UIFont systemFontOfSize:13];
	label.backgroundColor = [UIColor clearColor];
	[label click:^(UIView *view, UIGestureRecognizer *sender) {
		forget *e = [[forget alloc]init];
		[self.navigationController pushViewController:e animated:YES];
	}];
	[self.view addSubview:label];
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
	if (!_name.text.length || !_password.text.length) {
		[ProgressHUD showError:@"请输入用户名与密码"];
		return;
	}
	[ProgressHUD show:nil];
	NSMutableDictionary *postData = [NSMutableDictionary dictionary];
	[postData setValue:[@"udid" getUserDefaultsString] forKey:@"udid"];
	[postData setValue:_name.text forKey:@"name"];
	[postData setValue:_password.text forKey:@"password"];
	[Common postApiWithParams:@{@"app":@"passport", @"act":@"login"} data:postData feedback:@"登录成功" success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		[@"person" setUserDefaultsWithData:json[@"data"]];
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
