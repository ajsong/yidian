//
//  rechargeComplete.m
//
//  Created by ajsong on 16/2/26.
//  Copyright (c) 2016年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import "annualComplete.h"

@interface annualComplete ()

@end

@implementation annualComplete

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	self.navigationControllerKK.enableDragBack = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	self.navigationControllerKK.enableDragBack = YES;
}

- (void)pushReturn{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"续费成功";
	self.view.backgroundColor = WHITE;
	self.edgesForExtendedLayout = UIRectEdgeNone;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithImage:IMG(@"return") size:CGSizeMake(44, 44) itemType:KKNavigationItemTypeLeft];
	[item addTarget:self action:@selector(pushReturn) forControlEvents:UIControlEventTouchUpInside];
	
	UIImageView *pic = [[UIImageView alloc]initWithFrame:CGRectMakeScale(0, 0, SCREEN_WIDTH, 155)];
	pic.image = IMG(@"c-complete");
	[self.view addSubview:pic];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, pic.bottom, SCREEN_WIDTH, 22)];
	label.text = @"恭喜您，续费成功！";
	label.textColor = MAINCOLOR;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONTBOLD(18);
	label.backgroundColor = [UIColor clearColor];
	[self.view addSubview:label];
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake((SCREEN_WIDTH-150)/2, label.bottom+15, 150, 35);
	btn.titleLabel.font = FONT(13);
	btn.backgroundColor = MAINSUBCOLOR;
	[btn setTitle:@"返回首页" forState:UIControlStateNormal];
	[btn setTitleColor:WHITE forState:UIControlStateNormal];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 3;
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[self pushReturn];
	}];
	[self.view addSubview:btn];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
