//
//  Group+Extend.m
//
//  Created by ajsong on 15/10/9.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import "Global.h"

#pragma mark - UINavigationController+UITabBarController+Extend
@implementation UINavigationController (GlobalExtend)
//导航栏背景色与文字颜色
//blog.csdn.net/mad1989/article/details/41516743
- (void)setBackgroundColor:(UIColor *)bgcolor textColor:(UIColor *)textcolor{
	if (!self.viewControllers.count) return;
	self.navigationBar.translucent = NO;
	if (!IOS6) {
		self.navigationBar.barTintColor = bgcolor;
		self.navigationBar.tintColor = textcolor; //按钮文字
		self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:textcolor}; //中间文字
	} else {
		self.navigationBar.tintColor = bgcolor;
	}
	if ([self isKindOfClass:[KKNavigationController class]]) {
		if (NAVBAR_HIDDEN_UNDERLINE) ((KKNavigationController*)self).hiddenUnderLine = YES;
	}
}
//滑动隐藏
- (void)autoHidden{
	self.hidesBarsOnSwipe = YES;
}
- (BOOL)shouldAutorotate {
	return [[self.viewControllers lastObject] shouldAutorotate];
}
- (NSUInteger)supportedInterfaceOrientations {
	return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)())completion{
	if (!viewController) return;
	if ([self isKindOfClass:[KKNavigationController class]]) {
		[(KKNavigationController*)self pushViewController:viewController animated:animated completion:completion];
		return;
	}
	if (completion) {
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				completion();
			});
		});
	}
	[self pushViewController:viewController animated:animated];
}
//返回到指定的视图
- (UIViewController*)popToViewControllerOfClass:(Class)cls animated:(BOOL)animated{
	return [self popToViewControllerOfClass:cls animated:animated completion:nil];
}
- (UIViewController*)popToViewControllerOfClass:(Class)cls animated:(BOOL)animated completion:(void (^)())completion{
	UIViewController *viewController = nil;
	for (UIViewController *controller in self.viewControllers) {
		if ([controller isKindOfClass:cls]) {
			if (completion) {
				NSTimeInterval delay = animated ? 0.2 : 0;
				dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
				dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
					dispatch_async(dispatch_get_main_queue(), ^{
						completion();
					});
				});
			}
			[self popToViewController:controller animated:animated];
			viewController = controller;
			break;
		}
	}
	if (!viewController) {
		viewController = [self popViewControllerAnimated:animated];
	}
	return viewController;
}
@end
@implementation UITabBarController (GlobalExtend)
- (BOOL)shouldAutorotate {
	return [[self.viewControllers lastObject] shouldAutorotate];
}
- (NSUInteger)supportedInterfaceOrientations {
	return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}
@end


#pragma mark - NSTimer+Blocks
@implementation NSTimer (Blocks)
+ (NSTimer*)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats{
	void (^block)() = [inBlock copy];
	id ret = [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(executeSimpleBlock:) userInfo:block repeats:inRepeats];
	return ret;
}
+ (NSTimer*)timerWithTimeInterval:(NSTimeInterval)inTimeInterval repeats:(BOOL)inRepeats block:(void (^)())inBlock{
	void (^block)() = [inBlock copy];
	id ret = [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(executeSimpleBlock:) userInfo:block repeats:inRepeats];
	return ret;
}
+ (void)executeSimpleBlock:(NSTimer*)inTimer{
	if ([inTimer userInfo]) {
		void (^block)() = (void (^)())[inTimer userInfo];
		block();
	}
}
- (void)pause{
	if (![self isValid]) return;
	[self setFireDate:[NSDate distantFuture]];
}
- (void)resume{
	if (![self isValid]) return;
	[self setFireDate:[NSDate date]];
}
- (void)stop{
	[self pause];
	[self invalidate];
}
@end


