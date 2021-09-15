//
//  GestureRecognizerView.m
//
//  Created by ajsong on 15/4/21.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "GestureRecognizerView.h"
#import <objc/runtime.h>

@implementation GestureRecognizerView

//点击
- (void)addTapGestureRecognizerWithTarget:(id)target action:(SEL)action{
	self.userInteractionEnabled = YES;
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
	[self addGestureRecognizer:recognizer];
}

//长按
- (void)addLongPressGestureRecognizerWithTarget:(id)target action:(SEL)action{
	self.userInteractionEnabled = YES;
	UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:action];
	[self addGestureRecognizer:recognizer];
}

//拨动, 0:no, 1:up, 2:down, 3:left, 4:right
- (void)addPanGestureRecognizerWithCompletion:(void (^)(NSInteger direction))completion{
	if (completion==nil) return;
	[self element:self][@"direction"] = @0;
	[self element:self][@"completion"] = completion;
	self.userInteractionEnabled = YES;
	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[self addGestureRecognizer:recognizer];
}
- (void)handlePan:(UIPanGestureRecognizer*)recognizer{
	CGPoint translation = [recognizer translationInView:recognizer.view];
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		[self element:self][@"direction"] = @0;
	} else if (recognizer.state == UIGestureRecognizerStateChanged) {
		NSInteger direction = [self getMoveDirectionWithTranslation:translation direction:[[self element:self][@"direction"] integerValue]];
		[self element:self][@"direction"] = @(direction);
	} else if (recognizer.state == UIGestureRecognizerStateEnded) {
		NSInteger direction = [[self element:self][@"direction"] integerValue];
		void (^completion)(NSInteger direction) = [self element:self][@"completion"];
		completion(direction);
	}
}

//旋转
- (void)addRotationGestureRecognizerWithCompletion:(void (^)(NSInteger rotate))completion{
	[self element:self][@"rotationGesture"] = @YES;
	if (completion) [self element:self][@"completion"] = completion;
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
		if ([self element:self][@"completion"]) {
			void (^completion)(NSInteger rotate) = [self element:self][@"completion"];
			completion(rotate);
		}
	}
}

//张开捏合
- (void)addPinchGestureRecognizerWithCompletion:(void (^)(NSInteger scale))completion{
	[self element:self][@"pinchGesture"] = @YES;
	if (completion) [self element:self][@"completion"] = completion;
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
		if ([self element:self][@"completion"]) {
			void (^completion)(NSInteger scale) = [self element:self][@"completion"];
			completion(scale);
		}
	}
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer{
	return [self element:gestureRecognizer.view][@"rotationGesture"] && [self element:otherGestureRecognizer.view][@"pinchGesture"];
}

//移动
- (void)addDragGestureRecognizerWithOutParent:(BOOL)outParent completion:(void (^)(CGPoint center))completion{
	self.userInteractionEnabled = YES;
	[self element:self][@"dragGesture"] = @YES;
	[self element:self][@"outParent"] = @(outParent);
	if (completion) [self element:self][@"completion"] = completion;
	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(emptyDrag:)];
	recognizer.cancelsTouchesInView = NO;
	[self addGestureRecognizer:recognizer];
}
- (void)emptyDrag:(UIPanGestureRecognizer*)recognizer{
	return;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	if (![self element:self][@"dragGesture"]) return;
	CGPoint startPoint = [[touches anyObject] locationInView:self];
	[self element:self][@"startPoint"] = [NSValue valueWithCGPoint:startPoint];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	if (![self element:self][@"dragGesture"]) return;
	CGPoint startPoint = [[self element:self][@"startPoint"] CGPointValue];
	BOOL outParent = [[self element:self][@"outParent"] boolValue];
	CGPoint lastPoint = [[touches anyObject] locationInView:self];
	CGFloat dx = lastPoint.x - startPoint.x;
	CGFloat dy = lastPoint.y - startPoint.y;
	CGPoint newCenter = CGPointMake(self.center.x+dx, self.center.y+dy);
	if (_delegate && [_delegate respondsToSelector:@selector(dragGestureRecognizerViewWithMoveInMaxArea:)]) {
		UIEdgeInsets edgeInsets = [_delegate dragGestureRecognizerViewWithMoveInMaxArea:self];
		CGFloat halfX = CGRectGetMidX(self.bounds);
		CGFloat halfY = CGRectGetMidY(self.bounds);
		newCenter.x = MIN(edgeInsets.right-halfX, MAX(edgeInsets.left, newCenter.x));
		newCenter.y = MIN(edgeInsets.bottom-halfY, MAX(edgeInsets.top, newCenter.y));
	} else {
		if (!outParent) {
			CGFloat halfX = CGRectGetMidX(self.bounds);
			CGFloat halfY = CGRectGetMidY(self.bounds);
			newCenter.x = MIN(self.superview.bounds.size.width-halfX, MAX(halfX, newCenter.x));
			newCenter.y = MIN(self.superview.bounds.size.height-halfY, MAX(halfY, newCenter.y));
		}
	}
	self.center = newCenter;
	if (_delegate && [_delegate respondsToSelector:@selector(dragGestureRecognizerViewWithMove:)]) {
		[_delegate dragGestureRecognizerViewWithMove:self];
	}
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	if (![self element:self][@"dragGesture"]) return;
	if ([self element:self][@"completion"]) {
		void (^completion)(CGPoint center) = [self element:self][@"completion"];
		completion(self.center);
	}
}

- (NSMutableDictionary*)element:(UIView*)view{
	NSMutableDictionary *ele = objc_getAssociatedObject(view, @"element");
	if (!ele) {
		ele = [[NSMutableDictionary alloc]init];
		objc_setAssociatedObject(view, @"element", ele, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return ele;
}

- (NSInteger)getMoveDirectionWithTranslation:(CGPoint)translation direction:(NSInteger)direction{
	CGFloat gestureMinimumTranslation = 50.f;
	if (direction != 0) return direction;
	if (fabs(translation.x) > gestureMinimumTranslation) {
		BOOL gestureHorizontal = (translation.y==0.0) ? YES : (fabs(translation.x / translation.y) > 5.0);
		if (gestureHorizontal) {
			if (translation.x > 0.0) return 4;
			else return 3;
		}
	} else if (fabs(translation.y) > gestureMinimumTranslation) {
		BOOL gestureVertical = (translation.x==0.0) ? YES : (fabs(translation.y / translation.x) > 5.0);
		if (gestureVertical) {
			if (translation.y > 0.0) return 2;
			else return 1;
		}
	}
	return direction;
}

@end
