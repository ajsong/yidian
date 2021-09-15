//
//  UIView+Extend.m
//
//  Created by ajsong on 15/10/9.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import "Global.h"

#pragma mark - UIView+Extend
@implementation UIView (GlobalExtend)
- (CGFloat)left{
	return self.frame.origin.x;
}

- (CGFloat)top{
	return self.frame.origin.y;
}

- (CGFloat)right{
	return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)bottom{
	return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)width{
	return self.frame.size.width;
}

- (CGFloat)height{
	return self.frame.size.height;
}

- (CGPoint)origin{
	return self.frame.origin;
}

- (CGSize)size{
	return self.frame.size;
}

- (CGFloat)getLeftUntil:(UIView*)view{
	CGFloat left = self.frame.origin.x;
	UIView *superView = self.superview;
	while (![superView isEqual:view]) {
		left += superView.frame.origin.x;
		superView = superView.superview;
		if (superView==nil) break;
	}
	return left;
}

- (CGFloat)getTopUntil:(UIView*)view{
	CGFloat top = self.frame.origin.y;
	UIView *superView = self.superview;
	while (![superView isEqual:view]) {
		top += superView.frame.origin.y;
		superView = superView.superview;
		if (superView==nil) break;
	}
	return top;
}

- (CGFloat)getWidthPercent:(CGFloat)percent{
	return self.frame.size.width * (percent / 100);
}

- (CGFloat)getHeightPercent:(CGFloat)percent{
	return self.frame.size.height * (percent / 100);
}

- (CGPoint)offset{
	UIView *view = self;
	CGFloat x = 0;
	CGFloat y = 0;
	while (view) {
		if ([view.superview isKindOfClass:[UIScrollView class]]) {
			y -= ((UIScrollView*)view.superview).contentOffset.y;
		}
		x += view.frame.origin.x;
		y += view.frame.origin.y;
		view = view.superview;
	}
	return CGPointMake(x, y);
}

- (void)setLeft:(CGFloat)newLeft{
	CGRect frame = self.frame;
	frame.origin.x = newLeft;
	self.frame = frame;
}

- (void)setTop:(CGFloat)newTop{
	CGRect frame = self.frame;
	frame.origin.y = newTop;
	self.frame = frame;
}

- (void)setRight:(CGFloat)newRight{
	CGRect frame = self.frame;
	if (self.superview) frame.origin.x = self.superview.frame.size.width - frame.size.width - newRight;
	self.frame = frame;
}

- (void)setBottom:(CGFloat)newBottom{
	CGRect frame = self.frame;
	if (self.superview) frame.origin.y = self.superview.frame.size.height - frame.size.height - newBottom;
	self.frame = frame;
}

- (void)setWidth:(CGFloat)newWidth{
	CGRect frame = self.frame;
	frame.size.width = newWidth;
	self.frame = frame;
}

- (void)setHeight:(CGFloat)newHeight{
	CGRect frame = self.frame;
	frame.size.height = newHeight;
	self.frame = frame;
}

- (void)setOrigin:(CGPoint)newOrigin{
	CGRect frame = self.frame;
	frame.origin = newOrigin;
	self.frame = frame;
}

- (void)setSize:(CGSize)newSize{
	CGRect frame = self.frame;
	frame.size = newSize;
	self.frame = frame;
}

- (void)centerX{
	CGRect superFrame = self.superview.frame;
	CGRect frame = self.frame;
	frame.origin.x = (superFrame.size.width - frame.size.width) / 2;
	self.frame = frame;
}

- (void)centerY{
	CGRect superFrame = self.superview.frame;
	CGRect frame = self.frame;
	frame.origin.y = (superFrame.size.height - frame.size.height) / 2;
	self.frame = frame;
}

- (void)centerXY{
	CGRect superFrame = self.superview.frame;
	CGRect frame = self.frame;
	frame.origin.x = (superFrame.size.width - frame.size.width) / 2;
	frame.origin.y = (superFrame.size.height - frame.size.height) / 2;
	self.frame = frame;
}

- (CGFloat)leftAnimate{
	return self.left;
}
- (void)setLeftAnimate:(CGFloat)newLeft{
	CGRect frame = self.frame;
	frame.origin.x = newLeft;
	[UIView animateWithDuration:0.3 animations:^{
		self.frame = frame;
	}];
}

- (CGFloat)topAnimate{
	return self.top;
}
- (void)setTopAnimate:(CGFloat)newTop{
	CGRect frame = self.frame;
	frame.origin.y = newTop;
	[UIView animateWithDuration:0.3 animations:^{
		self.frame = frame;
	}];
}

- (CGFloat)widthAnimate{
	return self.width;
}
- (void)setWidthAnimate:(CGFloat)newWidth{
	CGRect frame = self.frame;
	frame.size.width = newWidth;
	[UIView animateWithDuration:0.3 animations:^{
		self.frame = frame;
	}];
}

- (CGFloat)heightAnimate{
	return self.height;
}
- (void)setHeightAnimate:(CGFloat)newHeight{
	CGRect frame = self.frame;
	frame.size.height = newHeight;
	[UIView animateWithDuration:0.3 animations:^{
		self.frame = frame;
	}];
}

- (void)setWidthPercent:(CGFloat)newWidth{
	CGFloat width = 0;
	CGRect frame = self.frame;
	if (self.superview) width = self.superview.frame.size.width * (newWidth / 100);
	frame.size.width = width;
	self.frame = frame;
}

- (void)setHeightPercent:(CGFloat)newHeight{
	CGFloat height = 0;
	CGRect frame = self.frame;
	if (self.superview) height = self.superview.frame.size.height * (newHeight / 100);
	frame.size.height = height;
	self.frame = frame;
}

- (UIColor*)shadow{
	return [UIColor colorWithCGColor:self.layer.shadowColor];
}