#pragma mark - UIAlertView+Extend
@implementation UIAlertView (GlobalExtend)
+ (void)alert:(NSString*)message{
	[UIAlertView alert:message submit:@"确定" block:nil];
}
+ (void)alert:(NSString*)message block:(void(^)(NSInteger buttonIndex))block{
	[UIAlertView alert:message submit:@"确定" block:block];
}
+ (void)alert:(NSString*)message submit:(NSString*)submit block:(void(^)(NSInteger buttonIndex))block{
	NSString *cancelButtonTitle = nil;
	if (block) cancelButtonTitle = @"取消";
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:submit,nil];
	[alert showWithBlock:^(NSInteger buttonIndex) {
		if (block) block(buttonIndex);
	}];
}
- (void)showWithBlock:(void(^)(NSInteger buttonIndex))block{
	self.delegate = self;
	if (block) self.element[@"block"] = block;
	[self show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	void(^block)(NSInteger buttonIndex) = alertView.element[@"block"];
	if (block) block(buttonIndex);
}
@end


#pragma mark - UIActionSheet+Extend
@implementation UIActionSheet (GlobalExtend)
- (void)showInView:(UIView *)view withBlock:(void(^)(NSInteger buttonIndex))block{
	self.delegate = self;
	if (block) self.element[@"block"] = block;
	[self showInView:view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	void(^block)(NSInteger buttonIndex) = actionSheet.element[@"block"];
	if (block) block(buttonIndex);
}
@end


#pragma mark - UIControl+Extend
@implementation UIControl (GlobalExtend)
- (void)addControlEvent:(UIControlEvents)event withBlock:(void(^)(id sender))block{
	NSString *methodName = [self eventName:event];
	if (block) self.element[@"block"] = block;
	[self addTarget:self action:NSSelectorFromString(methodName) forControlEvents:event];
}
- (void)removeControlEvent:(UIControlEvents)event{
	NSString *methodName = [self eventName:event];
	[self removeElement:@"block"];
	[self removeTarget:self action:NSSelectorFromString(methodName) forControlEvents:event];
}
- (NSString*)eventName:(UIControlEvents)event{
	switch (event) {
		case UIControlEventTouchDown:			return @"UIControlEventTouchDown";
		case UIControlEventTouchDownRepeat:		return @"UIControlEventTouchDownRepeat";
		case UIControlEventTouchDragInside:		return @"UIControlEventTouchDragInside";
		case UIControlEventTouchDragOutside:	return @"UIControlEventTouchDragOutside";
		case UIControlEventTouchDragEnter:		return @"UIControlEventTouchDragEnter";
		case UIControlEventTouchDragExit:		return @"UIControlEventTouchDragExit";
		case UIControlEventTouchUpInside:		return @"UIControlEventTouchUpInside";
		case UIControlEventTouchUpOutside:		return @"UIControlEventTouchUpOutside";
		case UIControlEventTouchCancel:			return @"UIControlEventTouchCancel";
		case UIControlEventValueChanged:		return @"UIControlEventValueChanged";
		case UIControlEventEditingDidBegin:		return @"UIControlEventEditingDidBegin";
		case UIControlEventEditingChanged:		return @"UIControlEventEditingChanged";
		case UIControlEventEditingDidEnd:		return @"UIControlEventEditingDidEnd";
		case UIControlEventEditingDidEndOnExit:	return @"UIControlEventEditingDidEndOnExit";
		case UIControlEventAllTouchEvents:		return @"UIControlEventAllTouchEvents";
		case UIControlEventAllEditingEvents:	return @"UIControlEventAllEditingEvents";
		case UIControlEventApplicationReserved:	return @"UIControlEventApplicationReserved";
		case UIControlEventSystemReserved:		return @"UIControlEventSystemReserved";
		case UIControlEventAllEvents:			return @"UIControlEventAllEvents";
		default:								return @"description";
	}
	return @"description";
}
- (void)UIControlEventTouchDown{[self callActionBlock:UIControlEventTouchDown];}
- (void)UIControlEventTouchDownRepeat{[self callActionBlock:UIControlEventTouchDownRepeat];}
- (void)UIControlEventTouchDragInside{[self callActionBlock:UIControlEventTouchDragInside];}
- (void)UIControlEventTouchDragOutside{[self callActionBlock:UIControlEventTouchDragOutside];}
- (void)UIControlEventTouchDragEnter{[self callActionBlock:UIControlEventTouchDragEnter];}
- (void)UIControlEventTouchDragExit{[self callActionBlock:UIControlEventTouchDragExit];}
- (void)UIControlEventTouchUpInside{[self callActionBlock:UIControlEventTouchUpInside];}
- (void)UIControlEventTouchUpOutside{[self callActionBlock:UIControlEventTouchUpOutside];}
- (void)UIControlEventTouchCancel{[self callActionBlock:UIControlEventTouchCancel];}
- (void)UIControlEventValueChanged{[self callActionBlock:UIControlEventValueChanged];}
- (void)UIControlEventEditingDidBegin{[self callActionBlock:UIControlEventEditingDidBegin];}
- (void)UIControlEventEditingChanged{[self callActionBlock:UIControlEventEditingChanged];}
- (void)UIControlEventEditingDidEnd{[self callActionBlock:UIControlEventEditingDidEnd];}
- (void)UIControlEventEditingDidEndOnExit{[self callActionBlock:UIControlEventEditingDidEndOnExit];}
- (void)UIControlEventAllTouchEvents{[self callActionBlock:UIControlEventAllTouchEvents];}
- (void)UIControlEventAllEditingEvents{[self callActionBlock:UIControlEventAllEditingEvents];}
- (void)UIControlEventApplicationReserved{[self callActionBlock:UIControlEventApplicationReserved];}
- (void)UIControlEventSystemReserved{[self callActionBlock:UIControlEventSystemReserved];}
- (void)UIControlEventAllEvents{[self callActionBlock:UIControlEventAllEvents];}
- (void)callActionBlock:(UIControlEvents)event{
	void(^block)(id sender) = self.element[@"block"];
	if (block) block(self);
}
@end


#pragma mark - NSData+Extend
@implementation NSData (GlobalExtend)
//是否图片
- (BOOL)isImage{
	NSString *suffix = self.imageSuffix;
	return suffix.length > 0;
}
//是否GIF
- (BOOL)isGIF{
	return [self.imageSuffix isEqualToString:@"gif"];
}
//GIF数据转为GIF图片
- (UIImage*)gif{
	if (!self.length) return nil;
	if (!self.isGIF) return [[UIImage alloc]initWithData:self];
	return [GIFImage imageWithData:self];
}
//转base64
- (NSString*)base64{
	return [self base64EncodedStringWithOptions:0];
}
//后缀名(图片)
- (NSString*)imageSuffix{
	NSString *format = @"";
	uint8_t c;
	[self getBytes:&c length:1];
	switch (c) {
		case 0xFF:
			format = @"jpg";
			break;
		case 0x89:
			format = @"png";
			break;
		case 0x47:
			format = @"gif";
			break;
		case 0x49:
		case 0x4D:
			format = @"tiff";
			break;
		case 0x42:
			format = @"bmp";
			break;
	}
	return format;
}
//MimeType(图片)
- (NSString*)imageMimeType{
	NSString *format = @"application/octet-stream";
	uint8_t c;
	[self getBytes:&c length:1];
	switch (c) {
		case 0xFF:
			format = @"image/jpeg";
			break;
		case 0x89:
			format = @"image/png";
			break;
		case 0x47:
			format = @"image/gif";
			break;
		case 0x49:
		case 0x4D:
			format = @"image/tiff";
			break;
		case 0x42:
			format = @"application/x-bmp";
			break;
	}
	return format;
}
//又拍云上传图片
- (void)UploadToUpyun:(NSString*)upyunFolder completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	[self UploadToUpyun:upyunFolder imageName:nil completion:completion];
}
//又拍云上传图片, 指定文件名(不包含后缀)
- (void)UploadToUpyun:(NSString*)upyunFolder imageName:(NSString*)imageName completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	if (self.length<=0) {
		[ProgressHUD showError:@"图片无效"];
		return;
	}
	if (!imageName.length) imageName = [Global datetimeAndRandom];
	NSString *suffix = self.imageSuffix;
	NSString *name = [NSString stringWithFormat:@"%@.%@", imageName, suffix];
	NSDictionary *options = @{
							  @"bucket" : UPYUN_BUCKET,
							  @"expiration" : [NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970]+600],
							  @"save-key" : [NSString stringWithFormat:@"/%@/{year}/{mon}/{day}/%@", upyunFolder, name],
							  @"allow-file-type" : @"jpg,jpeg,gif,png,bmp",
							  @"content-length-range" : @"0,10240000",
							  @"image-width-range" : @"0,1024000",
							  @"image-height-range" : @"0,1024000"
							  };
	NSString *json = options.jsonString;
	NSString *policy = json.base64;
	NSString *sign = [[NSString stringWithFormat:@"%@&%@", policy, UPYUN_SECRET] md5];
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:policy forKey:@"policy"];
	[postData setValue:sign forKey:@"signature"];
	[postData setValue:self forKey:STRINGFORMAT(@"file.%@", suffix)];
	[Global upload:[NSString stringWithFormat:@"http://v0.api.upyun.com/%@", UPYUN_BUCKET] data:postData completion:^(NSString *result) {
		NSMutableDictionary *json = result.formatJson;
		if (json.isDictionary) {
			if ([json[@"code"]integerValue]==200) {
				if (completion) {
					NSString *imageUrl = [NSString stringWithFormat:@"%@%@", UPYUN_IMGURL, json[@"url"]];
					completion(json, [UIImage imageWithData:self], imageUrl, imageName);
				} else {
					[ProgressHUD dismiss];
				}
			} else {
				[ProgressHUD showError:json[@"message"]];
			}
		} else {
			NSLog(@"%@", result);
			[ProgressHUD showError:@"图片上传失败"];
		}
	} fail:nil];
}
@end


#pragma mark - UILabel+Extend
@implementation UILabel (GlobalExtend)
- (void)autoWidth{
	if (self.numberOfLines==1) self.numberOfLines = 0;
	CGFloat width = self.width;
	CGSize s = [self.text autoWidth:self.font height:self.height];
	if ([self.element[@"padding"] isset]) {
		UIEdgeInsets padding = UIEdgeInsetsFromString(self.element[@"padding"]);
		s.width += padding.left + padding.right;
	}
	self.width = s.width < width ? width : s.width;
}

