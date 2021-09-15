//
//  UIView+Extend.h
//
//  Created by ajsong on 15/10/9.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SubviewsDragSortDelegate<NSObject>
@optional
- (void)subviewsDragSortStateStart:(UIView*)view;
- (void)subviewsDragSortStateChanged:(UIView*)view fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (void)subviewsDragSortStateEnd:(UIView*)view;
@end

#pragma mark - UIView+Extend
typedef enum : NSInteger {
	UIPanGestureRecognizerDirectionUndefined = 0,
	UIPanGestureRecognizerDirectionUp,
	UIPanGestureRecognizerDirectionDown,
	UIPanGestureRecognizerDirectionLeft,
	UIPanGestureRecognizerDirectionRight,
} UIPanGestureRecognizerDirection;
typedef enum : NSInteger {
	GeLineTypeTop = 0,
	GeLineTypeBottom,
	GeLineTypeLeft,
	GeLineTypeRight,
	GeLineTypeTopBottom,
	GeLineTypeLeftRight,
	GeLineTypeLeftTop,
	GeLineTypeLeftBottom,
	GeLineTypeRightTop,
	GeLineTypeRightBottom,
	GeLineTypeAll,
} GeLineType;
typedef enum : NSInteger {
	GeLineTopTag = 58797263,
	GeLineBottomTag,
	GeLineLeftTag,
	GeLineRightTag,
} GeLineTag;
@interface UIView (GlobalExtend)<UIGestureRecognizerDelegate>
- (CGFloat)left;
- (CGFloat)top;
- (CGFloat)right;
- (CGFloat)bottom;
- (CGFloat)width;
- (CGFloat)height;
- (CGPoint)origin;
- (CGSize)size;
- (CGFloat)getLeftUntil:(UIView*)view;
- (CGFloat)getTopUntil:(UIView*)view;
- (CGFloat)getWidthPercent:(CGFloat)percent;
- (CGFloat)getHeightPercent:(CGFloat)percent;
- (CGPoint)offset;
- (void)setLeft:(CGFloat)newLeft;
- (void)setTop:(CGFloat)newTop;
- (void)setRight:(CGFloat)newRight;
- (void)setBottom:(CGFloat)newBottom;
- (void)setWidth:(CGFloat)newWidth;
- (void)setHeight:(CGFloat)newHeight;
- (void)setOrigin:(CGPoint)newOrigin;
- (void)setSize:(CGSize)newSize;
- (void)centerX;
- (void)centerY;
- (void)centerXY;
- (CGFloat)leftAnimate;
- (void)setLeftAnimate:(CGFloat)newLeft;
- (CGFloat)topAnimate;
- (void)setTopAnimate:(CGFloat)newTop;
- (CGFloat)widthAnimate;
- (void)setWidthAnimate:(CGFloat)newWidth;
- (CGFloat)heightAnimate;
- (void)setHeightAnimate:(CGFloat)newHeight;
- (void)setWidthPercent:(CGFloat)newWidth;
- (void)setHeightPercent:(CGFloat)newHeight;
- (UIColor*)shadow;
- (void)setShadow:(UIColor*)color;
- (void)removeSubviewWithTag:(NSInteger)tag;
- (void)removeAllSubviews;
- (void)removeAllSubviewsExceptTag:(NSInteger)tag;
- (void)removeAllDelegate;
- (void)shake:(CGFloat)range;
- (void)shakeRepeat:(CGFloat)range;
- (void)shakeX:(CGFloat)range;
- (NSInteger)index;
- (NSInteger)indexOfSubview:(UIView*)view;
- (UIView*)subviewAtIndex:(NSInteger)index;
- (UIView*)firstSubview;
- (UIView*)lastSubview;
- (UIView*)prevView;
- (UIView*)prevView:(NSInteger)count;
- (NSMutableArray*)prevViews;
- (UIView*)nextView;
- (UIView*)nextView:(NSInteger)count;
- (NSMutableArray*)nextViews;
- (CGRect)frameTop;
- (CGRect)frameTop:(CGFloat)margin;
- (CGRect)frameLeft;
- (CGRect)frameLeft:(CGFloat)margin;
- (CGRect)frameRight;
- (CGRect)frameRight:(CGFloat)margin;
- (CGRect)frameBottom;
- (CGRect)frameBottom:(CGFloat)margin;
- (void)floatRight:(CGFloat)margin;
- (void)floatBottom:(CGFloat)margin;
- (NSArray*)allSubviews;
- (NSArray*)subviewsOfTag:(NSInteger)tag;
- (NSArray*)subviewsOfClass:(Class)cls;
- (UIView*)parentOfClass:(Class)cls;
- (UIViewController*)parentViewController;
- (BOOL)hasSubview:(UIView*)subview;
- (BOOL)hasSubviewOfClass:(Class)cls;
- (void)aboveToView:(UIView*)view;
- (void)belowToView:(UIView*)view;
- (UIView*)cloneView;
- (NSArray*)backgroundColors;
- (void)setBackgroundColors:(NSArray*)backgroundColors;
- (UIImage*)backgroundImage;
- (void)setBackgroundImage:(UIImage*)backgroundImage;
- (void)opacityIn:(NSTimeInterval)duration completion:(void (^)())completion;
- (void)opacityOut:(NSTimeInterval)duration completion:(void (^)())completion;
- (void)opacityTo:(NSInteger)opacity duration:(NSTimeInterval)duration completion:(void (^)())completion;
- (void)opacityFn:(NSTimeInterval)duration afterHidden:(void (^)())afterHidden completion:(void (^)())completion;
- (void)fadeIn:(NSTimeInterval)duration completion:(void (^)())completion;
- (void)fadeOut:(NSTimeInterval)duration completion:(void (^)())completion;
- (void)removeOut:(NSTimeInterval)duration completion:(void (^)())completion;
- (void)scaleViewWithPercent:(CGFloat)percent;
- (void)scaleAnimateWithTime:(NSTimeInterval)time percent:(CGFloat)percent completion:(void (^)())completion;
- (void)scaleAnimateBouncesWithTime:(NSTimeInterval)time percent:(CGFloat)percent completion:(void (^)())completion;
- (void)scaleAnimateBouncesWithTime:(NSTimeInterval)time percent:(CGFloat)percent bounce:(CGFloat)bounce completion:(void (^)())completion;
- (void)rotatedViewWithDegrees:(CGFloat)degrees;
- (void)rotatedViewWithDegrees:(CGFloat)degrees center:(CGPoint)center;
- (void)rotatedAnimateWithTime:(NSTimeInterval)time degrees:(CGFloat)degrees completion:(void (^)())completion;
- (void)setRectCorner:(UIRectCorner)rectCorner cornerRadius:(CGFloat)cornerRadius;
- (void)addTapGestureRecognizerWithTarget:(id)target action:(SEL)action;
- (void)addTapGestureRecognizerWithTouches:(NSInteger)touches target:(id)target action:(SEL)action;
- (void)addLongPressGestureRecognizerWithTarget:(id)target action:(SEL)action;
- (void)addLongPressGestureRecognizerWithTouches:(NSInteger)touches target:(id)target action:(SEL)action;
- (void)addSwipeGestureRecognizerWithDirection:(UISwipeGestureRecognizerDirection)direction target:(id)target action:(SEL)action;
- (void)addSwipeGestureRecognizerWithDirection:(UISwipeGestureRecognizerDirection)direction touches:(NSInteger)touches target:(id)target action:(SEL)action;
- (void)addPanGestureRecognizerWithCompletion:(void (^)(UIPanGestureRecognizerDirection direction))completion;
- (void)addRotationGestureRecognizerWithCompletion:(void (^)(NSInteger rotate))completion;
- (void)addPinchGestureRecognizerWithCompletion:(void (^)(NSInteger scale))completion;
- (void)autoLayoutSubviews:(NSMutableArray*)subviews marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r;
- (void)autoLayoutSubviewsAgainWithX:(CGFloat)x y:(CGFloat)y marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r;
- (void)autoLayoutAddSubview:(UIView*)subview atIndex:(NSInteger)index x:(CGFloat)x y:(CGFloat)y marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r completion:(void (^)())completion;
- (CGRect)autoXYWithSubview:(UIView*)subview marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r prevRight:(NSNumber**)pr prevBottom:(NSNumber**)pb;
- (CGRect)autoXYWithSubview:(UIView*)subview frame:(CGRect)subviewFrame marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r prevRight:(NSNumber**)pr prevBottom:(NSNumber**)pb;
- (UIView*)addGeWithType:(GeLineType)type;
- (UIView*)addGeWithType:(GeLineType)type color:(UIColor*)color;
- (UIView*)addGeWithType:(GeLineType)type color:(UIColor*)color wide:(CGFloat)wide;
- (void)removeGeLine;
- (void)removeGeLine:(NSInteger)tag;
- (UIImage*)toImage;
- (void)click:(void(^)(UIView *view, UIGestureRecognizer *sender))block;
- (void)longClick:(void(^)(UIView *view, UIGestureRecognizer *sender))block;
- (void)subviewsDragSortWithTarget:(id<SubviewsDragSortDelegate>)target;
- (void)subviewsDragSortWithTarget:(id<SubviewsDragSortDelegate>)target withOut:(id)withOutView;
- (void)blur;
- (void)Unblur;
@end
