//
//  applyComplete.m
//  ejdian
//
//  Created by ajsong on 15/6/8.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import "shopApplyComplete.h"

@interface shopApplyComplete ()

@end

@implementation shopApplyComplete

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	self.navigationControllerKK.enableDragBack = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	self.navigationControllerKK.enableDragBack = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"完成";
	self.view.backgroundColor = WHITE;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithImage:IMG(@"return-white") size:CGSizeMake(44, 44) itemType:KKNavigationItemTypeLeft];
	[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	}];
	
	UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-220)/2, 0, 220, 200)];
	logo.image = [UIImage imageNamed:@"h-complete-logo"];
	[self.view addSubview:logo];
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(35, logo.bottom+20, SCREEN_WIDTH-35*2, 40);
	btn.titleLabel.font = [UIFont systemFontOfSize:15];
	btn.backgroundColor = MAINSUBCOLOR;
	[btn setTitle:@"返回" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	}];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 4;
	[self.view addSubview:btn];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
