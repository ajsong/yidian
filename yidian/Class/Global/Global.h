//
//  Global.h
//
//  Created by ajsong on 2014-9-1.
//  Copyright (c) 2014 @jsong. All rights reserved.
//
#define SDK_VERSION @"6.0.20160421"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <WebKit/WebKit.h>
#import <objc/message.h>
//Build Setting - Apple LLVM 6.0 - Preprocessing - Enable Strict Checking of objc_msgSend Calls - NO
//message.h 供 if ([target respondsToSelector:action]) objc_msgSend(target, action, arg1, arg2, ...);
#import <objc/runtime.h>
//runtime.h 供 objc_setAssociatedObject, objc_getAssociatedObject, objc_removeAssociatedObjects
//objc_setAssociatedObject(imgView, @"KEY", dictionary, OBJC_ASSOCIATION_RETAIN);
//NSDictionary *dictionary = objc_getAssociatedObject(imgView, @"KEY");
//objc_removeAssociatedObjects(imgView);

#import "SParameter.h"
#import "AFNetworking.h"
#import "CheckNetwork.h"
#import "Common.h"
#import "IQKeyboardManager.h"
#import "KKNavigationController.h"
#import "KKTabBarController.h"
#import "MJPhotoBrowser.h"
#import "MJRefresh.h"
#import "MLSelectPhoto.h"
#import "PagePhotosView.h"
#import "ProgressHUD.h"
#import "QRCodeReaderController.h"
#import "ShareHelper.h"
#import "SUNSlideSwitchView.h"
#import "TMCache.h"

#import "Group+Extend.h"
#import "NSArray+Extend.h"
#import "NSObject+Extend.h"
#import "NSString+Extend.h"
#import "UIImage+Extend.h"
#import "UIView+Extend.h"
#import "UIViewController+Extend.h"

#import "AJActionView.h"
#import "AJCheckbox.h"
#import "AJDatePickerView.h"
#import "AJHeaderView.h"
#import "AJPickerView.h"
#import "AJPopView.h"
#import "AJRatingView.h"
#import "AJTransitionController.h"
#import "AJVerticalTab.h"
#import "AreaPickerView.h"
#import "DrawView.h"
#import "GestureRecognizerImageView.h"
#import "GestureRecognizerLabel.h"
#import "GestureRecognizerView.h"
#import "GFileList.h"
#import "GIFImageView.h"
#import "UITableViewRowAction+JZExtension.h"
#import "MDRadialProgressView.h"
#import "SKPSMTPMessage.h"
#import "SpecialLabel.h"
#import "SpecialTextField.h"
#import "SpecialTextView.h"

//安装统计、跟踪
#import "UMMobClick/MobClick.h"
//快速登录、分享
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocialWechatHandler.h"
#import "WXApi.h"
//消息推送
#import "UMessage.h"
//支付宝
#import <AlipaySDK/AlipaySDK.h>
#import "AlipayResult.h"
#import "Alipay.h"
//微信支付
#import "WechatPay.h"

//腾讯Bugly
#import <Bugly/Bugly.h>

//系统信息
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue] //系统版本
#define IOS6 (IOS_VERSION<7.0) //系统是否iOS6及以下
#define IOS7 (IOS_VERSION>=7.0) //系统是否iOS7及以上
#define IOS8 (IOS_VERSION>=8.0) //系统是否iOS8及以上
#define IOS9 (IOS_VERSION>=9.0) //系统是否iOS8及以上
#define IOS10 (IOS_VERSION>=10.0) //系统是否iOS10及以上
#define iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define isSimulator (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)
#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size)||CGSizeEqualToSize(CGSizeMake(960, 640), [[UIScreen mainScreen] currentMode].size)||CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)||CGSizeEqualToSize(CGSizeMake(1136, 640), [[UIScreen mainScreen] currentMode].size)||CGSizeEqualToSize(CGSizeMake(1536, 2048), [[UIScreen mainScreen] currentMode].size)||CGSizeEqualToSize(CGSizeMake(2048, 1536), [[UIScreen mainScreen] currentMode].size)) : NO)
#define APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] //获取应用名称
#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] //获取应用版本
#define APP_BUILD_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] //获取应用build版本
#define APP_BUNDLE_ID [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] //获取应用bundle_id
#define KEYWINDOW ((UIWindow*)[[UIApplication sharedApplication].windows objectAtIndex:0]) //当前窗口
#define STATUSBAR_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height //状态栏高度
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width //屏幕宽度
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height - (!IOS6?0:STATUSBAR_HEIGHT)) //屏幕高度,不包含状态栏高度
#define SCREEN_ALL_HEIGHT [UIScreen mainScreen].bounds.size.height //屏幕总高度
#define SCREEN_SCALE (SCREEN_HEIGHT>568.0f ? SCREEN_HEIGHT/568.0f : 1.0f) //屏幕高度比例(适配用)
#define APPCurrentController KEYWINDOW.currentController //当前显示的控制器
#define APPCurrentView KEYWINDOW.currentController.view //当前显示的页面