- (void)autoHeight{
	if (self.numberOfLines==1) self.numberOfLines = 0;
	CGFloat width = self.width;
	CGFloat height = self.height;
	[self sizeToFit];
	self.width = width;
	if (self.height < height) self.height = height;
	/*
	CGSize s = [self.text autoHeight:self.font width:self.width];
	if ([self.element[@"padding"] isset]) {
		UIEdgeInsets padding = UIEdgeInsetsFromString(self.element[@"padding"]);
		s.height += padding.top + padding.bottom;
	}
	self.height = s.height;
	*/
}
@end


#pragma mark - UISearchBar+Extend
@implementation UISearchBar (GlobalExtend)
- (UIColor*)textColor{
	UITextField *searchField = [self valueForKey:@"_searchField"];
	return searchField.textColor;
}
- (void)setTextColor:(UIColor *)textColor{
	UITextField *searchField = [self valueForKey:@"_searchField"];
	searchField.textColor = textColor;
}
- (UIColor*)placeholderColor{
	UITextField *searchField = [self valueForKey:@"_searchField"];
	return [searchField valueForKeyPath:@"_placeholderLabel.textColor"];
}
- (void)setPlaceholderColor:(UIColor *)placeholderColor{
	UITextField *searchField = [self valueForKey:@"_searchField"];
	[searchField setValue:placeholderColor forKeyPath:@"_placeholderLabel.textColor"];
}
@end


#pragma mark - UIColor+Extend
@implementation UIColor (GlobalExtend)
- (CGFloat)alpha{
	CGFloat r, g, b, a;
	if ([self getRed:&r green:&g blue:&b alpha:&a]){
		return a;
	}
	return 1.f;
}
- (UIColor*)setAlpha:(CGFloat)alpha{
	CGFloat r, g, b, a;
	if ([self getRed:&r green:&g blue:&b alpha:&a]){
		return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
	}
	return nil;
}
//UIColor转网页颜色
- (NSString*)string{
	const CGFloat *cs = CGColorGetComponents(self.CGColor);
	NSString *hex = [NSString stringWithFormat:@"%02X%02X%02X", (int)(cs[0]*255.f), (int)(cs[1]*255.f), (int)(cs[2]*255.f)];
	return hex;
}
@end


#pragma mark - UIWindow+Extend
@implementation UIWindow (GlobalExtend)
- (UIViewController*)currentController{
	UIViewController *controller = self.rootViewController;
	if ([controller isKindOfClass:[UITabBarController class]]) {
		controller = ((UITabBarController*)controller).selectedViewController;
	}
	//[[NSString stringWithUTF8String:object_getClassName(controller)] isEqualToString:@"KKTabBarController"]
	if ([controller isKindOfClass:[KKTabBarController class]]) {
		controller = ((KKTabBarController*)controller).selectedViewController;
	}
	if ([controller isKindOfClass:[UINavigationController class]]) {
		controller = ((UINavigationController*)controller).viewControllers.lastObject;
	}
	return controller;
}
- (UIView*)statusBar{
	UIView *statusBar = nil;
	NSData *data = [NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9];
	NSString *key = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	id object = [UIApplication sharedApplication];
	if ([object respondsToSelector:NSSelectorFromString(key)]) statusBar = [object valueForKey:key];
	return statusBar;
}
- (CGFloat)statusBarHeight{
	return [UIApplication sharedApplication].statusBarFrame.size.height;
}
@end


