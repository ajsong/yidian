//
//  ShareHelper.m
//
//  Created by ajsong on 15/4/14.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>

#define NO_CLINET_PASS 1 //没有分享客户端也继续显示
#define SHOW_QRCODE 1 //显示二维码选项

@implementation ShareHelperModel
@end

@interface ShareHelper ()<MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,WXApiDelegate>

@end

@implementation ShareHelper

+ (ShareHelper*)sharedHelper{
	static dispatch_once_t once = 0;
	static ShareHelper *shareView;
	dispatch_once(&once, ^{ shareView = [[ShareHelper alloc] init]; });
	return shareView;
}

- (id)init{
	self = [super init];
	if (self) {
		self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
		//self.backgroundColor = WHITE;
		_types = @[@"wxsession", @"wxtimeline", @"sina", @"qzone"];
	}
	return self;
}

- (void)show{
	if (!_title.length || !_url.length) {
		[ProgressHUD showError:@"缺少需分享的标题、网址"];
		return;
	}
	if (!_content.length) _content = [_title copy];
	if (!_image) _image = APPICON_60;
	
	NSInteger tag = 29865363;
	[[self viewWithTag:tag] removeFromSuperview];
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
	view.tag = tag;
	[self addSubview:view];
	
	NSArray *nameArray = SHARE_NAME_ARRAY;
	NSArray *typeArray = SHARE_TYPE_ARRAY;
	
	UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 10*SCREEN_SCALE, SCREEN_WIDTH, 14*SCREEN_SCALE)];
	title.text = @"分享到";
	title.textColor = COLOR999;
	title.textAlignment = NSTextAlignmentCenter;
	title.font = FONT(12);
	title.backgroundColor = CLEAR;
	[view addSubview:title];
	
	NSMutableArray *array = [[NSMutableArray alloc]init];
	if (_types.isArray) {
		for (NSString *type in _types) {
			NSInteger tag = [typeArray indexOfObject:type];
			switch (tag) {
				case 0:{
					if ([ShareHelper isSinaInstalled] && [SINA_APPKEY length]) [array addObject:type];
					break;
				}
				case 1:
				case 2:
				case 3:{
					if ([ShareHelper isWXAppInstalled] && [WX_APPID length]) [array addObject:type];
					break;
				}
				case 4:
				case 5:
				case 6:{
					if ([ShareHelper isQQInstalled] && [QQ_APPID length]) [array addObject:type];
					break;
				}
				case 7:
				case 8:
				case 9:{
					[array addObject:type];
					break;
				}
				case 10:{
					if (SHOW_QRCODE) [array addObject:type];
					break;
				}
			}
		}
	} else {
		if ([ShareHelper isSinaInstalled] && [SINA_APPKEY length]) {
			[array addObject:typeArray[0]];
		}
		if ([ShareHelper isWXAppInstalled] && [WX_APPID length]) {
			[array addObject:typeArray[1]];
			[array addObject:typeArray[2]];
			[array addObject:typeArray[3]];
		}
		if ([ShareHelper isQQInstalled] && [QQ_APPID length]) {
			[array addObject:typeArray[4]];
			[array addObject:typeArray[5]];
			[array addObject:typeArray[6]];
		}
		[array addObject:typeArray[7]];
		[array addObject:typeArray[8]];
		[array addObject:typeArray[9]];
		if (SHOW_QRCODE) {
			[array addObject:typeArray[10]];
		}
	}
	if (!array.count && !NO_CLINET_PASS) {
		[ProgressHUD showError:@"设备没有可分享的客户端"];
		return;
	}
	
	CGFloat blank = 0;
	CGFloat width = 55*SCREEN_SCALE;
	
	if (array.count<=3) {
		blank = (SCREEN_WIDTH - array.count*width) / (array.count+1);
	} else {
		blank = (SCREEN_WIDTH - 4*width) / (4+1)*SCREEN_SCALE;
	}
	UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, title.bottom+10*SCREEN_SCALE, SCREEN_WIDTH, width+(5+12)*SCREEN_SCALE)];
	[view addSubview:scrollView];
	for (int i=0; i<array.count; i++) {
		UIView *item = [[UIView alloc]initWithFrame:CGRectMake(blank+(width+blank)*i, 0, width, scrollView.height)];
		item.element[@"type"] = array[i];
		[scrollView addSubview:item];
		
		UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, width)];
		image.image = IMG(@"share_%@", array[i]);
		[item addSubview:image];
		
		UILabel *text = [[UILabel alloc]initWithFrame:CGRectMake(0, image.bottom+5*SCREEN_SCALE, width, 12*SCREEN_SCALE)];
		text.text = nameArray[[typeArray indexOfObject:array[i]]];
		text.textColor = COLOR666;
		text.textAlignment = NSTextAlignmentCenter;
		text.font = FONT(10);
		text.backgroundColor = CLEAR;
		[item addSubview:text];
		
		[item click:^(UIView *sender, UIGestureRecognizer *recognizer) {
			[self selectShare:sender];
		}];
	}
	if (array.count>3) scrollView.contentSize = CGSizeMake(scrollView.lastSubview.right+blank, scrollView.height);
	CGFloat bottom = scrollView.bottom + 10*SCREEN_SCALE;
	
	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, bottom, SCREEN_WIDTH-10*2*SCREEN_SCALE, 40*SCREEN_SCALE)];
	btn.titleLabel.font = FONT(14);
	btn.backgroundColor = [UIColor clearColor];
	[btn setTitle:@"取消" forState:UIControlStateNormal];
	[btn setTitleColor:COLOR666 forState:UIControlStateNormal];
	btn.layer.borderColor = COLOR666.CGColor;
	btn.layer.borderWidth = 0.5*SCREEN_SCALE;
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 3*SCREEN_SCALE;
	[btn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:btn];
	
	view.height = btn.bottom + 10*SCREEN_SCALE;
	self.height = view.bottom;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			NSInteger tag = 785623753;
			[[self viewWithTag:tag] removeFromSuperview];
			UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:self.bounds];
			toolbar.barStyle = UIBarStyleDefault;
			toolbar.tag = tag;
			[self insertSubview:toolbar atIndex:0];
		});
	});
	
	[APPCurrentController presentActionView:self];
}

