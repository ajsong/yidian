//
//  bulkChatPost.m
//  ejdian
//
//  Created by ajsong on 15/9/7.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "AppDelegate+EaseMob.h"
#import "bulkChatPost.h"
#import "fans.h"

@interface bulkChatPost (){
	NSDictionary *_person;
	SpecialTextView *_content;
}
@end

@implementation bulkChatPost

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"群发消息";
	self.view.backgroundColor = BACKCOLOR;
	
	_person = PERSON;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"发送" textColor:WHITE fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addTarget:self action:@selector(sendText) forControlEvents:UIControlEventTouchUpInside];
	
	UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	scrollView.contentSize = CGSizeMake(scrollView.width, scrollView.height);
	[self.view addSubview:scrollView];
	
	_content = [[SpecialTextView alloc]initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-10*2, scrollView.height-10*2)];
	_content.placeholder = @"请输入要群发的内容，点击右上角发送！";
	_content.font = [UIFont systemFontOfSize:14.f];
	_content.backgroundColor = [UIColor clearColor];
	[scrollView addSubview:_content];
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)sendText{
	if (!_content.text.length) {
		[ProgressHUD showError:@"请输入消息"];
		return;
	}
	[self backgroundTap];
	[ProgressHUD show:nil];
	
	for (int i=0; i<_userID.count; i++) {
		NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
		[postData setValue:_person[@"name"] forKey:@"from"];
		[postData setValue:_person[@"id"] forKey:@"from_id"];
		[postData setValue:_userID[i] forKey:@"chatter"];
		[postData setValue:_content.text forKey:@"content"];
		[Common postApiWithParams:@{@"app":@"chat", @"act":@"send"} data:postData feedback:nil success:nil fail:nil];
		
		EMMessage *message = [EaseSDKHelper sendTextMessage:_content.text
														 to:_userID[i]
												messageType:EMChatTypeChat
												 messageExt:@{
															  @"member_id" : _person[@"id"],
															  @"member_name" : _person[@"name"],
															  @"member_avatar" : _person[@"avatar"],
															  @"goods_id" : @"",
															  @"goods_name" : @"",
															  @"goods_image" : @""
															  }];
		[EaseSDKHelper sendMessage:message completion:nil];
	}
	[ProgressHUD showSuccess:@"发送成功"];
	[self.navigationController popToViewControllerOfClass:[fans class] animated:YES];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
