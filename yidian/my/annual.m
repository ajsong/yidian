//
//  annual.m
//  yidian
//
//  Created by ajsong on 16/7/15.
//  Copyright © 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "annual.h"
#import "annualPost.h"

@interface annual (){
	NSMutableDictionary *_ms;
	UIScrollView *_scroll;
}
@end

@implementation annual

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"服务年费";
	self.view.backgroundColor = WHITE;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"支付年费" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		annualPost *e = [[annualPost alloc]init];
		[self.navigationController pushViewController:e animated:YES];
	}];
	
	_scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	[self.view addSubview:_scroll];
	
	//[self performSelector:@selector(loadViews) withObject:nil afterDelay:0];
	[ProgressHUD show:nil];
	[self loadData];
}

#pragma mark - loadData
- (void)loadData{
	_ms = [[NSMutableDictionary alloc]init];
	[Common getApiWithParams:@{@"app":@"annual", @"act":@"history"} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([json[@"data"] isDictionary]) {
			_ms = [NSMutableDictionary dictionaryWithDictionary:json[@"data"]];
		}
		//NSLog(@"%@", _ms.descriptionASCII);
		[self loadViews];
	} fail:^(NSMutableDictionary *json) {
		[self loadViews];
	}];
}

- (void)loadViews{
	[_scroll removeAllSubviews];
	if (!_ms.isDictionary) return;
	
	UIFont *font = FONT(14);
	UIFont *font13 = FONT(13);
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMakeScale(0, 0, SCREEN_WIDTH, 94)];
	view.backgroundColor = COLORRGB(@"ffffcc");
	[_scroll addSubview:view];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, view.width-15, font.lineHeight)];
	label.text = _ms[@"tips"];
	label.textColor = BLACK;
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	NSString *string = STRINGFORMAT(@"有效期：<p>%@</p> 至 <p>%@</p>", _ms[@"start_time"], _ms[@"end_time"]);
	NSDictionary *style = @{@"body":@[font, BLACK], @"p":FONT(17)};
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, label.bottom+15, view.width-15, 0)];
	label.attributedText = [string attributedStyle:style];
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	[label autoHeight];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, view.bottom, _scroll.width-15, 40)];
	label.text = @"年费支付历史";
	label.textColor = BLACK;
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[_scroll addSubview:label];
	
	CGFloat top = label.bottom;
	if ([_ms[@"order"] isArray]) {
		NSArray *list = _ms[@"order"];
		for (int i=0; i<list.count; i++) {
			view = [[UIView alloc]initWithFrame:CGRectMake(15, top, _scroll.width-15*2, 30)];
			[_scroll addSubview:view];
			[view addGeWithType:GeLineTypeBottom color:COLOR_GE_LIGHT];
			
			label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.width, view.height)];
			label.text = STRINGFORMAT(@"%@　　￥%.2f", list[i][@"pay_time"], [list[i][@"total_price"]floatValue]);
			label.textColor = COLOR777;
			label.font = font13;
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			top = view.bottom;
		}
	}
	
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.lastSubview.bottom);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