- (void)show:(void (^)())completion{
	_completion = completion;
	[self show];
}

- (void)close{
	[APPCurrentController dismissActionView];
}

- (void)close:(void (^)())completion{
	[APPCurrentController dismissActionView:completion];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"\ntitle: %@\ncontent: %@\nurl: %@", _title, _content, _url];
}

- (void)selectShare:(UIView*)sender{
	if ([sender.element[@"type"] isEqualToString:@"sms"]) {
		Class class = (NSClassFromString(@"MFMessageComposeViewController"));
		if (!class || ![class canSendSubject]) {
			[ProgressHUD showError:@"系统不支持应用内发短信"];
			return;
		}
		MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
		picker.messageComposeDelegate = self;
		picker.subject = _title;
		picker.body = STRINGFORMAT(@"%@\n\n%@", _content, _url);
		NSData *imageData;
		NSString *suffix;
		if ([_image isKindOfClass:[UIImage class]]) {
			UIImage *image = (UIImage*)_image;
			imageData = image.imageToData;
			suffix = image.imageSuffix;
		} else {
			imageData = (NSData*)_image;
			suffix = imageData.imageSuffix;
		}
		[picker addAttachmentData:imageData typeIdentifier:@"public.data" filename:STRINGFORMAT(@"attachment.%@", suffix)];
		[APPCurrentController presentViewController:picker animated:YES completion:nil];
		[self close];
		return;
	}
	if ([sender.element[@"type"] isEqualToString:@"email"]) {
		Class class = (NSClassFromString(@"MFMailComposeViewController"));
		if (!class || ![class canSendMail]) {
			[ProgressHUD showError:@"系统不支持应用内发邮件"];
			return;
		}
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		picker.subject = _title;
		NSData *imageData;
		NSString *mimeType;
		NSString *suffix;
		if ([_image isKindOfClass:[UIImage class]]) {
			UIImage *image = (UIImage*)_image;
			imageData = image.imageToData;
			mimeType = image.imageMimeType;
			suffix = image.imageSuffix;
		} else {
			imageData = (NSData*)_image;
			mimeType = imageData.imageMimeType;
			suffix = imageData.imageSuffix;
		}
		[picker addAttachmentData:imageData mimeType:mimeType fileName:STRINGFORMAT(@"attachment.%@", suffix)];
		NSString *emailBody = [NSString stringWithFormat:@"<h3 style=\"margin:0;\">%@</h3><font color=gray>%@</font><br /><br /><a href=\"%@\" target=\"_blank\">前往%@查看</a>", _title, _content, _url, APP_NAME];
		[picker setMessageBody:emailBody isHTML:YES];
		[APPCurrentController presentViewController:picker animated:YES completion:nil];
		[self close];
		return;
	}
	if ([sender.element[@"type"] isEqualToString:@"link"]) {
		[Global copyString:[NSString stringWithFormat:@"%@\n%@", _title, _url]];
		[ProgressHUD showSuccess:@"已复制链接"];
		[self close];
		return;
	}
	if (SHOW_QRCODE && [sender.element[@"type"] isEqualToString:@"qrcode"]) {
		UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 240*SCREEN_SCALE, 0)];
		view.backgroundColor = [UIColor whiteColor];
		view.layer.masksToBounds = YES;
		view.layer.cornerRadius = 5*SCREEN_SCALE;
		
		UIImageView *qrcode = [[UIImageView alloc]initWithFrame:CGRectMake((view.width-200*SCREEN_SCALE)/2, 25*SCREEN_SCALE, 200*SCREEN_SCALE, 200*SCREEN_SCALE)];
		qrcode.image = [QRCodeGenerator createQRCode:[NSString stringWithFormat:@"%@\n%@", _title, _url] size:qrcode.width];
		[qrcode addLongPressGestureRecognizerWithTarget:self action:@selector(saveQrcode:)];
		[view addSubview:qrcode];
		
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, qrcode.bottom, view.width, 48*SCREEN_SCALE)];
		label.text = @"（长按二维码保存到相册）";
		label.textColor = COLOR999;
		label.textAlignment = NSTextAlignmentCenter;
		label.font = FONT(12);
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		
		UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(qrcode.left, label.bottom, qrcode.width, 38*SCREEN_SCALE)];
		btn.titleLabel.font = FONT(14);
		btn.backgroundColor = [UIColor clearColor];
		[btn setTitle:@"取消" forState:UIControlStateNormal];
		[btn setTitleColor:COLOR666 forState:UIControlStateNormal];
		btn.layer.borderColor = COLOR666.CGColor;
		btn.layer.borderWidth = 0.5*SCREEN_SCALE;
		btn.layer.masksToBounds = YES;
		btn.layer.cornerRadius = 3*SCREEN_SCALE;
		[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
			[APPCurrentController dismissAlertView:DYAlertViewDown];
		}];
		[view addSubview:btn];
		
		view.height = btn.bottom + 20*SCREEN_SCALE;
		
		[self close:^{
			[APPCurrentController presentAlertView:view animation:DYAlertViewDown];
		}];
		return;
	}
	[self close];
	
	NSArray *array = SHARE_TYPE_ARRAY;
	NSString *type = sender.element[@"type"];
	NSString *title = _title;
	NSString *content = _content;
	NSString *url = _url;
	id image = _image;
	if (_models.isArray) {
		for (ShareHelperModel *model in _models) {
			if ([array[model.type] isEqualToString:type]) {
				if (model.title.length) title = model.title;
				if (model.content.length) content = model.content;
				if (model.url.length) url = model.url;
				if (model.image) image = model.image;
				break;
			}
		}
	}
	[ShareHelper shareWithType:type url:url title:title content:content image:image completion:_completion];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
	switch (result) {
		case MessageComposeResultSent:
			[ProgressHUD showError:@"发送成功"];
			break;
		case MessageComposeResultFailed:
			[ProgressHUD showError:@"短信发送失败"];
			break;
		default:
			break;
	}
	[controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
	switch (result) {
		case MFMailComposeResultSent:
			[ProgressHUD showError:@"发送成功"];
			break;
		case MFMailComposeResultFailed:
			[ProgressHUD showError:@"邮件发送失败"];
			break;
		default:
			break;
	}
	[controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveQrcode:(UIGestureRecognizer*)sender{
	if (sender.state == UIGestureRecognizerStateBegan) {
		UIImageView *qrcode = (UIImageView*)sender.view;
		UIImageWriteToSavedPhotosAlbum(qrcode.image, nil, nil, nil);
		[ProgressHUD showSuccess:@"成功保存"];
	}
}

+ (void)shareWithUrl:(NSString*)url title:(NSString*)title content:(NSString*)content image:(id)image completion:(void (^)(ShareHelperResult result))completion{
	ShareHelper *shareView = [[ShareHelper alloc]init];
	shareView.title = title;
	shareView.content = content;
	shareView.url = url;
	shareView.image = image;
	shareView.completion = completion;
	[shareView show];
}

+ (void)shareWithType:(NSString*)type url:(NSString*)url title:(NSString*)title content:(NSString*)content image:(id)image completion:(void (^)(ShareHelperResult result))completion{
	if (!title.length || !url.length) {
		[ProgressHUD showError:@"缺少需分享的标题、网址"];
		return;
	}
	NSInteger tag = [SHARE_TYPE_ARRAY indexOfObject:type];
	BOOL hasClinet = NO;
	switch (tag) {
		case 0:hasClinet = [ShareHelper isSinaInstalled];break;
		case 1:
		case 2:
		case 3:hasClinet = [ShareHelper isWXAppInstalled];break;
		case 4:
		case 5:
		case 6:hasClinet = [ShareHelper isQQInstalled];break;
		default:hasClinet = YES;break;
	}
	if (!hasClinet && !NO_CLINET_PASS) {
		[ProgressHUD showError:@"设备没有可分享的客户端"];
		return;
	}
	[ShareHelper registerAppWithType:tag];
	[ProgressHUD show:nil];
	[ProgressHUD dismiss:3];
	switch (tag) {
		case 0:{
			title = [NSString stringWithFormat:@"%@ %@", title, url];
			break;
		}
		case 1:{
			[UMSocialData defaultData].extConfig.wechatSessionData.title = title;
			[UMSocialData defaultData].extConfig.wechatSessionData.shareText = content;
			[UMSocialData defaultData].extConfig.wechatSessionData.url = url;
			break;
		}
		case 2:{
			[UMSocialData defaultData].extConfig.wechatTimelineData.title = title;
			[UMSocialData defaultData].extConfig.wechatTimelineData.shareText = content;
			[UMSocialData defaultData].extConfig.wechatTimelineData.url = url;
			break;
		}
		case 3:{
			[UMSocialData defaultData].extConfig.wechatFavoriteData.title = title;
			[UMSocialData defaultData].extConfig.wechatFavoriteData.shareText = content;
			[UMSocialData defaultData].extConfig.wechatFavoriteData.url = url;
			break;
		}
		case 4:{
			//分享给QQ好友只会显示一条链接
			[UMSocialData defaultData].extConfig.qqData.title = title;
			[UMSocialData defaultData].extConfig.qqData.shareText = content;
			[UMSocialData defaultData].extConfig.qqData.url = url;
			break;
		}
		case 5:{
			[UMSocialData defaultData].extConfig.qzoneData.title = title;
			[UMSocialData defaultData].extConfig.qzoneData.shareText = content;
			[UMSocialData defaultData].extConfig.qzoneData.url = url;
			break;
		}
		case 9:{
			UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
			pasteBoard.string = [NSString stringWithFormat:@"%@\n%@", title, url];
			[ProgressHUD showSuccess:@"已复制"];
			return;
			break;
		}
		default:{
			return;
			break;
		}
	}
	void (^postShare)(NSArray *type, NSString *title, id image, void (^completion)(ShareHelperResult result)) = ^(NSArray *type, NSString *title, id image, void (^completion)(ShareHelperResult result)){
		[UMSocialConfig setFinishToastIsHidden:YES position:UMSocialiToastPositionCenter];
		[[UMSocialDataService defaultDataService] postSNSWithTypes:type content:title image:image location:nil urlResource:nil presentedController:APPCurrentController completion:^(UMSocialResponseEntity *shareResponse){
			if (shareResponse.responseCode == UMSResponseCodeSuccess) {
				if (completion) {
					completion(ShareHelperResultSuccess);
				} else {
					[ProgressHUD showSuccess:@"分享成功"];
				}
			} else {
				NSLog(@"Share Failed: %@", shareResponse);
				switch (tag) {
					case 0:[ShareHelper logoutWithSina];break;
					case 1:
					case 2:
					case 3:[ShareHelper logoutWithWechat];break;
					case 4:
					case 5:[ShareHelper logoutWithQQ];break;
				}
				if (completion) {
					completion(ShareHelperResultFail);
				} else {
					if (shareResponse.responseCode == UMSResponseCodeFaild) [ProgressHUD showError:@"分享失败"];
				}
			}
		}];
	};
	if (!image) image = APPICON_60;
	if ([image isKindOfClass:[NSString class]]) {
		[image cacheImageAndCompletion:^(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache) {
			postShare(@[type], title, image, completion);
		}];
	} else {
		postShare(@[type], title, image, completion);
	}
}

+ (void)shareWithSchemeUrl:(NSString*)schemeUrl completion:(void (^)(ShareHelperResult result))completion{
	[ShareHelper shareWithSchemeUrl:schemeUrl assignUrl:nil completion:completion];
}

+ (void)shareWithSchemeUrl:(NSString*)schemeUrl assignUrl:(NSString*)assignUrl completion:(void (^)(ShareHelperResult result))completion{
	if (![schemeUrl hasPrefix:[NSString stringWithFormat:@"%@://share?", APP_SCHEME]]) return;
	NSDictionary *params = schemeUrl.params;
	NSString *title = params[@"title"];
	NSString *url = params[@"url"];
	NSString *content = params[@"content"];
	NSString *image = params[@"image"];
	NSString *type = params[@"type"];
	if (assignUrl.length) url = assignUrl;
	if (!type.length) type = @"2";
	if (!content.length) content = title;
	if (!title.length || !url.length) {
		[ProgressHUD showError:@"缺少需分享的标题、网址"];
		return;
	}
	BOOL hasClinet = NO;
	switch (type.integerValue) {
		case ShareHelperTypeSina:
			hasClinet = [ShareHelper isSinaInstalled];break;
		case ShareHelperTypeWXSession:
		case ShareHelperTypeWXTimeLine:
		case ShareHelperTypeWXFavorite:
			hasClinet = [ShareHelper isWXAppInstalled];break;
		case ShareHelperTypeQQ:
		case ShareHelperTypeQZone:
		case ShareHelperTypeTencent:
			hasClinet = [ShareHelper isQQInstalled];break;
	}
	if (!hasClinet && !NO_CLINET_PASS) {
		[ProgressHUD showError:@"设备没有可分享的客户端"];
		return;
	}
	type = [SHARE_TYPE_ARRAY objectAtIndex:type.integerValue];
	if (image.length) {
		[ProgressHUD show:nil];
		[image cacheImageAndCompletion:^(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache) {
			[ProgressHUD dismiss];
			if (exist) {
				[ShareHelper shareWithType:type url:url title:title content:content image:image completion:completion];
			} else {
				[ShareHelper shareWithType:type url:url title:title content:content image:APPICON_60 completion:completion];
			}
		}];
	} else {
		[ShareHelper shareWithType:type url:url title:title content:content image:APPICON_60 completion:completion];
	}
}

#define mark - helper
+ (BOOL)isWXAppInstalled{
	return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]];
	//return [WXApi isWXAppInstalled];
}

