//
//  resellerDetail.m
//  yidian
//
//  Created by ajsong on 16/1/6.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "AppDelegate+EaseMob.h"
#import "resellerDetail.h"
#import "talk.h"

@interface resellerDetail (){
	UIScrollView *_scroll;
}
@end

@implementation resellerDetail

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"渠道商详情";
	self.view.backgroundColor = BACKCOLOR;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"统计" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		outlet *e = [[outlet alloc]init];
		e.title = @"统计";
		e.url = STRINGFORMAT(@"%@/wap.php?app=member&act=statistic&id=%@&sign=%@", API_URL, _data[@"id"], SIGN);
		[self.navigationController pushViewController:e animated:YES];
	}];
	
	_scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_scroll.contentInset = UIEdgeInsetsMake(0, 0, 42, 0);
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.height);
	[self.view addSubview:_scroll];
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, self.height-42, SCREEN_WIDTH, 42)];
	[self.view addSubview:view];
	
	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 106.5, view.height)];
	btn.backgroundColor = [UIColor clearColor];
	btn.adjustsImageWhenHighlighted = NO;
	[btn setBackgroundImage:IMG(@"s-reseller-btn1") forState:UIControlStateNormal];
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		NSDictionary *person = PERSON;
		if (![EaseSDKHelper isLogin]) {
			[self showLoginController];
			return;
		}
		NSString *chatter = STRING(_data[@"member_id"]);
		if ([chatter isEqualToString:STRING(person[@"id"])]) {
			[ProgressHUD showError:@"不能与自己聊天"];
			return;
		}
		talk *e = [[talk alloc]initWithConversationChatter:chatter conversationType:EMConversationTypeChat];
		e.title = _data[@"member_name"];
		[self.navigationController pushViewController:e animated:YES];
	}];
	[view addSubview:btn];
	
	btn = [[UIButton alloc]initWithFrame:CGRectMake(btn.right, 0, 106.5, view.height)];
	btn.backgroundColor = [UIColor clearColor];
	btn.adjustsImageWhenHighlighted = NO;
	[btn setBackgroundImage:IMG(@"s-reseller-btn2") forState:UIControlStateNormal];
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[Global openSms:_data[@"mobile"]];
	}];
	[view addSubview:btn];
	
	btn = [[UIButton alloc]initWithFrame:CGRectMake(btn.right, 0, 107, view.height)];
	btn.backgroundColor = [UIColor clearColor];
	btn.adjustsImageWhenHighlighted = NO;
	[btn setBackgroundImage:IMG(@"s-reseller-btn3") forState:UIControlStateNormal];
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[Global openCall:_data[@"mobile"]];
	}];
	[view addSubview:btn];
	
	[self performSelector:@selector(loadViews) withObject:nil afterDelay:0];
}

