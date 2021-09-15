//
//  UIViewController+Extend.m
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import "Global.h"

#pragma mark - UIViewController+Extend
#define PRESENT_VIEW_TAG 20040724
@implementation UIViewController (GlobalExtend)
- (BOOL)checkLogin{
	return [self checkLogin:NO];
}
- (BOOL)checkLogin:(BOOL)showLogin{
	if (!PERSON.isDictionary) {
		if (showLogin) {
			[self showLoginController];
		}
		return NO;
	}
	return YES;
}
- (void)showLoginController{
	[self showLoginControllerWithDelegate:NO];
}
- (void)showLoginControllerWithDelegate{
	[self showLoginControllerWithDelegate:YES];
}
- (void)showLoginControllerWithDelegate:(BOOL)setDelegate{
	if (NSClassFromString(@"login")) {
		id e = [[NSClassFromString(@"login") alloc]init];
		if (setDelegate) {
			SEL sel = NSSelectorFromString(@"setDelegate:");
			if ([e respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
				[e performSelector:sel withObject:self];
#pragma clang diagnostic pop
			}
		}
		KKNavigationController *nav = [[KKNavigationController alloc]initWithRootViewController:e];
		[self presentViewController:nav animated:YES completion:nil];
	}
}
//DYActionSheet
- (void)presentActionViewController:(UIViewController*)vc{
	[self presentActionView:vc.view];
}

- (void)presentActionView:(UIView*)view{
	[self presentActionView:view remove:YES inView:[[UIApplication sharedApplication] keyWindow]];
}

- (void)presentActionViewNoRemove:(UIView*)view{
	[self presentActionView:view remove:NO inView:[[UIApplication sharedApplication] keyWindow]];
}

- (void)presentActionView:(UIView*)view inView:(UIView*)target{
	[self presentActionView:view remove:YES inView:target];
}

- (void)presentActionView:(UIView*)view remove:(BOOL)remove inView:(UIView*)target{
	[self presentActionView:view remove:remove inView:target close:nil];
}

- (void)presentActionView:(UIView*)view remove:(BOOL)remove inView:(UIView*)target close:(void (^)())close{
	if ([target viewWithTag:PRESENT_VIEW_TAG] && remove) return;
	self.element[@"presentTarget"] = target;
	self.element[@"presentRemove"] = @(remove);
	if (close) self.element[@"presentClose"] = close;
	//UIToolbar *overlay = [[UIToolbar alloc]initWithFrame:target.bounds];
	//overlay.barStyle = UIBarStyleBlackTranslucent; //UIBarStyleDefault:白色
	UIView *overlay = [[UIView alloc]initWithFrame:target.bounds];
	overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
	overlay.userInteractionEnabled = YES;
	overlay.tag = PRESENT_VIEW_TAG-1;
	overlay.alpha = 0;
	[target addSubview:overlay];
	//UIVisualEffectView *visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
	//visualEfView.frame = overlay.bounds;
	//[overlay addSubview:visualEfView];
	UIButton *dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	dismissBtn.frame = overlay.bounds;
	dismissBtn.backgroundColor = [UIColor clearColor];
	if (![view.element[@"close"]isset]) [dismissBtn addTarget:self action:@selector(dismissActionView) forControlEvents:UIControlEventTouchUpInside];
	[overlay addSubview:dismissBtn];
	view.tag = PRESENT_VIEW_TAG;
	view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, target.frame.size.height, view.frame.size.width, view.frame.size.height);
	if (![target viewWithTag:PRESENT_VIEW_TAG]) [target addSubview:view];
	[target bringSubviewToFront:view];
	[UIView animateWithDuration:0.3 animations:^{
		overlay.alpha = 1;
		view.frame = CGRectMake(view.frame.origin.x, target.frame.size.height-view.frame.size.height, view.frame.size.width, view.frame.size.height);
	}];
}

- (void)dismissActionView{
	[self dismissActionView:self.element[@"presentClose"]];
}

- (void)dismissActionView:(void (^)())completion{
	[ProgressHUD dismiss];
	UIView *target = self.element[@"presentTarget"];
	BOOL remove = [self.element[@"presentRemove"] boolValue];
	if (!target) return;
	UIView *overlay = [target viewWithTag:PRESENT_VIEW_TAG-1];
	UIView *view = [target viewWithTag:PRESENT_VIEW_TAG];
	[UIView animateWithDuration:0.3 animations:^{
		overlay.alpha = 0;
	} completion:^(BOOL finished) {
		[overlay removeFromSuperview];
	}];
	[UIView animateWithDuration:0.3 animations:^{
		view.frame = CGRectMake(view.frame.origin.x, target.frame.size.height, view.frame.size.width, view.frame.size.height);
	} completion:^(BOOL finished) {
		if (remove) [view removeFromSuperview];
		if (completion) completion();
	}];
}