+ (BOOL)isQQInstalled{
	return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]];
	//return [QQApiInterface isQQInstalled];
}

+ (BOOL)isSinaInstalled{
	return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sinaweibo://"]];
}

+ (BOOL)isAlipayInstalled{
	return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay://"]];
}

//向对应的客户端注册APP
+ (void)registerAppWithType:(ShareHelperType)type{
	switch (type) {
		case ShareHelperTypeSina:{
			//打开新浪微博的SSO开关
			[UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:SINA_APPKEY secret:SINA_SECRET RedirectURL:SINA_SSOURL];
			break;
		}
		case ShareHelperTypeWXSession:
		case ShareHelperTypeWXTimeLine:
		case ShareHelperTypeWXFavorite:{
			//设置微信AppId，设置分享url，默认使用友盟的网址
			[UMSocialWechatHandler setWXAppId:WX_APPID appSecret:WX_APPSECRET url:API_URL];
			[WXApi registerApp:WX_APPID withDescription:APP_NAME];
			break;
		}
		case ShareHelperTypeQQ:
		case ShareHelperTypeQZone:
		case ShareHelperTypeTencent:{
			//分享到QQ空间的应用Id，和分享url链接
			[UMSocialQQHandler setQQWithAppId:QQ_APPID appKey:QQ_APPKEY url:API_URL];
			[UMSocialQQHandler setSupportWebView:YES]; //支持没有客户端情况下使用SSO授权
			break;
		}
		default:break;
	}
}

