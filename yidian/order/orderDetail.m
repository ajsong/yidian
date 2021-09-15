//
//  orderDetail.m
//  syoker
//
//  Created by ajsong on 15/4/10.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "AppDelegate+EaseMob.h"
#import "orderDetail.h"
#import "talk.h"
#import "orderShipping.h"
#import "orderExpress.h"

@interface orderDetail ()<OrderDetailDelegate>{
	NSMutableDictionary *_person;
	NSDictionary *_ms;
	UIScrollView *_scroll;
	CGFloat _total;
	SpecialTextView *_reason;
}
@end

@implementation orderDetail

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"订单详情";
	self.view.backgroundColor = BACKCOLOR;
	
	_person = PERSON;
	_ms = [[NSDictionary alloc]init];
	
	_scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_scroll.contentSize = CGSizeMake(SCREEN_WIDTH, _scroll.frame.size.height);
	[_scroll addHeaderWithTarget:self action:@selector(tableViewRefresh)];
	[self.view addSubview:_scroll];
	[_scroll headerBeginRefreshing];
}

- (void)loadData{
	self.navigationItem.rightBarButtonItem = nil;
	_total = 0;
	[Common getApiWithParams:@{@"app":@"shop_order", @"act":@"detail", @"id":_data[@"id"]} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([Global isDictionary:json[@"data"]]) {
			_ms = json[@"data"];
		}
		//NSLog(@"%@", _ms);
		[self refreshTable];
	} fail:nil];
}

