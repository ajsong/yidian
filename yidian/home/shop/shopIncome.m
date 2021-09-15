//
//  shopIncome.m
//  yidian
//
//  Created by ajsong on 16/1/4.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "shopIncome.h"
#import "shopIncomeAction.h"
#import "shopIncomeFreeze.h"
#import "shopIncomeOk.h"
#import "shopIncomeNotOk.h"
#import "shopIncomeHistory.h"

@interface shopIncome (){
	NSString *_can_withdraw_money;
	NSString *_freeze_money;
	NSString *_ok_income;
	NSString *_notok_income;
}
@end

@implementation shopIncome

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的收入";
	self.view.backgroundColor = BACKCOLOR;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithImage:IMG(@"s-question") size:CGSizeMake(44, 44) itemType:KKNavigationItemTypeRight];
	[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		outlet *e = [[outlet alloc]init];
		e.title = @"收入说明";
		e.url = STRINGFORMAT(@"%@/wap.php?app=article&act=detail&id=7", API_URL);
		[self.navigationController pushViewController:e animated:YES];
	}];
	
	[ProgressHUD show:nil];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self loadData];
	});
}

#pragma mark - loadData
- (void)loadData{
	[Common getApiWithParams:@{@"app":@"income", @"act":@"index"} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([json[@"data"] isDictionary]) {
			_can_withdraw_money = json[@"data"][@"can_withdraw_money"];
			_freeze_money = json[@"data"][@"freeze_money"];
			_ok_income = json[@"data"][@"ok_income"];
			_notok_income = json[@"data"][@"notok_income"];
		}
		//NSLog(@"%@", _ms);
		[self loadViews];
	} fail:nil];
}

- (void)loadViews{
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120)];
	view.backgroundColor = COLORRGB(@"fdad42");
	[self.view addSubview:view];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self selectRow:0];
	}];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15, 58)];
	label.text = @"可提现金额";
	label.textColor = [UIColor whiteColor];
	label.font = FONT(15);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 58+14, 0, 22)];
	label.text = @"￥";
	label.textColor = [UIColor whiteColor];
	label.font = FONTBOLD(24);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	[label autoWidth];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(label.right, 58, view.width-label.right, 42)];
	label.text = STRINGFORMAT(@"%.2f", [_can_withdraw_money floatValue]);
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont fontWithName:@"STHeitiSC-Light" size:38];
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	UIImageView *push = [[UIImageView alloc]initWithFrame:CGRectMake(view.width-44, 63, 44, 44)];
	push.image = IMG(@"push-white");
	[view addSubview:push];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(push.left-50+10, 77, 50, 15)];
	label.text = @"提现";
	label.textColor = [UIColor whiteColor];
	label.textAlignment = NSTextAlignmentRight;
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[self.view addSubview:view];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15*2, view.height)];
	label.text = @"不可用金额";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	push = [[UIImageView alloc]initWithFrame:CGRectMake(view.width-44, 0, 44, 44)];
	push.image = IMG(@"push-small");
	[view addSubview:push];
	label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, push.left+10, view.height)];
	label.text = STRINGFORMAT(@"￥%.2f", [_freeze_money floatValue]);
	label.textColor = COLOR777;
	label.textAlignment = NSTextAlignmentRight;
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self selectRow:1];
	}];
	
	view = [[UIView alloc]initWithFrame:[view frameBottom:8]];
	view.backgroundColor = WHITE;
	[self.view addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15*2, view.height)];
	label.text = @"已结算收入";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	push = [[UIImageView alloc]initWithFrame:push.frame];
	push.image = IMG(@"push-small");
	[view addSubview:push];
	label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, push.left+10, view.height)];
	label.text = STRINGFORMAT(@"￥%.2f", [_ok_income floatValue]);
	label.textColor = COLOR777;
	label.textAlignment = NSTextAlignmentRight;
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self selectRow:2];
	}];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[self.view addSubview:view];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15*2, view.height)];
	label.text = @"未结算收入";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	push = [[UIImageView alloc]initWithFrame:push.frame];
	push.image = IMG(@"push-small");
	[view addSubview:push];
	label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, push.left+10, view.height)];
	label.text = STRINGFORMAT(@"￥%.2f", [_notok_income floatValue]);
	label.textColor = COLOR777;
	label.textAlignment = NSTextAlignmentRight;
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self selectRow:3];
	}];
	
	view = [[UIView alloc]initWithFrame:[view frameBottom:8]];
	view.backgroundColor = WHITE;
	[self.view addSubview:view];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15*2, view.height)];
	label.text = @"提现记录";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	push = [[UIImageView alloc]initWithFrame:push.frame];
	push.image = IMG(@"push-small");
	[view addSubview:push];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self selectRow:4];
	}];
}

- (void)selectRow:(NSInteger)row{
	switch (row) {
		case 0:{
			if ([_can_withdraw_money floatValue]<100) {
				[ProgressHUD showWarning:@"当前可提现金额不允许操作"];
				return;
			}
			shopIncomeAction *e = [[shopIncomeAction alloc]init];
			//e.data = @{@"can_withdraw_money":_can_withdraw_money};
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 1:{
			shopIncomeFreeze *e = [[shopIncomeFreeze alloc]init];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 2:{
			shopIncomeOk *e = [[shopIncomeOk alloc]init];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 3:{
			shopIncomeNotOk *e = [[shopIncomeNotOk alloc]init];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 4:{
			shopIncomeHistory *e = [[shopIncomeHistory alloc]init];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
