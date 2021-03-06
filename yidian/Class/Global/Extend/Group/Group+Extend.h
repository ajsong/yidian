//
//  Group+Extend.h
//
//  Created by ajsong on 15/10/9.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"

#pragma mark - UINavigationController+UITabBarController+Extend
@interface UINavigationController (GlobalExtend)
- (void)setBackgroundColor:(UIColor *)bgcolor textColor:(UIColor *)textcolor;
- (void)autoHidden;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)())completion;
- (UIViewController*)popToViewControllerOfClass:(Class)cls animated:(BOOL)animated;
- (UIViewController*)popToViewControllerOfClass:(Class)cls animated:(BOOL)animated completion:(void (^)())completion;
@end
@interface UITabBarController (GlobalExtend)
@end


#pragma mark - NSTimer+Extend
@interface NSTimer (GlobalExtend)
+ (NSTimer*)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;
+ (NSTimer*)timerWithTimeInterval:(NSTimeInterval)inTimeInterval repeats:(BOOL)inRepeats block:(void (^)())inBlock;
+ (void)executeSimpleBlock:(NSTimer*)inTimer;
- (void)pause;
- (void)resume;
- (void)stop;
@end


#pragma mark - UIAlertView+Extend
@interface UIAlertView (GlobalExtend)<UIAlertViewDelegate>
+ (void)alert:(NSString*)message;
+ (void)alert:(NSString*)message block:(void(^)(NSInteger buttonIndex))block;
+ (void)alert:(NSString*)message submit:(NSString*)submit block:(void(^)(NSInteger buttonIndex))block;
- (void)showWithBlock:(void(^)(NSInteger buttonIndex))block;
@end


#pragma mark - UIActionSheet+Extend
@interface UIActionSheet (GlobalExtend)<UIActionSheetDelegate>
- (void)showInView:(UIView *)view withBlock:(void(^)(NSInteger buttonIndex))block;
@end


#pragma mark - UIControl+Extend
@interface UIControl (GlobalExtend)
- (void)addControlEvent:(UIControlEvents)event withBlock:(void(^)(id sender))block;
- (void)removeControlEvent:(UIControlEvents)event;
@end


#pragma mark - NSData+Extend
@interface NSData (GlobalExtend)
- (BOOL)isImage;
- (BOOL)isGIF;
- (UIImage*)gif;
- (NSString*)base64;
- (NSString*)imageSuffix;
- (NSString*)imageMimeType;
- (void)UploadToUpyun:(NSString*)upyunFolder completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion;
- (void)UploadToUpyun:(NSString*)upyunFolder imageName:(NSString*)imageName completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion;
@end


#pragma mark - UILabel+Extend
@interface UILabel (GlobalExtend)
- (void)autoWidth;
- (void)autoHeight;
@end


#pragma mark - UISearchBar+Extend
@interface UISearchBar (GlobalExtend)
- (UIColor*)textColor;
- (void)setTextColor:(UIColor*)textColor;
- (UIColor*)placeholderColor;
- (void)setPlaceholderColor:(UIColor*)placeholderColor;
@end


#pragma mark - UIColor+Extend
@interface UIColor (GlobalExtend)
- (CGFloat)alpha;
- (UIColor*)setAlpha:(CGFloat)alpha;
- (NSString*)string;
@end


#pragma mark - UIWindow+Extend
@interface UIWindow (GlobalExtend)
- (UIViewController*)currentController;
- (UIView*)statusBar;
- (CGFloat)statusBarHeight;
@end


#pragma mark - NSMutableDictionary+Extend
@interface NSDictionary (GlobalExtend)
- (NSDictionary*)merge:(NSDictionary*)dictionary;
- (NSString*)hasChild:(id)object;
- (NSString*)descriptionASCII;
- (NSDictionary*)compatible;
- (NSDictionary*)UpyunSuffix:(NSString*)suffix forKeys:(NSArray*)keys;
@end
@interface NSMutableDictionary (GlobalExtend)
- (NSMutableDictionary*)merge:(NSDictionary*)dictionary;
- (NSString*)hasChild:(id)object;
- (NSString*)descriptionASCII;
- (NSMutableDictionary*)compatible;
- (NSMutableDictionary*)UpyunSuffix:(NSString*)suffix forKeys:(NSArray*)keys;
@end


#pragma mark - FileDownloader
@interface FileDownloader : NSObject
@property (nonatomic,retain) NSString *url;
@property (nonatomic,assign) NSTimeInterval timeout;
@property (nonatomic,copy) void (^progress)(double progress, long dataSize, long long currentSize, long long totalSize);
@property (nonatomic,copy) void (^completion)(NSData *data, BOOL exist);
@property (nonatomic,copy) void (^fail)(NSString *description, NSInteger code);
+ (FileDownloader*)downloadWithUrl:(NSString*)url completion:(void(^)(NSData *data, BOOL exist))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (FileDownloader*)downloadWithUrl:(NSString*)url timeout:(NSTimeInterval)timeout progress:(void(^)(double progress, long dataSize, long long currentSize, long long totalSize))progress completion:(void(^)(NSData *data, BOOL exist))completion fail:(void (^)(NSString *description, NSInteger code))fail;
- (void)start;
- (void)pause;
- (void)stop;
@end


#pragma mark - One Finger Rotation
@interface OneFingerRotationGestureRecognizer : UIGestureRecognizer
@property (nonatomic,assign) CGFloat rotation;
@end