-(void)refresh{
	NSInteger orderstatus = [_ms[@"status"]integerValue];
	UIFont *font = [UIFont systemFontOfSize:14];
	
	[[_scroll viewWithTag:10] removeFromSuperview];
	self.navigationItem.rightBarButtonItem = nil;
	
	UIView *container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
	container.tag = 10;
	[_scroll addSubview:container];
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
	view.backgroundColor = WHITE;
	[container addSubview:view];
	[view addGeWithType:GeLineTypeTop];
	[view addGeWithType:GeLineTypeBottom];
	
	NSString *string = [self statusName:orderstatus];
	CGSize s = [string autoWidth:font height:view.height];
	UILabel *status = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, s.width, view.height)];
	status.text = [self statusName:orderstatus];
	status.textColor = [self statusColor:orderstatus];
	status.font = font;
	status.backgroundColor = [UIColor clearColor];
	[view addSubview:status];
	
	if (orderstatus>0 && [_ms[@"ask_refund_time"]integerValue]>0) {
		string = @"(退货退款中)";
		s = [string autoWidth:FONT(12) height:40];
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(status.right+5, 0, s.width, view.height)];
		label.text = string;
		label.textColor = COLOR999;
		label.font = FONT(12);
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
	}
	
	string = STRINGFORMAT(@"订单号：%@", _ms[@"order_sn"]);
	s = [string autoWidth:FONT(12) height:40];
	UILabel *no = [[UILabel alloc]initWithFrame:CGRectMake(view.width-s.width-15, 0, s.width, view.height)];
	no.text = string;
	no.textColor = [UIColor blackColor];
	no.textAlignment = NSTextAlignmentRight;
	no.font = FONT(12);
	no.backgroundColor = [UIColor clearColor];
	[view addSubview:no];
	
	if ([_person[@"member_type"]integerValue]==3 && [_ms[@"shop_id"]integerValue]!=[_ms[@"factory_shop_id"]integerValue]) {
		view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, view.height)];
		view.backgroundColor = WHITE;
		[container addSubview:view];
		[view addGeWithType:GeLineTypeBottom];
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15*2, view.height)];
		label.text = STRINGFORMAT(@"%@(ID:%@)", _ms[@"shop_name"], _ms[@"shop_id"]);
		label.textColor = COLOR666;
		label.textAlignment = NSTextAlignmentRight;
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
//		[view click:^(UIView *view, UIGestureRecognizer *sender) {
//			NSDictionary *person = PERSON;
//			if (![EaseSDKHelper isLogin]) {
//				[ProgressHUD showWarning:@"聊天账号未登录"];
//				return;
//			}
//			NSString *chatter = STRING(_ms[@"member_id"]);
//			if ([chatter isEqualToString:STRING(person[@"id"])]) {
//				[ProgressHUD showError:@"不能与自己聊天"];
//				return;
//			}
//			talk *e = [[talk alloc]initWithConversationChatter:chatter conversationType:EMConversationTypeChat];
//			e.title = _ms[@"shop_name"];
//			[self.navigationController pushViewController:e animated:YES];
//		}];
	}
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, view.height)];
	view.backgroundColor = WHITE;
	[container addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15*2, view.height)];
	label.text = @"下单时间";
	label.textColor = COLOR666;
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = _ms[@"add_time"];
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentRight;
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom+15, SCREEN_WIDTH, 40+72)];
	view.backgroundColor = WHITE;
	[container addSubview:view];
	UIImageView *addressBg = [[UIImageView alloc]initWithFrame:view.bounds];
	addressBg.image = [UIImage imageNamed:@"s-order-address-bg"];
	[view addSubview:addressBg];
	UIView *cell = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
	[view addSubview:cell];
	[cell addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, cell.width-15, cell.height)];
	label.text = @"收货地址";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[cell addSubview:label];
	
	UIView *addressView = [[UIView alloc]initWithFrame:CGRectMake(15, cell.bottom, cell.width-15, 72)];
	[view addSubview:addressView];
	label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, addressView.width-26, 30)];
	label.text = STRINGFORMAT(@"%@　%@", _ms[@"name"], _ms[@"mobile"]);
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[addressView addSubview:label];
	label = [[UILabel alloc]initWithFrame:CGRectMake(0, label.bottom, label.width, 34)];
	label.text = STRINGFORMAT(@"%@%@%@%@", _ms[@"province"], _ms[@"city"], _ms[@"district"], [_person[@"member_type"]integerValue]==3?_ms[@"address"]:@"****");
	label.textColor = COLOR777;
	label.font = [UIFont systemFontOfSize:13];
	label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 2;
	[addressView addSubview:label];
	
	UIView *ge;
	CGFloat bottom = view.bottom + 15;
	NSArray *prolist = _ms[@"goods"];
	if (prolist.isArray) {
		for (int j=0; j<prolist.count; j++) {
			_total += [prolist[j][@"price"]floatValue] * [prolist[j][@"quantity"]integerValue];
			
			view = [[UIView alloc]initWithFrame:CGRectMake(0, bottom, SCREEN_WIDTH, 86)];
			view.backgroundColor = WHITE;
			[_scroll addSubview:view];
			
			UIImageView *pic = [[UIImageView alloc]initWithFrame:CGRectMake(10, (view.height-60)/2, 60, 60)];
			pic.image = IMG(@"nopic");
			pic.url = prolist[j][@"goods_pic"];
			pic.layer.borderColor = COLOR_GE.CGColor;
			pic.layer.borderWidth = 0.5;
			[view addSubview:pic];
			
			SpecialLabel *title = [[SpecialLabel alloc]initWithFrame:CGRectMake(pic.right+8, pic.top, view.width-pic.right-8-65, pic.height-15)];
			title.text = [prolist[j][@"goods_name"] trim];
			title.textColor = COLORRGB(@"333");
			title.font = [UIFont systemFontOfSize:13];
			title.backgroundColor = [UIColor clearColor];
			title.numberOfLines = 2;
			[view addSubview:title];
			title.verticalAlignment = VerticalAlignmentTop;
			
			CGSize s;
			CGFloat x = title.left;
			CGFloat y = pic.bottom - 15;
			if (![prolist[j][@"spec"] isEqualToString:@""]) {
				s = [Global autoWidth:STRINGFORMAT(@"规格：%@", prolist[j][@"spec"]) font:[UIFont systemFontOfSize:12] height:15];
				UILabel *color = [[UILabel alloc]initWithFrame:CGRectMake(x, y, s.width, 15)];
				color.text = STRINGFORMAT(@"规格:%@", prolist[j][@"spec"]);
				color.textColor = COLOR999;
				color.font = [UIFont systemFontOfSize:12];
				color.backgroundColor = [UIColor clearColor];
				[view addSubview:color];
				x = color.right + 10;
			}
			
			UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(view.width-65-10, title.top, 65, 15)];
			price.text = STRINGFORMAT(@"￥%.2f", [prolist[j][@"price"]floatValue]);
			price.textColor = MAINSUBCOLOR;
			price.textAlignment = NSTextAlignmentRight;
			price.font = [UIFont systemFontOfSize:13];
			price.backgroundColor = [UIColor clearColor];
			[view addSubview:price];
			
			if ([prolist[j][@"quantity"]integerValue]>0) {
				UILabel *quantity = [[UILabel alloc]initWithFrame:CGRectMake(price.left, price.bottom, price.width, 15)];
				quantity.text = STRINGFORMAT(@"× %@", prolist[j][@"quantity"]);
				quantity.textColor = COLOR999;
				quantity.textAlignment = NSTextAlignmentRight;
				quantity.font = [UIFont systemFontOfSize:12];
				quantity.backgroundColor = [UIColor clearColor];
				[view addSubview:quantity];
			}
			
			bottom = view.bottom;
			if (j==0) [view addGeWithType:GeLineTypeTop];
			if (j==prolist.count-1) {
				[view addGeWithType:GeLineTypeBottom];
			} else {
				ge = [[UIView alloc]initWithFrame:CGRectMake(10, view.height-0.5, view.width-10*2, 0.5)];
				ge.backgroundColor = COLORRGB(@"e5e5e5");
				[view addSubview:ge];
			}
		}
	}
	
	if ([_person[@"member_type"]integerValue]==3) {
		view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 38)];
		view.backgroundColor = WHITE;
		[_scroll addSubview:view];
		[view addGeWithType:GeLineTypeBottom];
		
		UIView *cell = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, view.height)];
		[view addSubview:cell];
		UIView *span = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, cell.height)];
		[cell addSubview:span];
		UIImageView *ico = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 38, 38)];
		ico.image = IMG(@"o-im");
		[span addSubview:ico];
		label = [[UILabel alloc]initWithFrame:CGRectMake(ico.right, 0, 0, span.height)];
		label.text = @"联系买家";
		label.textColor = [UIColor blackColor];
		label.font = FONT(11);
		label.backgroundColor = [UIColor clearColor];
		[span addSubview:label];
		[label autoWidth];
		span.width = label.right;
		span.origin = CGPointMake((cell.width-span.width)/2, 0);
		[cell click:^(UIView *view, UIGestureRecognizer *sender) {
			if (![EaseSDKHelper isLogin]) {
				[self showLoginController];
				return;
			}
			NSString *chatter = STRING(_ms[@"member_id"]);
			if ([chatter isEqualToString:STRING(PERSON[@"id"])]) {
				[ProgressHUD showError:@"不能与自己聊天"];
				return;
			}
			talk *e = [[talk alloc]initWithConversationChatter:_ms[@"member_id"] conversationType:EMConversationTypeChat];
			e.title = _ms[@"member_name"];
			[self.navigationController pushViewController:e animated:YES];
		}];
		
		cell = [[UIView alloc]initWithFrame:cell.frameRight];
		[view addSubview:cell];
		span = [[UIView alloc]initWithFrame:span.frame];
		[cell addSubview:span];
		ico = [[UIImageView alloc]initWithFrame:ico.frame];
		ico.image = IMG(@"o-tel");
		[span addSubview:ico];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = @"拨打电话";
		label.textColor = [UIColor blackColor];
		label.font = FONT(11);
		label.backgroundColor = [UIColor clearColor];
		[span addSubview:label];
		[cell click:^(UIView *view, UIGestureRecognizer *sender) {
			[Global openCall:_ms[@"mobile"]];
		}];
		
		UIView *ge = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2, (view.height-22)/2, 0.5, 22)];
		ge.backgroundColor = COLOR_GE;
		[view addSubview:ge];
	}
	
	CGFloat top = view.bottom+15;
	view = [[UIView alloc]initWithFrame:CGRectMake(0, top, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[container addSubview:view];
	[view addGeWithType:GeLineTypeTop];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15*2, view.height)];
	label.text = @"分利";
	label.textColor = COLOR666;
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	UIImageView *push;
	if ([_person[@"member_type"]integerValue]==3) {
		push = [[UIImageView alloc]initWithFrame:CGRectMake(view.width-44, (view.height-44)/2, 44, 44)];
		push.image = IMG(@"push");
		[view addSubview:push];
		[view click:^(UIView *view, UIGestureRecognizer *sender) {
			UIFont *font = FONT(14);
			UIView *subview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 270, 0)];
			subview.backgroundColor = WHITE;
			subview.layer.masksToBounds = YES;
			subview.layer.cornerRadius = 5;
			
			UIView *row = [[UIView alloc]initWithFrame:CGRectMake(0, 0, subview.width, 45)];
			[subview addSubview:row];
			[row addGeWithType:GeLineTypeBottom];
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, row.width-17, row.height)];
			label.text = @"分利情况";
			label.textColor = [UIColor blackColor];
			label.font = FONT(15);
			label.backgroundColor = [UIColor clearColor];
			[row addSubview:label];
			
			for (int k=1; k<=3; k++) {
				row = [[UIView alloc]initWithFrame:CGRectMake(0, row.bottom, row.width, 40)];
				[subview addSubview:row];
				[row addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
				label = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, row.width-17, row.height)];
				label.text = _ms[STRINGFORMAT(@"reseller_shop_name%d", k)];
				label.textColor = [UIColor blackColor];
				label.font = font;
				label.backgroundColor = [UIColor clearColor];
				[row addSubview:label];
				NSString *string = _ms[STRINGFORMAT(@"commission_money%d", k)];
				string = STRINGFORMAT(@"￥%.2f", [string floatValue]);
				CGSize s = [string autoWidth:font height:row.height];
				UILabel *value = [[UILabel alloc]initWithFrame:CGRectMake(row.width-s.width-17, 0, s.width, row.height)];
				value.text = string;
				value.textColor = COLOR777;
				value.font = font;
				value.backgroundColor = [UIColor clearColor];
				[row addSubview:value];
			}
			
			row = [[UIView alloc]initWithFrame:CGRectMake(0, row.bottom, subview.width, 45)];
			[subview addSubview:row];
			label = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, row.width-17, row.height)];
			label.text = @"总计";
			label.textColor = [UIColor blackColor];
			label.font = FONT(15);
			label.backgroundColor = [UIColor clearColor];
			[row addSubview:label];
			label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, row.width-17, row.height)];
			label.text = STRINGFORMAT(@"￥-%.2f", [_ms[@"commission_total_money"]floatValue]);
			label.textColor = [UIColor redColor];
			label.textAlignment = NSTextAlignmentRight;
			label.font = font;
			label.backgroundColor = [UIColor clearColor];
			[row addSubview:label];
			
			subview.height = row.bottom;
			[self presentAlertView:subview animation:DYAlertViewDown];
		}];
	}
	label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.width-([_person[@"member_type"]integerValue]==3?0:15)-push.width, view.height)];
	label.text = STRINGFORMAT(@"￥%@%.2f", [_person[@"member_type"]integerValue]==3?@"-":@"", [_ms[@"commission_total_money"]floatValue]);
	label.textColor = MAINSUBCOLOR;
	label.textAlignment = NSTextAlignmentRight;
	label.font = [UIFont systemFontOfSize:14];
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	top = view.bottom;
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, top, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[container addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15*2, view.height)];
	label.text = @"合计";
	label.textColor = COLOR666;
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = STRINGFORMAT(@"商品总价￥%.2f + 运费￥%.2f", _total, [_ms[@"shipping_price"]floatValue]);
	label.textColor = MAINSUBCOLOR;
	label.textAlignment = NSTextAlignmentRight;
	label.font = [UIFont systemFontOfSize:14];
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, view.height)];
	view.backgroundColor = WHITE;
	[container addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"实际支付";
	label.textColor = COLOR666;
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	if (orderstatus==0 && [_person[@"member_type"]integerValue]==3) {
		UILabel *tip = [[UILabel alloc]initWithFrame:CGRectMake(80, 0, 120, view.height)];
		tip.text = @"(点击修改价格)";
		tip.textColor = COLOR999;
		tip.font = [UIFont systemFontOfSize:12];
		tip.backgroundColor = [UIColor clearColor];
		[view addSubview:tip];
		[view click:^(UIView *view, UIGestureRecognizer *sender) {
			[self changePrice:view];
		}];
	}
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = STRINGFORMAT(@"￥%.2f", [_ms[@"total_price"]floatValue]);
	label.textColor = MAINSUBCOLOR;
	label.textAlignment = NSTextAlignmentRight;
	label.font = [UIFont systemFontOfSize:14];
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	if ([Global hasString:_ms[@"invoice_name"]]) {
		view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom+15, SCREEN_WIDTH, 44)];
		view.backgroundColor = WHITE;
		[container addSubview:view];
		[view addGeWithType:GeLineTypeTopBottom];
		label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15*2, view.height)];
		label.text = @"发票抬头";
		label.textColor = COLOR666;
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = _ms[@"invoice_name"];
		label.textColor = [UIColor blackColor];
		label.textAlignment = NSTextAlignmentRight;
		label.font = [UIFont systemFontOfSize:14];
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		
		view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, view.height)];
		view.backgroundColor = WHITE;
		[container addSubview:view];
		[view addGeWithType:GeLineTypeBottom];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = @"发票内容";
		label.textColor = COLOR666;
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = _ms[@"invoice_content"];
		label.textColor = [UIColor blackColor];
		label.textAlignment = NSTextAlignmentRight;
		label.font = [UIFont systemFontOfSize:14];
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
	}
	
	if (orderstatus>1 && [Global hasString:_ms[@"shipping_number"]]) {
		KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"物流" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
		[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
			orderExpress *e = [[orderExpress alloc]init];
			e.data = _ms;
			[self.navigationController pushViewController:e animated:YES];
		}];
		
		view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom+15, SCREEN_WIDTH, 44)];
		view.backgroundColor = WHITE;
		[container addSubview:view];
		[view addGeWithType:GeLineTypeTopBottom];
		label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15*2, view.height)];
		label.text = @"物流公司";
		label.textColor = COLOR666;
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = _ms[@"shipping_company"];
		label.textColor = [UIColor blackColor];
		label.textAlignment = NSTextAlignmentRight;
		label.font = [UIFont systemFontOfSize:14];
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		
		view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, view.height)];
		view.backgroundColor = WHITE;
		[container addSubview:view];
		[view addGeWithType:GeLineTypeBottom];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = @"物流单号";
		label.textColor = COLOR666;
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = _ms[@"shipping_number"];
		label.textColor = [UIColor blackColor];
		label.textAlignment = NSTextAlignmentRight;
		label.font = [UIFont systemFontOfSize:14];
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
	}
	
	if ([_person[@"member_type"]integerValue]==3 && [_ms[@"return_goods"] isDictionary] && [_ms[@"refund"] isDictionary]) {
		UILabel *labelTit = [[UILabel alloc]initWithFrame:CGRectMake(15, view.bottom, SCREEN_WIDTH-15*2, 40)];
		if ([_ms[@"refund"][@"refund_type"] intValue]==1) {
			labelTit.text = @"退款申请";
		} else {
			labelTit.text = @"退货申请";
		}
		labelTit.textColor = [UIColor blackColor];
		labelTit.font = font;
		labelTit.backgroundColor = [UIColor clearColor];
		[container addSubview:labelTit];
		
		view = [[UIView alloc]initWithFrame:CGRectMake(0, labelTit.bottom, SCREEN_WIDTH, view.height)];
		view.backgroundColor = WHITE;
		[container addSubview:view];
		[view addGeWithType:GeLineTypeTopBottom];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = @"申请时间";
		label.textColor = COLOR666;
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = _ms[@"refund"][@"add_time"];
		label.textColor = [UIColor blackColor];
		label.textAlignment = NSTextAlignmentRight;
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		
		view = [[UIView alloc]initWithFrame:view.frameBottom];
		view.backgroundColor = WHITE;
		[container addSubview:view];
		[view addGeWithType:GeLineTypeBottom];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = STRINGFORMAT(@"%@原因", [_ms[@"refund"][@"refund_type"] intValue]==1?@"退款":@"退货");
		label.textColor = COLOR666;
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = _ms[@"refund"][@"reason"];
		label.textColor = [UIColor blackColor];
		label.textAlignment = NSTextAlignmentRight;
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		
		NSString *str = _ms[@"refund"][@"memo"];
		if (str.length) {
			view = [[UIView alloc]initWithFrame:view.frameBottom];
			view.backgroundColor = WHITE;
			[container addSubview:view];
			label = [[UILabel alloc]initWithFrame:label.frame];
			label.text = STRINGFORMAT(@"%@说明", [_ms[@"refund"][@"refund_type"] intValue]==1?@"退款":@"退货");
			label.textColor = COLOR666;
			label.font = font;
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			CGSize s = [str autoHeight:font width:216];
			CGFloat h = s.height;
			CGFloat y = 13.5;
			if (s.height<17) {
				h = 44;
				y = 0;
			}
			label = [[UILabel alloc]initWithFrame:CGRectMake(view.width-216-15, y, 216, h)];
			label.text = str;
			label.textColor = [UIColor blackColor];
			if (s.height<17) label.textAlignment = NSTextAlignmentRight;
			label.font = font;
			label.backgroundColor = [UIColor clearColor];
			label.numberOfLines = 0;
			[view addSubview:label];
			if (s.height>17) view.height = label.bottom+13.5;
			[view addGeWithType:GeLineTypeBottom];
		}
		
		if ([_ms[@"refund"][@"status"] intValue]==0) {
			view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
			view.backgroundColor = WHITE;
			[container addSubview:view];
			[view addGeWithType:GeLineTypeBottom];
			
			UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(15, (view.height-30)/2, (SCREEN_WIDTH-15*3)/2, 30)];
			btn.titleLabel.font = font;
			btn.backgroundColor = [UIColor clearColor];
			[btn setTitle:@"同意" forState:UIControlStateNormal];
			[btn setTitleColor:MAINSUBCOLOR forState:UIControlStateNormal];
			btn.layer.borderColor = MAINSUBCOLOR.CGColor;
			btn.layer.borderWidth = 0.5;
			btn.layer.masksToBounds = YES;
			btn.layer.cornerRadius = 3;
			[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
				[UIAlertView alert:@"真的同意吗？" block:^(NSInteger buttonIndex) {
					if (buttonIndex==1) {
						[ProgressHUD show:nil];
						NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
						[postData setValue:_data[@"id"] forKey:@"order_id"];
						[postData setValue:@1 forKey:@"status"];
						[Common postApiWithParams:@{@"app":@"member", @"act":@"order_check_return_goods"} data:postData success:^(NSMutableDictionary *json) {
							[_scroll headerBeginRefreshing];
						} fail:nil];
					}
				}];
			}];
			[view addSubview:btn];
			
			btn = [[UIButton alloc]initWithFrame:[btn frameRight:15]];
			btn.titleLabel.font = font;
			btn.backgroundColor = [UIColor clearColor];
			[btn setTitle:@"不同意" forState:UIControlStateNormal];
			[btn setTitleColor:COLOR666 forState:UIControlStateNormal];
			btn.layer.borderColor = COLOR666.CGColor;
			btn.layer.borderWidth = 0.5;
			btn.layer.masksToBounds = YES;
			btn.layer.cornerRadius = 3;
			[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
				UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 260, 180)];
				view.backgroundColor = WHITE;
				view.layer.masksToBounds = YES;
				view.layer.cornerRadius = 5;
				
				SpecialTextView *reason = [[SpecialTextView alloc]initWithFrame:CGRectMake(15, 15, view.width-15*2, view.height-15-10-30-10)];
				reason.placeholder = @"请填写不同意原因";
				reason.textColor = [UIColor blackColor];
				reason.font = FONT(13);
				reason.backgroundColor = [UIColor clearColor];
				[view addSubview:reason];
				
				UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(15, reason.bottom+10, view.width-15*2, 30)];
				btn.titleLabel.font = FONT(14);
				btn.backgroundColor = MAINSUBCOLOR;
				[btn setTitle:@"确定" forState:UIControlStateNormal];
				[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
				btn.layer.masksToBounds = YES;
				btn.layer.cornerRadius = 3;
				[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
					[reason resignFirstResponder];
					if (!reason.text.length) {
						[ProgressHUD showError:@"请填写不同意原因"];
						return;
					}
					[ProgressHUD show:nil];
					NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
					[postData setValue:_data[@"id"] forKey:@"order_id"];
					[postData setValue:reason.text forKey:@"reason"];
					[postData setValue:@-1 forKey:@"status"];
					[Common postApiWithParams:@{@"app":@"member", @"act":@"order_check_return_goods"} data:postData feedback:@"nomsg" success:^(NSMutableDictionary *json) {
						[self dismissAlertView:DYAlertViewScale];
					} fail:nil];
				}];
				[view addSubview:btn];
				
				[self presentAlertView:view animation:DYAlertViewScale close:^{
					[_scroll headerBeginRefreshing];
				}];
			}];
			[view addSubview:btn];
		} else if ([_ms[@"return_goods"][@"audit_memo"] length]) {
			NSString *str = _ms[@"return_goods"][@"audit_memo"];
			view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
			view.backgroundColor = WHITE;
			[container addSubview:view];
			label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15*2, view.height)];
			label.text = @"处理结果";
			label.textColor = COLOR666;
			label.font = font;
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			CGSize s = [str autoHeight:font width:216];
			CGFloat h = s.height;
			CGFloat y = 13.5;
			if (s.height<17) {
				h = 44;
				y = 0;
			}
			label = [[UILabel alloc]initWithFrame:CGRectMake(view.width-216-15, y, 216, h)];
			label.text = str;
			label.textColor = [UIColor blackColor];
			if (s.height<17) label.textAlignment = NSTextAlignmentRight;
			label.font = font;
			label.backgroundColor = [UIColor clearColor];
			label.numberOfLines = 0;
			[view addSubview:label];
			if (s.height>17) view.height = label.bottom+13.5;
			[view addGeWithType:GeLineTypeBottom];
			
			view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
			view.backgroundColor = WHITE;
			[container addSubview:view];
			[view addGeWithType:GeLineTypeBottom];
			label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15*2, view.height)];
			label.text = @"处理时间";
			label.textColor = COLOR666;
			label.font = font;
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			label = [[UILabel alloc]initWithFrame:label.frame];
			label.text = _ms[@"return_goods"][@"audit_time"];
			label.textColor = [UIColor blackColor];
			label.textAlignment = NSTextAlignmentRight;
			label.font = font;
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
		}
	}
	
	if (orderstatus==1 && [_person[@"member_type"]integerValue]==3) {
		view = [[UIView alloc]initWithFrame:CGRectMake(15, view.bottom+15, SCREEN_WIDTH-15*2, 35)];
		[container addSubview:view];
		
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.frame = CGRectMake(0, 0, view.width, view.height);
		btn.backgroundColor = MAINSUBCOLOR;
		btn.titleLabel.font = [UIFont systemFontOfSize:15];
		[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[btn setTitle:@"扫码发货" forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(shipping:) forControlEvents:UIControlEventTouchUpInside];
		btn.layer.masksToBounds = YES;
		btn.layer.cornerRadius = 4;
		[view addSubview:btn];
	}
	if (!view.subviews.count) view.height = 0;
	
	container.height = view.bottom;
	
	_scroll.contentSize = CGSizeMake(SCREEN_WIDTH, container.bottom+15);
}