#define STRING(object) [NSString stringWithFormat:@"%@", object]
#define STRINGFORMAT(string, ...) [NSString stringWithFormat:string, ##__VA_ARGS__]
#define INTEGER(string) [string integerValue]
#define FLOAT(string) [string floatValue]
#define MARRAY(array) [NSMutableArray arrayWithArray:array]
#define MDICTIONARY(dictionary) [NSMutableDictionary dictionaryWithDictionary:dictionary]
#define MSARRAY(obj, ...) [NSMutableArray arrayWithObjects:obj, ##__VA_ARGS__, nil]
#define MSDICTIONARY(obj, ...) [NSMutableDictionary dictionaryWithObjectsAndKeys:obj, ##__VA_ARGS__, nil]

#define APPICON_60 IMG(@"AppIcon60x60")
#define FONT(float) [UIFont systemFontOfSize:float]
#define FONTBOLD(float) [UIFont boldSystemFontOfSize:float]
#define COLORRGB(string) [Global colorFromHexRGB:string]
#define COLORRGBA(string, alpha) [Global colorFromHexRGB:string alpha:alpha]
#define FILEPATH(name) [[NSBundle mainBundle] pathForResource:name ofType:nil]
#define IMG(string, ...) [UIImage imageNamed:[NSString stringWithFormat:string, ##__VA_ARGS__]]
#define IMGFORMAT(string, ...) [UIImage imageNamed:[NSString stringWithFormat:string, ##__VA_ARGS__]]
#define IMGFILE(name) [UIImage imageFile:name]
#define IMGFILEFORMAT(string, ...) [UIImage imageFile:[NSString stringWithFormat:string, ##__VA_ARGS__]]

#define CLEAR [UIColor clearColor]
#define WHITE [UIColor whiteColor]
#define BLACK [UIColor blackColor]
#define RED [UIColor colorWithRed:220/255.f green:4/255.f blue:49/255.f alpha:1.f] //dc0431
#define ORANGE [UIColor colorWithRed:235/255.f green:155/255.f blue:0/255.f alpha:1.f] //eb9b00
#define GREEN [UIColor colorWithRed:0/255.f green:190/255.f blue:20/255.f alpha:1.f] //00be14
#define BLUE [UIColor colorWithRed:0/255.f green:149/255.f blue:217/255.f alpha:1.f] //0095d9
#define YELLOW [UIColor colorWithRed:255/255.f green:199/255.f blue:0/255.f alpha:1.f] //ffc700
#define PINK [UIColor colorWithRed:240/255.f green:96/255.f blue:165/255.f alpha:1.f] //f060a5
#define PURPLE [UIColor colorWithRed:163/255.f green:93/255.f blue:181/255.f alpha:1.f] //a35db5
#define SYSTEM_BLUE [UIColor colorWithRed:0/255.f green:122/255.f blue:255/255.f alpha:1.f] //007aff
#define COLOR_GE [UIColor colorWithRed:199/255.f green:199/255.f blue:199/255.f alpha:1.f] //c7c7c7
#define COLOR_GE_LIGHT [UIColor colorWithRed:234/255.f green:234/255.f blue:234/255.f alpha:1.f] //eaeaea
#define COLOR_PLACEHOLDER [UIColor colorWithRed:199/255.f green:199/255.f blue:199/255.f alpha:1.f] //c7c7c7
#define COLORCCC [UIColor colorWithRed:204/255.f green:204/255.f blue:204/255.f alpha:1.f] //ccc
#define COLOR999 [UIColor colorWithRed:153/255.f green:153/255.f blue:153/255.f alpha:1.f] //999
#define COLOR777 [UIColor colorWithRed:119/255.f green:119/255.f blue:119/255.f alpha:1.f] //777
#define COLOR666 [UIColor colorWithRed:102/255.f green:102/255.f blue:102/255.f alpha:1.f] //666
#define COLOR333 [UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:1.f] //333

