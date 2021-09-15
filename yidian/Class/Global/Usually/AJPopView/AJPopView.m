//
//  AJPopView.m
//
//  Created by ajsong on 15/9/22.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "AJPopView.h"

#define kAJPopMargin 7
#define kTriangleThickness 10

@interface AJPopView (){
	UIView *_parentView;
	UIView *_overlay;
	UIView *_fromView;
	void (^_close)();
	void (^_willShow)();
	void (^_willClose)();
}
@end

@implementation AJPopView

- (instancetype)initInView:(UIView*)parentView{
	return [self initInView:parentView fromPoint:CGPointZero];
}

- (instancetype)initInView:(UIView*)parentView pointFromView:(UIView*)fromView{
	CGPoint fromPoint = CGPointZero;
	_fromView = fromView;
	if (_fromView) {
		CGRect rect = [_fromView convertRect:_fromView.frame toView:nil];
		fromPoint = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height + kAJPopMargin);
	}
	return [self initInView:parentView fromPoint:fromPoint];
}

- (instancetype)initInView:(UIView*)parentView fromPoint:(CGPoint)fromPoint{
	self = [super init];
	if (self) {
		_parentView = parentView;
		_contentOffset = CGPointMake(fromPoint.x, fromPoint.y);
		_backgroundAlpha = 0.4;
		//_animateType = AJPopViewAnimateTypeSlide;
		_animateDuration = 0.3;
		_triangleOffset = UIOffsetMake(0, 0);
		_close = nil;
		_willShow = nil;
		_willClose = nil;
		[self performSelector:@selector(loadViews) withObject:nil afterDelay:0];
	}
	return self;
}

- (void)setPointFromView:(UIView *)pointFromView{
	CGPoint fromPoint = CGPointZero;
	_fromView = pointFromView;
	if (_fromView) {
		CGRect rect = [_fromView convertRect:_fromView.bounds toView:nil];
		fromPoint = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height + kAJPopMargin);
	}
	_contentOffset = CGPointMake(fromPoint.x, fromPoint.y);
}

- (void)setIsFullscreen:(BOOL)isFullscreen{
	_isFullscreen = isFullscreen;
	if (!_overlay) return;
	CGRect frame = _overlay.frame;
	frame.origin.y = 0;
	frame.size.height = _parentView.frame.size.height;
	_overlay.frame = frame;
}