#pragma mark - Refresh and load more methods
- (void)refreshTable {
	[_scroll headerEndRefreshing];
	[self refresh];
}

- (void)tableViewRefresh {
	if (![Global isNetwork:YES]) {
		[_scroll headerEndRefreshing];
		return;
	}
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self loadData];
	});
}

- (void)changePrice:(UIView*)parent{
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-15*2, 0)];
	view.backgroundColor = WHITE;
	view.layer.masksToBounds = YES;
	view.layer.cornerRadius = 5;
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.width, 30)];
	label.text = @"修改订单价格";
	label.textColor = COLOR999;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont systemFontOfSize:11];
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	UILabel *text = [[UILabel alloc]initWithFrame:CGRectMake((view.width-(30+70))/2-12, label.bottom+10, 30, 20)];
	text.text = @"￥";
	text.textColor = [UIColor blackColor];
	text.textAlignment = NSTextAlignmentRight;
	text.font = [UIFont systemFontOfSize:14];
	text.backgroundColor = [UIColor clearColor];
	[view addSubview:text];
	SpecialTextField *input = [[SpecialTextField alloc]initWithFrame:CGRectMake(text.right, text.top, 70, 20)];
	input.text = STRINGFORMAT(@"%.2f", [_ms[@"total_price"]floatValue]);
	input.placeholder = @"订单价格";
	input.textColor = [UIColor blackColor];
	input.textAlignment = NSTextAlignmentCenter;
	input.font = [UIFont systemFontOfSize:15];
	input.backgroundColor = [UIColor clearColor];
	input.keyboardType = UIKeyboardTypeDecimalPad;
	[view addSubview:input];
	[input addGeWithType:GeLineTypeBottom];
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake((view.width-120)/2, text.bottom+10, 120, 35);
	btn.titleLabel.font = [UIFont systemFontOfSize:15];
	btn.backgroundColor = MAINSUBCOLOR;
	[btn setTitle:@"确定" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		UITextField *input = (UITextField*)((UIButton*)sender).prevView;
		if (!input.text.length) {
			[ProgressHUD showError:@"请输入价格"];
			return;
		}
		if ([input.text floatValue]<=0) {
			[ProgressHUD showError:@"价格不合法"];
			return;
		}
		[ProgressHUD show:nil];
		NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
		[postData setValue:_ms[@"id"] forKey:@"id"];
		[postData setValue:input.text forKey:@"price"];
		[Common postApiWithParams:@{@"app":@"member", @"act":@"order_change_price"} data:postData feedback:@"修改成功" success:^(NSMutableDictionary *json) {
			//((UILabel*)parent.lastSubview).text = STRINGFORMAT(@"￥%.2f", [input.text floatValue]);
			[self dismissAlertView:DYAlertViewScale];
			[_scroll headerBeginRefreshing];
		} fail:nil];
	}];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 4;
	[view addSubview:btn];
	
	view.height = btn.bottom + 10;
	
	[self presentAlertView:view animation:DYAlertViewScale];
}