#pragma mark - 第三方登录
+ (NSArray*)loginWithType:(NSArray*)type completion:(void (^)(NSMutableDictionary* postData))completion{
	if (!type.isArray) type = @[@"sina", @"wxsession", @"qq"];
	NSMutableArray *array = [NSMutableArray arrayWithArray:SHARE_TYPE_ARRAY];
	[array addObject:@"taobao"];
	NSMutableArray *btns = [[NSMutableArray alloc]init];
	CGFloat width = 54*SCREEN_SCALE;
	for (int i=0; i<type.count; i++) {
		NSInteger tag = [array indexOfObject:type[i]];
		switch (tag) {
			case 0:{
				if (![ShareHelper isSinaInstalled] || !SINA_APPKEY.length) continue;
				break;
			}
			case 1:
			case 2:
			case 3:{
				if (![ShareHelper isWXAppInstalled] || !WX_APPID.length) continue;
				break;
			}
			case 4:
			case 5:
			case 6:{
				if (![ShareHelper isQQInstalled] || !QQ_APPID.length) continue;
				break;
			}
			case 7:
			case 8:
			case 9:
			case 10:{
				continue;
				break;
			}
		}
		UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, width)];
		btn.backgroundColor = [UIColor clearColor];
		btn.adjustsImageWhenHighlighted = NO;
		[btn setBackgroundImage:[UIImage imageNamed:type[i]] forState:UIControlStateNormal];
		[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
			switch (tag) {
				case 0:{
					[ShareHelper loginWithSina:completion];
					break;
				}
				case 1:
				case 2:
				case 3:{
					[ShareHelper loginWithWechat:completion];
					break;
				}
				case 4:
				case 5:
				case 6:{
					[ShareHelper loginWithQQ:completion];
					break;
				}
				case 11:{
					[ShareHelper loginWithTaobao:completion];
					break;
				}
				default:{
					break;
				}
			}
		}];
		[btns addObject:btn];
	}
	return btns;
}

