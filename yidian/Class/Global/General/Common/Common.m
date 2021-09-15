//
//  Common.m
//
//  Created by ajsong on 15/4/23.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global+AppDelegate.h"

@implementation Common

//组合接口与参数
+ (NSString*)apiUrlWithFile:(NSString*)file params:(NSDictionary*)params{
	NSString *url = [NSString stringWithFormat:@"%@/%@?sdk=%@%@", API_URL, file, SDK_VERSION, API_PARAMETER];
	if (params.isDictionary) {
		NSMutableString *strings = [[NSMutableString alloc]init];
		for (NSString *key in params) {
			[strings appendFormat:@"&%@=%@", key, [STRING(params[key])URLEncode]];
		}
		url = [NSString stringWithFormat:@"%@%@", url, strings];
	}
	return url;
}

+ (NSString*)getApiWithParams:(NSDictionary*)params complete:(void (^)(NSMutableDictionary *))complete{
	return [Common getApiWithParams:params feedback:nil complete:complete];
}
+ (NSString*)getApiWithParams:(NSDictionary*)params feedback:(NSString*)feedback complete:(void (^)(NSMutableDictionary *))complete{
	NSString *url = [Common apiUrlWithFile:API_FILE params:params];
	return [Common getApiWithUrl:url type:nil feedback:feedback cachetime:0 success:nil fail:nil complete:complete];
}
+ (NSString*)getApiWithParams:(NSDictionary*)params success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common getApiWithParams:params feedback:nil cachetime:0 success:success fail:fail];
}
+ (NSString*)getApiWithParams:(NSDictionary*)params cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common getApiWithParams:params feedback:nil cachetime:cachetime success:success fail:fail];
}
+ (NSString*)getApiWithParams:(NSDictionary*)params feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common getApiWithParams:params feedback:feedback cachetime:0 success:success fail:fail];
}
+ (NSString*)getApiWithParams:(NSDictionary*)params feedback:(NSString*)feedback cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	NSString *url = [Common apiUrlWithFile:API_FILE params:params];
	return [Common getApiWithUrl:url feedback:feedback cachetime:cachetime success:success fail:fail];
}
+ (NSString*)getApiWithFile:(NSString*)file params:(NSDictionary*)params feedback:(NSString*)feedback cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	NSString *url = [Common apiUrlWithFile:file params:params];
	return [Common getApiWithUrl:url feedback:feedback cachetime:cachetime success:success fail:fail];
}
+ (NSString*)getApiWithUrl:(NSString*)url success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common getApiWithUrl:url feedback:nil cachetime:0 success:success fail:fail];
}
+ (NSString*)getApiWithUrl:(NSString*)url type:(NSString*)type success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common getApiWithUrl:url type:type feedback:nil cachetime:0 success:success fail:fail complete:nil];
}
+ (NSString*)getApiWithUrl:(NSString*)url cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common getApiWithUrl:url feedback:nil cachetime:cachetime success:success fail:fail];
}
+ (NSString*)getApiWithUrl:(NSString*)url feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common getApiWithUrl:url feedback:feedback cachetime:0 success:success fail:fail];
}
+ (NSString*)getApiWithUrl:(NSString*)url feedback:(NSString*)feedback cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{ //cachetime:单位秒
	return [Common getApiWithUrl:url type:@"json" feedback:feedback cachetime:cachetime success:success fail:fail complete:nil];
}
+ (NSString*)getApiWithUrl:(NSString*)url type:(NSString*)type feedback:(NSString*)feedback cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail complete:(void (^)(NSMutableDictionary *json))complete{
#ifdef DEBUG
	NSLog(@"%@", url);
#endif
	NSString *cacheFolder = @"CacheDatas";
	NSString *cacheFilename = [url.URLEncode replace:@"." to:@"%2E"];
	NSString *cachePath = [NSString stringWithFormat:@"%@/%@", cacheFolder, cacheFilename];
	if (cachetime>0) {
		if ([Global fileExistFromTmp:cachePath]) {
			NSMutableDictionary *attributes = [Global fileAttributes:[Global getFilePathFromTmp:cachePath]];
			if ([Global dateDiff:@"s" earlyDate:attributes[@"createdate"] lateDate:[Global nowDate]] <= cachetime) {
				NSString *cacheString = [Global getFileTextFromTmp:cachePath];
				if ([type isEqualToString:@"json"]) {
					NSMutableDictionary *json = cacheString.formatJson;
					if (json.isDictionary) {
						dispatch_async(dispatch_get_main_queue(), ^{
							if (![feedback isEqualToString:@"always"]) [ProgressHUD dismiss];
							if (success) success(json);
							if (complete) complete(json);
							[Common successExecute:json];
						});
						return url;
					}
				} else {
					dispatch_async(dispatch_get_main_queue(), ^{
						if (![feedback isEqualToString:@"always"]) [ProgressHUD dismiss];
						if (success) success((NSMutableDictionary*)cacheString);
						if (complete) complete((NSMutableDictionary*)cacheString);
						[Common successExecute:(NSMutableDictionary*)cacheString];
					});
					return url;
				}
			}
		}
	}
	if (![Global isNetwork:![feedback isEqualToString:@"nomsg"]]) {
		NSMutableDictionary *json = MSDICTIONARY(@0, API_KEY_MSGTYPE, @"NO NETWORK", API_KEY_MSG);
		dispatch_async(dispatch_get_main_queue(), ^{
			if (fail) fail(json);
			if (complete) complete(json);
		});
		[ProgressHUD dismiss];
		return url;
	}
	__block NSString *string = feedback;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[Global get:url data:nil completion:^(NSString *result) {
			if ([type isEqualToString:@"json"]) {
				NSMutableDictionary *json = (NSMutableDictionary*)result;
				if ([result isKindOfClass:[NSString class]]) json = result.formatJson;
#ifdef DEBUG
				NSLog(@"\n%@", json.descriptionASCII);
#endif
				if (json.isDictionary) {
					if ([json[API_KEY_ERROR] isset] && [json[API_KEY_MSGTYPE] isset]) {
						if ([json[API_KEY_ERROR] intValue]==API_KEY_ERROR_CODE) {
							if (![string isEqualToString:@"always"]) {
								if ([string isEqualToString:@"msg"] && [json[API_KEY_MSG] isset]) {
									[ProgressHUD showSuccess:json[API_KEY_MSG]];
								} else {
									[ProgressHUD dismiss];
								}
							}
							if (success) success(json);
							[Common successExecute:json];
							if (cachetime>0) {
								[Global makeDirFromTmp:cacheFolder];
								//以网址作为文件名缓存数据
								[Global saveFileToTmp:cachePath content:result new:YES];
							}
						} else {
							if (![string isEqualToString:@"nomsg"]) {
								if ( !([json[API_KEY_MSGTYPE]intValue]==-100 && NSClassFromString(@"login")) ) {
									if ([json[API_KEY_MSG] isset]) {
										[ProgressHUD showError:json[API_KEY_MSG]];
									} else {
										[ProgressHUD showError:@"提交失败"];
									}
								}
							} else {
								[ProgressHUD dismiss];
							}
							if (fail) fail(json);
							[Common errorExecute:json];
						}
					} else {
						if (![string isEqualToString:@"always"]) [ProgressHUD dismiss];
						if (success) success(json);
					}
				} else {
					NSString *description = STRINGFORMAT(@"\n%@\n%@", url, result);
					NSLog(@"%@", description);
					if ([API_ERROR_SENDEMAIL length]) {
						UIImage *attachment = [Global imageWithView:KEYWINDOW frame:[UIScreen mainScreen].bounds];
						attachment = [attachment fitToSize:CGSizeMake(640, 0)];
						[SKPSMTPMessage sendEmailTo:API_ERROR_SENDEMAIL title:STRINGFORMAT(@"%@(APP)接口出错", APP_NAME) content:description attachment:attachment.data];
					}
					NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
					if ([result indexOf:@"Undefined index: member in"]!=NSNotFound) [json setObject:@(-100) forKey:API_KEY_MSGTYPE];
					if (fail) fail(json);
					[Common errorExecute:json];
				}
				if (complete) complete(json);
			} else {
				if (![string isEqualToString:@"always"]) [ProgressHUD dismiss];
				if (success) success((NSMutableDictionary*)result);
				[Common successExecute:(NSMutableDictionary*)result];
				if (cachetime>0) {
					[Global makeDirFromTmp:cacheFolder];
					[Global saveFileToTmp:cachePath content:result new:YES];
				}
				if (complete) complete((NSMutableDictionary*)result);
			}
		} fail:^(NSString *description, NSInteger code) {
			NSMutableDictionary *json = MSDICTIONARY(@0, API_KEY_MSGTYPE, @"DATA ERROR", API_KEY_MSG);
			if (fail) fail(json);
			if (complete) complete(json);
			[Common errorExecute:json];
		}];
	});
	return url;
}

