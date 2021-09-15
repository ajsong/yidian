//
//  home.m
//  yidian
//
//  Created by ajsong on 15/12/12.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import "AppDelegate+EaseMob.h"
#import "home.h"
#import "login.h"
#import "shopApply.h"
#import "order.h"
#import "shopIncome.h"
#import "shopSet.h"
#import "product.h"
#import "reseller.h"
#import "fans.h"
#import "shopDelegate.h"
#import "shopOutlet.h"
#import "factory.h"
#import "annualPost.h"

@interface home ()<KKNavigationControllerDelegate>{
	NSMutableDictionary *_person;
	NSDictionary *_ms;
	UIScrollView *_scroll;
	
	ShareHelper *_shareView;
	NSInteger _userID;
	
	NSMutableArray *_codeDatas;
	NSInteger _capacity;
	NSInteger _capacity2;
	
	NSTimer *_timer;
}
@end

@implementation home

- (void)navigationPushViewController:(KKNavigationController *)navigationController{
	[self.tabBarControllerKK setTabBarHidden:YES animated:YES];
}

- (void)navigationDidAppearFromPopAction:(KKNavigationController *)navigationController isGesture:(BOOL)flag{
	[self.tabBarControllerKK setTabBarHidden:NO animated:YES];
}

- (void)pushLogin{
	[self pushLogin:YES];
}

- (void)pushLogin:(BOOL)animated{
	login *e = [[login alloc]init];
	KKNavigationController *nav = [[KKNavigationController alloc]initWithRootViewController:e];
	[self presentViewController:nav animated:animated completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	//return;
	_person = PERSON;
	if (_person.isDictionary && [_person[@"id"] isset]) {
		//if (_userID == [_person[@"id"]integerValue]) return;
		_userID = [_person[@"id"]integerValue];
		[Common getApiWithParams:@{@"app":@"passport", @"act":@"check_sign", @"id":_person[@"id"]} feedback:@"nomsg" success:^(NSMutableDictionary *json) {
			if ([_person[@"member_type"]integerValue]<2) {
				[self loadNormal];
				return;
			}
			[self checkShop];
		} fail:^(NSMutableDictionary *json) {
			[ProgressHUD dismiss];
			[@"person" deleteUserDefaults];
			[@"shop" deleteUserDefaults];
			[@"withdraw" deleteUserDefaults];
			[EaseSDKHelper logout];
			[self pushLogin:NO];
		}];
	} else {
		[ProgressHUD dismiss];
		[@"person" deleteUserDefaults];
		[@"shop" deleteUserDefaults];
		[@"withdraw" deleteUserDefaults];
		[EaseSDKHelper logout];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				[self pushLogin:NO];
				//[self loadNormal];
			});
		});
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
	self.view.backgroundColor = BACKCOLOR;
	[self.navigationController setBackgroundColor:NAVBGCOLOR textColor:NAVTEXTCOLOR];
	
	_person = PERSON;
	_ms = [[NSDictionary alloc]init];
	//NSLog(@"%@", _person);
	
	_scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_scroll.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarControllerKK.tabBarHeight, 0);
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.height-self.tabBarControllerKK.tabBarHeight);
	[self.view addSubview:_scroll];
	
	_shareView = [[ShareHelper alloc]init];
	
	[ProgressHUD show:nil];
	
	/*
	_codeDatas = [[NSMutableArray alloc]init];
	_capacity = 2;
	_capacity2 = 2;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			long long bq1 = 123456160900000000;
			long long bq2 = 123456166900000000;
			long long bq3 = 123456168900000000;
			
			NSMutableArray *codes1 = [[NSMutableArray alloc]init];
			NSMutableArray *codes2 = [[NSMutableArray alloc]init];
			NSMutableArray *codes3 = [[NSMutableArray alloc]init];
			NSInteger capacity = 0;
			NSInteger capacity2 = 0;
			
			for (int i=0; i<=99; i++) {
				[codes1 addObject:STRINGFORMAT(@"%lld", (long long)bq1)];
				bq1++;
				capacity++;
				if (capacity==_capacity) {
					capacity = 0;
					[codes2 addObject:STRINGFORMAT(@"%lld", (long long)bq2)];
					bq2++;
					capacity2++;
					if (capacity2==_capacity2) {
						capacity2 = 0;
						[codes3 addObject:STRINGFORMAT(@"%lld", (long long)bq3)];
						bq3++;
					}
				}
			}
			
			[_codeDatas addObject:codes1];
			[_codeDatas addObject:codes2];
			[_codeDatas addObject:codes3];
			
			//NSLog(@"%@", _codeDatas);
			[self performSelector:@selector(postPackage3) withObject:nil afterDelay:2];
		});
	});
	 */
}