#pragma mark - 微博登录
+ (void)loginWithSina:(void (^)(NSMutableDictionary *postData))completion{
	[ShareHelper registerAppWithType:ShareHelperTypeSina];
	[ShareHelper logoutWithSina];
	UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
	snsPlatform.loginClickHandler(APPCurrentController, [UMSocialControllerService defaultControllerService], YES, ^(UMSocialResponseEntity *response){
		if (response.responseCode == UMSResponseCodeSuccess) {
			[[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToSina completion:^(UMSocialResponseEntity *response){
				[ProgressHUD show:nil];
				NSDictionary *sourceData = [NSDictionary dictionaryWithDictionary:response.data];
				[Global downloadImage:sourceData[@"profile_image_url"] completion:^(UIImage *image, NSData *imageData, BOOL exist) {
					[imageData UploadToUpyun:@"uploadfiles/avatar" completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
						if ([json[@"code"]integerValue]==200) {
							if (completion) {
								NSString *avatarUrl = [NSString stringWithFormat:@"%@%@", UPYUN_IMGURL, json[@"url"]];
								NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
								[postData setObject:sourceData[@"screen_name"] forKey:@"name"];
								[postData setObject:avatarUrl forKey:@"avatar"];
								[postData setObject:([sourceData[@"gender"]intValue]==1?@"男":@"女") forKey:@"sex"];
								[postData setObject:[sourceData[@"location"] replace:@" " to:@""] forKey:@"address"];
								[postData setObject:sourceData[@"uid"] forKey:@"hash"];
								[postData setObject:@"weibo" forKey:@"source"];
								[postData setObject:@"sina" forKey:@"type"];
								[postData setObject:sourceData[@"description"] forKey:@"description"];
								[postData setObject:sourceData[@"favourites_count"] forKey:@"favourites_count"];
								[postData setObject:sourceData[@"followers_count"] forKey:@"followers_count"];
								[postData setObject:sourceData[@"friends_count"] forKey:@"friends_count"];
								[postData setObject:sourceData[@"statuses_count"] forKey:@"statuses_count"];
								[postData setObject:sourceData[@"uid"] forKey:@"uid"];
								[postData setObject:sourceData[@"access_token"] forKey:@"access_token"];
								completion(postData);
							}
						} else {
							[ProgressHUD showError:json[@"message"]];
						}
					}];
				}];
			}];
		} else {
			[ProgressHUD showError:response.message];
		}
	});
}