#pragma mark - NSMutableDictionary+Extend
@implementation NSDictionary (GlobalExtend)
- (NSDictionary*)merge:(NSDictionary*)dictionary{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:self];
	for (NSString *key in dictionary) {
		[newDict setObject:dictionary[key] forKey:key];
	}
	return [NSDictionary dictionaryWithDictionary:newDict];
}
- (NSString*)hasChild:(id)object{
	return [object inDictionary:self];
}
- (NSString*)descriptionASCII{
	NSString *description = [NSString stringWithCString:[self.description cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
	if (!description.length) description = [self description];
	return description;
}
- (NSDictionary*)compatible{
	if (!self.isDictionary) return self;
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:self];
	newDict = newDict.compatible;
	return [NSDictionary dictionaryWithDictionary:newDict];
}
- (NSDictionary*)UpyunSuffix:(NSString*)suffix forKeys:(NSArray*)keys{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:self];
	newDict = [newDict UpyunSuffix:suffix forKeys:keys];
	return [NSDictionary dictionaryWithDictionary:newDict];
}
@end
@implementation NSMutableDictionary (GlobalExtend)
- (NSMutableDictionary*)merge:(NSDictionary*)dictionary{
	for (NSString *key in dictionary) {
		[self setObject:dictionary[key] forKey:key];
	}
	return self;
}
- (NSString*)hasChild:(id)object{
	return [object inDictionary:self];
}
- (NSString*)descriptionASCII{
	NSString *description = [NSString stringWithCString:[[self description] cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
	if (!description.length) description = [self description];
	return description;
}
//转换null为空字符串
- (NSMutableDictionary*)compatible{
	if (!self.isDictionary) return self;
	NSMutableDictionary *newDict = [[NSMutableDictionary alloc]init];
	for (NSString *key in self) {
		if (self[key]==nil || [self[key] isKindOfClass:[NSNull class]]) {
			[newDict setObject:@"" forKey:key];
		} else if ([self[key] isKindOfClass:[NSDictionary class]] || [self[key] isKindOfClass:[NSArray class]]) {
			[newDict setObject:[self[key]compatible] forKey:key];
		} else {
			[newDict setObject:self[key] forKey:key];
		}
	}
	return newDict;
}
- (NSMutableDictionary*)UpyunSuffix:(NSString*)suffix forKeys:(NSArray*)keys{
	NSMutableDictionary *newDict = [[NSMutableDictionary alloc]init];
	for (NSString *key in self) {
		if ([self[key] isKindOfClass:[NSArray class]]) {
			NSArray *l = [(NSArray*)self[key] UpyunSuffix:suffix forKeys:keys];
			[newDict setObject:l forKey:key];
		} else if ([self[key] isKindOfClass:[NSDictionary class]]) {
			NSDictionary *d = [(NSDictionary*)self[key] UpyunSuffix:suffix forKeys:keys];
			[newDict setObject:d forKey:key];
		} else {
			if ([self[key] isKindOfClass:[NSString class]] && [self[key] length]) {
				if ([key inArray:keys]!=NSNotFound) {
					if ([self[key] indexOf:@"b0.upaiyun.com"]!=NSNotFound && ![self[key] preg_test:@"!\\w+$"]) {
						[newDict setObject:STRINGFORMAT(@"%@%@", self[key], suffix) forKey:key];
					} else {
						[newDict setObject:self[key] forKey:key];
					}
				} else {
					[newDict setObject:self[key] forKey:key];
				}
			} else {
				[newDict setObject:self[key] forKey:key];
			}
		}
	}
	return newDict;
}
@end


#pragma mark - FileDownloader
@interface FileDownloader ()<NSURLConnectionDataDelegate>{
	NSURLConnection *_conn;
	NSMutableData *_data;
	unsigned long long _currentLength; //已获取的数据长度
	unsigned long long _totalLength; //总数据长度
}
@end
@implementation FileDownloader
+ (FileDownloader*)downloadWithUrl:(NSString*)url completion:(void(^)(NSData *data, BOOL exist))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	FileDownloader *fileDownloader = [[FileDownloader alloc]init];
	fileDownloader.url = url;
	fileDownloader.completion = completion;
	fileDownloader.fail = fail;
	dispatch_async(dispatch_get_main_queue(), ^{
		[fileDownloader start];
	});
	return fileDownloader;
}
+ (FileDownloader*)downloadWithUrl:(NSString*)url timeout:(NSTimeInterval)timeout progress:(void (^)(double progress, long dataSize, long long currentSize, long long totalSize))progress completion:(void (^)(NSData *data, BOOL exist))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	FileDownloader *fileDownloader = [[FileDownloader alloc]init];
	fileDownloader.url = url;
	fileDownloader.timeout = timeout;
	fileDownloader.progress = progress;
	fileDownloader.completion = completion;
	fileDownloader.fail = fail;
	dispatch_async(dispatch_get_main_queue(), ^{
		[fileDownloader start];
	});
	return fileDownloader;
}
- (instancetype)init{
	self = [super init];
	if (self) {
		_timeout = DOWNLOAD_TIMEOUT;
	}
	return self;
}
//开始下载
- (void)start{
	if (!_url.length) return;
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:_timeout];
	[request setHTTPMethod:@"GET"];
	NSString *rangeValue = [NSString stringWithFormat:@"bytes=%llu-", _currentLength];
	[request setValue:rangeValue forHTTPHeaderField:@"Range"];
	_conn = [NSURLConnection connectionWithRequest:request delegate:self];
	dispatch_async(dispatch_queue_create("downloadConnection", DISPATCH_QUEUE_CONCURRENT), ^{
		[_conn start];
	});
}
//暂停下载
- (void)pause{
	[_conn cancel];
	_conn = nil;
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
//取消下载
- (void)stop{
	[self pause];
	_currentLength = 0;
	_totalLength = 0;
	[_data setData:nil];
}
//当接收到响应(连通了服务器)时调用
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
	if ( !(responseCode>=200 && responseCode<300) ) {
		NSLog(@"FileDownloader Receive Error:%ld", (long)responseCode);
		if (_fail) {
			dispatch_async(dispatch_get_main_queue(), ^{
				_fail(@"Receive Error", responseCode);
			});
		}
		return;
	}
	if (_totalLength) return;
	_totalLength = response.expectedContentLength;
	if (!_data) {
		_data = [NSMutableData data];
	} else {
		[_data setData:nil];
	}
}
#pragma clang diagnostic pop
//当接收到数据时调用(如果数据量大,例如视频可能会被调用多次,每次只传递部分数据)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	if (!data.length) {
		dispatch_async(dispatch_get_main_queue(), ^{
			//if (_completion) _completion(nil, NO);
		});
		return;
	}
	_currentLength += data.length;
	double progress = (double)_currentLength / _totalLength;
	if (_progress) {
		dispatch_async(dispatch_get_main_queue(), ^{
			_progress(progress, data.length, _currentLength, _totalLength);
		});
		//NSLog(@"%f%%", progress);
	}
	[_data appendData:data];
}
//当数据加载完毕时调用
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (_data) {
			if (_completion) _completion(_data, YES);
		}
	});
}
//请求错误(失败)时调用(请求超时\断网\没有网,一般指客户端网络出错)
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSString *result = [[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
	NSLog(@"FileDownloder Httperror:%@ Errorcode:%ld", error.localizedDescription, (long)error.code);
	dispatch_async(dispatch_get_main_queue(), ^{
		if (_fail) _fail(error.localizedDescription, (long)error.code);
	});
	[self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}
@end


#pragma mark - One Finger Rotation
#import <UIKit/UIGestureRecognizerSubclass.h>
@implementation OneFingerRotationGestureRecognizer
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	if ([[event touchesForGestureRecognizer:self] count] > 1) {
		[self setState:UIGestureRecognizerStateFailed];
	}
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	if ([self state] == UIGestureRecognizerStatePossible) {
		[self setState:UIGestureRecognizerStateBegan];
	} else {
		[self setState:UIGestureRecognizerStateChanged];
	}
	UITouch *touch = [touches anyObject];
	UIView *view = [self view];
	CGPoint center = CGPointMake(CGRectGetMidX([view bounds]), CGRectGetMidY([view bounds]));
	CGPoint currentTouchPoint = [touch locationInView:view];
	CGPoint previousTouchPoint = [touch previousLocationInView:view];
	CGFloat angleInRadians = atan2f(currentTouchPoint.y - center.y, currentTouchPoint.x - center.x) - atan2f(previousTouchPoint.y - center.y, previousTouchPoint.x - center.x);
	_rotation = angleInRadians;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	if ([self state] == UIGestureRecognizerStateChanged) {
		[self setState:UIGestureRecognizerStateEnded];
	} else {
		[self setState:UIGestureRecognizerStateFailed];
	}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	[self setState:UIGestureRecognizerStateFailed];
}
@end


#pragma mark - QueueHandle
@interface QueueHandle ()
@property(nonatomic) dispatch_queue_t queue;
@property(nonatomic) dispatch_semaphore_t semaphore;
@end
@implementation QueueHandle
- (id)init{
	if (self = [super init]) {
		_queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
	}
	return self;
}
- (void)queueHandleBlock:(void (^)(void))operate{
	dispatch_async(_queue, ^{
		_semaphore = dispatch_semaphore_create(0);
		dispatch_async(dispatch_get_main_queue(), operate);
		dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
	});
}
- (void)completionBlock:(void (^)(void))completion{
	if (completion) completion();
	dispatch_semaphore_signal(_semaphore);
}
@end


#pragma mark - ToastView
#define TOASTVIEW_TAG 20100818
@implementation ToastView
+ (ToastView*)toastShare{
	static dispatch_once_t once = 0;
	static ToastView *toast;
	dispatch_once(&once, ^{ toast = [[ToastView alloc]init]; });
	return toast;
}
+ (void)content:(NSString*)content target:(id)target action:(SEL)action{
	[ToastView content:content target:target action:action withObject:nil];
}
+ (void)content:(NSString*)content target:(id)target action:(SEL)action withObject:(id)anArgument{
	ToastView *toastView = [self toastShare];
	[toastView toastWithText:content target:target action:action withObject:anArgument];
	[toastView showToast:5.0f];
}
+ (void)content:(NSString*)content time:(NSTimeInterval)time target:(id)target action:(SEL)action{
	[ToastView content:content time:time target:target action:action withObject:nil];
}
+ (void)content:(NSString*)content time:(NSTimeInterval)time target:(id)target action:(SEL)action withObject:(id)anArgument{
	ToastView *toastView = [self toastShare];
	[toastView toastWithText:content target:target action:action withObject:anArgument];
	[toastView showToast:time];
}
- (void)toastWithText:(NSString*)content target:(id)target action:(SEL)action withObject:(id)anArgument{
	BOOL exist = YES;
	NSInteger subviewCount = 0;
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	if (![window viewWithTag:TOASTVIEW_TAG]) {
		exist = NO;
		_toastView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
		_toastView.barStyle = UIBarStyleBlackTranslucent;
		_toastView.tag = TOASTVIEW_TAG;
		_toastView.userInteractionEnabled = YES;
	} else {
		_toastView = (UIToolbar*)[window viewWithTag:TOASTVIEW_TAG];
	}
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(15, 30, SCREEN_WIDTH-15-15, 0)];
	view.clipsToBounds = YES;
	view.tag = TOASTVIEW_TAG + 1;
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		if (target && action && [target respondsToSelector:action]) objc_msgSend(target, action, anArgument);
		[self closeToast];
	}];
	
	UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
	icon.image = IMG(@"AppIcon29x29");
	icon.layer.masksToBounds = YES;
	icon.layer.cornerRadius = 5;
	[view addSubview:icon];
	
	NSString *string = STRINGFORMAT(@"%@提醒", APP_NAME);
	CGSize s = [string autoWidth:FONTBOLD(12) height:17];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(icon.width+12, 0, s.width, 10)];
	label.text = string;
	label.textColor = [UIColor whiteColor];
	label.font = FONTBOLD(12);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right+12, 3, 100, 10)];
	timeLabel.text = [Global formatDate:[NSDate date] format:@"yyyy-MM-dd HH:mm:ss"];
	timeLabel.textColor = [UIColor lightGrayColor];
	timeLabel.font = FONTBOLD(9);
	timeLabel.backgroundColor = [UIColor clearColor];
	[view addSubview:timeLabel];
	
	s = [content autoHeight:FONT(12) width:view.width-label.left];
	if (s.height>34) s.height = 34;
	label = [[UILabel alloc]initWithFrame:CGRectMake(label.left, label.bottom+2, view.width-label.left, s.height)];
	label.text = content;
	label.textColor = [UIColor whiteColor];
	label.font = FONT(12);
	label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 0;
	[view addSubview:label];
	
	UIView *ge = [[UIView alloc]initWithFrame:CGRectMake(0, label.bottom+10, view.width, 0.5)];
	ge.backgroundColor = [UIColor lightGrayColor];
	[view addSubview:ge];
	
	view.height = ge.bottom;
	if (exist) {
		NSMutableArray *subviews = [[NSMutableArray alloc]init];
		for (int i=0; i<_toastView.subviews.count; i++) {
			if ([_toastView.subviews[i] tag]>TOASTVIEW_TAG) [subviews addObject:_toastView.subviews[i]];
		}
		for (int i=0; i<subviews.count; i++) {
			[UIView animateWithDuration:0.3 animations:^{
				UIView *subview = subviews[i];
				subview.top = subview.top + view.height + 10;
				_toastView.height = _toastView.height + view.height + 10;
			} completion:^(BOOL finished) {
				if (i==subviews.count-1) {
					view.alpha = 0;
					[_toastView insertSubview:view belowSubview:subviews[0]];
					[UIView animateWithDuration:0.3 animations:^{
						view.alpha = 1;
					}];
				}
			}];
		}
	} else {
		[_toastView addSubview:view];
		CGFloat height = view.bottom + 10;
		_toastView.frame = CGRectMake(0, -height, SCREEN_WIDTH, height);
	}
}
- (void)showToast:(NSTimeInterval)showTime{
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	if (![window viewWithTag:TOASTVIEW_TAG]) {
		[window addSubview:_toastView];
		[UIView animateWithDuration:0.5 animations:^{
			_toastView.top = 0;
		}];
	}
	if (showTime>0) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, showTime * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				[self closeToast];
			});
		});
	}
}
- (void)closeToast{
	NSInteger count = 0;
	for (int i=0; i<_toastView.subviews.count; i++) {
		if ([_toastView.subviews[i] tag]>TOASTVIEW_TAG) count++;
	}
	if (count==1) {
		[UIView animateWithDuration:0.5 animations:^{
			_toastView.top = -_toastView.height;
		} completion:^(BOOL finished) {
			[_toastView removeFromSuperview];
		}];
	} else {
		UIView *view = _toastView.lastSubview;
		[UIView animateWithDuration:0.3 animations:^{
			view.alpha = 0;
			view.height = 0;
			_toastView.height = view.bottom;
		} completion:^(BOOL finished) {
			[view removeFromSuperview];
		}];
	}
}
@end