#define GlobalQueue(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define MainQueue(block) dispatch_async(dispatch_get_main_queue(),block)
#define NLog(FORMAT, ...) fprintf(stderr, "function: %s\nline:%d\n%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#define VIEWWITHTAG(_OBJECT, _TAG) [_OBJECT viewWithTag:_TAG] //根据TAG获取对象
#define LocalString(x, ...) NSLocalizedString(x, nil) //引用国际化的文件
#define degreesToRadian(x) (M_PI * (x) / 180.0) //角度获取弧度
#define radianToDegrees(radian) ((radian*180.0)/(M_PI)) //弧度获取角度

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
#define kCGImageAlphaPremultipliedLast (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast)
#else
#define kCGImageAlphaPremultipliedLast kCGImageAlphaPremultipliedLast
#endif
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
//#if TARGET_OS_IPHONE
//#if TARGET_IPHONE_SIMULATOR

//忽略警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable" //含有没有被使用的变量
//#pragma clang diagnostic ignored "-Wincompatible-pointer-types" //指针类型不匹配

#define DOWNLOAD_TIMEOUT 7 //下载超时
#define NAVBAR_HIDDEN_UNDERLINE YES //隐藏导航底部线条

//使用屏幕比例创建CGRect
CG_INLINE CGRect
CGRectMakeScale(CGFloat x, CGFloat y, CGFloat width, CGFloat height){
	CGFloat scaleSizeX = 1.0f;
	CGFloat scaleSizeY = 1.0f;
	if (SCREEN_HEIGHT > 480) {
		scaleSizeX = SCREEN_WIDTH / 320;
		scaleSizeY = SCREEN_HEIGHT / 568;
	}
	CGRect rect;
	rect.origin.x = x * scaleSizeX;
	rect.origin.y = y * scaleSizeY;
	rect.size.width = width * scaleSizeX;
	rect.size.height = height * scaleSizeY;
	return rect;
}

@interface Global : NSObject
@property (atomic,strong) NSCache *cacheObject;

#pragma mark - 系统
+ (UIViewController*)currentController;
+ (BOOL)verticalScreen:(UIViewController*)view;
+ (BOOL)isNewVersion;
+ (NSString*)deviceString;
+ (NSString*)device;
+ (NSString*)getTelephonyNumber;
+ (void)copyString:(NSString*)string;
+ (id)getUserDefaults:(NSString*)key;
+ (NSString*)getUserDefaultsString:(NSString*)key;
+ (NSInteger)getUserDefaultsInteger:(NSString*)key;
+ (CGFloat)getUserDefaultsFloat:(NSString*)key;
+ (BOOL)getUserDefaultsBool:(NSString*)key;
+ (NSMutableArray*)getUserDefaultsArray:(NSString*)key;
+ (NSMutableDictionary*)getUserDefaultsDictionary:(NSString*)key;
+ (void)setUserDefaults:(NSString*)key data:(id)data;
+ (void)deleteUserDefaults:(NSString*)key;

#pragma mark - 类型检测
+ (BOOL)isInt:(NSString*)string;
+ (BOOL)isFloat:(NSString*)string;
+ (BOOL)isArray:(id)data;
+ (BOOL)isDictionary:(id)data;
+ (BOOL)isDate:(NSString*)string;
+ (NSInteger)inArray:(NSArray*)array object:(id)object;
+ (NSString*)inDictionary:(NSDictionary*)dictionary object:(id)object;
+ (BOOL)isJailbroken;
+ (BOOL)hasString:(NSString*)string;