- (void)presentAlertViewController:(UIViewController*)vc{
	[self presentAlertView:vc.view];
}

- (void)presentAlertView:(UIView*)view{
	[self presentAlertView:view animation:DYAlertViewNoAnimation];
}

- (void)presentAlertView:(UIView*)view animation:(DYAlertViewAnimation)animation{
	[self presentAlertView:view animation:animation close:nil];
}
- (void)presentAlertView:(UIView*)view animation:(DYAlertViewAnimation)animation close:(void (^)())close{
	[self presentAlertView:view remove:YES inView:[[UIApplication sharedApplication] keyWindow] animation:animation close:close];
}

- (void)presentAlertViewNoRemove:(UIView*)view animation:(DYAlertViewAnimation)animation{
	[self presentAlertViewNoRemove:view animation:animation close:nil];
}
- (void)presentAlertViewNoRemove:(UIView*)view animation:(DYAlertViewAnimation)animation close:(void (^)())close{
	[self presentAlertView:view remove:NO inView:[[UIApplication sharedApplication] keyWindow] animation:animation close:close];
}

- (void)presentAlertView:(UIView*)view remove:(BOOL)remove inView:(UIView*)target animation:(DYAlertViewAnimation)animation{
	[self presentAlertView:view remove:remove inView:target animation:animation close:nil];
}

- (void)presentAlertView:(UIView*)view remove:(BOOL)remove inView:(UIView*)target animation:(DYAlertViewAnimation)animation close:(void (^)())close{
	if ([target viewWithTag:PRESENT_VIEW_TAG] && remove) return;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentAlertKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentAlertKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	self.element[@"presentTarget"] = target;
	self.element[@"presentRemove"] = @(remove);
	if (close) self.element[@"presentClose"] = close;
	//UIToolbar *overlay = [[UIToolbar alloc]initWithFrame:target.bounds];
	//overlay.barStyle = UIBarStyleBlackTranslucent;
	UIView *overlay = [[UIView alloc]initWithFrame:target.bounds];
	overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
	overlay.userInteractionEnabled = YES;
	overlay.tag = PRESENT_VIEW_TAG-1;
	overlay.alpha = 0;
	[target addSubview:overlay];
	UIButton *dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	dismissBtn.tag = 777 + animation;
	dismissBtn.frame = overlay.bounds;
	dismissBtn.backgroundColor = [UIColor clearColor];
	if (![view.element[@"close"]isset] || ([view.element[@"close"]isset] && [view.element[@"close"]boolValue])) [dismissBtn addTarget:self action:@selector(dismissAlertViewWithBtn:) forControlEvents:UIControlEventTouchUpInside];
	[overlay addSubview:dismissBtn];
	switch (animation) {
		case DYAlertViewNoAnimation:{
			view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
			break;
		}
		case DYAlertViewUp:{
			view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, -view.frame.size.height, view.frame.size.width, view.frame.size.height);
			break;
		}
		case DYAlertViewDown:{
			view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, target.frame.size.height, view.frame.size.width, view.frame.size.height);
			break;
		}
		case DYAlertViewLeft:{
			view.frame = CGRectMake(-view.frame.size.width, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
			break;
		}
		case DYAlertViewRight:{
			view.frame = CGRectMake(target.frame.size.width, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
			break;
		}
		case DYAlertViewFade:{
			view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
			view.alpha = 0;
			break;
		}
		case DYAlertViewScale:{
			view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
			view.alpha = 0.5f;
			view.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0f);
			break;
		}
		default:
			break;
	}
	view.tag = PRESENT_VIEW_TAG;
	view.hidden = NO;
	if (![target viewWithTag:PRESENT_VIEW_TAG]) [target addSubview:view];
	[target bringSubviewToFront:view];
