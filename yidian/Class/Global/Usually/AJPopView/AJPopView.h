//
//  AJPopView.h
//
//  Created by ajsong on 15/9/22.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger {
	AJPopViewAnimateTypeNone = 0,
	AJPopViewAnimateTypeAlpha,
	AJPopViewAnimateTypeScale,
	AJPopViewAnimateTypeSlide,
} AJPopViewAnimateType;

typedef enum : NSInteger {
	AJPopViewTriangleTop = 0,
	AJPopViewTriangleLeft,
	AJPopViewTriangleBottom,
	AJPopViewTriangleRight,
} AJPopViewTrianglePosition;

@interface AJPopView : UIView
@property (nonatomic,strong) UIView *view; //内容容器
@property (nonatomic,strong) UIScrollView *scrollView; //是否过高产生了滚动
@property (nonatomic,strong) UIView *pointFromView; //从哪个view获取坐标
@property (nonatomic,assign) CGPoint contentOffset; //坐标
@property (nonatomic,assign) CGFloat popHeight; //指定高度
@property (nonatomic,assign) CGFloat backgroundAlpha; //遮罩透明度
@property (nonatomic,assign) AJPopViewAnimateType animateType; //动画类型
@property (nonatomic,assign) NSTimeInterval animateDuration; //动画时间
@property (nonatomic,assign) BOOL isFullscreen; //遮罩全屏
@property (nonatomic,strong) UIColor *triangleColor; //三角形背景色
@property (nonatomic,strong) UIColor *triangleBorderColor; //三角形边框色
@property (nonatomic,assign) UIOffset triangleOffset; //三角形偏移
@property (nonatomic,assign) AJPopViewTrianglePosition trianglePosition; //三角形位置

- (instancetype)initInView:(UIView*)parentView;
- (instancetype)initInView:(UIView*)parentView pointFromView:(UIView*)fromView;
- (instancetype)initInView:(UIView*)parentView fromPoint:(CGPoint)fromPoint;
- (void)showAuto;
- (void)show;
- (void)close;
- (void)showAuto:(void (^)())show close:(void (^)())close;
- (void)willShowAuto:(void (^)())show close:(void (^)())close;
- (void)show:(void (^)())completion;
- (void)close:(void (^)())completion;
@end