#pragma mark - 微信登录
+ (void)loginWithWechat:(void (^)(NSMutableDictionary *postData))completion{
	[ShareHelper registerAppWithType:ShareHelperTypeWXSession];
	[ShareHelper logoutWithWechat];
	UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
	snsPlatform.loginClickHandler(APPCurrentController, [UMSocialControllerService defaultControllerService], YES, ^(UMSocialResponseEntity *response){
		if (response.responseCode == UMSResponseCodeSuccess) {
			[[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToWechatSession completion:^(UMSocialResponseEntity *response){
				[ProgressHUD show:nil];
				NSDictionary *sourceData = [NSDictionary dictionaryWithDictionary:response.data];
				[Global downloadImage:sourceData[@"profile_image_url"] completion:^(UIImage *image, NSData *imageData, BOOL exist) {
					[imageData UploadToUpyun:@"uploadfiles/avatar" completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
						if ([json[@"code"]integerValue]==200) {
							if (completion) {
								NSString *avatarUrl = [NSString stringWithFormat:@"%@%@", UPYUN_IMGURL, json[@"url"]];
								[Common getApiWithUrl:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@&lang=zh_CN", sourceData[@"access_token"], sourceData[@"openid"]] success:^(NSMutableDictionary *json) {
									if (json.isDictionary) {
										NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
										[postData setObject:json[@"nickname"] forKey:@"name"];
										[postData setObject:avatarUrl forKey:@"avatar"];
										[postData setObject:([json[@"sex"]intValue]==1?@"男":@"女") forKey:@"sex"];
										[postData setObject:STRINGFORMAT(@"%@%@%@", json[@"country"], json[@"province"], json[@"city"]) forKey:@"address"];
										[postData setObject:json[@"openid"] forKey:@"hash"];
										[postData setObject:@"wechat" forKey:@"source"];
										[postData setObject:@"wxsession" forKey:@"type"];
										[postData setObject:json[@"country"] forKey:@"country"];
										[postData setObject:json[@"province"] forKey:@"province"];
										[postData setObject:json[@"city"] forKey:@"city"];
										[postData setObject:json[@"language"] forKey:@"language"];
										[postData setObject:json[@"openid"] forKey:@"openid"];
										completion(postData);
									}
								} fail:nil];
							}
						} else {
							[ProgressHUD showError:json[@"message"]];
						}
					}];
				}];
			}];
		} else {
			[ProgressHUD showError:response.message];
		}
	});
}
//原生微信登录
/*
 - application:openURL:sourceApplication:annotation:增加
 if ([@"wxauth" getUserDefaultsBool]) {
	return [WXApi handleOpenURL:url delegate:(id<WXApiDelegate>)[ShareHelper sharedHelper]];
 }
 */