#pragma mark - 导航
+ (UIView*)statusBar;
+ (CGFloat)statusBarHeight;
+ (void)statusBarHidden:(BOOL)hidden animated:(BOOL)animated;
+ (void)statusBarStyle:(UIStatusBarStyle)style animated:(BOOL)animated;
+ (CGFloat)navigationAndStatusBarHeight;
+ (CGFloat)navigationHeight;
+ (void)navigationBackgroundColor:(UIColor*)bgcolor textcolor:(UIColor*)textcolor;
+ (void)navigationBackgroundColor:(UIColor *)bgcolor textcolor:(UIColor *)textcolor controller:(UIViewController*)controller;
+ (void)navigationBackgroundImage:(UIImage*)image;
+ (void)navigationTranslucent;

#pragma mark - 颜色
+ (UIColor*)colorFromHexRGB:(NSString*)colorString;
+ (UIColor*)colorFromHexRGB:(NSString*)colorString alpha:(CGFloat)alpha;
+ (NSString*)stringOfColor:(UIColor*)color;
+ (UIColor*)colorFromImage:(UIImage*)img;
+ (UIColor*)colorFromImage:(UIImage*)img size:(CGSize)size;
+ (UIImage*)imageFromColor:(UIColor*)color size:(CGSize)size;
+ (UIColor*)randomColor;
+ (UIColor*)lighterColor:(UIColor*)color;
+ (UIColor*)darkerColor:(UIColor*)color;
+ (UIColor*)colorBetweenColor1:(UIColor*)color1 color2:(UIColor*)color2 percent:(CGFloat)percent;
+ (UIImage*)gradientColors:(NSArray*)colors gradientType:(NSInteger)gradientType inView:(UIView*)view;

#pragma mark - 图片
+ (UIImage*)decodeImage:(UIImage*)image;
+ (NSData*)imageToData:(UIImage*)image;
+ (NSString*)imageSuffix:(NSData*)data;
+ (UIImage*)fitToSize:(UIImage*)image size:(CGSize)size;
+ (UIImage*)fitToSize:(UIImage*)image size:(CGSize)size fix:(CGFloat)fix;
+ (UIImage*)maskingImage:(UIImage*)image colorArray:(NSArray*)color;
+ (void)saveImageToPhotos:(UIImage*)image;
+ (void)saveToAlbumWithImage:(UIImage*)image completion:(void (^)(BOOL success))completion;
+ (void)saveImageToDocument:(UIImage*)image withName:(NSString*)imageName;
+ (void)saveImageToTmp:(UIImage*)image withName:(NSString*)imageName;
+ (UIImage*)getImage:(NSString*)imageName;
+ (UIImage*)getImageFromDocument:(NSString*)imageName;
+ (UIImage*)getImageFromTmp:(NSString*)imageName;
+ (UIImage*)croppedImage:(UIImage*)image inRect:(CGRect)bounds;
+ (UIImage*)imageWithView:(UIView*)view frame:(CGRect)frame;
+ (UIImage*)blurImageWith:(UIImage*)image radius:(CGFloat)blurRadius tintColor:(UIColor*)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor;
+ (UIImage*)mergeImage:(UIImage*)baseImage smallImage:(UIImage*)smallImage point:(CGPoint)point;
+ (UIImage*)rotatedImage:(UIImage*)image degrees:(CGFloat)degrees;
+ (UIImage*)rotatedImage:(UIImage*)image rotate:(CGFloat)rotate;
+ (UIImage*)grayImage:(UIImage*)image;
+ (void)animateImage:(UIImageView*)imageView duration:(NSTimeInterval)time repeat:(NSInteger)repeat images:(UIImage*)image,...;