- (void)loadViews{
	if (!_view) {
		NSLog(@"请设置view对象");
		return;
	}
	
	CGPoint contentOffset = _contentOffset;
	CGFloat triangleThickness = 0;
	CGRect selfFrame = _view.frame;
	CGRect contentFrame = _view.frame;
	contentFrame.origin.x = 0;
	contentFrame.origin.y = 0;
	if (_triangleColor) {
		triangleThickness = kTriangleThickness;
		switch (_trianglePosition) {
			case AJPopViewTriangleTop:{
				contentOffset.y -= triangleThickness;
				contentFrame.origin.y = triangleThickness;
				break;
			}
			case AJPopViewTriangleLeft:{
				contentOffset.x -= triangleThickness;
				selfFrame.size.width += triangleThickness;
				contentFrame.origin.x = triangleThickness;
				break;
			}
			case AJPopViewTriangleBottom:{
				break;
			}
			case AJPopViewTriangleRight:{
				selfFrame.size.width += triangleThickness;
				break;
			}
		}
	}
	
	CGRect rect = CGRectMake(contentOffset.x, contentOffset.y, selfFrame.size.width, 0);
	if (_fromView) rect.origin.x += (_fromView.frame.size.width - rect.size.width) / 2;
	if (rect.origin.x < 0) rect.origin.x = kAJPopMargin;
	self.frame = rect;
	self.hidden = YES;
	
	CGFloat overlayTop = _contentOffset.y;
	CGFloat overlayHeight = _parentView.frame.size.height - _contentOffset.y;
	if (_isFullscreen || _backgroundAlpha <= 0.f) {
		overlayTop = 0;
		overlayHeight = _parentView.frame.size.height;
	}
	_overlay = [[UIView alloc]initWithFrame:CGRectMake(0, overlayTop, _parentView.frame.size.width, overlayHeight)];
	_overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:_backgroundAlpha];
	_overlay.alpha = 0;
	_overlay.hidden = YES;
	_overlay.userInteractionEnabled = YES;
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(close)];
	[_overlay addGestureRecognizer:tap];
	[_parentView addSubview:_overlay];
	
	UIColor *backgroundColor = _view.backgroundColor;
	CGRect frame = _view.frame;
	frame.origin.x = 0;
	frame.origin.y = 0;
	_view.frame = frame;
	if (_popHeight && _popHeight<frame.size.height) {
		_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(contentFrame.origin.x, contentFrame.origin.y, frame.size.width, _popHeight)];
		_scrollView.contentSize = CGSizeMake(frame.size.width, frame.size.height);
		_scrollView.backgroundColor = backgroundColor;
		[_scrollView addSubview:_view];
		_view.backgroundColor = [UIColor clearColor];
		[self addSubview:_scrollView];
	} else {
		if (!_popHeight) _popHeight = frame.size.height;
		if (_popHeight>_parentView.frame.size.height-_contentOffset.y) {
			_popHeight = _parentView.frame.size.height - _contentOffset.y;
			_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(contentFrame.origin.x, contentFrame.origin.y, frame.size.width, _popHeight)];
			_scrollView.contentSize = CGSizeMake(frame.size.width, frame.size.height);
			_scrollView.backgroundColor = backgroundColor;
			[_scrollView addSubview:_view];
			_view.backgroundColor = [UIColor clearColor];
			[self addSubview:_scrollView];
		} else {
			frame.origin.x = contentFrame.origin.x;
			frame.origin.y = contentFrame.origin.y;
			_view.frame = frame;
			[self addSubview:_view];
		}
	}
	[_parentView addSubview:self];
	
	if (_triangleColor) {
		UIBezierPath *bezierPath = [UIBezierPath bezierPath];
		switch (_trianglePosition) {
			case AJPopViewTriangleTop:{
				[bezierPath moveToPoint:CGPointMake(_triangleOffset.horizontal, triangleThickness)];
				[bezierPath addLineToPoint:CGPointMake(_triangleOffset.horizontal+triangleThickness, 0)];
				[bezierPath addLineToPoint:CGPointMake(_triangleOffset.horizontal+triangleThickness*2, triangleThickness)];
				break;
			}
			case AJPopViewTriangleLeft:{
				[bezierPath moveToPoint:CGPointMake(triangleThickness, _triangleOffset.vertical)];
				[bezierPath addLineToPoint:CGPointMake(0, _triangleOffset.vertical+triangleThickness)];
				[bezierPath addLineToPoint:CGPointMake(triangleThickness, _triangleOffset.vertical+triangleThickness*2)];
				break;
			}
			case AJPopViewTriangleBottom:{
				[bezierPath moveToPoint:CGPointMake(_triangleOffset.horizontal, _popHeight)];
				[bezierPath addLineToPoint:CGPointMake(_triangleOffset.horizontal+triangleThickness, _popHeight+triangleThickness)];
				[bezierPath addLineToPoint:CGPointMake(_triangleOffset.horizontal+triangleThickness*2, _popHeight)];
				break;
			}
			case AJPopViewTriangleRight:{
				[bezierPath moveToPoint:CGPointMake(frame.size.width, _triangleOffset.vertical)];
				[bezierPath addLineToPoint:CGPointMake(frame.size.width+triangleThickness, _triangleOffset.vertical+triangleThickness)];
				[bezierPath addLineToPoint:CGPointMake(frame.size.width, _triangleOffset.vertical+triangleThickness*2)];
				break;
			}
		}
		[bezierPath closePath];
		CAShapeLayer *shapeLayer = [CAShapeLayer layer];
		shapeLayer.path = bezierPath.CGPath;
		shapeLayer.fillColor = _triangleColor.CGColor;
		if (_triangleBorderColor) shapeLayer.strokeColor = _triangleBorderColor.CGColor;
		shapeLayer.frame = self.bounds;
		[self.layer addSublayer:shapeLayer];
	}
}

- (void)setBackgroundAlpha:(CGFloat)backgroundAlpha{
	_backgroundAlpha = backgroundAlpha;
	_overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:_backgroundAlpha];
}

