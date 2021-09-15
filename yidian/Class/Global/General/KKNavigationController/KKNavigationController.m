//
//  KKNavigationController.m
//
//  Created by Coneboy_K on 13-12-2.
//  Copyright (c) 2013年 Coneboy_K. All rights reserved.  MIT
//  WELCOME TO MY BLOG  http://www.coneboy.com
//

#import <QuartzCore/QuartzCore.h>
#import <math.h>
#import "KKNavigationController.h"
#import "ProgressHUD.h"
#import <objc/runtime.h>

#define startX -200; //背景视图起始frame.x

NSString * const KKNavigationController_gestureRecognizer = @"__KKNavigationController_gestureRecognizer";

@interface KKNavigationController()<UIGestureRecognizerDelegate>{
	UIImageView *_shadowImageView;
	UIView *_backgroundView;
	CGFloat _startBackViewX;
	CGPoint _startTouch;
	UIImageView *_lastScreenShotView;
	UIView *_blackMask;
	UIImage *_captureImage;
	NSMutableArray *_screenShotsList;
	BOOL _isGesture;
	BOOL _isMoving;
	BOOL _originTranslucent;
	UIColor *_originBarTintColor;
}
@end

@implementation KKNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController{
	self = [super initWithRootViewController:rootViewController];
	if (self) {
		_navigationKKDelegate = (id<KKNavigationControllerDelegate>)rootViewController;
		_screenShotsList = [[NSMutableArray alloc]init];
		_enableDragBack = YES;
		_useShadow = NO;
		_useOverlayer = YES;
		_hiddenBackText = YES;
	}
	return self;
}

- (void)dealloc{
	_screenShotsList = nil;
	[_backgroundView removeFromSuperview];
	_backgroundView = nil;
	self.navigationBarView = nil;
}

- (void)viewDidLoad{
	[super viewDidLoad];
	[self performSelector:@selector(loadViews) withObject:nil afterDelay:0];
}

