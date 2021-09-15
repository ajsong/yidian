//
//  UIViewController+Extend.h
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - UIViewController+Extend
typedef enum : NSInteger {
	DYAlertViewNoAnimation = 0, //没有动画
	DYAlertViewUp, //从上到下
	DYAlertViewDown, //从下到上
	DYAlertViewLeft, //从左到右
	DYAlertViewRight, //从右到左
	DYAlertViewFade, //渐显渐隐
	DYAlertViewScale, //放大缩小
} DYAlertViewAnimation;

@interface UIViewController (GlobalExtend)<UIGestureRecognizerDelegate>
- (BOOL)checkLogin;
- (BOOL)checkLogin:(BOOL)showLogin;
- (void)showLoginController;
- (void)showLoginControllerWithDelegate;
- (void)presentActionViewController:(UIViewController*)vc;
- (void)presentActionView:(UIView*)view;
- (void)presentActionViewNoRemove:(UIView*)view;
- (void)presentActionView:(UIView*)view inView:(UIView*)target;
- (void)presentActionView:(UIView*)view remove:(BOOL)remove inView:(UIView*)target;
- (void)presentActionView:(UIView*)view remove:(BOOL)remove inView:(UIView*)target close:(void (^)())close;
- (void)dismissActionView;
- (void)dismissActionView:(void (^)())completion;
- (void)presentAlertViewController:(UIViewController*)vc;
- (void)presentAlertView:(UIView*)view;
- (void)presentAlertView:(UIView*)view animation:(DYAlertViewAnimation)animation;
- (void)presentAlertView:(UIView*)view animation:(DYAlertViewAnimation)animation close:(void (^)())close;
- (void)presentAlertViewNoRemove:(UIView*)view animation:(DYAlertViewAnimation)animation;
- (void)presentAlertViewNoRemove:(UIView*)view animation:(DYAlertViewAnimation)animation close:(void (^)())close;
- (void)presentAlertView:(UIView*)view remove:(BOOL)remove inView:(UIView*)target animation:(DYAlertViewAnimation)animation;
- (void)presentAlertView:(UIView*)view remove:(BOOL)remove inView:(UIView*)target animation:(DYAlertViewAnimation)animation close:(void (^)())close;
- (void)dismissAlertView;
- (void)dismissAlertView:(DYAlertViewAnimation)animation;
- (void)dismissAlertView:(DYAlertViewAnimation)animation completion:(void (^)())completion;
- (UIViewController*)parentTarget;
- (UIView*)statusBar;
- (CGFloat)statusBarHeight;
- (CGFloat)navigationAndStatusBarHeight;
- (CGFloat)height;
- (UIColor*)backgroundColor;
- (void)setBackgroundColor:(UIColor*)backgroundColor;
- (void)statusBarOpacityTo:(CGFloat)opacity;
- (void)navigationFollowScrollView:(UIScrollView*)scrollableView;
@end