+ (void)loginWithWechatAuth:(void (^)(NSMutableDictionary *postData))completion{
	if (!completion) return;
	[ShareHelper registerAppWithType:ShareHelperTypeWXSession];
	[ShareHelper logoutWithWechat];
	[@"wxauth" setUserDefaultsWithData:@YES];
	KEYWINDOW.element[@"wxauthCompletion"] = completion;
	SendAuthReq *req =[[SendAuthReq alloc]init];
	req.scope = @"snsapi_userinfo";
	req.state = @"STATE";
	[WXApi sendReq:req];
}
//只获取code,然后把code传到api的interface去换取access_token与获取用户资料
+ (void)loginWithWechatCodeToInterface:(NSDictionary*)params completion:(void (^)(NSMutableDictionary *json))completion{
	if (!completion) return;
	[ShareHelper registerAppWithType:ShareHelperTypeWXSession];
	[ShareHelper logoutWithWechat];
	[@"wxauth" setUserDefaultsWithData:@YES];
	KEYWINDOW.element[@"wxauthCompletion"] = completion;
	KEYWINDOW.element[@"wxauthInterface"] = @YES;
	KEYWINDOW.element[@"wxauthInterfaceParams"] = params;
	SendAuthReq *req =[[SendAuthReq alloc]init];
	req.scope = @"snsapi_userinfo";
	req.state = @"STATE";
	[WXApi sendReq:req];
}
- (void)onResp:(BaseResp *)resp{
	if ([resp isKindOfClass:[SendAuthResp class]]) {
		[@"wxauth" deleteUserDefaults];
		void (^completion)(NSMutableDictionary *json) = KEYWINDOW.element[@"wxauthCompletion"];
		KEYWINDOW.removeElement = @"wxauthCompletion";
		if ([(SendAuthResp*)resp code]) {
			BOOL interface = [KEYWINDOW.element[@"wxauthInterface"] boolValue];
			KEYWINDOW.removeElement = @"wxauthInterface";
			if (interface) {
				NSDictionary *params = KEYWINDOW.element[@"wxauthInterfaceParams"];
				KEYWINDOW.removeElement = @"wxauthInterfaceParams";
				NSMutableString *strings = [[NSMutableString alloc]init];
				if (params.isDictionary) {
					for (NSString *key in params) {
						[strings appendFormat:@"&%@=%@", key, [STRING(params[key])URLEncode]];
					}
				}
				NSString *url = STRINGFORMAT(@"%@/wx_interface.php?getcode=getcode&code=%@%@", API_URL, [(SendAuthResp*)resp code], strings);
				[Common getApiWithUrl:url success:^(NSMutableDictionary *json) {
					//NSLog(@"%@", json.descriptionASCII);
					if ([json[@"errcode"]isset]) {
						NSLog(@"api userinfo: %@\n%@", json[@"errcode"], json[@"errmsg"]);
						[ProgressHUD showError:STRINGFORMAT(@"获取数据错误，错误码: %@", json[@"errcode"])];
						return;
					}
					if (![json[@"openid"]isset]) {completion(json);return;}
					NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
					[postData setObject:json[@"nickname"] forKey:@"name"];
					[postData setObject:([json[@"sex"]intValue]==1?@"男":@"女") forKey:@"sex"];
					[postData setObject:STRINGFORMAT(@"%@%@%@", json[@"country"], json[@"province"], json[@"city"]) forKey:@"address"];
					[postData setObject:json[@"openid"] forKey:@"hash"];
					[postData setObject:@"wechat" forKey:@"source"];
					[postData setObject:@"wxsession" forKey:@"type"];
					[postData setObject:json[@"country"] forKey:@"country"];
					[postData setObject:json[@"province"] forKey:@"province"];
					[postData setObject:json[@"city"] forKey:@"city"];
					[postData setObject:json[@"language"] forKey:@"language"];
					[postData setObject:json[@"openid"] forKey:@"openid"];
					if (json[@"headimgurl"]) {
						[json[@"headimgurl"] cacheImageAndCompletion:^(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache) {
							[imageData UploadToUpyun:@"uploadfiles/avatar" completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
								if ([json[@"code"]integerValue]==200) {
									NSString *avatarUrl = [NSString stringWithFormat:@"%@%@", UPYUN_IMGURL, json[@"url"]];
									[postData setObject:avatarUrl forKey:@"avatar"];
									completion(postData);
								} else {
									[ProgressHUD showError:json[@"message"]];
								}
							}];
						}];
					} else {
						completion(postData);
					}
				} fail:nil];
				return;
			}
			[Common getApiWithUrl:STRINGFORMAT(@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", WX_APPID, WX_APPSECRET, [(SendAuthResp*)resp code]) success:^(NSMutableDictionary *json) {
				if ([json[@"errcode"]isset]) {
					NSLog(@"access_token: %@\n%@", json[@"errcode"], json[@"errmsg"]);
					[ProgressHUD showError:STRINGFORMAT(@"获取数据错误，错误码: %@", json[@"errcode"])];
					return;
				}
				NSString *access_token = json[@"access_token"];
				NSString *openid = json[@"openid"];
				[Common getApiWithUrl:STRINGFORMAT(@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@&lang=zh_CN", access_token, openid) success:^(NSMutableDictionary *json) {
					//NSLog(@"%@", json.descriptionASCII);
					if ([json[@"errcode"]isset]) {
						NSLog(@"userinfo: %@\n%@", json[@"errcode"], json[@"errmsg"]);
						[ProgressHUD showError:STRINGFORMAT(@"获取数据错误，错误码: %@", json[@"errcode"])];
						return;
					}
					NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
					[postData setObject:json[@"nickname"] forKey:@"name"];
					[postData setObject:([json[@"sex"]intValue]==1?@"男":@"女") forKey:@"sex"];
					[postData setObject:STRINGFORMAT(@"%@%@%@", json[@"country"], json[@"province"], json[@"city"]) forKey:@"address"];
					[postData setObject:json[@"openid"] forKey:@"hash"];
					[postData setObject:@"wechat" forKey:@"source"];
					[postData setObject:@"wxsession" forKey:@"type"];
					[postData setObject:json[@"country"] forKey:@"country"];
					[postData setObject:json[@"province"] forKey:@"province"];
					[postData setObject:json[@"city"] forKey:@"city"];
					[postData setObject:json[@"language"] forKey:@"language"];
					[postData setObject:json[@"openid"] forKey:@"openid"];
					if (json[@"headimgurl"]) {
						[json[@"headimgurl"] cacheImageAndCompletion:^(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache) {
							[imageData UploadToUpyun:@"uploadfiles/avatar" completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
								if ([json[@"code"]integerValue]==200) {
									NSString *avatarUrl = [NSString stringWithFormat:@"%@%@", UPYUN_IMGURL, json[@"url"]];
									[postData setObject:avatarUrl forKey:@"avatar"];
									completion(postData);
								} else {
									[ProgressHUD showError:json[@"message"]];
								}
							}];
						}];
					} else {
						completion(postData);
					}
				} fail:nil];
			} fail:nil];
		}
	}
}