/*
#pragma mark - 绑定三级包装
- (void)postPackage3{
	NSMutableArray *codeDatas = [[NSMutableArray alloc]init];
	NSMutableArray *codes1 = [NSMutableArray arrayWithArray:_codeDatas[0]];
	NSMutableArray *codes2 = [NSMutableArray arrayWithArray:_codeDatas[1]];
	NSMutableArray *codes3 = [NSMutableArray arrayWithArray:_codeDatas[2]];
	if (codes1.count>=_capacity && codes2.count>=_capacity2) {
		for (int k=0; k<codes3.count; k++) {
			NSMutableDictionary *data3 = [[NSMutableDictionary alloc]init];
			NSMutableArray *datas2 = [[NSMutableArray alloc]init];
			for (int j=0; j<codes2.count; j++) {
				NSMutableDictionary *data2 = [[NSMutableDictionary alloc]init];
				NSMutableArray *datas = [[NSMutableArray alloc]init];
				for (int i=0; i<codes1.count; i++) {
					[datas addObject:codes1[i]];
					if (fmod(i+1, _capacity)==0) {
						[data2 setObject:datas forKey:codes2[j]];
						datas = [[NSMutableArray alloc]init];
						[codes1 removeObjectsInRange:NSMakeRange(0, _capacity)];
						break;
					}
				}
				[datas2 addObject:data2];
				if (fmod(j+1, _capacity2)==0) {
					[data3 setObject:datas2 forKey:codes3[k]];
					datas2 = [[NSMutableArray alloc]init];
					[codes2 removeObjectsInRange:NSMakeRange(0, _capacity2)];
					break;
				}
			}
			[codeDatas addObject:data3];
		}
	}
	
	if (!codeDatas.isArray) {
		[ProgressHUD showError:@"请先把标签扫描完整"];
		return;
	}
	
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:@"10144" forKey:@"clientId"];
	[postData setValue:@"352" forKey:@"productId"];
	//[postData setValue:@"true" forKey:@"bind"];
	[postData setValue:codeDatas.jsonString forKey:@"body"];
	//NSLog(@"%@", postData);return;
	[ProgressHUD show:nil];
	[Common postApiWithParams:@{@"app":@"member", @"act":@"factory_package2"} data:postData timeout:-1 feedback:nil success:^(NSMutableDictionary *json) {
		if ([json[@"error"]intValue]==0) {
			[ProgressHUD showSuccess:@"绑定成功"];
		} else {
			NSLog(@"%@", json[@"msg"]);
			[ProgressHUD showError:json[@"msg"]];
		}
	} fail:nil];
}
*/

- (void)checkShop{
	[_scroll removeHeader];
	[_scroll addHeaderWithTarget:self action:@selector(loadData)];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self loadData];
	});
}

- (void)loadData{
	[Common getApiWithParams:@{@"app":@"home", @"act":@"index"} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if (![json[@"data"][@"member"] isDictionary] || ![json[@"data"][@"shop"] isDictionary]) {
			[self loadNormal];
		} else {
			_ms = json[@"data"];
			[@"person" replaceUserDefaultsWithData:@{@"member_type":STRING(_ms[@"member"][@"member_type"])}];
			_person = PERSON;
			NSArray *status = @[@"-1", @"0", @"1", @"-2"];
			NSInteger index = [status indexOfObject:STRING(_ms[@"shop"][@"status"])];
			switch (index) {
				case 0:
				case 3:{
					[self loadClose];
					break;
				}
				case 1:{
					if ([_person[@"member_type"] integerValue]==3) {
						[self loadWait];
					} else {
						[self loadViews];
					}
					break;
				}
				case 2:{
					[self loadViews];
					break;
				}
				default:{
					[self loadNormal];
					break;
				}
			}
		}
		_timer = [NSTimer scheduledTimerWithTimeInterval:2 block:^{
			[_timer stop];
			_timer = nil;
			if (!_scroll.subviews.count) {
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
					[self loadData];
				});
			}
		} repeats:NO];
	} fail:^(NSMutableDictionary *json) {
		[self loadNormal];
		_timer = [NSTimer scheduledTimerWithTimeInterval:2 block:^{
			[_timer stop];
			_timer = nil;
			if (!_scroll.subviews.count) {
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
					[self loadData];
				});
			}
		} repeats:NO];
	}];
}

