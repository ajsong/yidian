//
//  MJRefreshBaseView.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <UIKit/UIKit.h>
#import "GIFImageView.h"

#pragma mark - 控件的刷新状态
typedef enum {
	MJRefreshStatePulling = 1, // 松开就可以进行刷新的状态
	MJRefreshStateNormal = 2, // 普通状态
	MJRefreshStateRefreshing = 3, // 正在刷新中的状态
	MJRefreshStateWillRefreshing = 4
} MJRefreshState;

#pragma mark - 控件的类型
typedef enum {
	MJRefreshViewTypeHeader = -1, // 头部控件
	MJRefreshViewTypeFooter = 1 // 尾部控件
} MJRefreshViewType;

/**
 类的声明
 */
@interface MJRefreshBaseView : UIView
@property (nonatomic, copy) void (^changeState)(MJRefreshState state, MJRefreshBaseView *view); //根据状态执行

#pragma mark - 父控件
@property (nonatomic, weak, readonly) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) UIEdgeInsets scrollViewOriginalInset;
@property (nonatomic, assign) CGFloat scrollViewContentSizeHeight;

#pragma mark - 内部的控件
@property (nonatomic, assign) BOOL autoCreate;
@property (nonatomic, weak, readonly) UILabel *statusLabel;
@property (nonatomic, weak, readonly) UIImageView *arrowImage;
@property (nonatomic, weak, readonly) UIActivityIndicatorView *activityView;
@property (nonatomic, weak, readonly) UIImageView *imagesView;
@property (nonatomic, weak, readonly) GIFImageView *gifView;

/**
 *  自定义创建
 */
+ (MJRefreshBaseView*)createWithFrame:(CGRect)frame subviews:(void (^)(MJRefreshBaseView *view))subviews changeState:(void (^)(MJRefreshState state, MJRefreshBaseView *view))changeState;

#pragma mark - 回调
/**
 *  开始进入刷新状态的监听器
 */
@property (weak, nonatomic) id beginRefreshingTaget;
/**
 *  开始进入刷新状态的监听方法
 */
@property (assign, nonatomic) SEL beginRefreshingAction;
/**
 *  开始进入刷新状态就会调用
 */
@property (nonatomic, copy) void (^beginRefreshingCallback)();

/**
 *  刷新完毕停止动画后的监听器
 */
@property (weak, nonatomic) id didEndRefreshTaget;
/**
 *  刷新完毕停止动画后的监听方法
 */
@property (assign, nonatomic) SEL didEndRefreshAction;
/**
 *  刷新完毕停止动画后就会调用
 */
@property (nonatomic, copy) void (^didEndRefreshCallback)();

#pragma mark - 刷新相关
/**
 *  是否正在刷新
 */
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;
/**
 *  开始刷新
 */
- (void)beginRefreshing;
/**
 *  结束刷新
 */
- (void)endRefreshing;

#pragma mark - 交给子类去实现 和 调用
@property (assign, nonatomic) MJRefreshState state;

/**
 *  箭头图片
 */
@property (copy, nonatomic) NSString *arrowImageName;

/**
 *  文字
 */
@property (copy, nonatomic) NSString *pullToRefreshText;
@property (copy, nonatomic) NSString *releaseToRefreshText;
@property (copy, nonatomic) NSString *refreshingText;

/**
 *  动画图片, 设置后箭头与文字将不显示
 */
@property (copy, nonatomic) NSArray *images;
@property (retain, nonatomic) GIFImage *gif; //不设置即加载中时使用images的循环动画
@property (assign, nonatomic) CGSize imagesSize;
@property (assign, nonatomic) UIOffset imagesOffset;
@end