- (void)setShadow:(UIColor*)color{
	self.layer.shadowOffset = CGSizeMake(0, 1);
	self.layer.shadowOpacity = 1;
	self.layer.shadowColor = color.CGColor;
	self.layer.shadowRadius = 0;
}

- (void)removeSubviewWithTag:(NSInteger)tag{
	[[self viewWithTag:tag] removeFromSuperview];
}

- (void)removeAllSubviews{
	[self removeAllSubviewsExceptTag:-327865];
}

- (void)removeAllSubviewsExceptTag:(NSInteger)tag{
	for (UIView *subview in self.subviews) {
		if (subview.tag!=MJRefreshViewTag && subview.tag!=(MJRefreshViewTag+1) && subview.tag!=(MJRefreshViewTag+2) //MJRefresh的控件
			&& !([subview isKindOfClass:[UIImageView class]] && (subview.width<3 || subview.height<3)) //UIScrollView的滚动条
			&& subview.tag!=tag) {
			[subview removeFromSuperview];
		}
	}
}

- (void)removeAllDelegate{
	if ([self respondsToSelector:@selector(delegate)]) {
		[self performSelector:@selector(setDelegate:) withObject:nil];
	}
	for (UIView *subview in self.subviews) {
		[subview removeAllDelegate];
	}
}

- (void)shake:(CGFloat)range{
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	animation.duration = 0.5;
	animation.values = @[ @(-range), @(range), @(-range/2), @(range/2), @(-range/5), @(range/5), @(0) ];
	[self.layer addAnimation:animation forKey:@"shake"];
}

- (void)shakeRepeat:(CGFloat)range{
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	animation.duration = 0.6;
	animation.values = @[ @(-range), @(range), @(-range/2), @(range/2), @(-range/5), @(range/5), @(0) ];
	animation.repeatCount = NSIntegerMax;
	[self.layer addAnimation:animation forKey:@"shake"];
}

- (void)shakeX:(CGFloat)range{
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	animation.duration = 0.6;
	animation.values = @[ @(-range), @(range), @(-range/2), @(range/2), @(-range/5), @(range/5), @(0) ];
	[self.layer addAnimation:animation forKey:@"shake"];
}

- (NSInteger)index{
	NSInteger index = 0;
	UIView *superview = self.superview;
	for (int i=0; i<superview.subviews.count; i++) {
		if ([superview.subviews[i] isEqual:self]) return i;
	}
	return index;
}

- (NSInteger)indexOfSubview:(UIView*)view{
	NSInteger index = 0;
	for (UIView *subview in self.subviews) {
		if ([subview isEqual:view]) break;
		index++;
	}
	return index;
}

- (UIView*)subviewAtIndex:(NSInteger)index{
	UIView *subview = nil;
	for (NSInteger i=0; i<self.subviews.count; i++) {
		if (i == index) return self.subviews[i];
	}
	return subview;
}

- (UIView*)firstSubview{
	if (![self isKindOfClass:[UIScrollView class]]) return self.subviews.firstObject;
	for (NSInteger i=0; i<self.subviews.count; i++) {
		UIView *view = self.subviews[i];
		if (view.tag==MJRefreshViewTag || view.tag==(MJRefreshViewTag+1) || view.tag==(MJRefreshViewTag+2) //MJRefresh的控件
			|| ([view isKindOfClass:[UIImageView class]] && (view.width<3 || view.height<3)) //UIScrollView的滚动条
			) continue;
		return view;
	}
	return nil;
}

- (UIView*)lastSubview{
	if (![self isKindOfClass:[UIScrollView class]]) return self.subviews.lastObject;
	UIView *subview = nil;
	for (NSInteger i=0; i<self.subviews.count; i++) {
		UIView *view = self.subviews[i];
		if (view.tag==MJRefreshViewTag || view.tag==(MJRefreshViewTag+1) || view.tag==(MJRefreshViewTag+2)
			|| ([view isKindOfClass:[UIImageView class]] && (view.width<3 || view.height<3)) ) continue;
		subview = view;
	}
	return subview;
}

- (UIView*)prevView{
	UIView *superview = self.superview;
	if (![superview.subviews.firstObject isEqual:self]) {
		UIView *brother = nil;
		for (int i=0; i<superview.subviews.count; i++) {
			UIView *view = superview.subviews[i];
			if (view.tag==MJRefreshViewTag || view.tag==(MJRefreshViewTag+1) || view.tag==(MJRefreshViewTag+2)
				|| ([view isKindOfClass:[UIImageView class]] && (view.width<3 || view.height<3)) ) continue;
			if ([view isEqual:self]) return brother;
			brother = view;
		}
	}
	return nil;
}

- (UIView*)prevView:(NSInteger)count{
	if (count==0) return self;
	if (count<0) return [self nextView:labs(count)];
	UIView *view = self.prevView;
	for (NSInteger i=1; i<count; i++) {
		view = view.prevView;
	}
	return view;
}

- (NSMutableArray*)prevViews{
	NSMutableArray *views = [[NSMutableArray alloc]init];
	UIView *superview = self.superview;
	if (![superview.subviews.firstObject isEqual:self]) {
		for (int i=0; i<superview.subviews.count; i++) {
			UIView *view = superview.subviews[i];
			if (view.tag==MJRefreshViewTag || view.tag==(MJRefreshViewTag+1) || view.tag==(MJRefreshViewTag+2)
				|| ([view isKindOfClass:[UIImageView class]] && (view.width<3 || view.height<3)) ) continue;
			if ([view isEqual:self]) break;
			[views addObject:view];
		}
	}
	return views;
}

- (UIView*)nextView{
	UIView *superview = self.superview;
	if (![superview.subviews.lastObject isEqual:self]) {
		for (int i=0; i<superview.subviews.count; i++) {
			UIView *view = superview.subviews[i];
			if (view.tag==MJRefreshViewTag || view.tag==(MJRefreshViewTag+1) || view.tag==(MJRefreshViewTag+2)
				|| ([view isKindOfClass:[UIImageView class]] && (view.width<3 || view.height<3)) ) continue;
			if ([view isEqual:self]) return superview.subviews[i+1];
		}
	}
	return nil;
}

