//
//  SUNSlideSwitchView.h
//  SUNCommonComponent
//
//  Created by 麦志泉 on 13-9-4.
//  Copyright (c) 2013年 中山市新联医疗科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SUNSlideSwitchViewDelegate;
@interface SUNSlideSwitchView : UIView

@property (nonatomic, weak) id<SUNSlideSwitchViewDelegate> delegate;
@property (nonatomic, strong) UIScrollView *rootScrollView; //主视图
@property (nonatomic, strong) UIView *navController; //页签容器
@property (nonatomic, strong) UIScrollView *topScrollView; //页签视图
@property (nonatomic, assign) NSInteger index; //启动后默认显示的选项卡的索引, 然后变成当前显示的选项卡的索引
@property (nonatomic, retain) UIView *currentView; //当前显示的子视图
@property (nonatomic, retain) UIViewController *currentController; //当前显示的子视图所属控制器
@property (nonatomic, strong) NSMutableArray *viewArray; //子视图数组
@property (nonatomic, strong) NSMutableArray *controllerArray; //子视图控制器数组
@property (nonatomic, assign) BOOL navControllerShadow; //页签容器是否使用阴影(动画移动)
@property (nonatomic, assign) BOOL navOnBottom; //页签容器放在底部
@property (nonatomic, assign) BOOL syncLoad; //同步加载(默认NO)
@property (nonatomic, assign) BOOL fadeIn; //主视图异步加载时载入完毕后渐显(默认YES)
@property (nonatomic, assign) CGFloat tabItemMargin; //tab按钮margin, 默认16.0f
@property (nonatomic, assign) CGFloat tabItemPadding; //tab按钮padding, 默认10.0f
@property (nonatomic, assign) BOOL tabItemFitWidth; //tab自适应宽度
@property (nonatomic, assign) CGFloat tabBarHeight; //页签容器高度
@property (nonatomic, assign) BOOL scrollAnimation; //主视图是否动画滑动
@property (nonatomic, assign) BOOL scrollEnabled; //主视图是否可滑动
@property (nonatomic, assign) BOOL tabItemEnabled; //tab能否点击
@property (nonatomic, strong) UIFont *tabItemFont; //tab文字字体
@property (nonatomic, strong) UIColor *tabItemNormalColor; //正常时tab文字颜色
@property (nonatomic, strong) UIColor *tabItemSelectedColor; //选中时tab文字颜色
@property (nonatomic, strong) UIImage *tabItemNormalBackgroundImage; //正常时tab的背景图片
@property (nonatomic, strong) UIImage *tabItemSelectedBackgroundImage; //选中时tab的背景图片
@property (nonatomic, strong) UIColor *tabItemNormalBackgroundColor; //正常时tab的背景颜色
@property (nonatomic, strong) UIColor *tabItemSelectedBackgroundColor; //选中时tab的背景颜色
@property (nonatomic, strong) UIImage *shadowImage; //阴影(动画移动)
@property (nonatomic, strong) UIButton *rightSideButton; //右侧按钮
@property (nonatomic, strong) UIImageView *rightSideButtonShadow; //右侧按钮阴影

/*!
 * @method 创建子视图UI
 * @abstract
 * @discussion
 * @param
 * @result
 */
- (void)buildUI;

//选中页签
- (void)selectButton:(NSInteger)index;

//隐藏顶部tab
- (void)toggleTopViewHidden;

@end

@protocol SUNSlideSwitchViewDelegate <NSObject>

@required

/*!
 * @method 顶部tab个数
 * @abstract
 * @discussion
 * @param 本控件
 * @result tab个数
 */
- (NSUInteger)numberOfTab:(SUNSlideSwitchView *)switchView;

/*!
 * @method 每个tab所属的viewController
 * @abstract
 * @discussion
 * @param tab索引
 * @result viewController
 */
- (UIViewController *)slideSwitchView:(SUNSlideSwitchView *)switchView viewOfTab:(NSUInteger)index;

@optional

/*!
 * @method 隐藏顶部tab
 * @abstract
 * @discussion
 * @param 顶部tab当前状态
 * @result
 */
- (void)slideSwitchView:(SUNSlideSwitchView *)switchView toggleTopViewHidden:(BOOL)isHidden;

/*!
 * @method 点击tab
 * @abstract
 * @discussion
 * @param tab索引
 * @result
 */
- (void)slideSwitchView:(SUNSlideSwitchView *)switchView didSelectTab:(NSUInteger)index;

/*!
 * @method 主视图停止滚动后执行
 * @abstract
 * @discussion
 * @param 主视图
 * @result
 */
- (void)slideSwitchView:(SUNSlideSwitchView *)switchView scrollViewDidEndDecelerating:(UIScrollView*)scrollView;

/*!
 * @method 滑动左边界时传递手势
 * @abstract
 * @discussion
 * @param   手势
 * @result 
 */
- (void)slideSwitchView:(SUNSlideSwitchView *)switchView panLeftEdge:(UIPanGestureRecognizer*)panParam;

/*!
 * @method 滑动右边界时传递手势
 * @abstract
 * @discussion
 * @param   手势
 * @result
 */
- (void)slideSwitchView:(SUNSlideSwitchView *)switchView panRightEdge:(UIPanGestureRecognizer*)panParam;

@end
