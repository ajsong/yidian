//
//  shopVerifyDetail.m
//  yidian
//
//  Created by ajsong on 16/1/5.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "shopVerifyDetail.h"

@interface shopVerifyDetail ()

@end

@implementation shopVerifyDetail

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"审核申请";
	self.view.backgroundColor = BACKCOLOR;
	
	UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	[self.view addSubview:scroll];
	
	UIImageView *avatar = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-82)/2, 22, 82, 82)];
	avatar.image = IMG(@"avatar");
	avatar.url = _data[@"avatar"];
	avatar.layer.masksToBounds = YES;
	avatar.layer.cornerRadius = 41;
	[scroll addSubview:avatar];
	
	UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(0, avatar.bottom, SCREEN_WIDTH, 30)];
	name.text = _data[@"name"];
	name.textColor = [UIColor blackColor];
	name.textAlignment = NSTextAlignmentCenter;
	name.font = [UIFont systemFontOfSize:16];
	name.backgroundColor = [UIColor clearColor];
	[scroll addSubview:name];
	
	UIFont *font = [UIFont systemFontOfSize:14];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, name.bottom+10, SCREEN_WIDTH-15*2, 44)];
	label.text = @"申请成为我的渠道商";
	label.textColor = COLOR777;
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[scroll addSubview:label];
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, label.bottom, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	[view addGeWithType:GeLineTypeTop];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 85, view.height)];
	label.text = @"联系电话";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	UILabel *value = [[UILabel alloc]initWithFrame:CGRectMake(label.right, 0, view.width-label.right-10, view.height)];
	value.text = _data[@"mobile"];
	value.textColor = COLOR666;
	value.font = font;
	value.backgroundColor = [UIColor clearColor];
	[view addSubview:value];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 0)];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"申请理由";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	NSString *reason = _data[@"reason"];
	CGSize s = [reason autoHeight:font width:value.width];
	value = [[UILabel alloc]initWithFrame:CGRectMake(label.right, 12, value.width, s.height)];
	value.text = reason;
	value.textColor = COLOR666;
	value.font = font;
	value.backgroundColor = [UIColor clearColor];
	value.numberOfLines = 0;
	[view addSubview:value];
	view.height = value.bottom + 14;
	[view addGeWithType:GeLineTypeBottom];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"上级渠道商";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	value = [[UILabel alloc]initWithFrame:CGRectMake(label.right, 0, view.width-label.right-10, view.height)];
	value.text = _data[@"invitor_shop_name"];
	value.textColor = COLOR666;
	value.font = font;
	value.backgroundColor = [UIColor clearColor];
	[view addSubview:value];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"渠道商类型";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	value = [[UILabel alloc]initWithFrame:value.frame];
	value.text = _data[@"reseller_type"];
	value.textColor = COLOR666;
	value.font = font;
	value.backgroundColor = [UIColor clearColor];
	[view addSubview:value];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"渠道商证件";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(label.right, (view.height-28)/2, 28, 28)];
	img.image = IMG(@"nopic");
	img.url = _data[@"id_pic"];
	[view addSubview:img];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		if (![img.element[@"exist"] boolValue]) return;
		MJPhoto *photo = [[MJPhoto alloc] init];
		photo.url = _data[@"id_pic"];
		photo.srcImageView = img;
		MJPhotoBrowser *browser = [[MJPhotoBrowser alloc]init];
		browser.photos = @[photo];
		[browser show];
	}];
	
	CGFloat width = (SCREEN_WIDTH-10*3) / 2;
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(10, view.bottom+10, width, 40);
	btn.titleLabel.font = [UIFont systemFontOfSize:15];
	btn.backgroundColor = COLORCCC;
	[btn setTitle:@"不同意申请" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[self pass:@"-1"];
	}];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 4;
	[scroll addSubview:btn];
	
	btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(10+width+10, view.bottom+10, width, 40);
	btn.titleLabel.font = [UIFont systemFontOfSize:15];
	btn.backgroundColor = COLORRGB(@"ff9f2c");
	[btn setTitle:@"同意申请" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[self pass:@"1"];
	}];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 4;
	[scroll addSubview:btn];
	
	scroll.contentSize = CGSizeMake(scroll.width, btn.bottom+10);
}

- (void)pass:(NSString*)status{
	[ProgressHUD show:nil];
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:_data[@"id"] forKey:@"id"];
	[postData setValue:status forKey:@"status"];
	[Common postApiWithParams:@{@"app":@"eshop", @"act":@"reseller_apply_audit"} data:postData feedback:@"操作成功" success:^(NSMutableDictionary *json) {
		[self.navigationController popViewControllerAnimated:YES];
	} fail:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