+ (NSString*)postAutoApiWithParams:(NSDictionary*)params data:(NSDictionary*)data success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common postAutoApiWithParams:params data:data feedback:@"提交成功" success:success fail:fail];
}
+ (NSString*)postAutoApiWithParams:(NSDictionary*)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	BOOL formData = NO;
	if (data.count) {
		for (NSString *key in data) {
			if ([data[key] isKindOfClass:[UIImage class]] || [data[key] isKindOfClass:[NSData class]]) {
				formData = YES;
				break;
			}
		}
	}
	if (!formData) {
		return [Common postApiWithParams:params data:data feedback:feedback success:success fail:fail];
	} else {
		return [Common uploadApiWithParams:params data:data feedback:feedback success:success fail:fail];
	}
}

+ (NSString*)postApiWithParams:(NSDictionary*)params data:(NSDictionary*)data success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common postApiWithParams:params data:data feedback:@"提交成功" success:success fail:fail];
}
+ (NSString*)postApiWithParams:(NSDictionary*)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common postApiWithFile:API_FILE params:params data:data feedback:feedback success:success fail:fail];
}
+ (NSString*)postApiWithParams:(NSDictionary*)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common postApiWithFile:API_FILE params:params data:data timeout:timeout feedback:@"nomsg" success:success fail:fail complete:nil];
}
+ (NSString*)postApiWithParams:(NSDictionary*)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common postApiWithFile:API_FILE params:params data:data timeout:timeout feedback:feedback success:success fail:fail complete:nil];
}
+ (NSString*)postApiWithFile:(NSString*)file params:(NSDictionary*)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common postApiWithFile:file params:params data:data timeout:5 feedback:feedback success:success fail:fail complete:nil];
}
+ (NSString*)postApiWithFile:(NSString*)file params:(NSDictionary*)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail complete:(void (^)(NSMutableDictionary *json))complete{
	NSString *url = [Common apiUrlWithFile:file params:params];
	return [Common postApiWithUrl:url data:data timeout:timeout feedback:feedback success:success fail:fail complete:complete];
}
+ (NSString*)postApiWithUrl:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail complete:(void (^)(NSMutableDictionary *json))complete{
	return [Common postApiWithUrl:url data:data type:nil timeout:timeout feedback:feedback success:success fail:fail complete:complete];
}
+ (NSString*)postJSONWithUrl:(NSString*)url data:(id)data success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common postJSONWithUrl:url data:data timeout:5 feedback:nil success:success fail:fail complete:nil];
}
+ (NSString*)postJSONWithUrl:(NSString*)url data:(id)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common postJSONWithUrl:url data:data timeout:5 feedback:feedback success:success fail:fail complete:nil];
}
+ (NSString*)postJSONWithUrl:(NSString*)url data:(id)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail complete:(void (^)(NSMutableDictionary *json))complete{
	return [Common postApiWithUrl:url data:data type:@"json" timeout:timeout feedback:feedback success:success fail:fail complete:complete];
}
+ (NSString*)postApiWithUrl:(NSString*)url data:(id)data type:(NSString*)type timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail complete:(void (^)(NSMutableDictionary *json))complete{
#ifdef DEBUG
	NSLog(@"%@\n%@", url, data);
#endif
	if (![Global isNetwork:![feedback isEqualToString:@"nomsg"]]) {
		NSMutableDictionary *json = MSDICTIONARY(@0, API_KEY_MSGTYPE, @"NO NETWORK", API_KEY_MSG);
		dispatch_async(dispatch_get_main_queue(), ^{
			if (fail) fail(json);
			if (complete) complete(json);
		});
		[ProgressHUD dismiss];
		return url;
	}
	__block NSString *string = feedback;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[Global post:url data:data type:type timeout:timeout completion:^(NSString *result) {
			NSMutableDictionary *json = (NSMutableDictionary*)result;
			if ([result isKindOfClass:[NSString class]]) json = result.formatJson;
#ifdef DEBUG
			NSLog(@"\n%@", json.descriptionASCII);
#endif
			if (json.isDictionary) {
				if ([json[API_KEY_ERROR] isset] && [json[API_KEY_MSGTYPE] isset]) {
					if ([json[API_KEY_ERROR] intValue]==API_KEY_ERROR_CODE) {
						if (string.length) {
							if ([string isEqualToString:@"nomsg"]) string = @"提交成功";
							if (![string isEqualToString:@"always"]) {
								if ([string isEqualToString:@"msg"] && [json[API_KEY_MSG] isset]) {
									[ProgressHUD showSuccess:json[API_KEY_MSG]];
								} else {
									[ProgressHUD showSuccess:string];
								}
							}
						} else {
							[ProgressHUD dismiss];
						}
						if (success) success(json);
						[Common successExecute:json];
					} else {
						if (![string isEqualToString:@"nomsg"]) {
							if ( !([json[API_KEY_MSGTYPE]intValue]==-100 && NSClassFromString(@"login")) ) {
								if ([json[API_KEY_MSG] isset]) {
									[ProgressHUD showError:json[API_KEY_MSG]];
								} else {
									[ProgressHUD showError:@"提交失败"];
								}
							}
						} else {
							[ProgressHUD dismiss];
						}
						if (fail) fail(json);
						[Common errorExecute:json];
					}
				} else {
					if (![string isEqualToString:@"always"]) [ProgressHUD dismiss];
					if (success) success(json);
				}
			} else {
				NSString *description = STRINGFORMAT(@"\n%@\n%@", url, result);
				NSLog(@"%@", description);
				if ([API_ERROR_SENDEMAIL length]) {
					UIImage *attachment = [Global imageWithView:KEYWINDOW frame:[UIScreen mainScreen].bounds];
					attachment = [attachment fitToSize:CGSizeMake(640, 0)];
					[SKPSMTPMessage sendEmailTo:API_ERROR_SENDEMAIL title:STRINGFORMAT(@"%@(APP)接口出错", APP_NAME) content:description attachment:attachment.data];
				}
				NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
				if ([result indexOf:@"Undefined index: member in"]!=NSNotFound) [json setObject:@(-100) forKey:API_KEY_MSGTYPE];
				if (fail) fail(json);
				[Common errorExecute:json];
			}
			if (complete) complete(json);
		} fail:^(NSString *description, NSInteger code) {
			NSMutableDictionary *json = MSDICTIONARY(@0, API_KEY_MSGTYPE, @"DATA ERROR", API_KEY_MSG);
			if (fail) fail(json);
			if (complete) complete(json);
			[Common errorExecute:json];
		}];
	});
	return url;
}

