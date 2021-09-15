//
//  AppDelegate.m
//  yidian
//
//  Created by ajsong on 15/12/12.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import "AppDelegate+EaseMob.h"
#import "home.h"
#import "goods.h"
#import "order.h"
#import "chat.h"
#import "talk.h"
#import "member.h"
#import "annualComplete.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[Global statusBarStyle:UIStatusBarStyleLightContent animated:YES];
	[application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	
	[Common getAuditKey:@"on0822" completion:nil];
	
	//安装统计、跟踪
	UMConfigInstance.appKey = UM_APPKEY;
	[MobClick startWithConfigure:UMConfigInstance];
	//[MobClick setLogEnabled:YES];
	
	//消息推送
	[UMessage startWithAppkey:UM_APPKEY launchOptions:launchOptions];
	[UMessage registerForRemoteNotifications];
	//[UMessage setAutoAlert:NO]; //在前台运行收到Push时弹出Alert,默认开启
	//[UMessage setLogEnabled:YES];
	
	//快速登录、分享
	[UMSocialData setAppKey:UM_APPKEY];
	//[UMSocialData openLog:YES];
	
	//腾讯Bugly
	[Bugly startWithAppId:BUGLY_APPID];
	
	KKNavigationController *nav1 = [[KKNavigationController alloc]initWithRootViewController:[[home alloc]init]];
	KKNavigationController *nav2 = [[KKNavigationController alloc]initWithRootViewController:[[goods alloc]init]];
	KKNavigationController *nav3 = [[KKNavigationController alloc]initWithRootViewController:[[order alloc]init]];
	KKNavigationController *nav4 = [[KKNavigationController alloc]initWithRootViewController:[[chat alloc]init]];
	KKNavigationController *nav5 = [[KKNavigationController alloc]initWithRootViewController:[[member alloc]init]];
	
	_tabBarController                      = [[KKTabBarController alloc]init];
	_tabBarController.viewControllers      = @[nav1, nav2, nav3, nav4, nav5];
	_tabBarController.tabBarHeight         = 49;
	_tabBarController.view.backgroundColor = BACKCOLOR;
	_tabBarController.tabBar.translucent   = YES;
	
	int index = 1;
	for (KKTabBarItem *item in _tabBarController.tabBar.items) {
		item.badgeHeight             = 7;
		item.badgeTextFont           = FONT(1);
		item.badgePositionAdjustment = UIOffsetMake(5, 3);
		[item setImage:IMGFORMAT(@"tabBar%d", index) withSelectedImage:IMGFORMAT(@"tabBar%d-x", index)];
		index++;
	}
	
	[self performSelector:@selector(setTabBarBackgroundView) withObject:nil afterDelay:0];
	[self performSelector:@selector(loadEaseMobData) withObject:nil afterDelay:0.1];
	
	//环信
	[self easemobApplication:application didFinishLaunchingWithOptions:launchOptions appkey:EASEMOB_APPKEY apnsCertName:EASEMOB_APNSCERTNAME enableLog:NO];
	[EaseSDKHelper shareHelper].chatListClass = NSClassFromString(@"chat");
	[EaseSDKHelper shareHelper].chatViewClass = NSClassFromString(@"talk");
	
	self.window.rootViewController = _tabBarController;
	self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];
	
	NSMutableDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	if (userInfo) {
		[Global saveFileToTmp:@"userInfo" content:userInfo.descriptionASCII new:YES];
		if ([userInfo[@"type"] isset] && [userInfo[@"type"] isEqualToString:@"chat"]) {
			[self showChat:userInfo];
		}
	}
	
	return YES;
}

- (void)setTabBarBackgroundView{
	_tabBarController.tabBar.backgroundView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
	UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:_tabBarController.tabBar.backgroundView.bounds];
	[_tabBarController.tabBar.backgroundView addSubview:toolBar];
}

- (void)loadEaseMobData{
	NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
	NSInteger count = 0;
	for (int i=0; i<conversations.count; i++) {
		EMConversation *conversation = conversations[i];
		count += [conversation unreadMessagesCount];
	}
	if (count) {
		KKTabBarItem *tabBarItem = _tabBarController.tabBar.items[3];
		tabBarItem.badgeValue = @"1";
	}
}

