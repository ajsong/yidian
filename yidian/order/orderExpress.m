//
//  orderExpress.m
//  yidianb
//
//  Created by ajsong on 16/4/29.
//  Copyright © 2016年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import "orderExpress.h"

@interface orderExpress (){
	NSMutableArray *_ms;
	NSDictionary *_json;
	UIScrollView *_scroll;
}
@end

@implementation orderExpress

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"物流情况";
	self.view.backgroundColor = WHITE;
	
	_ms = [[NSMutableArray alloc]init];
	
	_scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.height);
	[self.view addSubview:_scroll];
	
	//[self performSelector:@selector(loadViews) withObject:nil afterDelay:0];
	[ProgressHUD show:nil];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self loadData];
	});
}

#pragma mark - loadData
- (void)loadData{
	[Common getApiWithParams:@{@"app":@"other", @"act":@"kuaidi", @"spell_name":_data[@"shipping_company"], @"mail_no":_data[@"shipping_number"]} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([json[@"data"] isArray]) {
			NSArray *list = json[@"data"];
			for (int i=0; i<list.count; i++) {
				[_ms addObject:list[i]];
			}
			_ms = _ms.reverse;
		}
		_json = json;
		[self loadViews];
	} fail:^(NSMutableDictionary *json) {
		[self loadViews];
	}];
}

- (void)loadViews{
	[_scroll removeAllSubviews];
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, (10+60+10)*SCREEN_SCALE)];
	[_scroll addSubview:view];
	
	NSArray *list = _data[@"goods"];
	UIImageView *pic = [[UIImageView alloc]initWithFrame:CGRectMakeScale(10, 10, 60, 60)];
	pic.image = IMG(@"nopic");
	pic.url = list[0][@"goods_pic"];
	pic.layer.borderColor = BACKCOLOR.CGColor;
	pic.layer.borderWidth = 0.5;
	[view addSubview:pic];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(pic.right+10, pic.top, view.width-(pic.right+10), 20*SCREEN_SCALE)];
	label.text = STRINGFORMAT(@"物流公司：%@", _data[@"shipping_company"]);
	label.textColor = COLOR999;
	label.font = FONT(11);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	label = [[UILabel alloc]initWithFrame:label.frameBottom];
	label.text = STRINGFORMAT(@"快递单号：%@", _data[@"shipping_number"]);
	label.textColor = COLOR999;
	label.font = FONT(11);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	NSString *string = STRINGFORMAT(@"官方电话：<p>%@</p>", [_data[@"shipping_tel"]isset]?_data[@"shipping_tel"]:@"-");
	NSDictionary *style = @{@"body":@[FONT(11), COLOR999], @"p":COLORRGB(@"4074ad")};
	label = [[UILabel alloc]initWithFrame:label.frameBottom];
	label.attributedText = [string attributedStyle:style];
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	[label click:^(UIView *view, UIGestureRecognizer *sender) {
		if (![_data[@"shipping_tel"]isset]) return;
		NSArray *tels = [_data[@"shipping_tel"] split:@"/"];
		NSString *tel = tels[0];
		[Global openCall:tel];
	}];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 8*SCREEN_SCALE)];
	view.backgroundColor = BACKCOLOR;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeTopBottom color:COLORRGB(@"ddd")];
	
	if (!_ms.isArray) {
		label = [[UILabel alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, _scroll.height-view.bottom)];
		label.text = @"暂时没有物流信息";
		label.textColor = COLOR999;
		label.textAlignment = NSTextAlignmentCenter;
		label.font = FONT(13);
		label.backgroundColor = [UIColor clearColor];
		[_scroll addSubview:label];
		return;
	}
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, view.bottom, SCREEN_WIDTH-(10*SCREEN_SCALE)*2, 44*SCREEN_SCALE)];
	label.text = @"物流跟踪";
	label.textColor = COLOR333;
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[_scroll addSubview:label];
	[label addGeWithType:GeLineTypeBottom color:COLORRGB(@"eee")];
	
	CGFloat top = label.bottom;
	for (int i=0; i<_ms.count; i++) {
		view = [[UIView alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, top, SCREEN_WIDTH-(10*SCREEN_SCALE)*2, 0)];
		[_scroll addSubview:view];
		
		UIView *line = [[UIView alloc]initWithFrame:CGRectMake((16-1)/2*SCREEN_SCALE, 0, 1*SCREEN_SCALE, 0)];
		line.backgroundColor = COLORRGB(@"ddd");
		[view addSubview:line];
		
		UIView *dotView = [[UIView alloc]initWithFrame:CGRectMakeScale(0, 12, 16, 16)];
		dotView.layer.masksToBounds = YES;
		dotView.layer.cornerRadius = dotView.height/2;
		[view addSubview:dotView];
		UIView *dot = [[UIView alloc]initWithFrame:CGRectMakeScale(0, 0, 10, 10)];
		dot.layer.masksToBounds = YES;
		dot.layer.cornerRadius = dot.height/2;
		dot.center = CGPointMake(dotView.width/2, dotView.height/2);
		[dotView addSubview:dot];
		
		label = [[UILabel alloc]initWithFrame:CGRectMake(24*SCREEN_SCALE, dotView.top+1*SCREEN_SCALE, view.width-24*SCREEN_SCALE-10*SCREEN_SCALE, 0)];
		label.text = _ms[i][@"context"];
		label.font = FONT(12);
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		[label autoHeight];
		
		UILabel *time = [[UILabel alloc]initWithFrame:CGRectMake(24*SCREEN_SCALE, label.bottom, view.width-24*SCREEN_SCALE, 30*SCREEN_SCALE)];
		time.text = _ms[i][@"time"];
		time.font = label.font;
		time.backgroundColor = [UIColor clearColor];
		[view addSubview:time];
		[time addGeWithType:GeLineTypeBottom color:COLORRGB(@"eee")];
		
		view.height = time.bottom;
		
		if (!i) {
			dotView.backgroundColor = COLORRGB(@"c7edd4");
			dot.backgroundColor = COLORRGB(@"29ac60");
			label.textColor = COLORRGB(@"29ac60");
			time.textColor = COLORRGB(@"29ac60");
			line.top = (12+16/2)*SCREEN_SCALE;
			if (_ms.count>1) line.height = view.height - line.top;
		} else {
			dot.width = 10*SCREEN_SCALE;
			dot.height = 10*SCREEN_SCALE;
			dot.layer.cornerRadius = dot.height/2;
			dot.backgroundColor = COLORRGB(@"ddd");
			label.textColor = COLOR999;
			time.textColor = COLOR999;
			line.top = 0;
			if (i<_ms.count-1) {
				line.height = view.height;
			} else {
				line.height = (12+16/2)*SCREEN_SCALE;
			}
		}
		
		top = view.bottom;
	}
	
	_scroll.contentSize = CGSizeMake(_scroll.width, top+30*SCREEN_SCALE);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