#pragma mark - SimpleSwitchView
@implementation SimpleSwitchView
- (void)setHiddenGeLine:(BOOL)hiddenGeLine{
	_hiddenGeLine = hiddenGeLine;
	if (!hiddenGeLine) return;
	NSArray *svs = self.subviews;
	if (!svs.count) return;
	if ([svs[0] isKindOfClass:[UIScrollView class]]) svs = [svs[0] subviews];
	for (int i=0; i<svs.count; i++) {
		if ([svs[i] tag]>=54263) [svs[i] removeGeLine:GeLineRightTag];
	}
}
- (void)setIndex:(NSInteger)index{
	if (!_nameArray.count || index>=_nameArray.count) index = 0;
	_index = index;
	NSArray *svs = self.subviews;
	if (!svs.count) return;
	if ([svs[0] isKindOfClass:[UIScrollView class]]) svs = [svs[0] subviews];
	[self selectValue:svs[index]];
}
- (void)willMoveToSuperview:(UIView *)newSuperview{
	BOOL isScroll = NO;
	UIFont *font = _font ? _font : [UIFont systemFontOfSize:14.f];
	CGFloat w = self.frame.size.width / _nameArray.count;
	CGFloat totalWidth = 0;
	for (int i=0; i<_nameArray.count; i++) {
		CGSize s = [_nameArray[i] autoWidth:font height:self.frame.size.height];
		totalWidth += s.width + (_padding?_padding:10)*2;
	}
	if (totalWidth>self.frame.size.width) {
		isScroll = YES;
		_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.contentSize = CGSizeMake(_scrollView.width, _scrollView.height);
		[self addSubview:_scrollView];
	}
	CGFloat left = 0;
	for (int i=0; i<_nameArray.count; i++) {
		if (_scrollView) {
			CGSize s = [_nameArray[i] autoWidth:font height:self.frame.size.height];
			w = s.width + (_padding?_padding:10)*2;
		}
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(left, 0, w, self.frame.size.height)];
		label.text = _nameArray[i];
		label.textAlignment = NSTextAlignmentCenter;
		label.font = font;
		if (i==_index) {
			label.textColor = _selectedTextColor ? _selectedTextColor : [UIColor blackColor];
			label.backgroundColor = _selectedBgColor ? _selectedBgColor : [UIColor clearColor];
		} else {
			label.textColor = _textColor ? _textColor : [UIColor blackColor];
			label.backgroundColor = _bgColor ? _bgColor : [UIColor clearColor];
		}
		label.tag = i + 54263;
		[_scrollView?_scrollView:self addSubview:label];
		[label click:^(UIView *view, UIGestureRecognizer *sender) {
			[self selectValue:(UILabel*)view];
		}];
		if (!_hiddenGeLine && i<_nameArray.count-1) [label addGeWithType:GeLineTypeRight];
		left = label.right;
	}
	if (_scrollView) _scrollView.contentSize = CGSizeMake(left, _scrollView.height);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (_delegate && [_delegate respondsToSelector:@selector(SimpleSwitchView:didSelectAtIndex:value:)]) {
				[_delegate SimpleSwitchView:self didSelectAtIndex:_index value:_valueArray[_index]];
			}
		});
	});
}
- (void)selectValue:(UILabel*)label{
	NSInteger tag = label.tag - 54263;
	NSMutableArray *subviews = [[NSMutableArray alloc]init];
	NSArray *svs = self.subviews;
	if ([svs[0] isKindOfClass:[UIScrollView class]]) svs = [svs[0] subviews];
	for (int i=0; i<svs.count; i++) {
		if ([svs[i] tag]>=54263) [subviews addObject:svs[i]];
	}
	for (UILabel *subview in subviews) {
		subview.textColor = _textColor ? _textColor : [UIColor blackColor];
		subview.backgroundColor = _bgColor ? _bgColor : [UIColor clearColor];
	}
	label.textColor = _selectedTextColor ? _selectedTextColor : [UIColor blackColor];
	label.backgroundColor = _selectedBgColor ? _selectedBgColor : [UIColor clearColor];
	NSString *value = _valueArray[tag];
	if (_delegate && [_delegate respondsToSelector:@selector(SimpleSwitchView:didSelectAtIndex:value:)]) {
		[_delegate SimpleSwitchView:self didSelectAtIndex:tag value:value];
	}
}
@end