#if (defined(__IPHONE_7_0))
	// Add motion effects
	CGFloat kCustomIOS7MotionEffectExtent = 10.0;
	UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontalEffect.minimumRelativeValue = @(-kCustomIOS7MotionEffectExtent);
	horizontalEffect.maximumRelativeValue = @( kCustomIOS7MotionEffectExtent);
	UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	verticalEffect.minimumRelativeValue = @(-kCustomIOS7MotionEffectExtent);
	verticalEffect.maximumRelativeValue = @( kCustomIOS7MotionEffectExtent);
	UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
	motionEffectGroup.motionEffects = @[horizontalEffect, verticalEffect];
	[view addMotionEffect:motionEffectGroup];
#endif
	if (animation == DYAlertViewNoAnimation) {
		overlay.alpha = 1;
		return;
	}
	[UIView animateWithDuration:0.3 animations:^{
		overlay.alpha = 1;
		view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
		view.alpha = 1;
		if (animation == DYAlertViewScale) {
			view.layer.transform = CATransform3DMakeScale(1.0f, 1.0f, 1.0f);
		}
	}];
}

- (void)dismissAlertViewWithBtn:(UIButton*)sender{
	NSInteger animation = sender.tag - 777;
	[self dismissAlertView:animation];
}

- (void)dismissAlertView{
	[self dismissAlertView:DYAlertViewNoAnimation];
}

- (void)dismissAlertView:(DYAlertViewAnimation)animation{
	[self dismissAlertView:animation completion:self.element[@"presentClose"]];
}

