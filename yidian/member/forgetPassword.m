//
//  forgetPassword.m
//  xytao
//
//  Created by ajsong on 15/5/29.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import "forgetPassword.h"

@interface forgetPassword (){
	SpecialTextField *_password;
}
@end

@implementation forgetPassword

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"忘记密码";
	self.view.backgroundColor = BACKCOLOR;
	
	UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backBtn;
	
	UILabel *tip = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-16*2, 48)];
	tip.text = @"请设置新的密码";
	tip.textColor = COLOR999;
	tip.font = [UIFont systemFontOfSize:13];
	tip.backgroundColor = [UIColor clearColor];
	[self.view addSubview:tip];
	
	_password = [[SpecialTextField alloc]initWithFrame:CGRectMake(15, tip.bottom, tip.width, 44)];
	_password.placeholder = @"设置新密码";
	_password.textColor = [UIColor blackColor];
	_password.font = [UIFont systemFontOfSize:14];
	_password.backgroundColor = WHITE;
	_password.layer.borderColor = COLORRGB(@"e1e1e1").CGColor;
	_password.layer.borderWidth = 1;
	_password.layer.masksToBounds = YES;
	_password.layer.cornerRadius = 4;
	_password.secureTextEntry = YES;
	[self.view addSubview:_password];
	_password.padding = UIEdgeInsetsMake(0, 15, 0, 0);
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(_password.left, _password.bottom+15, _password.width, 40);
	btn.titleLabel.font = [UIFont systemFontOfSize:15];
	btn.backgroundColor = MAINSUBCOLOR;
	[btn setTitle:@"提交" forState:UIControlStateNormal];
	[btn setTitleColor:WHITE forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchUpInside];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 4;
	[self.view addSubview:btn];
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)pass{
	[self backgroundTap];
	if (!_password.text.length) {
		[ProgressHUD showError:@"请输入密码"];
		return;
	}
	[ProgressHUD show:nil];
	NSMutableDictionary *postData = [NSMutableDictionary dictionary];
	[postData setValue:_mobile forKey:@"mobile"];
	[postData setValue:_code forKey:@"code"];
	[postData setValue:_password.text forKey:@"password"];
	[Common postApiWithParams:@{@"app":@"passport", @"act":@"forget"} data:postData feedback:@"设置成功" success:^(NSMutableDictionary *json) {
		[self dismissViewControllerAnimated:YES completion:nil];
	} fail:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