#pragma mark - AJWebView
@interface AJWebView ()<WKNavigationDelegate,WKUIDelegate>{
	BOOL _autoHeight;
	BOOL _removeObservered;
	UIActivityIndicatorView *_loading;
	void(^_finishLoad)(NSString *html);
}
@end
@implementation AJWebView
- (instancetype)initWithFrame:(CGRect)frame{
	if (frame.size.height<=0) frame.size.height = 0.00001;
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
		self.scrollView.bounces = NO;
		if (@available(iOS 11.0, *)) {
			self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
			self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
			self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
		}
		_textColor = COLOR333;
		_font = FONT(12);
		_padding = UIEdgeInsetsMake(8*SCREEN_SCALE, 8*SCREEN_SCALE, 8*SCREEN_SCALE, 8*SCREEN_SCALE);
		_style = @"";
		_script = @"";
	}
	return self;
}
- (void)setHtml:(NSString *)html{
	self.navigationDelegate = self;
	html = [[html replace:@"\\n" to:@""] preg_replace:@"</?a[^>]*>" with:@""];
	html = [html preg_replace:@"width:\\s*(\\d+)px;\\s*height:\\s*(\\d+)px;" replacement:^NSString *(NSDictionary *matcher, NSInteger index) {
		if ([matcher[@"group"][0]intValue]>600) return @"width:600px;";
		return matcher[@"value"];
	}];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			NSString *bodyCss = @"";
			[self loadHTMLString:STRINGFORMAT(@"<!doctype html><html><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width,minimum-scale=1.0,maximum-scale=1.0,initial-scale=1.0,user-scalable=no\"><style>html,body{background-color:transparent;-webkit-touch-callout:none;-webkit-user-select:none;-webkit-overflow-scrolling:touch;color:#%@;font-size:%.fpx;font-family:arial;margin:0;padding:0;text-align:left;}body>div{width:100%%;height:auto;overflow:hidden;box-sizing:border-box;float:left;padding:%.fpx %.fpx %.fpx %.fpx;}body>div>p:first-child{margin-top:0;}body>div>p:last-child{margin-bottom:0;}p{margin:0;padding:0;width:auto;word-break:break-all;white-space:pre-wrap;}p img{float:left;}%@</style></head><body><div>%@</div></body></html>", _textColor.string, _font.pointSize, _padding.top, _padding.right, _padding.bottom, _padding.left, _style, html) baseURL:nil];
		});
	});
}
- (void)autoHeightWithHtml:(NSString *)html finishLoad:(void (^)(AJWebView *webView))finishLoad{
	_autoHeight = YES;
	if (finishLoad) self.element[@"finishLoad"] = finishLoad;
	self.scrollView.scrollEnabled = NO;
	[self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
	self.html = html;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			_removeObservered = YES;
			[self.scrollView removeObserver:self forKeyPath:@"contentSize" context:nil];
		});
	});
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if (_autoHeight && !_removeObservered && [keyPath isEqualToString:@"contentSize"]) {
		[self evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
			_html = obj;
			NSString *js = @"document.getElementsByTagName('body')[0].children[0].offsetHeight";
			[self evaluateJavaScript:js completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
				CGFloat divHeight = [obj floatValue];
				CGFloat height = self.scrollView.contentSize.height;
				if (height > divHeight) height = divHeight;
				if (self.height != height) {
					dispatch_async(dispatch_get_main_queue(), ^{
						self.height = height;
						void (^finishLoad)(AJWebView *webView) = self.element[@"finishLoad"];
						if (finishLoad) finishLoad(self);
					});
				}
			}];
		}];
	}
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
	[_loading startAnimating];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
	[_loading stopAnimating];
	if (_autoHeight) {
		NSString *js = STRINGFORMAT(@"var img = document.getElementsByTagName('img');\
							  for(var i=0;i<img.length;i++){if(img[i].offsetWidth<=300)continue;\
							  img[i].style.width='';img[i].style.height='';img[i].style.verticalAlign='bottom';\
							  img[i].setAttribute('width','100%%');if(img[i].getAttribute('height'))img[i].removeAttribute('height');}\
							  %@", _script);
		[webView evaluateJavaScript:js completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
			[webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
				_html = obj;
				if (_finishLoad) _finishLoad(_html);
			}];
		}];
	} else {
		[webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
			_html = obj;
			if (_finishLoad) _finishLoad(_html);
		}];
	}
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
	if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
		decisionHandler(WKNavigationActionPolicyCancel);
		return;
	}
	decisionHandler(WKNavigationActionPolicyAllow);
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
	NSLog(@"%@", error.userInfo);
	[_loading stopAnimating];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
	NSLog(@"%@", error.userInfo);
	[_loading stopAnimating];
}
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		completionHandler();
	}]];
	[APPCurrentController presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		completionHandler(NO);
	}]];
	[alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		completionHandler(YES);
	}]];
	[APPCurrentController presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.text = defaultText;
	}];
	[alertController addAction:[UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		completionHandler(alertController.textFields[0].text?:@"");
	}]];
	[APPCurrentController presentViewController:alertController animated:YES completion:nil];
}
- (void)setUrl:(NSString *)url{
	self.navigationDelegate = self;
	self.UIDelegate = self;
	if (!_loading) {
		_loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_loading.frame = CGRectMake(0, 0, 20*SCREEN_SCALE, 20*SCREEN_SCALE);
		_loading.hidesWhenStopped = YES;
		[self addSubview:_loading];
		CGRect frame = _loading.frame;
		frame.origin.x = (self.width-frame.size.width)/2;
		frame.origin.y = (self.height-frame.size.height)/2;
		_loading.frame = frame;
	}
	[self performSelector:@selector(setUrlDelay:) withObject:url afterDelay:0];
}
- (void)setUrlDelay:(NSString *)url{
	_url = url;
	[self loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:_url]]];
}
- (void)didFinishLoad:(void (^)(NSString *html))finishLoad{
	_finishLoad = finishLoad;
}
- (void)dealloc{
	[self loadHTMLString:@"" baseURL:nil];
}
@end