+ (NSString*)uploadApiWithParams:(NSDictionary*)params data:(NSDictionary*)data success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [self uploadApiWithParams:params data:data feedback:@"提交成功" success:success fail:fail];
}
+ (NSString*)uploadApiWithParams:(NSDictionary*)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common uploadApiWithFile:API_FILE params:params data:data feedback:feedback success:success fail:fail];
}
+ (NSString*)uploadApiWithParams:(NSDictionary*)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common uploadApiWithFile:API_FILE params:params data:data timeout:timeout feedback:@"nomsg" success:success fail:fail complete:nil];
}
+ (NSString*)uploadApiWithParams:(NSDictionary*)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common uploadApiWithFile:API_FILE params:params data:data timeout:timeout feedback:feedback success:success fail:fail complete:nil];
}
+ (NSString*)uploadApiWithFile:(NSString*)file params:(NSDictionary*)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail{
	return [Common uploadApiWithFile:API_FILE params:params data:data timeout:20 feedback:feedback success:success fail:fail complete:nil];
}
+ (NSString*)uploadApiWithFile:(NSString*)file params:(NSDictionary*)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail complete:(void (^)(NSMutableDictionary *json))complete{
	NSString *url = [Common apiUrlWithFile:file params:params];
	return [Common uploadApiWithUrl:url data:data timeout:timeout feedback:feedback success:success fail:fail complete:complete];
}
+ (NSString*)uploadApiWithUrl:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail complete:(void (^)(NSMutableDictionary *json))complete{
#ifdef DEBUG
	NSLog(@"%@\n%@", url, data);
#endif
	if (![Global isNetwork:![feedback isEqualToString:@"nomsg"]]) {
		NSMutableDictionary *json = MSDICTIONARY(@0, API_KEY_MSGTYPE, @"NO NETWORK", API_KEY_MSG);
		dispatch_async(dispatch_get_main_queue(), ^{
			if (fail) fail(json);
			if (complete) complete(json);
		});
		[ProgressHUD dismiss];
		return url;
	}
	__block NSString *string = feedback;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[Global upload:url data:data timeout:timeout completion:^(NSString *result) {
			NSMutableDictionary *json = (NSMutableDictionary*)result;
			if ([result isKindOfClass:[NSString class]]) json = result.formatJson;
#ifdef DEBUG
			NSLog(@"\n%@", json.descriptionASCII);
#endif
			if (json.isDictionary) {
				if ([json[API_KEY_ERROR] isset] && [json[API_KEY_MSGTYPE] isset]) {
					if ([json[API_KEY_ERROR] intValue]==API_KEY_ERROR_CODE) {
						if (string.length) {
							if ([string isEqualToString:@"nomsg"]) string = @"提交成功";
							if (![string isEqualToString:@"always"]) {
								if ([string isEqualToString:@"msg"] && [json[API_KEY_MSG] isset]) {
									[ProgressHUD showSuccess:json[API_KEY_MSG]];
								} else {
									[ProgressHUD showSuccess:string];
								}
							}
						} else {
							[ProgressHUD dismiss];
						}
						if (success) success(json);
						[Common successExecute:json];
					} else {
						if (![string isEqualToString:@"nomsg"]) {
							if ( !([json[API_KEY_MSGTYPE]intValue]==-100 && NSClassFromString(@"login")) ) {
								if ([json[API_KEY_MSG] isset]) {
									[ProgressHUD showError:json[API_KEY_MSG]];
								} else {
									[ProgressHUD showError:@"提交失败"];
								}
							}
						} else {
							[ProgressHUD dismiss];
						}
						if (fail) fail(json);
						[Common errorExecute:json];
					}
				} else {
					if (![string isEqualToString:@"always"]) [ProgressHUD dismiss];
					if (success) success(json);
				}
			} else {
				NSString *description = STRINGFORMAT(@"\n%@\n%@", url, result);
				NSLog(@"%@", description);
				if ([API_ERROR_SENDEMAIL length]) {
					UIImage *attachment = [Global imageWithView:KEYWINDOW frame:[UIScreen mainScreen].bounds];
					attachment = [attachment fitToSize:CGSizeMake(640, 0)];
					[SKPSMTPMessage sendEmailTo:API_ERROR_SENDEMAIL title:STRINGFORMAT(@"%@(APP)接口出错", APP_NAME) content:description attachment:attachment.data];
				}
				NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
				if ([result indexOf:@"Undefined index: member in"]!=NSNotFound) [json setObject:@(-100) forKey:API_KEY_MSGTYPE];
				if (fail) fail(json);
				[Common errorExecute:json];
			}
			if (complete) complete(json);
		} fail:^(NSString *description, NSInteger code) {
			NSMutableDictionary *json = MSDICTIONARY(@0, API_KEY_MSGTYPE, @"DATA ERROR", API_KEY_MSG);
			if (fail) fail(json);
			if (complete) complete(json);
			[Common errorExecute:json];
		}];
	});
	return url;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