#pragma mark - FSO
+ (NSString*)getFileFullname:(NSString*)filePath;
+ (NSString*)getFilename:(NSString*)filePath;
+ (NSString*)getSuffix:(NSString*)filePath;
+ (NSString*)getDocument;
+ (NSString*)getTmp;
+ (NSString*)getCaches;
+ (NSString*)getFilePathFromDocument:(NSString*)filename;
+ (NSString*)getFilePathFromTmp:(NSString*)filename;
+ (NSString*)getFilePathFromCaches:(NSString*)filename;
+ (NSString*)getFilePathFromAPP:(NSString*)filename;
+ (NSData*)getFileData:(NSString*)filePath;
+ (NSData*)getFileDataFromDocument:(NSString*)filename;
+ (NSData*)getFileDataFromTmp:(NSString*)filename;
+ (NSData*)getFileDataFromCaches:(NSString*)filename;
+ (NSString*)getFileText:(NSString*)filePath;
+ (NSString*)getFileTextFromDocument:(NSString*)filename;
+ (NSString*)getFileTextFromTmp:(NSString*)filename;
+ (NSString*)getFileTextFromCaches:(NSString*)filename;
+ (NSArray*)getFileList:(NSString*)folderPath;
+ (NSArray*)getFileListFromDocument;
+ (NSArray*)getFileListFromTmp;
+ (NSArray*)getFileListFromCaches;
+ (BOOL)fileExist:(NSString*)filePath;
+ (BOOL)fileExistFromDocument:(NSString*)filename;
+ (BOOL)fileExistFromTmp:(NSString*)filename;
+ (BOOL)fileExistFromCaches:(NSString*)filename;
+ (BOOL)fileExistFromAPP:(NSString*)filename;
+ (BOOL)folderExist:(NSString*)folderPath;
+ (BOOL)makeDir:(NSString*)folderPath;
+ (BOOL)makeDirFromDocument:(NSString*)foldername;
+ (BOOL)makeDirFromTmp:(NSString*)foldername;
+ (BOOL)makeDirFromCaches:(NSString*)foldername;
+ (void)deleteDir:(NSString*)folderPath killme:(BOOL)kill;
+ (void)deleteDirFromDocument:(NSString*)foldername killme:(BOOL)kill;
+ (void)deleteDirFromTmp:(NSString*)foldername killme:(BOOL)kill;
+ (void)deleteDirFromCaches:(NSString*)foldername killme:(BOOL)kill;
+ (BOOL)saveFile:(NSString*)filePath data:(NSData*)fileData;
+ (BOOL)saveFileToDocument:(NSString*)filename data:(NSData*)fileData;
+ (BOOL)saveFileToTmp:(NSString*)filename data:(NSData*)fileData;
+ (BOOL)saveFileToCaches:(NSString*)filename data:(NSData*)fileData;
+ (BOOL)saveFile:(NSString*)filePath content:(NSString*)content new:(BOOL)flag;
+ (BOOL)saveFileToDocument:(NSString*)filename content:(NSString*)content new:(BOOL)flag;
+ (BOOL)saveFileToTmp:(NSString*)filename content:(NSString*)content new:(BOOL)flag;
+ (BOOL)saveFileToCaches:(NSString*)filename content:(NSString*)content new:(BOOL)flag;
+ (void)renameFolder:(NSString*)folderPath to:(NSString*)newName;
+ (void)renameFile:(NSString*)filePath to:(NSString*)newName;
+ (BOOL)deleteFile:(NSString*)filePath;
+ (BOOL)deleteFileFromDocument:(NSString*)filename;
+ (BOOL)deleteFileFromTmp:(NSString*)filename;
+ (BOOL)deleteFileFromCaches:(NSString*)filename;
+ (long long)fileSize:(NSString*)filePath;
+ (long long)folderSize:(NSString*)folderPath;
+ (NSString*)formatSize:(long long)size unit:(NSString*)unit;
+ (NSMutableDictionary*)fileAttributes:(NSString*)filePath;
+ (NSMutableArray*)getPlistArray:(NSString*)filename;
+ (NSMutableDictionary*)getPlistDictionary:(NSString*)filename;
+ (NSMutableArray*)getPlistArrayFromTmp:(NSString*)filename;
+ (NSMutableDictionary*)getPlistDictionaryFromTmp:(NSString*)filename;
+ (BOOL)savePlist:(NSString*)filePath data:(id)data;
+ (BOOL)savePlistToDocument:(NSString*)filename data:(id)data;
+ (BOOL)savePlistToTmp:(NSString*)filename data:(id)data;
+ (BOOL)savePlistToCaches:(NSString*)filename data:(id)data;