#pragma mark - Outlet WebView
@interface outlet ()<UIGestureRecognizerDelegate>{
	UIStatusBarStyle _originStatusBarStyle;
	BOOL _originStatusBarHidden;
	BOOL _navigationBarHidden;
	UIPanGestureRecognizer *_panGesture;
	UIView *_progressView;
}
@end
@implementation outlet
- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	if (_viewWillAppear) _viewWillAppear();
	if (_isFullscreen) {
		_originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
		_originStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
		if (_statusBarBlack) {
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
		} else {
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
		}
		[[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden withAnimation:UIStatusBarAnimationSlide];
		if (self.navigationController) [self.navigationController setNavigationBarHidden:YES animated:YES];
	}
	if (_isProgressLoad) {
		if (!_isFullscreen && self.navigationController) {
			_progressView.frame = CGRectMake(0, self.navigationController.navigationBar.bounds.size.height, self.view.frame.size.width, 3*SCREEN_SCALE);
			[self.navigationController.navigationBar addSubview:_progressView];
		} else {
			_progressView.frame = CGRectMake(0, 0, self.view.frame.size.width, 3*SCREEN_SCALE);
			[self.view addSubview:_progressView];
		}
		[_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
	}
}
- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	if (_viewWillDisappear) _viewWillDisappear();
	if (_isFullscreen) {
		[[UIApplication sharedApplication] setStatusBarStyle:_originStatusBarStyle animated:YES];
		[[UIApplication sharedApplication] setStatusBarHidden:_originStatusBarHidden withAnimation:UIStatusBarAnimationSlide];
		if (self.navigationController) [self.navigationController setNavigationBarHidden:_navigationBarHidden animated:YES];
	}
	if (_isProgressLoad) {
		[_webView removeObserver:self forKeyPath:@"estimatedProgress"];
	}
}
- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	if (self.navigationController) return;
	[self.view removeAllDelegate];
	_webView.navigationDelegate = nil;
	_webView.UIDelegate = nil;
	[_webView loadHTMLString:@"" baseURL:nil];
	[_webView stopLoading];
	[_webView removeFromSuperview];
	[_progressView removeFromSuperview];
	_webView = nil;
	_progressView = nil;
	self.delegate = nil;
}
- (id)init{
	self = [super init];
	if (self) {
		_isWebGoBack = YES;
		_isProgressLoad = YES;
		if (APPCurrentController.navigationController) _navigationBarHidden = APPCurrentController.navigationController.navigationBarHidden;
	}
	return self;
}
- (void)returnTo{
	if (_isWebGoBack && _webView.canGoBack) {
		[_webView goBack];
	} else {
		if (self.navigationController && ![self.navigationController.viewControllers.firstObject isEqual:self]) {
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	}
}
- (void)viewDidLoad{
	[super viewDidLoad];
	if (!self.title.length) self.title = @"详情";
	if (!self.view.backgroundColor) self.view.backgroundColor = [UIColor whiteColor];
	_webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_webView.backgroundColor = [UIColor clearColor];
	_webView.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
	_webView.navigationDelegate = self;
	_webView.UIDelegate = self;
	[self.view addSubview:_webView];
	if (_isProgressLoad) {
		_progressView = [[UIView alloc]init];
		_progressView.backgroundColor = CLEAR;
		_progressLayer = [CALayer layer];
		_progressLayer.frame = CGRectMake(0, 0, 0, 3*SCREEN_SCALE);
		_progressLayer.backgroundColor = GREEN.CGColor;
		[_progressView.layer addSublayer:_progressLayer];
	}
	UIImage *returnImage = _leftImage ? _leftImage : [UIImage imageNamed:@"return"];
	if (_isFullscreen) {
		self.automaticallyAdjustsScrollViewInsets = NO;
		_webView.height = SCREEN_HEIGHT;
		UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(6, 20, returnImage.size.width, returnImage.size.height)];
		btn.backgroundColor = [UIColor clearColor];
		[btn setBackgroundImage:returnImage forState:UIControlStateNormal];
		[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
			if (_leftBlock) {
				_leftBlock();
				return;
			}
			[self returnTo];
		}];
		[self.view addSubview:btn];
		if (_rightImage) {
			btn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.width-_rightImage.size.width-6, 20, _rightImage.size.width, _rightImage.size.height)];
			btn.backgroundColor = [UIColor clearColor];
			[btn setBackgroundImage:_rightImage forState:UIControlStateNormal];
			if (_rightBlock) {
				[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
					_rightBlock();
				}];
			}
			[self.view addSubview:btn];
		}
	} else {
		if (_leftBlock) {
			KKNavigationBarItem *item = [self.navigationItem setItemWithImage:returnImage size:CGSizeMake(44, 44) itemType:KKNavigationItemTypeLeft];
			[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
				_leftBlock();
			}];
		}
		if (_rightText.length) {
			KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:_rightText textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
			if (_rightBlock) {
				[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
					_rightBlock();
				}];
			}
		}
		if (_rightView) {
			KKNavigationBarItem *item = [self.navigationItem setItemWithCustomView:_rightView itemType:KKNavigationItemTypeRight];
			if (_rightBlock) {
				[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
					_rightBlock();
				}];
			}
		}
		//如果导航栏为白色即增加分隔线
		if (self.navigationController && !self.navigationController.navigationBarHidden) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					BOOL isWhiteColor = NO;
					CGFloat r, g, b, a;
					if ([self.navigationController.navigationBar.barTintColor getRed:&r green:&g blue:&b alpha:&a]){
						isWhiteColor = (r==1 && g==1 && b==1 && a==1);
					}
					if (isWhiteColor) {
						UIView *geline = [[UIView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 0.5*SCREEN_SCALE)];
						geline.backgroundColor = COLOR_GE_LIGHT;
						[self.view addSubview:geline];
					}
				});
			});
		}
	}
	self.isTwoFingerReload = YES;
	[_webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id obj, NSError *error) {
		NSString *agent = [obj stringByAppendingFormat:@" @jsong/%@", SDK_VERSION];
		agent = [agent stringByAppendingFormat:@" %@/%@", APP_BUNDLE_ID, APP_BUILD_VERSION];
		agent = [agent stringByAppendingFormat:@" (%@ruandao)", _userAgentMark.length?STRINGFORMAT(@"%@/", _userAgentMark):@""];
		if ([_webView respondsToSelector:@selector(setCustomUserAgent:)]) {
			[_webView setCustomUserAgent:agent];
		} else {
			[_webView setValue:agent forKey:@"applicationNameForUserAgent"];
		}
		[_webView loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _url]]]];
		[self performSelector:@selector(loadViews) withObject:nil afterDelay:0];
	}];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"estimatedProgress"]) {
		_progressLayer.opacity = 1;
		if ([change[@"new"] floatValue] < [change[@"old"] floatValue]) return;
		_progressLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width * [change[@"new"] floatValue], 3*SCREEN_SCALE);
		if ([change[@"new"] floatValue] == 1) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				_progressLayer.opacity = 0;
			});
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				_progressLayer.frame = CGRectMake(0, 0, 0, 3*SCREEN_SCALE);
			});
		}
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}
- (void)loadViews{
	if (_delegate && [_delegate respondsToSelector:@selector(OutletLoadViewWith:)]) {
		[_delegate OutletLoadViewWith:self];
	}
	if ([self respondsToSelector:@selector(OutletViewDidLoad)]) {
		[self OutletViewDidLoad];
	}
}
- (void)setIsTwoFingerReload:(BOOL)isTwoFingerReload{
	if (isTwoFingerReload) {
		[_webView.scrollView removeGestureRecognizer:_panGesture];
		_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerReload:)];
		_panGesture.minimumNumberOfTouches = 2;
		_panGesture.maximumNumberOfTouches = 2;
		_panGesture.delaysTouchesBegan = YES;
		_panGesture.delegate = self;
		[_webView.scrollView addGestureRecognizer:_panGesture];
	} else {
		[_webView.scrollView removeGestureRecognizer:_panGesture];
	}
}
- (void)twoFingerReload:(UIPanGestureRecognizer*)recognizer{
	static UIPanGestureRecognizerDirection direction = UIPanGestureRecognizerDirectionUndefined;
	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan: {
			if (direction == UIPanGestureRecognizerDirectionUndefined) {
				CGPoint velocity = [recognizer velocityInView:recognizer.view];
				BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
				if (isVerticalGesture) {
					if (velocity.y > 0) {
						direction = UIPanGestureRecognizerDirectionDown;
					} else {
						direction = UIPanGestureRecognizerDirectionUp;
					}
				} else {
					if (velocity.x > 0) {
						direction = UIPanGestureRecognizerDirectionRight;
					} else {
						direction = UIPanGestureRecognizerDirectionLeft;
					}
				}
			}
			break;
		}
		case UIGestureRecognizerStateEnded: {
			if (direction == UIPanGestureRecognizerDirectionDown) {
				[self clearCaches];
				[self reload];
			}
			direction = UIPanGestureRecognizerDirectionUndefined;
			break;
		}
		default:
			break;
	}
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
	if (!_isProgressLoad) [ProgressHUD show:nil];
	if (_delegate && [_delegate respondsToSelector:@selector(OutletDidStartLoad:)]) {
		[_delegate OutletDidStartLoad:self];
	}
	if ([self respondsToSelector:@selector(OutletDidStartLoad)]) {
		[self OutletDidStartLoad];
	}
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
	NSLog(@"%@", error.userInfo);
	if (!_isProgressLoad) [ProgressHUD dismiss];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
	if (!_isProgressLoad) [ProgressHUD dismiss];
	NSString *url = webView.URL.absoluteString; //当前网址
	[webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(id obj, NSError *error) {
		NSString *html = obj; //获取html代码
		if (_delegate && [_delegate respondsToSelector:@selector(OutletDidFinishLoadWith:url:html:)]) {
			[_delegate OutletDidFinishLoadWith:self url:url html:html];
		}
		if ([self respondsToSelector:@selector(OutletDidFinishLoad:html:)]) {
			[self OutletDidFinishLoad:url html:html];
		}
	}];
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
	NSURL *URL = navigationAction.request.URL;
	NSString *url = URL.absoluteString;
	if ([url hasPrefix:@"https://itunes.apple.com"] || [url hasPrefix:@"http://itunes.apple.com"]) {
		[[UIApplication sharedApplication] openURL:navigationAction.request.URL];
		decisionHandler(WKNavigationActionPolicyCancel);
		return;
	}
	if ([[URL scheme] isEqualToString:@"tel"]) {
		decisionHandler(WKNavigationActionPolicyCancel);
		NSString *callPhone = [NSString stringWithFormat:@"tel://%@", [URL resourceSpecifier]];
		dispatch_async(dispatch_get_global_queue(0, 0), ^{ //防止iOS10及其之后，拨打电话系统弹出框延迟出现
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone]];
		});
		return;
	}
	[webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(id obj, NSError *error) {
		NSString *html = obj; //获取html代码
		if (_startLoadUrl) _startLoadUrl(self, url, html);
		if (_delegate && [_delegate respondsToSelector:@selector(OutletStartLoadUrlWith:url:html:)]) {
			BOOL flag = [_delegate OutletStartLoadUrlWith:self url:url html:html];
			if (flag) {
				decisionHandler(WKNavigationActionPolicyAllow);
			} else {
				decisionHandler(WKNavigationActionPolicyCancel);
			}
			return;
		}
		if ([self respondsToSelector:@selector(OutletStartLoadUrl:html:)]) {
			BOOL flag = [self OutletStartLoadUrl:url html:html];
			if (flag) {
				decisionHandler(WKNavigationActionPolicyAllow);
			} else {
				decisionHandler(WKNavigationActionPolicyCancel);
			}
			return;
		}
		decisionHandler(WKNavigationActionPolicyAllow);
	}];
}
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		completionHandler();
	}])];
	[self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		completionHandler(NO);
	}])];
	[alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		completionHandler(YES);
	}])];
	[self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.text = defaultText;
	}];
	[alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		completionHandler(alertController.textFields[0].text?:@"");
	}])];
}
- (void)setUrl:(NSString *)url{
	NSString *weburl = url;
	if ([weburl indexOf:@"sdk="]==NSNotFound) {
		weburl = [NSString stringWithFormat:@"%@%@sdk=%@%@", weburl, ([weburl indexOf:@"?"]!=NSNotFound?@"&":@"?"), SDK_VERSION, API_PARAMETER];
	}
	_url = weburl;
	if (_webView) [_webView loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:_url]]];
}
- (void)reload{
	self.url = _webView.URL.absoluteString;
}
- (void)clearCaches{
	NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
	NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
	NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit", libraryPath];
	NSString *webKitFolderInCaches = [NSString stringWithFormat:@"%@/Caches/%@/WebKit", libraryPath, bundleId];
	NSString *webKitFolderInCachesfs = [NSString stringWithFormat:@"%@/Caches/%@/fsCachedData", libraryPath, bundleId];
	NSString *cookiesFolderPath = [NSString stringWithFormat:@"%@/Cookies", libraryPath];
	[[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCachesfs error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:nil];
}
- (void)OutletDidFinishLoad:(NSString*)url html:(NSString*)html{
	/* Subclasses should override */
}
- (BOOL)OutletStartLoadUrl:(NSString*)url html:(NSString*)html{
	/* Subclasses should override */
	return YES;
}
- (void)OutletDidStartLoad{
	/* Subclasses should override */
}
- (void)OutletViewDidLoad{
	/* Subclasses should override */
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	return YES;
}
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}
@end
