//
//  edit.m
//  xytao
//
//  Created by ajsong on 15/5/29.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import "edit.h"

@interface edit (){
	NSDictionary *_person;
	//UITextField *_real_name;
	SpecialTextField *_mobile;
	UITextField *_qq;
	UITextField *_weixin;
}
@end

@implementation edit

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"个人资料";
	self.view.backgroundColor = BACKCOLOR;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"保存" textColor:WHITE fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchUpInside];
	
	_person = PERSON;
	
	UIFont *font = [UIFont systemFontOfSize:14];
	
	UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	scroll.contentSize = CGSizeMake(scroll.frame.size.width, scroll.frame.size.height);
	[self.view addSubview:scroll];
	
	/*
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 94, view.height)];
	label.text = @"真实姓名";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_real_name = [[UITextField alloc]initWithFrame:CGRectMake(label.right, 0, view.width-label.right, view.height)];
	_real_name.text = _person[@"real_name"];
	_real_name.placeholder = @"请输入姓名";
	_real_name.textColor = COLOR666;
	_real_name.font = font;
	_real_name.backgroundColor = [UIColor clearColor];
	_real_name.clearButtonMode = UITextFieldViewModeWhileEditing;
	[view addSubview:_real_name];
	*/
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 94, view.height)];
	label.text = @"电话";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_mobile = [[SpecialTextField alloc]initWithFrame:CGRectMake(label.right, 0, view.width-label.right, view.height)];
	_mobile.text = _person[@"mobile"];
	_mobile.placeholder = @"请输入手机号码";
	_mobile.textColor = COLOR666;
	_mobile.font = font;
	_mobile.backgroundColor = [UIColor clearColor];
	_mobile.keyboardType = UIKeyboardTypePhonePad;
	_mobile.clearButtonMode = UITextFieldViewModeWhileEditing;
	_mobile.enabled = NO;
	[view addSubview:_mobile];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"QQ";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_qq = [[UITextField alloc]initWithFrame:_mobile.frame];
	_qq.text = _person[@"qq"];
	_qq.placeholder = @"请输入QQ";
	_qq.textColor = COLOR666;
	_qq.font = font;
	_qq.backgroundColor = [UIColor clearColor];
	_qq.keyboardType = UIKeyboardTypeNumberPad;
	_qq.clearButtonMode = UITextFieldViewModeWhileEditing;
	[view addSubview:_qq];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"微信";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_weixin = [[UITextField alloc]initWithFrame:_mobile.frame];
	_weixin.text = _person[@"weixin"];
	_weixin.placeholder = @"请输入微信账号";
	_weixin.textColor = COLOR666;
	_weixin.font = font;
	_weixin.backgroundColor = [UIColor clearColor];
	_weixin.clearButtonMode = UITextFieldViewModeWhileEditing;
	[view addSubview:_weixin];
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)pass{
	[self backgroundTap];
	/*
	if (!_real_name.text.length) {
		[ProgressHUD showError:@"请填写真实姓名"];
		return;
	}
	*/
	if (!_mobile.text.length) {
		[ProgressHUD showError:@"请填写手机号码"];
		return;
	}
	[ProgressHUD show:nil];
	NSMutableDictionary *postData = [NSMutableDictionary dictionary];
	//[postData setValue:_real_name.text forKey:@"real_name"];
	//[postData setValue:_mobile.text forKey:@"mobile"];
	[postData setValue:_qq.text forKey:@"qq"];
	[postData setValue:_weixin.text forKey:@"weixin"];
	[Common postApiWithParams:@{@"app":@"member", @"act":@"edit_info"} data:postData feedback:@"修改成功" success:^(NSMutableDictionary *json) {
		[_person merge:postData];
		[@"person" setUserDefaultsWithData:_person];
		[self.navigationController popViewControllerAnimated:YES];
	} fail:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