#pragma mark - 字符串
+ (CGSize)autoWidth:(NSString*)str font:(UIFont*)font height:(CGFloat)height;
+ (CGSize)autoHeight:(NSString*)str font:(UIFont*)font width:(CGFloat)width;
+ (void)minFontSizeWith:(UILabel*)label minScale:(CGFloat)scale;
+ (NSString*)strtolower:(NSString*)str;
+ (NSString*)strtoupper:(NSString*)str;
+ (NSString*)strtoupperFirst:(NSString*)str;
+ (NSString*)trim:(NSString*)string;
+ (NSString*)trim:(NSString*)string assign:(NSString*)assign;
+ (NSInteger)indexOf:(NSString*)origin search:(NSString*)str;
+ (NSString*)replace:(NSString*)r1 to:(NSString*)r2 from:(NSString*)original;
+ (NSString*)substr:(NSString*)string start:(NSUInteger)start length:(NSUInteger)length;
+ (NSString*)substr:(NSString*)string start:(NSUInteger)start;
+ (NSString*)left:(NSString*)string length:(NSUInteger)length;
+ (NSString*)right:(NSString*)string length:(NSUInteger)length;
+ (NSString*)fillZero:(NSInteger)integer length:(NSInteger)length;
+ (NSInteger)fontLength:(NSString*)str;
+ (NSString*)cropHtml:(NSString*)webHtml startStr:(NSString*)startStr overStr:(NSString*)overStr;
+ (NSString*)deleteStringPart:(NSString*)string prefix:(NSString*)prefix suffix:(NSString*)suffix;
+ (BOOL)isEmoji:(NSString*)string;
+ (NSString*)URLEncode:(NSString*)string;
+ (NSString*)URLEncode:(NSString*)string encoding:(NSStringEncoding)encoding;
+ (NSString*)URLDecode:(NSString*)string;
+ (NSString*)URLDecode:(NSString*)string encoding:(NSStringEncoding)encoding;
+ (NSString*)stringToBase64:(NSString*)string;
+ (NSString*)dataToBase64:(NSData*)data;
+ (NSString*)base64ToString:(NSString*)base64;
+ (NSData*)base64ToData:(NSString*)string;
+ (NSString*)stringToMD5:(NSString*)string;
+ (NSString*)stringToSHA1:(NSString*)string;

#pragma mark - 数组
+ (NSMutableArray*)split:(NSString*)string with:(NSString*)symbol;
+ (NSString*)implode:(NSArray*)array with:(NSString*)symbol;

#pragma mark - 正则表达式
+ (BOOL)preg_test:(NSString*)string patton:(NSString*)patton;
+ (NSString*)preg_replace:(NSString*)string patton:(NSString*)patton with:(NSString*)templateStr;
+ (NSMutableArray*)preg_match:(NSString*)string patton:(NSString*)patton;
+ (BOOL)isEmail:(NSString*)string;
+ (BOOL)isMobile:(NSString*)string;

#pragma mark - JSON
+ (id)formatJson:(NSString*)jsonString;
+ (NSString*)jsonString:(id)data;

#pragma mark - NETWORK
+ (void)get:(NSString*)url;
+ (void)get:(NSString*)url data:(NSDictionary*)data completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)post:(NSString*)url data:(NSDictionary*)data completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)upload:(NSString*)url data:(NSDictionary*)data completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)postAuto:(NSString*)url data:(NSDictionary*)data completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)postAuto:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)get:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)post:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)postJSON:(NSString*)url data:(id)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)post:(NSString*)url data:(id)data type:(NSString*)type timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)upload:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)downloadImage:(NSString*)url completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist))completion;
+ (void)downloadImage:(NSString*)url size:(CGSize)size completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist))completion;
+ (void)downloadImageToPath:(NSString*)savePath url:(NSString*)url completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist))completion;
+ (void)cacheImageWithUrl:(NSString*)url completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion;
+ (void)cacheToImageView:(UIImageView*)imageView url:(NSString*)url placeholder:(id)placeholder completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion;
+ (void)cacheToImageView:(UIImageView*)imageView url:(NSString*)url placeholder:(id)placeholder completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion animate:(void (^)(UIImageView *imageView, BOOL isCache))animate;
+ (void)download:(NSString*)url completion:(void (^)(NSString *fileName, NSData *fileData, BOOL exist))completion;