-(void)shipping:(UIButton*)sender{
	orderShipping *e = [[orderShipping alloc]init];
	e.delegate = self;
	e.data = _ms;
	[self.navigationController pushViewController:e animated:YES];
}

- (void)getTrans:(UIButton*)sender{
//	orderTrans *g = [[orderTrans alloc]init];
//	g.url = STRINGFORMAT(@"http://m.kuaidi100.com/index_all.html?type=%@&postid=%@", [_ms[@"shipping_company"] URLEncode], _ms[@"shipping_number"]);
//	[self.navigationController pushViewController:g animated:YES];
}

- (void)closeView{
	[self dismissAlertView:DYAlertViewDown];
}

- (UIColor*)statusColor:(NSInteger)status{
	UIColor *color = nil;
	switch (status) {
		case 0:{
			color = MAINSUBCOLOR;
			break;
		}
		case 1:{
			color = ORANGE;
			break;
		}
		case 2:{
			color = BLUE;
			break;
		}
		case 3:
		case 4:{
			color = GREEN;
			break;
		}
		default:{
			color = COLOR999;
			break;
		}
	}
	return color;
}

- (NSString*)statusName:(NSInteger)status{
	NSString *name = nil;
	switch (status) {
		case -3:{
			name = @"已退货";
			break;
		}
		case -2:{
			name = @"已退款";
			break;
		}
		case -1:{
			name = @"取消";
			break;
		}
		case 0:{
			name = @"未支付";
			break;
		}
		case 1:{
			name = @"未发货";
			break;
		}
		case 2:{
			name = @"已发货";
			break;
		}
		case 3:
		case 4:{
			name = @"完成";
			break;
		}
	}
	return name;
}

- (void)refreshDetail{
	[_scroll headerBeginRefreshing];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