+ (void)successExecute:(NSDictionary *)json{
	if (!json.isDictionary) return;
	AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	SEL selector = NSSelectorFromString(@"CommonSuccessExecute:");
	if ([appDelegate respondsToSelector:selector]) {
		[appDelegate performSelector:selector withObject:json];
	}
	//	if ([json[@"notify"] isset]) {
	//		AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	//		int notify = [json[@"notify"]intValue];
	//		[@"notify" setUserDefaultsWithData:@(notify)];
	//		KKTabBarItem *item = appDelegate.tabBarController.tabBar.items[4];
	//		item.badgeValue = notify>0 ? STRINGFORMAT(@"%d", notify) : @"";
	//	}
}

+ (void)errorExecute:(NSDictionary *)json{
	if (!json.isDictionary) return;
	AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	SEL selector = NSSelectorFromString(@"CommonErrorExecute:");
	if ([appDelegate respondsToSelector:selector]) {
		[appDelegate performSelector:selector withObject:json];
	}
	if ([json[API_KEY_MSGTYPE]intValue]==-100) {
		if (![Common isAuditKey]) {
			if (NSClassFromString(@"login")) {
				id e = [[NSClassFromString(@"login") alloc]init];
				KKNavigationController *nav = [[KKNavigationController alloc]initWithRootViewController:e];
				[APPCurrentController presentViewController:nav animated:YES completion:nil];
			}
		} else {
			if (NSClassFromString(@"loginAudit")) {
				id e = [[NSClassFromString(@"loginAudit") alloc]init];
				KKNavigationController *nav = [[KKNavigationController alloc]initWithRootViewController:e];
				[APPCurrentController presentViewController:nav animated:YES completion:nil];
			}
		}
	}
}
#pragma clang diagnostic pop