#pragma mark - 日期
+ (NSString*)now;
+ (NSDate*)nowDate;
+ (NSDate*)localDate:(NSDate*)date;
+ (NSTimeInterval)unix;
+ (NSTimeInterval)unixFromDate:(id)dt;
+ (NSDate*)dateFromUnix:(NSTimeInterval)unix;
+ (NSDate*)dateFromString:(NSString*)str;
+ (NSString*)formatDate:(id)dt;
+ (NSString*)formatDate:(id)dt format:(NSString*)str;
+ (NSString*)formatDateTime:(id)dt;
+ (NSString*)formatTime:(id)dt;
+ (NSInteger)getYear:(NSDate*)date;
+ (NSInteger)getMonth:(NSDate*)date;
+ (NSInteger)getDay:(NSDate*)date;
+ (NSInteger)getHour:(NSDate*)date;
+ (NSInteger)getMinute:(NSDate*)date;
+ (NSInteger)getSecond:(NSDate*)date;
+ (NSTimeInterval)oneDay;
+ (NSTimeInterval)oneWeek;
+ (NSTimeInterval)oneMonth;
+ (NSTimeInterval)oneMonth:(NSInteger)days;
+ (NSTimeInterval)oneYear;
+ (NSInteger)getDateOffset:(NSInteger)delay range:(NSString*)range;
+ (NSDate*)dateAdd:(NSString*)range interval:(NSInteger)number date:(id)dt;
+ (NSInteger)dateDiff:(NSString*)range earlyDate:(id)earlyDate lateDate:(id)lateDate;
+ (NSArray*)getWeeksBeginAndEnd:(id)dt;
+ (NSInteger)getWeek:(id)dt;
+ (NSString*)datetimeAndRandom;

#pragma mark - UI操作
+ (id)cloneView:(UIView*)view;
+ (UILabel*)multiLine:(CGRect)frame string:(NSString*)string font:(UIFont*)font;
+ (UILabel*)multiLine:(CGRect)frame string:(NSString*)string font:(UIFont*)font lineheight:(CGFloat)linespace;
+ (void)zoomView:(UIView*)view;
+ (void)zoomView:(UIView*)view duration:(CGFloat)duration percent:(CGFloat)percent;
+ (void)moveView:(UIView*)view to:(CGRect)frame time:(CGFloat)time;
+ (void)throwView:(UIView*)view endpoint:(CGPoint)endpoint completion:(void (^)())completion;
+ (void)opacityOutIn:(UIView*)view duration:(CGFloat)duration afterHidden:(void (^)())afterHidden completion:(void (^)())completion;
+ (void)transformScreen:(UIViewController*)view;
+ (void)transformScreen:(UIViewController*)view orientation:(NSString*)orientation;
+ (void)scaleView:(UIView*)view percent:(CGFloat)percent;
+ (void)scaleAnimate:(UIView*)view time:(NSTimeInterval)time percent:(CGFloat)percent completion:(void (^)())completion;
+ (void)scaleAnimateBounces:(UIView*)view time:(NSTimeInterval)time percent:(CGFloat)percent completion:(void (^)())completion;
+ (void)scaleAnimateBounces:(UIView*)view time:(NSTimeInterval)time percent:(CGFloat)percent bounce:(CGFloat)bounce completion:(void (^)())completion;
+ (void)rotatedView:(UIView*)view degrees:(CGFloat)degrees;
+ (void)rotatedView:(UIView*)view degrees:(CGFloat)degrees center:(CGPoint)center;
+ (void)rotateAnimate:(UIView*)view time:(NSTimeInterval)time degrees:(CGFloat)degrees completion:(void (^)())completion;
+ (void)rotateAnimate:(UIView*)view time:(NSTimeInterval)time degrees:(CGFloat)degrees center:(CGPoint)center completion:(void (^)())completion;
+ (void)rotate3DAnimate:(UIView*)view delegate:(NSObject*)delegate;
+ (CAAnimation*)rotate3DAnimate;
+ (void)pageCurlAnimation:(UIView*)view time:(NSTimeInterval)time delegate:(NSObject*)delegate;
+ (CGRect)autoXYWithCellCount:(NSInteger)count width:(CGFloat)w height:(CGFloat)h blank:(CGFloat)b marginTop:(CGFloat)t marginLeft:(CGFloat)l uIndex:(NSNumber**)u vIndex:(NSNumber**)v;
+ (CGRect)autoXYInWidth:(CGFloat)width subview:(UIView*)subview marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r prevRight:(NSNumber**)pr prevBottom:(NSNumber**)pb;
+ (CGRect)autoXYInWidth:(CGFloat)width subview:(UIView*)subview frame:(CGRect)subviewFrame marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r prevRight:(NSNumber**)pr prevBottom:(NSNumber**)pb;
+ (void)autoLayoutWithView:(UIView*)view subviews:(NSMutableArray*)subviews marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r;
+ (void)showMenuControllerWithTarget:(UIView*)target titles:(NSArray*)titles actions:(NSArray*)actions;

