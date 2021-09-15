//
//  MJRefreshBaseView.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJRefreshBaseView.h"
#import "MJRefreshConst.h"
#import "UIView+MJExtension.h"
#import "UIScrollView+MJExtension.h"
#import <objc/message.h>

@interface  MJRefreshBaseView()
{
	__weak UILabel *_statusLabel;
	__weak UIImageView *_arrowImage;
	__weak UIActivityIndicatorView *_activityView;
	__weak UIImageView *_imagesView;
	__weak GIFImageView *_gifView;
}
@end

@implementation MJRefreshBaseView

#pragma mark - 控件初始化
/**
 *  状态标签
 */
- (UILabel *)statusLabel
{
	if (!_statusLabel) {
		UILabel *statusLabel = [[UILabel alloc] init];
		statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		statusLabel.font = [UIFont boldSystemFontOfSize:13];
		statusLabel.textColor = MJRefreshLabelTextColor;
		statusLabel.backgroundColor = [UIColor clearColor];
		statusLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_statusLabel = statusLabel];
		[self sendSubviewToBack:_statusLabel];
		
		if (self.images) _statusLabel.hidden = YES;
	}
	return _statusLabel;
}

/**
 *  箭头图片
 */
- (UIImageView *)arrowImage
{
	if (!_arrowImage) {
		UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:MJRefreshArrowImageName]];
		arrowImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[self addSubview:_arrowImage = arrowImage];
		
		if (self.images) _arrowImage.hidden = YES;
	}
	return _arrowImage;
}

/**
 *  设定箭头图片
 */
- (void)setArrowImageName:(NSString *)arrowImageName
{
	_arrowImage.image = [UIImage imageNamed:arrowImageName];
	_arrowImageName = arrowImageName;
}

/**
 *  状态标签
 */
- (UIActivityIndicatorView *)activityView
{
	if (!_activityView) {
		UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		activityView.bounds = self.arrowImage.bounds;
		activityView.autoresizingMask = self.arrowImage.autoresizingMask;
		[self addSubview:_activityView = activityView];
		
		if (self.images) _activityView.hidden = YES;
	}
	return _activityView;
}

- (UIImageView*)imagesView{
	if (!self.images) return nil;
	if (!_imagesView) {
		CGRect frame = CGRectMake((self.frame.size.width-self.imagesSize.width)/2+self.imagesOffset.horizontal,
								  (self.frame.size.height-self.imagesSize.height)/2+self.imagesOffset.vertical,
								  self.imagesSize.width, self.imagesSize.height);
		UIImageView *imagesView = [[UIImageView alloc]initWithFrame:frame];
		[self addSubview:_imagesView = imagesView];
	}
	return _imagesView;
}

- (GIFImageView*)gifView{
	if (!_imagesView || !_gif) return nil;
	if (!_gifView) {
		GIFImageView *gifView = [[GIFImageView alloc]initWithFrame:_imagesView.frame];
		gifView.image = _gif;
		gifView.hidden = YES;
		[self addSubview:_gifView = gifView];
	}
	return _gifView;
}

#pragma mark - 初始化方法
+ (MJRefreshBaseView *)createWithFrame:(CGRect)frame subviews:(void (^)(MJRefreshBaseView *))subviews changeState:(void (^)(MJRefreshState, MJRefreshBaseView *))changeState{
	MJRefreshBaseView *view = [[MJRefreshBaseView alloc]initWithFrame:frame];
	if (subviews) subviews(view);
	if (changeState) view.changeState = changeState;
	return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if (!frame.size.height) frame.size.height = MJRefreshViewHeight;
	if (self = [super initWithFrame:frame]) {
		// 1.自己的属性
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];
		
		// 2.设置默认状态
		_state = MJRefreshStateNormal;
		
		self.imagesSize = CGSizeMake(16.f, 16.f);
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (!self.autoCreate) return;
	
	// 1.箭头
	CGFloat arrowX = self.mj_width * 0.5 - 100;
	self.arrowImage.center = CGPointMake(arrowX, self.mj_height * 0.5);
	
	// 2.指示器
	self.activityView.center = self.arrowImage.center;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
	
	// 旧的父控件
	_scrollViewOriginalInset = ((UIScrollView*)self.superview).contentInset;
	[self.superview removeObserver:self forKeyPath:MJRefreshContentOffset context:nil];
	
	if (newSuperview) { // 新的父控件
		[newSuperview addObserver:self forKeyPath:MJRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
		
		// 设置宽度
		self.mj_width = newSuperview.mj_width;
		// 设置位置
		self.mj_x = 0;
		
		// 记录UIScrollView
		_scrollView = (UIScrollView *)newSuperview;
		// 记录UIScrollView最开始的contentInset
		_scrollViewOriginalInset = _scrollView.contentInset;
	}
}

#pragma mark - 显示到屏幕上
- (void)drawRect:(CGRect)rect
{
	if (self.state == MJRefreshStateWillRefreshing) {
		self.state = MJRefreshStateRefreshing;
	}
}

#pragma mark - 刷新相关
#pragma mark 是否正在刷新
- (BOOL)isRefreshing
{
	return MJRefreshStateRefreshing == self.state || MJRefreshStateWillRefreshing == self.state;
}

#pragma mark 开始刷新
typedef void (*send_type)(void *, SEL, UIView *);
- (void)beginRefreshing
{
	if ([self isRefreshing]) return;
	if (self.state == MJRefreshStateRefreshing) {
		// 回调
		if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
			msgSend((__bridge void *)(self.beginRefreshingTaget), self.beginRefreshingAction, self);
		}
		
		if (self.beginRefreshingCallback) {
			self.beginRefreshingCallback();
		}
	} else {
		if (self.window) {
			self.state = MJRefreshStateRefreshing;
		} else {
			//不能调用set方法
			_state = MJRefreshStateWillRefreshing;
			[super setNeedsDisplay];
		}
	}
}