//查询物流情况
//快递鸟
//www.kdniao.com/YundanChaxunAPI.aspx
#define KDN_EN @[@"EMS", @"SF", @"STO", @"YTO", @"YD", @"HTKY", @"HHTT", @"ZTO", @"ZJS", @"YZPY", @"QFKD", @"GTO", @"JD", @"LB", @"DBL", @"RFD", @"QRT", @"JJKY", @"DHL"]
#define KDN_CN @[@"EMS快递", @"顺丰快递", @"申通快递", @"圆通快递", @"韵达快递", @"百世汇通", @"天天快递", @"中通快递", @"宅急送快递", @"中国邮政", @"全峰快递", @"国通快递", @"京东快递", @"龙邦快递", @"德邦物流", @"如风达快递", @"全日通快递", @"佳吉快运", @"DHL快递"]
+ (void)getKuaidiWithSpellName:(NSString*)spellName mailNo:(NSString*)mailNo success:(void (^)(NSArray *data, NSMutableDictionary *json))success fail:(void (^)(NSString *msg))fail{
	NSInteger index = NSNotFound;
	NSArray *matches = [spellName preg_match:@"[\\u4e00-\\u9fa5]+"];
	if (matches.isArray) {
		NSString *companyName = [[[[spellName replace:@"快递" to:@""] replace:@"物流" to:@""] replace:@"快运" to:@""] replace:@"速递" to:@""];
		companyName = [companyName replace:@"速运" to:@""];
		index = [companyName inArraySearch:KDN_CN];
	} else {
		index = [spellName.uppercaseString inArray:KDN_EN];
	}
	if (index == NSNotFound) {
		NSLog(@"没有该物流公司代号: %@", spellName);
		if (fail) fail([NSString stringWithFormat:@"没有该物流公司代号: %@", spellName]);
		return;
	}
	NSString *companyName = KDN_EN[index];
	NSString *EBusinessID = @"1256920"; //电商ID
	NSString *AppKey = @"e7bbede8-6d12-439f-9ebf-d835613b638f"; //电商加密私钥
	NSString *requestData = STRINGFORMAT(@"{\"OrderCode\":\"\", \"ShipperCode\":\"%@\", \"LogisticCode\":\"%@\"}", companyName, mailNo);
	NSString *dataSign = STRINGFORMAT(@"%@%@", requestData, AppKey);
	dataSign = dataSign.md5.base64.URLEncode;
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setObject:EBusinessID forKey:@"EBusinessID"];
	[postData setObject:@"1002" forKey:@"RequestType"];
	[postData setObject:requestData.URLEncode forKey:@"RequestData"];
	[postData setObject:@"2" forKey:@"DataType"];
	[postData setObject:dataSign forKey:@"DataSign"];
	[Common postApiWithUrl:@"http://api.kdniao.com/Ebusiness/EbusinessOrderHandle.aspx" data:postData timeout:5 feedback:@"nomsg" success:^(NSMutableDictionary *json) {
		if ([json[@"Success"]intValue]==1) {
			if (success) {
				//json[@"State"] 2:在途中, 3:签收, 4:问题件
				NSString *result = json.jsonString;
				result = [result replace:@"\"AcceptTime\":" to:@"\"time\":"];
				result = [result replace:@"\"AcceptStation\":" to:@"\"context\":"];
				result = [result replace:@"\"Traces\":" to:@"\"data\":"];
				json = [NSMutableDictionary dictionaryWithDictionary:result.formatJson];
				NSArray *data = json[@"data"];
				if (data.isArray) {
					success(data, json);
				} else {
					NSLog(@"KDNIAO NO DATA, CHANGE API");
					[Common getKD100WithSpellName:spellName mailNo:mailNo success:success fail:fail];
				}
			}
		} else {
			NSLog(@"%@", json[@"Reason"]);
			if (fail) fail(json[@"Reason"]);
		}
	} fail:^(NSMutableDictionary *json) {
		NSLog(@"快递鸟接口发生异常");
		if (fail) fail(@"快递鸟接口发生异常");
	} complete:nil];
}