#pragma mark - Shop status
- (void)loadNormal{
	self.title = @"首页";
	_userID = 0;
	_scroll.backgroundColor = CLEAR;
	[_scroll removeHeader];
	[_scroll removeAllSubviews];
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = nil;
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(8, 8, SCREEN_WIDTH-8*2, 215)];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake((view.width-70)/2, 50, 70, 70)];
	logo.image = IMG(@"h-normal-logo1");
	[view addSubview:logo];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, logo.bottom, view.width, 42)];
	label.text = @"我要成为厂家";
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONTBOLD(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	label = [[UILabel alloc]initWithFrame:CGRectMake(0, label.bottom, view.width, 0)];
	label.text = @"我有实体工厂或品牌，我需要在网上招募\n渠道商扩大销售渠道";
	label.textColor = COLOR999;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONT(12);
	label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 0;
	[view addSubview:label];
	[label autoHeight];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		if (!_person.isDictionary) {
			[self pushLogin];
			return;
		}
		shopApply *e = [[shopApply alloc]init];
		[self.navigationController pushViewController:e animated:YES];
	}];
	
	view = [[UIView alloc]initWithFrame:[view frameBottom:8]];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	logo = [[UIImageView alloc]initWithFrame:CGRectMake((view.width-70)/2, 50, 70, 70)];
	logo.image = IMG(@"h-normal-logo2");
	[view addSubview:logo];
	label = [[UILabel alloc]initWithFrame:CGRectMake(0, logo.bottom, view.width, 42)];
	label.text = @"我要成为渠道商";
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONTBOLD(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	label = [[UILabel alloc]initWithFrame:CGRectMake(0, label.bottom, view.width, 0)];
	label.text = @"我有线下实体的门店或铺面，我希望能代理\n一些厂家的产品，增加客户，扩大销售";
	label.textColor = COLOR999;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONT(12);
	label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 0;
	[view addSubview:label];
	[label autoHeight];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		if (!_person.isDictionary) {
			[self pushLogin];
			return;
		}
		[UIAlertView alert:@"确定要成为渠道商？\n一旦确认，不可修改。" block:^(NSInteger buttonIndex) {
			if (buttonIndex == 1) {
				[Common getApiWithParams:@{@"app":@"home", @"act":@"to_be_reseller"} success:^(NSMutableDictionary *json) {
					if ([json[@"data"] isDictionary]) {
						[_person setObject:@"2" forKey:@"member_type"];
						[_person setObject:json[@"data"] forKey:@"shop"];
						[@"person" setUserDefaultsWithData:_person];
					}
					[self checkShop];
				} fail:nil];
			}
		}];
	}];
	
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.lastSubview.bottom+8);
}

- (void)loadWait{
	self.title = @"店铺审核";
	_userID = 0;
	_scroll.backgroundColor = WHITE;
	[_scroll removeHeader];
	[_scroll removeAllSubviews];
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = nil;
	
	UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake((_scroll.width-220)/2, 0, 220, 200)];
	img.image = IMG(@"h-wait-logo");
	[_scroll addSubview:img];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(25, img.bottom, SCREEN_WIDTH-25*2, 40)];
	label.text = @"您已经提交了店铺申请，请耐心等待审核，谢谢您的配合！";
	label.textColor = [UIColor blackColor];
	label.font = [UIFont systemFontOfSize:14];
	label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 0;
	[_scroll addSubview:label];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(label.left, label.bottom, label.width, 27)];
	label.text = @"如有疑问，请联系客服QQ：2720858701";
	label.textColor = COLOR666;
	label.font = [UIFont systemFontOfSize:14];
	label.backgroundColor = [UIColor clearColor];
	[_scroll addSubview:label];
	
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.lastSubview.bottom);
}

- (void)loadClose{
	self.title = @"店铺关闭";
	_userID = 0;
	_scroll.backgroundColor = WHITE;
	[_scroll removeHeader];
	[_scroll removeAllSubviews];
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = nil;
	
	UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake((_scroll.width-220)/2, 0, 220, 200)];
	img.image = IMG(@"h-close-logo");
	[_scroll addSubview:img];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(40, img.bottom, SCREEN_WIDTH-40, 40)];
	label.text = @"店铺已经关闭，请与客服联系：";
	label.textColor = [UIColor blackColor];
	label.font = [UIFont systemFontOfSize:16];
	label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 0;
	[_scroll addSubview:label];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(label.left, label.bottom, label.width, 40)];
	label.text = @"客服QQ：2850668620\nE-MAIL ：service@youbesun.com";
	label.textColor = COLOR666;
	label.font = [UIFont systemFontOfSize:14];
	label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 0;
	[_scroll addSubview:label];
	
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.lastSubview.bottom);
}