- (void)didReceiveMessages:(EMMessage*)message{
	KKTabBarItem *tabBarItem = _tabBarController.tabBar.items[3];
	tabBarItem.badgeValue = STRINGFORMAT(@"%d", tabBarItem.badgeValue.intValue+1);
}

- (void)showChat:(NSDictionary*)userInfo{
	if (!userInfo) return;
	if (![userInfo[@"chatter"] isset]) return;
	[self checkPerson:^{
		NSString *content = userInfo[@"aps"][@"alert"];
		if (!content.length) return;
		NSArray *arr = [content split:@":"];
		NSString *title = userInfo[@"chatter"];
		if (arr.count>1) title = arr[0];
		talk *e = [[talk alloc]initWithConversationChatter:userInfo[@"chatter"] conversationType:EMConversationTypeChat];
		e.title = title;
		e.isPresent = YES;
		KKNavigationController *nav = [[KKNavigationController alloc]initWithRootViewController:e];
		[APPCurrentController presentViewController:nav animated:YES completion:nil];
	}];
}

- (void)checkPerson:(void (^)())success{
	NSMutableDictionary *person = PERSON;
	//NSLog(@"person: %@", person.descriptionASCII);
	if (person.isDictionary && [person[@"id"] isset]) {
		[Common getApiWithParams:@{@"app":@"passport", @"act":@"check_sign", @"id":person[@"id"]} feedback:@"nomsg" success:^(NSMutableDictionary *json) {
			if (success) success();
		} fail:^(NSMutableDictionary *json) {
			[ProgressHUD dismiss];
			[@"person" deleteUserDefaults];
			[@"shop" deleteUserDefaults];
			[@"withdraw" deleteUserDefaults];
			
			[@"scanDatas" deleteUserDefaults];
			[@"scanGoodsData" deleteUserDefaults];
			[@"capacity" deleteUserDefaults];
			[@"capacity2" deleteUserDefaults];
			[EaseSDKHelper logout];
			if (!success) [ProgressHUD showWarning:@"该账号已在其他设备登录"];
		}];
	} else {
		[@"person" deleteUserDefaults];
		[@"shop" deleteUserDefaults];
		[@"withdraw" deleteUserDefaults];
		
		[@"scanDatas" deleteUserDefaults];
		[@"scanGoodsData" deleteUserDefaults];
		[@"capacity" deleteUserDefaults];
		[@"capacity2" deleteUserDefaults];
		[EaseSDKHelper logout];
	}
}

- (void)CommonSuccessExecute:(NSMutableDictionary*)json{
	if ([json[@"index_notify"] isset]) {
		int notify = [json[@"index_notify"]intValue];
		[@"index_notify" setUserDefaultsWithData:@(notify)];
		KKTabBarItem *item = _tabBarController.tabBar.items[0];
		item.badgeValue = notify>0 ? STRINGFORMAT(@"%d", notify) : @"";
	}
	if ([json[@"order_notify"] isset]) {
		int notify = [json[@"order_notify"]intValue];
		[@"order_notify" setUserDefaultsWithData:@(notify)];
		KKTabBarItem *item = _tabBarController.tabBar.items[2];
		item.badgeValue = notify>0 ? STRINGFORMAT(@"%d", notify) : @"";
	}
	if ([json[@"notify"] isset]) {
		int notify = [json[@"notify"]intValue];
		[@"notify" setUserDefaultsWithData:@(notify)];
		KKTabBarItem *item = _tabBarController.tabBar.items[4];
		item.badgeValue = notify>0 ? STRINGFORMAT(@"%d", notify) : @"";
	}
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[UMessage registerDeviceToken:deviceToken];
		[[EMClient sharedClient] bindDeviceToken:deviceToken];
	});
	//NSLog(@"%@",[deviceToken description]);
	NSString *token = [[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""];
	token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
	token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults removeObjectForKey:@"udid"];
	[userDefaults setObject:token forKey:@"udid"];
	[userDefaults synchronize];
	//NSLog(@"%@", token);
	[Global saveFileToTmp:@"production_deviceToken" content:token new:YES];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
