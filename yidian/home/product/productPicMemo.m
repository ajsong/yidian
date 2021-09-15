//
//  productPicMemo.m
//  yidian
//
//  Created by ajsong on 16/1/23.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "productPicMemo.h"
#import "GlobalDelegate.h"

@interface productPicMemo (){
	SpecialTextView *_content;
}
@end

@implementation productPicMemo

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"图片描述";
	self.view.backgroundColor = BACKCOLOR;
	[self.navigationController setBackgroundColor:NAVBGCOLOR textColor:NAVTEXTCOLOR];
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"确定" textColor:WHITE fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchUpInside];
	
	UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
	[self.view addSubview:scrollView];
	
	_content = [[SpecialTextView alloc]initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-10*2, scrollView.height-10*2)];
	if (_data.isDictionary) _content.text = _data[@"memo"];
	_content.font = [UIFont systemFontOfSize:14.f];
	_content.backgroundColor = [UIColor clearColor];
	[scrollView addSubview:_content];
	_content.placeholder = @"请输入图片的描述";
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)pass{
	[self backgroundTap];
	if (_delegate && [_delegate respondsToSelector:@selector(GlobalExecuteWithData:)]) {
		[_delegate GlobalExecuteWithData:@{@"memo":_content.text, @"browser":_browser}];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