#pragma mark - QueueHandle
/*
QueueHandle *queue = [[QueueHandle alloc]init];
for (int i=0; i<5; i++) {
	[queue queueHandleBlock:^{
		CGRect frame = _btn.frame;
		frame.origin.y -= 30;
		[UIView animateWithDuration:1.0 animations:^{
			_btn.frame = frame;
		} completion:^(BOOL finished) {
			[queue completionBlock:nil];
		}];
	}];
}
*/
@interface QueueHandle : NSObject
- (void)queueHandleBlock:(void (^)(void))operate;
- (void)completionBlock:(void (^)(void))completion;
@end


#pragma mark - ToastView
@interface ToastView : NSObject{
	UIToolbar *_toastView;
}
+ (ToastView*)toastShare;
+ (void)content:(NSString*)content target:(id)target action:(SEL)action;
+ (void)content:(NSString*)content target:(id)target action:(SEL)action withObject:(id)anArgument;
+ (void)content:(NSString*)content time:(NSTimeInterval)time target:(id)target action:(SEL)action;
+ (void)content:(NSString*)content time:(NSTimeInterval)time target:(id)target action:(SEL)action withObject:(id)anArgument;
@end


#pragma mark - SimpleSwitchView
@class SimpleSwitchView;
@protocol SimpleSwitchViewDelegate<NSObject>
@optional
- (void)SimpleSwitchView:(SimpleSwitchView*)switchView didSelectAtIndex:(NSInteger)index value:(id)value;
@end
@interface SimpleSwitchView : UIView
@property (nonatomic,weak) id<SimpleSwitchViewDelegate> delegate;
@property (nonatomic,strong) NSArray *nameArray; //?????????????????????
@property (nonatomic,strong) NSArray *valueArray; //???????????????????????????
@property (nonatomic,strong) UIColor *textColor; //??????????????????
@property (nonatomic,strong) UIColor *bgColor; //???????????????
@property (nonatomic,strong) UIColor *selectedTextColor; //?????????????????????
@property (nonatomic,strong) UIColor *selectedBgColor; //??????????????????
@property (nonatomic,strong) UIFont *font; //??????
@property (nonatomic,strong) UIScrollView *scrollView; //??????????????????????????????
@property (nonatomic,assign) BOOL hiddenGeLine; //???????????????
@property (nonatomic,assign) CGFloat padding; //????????????????????????????????????
@property (nonatomic,assign) NSInteger index; //???????????????
@end


#pragma mark - AJWebView
@interface AJWebView : WKWebView
@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic,strong) UIFont *font;
@property (nonatomic,assign) UIEdgeInsets padding;
@property (nonatomic,strong) NSString *style;
@property (nonatomic,strong) NSString *script;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *html;
- (void)autoHeightWithHtml:(NSString *)html finishLoad:(void (^)(AJWebView *webView))finishLoad;
- (void)didFinishLoad:(void (^)(NSString *html))finishLoad; //?????????????????????
@end


#pragma mark - Outlet WebView
@class outlet;
@protocol OutletDelegate<NSObject>
@optional
- (void)OutletDidStartLoad:(outlet*)controller;
- (void)OutletLoadViewWith:(outlet*)controller; //?????????????????????
- (void)OutletDidFinishLoadWith:(outlet*)controller url:(NSString*)url html:(NSString*)html; //????????????????????????
- (BOOL)OutletStartLoadUrlWith:(outlet*)controller url:(NSString*)url html:(NSString*)html; //??????????????????????????????, ??????NO:???????????????
@end
@interface outlet : UIViewController<WKNavigationDelegate,WKUIDelegate>
@property (nonatomic,copy) void(^viewWillAppear)(); //????????????????????????
@property (nonatomic,copy) void(^viewWillDisappear)(); //????????????????????????
@property (nonatomic,strong) id<OutletDelegate> delegate;
@property (nonatomic,assign) NSInteger tag;
@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) NSString *url; //????????????
@property (nonatomic,strong) NSString *userAgentMark; //???????????????, ??????????????????ruandao
@property (nonatomic,assign) BOOL isWebGoBack; //????????????????????????
@property (nonatomic,assign) BOOL isFullscreen; //????????????
@property (nonatomic,assign) BOOL isTwoFingerReload; //????????????????????????, ??????YES
@property (nonatomic,strong) UIImage *leftImage; //???????????????????????????
@property (nonatomic,copy) void(^leftBlock)(); //?????????????????????
@property (nonatomic,strong) NSString *rightText; //?????????????????????, !isFullscreen ??????
@property (nonatomic,strong) UIImage *rightImage; //?????????????????????
@property (nonatomic,strong) UIView *rightView; //????????????????????????, !isFullscreen ??????
@property (nonatomic,copy) void(^rightBlock)(); //?????????????????????
@property (nonatomic,strong) void(^startLoadUrl)(outlet *vc, NSString *url, NSString *html); //??????????????????
@property (nonatomic,assign) BOOL statusBarBlack; //????????????????????????
@property (nonatomic,assign) BOOL statusBarHidden; //???????????????
@property (nonatomic,strong) CALayer *progressLayer;
@property (nonatomic,assign) BOOL isProgressLoad; //?????????????????????????????????
- (void)reload;
- (void)clearCaches;
- (void)OutletDidStartLoad;
- (void)OutletViewDidLoad;
- (void)OutletDidFinishLoad:(NSString*)url html:(NSString*)html;
- (BOOL)OutletStartLoadUrl:(NSString*)url html:(NSString*)html;
@end