#pragma mark 结束刷新
- (void)endRefreshing
{
	if (![self isRefreshing]) return;
	double delayInSeconds = 0.3;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		self.state = MJRefreshStateNormal;
	});
}

#pragma mark - 设置状态
- (void)setPullToRefreshText:(NSString *)pullToRefreshText
{
	_pullToRefreshText = [pullToRefreshText copy];
	[self settingLabelText];
}
- (void)setReleaseToRefreshText:(NSString *)releaseToRefreshText
{
	_releaseToRefreshText = [releaseToRefreshText copy];
	[self settingLabelText];
}
- (void)setRefreshingText:(NSString *)refreshingText
{
	_refreshingText = [refreshingText copy];
	[self settingLabelText];
}
- (void)settingLabelText
{
	if (!self.autoCreate) return;
	switch (self.state) {
		case MJRefreshStateNormal:
			// 设置文字
			self.statusLabel.text = self.pullToRefreshText;
			break;
		case MJRefreshStatePulling:
			// 设置文字
			self.statusLabel.text = self.releaseToRefreshText;
			break;
		case MJRefreshStateRefreshing:
			// 设置文字
			self.statusLabel.text = self.refreshingText;
			break;
		default:
			break;
	}
}

- (void)setState:(MJRefreshState)state
{
	// 0.存储当前的contentInset
	if (self.state != MJRefreshStateRefreshing) {
		_scrollViewOriginalInset = self.scrollView.contentInset;
	}
	
	// 1.一样的就直接返回(暂时不返回)
	if (self.state == state) return;
	
	if (self.changeState) self.changeState(state, self);
	
	// 2.根据状态执行不同的操作
	switch (state) {
		case MJRefreshStateNormal: // 普通状态
		{
			if (self.state == MJRefreshStateRefreshing) {
				[UIView animateWithDuration:MJRefreshSlowAnimationDuration * 0.6 animations:^{
					if (self.autoCreate) {
						self.activityView.alpha = 0.0;
					}
				} completion:^(BOOL finished) {
					if (self.autoCreate) {
						// 停止转圈圈
						[self.activityView stopAnimating];
						
						// 恢复alpha
						self.activityView.alpha = 1.0;
					}
					
					// 动画停止后执行
					if ([self.didEndRefreshTaget respondsToSelector:self.didEndRefreshAction]) {
						objc_msgSend(self.didEndRefreshTaget, self.didEndRefreshAction, self);
					}
					
					if (self.didEndRefreshCallback) {
						self.didEndRefreshCallback();
					}
				}];
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJRefreshSlowAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					// 再次设置回normal
					_state = MJRefreshStatePulling;
					self.state = MJRefreshStateNormal;
					
					if (!self.autoCreate) return;
					if (self.images) {
						if (self.gif) {
							self.imagesView.hidden = NO;
							self.gifView.hidden = YES;
						} else {
							[self.imagesView stopAnimating];
							self.imagesView.animationImages = nil;
						}
					}
				});
				// 直接返回
				return;
			} else {
				if (self.autoCreate) {
					// 显示箭头
					if (!self.images) self.arrowImage.hidden = NO;
					
					// 停止转圈圈
					[self.activityView stopAnimating];
				}
			}
			break;
		}
			
		case MJRefreshStatePulling:
			break;
			
		case MJRefreshStateRefreshing:
		{
			if (self.autoCreate) {
				// 隐藏箭头
				self.arrowImage.hidden = YES;
				
				// 开始转圈圈
				if (!self.images) [self.activityView startAnimating];
			}
			
			// 回调
			if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
				objc_msgSend(self.beginRefreshingTaget, self.beginRefreshingAction, self);
			}
			
			if (self.beginRefreshingCallback) {
				self.beginRefreshingCallback();
			}
			break;
		}
			
		default:
			break;
	}
	
	// 3.存储状态
	_state = state;
	
	// 4.设置文字
	[self settingLabelText];
}

@end