- (void)loadViews{
	[_scroll removeAllSubviews];
	
	UIImageView *avatar = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-82)/2, 22, 82, 82)];
	avatar.image = IMG(@"avatar");
	avatar.url = _data[@"avatar"];
	avatar.layer.masksToBounds = YES;
	avatar.layer.cornerRadius = 41;
	[_scroll addSubview:avatar];
	
	UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(0, avatar.bottom, SCREEN_WIDTH, 30)];
	name.text = _data[@"member_name"];
	name.textColor = [UIColor blackColor];
	name.textAlignment = NSTextAlignmentCenter;
	name.font = [UIFont systemFontOfSize:16];
	name.backgroundColor = [UIColor clearColor];
	[_scroll addSubview:name];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, name.bottom, SCREEN_WIDTH, 15)];
	label.text = _data[@"mobile"];
	label.textColor = COLOR999;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont systemFontOfSize:13];
	label.backgroundColor = [UIColor clearColor];
	[_scroll addSubview:label];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(0, label.bottom, SCREEN_WIDTH, 30)];
	label.text = STRINGFORMAT(@"加入日期：%@", _data[@"add_time"]);
	label.textColor = COLOR999;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont systemFontOfSize:13];
	label.backgroundColor = [UIColor clearColor];
	[_scroll addSubview:label];
	
	UIFont *font = FONT(13);
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, label.bottom, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 85, view.height)];
	label.text = @"下级渠道商";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	UILabel *value = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.width-15, view.height)];
	value.text = STRINGFORMAT(@"%@个", _data[@"resellers"]);
	value.textColor = COLOR666;
	value.textAlignment = NSTextAlignmentRight;
	value.font = font;
	value.backgroundColor = [UIColor clearColor];
	[view addSubview:value];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"订单数";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	value = [[UILabel alloc]initWithFrame:value.frame];
	value.text = STRINGFORMAT(@"%@笔", _data[@"orders"]);
	value.textColor = COLOR666;
	value.textAlignment = NSTextAlignmentRight;
	value.font = font;
	value.backgroundColor = [UIColor clearColor];
	[view addSubview:value];
	
	if ([PERSON[@"member_type"]intValue]==3) {
		view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
		view.backgroundColor = WHITE;
		[_scroll addSubview:view];
		[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = @"订单分利合计";
		label.textColor = [UIColor blackColor];
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		value = [[UILabel alloc]initWithFrame:value.frame];
		value.text = STRINGFORMAT(@"￥%.2f", [_data[@"total_income"] floatValue]);
		value.textColor = COLOR666;
		value.textAlignment = NSTextAlignmentRight;
		value.font = font;
		value.backgroundColor = [UIColor clearColor];
		[view addSubview:value];
		
		view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
		view.backgroundColor = WHITE;
		[_scroll addSubview:view];
		[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = @"直接销售分利";
		label.textColor = [UIColor blackColor];
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		value = [[UILabel alloc]initWithFrame:value.frame];
		value.text = STRINGFORMAT(@"￥%.2f", [_data[@"direct_sale_income"] floatValue]);
		value.textColor = COLOR666;
		value.textAlignment = NSTextAlignmentRight;
		value.font = font;
		value.backgroundColor = [UIColor clearColor];
		[view addSubview:value];
		
		view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
		view.backgroundColor = WHITE;
		[_scroll addSubview:view];
		[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = @"二级销售分利";
		label.textColor = [UIColor blackColor];
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		value = [[UILabel alloc]initWithFrame:value.frame];
		value.text = STRINGFORMAT(@"￥%.2f", [_data[@"second_sale_income"] floatValue]);
		value.textColor = COLOR666;
		value.textAlignment = NSTextAlignmentRight;
		value.font = font;
		value.backgroundColor = [UIColor clearColor];
		[view addSubview:value];
		
		/*
		SpecialLabel *labels = [[SpecialLabel alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 30)];
		labels.text = @"点击这里取消他的代理资格";
		labels.textColor = COLORRGB(@"4496dc");
		labels.textAlignment = NSTextAlignmentRight;
		labels.font = FONT(13);
		labels.backgroundColor = [UIColor clearColor];
		[_scroll addSubview:labels];
		labels.padding = UIEdgeInsetsMake(0, 0, 0, 15);
		labels.lineType = LineTypeBottom;
		labels.lineWidth = 1;
		[labels click:^(UIView *view, UIGestureRecognizer *sender) {
			[UIAlertView alert:@"真的要取消吗？" block:^(NSInteger buttonIndex) {
				if (buttonIndex == 1) {
					NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
					[postData setValue:_data[@"id"] forKey:@"shop_id"];
					[Common postApiWithParams:@{@"app":@"eshop", @"act":@"reseller_delete"} data:postData feedback:@"取消成功" success:^(NSMutableDictionary *json) {
						[self.navigationController popViewControllerAnimated:YES];
					} fail:nil];
				}
			}];
		}];
		 */
	}
	
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.lastSubview.bottom+15);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
