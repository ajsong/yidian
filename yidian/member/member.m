//
//  member.m
//  yidian
//
//  Created by ajsong on 15/12/12.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import "AppDelegate+EaseMob.h"
#import "member.h"
#import "login.h"
#import "mobile.h"
#import "feedback.h"
#import "message.h"
#import "invite.h"
#import "info.h"
#import "withdraw.h"
#import "annual.h"

@interface member ()<KKNavigationControllerDelegate>{
	NSDictionary *_person;
	UIScrollView *_scroll;
}
@end

@implementation member

- (void)navigationPushViewController:(KKNavigationController *)navigationController{
	[self.tabBarControllerKK setTabBarHidden:YES animated:YES];
}

- (void)navigationDidAppearFromPopAction:(KKNavigationController *)navigationController isGesture:(BOOL)flag{
	[self.tabBarControllerKK setTabBarHidden:NO animated:YES];
}

- (void)pushLogin{
	login *e = [[login alloc]init];
	KKNavigationController *nav = [[KKNavigationController alloc]initWithRootViewController:e];
	[self presentViewController:nav animated:YES completion:nil];
}

- (void)pushMobile{
	mobile *e = [[mobile alloc]init];
	e.isFirst = YES;
	KKNavigationController *nav = [[KKNavigationController alloc]initWithRootViewController:e];
	[self presentViewController:nav animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	_person = PERSON;
	//NSLog(@"%@", _person);
	if (_person.isDictionary) {
		[Common getApiWithParams:@{@"app":@"passport", @"act":@"check_sign", @"id":_person[@"id"]} feedback:@"nomsg" success:^(NSMutableDictionary *json) {
			//NSLog(@"%@", json);
			[self loadViews];
		} fail:^(NSMutableDictionary *json) {
			if ([json[@"msg_type"]integerValue]==-9) [self autoLogout];
		}];
	} else {
		[self logout];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"会员";
	self.view.backgroundColor = BACKCOLOR;
	[self.navigationController setBackgroundColor:NAVBGCOLOR textColor:NAVTEXTCOLOR];
	
	_person = PERSON;
	//NSLog(@"%@", _person);
	
	_scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_scroll.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarControllerKK.tabBarHeight, 0);
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.height);
	[self.view addSubview:_scroll];
}