#pragma mark - 其他
+ (NSString*)getIP;
+ (CGSize)fitToSize:(CGSize)size originSize:(CGSize)origin;
+ (CGSize)fitToSize:(CGSize)size originSize:(CGSize)origin fix:(CGFloat)fix;
+ (void)openCall:(NSString*)tel;
+ (void)openSms:(NSString*)tel;
+ (void)openQQ:(NSString*)uin;
+ (void)openWechat:(NSString*)uin;
+ (void)alert:(NSString*)message;
+ (void)alert:(NSString*)message delegate:(NSObject*)delegate;
+ (void)alert:(NSString*)message block:(void(^)(NSInteger buttonIndex))block;
+ (UILabel*)createMarkWithFrame:(CGRect)frame font:(UIFont*)font;
+ (void)updateMark:(UILabel*)mark text:(NSString*)text;
+ (NSInteger)randomFrom:(NSInteger)from to:(NSInteger)to;
+ (double)randomFloatFrom:(double)from to:(double)to;
+ (NSString*)randomString:(NSInteger)length;
+ (NSInteger)getMoveDirectionWithTranslation:(CGPoint)translation direction:(NSInteger)direction;
+ (void)repeatDo:(NSTimeInterval)delay function:(void (^)())function;
+ (BOOL)isNetwork:(BOOL)showMsg;
+ (void)GFileList:(NSString*)folderPath;
+ (void)showLocalNotification:(NSString*)body;
+ (void)notificationRegisterWithObserver:(id)observer selector:(SEL)selector name:(NSString*)name object:(id)object;
+ (void)notificationPostWithName:(NSString*)name object:(id)object;
+ (void)notificationRemoveObserver:(id)observer;
+ (void)removeCache;
+ (void)playVoice:(NSString*)voicePath;
+ (void)touchIDWithReason:(NSString*)reason passwordTitle:(NSString*)passwordTitle success:(void (^)())successBlock fail:(void (^)(NSError *error))fail nosupport:(void (^)())nosupport;

#pragma mark - 本类
#define GlobalShared [Global shared]
#define getValue(key) [GlobalShared getValue:key]
#define setValue(key, value) [GlobalShared setValue:value key:key]
+ (Global*)shared;
- (id)getValue:(NSString*)key;
- (NSMutableDictionary*)allValues;
- (NSMutableDictionary*)setValue:(id)value key:(NSString*)key;
- (NSMutableDictionary*)setValues:(NSArray*)values keys:(NSArray*)keys;
- (NSMutableDictionary*)removeAllValues;
+ (id)cacheObjectForKey:(id)key;
+ (void)setCacheObject:(id)obj forKey:(id)key;
+ (void)removeAllCacheObjects;
+ (void)removeCacheObjectForKey:(id)key;

@end