//快递100
#define KD100_EN @[@"ems", @"shunfeng", @"shentong", @"yuantong", @"yunda", @"huitongkuaidi", @"tiantian", @"zhongtong", @"zhaijisong", @"youzhengguonei", @"quanfengkuaidi", @"guotongkuaidi", @"longbanwuliu", @"debangwuliu", @"rufengda", @"quanritongkuaidi", @"jiajiwuliu", @"dhl"]
#define KD100_CN @[@"EMS快递", @"顺丰快递", @"申通快递", @"圆通快递", @"韵达快递", @"汇通快递", @"天天快递", @"中通快递", @"宅急送快递", @"中国邮政", @"全峰快递", @"国通快递", @"龙邦快递", @"德邦物流", @"如风达快递", @"全日通快递", @"佳吉快运", @"DHL快递"]
+ (void)getKD100WithSpellName:(NSString*)spellName mailNo:(NSString*)mailNo success:(void (^)(NSArray *data, NSMutableDictionary *json))success fail:(void (^)(NSString *msg))fail{
	NSInteger index = NSNotFound;
	NSArray *matches = [spellName preg_match:@"[\\u4e00-\\u9fa5]+"];
	if (matches.isArray) {
		NSString *companyName = [[[[spellName replace:@"快递" to:@""] replace:@"物流" to:@""] replace:@"快运" to:@""] replace:@"速递" to:@""];
		index = [companyName inArraySearch:KD100_CN];
	} else {
		index = [spellName inArray:KD100_EN];
	}
	if (index == NSNotFound) {
		NSLog(@"没有该物流公司代号: %@", spellName);
		if (fail) fail([NSString stringWithFormat:@"没有该物流公司代号: %@", spellName]);
		return;
	}
	NSString *companyName = KD100_EN[index];
	NSString *url = [NSString stringWithFormat:@"http://www.kuaidi100.com/query?type=%@&postid=%@", companyName, mailNo];
	[Common getApiWithUrl:url success:^(NSMutableDictionary *json){
		if ([json[@"status"]intValue]==200) {
			if (success) {
				NSArray *data = json[@"data"];
				if (data.isArray) {
					data = data.reverse;
					success(data, json);
				} else {
					NSLog(@"KD100 NO DATA, CHANGE API");
					[Common getICKDWithSpellName:spellName mailNo:mailNo success:success fail:fail];
				}
			}
		} else {
			NSLog(@"%@\n%@", url, json[@"message"]);
			if (fail) fail(json[@"message"]);
		}
	} fail:^(NSMutableDictionary *json) {
		NSLog(@"%@\n%@", url, @"快递100接口错误");
		if (fail) fail(@"快递100接口错误");
	}];
}