- (UIView*)nextView:(NSInteger)count{
	if (count==0) return self;
	if (count<0) return [self prevView:labs(count)];
	UIView *view = self.nextView;
	for (NSInteger i=1; i<count; i++) {
		view = view.nextView;
	}
	return view;
}

- (NSMutableArray*)nextViews{
	NSMutableArray *views = [[NSMutableArray alloc]init];
	UIView *superview = self.superview;
	if (![superview.subviews.lastObject isEqual:self]) {
		BOOL start = NO;
		for (int i=0; i<superview.subviews.count; i++) {
			UIView *view = superview.subviews[i];
			if (view.tag==MJRefreshViewTag || view.tag==(MJRefreshViewTag+1) || view.tag==(MJRefreshViewTag+2)
				|| ([view isKindOfClass:[UIImageView class]] && (view.width<3 || view.height<3)) ) continue;
			if (start) [views addObject:view];
			if ([view isEqual:self]) start = YES;
		}
	}
	return views;
}

- (CGRect)frameTop{
	return [self frameTop:0];
}
- (CGRect)frameTop:(CGFloat)margin{
	CGRect frame = self.frame;
	frame.origin.y -= frame.size.height + margin;
	return frame;
}

- (CGRect)frameLeft{
	return [self frameLeft:0];
}
- (CGRect)frameLeft:(CGFloat)margin{
	CGRect frame = self.frame;
	frame.origin.x -= frame.size.width + margin;
	return frame;
}

- (CGRect)frameRight{
	return [self frameRight:0];
}
- (CGRect)frameRight:(CGFloat)margin{
	CGRect frame = self.frame;
	frame.origin.x += frame.size.width + margin;
	return frame;
}

- (CGRect)frameBottom{
	return [self frameBottom:0];
}
- (CGRect)frameBottom:(CGFloat)margin{
	CGRect frame = self.frame;
	frame.origin.y += frame.size.height + margin;
	return frame;
}

- (void)floatRight:(CGFloat)margin{
	CGRect frame = self.frame;
	frame.origin.x = self.superview.frame.size.width - frame.size.width - margin;
	self.frame = frame;
}

- (void)floatBottom:(CGFloat)margin{
	CGRect frame = self.frame;
	frame.origin.y = self.superview.frame.size.height - frame.size.height - margin;
	self.frame = frame;
}

- (NSArray*)allSubviews{
	NSMutableArray *subviews = [[NSMutableArray alloc]init];
	for (UIView *subview in self.subviews) {
		[subviews addObject:subview];
		if (subview.subviews.count) {
			NSArray *arr = subview.allSubviews;
			for (UIView *sv in arr) [subviews addObject:sv];
		}
	}
	return subviews;
}

- (NSArray*)subviewsOfTag:(NSInteger)tag{
	NSMutableArray *subviews = [[NSMutableArray alloc]init];
	for (UIView *subview in self.allSubviews) {
		if (subview.tag == tag) [subviews addObject:subview];
	}
	return subviews;
}

- (NSArray*)subviewsOfClass:(Class)cls{
	NSMutableArray *subviews = [[NSMutableArray alloc]init];
	for (UIView *subview in self.allSubviews) {
		if ([subview isKindOfClass:cls]) [subviews addObject:subview];
	}
	return subviews;
}

- (UIView*)parentOfClass:(Class)cls{
	UIView *parent = self.superview;
	while (![parent isKindOfClass:cls]) {
		parent = parent.superview;
		if (parent==nil) break;
	}
	return parent;
}

- (UIViewController*)parentViewController{
	if (self.superview) {
		for (UIView *next = self.superview; next; next = next.superview) {
			UIResponder *nextResponder = next.nextResponder;
			if ([nextResponder isKindOfClass:[UIViewController class]]) {
				return (UIViewController*)nextResponder;
			}
		}
	} else {
		UIResponder *nextResponder = self.nextResponder;
		if ([nextResponder isKindOfClass:[UIViewController class]]) {
			return (UIViewController*)nextResponder;
		}
	}
	return nil;
}

- (BOOL)hasSubview:(UIView*)subview{
	for (UIView *view in self.allSubviews) {
		if ([view isEqual:subview]) return YES;
	}
	return NO;
}

- (BOOL)hasSubviewOfClass:(Class)cls{
	for (UIView *view in self.allSubviews) {
		if ([view isKindOfClass:cls]) return YES;
	}
	return NO;
}

- (void)aboveToView:(UIView*)view{
	if (view==nil) return;
	if (![self.superview hasSubview:view]) return;
	NSInteger i = [self.superview.subviews indexOfObject:self];
	NSInteger j = [self.superview.subviews indexOfObject:view];
	if (i>j) return;
	for (NSInteger k=0; k<(j-i); k++) {
		[self.superview exchangeSubviewAtIndex:i+k withSubviewAtIndex:i+k+1];
	}
}

- (void)belowToView:(UIView*)view{
	if (view==nil) return;
	if (![self.superview hasSubview:view]) return;
	NSInteger i = [self.superview.subviews indexOfObject:self];
	NSInteger j = [self.superview.subviews indexOfObject:view];
	if (i<j) return;
	for (NSInteger k=0; k<(i-j); k++) {
		[self.superview exchangeSubviewAtIndex:i-k withSubviewAtIndex:i-k-1];
	}
}