- (void)loadViews{
	if (_enableSystemBack) return;
	if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
		self.interactivePopGestureRecognizer.enabled = NO;
	}
	_shadowImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"kknavigation_shadow"]];
	_shadowImageView.frame = CGRectMake(-10, 0, 10, self.view.frame.size.height);
	_shadowImageView.hidden = !_useShadow;
	[self.view addSubview:_shadowImageView];
	
	_panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(paningGestureReceive:)];
	_panGesture.delaysTouchesBegan = NO;
	_panGesture.delegate = self;
	[self.view addGestureRecognizer:_panGesture];
	objc_setAssociatedObject(_panGesture, &KKNavigationController_gestureRecognizer, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setUseShadow:(BOOL)useShadow{
	_useShadow = useShadow;
	if (useShadow) {
		_shadowImageView.hidden = NO;
	} else {
		_shadowImageView.hidden = YES;
	}
}

- (void)setUseOverlayer:(BOOL)useOverlayer{
	_useOverlayer = useOverlayer;
	if (useOverlayer) {
		_blackMask.hidden = NO;
	} else {
		_blackMask.hidden = YES;
	}
}

- (void)setHiddenUnderLine:(BOOL)hiddenUnderLine{
	if (hiddenUnderLine) {
		[self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
		[self.navigationBar setShadowImage:[UIImage new]];
	} else {
		[self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
		[self.navigationBar setShadowImage:nil];
	}
}

- (void)setNavigationBarView:(UIView *)navigationBarView{
	if (!navigationBarView) {
		[self.navigationBar setTranslucent:_originTranslucent];
		[self.navigationBar setBarTintColor:_originBarTintColor];
		[_navigationBarView removeFromSuperview];
		_navigationBarView = nil;
	} else {
		if (!_originBarTintColor) [self setInitValue];
		[self.navigationBar setTranslucent:YES];
		[self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
		[self.navigationBar setShadowImage:[UIImage new]];
		_navigationBarView = navigationBarView;
		[self.view insertSubview:_navigationBarView belowSubview:self.navigationBar];
	}
}
- (void)setNavigationBarViewColor:(UIColor *)navigationBarViewColor{
	if (!_navigationBarView) {
		self.navigationBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
	}
	_navigationBarView.backgroundColor = navigationBarViewColor;
}
- (void)setInitValue{
	_originTranslucent = self.navigationBar.translucent;
	_originBarTintColor = self.navigationBar.barTintColor;
}

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
	[self pushViewController:viewController animated:animated completion:nil];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)())completion{
	if (!viewController) return;
	//[ProgressHUD dismiss:1.0];
	if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationPushViewController:)]) {
		[_navigationKKDelegate navigationPushViewController:self];
	}
	[_screenShotsList addObject:[self capture]];
	if (_navigationBarView) self.navigationBarView = nil;
	if (completion) {
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				completion();
			});
		});
	}
	if (_hiddenBackText) {
		UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
		((UIViewController*)self.viewControllers.lastObject).navigationItem.backBarButtonItem = backBtn;
	}
	_navigationKKDelegate = (id<KKNavigationControllerDelegate>)viewController;
	[super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
	return [self popViewControllerAnimated:animated completion:nil];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated completion:(void (^)(UIViewController *viewController))completion{
	if (_navigationBarView) self.navigationBarView = nil;
	[ProgressHUD dismiss:1.0];
	UIViewController *viewController = nil;
	if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationPopToViewControllerOfClass:)]) {
		viewController = [self popToViewControllerOfClass:[_navigationKKDelegate navigationPopToViewControllerOfClass:self] animated:animated completion:completion];
	} else {
		if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationPopViewController:isGesture:)]) {
			[_navigationKKDelegate navigationPopViewController:self isGesture:_isGesture];
		}
		[_screenShotsList removeLastObject];
		[super popViewControllerAnimated:animated];
		viewController = self.viewControllers.lastObject;
		if (completion) {
			NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
			dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					completion(viewController);
				});
			});
		}
	}
	_navigationKKDelegate = (id<KKNavigationControllerDelegate>)viewController;
	if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationDidAppearFromPopAction:isGesture:)]) {
		[_navigationKKDelegate navigationDidAppearFromPopAction:self isGesture:_isGesture];
	}
	_isGesture = NO;
	return viewController;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated{
	return [self popToRootViewControllerAnimated:animated completion:nil];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)(NSArray *viewControllers))completion{
	[ProgressHUD dismiss:1.0];
	if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationPopViewController:isGesture:)]) {
		[_navigationKKDelegate navigationPopViewController:self isGesture:_isGesture];
	}
	[_screenShotsList removeAllObjects];
	NSArray *viewControllers = [super popToRootViewControllerAnimated:animated];
	if (completion) {
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(viewControllers);
			});
		});
	}
	_navigationKKDelegate = (id<KKNavigationControllerDelegate>)(self.viewControllers[0]);
	if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationDidAppearFromPopAction:isGesture:)]) {
		[_navigationKKDelegate navigationDidAppearFromPopAction:self isGesture:_isGesture];
	}
	_isGesture = NO;
	return viewControllers;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
	return [self popToViewController:viewController animated:animated completion:nil];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(NSArray *viewControllers))completion{
	[ProgressHUD dismiss:1.0];
	if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationPopViewController:isGesture:)]) {
		[_navigationKKDelegate navigationPopViewController:self isGesture:_isGesture];
	}
	for (NSInteger i=self.viewControllers.count-1; i>=0; i--) {
		if ([self.viewControllers[i] isEqual:viewController]) break;
		[_screenShotsList removeLastObject];
	}
	NSArray *viewControllers = [super popToViewController:viewController animated:animated];
	if (completion) {
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(viewControllers);
			});
		});
	}
	_navigationKKDelegate = (id<KKNavigationControllerDelegate>)viewController;
	if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationDidAppearFromPopAction:isGesture:)]) {
		[_navigationKKDelegate navigationDidAppearFromPopAction:self isGesture:_isGesture];
	}
	_isGesture = NO;
	return viewControllers;
}

- (UIViewController *)popToViewControllerOfClass:(Class)cls animated:(BOOL)animated{
	return [self popToViewControllerOfClass:cls animated:animated completion:nil];
}

- (UIViewController *)popToViewControllerOfClass:(Class)cls animated:(BOOL)animated completion:(void (^)())completion{
	[ProgressHUD dismiss:1.0];
	if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationPopViewController:isGesture:)]) {
		[_navigationKKDelegate navigationPopViewController:self isGesture:_isGesture];
	}
	for (NSInteger i=self.viewControllers.count-1; i>=0; i--) {
		if ([self.viewControllers[i] isKindOfClass:cls]) break;
		[_screenShotsList removeLastObject];
	}
	UIViewController *viewController = nil;
	for (UIViewController *controller in self.viewControllers) {
		if ([controller isKindOfClass:cls]) {
			if (completion) {
				NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
				dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
				dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
					dispatch_async(dispatch_get_main_queue(), ^{
						completion();
					});
				});
			}
			[super popToViewController:controller animated:animated];
			viewController = controller;
			break;
		}
	}
	if (!viewController) {
		viewController = [self popViewControllerAnimated:animated];
	}
	_navigationKKDelegate = (id<KKNavigationControllerDelegate>)viewController;
	if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationDidAppearFromPopAction:isGesture:)]) {
		[_navigationKKDelegate navigationDidAppearFromPopAction:self isGesture:_isGesture];
	}
	_isGesture = NO;
	return viewController;
}