//爱查快递
#define ICKD_EN @[@"ems", @"shunfeng", @"shentong", @"yuantong", @"yunda", @"huitong", @"tiantian", @"zhongtong", @"zhaijisong", @"pingyou", @"quanfeng", @"guotong", @"jingdong", @"ririshun", @"longbang", @"debang", @"rufeng", @"quanritong", @"jiaji", @"dhl"]
#define ICKD_CN @[@"EMS快递", @"顺丰快递", @"申通快递", @"圆通快递", @"韵达快递", @"汇通快递", @"天天快递", @"中通快递", @"宅急送快递", @"中国邮政", @"全峰快递", @"国通快递", @"京东快递", @"日日顺物流", @"龙邦快递", @"德邦物流", @"如风达快递", @"全日通快递", @"佳吉快运", @"DHL快递"]
+ (void)getICKDWithSpellName:(NSString*)spellName mailNo:(NSString*)mailNo success:(void (^)(NSArray *data, NSMutableDictionary *json))success fail:(void (^)(NSString *msg))fail{
	NSInteger index = NSNotFound;
	NSArray *matches = [spellName preg_match:@"[\\u4e00-\\u9fa5]+"];
	if (matches.isArray) {
		NSString *companyName = [[[[spellName replace:@"快递" to:@""] replace:@"物流" to:@""] replace:@"快运" to:@""] replace:@"速递" to:@""];
		companyName = [companyName replace:@"速运" to:@""];
		index = [companyName inArraySearch:ICKD_CN];
	} else {
		index = [spellName inArray:ICKD_EN];
	}
	if (index == NSNotFound) {
		NSLog(@"没有该物流公司代号: %@", spellName);
		if (fail) fail([NSString stringWithFormat:@"没有该物流公司代号: %@", spellName]);
		return;
	}
	NSString *companyName = ICKD_EN[index];
	NSString *url = [NSString stringWithFormat:@"http://biz.trace.ickd.cn/%@/%@?callback=callback", companyName, mailNo];
	[Common getApiWithUrl:url type:nil success:^(NSMutableDictionary *json){
		NSString *data = [(NSString*)json replace:@"/**/callback&&callback(" to:@""];
		NSString *result = [data preg_replace:@"<span[^>]+?>" with:@""];
		result = [result replace:@"<\\/span>" to:@""];
		result = [result substringToIndex:result.length-1];
		json = result.formatJson;
		if (json.isDictionary) {
			if ([json[@"errCode"]intValue]==0) {
				if (success) {
					NSArray *data = json[@"data"];
					if (data.isArray) {
						success(data, json);
					} else {
						NSLog(@"ICKD NO DATA");
					}
				}
			} else {
				NSLog(@"%@\n%@", url, json[@"message"]);
				if (fail) fail(json[@"message"]);
			}
		} else {
			NSLog(@"%@\n%@", url, data);
			if (fail) fail(@"爱查快递接口错误");
		}
	} fail:^(NSMutableDictionary *json) {
		NSLog(@"%@\n%@", url, @"爱查快递接口错误");
		if (fail) fail(@"爱查快递接口错误");
	}];
}

+ (void)getAuditKey:(NSString*)key completion:(void (^)(NSDictionary *configs))completion{
	[@"auditKey" setUserDefaultsWithData:key];
	[@"configs" deleteUserDefaults];
	[Common getApiWithParams:@{@"app":@"other", @"act":@"c"} feedback:@"nomsg" success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		NSDictionary *configs = json[@"data"];
		[@"configs" setUserDefaultsWithData:configs];
		if (completion) completion(configs);
	} fail:^(NSMutableDictionary *json) {
		NSDictionary *configs = @{
								  @"WX_APPID":WX_APPID,
								  @"WX_MCHID":WX_MCHID,
								  @"WX_APPSECRET":WX_APPSECRET,
								  @"WX_PARTNERID":WX_PARTNERID
								  };
		if (completion) completion(configs);
	}];
}

+ (BOOL)isAuditKey{
	NSDictionary *configs = [@"configs" getUserDefaultsDictionary];
	NSString *auditKey = [@"auditKey" getUserDefaultsString];
	if (!auditKey.length) auditKey = @"on1216";
	return !( !configs.isDictionary || ![configs[auditKey] isset] || ([configs[auditKey] isset] && [configs[auditKey]intValue]==0) );
}

@end