- (void)loadViews{
	[_scroll removeAllSubviews];
	
	UIFont *font = FONT(14);
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	UIImageView *ico = [[UIImageView alloc]initWithFrame:CGRectMake(15, (view.height-20)/2, 20, 20)];
	ico.image = IMG(@"m-ico01");
	[view addSubview:ico];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(ico.right+15, 0, view.width-(ico.right+15), view.height)];
	label.text = @"修改信息";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	UIImageView *push = [[UIImageView alloc]initWithFrame:CGRectMake(view.width-44, 0, 44, 44)];
	push.image = IMG(@"push");
	[view addSubview:push];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self selectRow:0];
	}];
	
	if (![Common isAuditKey]) {
		view = [[UIView alloc]initWithFrame:view.frameBottom];
		view.backgroundColor = WHITE;
		[_scroll addSubview:view];
		[view addGeWithType:GeLineTypeTop color:COLOR_GE_LIGHT];
		ico = [[UIImageView alloc]initWithFrame:ico.frame];
		ico.image = IMG(@"m-ico02");
		[view addSubview:ico];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = @"提现账户";
		label.textColor = [UIColor blackColor];
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		push = [[UIImageView alloc]initWithFrame:push.frame];
		push.image = IMG(@"push");
		[view addSubview:push];
		[view click:^(UIView *view, UIGestureRecognizer *sender) {
			[self selectRow:1];
		}];
	}
	
	if ([_person[@"member_type"]intValue]==3 && ![Common isAuditKey]) {
		view = [[UIView alloc]initWithFrame:view.frameBottom];
		view.backgroundColor = WHITE;
		[_scroll addSubview:view];
		[view addGeWithType:GeLineTypeTop color:COLOR_GE_LIGHT];
		ico = [[UIImageView alloc]initWithFrame:ico.frame];
		ico.image = IMG(@"m-ico09");
		[view addSubview:ico];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = @"服务年费";
		label.textColor = [UIColor blackColor];
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		push = [[UIImageView alloc]initWithFrame:push.frame];
		push.image = IMG(@"push");
		[view addSubview:push];
		[view click:^(UIView *view, UIGestureRecognizer *sender) {
			[self selectRow:4];
		}];
	}
	
	view = [[UIView alloc]initWithFrame:[view frameBottom:8]];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:COLOR_GE_LIGHT];
	ico = [[UIImageView alloc]initWithFrame:ico.frame];
	ico.image = IMG(@"m-ico03");
	[view addSubview:ico];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"我的邀请码";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	push = [[UIImageView alloc]initWithFrame:push.frame];
	push.image = IMG(@"push");
	[view addSubview:push];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self selectRow:2];
	}];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	ico = [[UIImageView alloc]initWithFrame:ico.frame];
	ico.image = IMG(@"m-ico05");
	[view addSubview:ico];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"我的消息";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	push = [[UIImageView alloc]initWithFrame:push.frame];
	push.image = IMG(@"push");
	[view addSubview:push];
	if ([@"notify" getUserDefaultsInt]>0) {
		UIView *dot = [[UIView alloc]initWithFrame:CGRectMake(102, 10, 7, 7)];
		dot.backgroundColor = COLORRGB(@"ea0617");
		dot.layer.masksToBounds = YES;
		dot.layer.cornerRadius = dot.height/2;
		[view addSubview:dot];
	}
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self selectRow:3];
	}];
	
	view = [[UIView alloc]initWithFrame:[view frameBottom:8]];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:COLOR_GE_LIGHT];
	ico = [[UIImageView alloc]initWithFrame:ico.frame];
	ico.image = IMG(@"m-ico06");
	[view addSubview:ico];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"帮助中心";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	push = [[UIImageView alloc]initWithFrame:push.frame];
	push.image = IMG(@"push");
	[view addSubview:push];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self selectRow:28];
	}];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:COLOR_GE_LIGHT];
	ico = [[UIImageView alloc]initWithFrame:ico.frame];
	ico.image = IMG(@"m-ico07");
	[view addSubview:ico];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"意见反馈";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	push = [[UIImageView alloc]initWithFrame:push.frame];
	push.image = IMG(@"push");
	[view addSubview:push];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self selectRow:29];
	}];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	ico = [[UIImageView alloc]initWithFrame:ico.frame];
	ico.image = IMG(@"m-ico08");
	[view addSubview:ico];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"关于我们";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	push = [[UIImageView alloc]initWithFrame:push.frame];
	push.image = IMG(@"push");
	[view addSubview:push];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self selectRow:30];
	}];
	
	if (_person.isDictionary) {
		if ([_person[@"name"] isEqualToString:@"ajsong"] || [_person[@"name"] isEqualToString:@"厂家22"]) {
			view = [[UIView alloc]initWithFrame:[view frameBottom:8]];
			view.backgroundColor = WHITE;
			[_scroll addSubview:view];
			[view addGeWithType:GeLineTypeBottom color:COLOR_GE_LIGHT];
			ico = [[UIImageView alloc]initWithFrame:ico.frame];
			ico.image = IMG(@"m-ico1000");
			[view addSubview:ico];
			label = [[UILabel alloc]initWithFrame:label.frame];
			label.text = @"清除缓存";
			label.textColor = [UIColor blackColor];
			label.font = font;
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			NSInteger byte = [[TMCache sharedCache] diskByteCount];
			UILabel *size = [[UILabel alloc]initWithFrame:CGRectMake(view.width-100-15, 0, 100, view.height)];
			size.text = [Global formatSize:byte unit:nil];
			size.textColor = COLOR999;
			size.textAlignment = NSTextAlignmentRight;
			size.font = FONT(13);
			size.backgroundColor = [UIColor clearColor];
			size.tag = 1000;
			[view addSubview:size];
			[view click:^(UIView *view, UIGestureRecognizer *sender) {
				[self selectRow:99];
			}];
			
			view = [[UIView alloc]initWithFrame:view.frameBottom];
			view.backgroundColor = WHITE;
			[_scroll addSubview:view];
			ico = [[UIImageView alloc]initWithFrame:ico.frame];
			ico.image = IMG(@"m-ico1000");
			[view addSubview:ico];
			label = [[UILabel alloc]initWithFrame:label.frame];
			label.text = @"查看TMP";
			label.textColor = [UIColor blackColor];
			label.font = font;
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			push = [[UIImageView alloc]initWithFrame:push.frame];
			push.image = IMG(@"push");
			[view addSubview:push];
			[view click:^(UIView *view, UIGestureRecognizer *sender) {
				[self selectRow:100];
			}];
		}
		
		view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, view.width, 60)];
		[_scroll addSubview:view];
		UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, view.width-10*2, 40)];
		btn.titleLabel.font = [UIFont systemFontOfSize:15];
		btn.backgroundColor = MAINSUBCOLOR;
		[btn setTitle:@"退出登录" forState:UIControlStateNormal];
		[btn setTitleColor:WHITE forState:UIControlStateNormal];
		[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
			[self logout];
		}];
		btn.layer.masksToBounds = YES;
		btn.layer.cornerRadius = 4;
		[view addSubview:btn];
	}
	
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.lastSubview.bottom);
}