- (UIView*)cloneView{
	NSData *tempArchive = [NSKeyedArchiver archivedDataWithRootObject:self];
	return [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
}

- (NSArray*)backgroundColors{
	return nil;
}
//背景色渐变
- (void)setBackgroundColors:(NSArray*)backgroundColors{
	NSMutableArray *colors = [[NSMutableArray alloc]init];
	for (UIColor *color in backgroundColors) {
		if (color) [colors addObject:(id)color.CGColor];
	}
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = self.bounds;
	gradient.colors = colors;
	[self.layer insertSublayer:gradient atIndex:0];
}

- (UIImage*)backgroundImage{
	return [Global imageFromColor:self.backgroundColor size:CGSizeMake(self.width, self.height)];
}
//背景图
- (void)setBackgroundImage:(UIImage*)backgroundImage{
	//self.backgroundColor = [UIColor clearColor];
	self.layer.backgroundColor = (__bridge CGColorRef)([UIColor colorWithPatternImage:backgroundImage]);
}

//渐显与渐隐
- (void)opacityIn:(NSTimeInterval)duration completion:(void (^)())completion{
	[UIView animateWithDuration:duration animations:^{
		self.alpha = 1;
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

- (void)opacityOut:(NSTimeInterval)duration completion:(void (^)())completion{
	[UIView animateWithDuration:duration animations:^{
		self.alpha = 0;
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

- (void)opacityTo:(NSInteger)opacity duration:(NSTimeInterval)duration completion:(void (^)())completion{
	[UIView animateWithDuration:duration animations:^{
		self.alpha = opacity;
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

//渐隐且执行后渐显
- (void)opacityFn:(NSTimeInterval)duration afterHidden:(void (^)())afterHidden completion:(void (^)())completion{
	[UIView animateWithDuration:duration animations:^{
		self.alpha = 0;
	} completion:^(BOOL finished) {
		if (afterHidden!=nil) afterHidden();
		[UIView animateWithDuration:duration animations:^{
			self.alpha = 1;
		} completion:^(BOOL finished) {
			if (completion) completion();
		}];
	}];
}

- (void)fadeIn:(NSTimeInterval)duration completion:(void (^)())completion{
	self.hidden = NO;
	[self opacityIn:duration completion:completion];
}

- (void)fadeOut:(NSTimeInterval)duration completion:(void (^)())completion{
	[self opacityOut:duration completion:^{
		self.hidden = YES;
		if (completion) completion();
	}];
}

//渐隐后删除自身
- (void)removeOut:(NSTimeInterval)duration completion:(void (^)())completion{
	[self opacityOut:duration completion:^{
		[self removeFromSuperview];
		if (completion) completion();
	}];
}

//设置某些角为圆角, UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight
- (void)setRectCorner:(UIRectCorner)rectCorner cornerRadius:(CGFloat)cornerRadius{
	UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
	CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
	maskLayer.frame = self.bounds;
	maskLayer.path = maskPath.CGPath;
	self.layer.mask = maskLayer;
}

//缩放View
- (void)scaleViewWithPercent:(CGFloat)percent{
	if (percent==0) percent = 0.01;
	self.transform = CGAffineTransformMakeScale(percent, percent);
}

//动画缩放View
- (void)scaleAnimateWithTime:(NSTimeInterval)time percent:(CGFloat)percent completion:(void (^)())completion{
	if (percent==0) percent = 0.01;
	[UIView animateWithDuration:time animations:^{
		self.transform = CGAffineTransformMakeScale(percent, percent);
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

//动画缩放View,回弹效果
- (void)scaleAnimateBouncesWithTime:(NSTimeInterval)time percent:(CGFloat)percent completion:(void (^)())completion{
	[self scaleAnimateBouncesWithTime:time percent:percent bounce:0.2 completion:completion];
}
- (void)scaleAnimateBouncesWithTime:(NSTimeInterval)time percent:(CGFloat)percent bounce:(CGFloat)bounce completion:(void (^)())completion{
	if (percent==0) percent = 0.01;
	[self scaleAnimateWithTime:time percent:percent+bounce completion:^{
		[self scaleAnimateWithTime:time percent:percent completion:^{
			if (completion) completion();
		}];
	}];
}

//角度旋转View
- (void)rotatedViewWithDegrees:(CGFloat)degrees{
	self.transform = CGAffineTransformMakeRotation((M_PI*(degrees)/180.0));
}

//指定中心点旋转View, center参数为百分比
- (void)rotatedViewWithDegrees:(CGFloat)degrees center:(CGPoint)center{
	CGRect frame = self.frame;
	self.layer.anchorPoint = center; //设置旋转的中心点
	self.frame = frame; //设置anchorPont会使view的frame改变,需重新赋值
	self.transform = CGAffineTransformMakeRotation((M_PI*(degrees)/180.0));
}

//动画旋转View
- (void)rotatedAnimateWithTime:(NSTimeInterval)time degrees:(CGFloat)degrees completion:(void (^)())completion{
	[UIView animateWithDuration:time animations:^{
		self.transform = CGAffineTransformMakeRotation((M_PI*(degrees)/180.0));
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

//点击
- (void)addTapGestureRecognizerWithTarget:(id)target action:(SEL)action{
	[self addTapGestureRecognizerWithTouches:1 target:target action:action];
}
- (void)addTapGestureRecognizerWithTouches:(NSInteger)touches target:(id)target action:(SEL)action{
	self.userInteractionEnabled = YES;
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
	recognizer.delegate = target;
	recognizer.numberOfTouchesRequired = touches;
	[self addGestureRecognizer:recognizer];
}

//长按
- (void)addLongPressGestureRecognizerWithTarget:(id)target action:(SEL)action{
	[self addLongPressGestureRecognizerWithTouches:1 target:target action:action];
}
- (void)addLongPressGestureRecognizerWithTouches:(NSInteger)touches target:(id)target action:(SEL)action{
	self.userInteractionEnabled = YES;
	UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:action];
	recognizer.delegate = target;
	recognizer.numberOfTouchesRequired = touches;
	[self addGestureRecognizer:recognizer];
}

//拨动
- (void)addSwipeGestureRecognizerWithDirection:(UISwipeGestureRecognizerDirection)direction target:(id)target action:(SEL)action{
	[self addSwipeGestureRecognizerWithDirection:direction touches:1 target:target action:action];
}
- (void)addSwipeGestureRecognizerWithDirection:(UISwipeGestureRecognizerDirection)direction touches:(NSInteger)touches target:(id)target action:(SEL)action{
	self.userInteractionEnabled = YES;
	UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:target action:action];
	recognizer.delegate = target;
	recognizer.direction = direction;
	recognizer.numberOfTouchesRequired = touches;
	[self addGestureRecognizer:recognizer];
}

//划动
- (void)addPanGestureRecognizerWithCompletion:(void (^)(UIPanGestureRecognizerDirection direction))completion{
	if (completion==nil) return;
	self.element[@"completion"] = completion;
	self.userInteractionEnabled = YES;
	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	recognizer.delegate = (id)self.parentViewController;
	recognizer.maximumNumberOfTouches = 1;
	recognizer.delaysTouchesBegan = YES;
	[self addGestureRecognizer:recognizer];
}
- (void)handlePan:(UIPanGestureRecognizer*)recognizer{
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
		case UIGestureRecognizerStateChanged: {
			break;
		}
		case UIGestureRecognizerStateEnded: {
			/*
			 switch (direction) {
				case UIPanGestureRecognizerDirectionUp: {
			 completion(1);
			 break;
				}
				case UIPanGestureRecognizerDirectionDown: {
			 completion(2);
			 break;
				}
				case UIPanGestureRecognizerDirectionLeft: {
			 completion(3);
			 break;
				}
				case UIPanGestureRecognizerDirectionRight: {
			 completion(4);
			 break;
				}
				default: {
			 completion(0);
			 break;
				}
			 }
			 */
			void (^completion)(UIPanGestureRecognizerDirection direction) = self.element[@"completion"];
			completion(direction);
			direction = UIPanGestureRecognizerDirectionUndefined;
			break;
		}
		default:
			break;
	}
}

//旋转
- (void)addRotationGestureRecognizerWithCompletion:(void (^)(NSInteger rotate))completion{
	self.element[@"rotationGesture"] = @YES;
	if (completion) self.element[@"completion"] = completion;
	self.userInteractionEnabled = YES;
	self.multipleTouchEnabled = YES;
	UIRotationGestureRecognizer *recognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
	recognizer.delegate = self;
	[self addGestureRecognizer:recognizer];
}
- (void)handleRotation:(UIRotationGestureRecognizer*)recognizer{
	if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
		recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
		CGFloat rotate = atan2f(recognizer.view.transform.b, recognizer.view.transform.a);
		recognizer.rotation = 0;
		if (self.element[@"completion"]) {
			void (^completion)(NSInteger rotate) = self.element[@"completion"];
			completion(rotate);
		}
	}
}

//张开捏合
- (void)addPinchGestureRecognizerWithCompletion:(void (^)(NSInteger scale))completion{
	self.element[@"pinchGesture"] = @YES;
	if (completion) self.element[@"completion"] = completion;
	self.userInteractionEnabled = YES;
	self.multipleTouchEnabled = YES;
	UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	recognizer.delegate = self;
	[self addGestureRecognizer:recognizer];
}
- (void)handlePinch:(UIPinchGestureRecognizer*)recognizer{
	if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
		CGFloat scale = recognizer.scale;
		recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, scale, scale);
		recognizer.scale = 1;
		if (self.element[@"completion"]) {
			void (^completion)(NSInteger scale) = self.element[@"completion"];
			completion(scale);
		}
	}
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer{
	return gestureRecognizer.view.element[@"rotationGesture"] && otherGestureRecognizer.view.element[@"pinchGesture"];
}

//添加子对象且自动排版,类似于WEB的DIV+CSS自动排版
- (void)autoLayoutSubviews:(NSMutableArray*)subviews marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r{
	if (!subviews.count) return;
	NSNumber *pr = [NSNumber numberWithFloat:0];
	NSNumber *pb = [NSNumber numberWithFloat:0];
	int i = 0;
	for (UIView *subview in subviews) {
		if (i==0) {
			subview.element[@"begin"] = @(YES);
			subview.element[@"first"] = @(YES);
		}
		[self addSubview:subview];
		subview.frame = [self autoXYWithSubview:subview marginPT:t marginPL:l marginPR:r prevRight:&pr prevBottom:&pb];
		i++;
	}
}

//子对象重新自动排版
- (void)autoLayoutSubviewsAgainWithX:(CGFloat)x y:(CGFloat)y marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r{
	if (!self.subviews.count) return;
	NSNumber *pr = [NSNumber numberWithFloat:0];
	NSNumber *pb = [NSNumber numberWithFloat:0];
	int i = 0;
	for (UIView *subview in self.subviews) {
		if (i==0) {
			subview.element[@"begin"] = @(YES);
			subview.element[@"first"] = @(YES);
		} else {
			[subview removeElement:@"begin"];
			[subview removeElement:@"first"];
		}
		CGRect frame = subview.frame;
		frame.origin.x = x;
		frame.origin.y = y;
		frame = [self autoXYWithSubview:subview frame:frame marginPT:t marginPL:l marginPR:r prevRight:&pr prevBottom:&pb];
		[UIView animateWithDuration:0.3 animations:^{
			subview.frame = frame;
		}];
		i++;
	}
}

//添加子对象到指定层且自动排版, index: < 0(从最后向前倒数添加), = NSNotFound(从最后面添加)
- (void)autoLayoutAddSubview:(UIView*)subview atIndex:(NSInteger)index x:(CGFloat)x y:(CGFloat)y marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r completion:(void (^)())completion{
	if (!subview) return;
	if (index>0 && self.subviews.count<=index) index = NSNotFound;
	CGRect frame = subview.frame;
	if (index == NSNotFound) {
		UIView *lastView = self.lastSubview;
		frame.origin.x = lastView.right + x;
		frame.origin.y = lastView.top;
		subview.frame = frame;
		[self addSubview:subview];
	} else {
		NSInteger idx = index;
		if (index < 0) idx = self.subviews.count + index;
		if (idx < 0) idx = 0;
		UIView *prevView = [self subviewAtIndex:idx-1];
		frame.origin.x = prevView.right + x;
		frame.origin.y = prevView.top;
		subview.frame = frame;
		[self insertSubview:subview atIndex:idx];
	}
	NSArray *subviews = self.subviews;
	NSNumber *pr = [NSNumber numberWithFloat:0];
	NSNumber *pb = [NSNumber numberWithFloat:0];
	int i = 0;
	for (UIView *subview in self.subviews) {
		if (i==0) {
			subview.element[@"begin"] = @(YES);
			subview.element[@"first"] = @(YES);
		} else {
			[subview removeElement:@"begin"];
			[subview removeElement:@"first"];
		}
		CGRect frame = subview.frame;
		frame.origin.x = x;
		frame.origin.y = y;
		frame = [self autoXYWithSubview:subview frame:frame marginPT:t marginPL:l marginPR:r prevRight:&pr prevBottom:&pb];
		[UIView animateWithDuration:0.3 animations:^{
			subview.frame = frame;
		} completion:^(BOOL finished) {
			if (completion && i==subviews.count-1) completion();
		}];
		i++;
	}
}

//固定宽度区域内自动调整X、Y坐标(换行),需在循环外部设定prevRight、prevBottom为[NSNumber numberWithFloat:0]
- (CGRect)autoXYWithSubview:(UIView*)subview marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r prevRight:(NSNumber**)pr prevBottom:(NSNumber**)pb{
	return [self autoXYWithSubview:subview frame:subview.frame marginPT:t marginPL:l marginPR:r prevRight:pr prevBottom:pb];
}
- (CGRect)autoXYWithSubview:(UIView*)subview frame:(CGRect)subviewFrame marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r prevRight:(NSNumber**)pr prevBottom:(NSNumber**)pb{
	CGFloat x = [*pr floatValue];
	CGFloat y = [*pb floatValue];
	CGFloat w = floor(subviewFrame.size.width);
	CGFloat h = floor(subviewFrame.size.height);
	if (x==0) x = l;
	if (y==0) y = t;
	if (!subview.element[@"begin"]) x += floor(subviewFrame.origin.x);
	CGRect frame = CGRectMake(x, y, w, h);
	if (x+w > self.width-r) {
		UIView *firstView;
		for (NSInteger i=subview.index-1; i>=0; i--) {
			UIView *prevView = [subview prevView:subview.index-i];
			if ([prevView.element[@"first"] isset]) {
				firstView = prevView;
				break;
			}
		}
		x = l;
		y = floor(firstView.frame.origin.y) + floor(firstView.frame.size.height) + floor(subviewFrame.origin.y);
		frame = CGRectMake(x, y, w, h);
		subview.element[@"first"] = @(YES);
	}
	x += w;
	*pr = [NSNumber numberWithFloat:x];
	*pb = [NSNumber numberWithFloat:y];
	return frame;
}

//创建间隔线
- (UIView*)addGeWithType:(GeLineType)type{
	return [self addGeWithType:type color:COLOR_GE];
}
- (UIView*)addGeWithType:(GeLineType)type color:(UIColor*)color{
	return [self addGeWithType:type color:color wide:0.5];
}
- (UIView*)addGeWithType:(GeLineType)type color:(UIColor*)color wide:(CGFloat)wide{
	UIView *ge;
	CGFloat width = self.width;
	CGFloat height = self.height;
	if (type == GeLineTypeLeftRight) {
		[self removeGeLine:GeLineLeftTag];
		[self removeGeLine:GeLineRightTag];
		ge = [[UIView alloc]initWithFrame:CGRectMake(0, 0, wide, height)];
		ge.backgroundColor = color;
		ge.tag = GeLineLeftTag;
		[self addSubview:ge];
		ge = [[UIView alloc]initWithFrame:CGRectMake(width-wide, 0, wide, height)];
		ge.backgroundColor = color;
		ge.tag = GeLineRightTag;
		[self addSubview:ge];
	} else if (type == GeLineTypeTopBottom) {
		[self removeGeLine:GeLineTopTag];
		[self removeGeLine:GeLineBottomTag];
		ge = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, wide)];
		ge.backgroundColor = color;
		ge.tag = GeLineTopTag;
		[self addSubview:ge];
		ge = [[UIView alloc]initWithFrame:CGRectMake(0, height-wide, width, wide)];
		ge.backgroundColor = color;
		ge.tag = GeLineBottomTag;
		[self addSubview:ge];
	} else if (type == GeLineTypeLeftTop) {
		[self removeGeLine:GeLineLeftTag];
		[self removeGeLine:GeLineTopTag];
		ge = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, wide)];
		ge.backgroundColor = color;
		ge.tag = GeLineTopTag;
		[self addSubview:ge];
		ge = [[UIView alloc]initWithFrame:CGRectMake(0, 0, wide, height)];
		ge.backgroundColor = color;
		ge.tag = GeLineLeftTag;
		[self addSubview:ge];
	} else if (type == GeLineTypeLeftBottom) {
		[self removeGeLine:GeLineLeftTag];
		[self removeGeLine:GeLineBottomTag];
		ge = [[UIView alloc]initWithFrame:CGRectMake(0, height-wide, width, wide)];
		ge.backgroundColor = color;
		ge.tag = GeLineBottomTag;
		[self addSubview:ge];
		ge = [[UIView alloc]initWithFrame:CGRectMake(0, 0, wide, height)];
		ge.backgroundColor = color;
		ge.tag = GeLineLeftTag;
		[self addSubview:ge];
	} else if (type == GeLineTypeRightTop) {
		[self removeGeLine:GeLineRightTag];
		[self removeGeLine:GeLineTopTag];
		ge = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, wide)];
		ge.backgroundColor = color;
		ge.tag = GeLineTopTag;
		[self addSubview:ge];
		ge = [[UIView alloc]initWithFrame:CGRectMake(width-wide, 0, wide, height)];
		ge.backgroundColor = color;
		ge.tag = GeLineRightTag;
		[self addSubview:ge];
	} else if (type == GeLineTypeRightBottom) {
		[self removeGeLine:GeLineRightTag];
		[self removeGeLine:GeLineBottomTag];
		ge = [[UIView alloc]initWithFrame:CGRectMake(0, height-wide, width, wide)];
		ge.backgroundColor = color;
		ge.tag = GeLineBottomTag;
		[self addSubview:ge];
		ge = [[UIView alloc]initWithFrame:CGRectMake(width-wide, 0, wide, height)];
		ge.backgroundColor = color;
		ge.tag = GeLineRightTag;
		[self addSubview:ge];
	} else if (type == GeLineTypeAll) {
		[self removeGeLine:GeLineTopTag];
		[self removeGeLine:GeLineBottomTag];
		[self removeGeLine:GeLineLeftTag];
		[self removeGeLine:GeLineRightTag];
		ge = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, wide)];
		ge.backgroundColor = color;
		ge.tag = GeLineTopTag;
		[self addSubview:ge];
		ge = [[UIView alloc]initWithFrame:CGRectMake(0, height-wide, width, wide)];
		ge.backgroundColor = color;
		ge.tag = GeLineBottomTag;
		[self addSubview:ge];
		ge = [[UIView alloc]initWithFrame:CGRectMake(0, 0, wide, height)];
		ge.backgroundColor = color;
		ge.tag = GeLineLeftTag;
		[self addSubview:ge];
		ge = [[UIView alloc]initWithFrame:CGRectMake(width-wide, 0, wide, height)];
		ge.backgroundColor = color;
		ge.tag = GeLineRightTag;
		[self addSubview:ge];
	} else {
		ge = [[UIView alloc]init];
		switch (type) {
			case GeLineTypeTop:{
				[self removeGeLine:GeLineTopTag];
				ge.frame = CGRectMake(0, 0, width, wide);
				ge.tag = GeLineTopTag;
				break;
			}
			case GeLineTypeBottom:{
				[self removeGeLine:GeLineBottomTag];
				ge.frame = CGRectMake(0, height-wide, width, wide);
				ge.tag = GeLineBottomTag;
				break;
			}
			case GeLineTypeLeft:{
				[self removeGeLine:GeLineLeftTag];
				ge.frame = CGRectMake(0, 0, wide, height);
				ge.tag = GeLineLeftTag;
				break;
			}
			case GeLineTypeRight:{
				[self removeGeLine:GeLineRightTag];
				ge.frame = CGRectMake(width-wide, 0, wide, height);
				ge.tag = GeLineRightTag;
				break;
			}
			default:break;
		}
		ge.backgroundColor = color;
		[self addSubview:ge];
	}
	return ge;
}
//删除间隔线
- (void)removeGeLine{
	[self removeGeLine:0];
}
- (void)removeGeLine:(NSInteger)tag{
	if (tag>0) {
		[[self viewWithTag:tag] removeFromSuperview];
	} else {
		[[self viewWithTag:GeLineTopTag] removeFromSuperview];
		[[self viewWithTag:GeLineBottomTag] removeFromSuperview];
		[[self viewWithTag:GeLineLeftTag] removeFromSuperview];
		[[self viewWithTag:GeLineRightTag] removeFromSuperview];
	}
}

//转为UIImage
- (UIImage*)toImage{
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

//点击绑定block
- (void)click:(void(^)(UIView *view, UIGestureRecognizer *sender))block{
	if (!block) return;
	self.element[@"block"] = block;
	[self addTapGestureRecognizerWithTarget:self action:@selector(onClick:)];
}
- (void)onClick:(UIGestureRecognizer*)sender{
	//CGPoint point = [sender locationInView:self]; //获取触点在视图中的坐标
	void(^block)(UIView *view, UIGestureRecognizer *sender) = sender.view.element[@"block"];
	block(sender.view, sender);
}

//长按绑定block
- (void)longClick:(void(^)(UIView *view, UIGestureRecognizer *sender))block{
	if (!block) return;
	self.element[@"block"] = block;
	[self addLongPressGestureRecognizerWithTarget:self action:@selector(onLongClick:)];
}
- (void)onLongClick:(UIGestureRecognizer*)sender{
	if (sender.state == UIGestureRecognizerStateBegan) {
		void(^block)(UIView *view, UIGestureRecognizer *sender) = sender.view.element[@"block"];
		block(sender.view, sender);
	}
}

//长按后拖曳排序
- (void)subviewsDragSortWithTarget:(id<SubviewsDragSortDelegate>)target{
	[self subviewsDragSortWithTarget:target withOut:nil];
}
- (void)subviewsDragSortWithTarget:(id<SubviewsDragSortDelegate>)target withOut:(id)withOutView{
	if (target) self.element[@"target"] = target;
	if (withOutView) self.element[@"withOutView"] = withOutView;
	NSArray *subviews = self.subviews;
	for (int i=0; i<subviews.count; i++) {
		if (withOutView && [subviews[i] isEqual:withOutView]) continue;
		UIView *view = subviews[i];
		if (view.element[@"bindDragSort"]) continue;
		view.element[@"bindDragSort"] = @YES;
		if (!view.tag) view.tag = 4527 + i;
		view.userInteractionEnabled = YES;
		UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressDragSort:)];
		[view addGestureRecognizer:lp];
	}
}
- (void)longPressDragSort:(UIGestureRecognizer*)recognizer{
	id<SubviewsDragSortDelegate> target = self.element[@"target"];
	id withOutView = self.element[@"withOutView"];
	UIView *view = recognizer.view;
	CGPoint point = [recognizer locationInView:self];
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		if (target && [target respondsToSelector:@selector(subviewsDragSortStateStart:)]) {
			[target subviewsDragSortStateStart:self];
		}
		//禁用其他兄弟的拖拽手势
		for (UIView *subview in self.subviews) {
			if (withOutView && [subview isEqual:withOutView]) continue;
			if (subview!=view) subview.userInteractionEnabled = NO;
		}
		//开始的时候改变拖动view的外观(放大，改变颜色等)
		[UIView animateWithDuration:0.2 animations:^{
			view.transform = CGAffineTransformMakeScale(1.3, 1.3);
			view.alpha = 0.7;
		}];
		CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
		shakeAnimation.duration = 0.08;
		shakeAnimation.autoreverses = YES;
		shakeAnimation.repeatCount = MAXFLOAT;
		shakeAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(view.layer.transform, -0.06, 0, 0, 1)];
		shakeAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(view.layer.transform, 0.06, 0, 0, 1)];
		[view.layer addAnimation:shakeAnimation forKey:@"shakeAnimation"];
		//把拖动view放到最上层
		[self bringSubviewToFront:view];
		//保存最新的移动位置
		view.element[@"valuePoint"] = NSStringFromCGPoint(view.center);
	} else if (recognizer.state == UIGestureRecognizerStateChanged) {
		//更新拖动view的center
		view.center = point;
		for (UIView *subview in self.subviews) {
			if (withOutView && [subview isEqual:withOutView]) continue;
			//判断是否移动到另一个view区域
			//CGRectContainsPoint(rect,point) 判断某个点是否被某个frame包含
			if (CGRectContainsPoint(subview.frame, view.center) && subview!=view) {
				view.element[@"index"] = @([self.subviews indexOfObject:subview]);
				NSInteger fromIndex = view.tag;
				NSInteger toIndex = subview.tag;
				if (toIndex > fromIndex) {
					//往后移动
					//从开始位置移动到结束位置
					//把拖动view的下一个subview移动到记录的view位置(valuePoint),并把subview的位置记为新的nextPoint,并把subview的tag值-1,依次类推
					[UIView animateWithDuration:0.2 animations:^{
						CGPoint valuePoint = CGPointFromString(view.element[@"valuePoint"]);
						CGPoint nextPoint;
						for (NSInteger i=fromIndex+1; i<=toIndex; i++) {
							UIView *next = [self viewWithTag:i];
							nextPoint = next.center;
							next.center = valuePoint;
							valuePoint = nextPoint;
							next.tag--;
						}
						view.tag = toIndex;
						view.element[@"valuePoint"] = NSStringFromCGPoint(valuePoint);
					} completion:^(BOOL finished) {
						if (target && [target respondsToSelector:@selector(subviewsDragSortStateChanged:fromIndex:toIndex:)]) {
							[target subviewsDragSortStateChanged:self fromIndex:fromIndex toIndex:toIndex];
							//id obj = array[fromIndex];
							//[array removeObjectAtIndex:fromIndex];
							//[array insertObject:obj atIndex:toIndex];
						}
					}];
				} else {
					//往前移动
					//从开始位置移动到结束位置
					//把拖动view的上一个subview移动到记录的view的位置(valuePoint),并把subview的位置记为新的nextPoint,并把view的tag值+1,依次类推
					[UIView animateWithDuration:0.2 animations:^{
						CGPoint valuePoint = CGPointFromString(view.element[@"valuePoint"]);
						CGPoint nextPoint;
						for (NSInteger i=fromIndex-1; i>=toIndex; i--) {
							UIView *next = [self viewWithTag:i];
							nextPoint = next.center;
							next.center = valuePoint;
							valuePoint = nextPoint;
							next.tag++;
						}
						view.tag = toIndex;
						view.element[@"valuePoint"] = NSStringFromCGPoint(valuePoint);
					} completion:^(BOOL finished) {
						if (target && [target respondsToSelector:@selector(subviewsDragSortStateChanged:fromIndex:toIndex:)]) {
							[target subviewsDragSortStateChanged:self fromIndex:fromIndex toIndex:toIndex];
						}
					}];
				}
			}
		}
	} else if (recognizer.state == UIGestureRecognizerStateEnded) {
		//恢复其他兄弟的拖拽手势
		for (UIView *subview in self.subviews) {
			if (withOutView && [subview isEqual:withOutView]) continue;
			if (subview!=view) subview.userInteractionEnabled = YES;
		}
		//结束的时候恢复拖动view的外观(放大，改变颜色等)
		[UIView animateWithDuration:0.2 animations:^{
			view.transform = CGAffineTransformMakeScale(1.0, 1.0);
			view.alpha = 1;
			view.center = CGPointFromString(view.element[@"valuePoint"]);
		} completion:^(BOOL finished) {
			[self insertSubview:view atIndex:[view.element[@"index"]integerValue]];
			if (target && [target respondsToSelector:@selector(subviewsDragSortStateEnd:)]) {
				[target subviewsDragSortStateEnd:self];
			}
		}];
		[view.layer removeAnimationForKey:@"shakeAnimation"];
	}
}

//增加磨砂玻璃效果
- (void)blur{
	UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	CIContext *context = [CIContext contextWithOptions:nil];
	CIImage *imageToBlur = [CIImage imageWithCGImage:viewImage.CGImage];
	CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
	[gaussianBlurFilter setValue:imageToBlur forKey: @"inputImage"];
	[gaussianBlurFilter setValue:[NSNumber numberWithFloat: 15] forKey: @"inputRadius"];
	CIImage *resultImage = [gaussianBlurFilter valueForKey: @"outputImage"];
	CGImageRef cgImage = [context createCGImage:resultImage fromRect:self.bounds];
	UIImage *blurredImage = [UIImage imageWithCGImage:cgImage];
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
	imageView.tag = -1;
	imageView.image = blurredImage;
	UIView *overlay = [[UIView alloc] initWithFrame:self.bounds];
	overlay.tag = -2;
	overlay.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
	[self addSubview:imageView];
	[self addSubview:overlay];
}
- (void)Unblur{
	[[self viewWithTag:-1] removeFromSuperview];
	[[self viewWithTag:-2] removeFromSuperview];
}
@end