#pragma mark - Utility Methods
- (UIImage *)capture{
	UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, NO, [UIScreen mainScreen].scale);
	[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	_captureImage = img;
	return img;
}

- (void)moveViewWithX:(CGFloat)x{
	CGFloat backWidth = [UIScreen mainScreen].bounds.size.width;
	x = x>backWidth ? backWidth : x;
	x = x<0 ? 0 : x;
	CGRect frame = self.view.frame;
	frame.origin.x = x;
	self.view.frame = frame;
	CGFloat alpha = 0.4 - (x/800);
	_blackMask.alpha = alpha;
	CGFloat percent = fabs(_startBackViewX) / backWidth;
	CGFloat y = x * percent;
	CGFloat lastScreenShotViewHeight = _captureImage.size.height;
	/*
	 if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
		UIViewController *controllerPrev = self.viewControllers[self.viewControllers.count-2];
		if (controllerPrev.edgesForExtendedLayout == UIRectEdgeNone) {
	 lastScreenShotViewHeight -= 20;
		}
	 }
	 */
	[_lastScreenShotView setFrame:CGRectMake(_startBackViewX+y, 0, backWidth, lastScreenShotViewHeight)];
}

#pragma mark - Gesture Recognizer
- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer{
	if (self.viewControllers.count <= 1 || !_enableDragBack) return;
	CGPoint touchPoint = [recoginzer locationInView:[[UIApplication sharedApplication] keyWindow]];
	
	if (recoginzer.state == UIGestureRecognizerStateBegan) {
		
		NSInteger index = self.viewControllers.count - 2;
		if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationPopToViewControllerOfClass:)]) {
			for (NSInteger i=self.viewControllers.count-2; i>=0; i--) {
				if ([self.viewControllers[i] isKindOfClass:[_navigationKKDelegate navigationPopToViewControllerOfClass:self]]) {
					index = i;
					break;
				}
			}
		}
		_isGesture = YES;
		_isMoving = YES;
		_startTouch = touchPoint;
		if (!_backgroundView){
			CGRect frame = self.view.frame;
			_backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
			[self.view.superview insertSubview:_backgroundView belowSubview:self.view];
			_blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
			_blackMask.backgroundColor = [UIColor blackColor];
			_blackMask.hidden = !_useOverlayer;
			[_backgroundView addSubview:_blackMask];
		}
		_blackMask.alpha = 1.0;
		_backgroundView.hidden = NO;
		if (_lastScreenShotView) [_lastScreenShotView removeFromSuperview];
		_lastScreenShotView = [[UIImageView alloc]initWithImage:_screenShotsList[index]];
		_startBackViewX = startX;
		[_lastScreenShotView setFrame:CGRectMake(_startBackViewX,
												 _lastScreenShotView.frame.origin.y,
												 _lastScreenShotView.frame.size.height,
												 _lastScreenShotView.frame.size.width)];
		[_backgroundView insertSubview:_lastScreenShotView belowSubview:_blackMask];
		if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationDidBeginGesture:)]) {
			[_navigationKKDelegate navigationDidBeginGesture:self];
		}
		
	} else if (recoginzer.state == UIGestureRecognizerStateEnded){
		
		if (touchPoint.x - _startTouch.x > 50){
			[UIView animateWithDuration:0.3 animations:^{
				[self moveViewWithX:[UIScreen mainScreen].bounds.size.width];
			} completion:^(BOOL finished) {
				CGRect frame = self.view.frame;
				frame.origin.x = 0;
				self.view.frame = frame;
				_isMoving = NO;
				_backgroundView.hidden = YES;
				if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationPopToViewControllerOfClass:)]) {
					[self popToViewControllerOfClass:[_navigationKKDelegate navigationPopToViewControllerOfClass:self] animated:NO];
				} else {
					[self popViewControllerAnimated:NO];
				}
				if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationDidEndGesture:)]) {
					[_navigationKKDelegate navigationDidEndGesture:self];
				}
			}];
		} else {
			[UIView animateWithDuration:0.3 animations:^{
				[self moveViewWithX:0];
			} completion:^(BOOL finished) {
				_isMoving = NO;
				_backgroundView.hidden = YES;
				if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationDidEndGesture:)]) {
					[_navigationKKDelegate navigationDidEndGesture:self];
				}
			}];
			
		}
		return;
		
	} else if (recoginzer.state == UIGestureRecognizerStateCancelled){
		
		[UIView animateWithDuration:0.3 animations:^{
			[self moveViewWithX:0];
		} completion:^(BOOL finished) {
			_isGesture = NO;
			_isMoving = NO;
			_backgroundView.hidden = YES;
			if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationDidEndGesture:)]) {
				[_navigationKKDelegate navigationDidEndGesture:self];
			}
		}];
		return;
		
	}
	
	if (_isMoving) {
		[self moveViewWithX:touchPoint.x - _startTouch.x];
	}
}