#if !TARGET_IPHONE_SIMULATOR
	NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
#endif
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	[UMessage didReceiveRemoteNotification:userInfo];
	/*
	 //完全关闭情况下点击APNs进入(这部分代码需要放在 didFinishLaunchingWithOptions 中)
	 NSMutableDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	 if (userInfo) {
		[self showViewController];
	 }
	 */
	/*
	 //正在运行或后台点击APNs进入, 在这里取得 APNs 标准信息内容
	 NSDictionary *aps = userInfo[@"aps"];
	 NSString *content = aps[@"alert"]; //推送显示的内容
	 NSInteger badge = [aps[@"badge"]integerValue]; //badge数量
	 NSString *sound = aps[@"sound"]; //播放的声音
	 */
	//NSLog(@"%@", userInfo);
	[Global saveFileToTmp:@"userInfo" content:userInfo.description new:YES];
	if (application.applicationState == UIApplicationStateActive) {
		//NSLog(@"%@", userInfo.descriptionASCII);
		//前台收到推送时执行
		if ([userInfo[@"type"] isset]) {
			if ([userInfo[@"type"] isEqualToString:@"message"]) {
				//[ToastView content:userInfo[@"aps"][@"alert"] target:nil action:nil];
				int notify = [@"notify" getUserDefaultsInt];
				notify++;
				KKTabBarItem *item = _tabBarController.tabBar.items[4];
				item.badgeValue = !notify ? @"" : STRINGFORMAT(@"%d", notify);
			} else {
				//if (![APPCurrentController isKindOfClass:[chat class]] && ![APPCurrentController isKindOfClass:[talk class]]) {
				//	[ToastView content:userInfo[@"aps"][@"alert"] target:self action:@selector(showChat:) withObject:userInfo];
				//}
				KKTabBarItem *item = _tabBarController.tabBar.items[3];
				item.badgeValue = @"1";
			}
		}
	} else {
		//后台收到推送,点击消息时执行
	}
	[UIApplication sharedApplication].applicationIconBadgeNumber += 1;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	/*
	 //NSLog(@"%@",userInfo);
	 NSDictionary *aps = userInfo[@"aps"];
	 NSString *content = aps[@"alert"]; //推送显示的内容
	 NSInteger badge = [aps[@"badge"]integerValue]; //badge数量
	 NSString *sound = aps[@"sound"]; //播放的声音
	 NSDictionary *extras = userInfo[@"extras"]; //自定义字段内容
	 objc_setAssociatedObject(self, @"APService", extras, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	 [Global toast:content target:self action:@"showViewController"];
	 */
	[self application:application didReceiveRemoteNotification:userInfo];
	completionHandler(UIBackgroundFetchResultNewData);
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
	if ([url.host isEqualToString:@"safepay"]) {
		//这里处理跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给SDK
		[[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
			//NSLog(@"%@",resultDic);
			UINavigationController *nav = KEYWINDOW.currentController.navigationController;
			NSDictionary *data = [@"order" getUserDefaultsDictionary];
			NSString *meal = [@"meal" getUserDefaultsString];
			NSString *recharge = [@"recharge" getUserDefaultsString];
			NSString *annual = [@"annual" getUserDefaultsString];
			[@"order" deleteUserDefaults];
			[@"meal" deleteUserDefaults];
			[@"recharge" deleteUserDefaults];
			[@"annual" deleteUserDefaults];
			//结果处理
			AlipayResult *result = [AlipayResult itemWithDictory:resultDic];
			//用公钥验证签名 严格验证请使用result.resultString与result.signString验签
			if (result && result.statusCode == 9000) { //状态返回9000为成功
				if (meal.length) {
//					mealbuyComplete *e = [[mealbuyComplete alloc]init];
//					e.data = data;
//					[nav pushViewController:e animated:YES];
				} else if (recharge.length) {
					[nav popViewControllerAnimated:YES];
				} else if (annual.length) {
					annualComplete *e = [[annualComplete alloc]init];
					e.data = data;
					[nav pushViewController:e animated:YES];
				} else {
//					bookingComplete *e = [[bookingComplete alloc]init];
//					e.data = data;
//					[nav pushViewController:e animated:YES];
				}
			} else { //失败
				[ProgressHUD showError:@"支付失败"];
				[nav popToRootViewControllerAnimated:YES];
			}
		}];
		return YES;
	} else if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"%@://pay/", WX_APPID]]) {
		//这里处理跳转微信支付返回的结果
		UINavigationController *nav = KEYWINDOW.currentController.navigationController;
		NSDictionary *data = [@"order" getUserDefaultsDictionary];
		NSString *meal = [@"meal" getUserDefaultsString];
		NSString *recharge = [@"recharge" getUserDefaultsString];
		NSString *annual = [@"annual" getUserDefaultsString];
		[@"order" deleteUserDefaults];
		[@"meal" deleteUserDefaults];
		[@"recharge" deleteUserDefaults];
		[@"annual" deleteUserDefaults];
		int errCode = [url.absoluteString.params[@"ret"] intValue];
		switch (errCode) {
			case WXSuccess:{
				NSLog(@"支付成功！retcode = %d", errCode);
				if (meal.length) {
//					mealbuyComplete *e = [[mealbuyComplete alloc]init];
//					e.data = data;
//					[nav pushViewController:e animated:YES];
				} else if (recharge.length) {
					[nav popViewControllerAnimated:YES];
				} else if (annual.length) {
					[nav popViewControllerAnimated:YES];
				} else {
//					bookingComplete *e = [[bookingComplete alloc]init];
//					e.data = data;
//					[nav pushViewController:e animated:YES];
				}
				break;
			}
			default:{
				NSLog(@"支付失败！retcode = %d", errCode);
				[ProgressHUD showError:@"支付失败"];
				[nav popToRootViewControllerAnimated:YES];
				break;
			}
		}
		return YES;
	}
	//这里处理新浪微博SSO授权之后跳转回来，和微信分享完成之后跳转回来
	return [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
	return [UMSocialSnsService handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
	[self checkPerson:nil];
	//这里处理新浪微博SSO授权进入新浪微博客户端后进入后台，再返回原来应用
	[UMSocialSnsService applicationDidBecomeActive];
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

//微信支付
- (void)onResp:(BaseResp*)resp{
	if ([resp isKindOfClass:[PayResp class]]) {
		//支付返回结果，实际支付结果需要去微信服务器端查询
		UINavigationController *nav = KEYWINDOW.currentController.navigationController;
		NSDictionary *data = [@"order" getUserDefaultsDictionary];
		NSString *meal = [@"meal" getUserDefaultsString];
		NSString *recharge = [@"recharge" getUserDefaultsString];
		NSString *annual = [@"annual" getUserDefaultsString];
		[@"order" deleteUserDefaults];
		[@"meal" deleteUserDefaults];
		[@"recharge" deleteUserDefaults];
		[@"annual" deleteUserDefaults];
		switch (resp.errCode) {
			case WXSuccess:{
				NSLog(@"支付成功！retcode = %d", resp.errCode);
				if (meal.length) {
//					mealbuyComplete *e = [[mealbuyComplete alloc]init];
//					e.data = data;
//					[nav pushViewController:e animated:YES];
				} else if (recharge.length) {
					[nav popViewControllerAnimated:YES];
				} else if (annual.length) {
					[nav popViewControllerAnimated:YES];
				} else {
//					bookingComplete *e = [[bookingComplete alloc]init];
//					e.data = data;
//					[nav pushViewController:e animated:YES];
				}
				break;
			}
			default:{
				NSLog(@"支付失败！retcode = %d, retstr = %@", resp.errCode, resp.errStr);
				[ProgressHUD showError:@"支付失败"];
				[nav popToRootViewControllerAnimated:YES];
				break;
			}
		}
	}
}

@end