- (void)dismissAlertView:(DYAlertViewAnimation)animation completion:(void (^)())completion{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[ProgressHUD dismiss];
	UIView *target = self.element[@"presentTarget"];
	BOOL remove = [self.element[@"presentRemove"] boolValue];
	if (!target) return;
	UIView *overlay = [target viewWithTag:PRESENT_VIEW_TAG-1];
	UIView *view = [target viewWithTag:PRESENT_VIEW_TAG];
	if (animation == DYAlertViewNoAnimation) {
		[overlay removeFromSuperview];
		if (remove) {
			[view removeFromSuperview];
		} else {
			view.hidden = YES;
		}
		if (completion) completion();
		return;
	}
	[UIView animateWithDuration:0.3 animations:^{
		overlay.alpha = 0;
	} completion:^(BOOL finished) {
		[overlay removeFromSuperview];
	}];
	CATransform3D currentTransform = view.layer.transform;
	if (animation == DYAlertViewScale) {
		CGFloat startRotation = [[view valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
		CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);
		view.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
	}
	[UIView animateWithDuration:0.3 animations:^{
		switch (animation) {
			case DYAlertViewUp:{
				view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, -view.frame.size.height, view.frame.size.width, view.frame.size.height);
				break;
			}
			case DYAlertViewDown:{
				view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, target.frame.size.height, view.frame.size.width, view.frame.size.height);
				break;
			}
			case DYAlertViewLeft:{
				view.frame = CGRectMake(-view.frame.size.width, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
				break;
			}
			case DYAlertViewRight:{
				view.frame = CGRectMake(target.frame.size.width, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
				break;
			}
			case DYAlertViewFade:{
				view.alpha = 0;
				break;
			}
			case DYAlertViewScale:{
				view.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
				view.layer.opacity = 0.0f;
				break;
			}
			default:
				break;
		}
	} completion:^(BOOL finished) {
		if (remove) {
			[view removeFromSuperview];
		} else {
			view.hidden = YES;
		}
		if (completion) completion();
	}];
}

- (void)presentAlertKeyboardWillShow:(NSNotification *)notification{
	NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
	self.element[@"keyboardBoundsValue"] = keyboardBoundsValue;
	[self presentAlertAdjustViewForKeyboardReveal];
}
- (void)presentAlertKeyboardWillHide:(NSNotification *)notification{
	if (!self.element[@"presentTarget"]) return;
	UIView *target = self.element[@"presentTarget"];
	UIView *view = [target viewWithTag:PRESENT_VIEW_TAG];
	CGRect frame = view.frame;
	frame.origin.y = (target.frame.size.height - frame.size.height) / 2;
	[UIView animateWithDuration:0.3 animations:^{
		view.frame = frame;
	}];
}
- (void)presentAlertAdjustViewForKeyboardReveal{
	if (!self.element[@"presentTarget"] || !self.element[@"keyboardBoundsValue"]) return;
	UIView *target = self.element[@"presentTarget"];
	UIView *view = [target viewWithTag:PRESENT_VIEW_TAG];
	CGRect frame = view.frame;
	CGRect keyboardbound = [self.element[@"keyboardBoundsValue"] CGRectValue];
	if (frame.origin.y+frame.size.height < target.frame.size.height-keyboardbound.size.height) return;
	CGFloat offsetTop = 0;
	if (target.frame.size.height-keyboardbound.size.height < frame.size.height) {
		offsetTop = target.frame.size.height-keyboardbound.size.height - frame.size.height;
	} else {
		offsetTop = (target.frame.size.height - keyboardbound.size.height - frame.size.height) / 2;
	}
	frame.origin.y = offsetTop;
	[UIView animateWithDuration:0.3 animations:^{
		view.frame = frame;
	}];
}

- (UIViewController*)parentTarget{
	//To make it work with UINav & UITabbar as well
	UIViewController *target = self;
	while (target.parentViewController != nil) {
		target = target.parentViewController;
	}
	return target;
}

//摇动
//viewDidLoad 增加
//[UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
//[self becomeFirstResponder];
//摇动开始
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
	//NSLog(@"摇动开始");
	if ([self respondsToSelector:NSSelectorFromString(@"shakeBegin")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[self performSelector:NSSelectorFromString(@"shakeBegin")];
#pragma clang diagnostic pop
	}
}
//摇动结束
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
	if (event.subtype == UIEventSubtypeMotionShake) { //判断是否摇动结束
		//NSLog(@"摇动结束");
		if ([self respondsToSelector:NSSelectorFromString(@"shakeEnd")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[self performSelector:NSSelectorFromString(@"shakeEnd")];
#pragma clang diagnostic pop
		}
	}
}
//摇动取消
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
	//NSLog(@"摇动取消");
	if ([self respondsToSelector:NSSelectorFromString(@"shakeCancel")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[self performSelector:NSSelectorFromString(@"shakeCancel")];
#pragma clang diagnostic pop
	}
}

//获取状态栏
- (UIView*)statusBar{
	UIView *statusBar = nil;
	NSData *data = [NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9];
	NSString *key = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	id object = [UIApplication sharedApplication];
	if ([object respondsToSelector:NSSelectorFromString(key)]) statusBar = [object valueForKey:key];
	return statusBar;
}

//获取状态栏高度
- (CGFloat)statusBarHeight{
	return [UIApplication sharedApplication].statusBarFrame.size.height;
}

//导航与状态栏高度
- (CGFloat)navigationAndStatusBarHeight{
	return self.navigationController.navigationBar.frame.size.height + [Global statusBarHeight];
}

//View高度(根据导航透明自动判断是否去除导航高度)
- (CGFloat)height{
	CGFloat height = SCREEN_HEIGHT;
	if (self.navigationController && !self.navigationController.navigationBarHidden && !self.navigationController.navigationBar.translucent) {
		height -= self.navigationAndStatusBarHeight;
	}
	return height;
}

//View背景色
- (UIColor*)backgroundColor{
	return self.view.backgroundColor;
}
- (void)setBackgroundColor:(UIColor*)backgroundColor{
	self.view.backgroundColor = backgroundColor;
}

//渐显/渐隐状态栏
- (void)statusBarOpacityTo:(CGFloat)opacity{
	UIView *statusBar = [self statusBar];
	[UIView animateWithDuration:0.3 animations:^{
		statusBar.alpha = opacity;
	}];
}

//滚动隐藏导航
- (void)navigationFollowScrollView:(UIScrollView*)scrollableView{
	if (!self.navigationController) return;
	if (!self.navigationController.navigationBar.barTintColor) NSLog(@"[%s]: %@", __func__, @"Warning: no bar tint color set");
	
	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
	recognizer.maximumNumberOfTouches = 1;
	recognizer.delegate = self;
	[scrollableView addGestureRecognizer:recognizer];
	
	CGRect frame = self.navigationController.navigationBar.frame;
	frame.origin = CGPointZero;
	UIView *overlay = [[UIView alloc]initWithFrame:frame];
	overlay.backgroundColor = self.navigationController.navigationBar.barTintColor;
	overlay.userInteractionEnabled = NO;
	overlay.alpha = 0;
	[self.navigationController.navigationBar addSubview:overlay];
	
	self.element[@"scrollableView"] = scrollableView;
	self.element[@"overlay"] = overlay;
	self.element[@"lastContentOffset"] = @0;
	self.element[@"isCollapsed"] = @NO;
	self.element[@"isExpanded"] = @NO;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	return YES;
}
- (void)handlePan:(UIPanGestureRecognizer*)recognizer{
	UIScrollView *scrollableView = self.element[@"scrollableView"];
	CGPoint translation = [recognizer translationInView:scrollableView.superview];
	
	CGFloat lastContentOffset = [self.element[@"lastContentOffset"]floatValue];
	CGFloat delta = lastContentOffset - translation.y;
	lastContentOffset = translation.y;
	self.element[@"lastContentOffset"] = @(lastContentOffset);
	
	BOOL isCollapsed = [self.element[@"isCollapsed"]boolValue];
	BOOL isExpanded = [self.element[@"isExpanded"]boolValue];
	
	CGRect frame;
	if (delta > 0) {
		if (isCollapsed) return;
		frame = self.navigationController.navigationBar.frame;
		if (frame.origin.y - delta < -24) {
			delta = frame.origin.y + 24;
		}
		frame.origin.y = MAX(-24, frame.origin.y - delta);
		self.navigationController.navigationBar.frame = frame;
		if (frame.origin.y == -24) {
			isCollapsed = YES;
			isExpanded = NO;
		}
		self.element[@"isCollapsed"] = @(isCollapsed);
		self.element[@"isExpanded"] = @(isExpanded);
		[self updateSizingWithDelta:delta];
		if ([scrollableView isKindOfClass:[UIScrollView class]]) {
			[scrollableView setContentOffset:CGPointMake(scrollableView.contentOffset.x, scrollableView.contentOffset.y - delta)];
		}
	}
	if (delta < 0) {
		if (isExpanded) return;
		frame = self.navigationController.navigationBar.frame;
		if (frame.origin.y - delta > 20) {
			delta = frame.origin.y - 20;
		}
		frame.origin.y = MIN(20, frame.origin.y - delta);
		self.navigationController.navigationBar.frame = frame;
		if (frame.origin.y == 20) {
			isExpanded = YES;
			isCollapsed = NO;
		}
		self.element[@"isCollapsed"] = @(isCollapsed);
		self.element[@"isExpanded"] = @(isExpanded);
		[self updateSizingWithDelta:delta];
	}
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		lastContentOffset = 0;
		self.element[@"lastContentOffset"] = @(lastContentOffset);
		[self checkForPartialScroll];
	}
}
- (void)checkForPartialScroll{
	__block BOOL isCollapsed = [self.element[@"isCollapsed"]boolValue];
	__block BOOL isExpanded = [self.element[@"isExpanded"]boolValue];
	CGFloat pos = self.navigationController.navigationBar.frame.origin.y;
	if (pos >= -2) {
		[UIView animateWithDuration:0.2 animations:^{
			CGRect frame;
			frame = self.navigationController.navigationBar.frame;
			CGFloat delta = frame.origin.y - 20;
			frame.origin.y = MIN(20, frame.origin.y - delta);
			self.navigationController.navigationBar.frame = frame;
			isExpanded = YES;
			isCollapsed = NO;
			self.element[@"isCollapsed"] = @(isCollapsed);
			self.element[@"isExpanded"] = @(isExpanded);
			[self updateSizingWithDelta:delta];
		}];
	} else {
		[UIView animateWithDuration:0.2 animations:^{
			CGRect frame;
			frame = self.navigationController.navigationBar.frame;
			CGFloat delta = frame.origin.y + 24;
			frame.origin.y = MAX(-24, frame.origin.y - delta);
			self.navigationController.navigationBar.frame = frame;
			isExpanded = NO;
			isCollapsed = YES;
			self.element[@"isCollapsed"] = @(isCollapsed);
			self.element[@"isExpanded"] = @(isExpanded);
			[self updateSizingWithDelta:delta];
		}];
	}
}
- (void)updateSizingWithDelta:(CGFloat)delta{
	UIScrollView *scrollableView = self.element[@"scrollableView"];
	UIView *overlay = self.element[@"overlay"];
	
	CGRect frame = self.navigationController.navigationBar.frame;
	CGFloat alpha = (frame.origin.y + 24) / frame.size.height;
	overlay.alpha = 1 - alpha;
	self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
	
	frame = scrollableView.superview.frame;
	frame.origin.y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
	frame.size.height = frame.size.height + delta;
	scrollableView.superview.frame = frame;
	
	frame = scrollableView.layer.frame;
	frame.size.height += delta;
	scrollableView.layer.frame = frame;
}
//UIMenuController Delegate
- (BOOL)canBecomeFirstResponder{
	return YES;
}
@end
