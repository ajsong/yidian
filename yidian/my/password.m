//
//  password.m
//  xytao
//
//  Created by ajsong on 15/5/29.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import "password.h"

@interface password (){
	NSDictionary *_person;
	SpecialTextField *_password;
	SpecialTextField *_newpass;
	SpecialTextField *_repass;
}
@end

@implementation password

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"修改密码";
	self.view.backgroundColor = BACKCOLOR;
	self.navigationController.navigationBar.translucent = NO;
	[[IQKeyboardManager sharedManager] considerToolbarPreviousNextInViewClass:[UIScrollView class]];
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"保存" textColor:WHITE fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchUpInside];
	
	_person = PERSON;
	
	UIFont *font = [UIFont systemFontOfSize:15];
	UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	scroll.contentSize = CGSizeMake(scroll.frame.size.width, scroll.frame.size.height);
	[self.view addSubview:scroll];
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 94, view.height)];
	label.text = @"旧密码";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_password = [[SpecialTextField alloc]initWithFrame:CGRectMake(label.right, 0, view.width-label.right-10-(40+10), view.height)];
	_password.placeholder = @"请输入旧密码";
	_password.textColor = [UIColor blackColor];
	_password.font = font;
	_password.backgroundColor = [UIColor clearColor];
	_password.secureTextEntry = YES;
	[view addSubview:_password];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"新密码";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_newpass = [[SpecialTextField alloc]initWithFrame:_password.frame];
	_newpass.placeholder = @"请输入新密码";
	_newpass.textColor = [UIColor blackColor];
	_newpass.font = font;
	_newpass.backgroundColor = [UIColor clearColor];
	_newpass.secureTextEntry = YES;
	[view addSubview:_newpass];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"确认密码";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_repass = [[SpecialTextField alloc]initWithFrame:_password.frame];
	_repass.placeholder = @"请再次输入新密码";
	_repass.textColor = [UIColor blackColor];
	_repass.font = font;
	_repass.backgroundColor = [UIColor clearColor];
	_repass.secureTextEntry = YES;
	[view addSubview:_repass];
	
	view = _password.superview;
	UISwitch *secureSwitch = [[UISwitch alloc]init];
	secureSwitch.onTintColor = MAINCOLOR;
	[view addSubview:secureSwitch];
	secureSwitch.origin = CGPointMake(view.width-secureSwitch.width-10, (view.height-secureSwitch.height)/2);
	[secureSwitch addControlEvent:UIControlEventValueChanged withBlock:^(id sender) {
		[self backgroundTap];
		BOOL secureTextEntry = _password.secureTextEntry;
		_password.secureTextEntry = !secureTextEntry;
		_newpass.secureTextEntry = !secureTextEntry;
		_repass.secureTextEntry = !secureTextEntry;
	}];
	UILabel *secureLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 24, secureSwitch.height)];
	secureLabel.text = @"ABC";
	secureLabel.textColor = [UIColor whiteColor];
	secureLabel.textAlignment = NSTextAlignmentCenter;
	secureLabel.font = FONT(7);
	secureLabel.backgroundColor = [UIColor clearColor];
	[secureSwitch addSubview:secureLabel];
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)pass{
	[self backgroundTap];
	if (!_password.text.length || !_newpass.text.length || !_repass.text.length) {
		[ProgressHUD showError:@"请填写完整"];
		return;
	}
	if (![_newpass.text isEqualToString:_repass.text]) {
		[ProgressHUD showError:@"两次密码不一致"];
		return;
	}
	
	[ProgressHUD show:nil];
	NSMutableDictionary *postData = [NSMutableDictionary dictionary];
	[postData setValue:_password.text forKey:@"origin_password"];
	[postData setValue:_newpass.text forKey:@"new_password"];
	[Common postApiWithParams:@{@"app":@"member", @"act":@"password"} data:postData feedback:@"修改成功" success:^(NSMutableDictionary *json) {
		[self.navigationController popViewControllerAnimated:YES];
	} fail:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
