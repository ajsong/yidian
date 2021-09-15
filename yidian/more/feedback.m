//
//  feedback.m
//
//  Created by ajsong on 15/5/21.
//  Copyright (c) 2014 ajsong. All rights reserved.
//

#import "Global.h"
#import "feedback.h"

@interface feedback (){
	SpecialTextView *_content;
}
@end

@implementation feedback

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"意见反馈";
	self.view.backgroundColor = BACKCOLOR;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"提交" textColor:WHITE fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchUpInside];
	
	UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
	[self.view addSubview:scrollView];
	
	_content = [[SpecialTextView alloc]initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-10*2, scrollView.height-10*2)];
	_content.font = [UIFont systemFontOfSize:14.f];
	_content.backgroundColor = [UIColor clearColor];
	[scrollView addSubview:_content];
	_content.placeholder = @"欢迎您反馈意见和问题，这将是我们产品进步的动力！";
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)pass{
	if (!_content.text.length) {
		[ProgressHUD showError:@"请输入内容"];
		return;
	}
	[self backgroundTap];
	[ProgressHUD show:nil];
	NSMutableDictionary *postData = [NSMutableDictionary dictionary];
	[postData setValue:_content.text forKey:@"content"];
	[Common postApiWithParams:@{@"app":@"member", @"act":@"feedback"} data:postData feedback:@"非常感谢您的反馈" success:^(NSMutableDictionary *json) {
		[self.navigationController popViewControllerAnimated:YES];
	} fail:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