#pragma mark - GestureRecognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer{
	UINavigationController *navigation = self;
	if ([navigation.transitionCoordinator isAnimated] || navigation.viewControllers.count<2) {
		return NO;
	}
	
	CGPoint velocity = [recognizer velocityInView:navigation.view];
	if (velocity.x<=0) {
		//NSLog(@"不是右滑的");
		return NO;
	}
	
	CGPoint translation = [recognizer translationInView:navigation.view];
	translation.x = translation.x==0 ? 0.00001f : translation.x;
	CGFloat ratio = ( fabs(translation.y) / fabs(translation.x) );
	//因为上滑的操作相对会比较频繁，所以角度限制少点
	if ( (translation.y>0 && ratio>0.618f) || (translation.y<0 && ratio>0.2f) ) {
		//NSLog(@"右滑角度不在范围内");
		return NO;
	}
	
	return YES;
}

- (BOOL)shouldAutorotate{
	return [self.viewControllers.lastObject shouldAutorotate];
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
#else
- (NSUInteger)supportedInterfaceOrientations {
#endif
	return [self.viewControllers.lastObject supportedInterfaceOrientations];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
	return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
}

- (UIViewController *)childViewControllerForStatusBarStyle{
	return self.topViewController;
}

@end
	
	
#pragma mark - UIScrollView delegate -
@interface UIScrollView (KKNavigationController)
@end
@implementation UIScrollView (KKNavigationController)
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	if ([gestureRecognizer isEqual:self.panGestureRecognizer]) {
		//如果scrollView有横向滚动就忽略
		if (CGAffineTransformEqualToTransform(CGAffineTransformMakeRotation(-M_PI*0.5), self.transform) ||
			CGAffineTransformEqualToTransform(CGAffineTransformMakeRotation(M_PI*0.5), self.transform)) {
			return NO;
		} else {
			if (self.contentSize.width>self.frame.size.width) return NO;
		}
		id value = objc_getAssociatedObject(otherGestureRecognizer, &KKNavigationController_gestureRecognizer);
		if (value) {
			return YES;
		}
	}
	return NO;
}
@end
	
	
#pragma mark - Return navigationControllerKK -
@implementation UIViewController (KKNavigationController)
- (KKNavigationController*)navigationControllerKK{
	return (KKNavigationController*)self.navigationController;
}
@end
	
	
#pragma mark - 自定义UIBarButtonItem -
#define DEFAULT_OFFSET 10
#define TITLEVIEW_SIZE CGSizeMake(70, 30) //用NSString设置item时 item的尺寸
@interface UIControl (KKNavigationBarItem)
- (NSMutableDictionary*)element;
- (void)addControlEvent:(UIControlEvents)event withBlock:(void(^)(id sender))block;
@end
@implementation UIControl (KKNavigationBarItem)
- (NSMutableDictionary*)element{
	NSMutableDictionary *ele = objc_getAssociatedObject(self, @"element");
	if (!ele) {
		ele = [[NSMutableDictionary alloc]init];
		objc_setAssociatedObject(self, @"element", ele, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return ele;
}
- (void)addControlEvent:(UIControlEvents)event withBlock:(void(^)(id sender))block{
	NSString *methodName = [self eventName:event];
	if (block) self.element[@"block"] = block;
	[self addTarget:self action:NSSelectorFromString(methodName) forControlEvents:event];
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

@implementation KKNavigationBarItem
+ (KKNavigationBarItem*)itemWithTitle:(NSString *)title textColor:(UIColor *)color fontSize:(CGFloat )font itemType:(KKNavigationItemType)type{
	KKNavigationBarItem *item = [[KKNavigationBarItem alloc] init];
	[item initCustomItemWithType:type andSize:TITLEVIEW_SIZE];
	[item setItemContetnWithType:type];
	[item.contentBarItem setTitle:title forState:UIControlStateNormal];
	[item.contentBarItem setTitleColor:color forState:UIControlStateNormal];
	[item.contentBarItem.titleLabel setFont:[UIFont systemFontOfSize:font]];
	return item;
}
+ (KKNavigationBarItem*)itemWithImage:(UIImage*)image size:(CGSize)size type:(KKNavigationItemType)type{
	KKNavigationBarItem *item = [[KKNavigationBarItem alloc] init];
	[item initCustomItemWithType:type andSize:size];
	[item setItemContetnWithType:type];
	[item.contentBarItem setImage:image forState:UIControlStateNormal];
	return item;
}
+ (KKNavigationBarItem*)itemWithCustomeView:(UIView *)customView type:(KKNavigationItemType)type{
	KKNavigationBarItem *item = [[KKNavigationBarItem alloc] init];
	[item initCustomItemWithType:type andSize:customView.frame.size];
	item.isCustomView = YES;
	item.customView = customView;
	customView.frame = item.contentBarItem.bounds;
	[item.contentBarItem addSubview:customView];
	[item setItemContetnWithType:type];
	return item;
}
- (void)initCustomItemWithType:(KKNavigationItemType)type andSize:(CGSize)size{
	self.isCustomView = NO;
	self.itemType = type;
	self.items = [[NSMutableArray alloc] init];
	self.contentBarItem = [UIButton buttonWithType:UIButtonTypeCustom];
	self.contentBarItem.frame = CGRectMake(0, 0, size.width, size.height);
	[self.items addObject:self.contentBarItem];
}
- (void)setItemContetnWithType:(KKNavigationItemType)type{
	if (type == KKNavigationItemTypeRight) {
		[self.contentBarItem setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
		[self setOffset:DEFAULT_OFFSET];
	} else if (type == KKNavigationItemTypeLeft){
		[self.contentBarItem setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		[self setOffset:-DEFAULT_OFFSET];
	}
}
- (void)setItemWithNavigationItem:(UINavigationItem *)navigationItem itemType:(KKNavigationItemType)type{
	if (type == KKNavigationItemTypeCenter) {
		[navigationItem setTitleView:self.contentBarItem];
	} else if (type == KKNavigationItemTypeLeft){
		[navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:self.contentBarItem]];
	} else if (type == KKNavigationItemTypeRight){
		[navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:self.contentBarItem]];
	}
}
- (void)setOffset:(CGFloat)offset{
	if (self.isCustomView) {
		CGRect customViewFrame = self.customView.frame;
		customViewFrame.origin.x = offset;
		self.customView.frame = customViewFrame;
	} else {
		[self.contentBarItem setContentEdgeInsets:UIEdgeInsetsMake(0, offset, 0, -offset)];
	}
}
- (void)addTarget:(id)target action:(SEL)selector forControlEvents:(UIControlEvents)event{
	[self.contentBarItem addTarget:target action:selector forControlEvents:event];
}
- (void)addControlEvent:(UIControlEvents)event withBlock:(void(^)(id sender))block{
	if (!block) return;
	[self.contentBarItem addControlEvent:event withBlock:block];
}
@end
@implementation UINavigationItem (NavigationBarItem)
- (KKNavigationBarItem*)setItemWithTitle:(NSString *)title textColor:(UIColor *)color fontSize:(CGFloat)font itemType:(KKNavigationItemType)type{
	KKNavigationBarItem *item = [KKNavigationBarItem itemWithTitle:title textColor:color fontSize:font itemType:type];
	[item setItemWithNavigationItem:self itemType:type];
	return item;
}
- (KKNavigationBarItem*)setItemWithImage:(UIImage *)image size:(CGSize)size itemType:(KKNavigationItemType)type{
	KKNavigationBarItem *item = [KKNavigationBarItem itemWithImage:image size:size type:type];
	[item setItemWithNavigationItem:self itemType:type];
	return item;
}
- (KKNavigationBarItem*)setItemWithCustomView:(UIView *)customView itemType:(KKNavigationItemType)type{
	KKNavigationBarItem *item = [KKNavigationBarItem itemWithCustomeView:customView type:type];
	[item setItemWithNavigationItem:self itemType:type];
	return item;
}
@end
