/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "AppDelegate+EaseMob.h"

/**
 *  本类中做了EaseMob初始化和推送等操作
 */

@implementation AppDelegate (EaseMob)

- (void)easemobApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
					appkey:(NSString *)appkey
			  apnsCertName:(NSString *)apnsCertName
				 enableLog:(BOOL)enableLog
{
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	//注册登录状态监听
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loginStateChange:)
												 name:KNOTIFICATION_LOGINCHANGE
											   object:nil];
	
	//SDK属性
	EMOptions *options = [EMOptions optionsWithAppkey:appkey];
	options.apnsCertName = apnsCertName;
	options.isAutoAcceptGroupInvitation = NO;
	options.enableConsoleLog = enableLog;
	[[EMClient sharedClient] initializeSDKWithOptions:options];
	
	[[EaseSDKHelper shareHelper] easemobApplication:application
					  didFinishLaunchingWithOptions:launchOptions
											 appkey:appkey
									   apnsCertName:apnsCertName];
	
	BOOL isAutoLogin = [EMClient sharedClient].isAutoLogin;
	if (isAutoLogin){
		[[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
	}
}

#pragma mark - login changed

- (void)loginStateChange:(NSNotification *)notification{
	BOOL loginSuccess = [notification.object boolValue];
	if (loginSuccess) { //登陆成功加载主窗口控制器
		[[EaseSDKHelper shareHelper] performSelector:@selector(asyncConversationFromDB) withObject:nil afterDelay:0];
		[[EaseSDKHelper shareHelper] performSelector:@selector(updatePushOptions) withObject:nil afterDelay:0];
	} else { //登陆失败加载登陆页面控制器
		
	}
}

@end
