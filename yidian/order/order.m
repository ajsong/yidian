//
//  orderTab.m
//  syoker
//
//  Created by ajsong on 15/4/10.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import "order.h"
#import "orderList.h"

@interface order ()<SUNSlideSwitchViewDelegate,KKNavigationControllerDelegate>{
	SUNSlideSwitchView *_switchView;
	NSMutableArray *_tabs;
	BOOL _isBuildUI;
}
@end

@implementation order

- (void)navigationPushViewController:(KKNavigationController *)navigationController{
	if (self.navigationController.viewControllers.count==1) [self.tabBarControllerKK setTabBarHidden:YES animated:YES];
}

- (void)navigationDidAppearFromPopAction:(KKNavigationController *)navigationController isGesture:(BOOL)flag{
	if (self.navigationController.viewControllers.count==1) [self.tabBarControllerKK setTabBarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	NSDictionary *person = PERSON;
	if (!person.isDictionary) {
		[self.view removeAllSubviews];
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.height)];
		label.text = @"请先登录";
		label.textColor = [UIColor blackColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.font = FONT(14);
		label.backgroundColor = [UIColor clearColor];
		label.numberOfLines = 0;
		label.lineBreakMode = NSLineBreakByTruncatingMiddle;
		[self.view addSubview:label];
		_isBuildUI = NO;
		return;
	}
	
	if (_isBuildUI) return;
	if (self.navigationController.viewControllers.count==1) {
		if ([person[@"shop_id"]integerValue]>0) {
			_act = @"shop_order";
			_isShop = YES;
		} else {
			_act = @"order";
			_isShop = NO;
		}
	}
	
	_isBuildUI = YES;
	[self buildUI];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"订单管理";
	self.view.backgroundColor = BACKCOLOR;
	[self.navigationController setBackgroundColor:NAVBGCOLOR textColor:NAVTEXTCOLOR];
}

- (void)buildUI{
	_switchView = [[SUNSlideSwitchView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_switchView.delegate = self;
	[self.view addSubview:_switchView];
	
	_switchView.tabBarHeight = 44;
	_switchView.navController.backgroundColor = [UIColor whiteColor];
	//_switchView.tabItemFitWidth = YES;
	_switchView.tabItemMargin = 10;
	_switchView.tabItemPadding = 5;
	_switchView.tabItemFont = [UIFont systemFontOfSize:14];
	_switchView.tabItemNormalColor = COLOR666;
	_switchView.tabItemSelectedColor = MAINSUBCOLOR;
	_switchView.shadowImage = [UIImage imageNamed:@"red_line_and_shadow"];
	[_switchView.navController addGeWithType:GeLineTypeBottom];
	
	//status=0：未支付，1：已支付，未发货，2：已支付，已发货，3：完成（已收货），-1：取消，-2：退款，-3：退货
	NSMutableArray *tabs = MSARRAY(@"全部", @"未支付", @"未发货", @"已发货", @"完成", @"取消", @"退货/退款");
	NSMutableArray *status = MSARRAY(@"", @"0", @"1", @"2", @"3,4", @"-1", @"-2,-3");
	
	_tabs = [[NSMutableArray alloc]init];
	for (int i=0; i<tabs.count; i++) {
		orderList *g = [[orderList alloc]init];
		g.title = tabs[i];
		g.status = status[i];
		[_tabs addObject:g];
	}
	
	[_switchView buildUI];
}

#pragma mark - 滑动tab视图代理方法
- (NSUInteger)numberOfTab:(SUNSlideSwitchView *)switchView{
	return _tabs.count;
}

- (UIViewController *)slideSwitchView:(SUNSlideSwitchView *)switchView viewOfTab:(NSUInteger)index{
	return _tabs[index];
}

- (void)slideSwitchView:(SUNSlideSwitchView *)switchView panLeftEdge:(UIPanGestureRecognizer *)panParam{
	[((KKNavigationController*)self.navigationController) paningGestureReceive:panParam];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