- (void)selectRow:(NSInteger)row{
	if (!_person.isDictionary && row<28) {
		[self pushLogin];
		return;
	}
	switch (row) {
		case 0:{
			info *e = [[info alloc]init];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 1:{
			withdraw *e = [[withdraw alloc]init];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 2:{
			if (![_person[@"shop"] isset]) {
				[ProgressHUD showWarning:@"请先申请厂家或渠道商"];
				return;
			}
			invite *e = [[invite alloc]init];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 3:{
			message *e = [[message alloc]init];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 4:{
			annual *e = [[annual alloc]init];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 28:{
			outlet *e = [[outlet alloc]init];
			e.title = @"帮助中心";
			e.url = STRINGFORMAT(@"%@/wap.php?app=article&act=detail&id=2", API_URL);
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 29:{
			feedback *e = [[feedback alloc]init];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 30:{
			outlet *e = [[outlet alloc]init];
			e.title = @"关于我们";
			e.url = STRINGFORMAT(@"%@/wap.php?app=article&act=detail&id=1", API_URL);
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 99:{
			[[TMCache sharedCache] removeAllObjects];
			[ProgressHUD showSuccess:@"清除完毕"];
			UILabel *label = (UILabel*)[self.view viewWithTag:1000];
			NSInteger byte = [[TMCache sharedCache] diskByteCount];
			label.text = [Global formatSize:byte unit:nil];
			break;
		}
		case 100:{
			[Global touchIDWithReason:@"该操作需要指纹认证" passwordTitle:@"输入密码" success:^{
				GFileList *e = [[GFileList alloc]initWithFolderPath:@"tmp"];
				[self.navigationController pushViewController:e animated:YES];
			} fail:nil nosupport:^{
				GFileList *e = [[GFileList alloc]initWithFolderPath:@"tmp"];
				[self.navigationController pushViewController:e animated:YES];
			}];
			break;
		}
	}
}

- (void)logout{
	if (!_person.isDictionary) {
		[self pushLogin];
		return;
	}
	[EaseSDKHelper logout];
	[ProgressHUD show:nil];
	[Common getApiWithParams:@{@"app":@"passport", @"act":@"logout"} success:^(NSMutableDictionary *json) {
		[@"person" deleteUserDefaults];
		[@"shop" deleteUserDefaults];
		[@"withdraw" deleteUserDefaults];
		
		[@"scanDatas" deleteUserDefaults];
		[@"scanGoodsData" deleteUserDefaults];
		[@"capacity" deleteUserDefaults];
		[@"capacity2" deleteUserDefaults];
		_person = PERSON;
		[self pushLogin];
		//[_scroll opacityFn:0.3 afterHidden:^{
		//	[self loadViews];
		//} completion:nil];
	} fail:nil];
}

- (void)autoLogout{
	[EaseSDKHelper logout];
	[ProgressHUD showWarning:@"该账号已在其他设备登录"];
	[Common getApiWithParams:@{@"app":@"passport", @"act":@"logout"} feedback:nil success:^(NSMutableDictionary *json) {
		[@"person" deleteUserDefaults];
		[@"shop" deleteUserDefaults];
		[@"withdraw" deleteUserDefaults];
		
		[@"scanDatas" deleteUserDefaults];
		[@"scanGoodsData" deleteUserDefaults];
		[@"capacity" deleteUserDefaults];
		[@"capacity2" deleteUserDefaults];
		_person = PERSON;
		[self pushLogin];
	} fail:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