#pragma mark - loadViews
- (void)loadViews{
	self.title = @"首页";
	_scroll.backgroundColor = WHITE;
	[_scroll headerEndRefreshing];
	_scroll.headerHidden = NO;
	[_scroll removeAllSubviews];
	
	if (![Common isAuditKey] && [_person[@"member_type"]integerValue]==3) {
		KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"店铺预览" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeLeft];
		[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
			shopOutlet *e = [[shopOutlet alloc]init];
			e.title = @"店铺预览";
			e.url = STRINGFORMAT(@"%@/wap.php?app=eshop&act=other_shop_index&shop_id=%@", API_URL, _person[@"shop"][@"id"]);
			[self.navigationController pushViewController:e animated:YES];
		}];
		
		item = [self.navigationItem setItemWithTitle:@"分享" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
		[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
			[Global cacheImageWithUrl:_person[@"shop"][@"avatar"] completion:^(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache) {
				NSString *code = _person[@"shop"][@"id"];
				_shareView.title = _person[@"shop"][@"name"];
				_shareView.image = image;
				_shareView.content = _person[@"shop"][@"description"];
				_shareView.url = STRINGFORMAT(@"%@/wap.php?app=eshop&act=other_shop_index&shop_id=%@&reseller=%@", API_URL, code, code);
				[_shareView show];
			}];
		}];
	} else {
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.rightBarButtonItem = nil;
	}
	
	CGFloat top = 0;
	NSString *string = @"";
	NSDictionary *style = [[NSDictionary alloc]init];
	UILabel *label;
	
	if (![Common isAuditKey]) {
		string = STRINGFORMAT(@"<p>%.2f</p>\n累计收入", [_ms[@"shop"][@"total_income"]floatValue]);
		style = @{@"body":@[FONT(13), COLOR777], @"p":@[FONT(22), BLACK]};
		label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 78)];
		label.attributedText = [string attributedStyle:style];
		label.textAlignment = NSTextAlignmentCenter;
		label.backgroundColor = [UIColor clearColor];
		label.numberOfLines = 0;
		[_scroll addSubview:label];
		[label addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
		[label click:^(UIView *view, UIGestureRecognizer *sender) {
			shopIncome *e = [[shopIncome alloc]init];
			[self.navigationController pushViewController:e animated:YES];
		}];
		
		top = label.bottom;
	}
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, top, SCREEN_WIDTH, 65)];
	[_scroll addSubview:view];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		self.tabBarControllerKK.selectedIndex = 2;
	}];
	
	string = STRINGFORMAT(@"<p>%@</p>\n七日订单", _ms[@"shop"][@"week_orders"]);
	style = @{@"body":@[FONT(13), COLOR777], @"p":@[FONT(15), BLACK]};
	label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.width/3, view.height)];
	label.attributedText = [string attributedStyle:style];
	label.textAlignment = NSTextAlignmentCenter;
	label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 0;
	[view addSubview:label];
	
	string = STRINGFORMAT(@"<p>%@</p>\n七日销售", _ms[@"shop"][@"week_income"]);
	//style = @{@"body":@[FONT(13), COLOR777], @"p":@[FONT(13), BLACK]};
	label = [[UILabel alloc]initWithFrame:CGRectMake(label.right, 0, label.width, view.height)];
	label.attributedText = [string attributedStyle:style];
	label.textAlignment = NSTextAlignmentCenter;
	label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 0;
	[view addSubview:label];
	
	string = STRINGFORMAT(@"<p>%@</p>\n订单总数", _ms[@"shop"][@"orders"]);
	//style = @{@"body":@[FONT(13), COLOR777], @"p":@[FONT(13), BLACK]};
	label = [[UILabel alloc]initWithFrame:CGRectMake(label.right, 0, label.width, view.height)];
	label.attributedText = [string attributedStyle:style];
	label.textAlignment = NSTextAlignmentCenter;
	label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 0;
	[view addSubview:label];
	
	UIView *ge = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 8)];
	ge.backgroundColor = BACKCOLOR;
	[_scroll addSubview:ge];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, ge.bottom+20, SCREEN_WIDTH, 0)];
	[_scroll addSubview:view];
	
	int member_type = [_person[@"member_type"]intValue];
	NSMutableArray *subviews = [[NSMutableArray alloc]init];
	NSArray *names = @[@"商品管理", @"订单管理", @"我的店铺", @"渠道商管理", @"我的粉丝", @"入库管理"];
	NSString *cate_mark = @"1";
	if (member_type==2) {
		names = @[@"订单管理", @"下级渠道商", @"代理店铺"];
		cate_mark = @"2";
	}
	for (int i=0; i<names.count; i++) {
		UIView *subview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, floor(SCREEN_WIDTH/3), 100)];
		UIImageView *ico = [[UIImageView alloc]initWithFrame:CGRectMake((subview.width-74)/2, 0, 74, 74)];
		ico.image = IMGFORMAT(@"h-cate%@-ico%d", cate_mark, i+1);
		[subview addSubview:ico];
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, ico.bottom, subview.width, 16)];
		label.text = names[i];
		label.textColor = COLOR777;
		label.textAlignment = NSTextAlignmentCenter;
		label.font = FONT(13);
		label.backgroundColor = [UIColor clearColor];
		[subview addSubview:label];
		if (i==3 && member_type==3 && [@"index_notify" getUserDefaultsInt]>0) {
			UIView *dot = [[UIView alloc]initWithFrame:CGRectMake(label.width/3*2+15, label.top-3, 7, 7)];
			dot.backgroundColor = COLORRGB(@"ea0617");
			dot.layer.masksToBounds = YES;
			dot.layer.cornerRadius = dot.height/2;
			[subview addSubview:dot];
		}
		[subview click:^(UIView *view, UIGestureRecognizer *sender) {
			if ([cate_mark integerValue]==1) {
				[self selectRow:i];
			} else {
				[self selectRow2:i];
			}
		}];
		[subviews addObject:subview];
	}
	[view autoLayoutSubviews:subviews marginPT:0 marginPL:0 marginPR:0];
	view.height = view.lastSubview.bottom;
	
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.lastSubview.bottom+20);
	[_scroll MJRefreshAutoContentSize];
	
	if (member_type==3) {
		if ([_ms[@"shop"][@"must_annual_fee"]intValue]==1) {
			UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
			view.backgroundColor = COLORRGB(@"FFFFCC");
			[_scroll addSubview:view];
			
			NSString *expire_time = _ms[@"shop"][@"expire_time"];
			NSString *expire = [expire_time isEqualToString:@"-"] ? @"即将" : [NSString stringWithFormat:@"将于%@", _ms[@"shop"][@"expire_time"]];
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, view.width-5, view.height)];
			label.text = STRINGFORMAT(@"您的账号%@到期，请及时缴纳年费！", expire);
			label.textColor = [UIColor blackColor];
			label.font = FONT(11);
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			
			[view click:^(UIView *view, UIGestureRecognizer *sender) {
				annualPost *e = [[annualPost alloc]init];
				[self.navigationController pushViewController:e animated:YES];
			}];
		}
		if ([_ms[@"shop"][@"must_annual_fee"]intValue]==2) {
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"您的账号已被冻结，需要支付年费才能激活。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"立即支付", nil];
			[alert showWithBlock:^(NSInteger buttonIndex) {
				if (buttonIndex==0) {
					annualPost *e = [[annualPost alloc]init];
					[self.navigationController pushViewController:e animated:YES];
				}
			}];
		}
	}
}

- (void)selectRow:(NSInteger)row{
	switch (row) {
		case 0:{
			product *e = [[product alloc]init];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 1:{
			self.tabBarControllerKK.selectedIndex = 2;
			break;
		}
		case 2:{
			shopSet *e = [[shopSet alloc]init];
			e.data = _ms[@"shop"];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 3:{
			reseller *e = [[reseller alloc]init];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 4:{
			fans *e = [[fans alloc]init];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 5:{
			factory *e = [[factory alloc]init];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
	}
}

- (void)selectRow2:(NSInteger)row{
	switch (row) {
		case 0:{
			self.tabBarControllerKK.selectedIndex = 2;
			break;
		}
		case 1:{
			reseller *e = [[reseller alloc]init];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 2:{
			shopDelegate *e = [[shopDelegate alloc]init];
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