#pragma mark - QQ登录
+ (void)loginWithQQ:(void (^)(NSMutableDictionary *postData))completion{
	[ShareHelper registerAppWithType:ShareHelperTypeQQ];
	[ShareHelper logoutWithQQ];
	//[UMSocialControllerService defaultControllerService].socialUIDelegate = self;
	UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
	snsPlatform.loginClickHandler(APPCurrentController, [UMSocialControllerService defaultControllerService], YES, ^(UMSocialResponseEntity *response){
		//获取用户名、uid、token等
		if (response.responseCode == UMSResponseCodeSuccess) {
			//获取绑定后的账号信息
			[[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToQQ completion:^(UMSocialResponseEntity *response){
				[ProgressHUD show:nil];
				NSDictionary *sourceData = [NSDictionary dictionaryWithDictionary:response.data];
				[Global downloadImage:sourceData[@"profile_image_url"] completion:^(UIImage *image, NSData *imageData, BOOL exist) {
					[imageData UploadToUpyun:@"uploadfiles/avatar" completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
						if ([json[@"code"]integerValue]==200) {
							if (completion) {
								NSString *avatarUrl = [NSString stringWithFormat:@"%@%@", UPYUN_IMGURL, json[@"url"]];
								NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
								[postData setObject:sourceData[@"screen_name"] forKey:@"name"];
								[postData setObject:avatarUrl forKey:@"avatar"];
								[postData setObject:sourceData[@"gender"] forKey:@"sex"];
								[postData setObject:sourceData[@"uid"] forKey:@"hash"];
								[postData setObject:@"qq" forKey:@"source"];
								[postData setObject:@"qq" forKey:@"type"];
								[postData setObject:sourceData[@"uid"] forKey:@"uid"];
								[postData setObject:sourceData[@"access_token"] forKey:@"access_token"];
								completion(postData);
							}
						} else {
							[ProgressHUD showError:json[@"message"]];
						}
					}];
				}];
			}];
		} else {
			[ProgressHUD showError:response.message];
		}
	});
}

#pragma mark - 淘宝登录
+ (void)loginWithTaobao:(void (^)(NSMutableDictionary *postData))completion{
	TaobaoOauth *g = [[TaobaoOauth alloc]init];
	g.completionOauth = ^(NSMutableDictionary *postData){
		if (completion) completion(postData);
	};
	UIViewController *viewController = APPCurrentController;
	UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	viewController.navigationItem.backBarButtonItem = backBtn;
	[viewController.navigationController pushViewController:g animated:YES];
}

#pragma mark - 微博退出
+ (void)logoutWithSina{
	[[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToSina completion:nil];
}

#pragma mark - 微信退出
+ (void)logoutWithWechat{
	[[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToWechatSession completion:nil];
}

#pragma mark - QQ退出
+ (void)logoutWithQQ{
	[[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToQQ completion:nil];
}

@end


#pragma mark - 淘宝授权登录
@implementation TaobaoOauth
- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"淘宝授权登录";
	self.view.backgroundColor = [UIColor whiteColor];
	UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	webView.dataDetectorTypes = UIDataDetectorTypeNone;
	webView.scrollView.bounces = NO;
	webView.delegate = self;
	[self.view addSubview:webView];
	//需与服务器协助, 具体代码查看 TaobaoOauth.php 文件
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api.php?app=oauth&act=taobao", API_URL]];
	[webView loadRequest:[[NSURLRequest alloc]initWithURL:url]];
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
	[ProgressHUD show:nil];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	NSLog(@"%@", error.userInfo);
	[ProgressHUD dismiss];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
	[ProgressHUD dismiss];
}
//JS与OC交互
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	[ProgressHUD dismiss];
	if (_completionOauth) {
		NSString *urlString = [[request URL] absoluteString];
		if ([urlString hasPrefix:[NSString stringWithFormat:@"%@/api.php?app=oauth&act=taobao_complete", API_URL]]) {
			NSArray *arr = [Global split:urlString with:@"taobao_user_id="];
			NSString *p = arr[1];
			arr = [p split:@"&taobao_user_nick="];
			NSString *taobao_user_id = arr[0];
			NSString *taobao_user_nick = arr[1];
			NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
			[postData setObject:taobao_user_nick forKey:@"name"];
			[postData setObject:taobao_user_id forKey:@"hash"];
			[postData setObject:@"taobao" forKey:@"source"];
			[postData setObject:@"taobao" forKey:@"type"];
			_completionOauth(postData);
		}
	}
	return YES;
}
@end