- (void)setPopHeight:(CGFloat)popHeight{
	_popHeight = popHeight;
}

- (void)showAuto{
	_willShow = nil;
	_willClose = nil;
	[self showAuto:nil close:nil];
}
- (void)showAuto:(void (^)())show close:(void (^)())close{
	_willShow = nil;
	_willClose = nil;
	if (self.isHidden) {
		[self show:show];
		_close = close;
	} else {
		[self close:close];
	}
}
- (void)willShowAuto:(void (^)())show close:(void (^)())close{
	if (self.isHidden) {
		_willShow = show;
		_willClose = close;
		_close = nil;
		[self show:nil];
	} else {
		[self close:nil];
	}
}

- (void)show{
	_willShow = nil;
	_willClose = nil;
	[self show:nil];
}
- (void)show:(void (^)())completion{
	[_parentView bringSubviewToFront:_overlay];
	[_parentView bringSubviewToFront:self];
	if (_willShow) _willShow();
	self.hidden = NO;
	CGRect frame = self.frame;
	frame.size.height = _popHeight + ((_triangleColor && _trianglePosition==AJPopViewTriangleBottom)?kTriangleThickness:0);
	if (frame.origin.x + frame.size.width >= _parentView.bounds.size.width) {
		frame.origin.x = _parentView.bounds.size.width - frame.size.width - kAJPopMargin;
	}
	if (frame.origin.y + frame.size.height >= _parentView.bounds.size.height) {
		if (frame.origin.y - frame.size.height - kAJPopMargin > 0) {
			frame.origin.y -= frame.size.height + kAJPopMargin;
		}
	}
	_overlay.hidden = NO;
	switch (_animateType) {
		case AJPopViewAnimateTypeAlpha:{
			self.frame = frame;
			self.alpha = 0;
			[UIView animateWithDuration:_animateDuration animations:^{
				self.alpha = 1;
				_overlay.alpha = 1;
			} completion:^(BOOL finished) {
				if (completion) completion();
			}];
			break;
		}
		case AJPopViewAnimateTypeScale:{
			self.frame = frame;
			self.alpha = 0;
			self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
			[UIView animateWithDuration:_animateDuration animations:^{
				self.alpha = 1;
				_overlay.alpha = 1;
				self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
			} completion:^(BOOL finished) {
				if (completion) completion();
			}];
			break;
		}
		case AJPopViewAnimateTypeSlide:{
			self.clipsToBounds = YES;
			[UIView animateWithDuration:_animateDuration animations:^{
				self.frame = frame;
				_overlay.alpha = 1;
			} completion:^(BOOL finished) {
				self.clipsToBounds = NO;
				if (completion) completion();
			}];
			break;
		}
		default:{
			self.frame = frame;
			_overlay.alpha = 1;
			if (completion) completion();
			break;
		}
	}
}

- (void)close{
	[self close:_close];
}
- (void)close:(void (^)())completion{
	if (_willClose) _willClose();
	switch (_animateType) {
		case AJPopViewAnimateTypeAlpha:{
			[UIView animateWithDuration:_animateDuration animations:^{
				self.alpha = 0;
				_overlay.alpha = 0;
			} completion:^(BOOL finished) {
				self.hidden = YES;
				_overlay.hidden = YES;
				if (completion) completion();
			}];
			break;
		}
		case AJPopViewAnimateTypeScale:{
			[UIView animateWithDuration:_animateDuration animations:^{
				self.alpha = 0;
				_overlay.alpha = 0;
				self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
			} completion:^(BOOL finished) {
				self.hidden = YES;
				_overlay.hidden = YES;
				self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
				if (completion) completion();
			}];
			break;
		}
		case AJPopViewAnimateTypeSlide:{
			self.clipsToBounds = YES;
			CGRect frame = self.frame;
			frame.size.height = 0;
			[UIView animateWithDuration:_animateDuration animations:^{
				self.frame = frame;
				_overlay.alpha = 0;
			} completion:^(BOOL finished) {
				self.hidden = YES;
				_overlay.hidden = YES;
				self.clipsToBounds = NO;
				if (completion) completion();
			}];
			break;
		}
		default:{
			_overlay.hidden = YES;
			self.hidden = YES;
			if (completion) completion();
			break;
		}
	}
}

@end
