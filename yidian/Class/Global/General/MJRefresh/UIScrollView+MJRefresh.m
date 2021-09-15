//
//  UIScrollView+MJRefresh.m
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "UIScrollView+MJRefresh.h"
#import "MJRefreshConst.h"

#define MJRefreshFooterTipHeight 64.f

@interface UIScrollView()

@end

@implementation UIScrollView (MJRefresh)

#pragma mark - 运行时相关
static char MJRefreshHeaderViewKey;
static char MJRefreshFooterViewKey;
static char MJRefreshFooterTipKey;

- (void)setHeader:(MJRefreshHeaderView *)header {
	[[self viewWithTag:MJRefreshViewTag] removeFromSuperview];
	[self addSubview:header];
	CGRect frame = header.frame;
	frame.origin.y = -self.contentInset.top - frame.size.height;
	header.frame = frame;
	((UIViewController*)[self viewController:header]).edgesForExtendedLayout = UIRectEdgeNone;
	if (![self isKindOfClass:[UITableView class]] && ![self isKindOfClass:[UICollectionView class]]) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				if (self.contentSize.height+self.contentInset.top+self.contentInset.bottom <= self.frame.size.height) {
					self.contentSize = CGSizeMake(self.contentSize.width, self.frame.size.height-(self.contentInset.top+self.contentInset.bottom)+0.5);
				}
			});
		});
	}
	[self willChangeValueForKey:@"MJRefreshHeaderViewKey"];
	objc_setAssociatedObject(self, &MJRefreshHeaderViewKey, header, OBJC_ASSOCIATION_ASSIGN);
	[self didChangeValueForKey:@"MJRefreshHeaderViewKey"];
}

- (MJRefreshHeaderView *)header{
	return objc_getAssociatedObject(self, &MJRefreshHeaderViewKey);
}

- (void)setFooter:(MJRefreshFooterView *)footer {
	[[self viewWithTag:MJRefreshViewTag+1] removeFromSuperview];
	[self addSubview:footer];
	[self willChangeValueForKey:@"MJRefreshFooterViewKey"];
	objc_setAssociatedObject(self, &MJRefreshFooterViewKey, footer, OBJC_ASSOCIATION_ASSIGN);
	[self didChangeValueForKey:@"MJRefreshFooterViewKey"];
}

- (MJRefreshFooterView *)footer{
	return objc_getAssociatedObject(self, &MJRefreshFooterViewKey);
}

- (UIViewController*)viewController:(UIView*)view{
	for (UIView *next = view.superview; next; next = next.superview) {
		UIResponder *nextResponder = [next nextResponder];
		if ([nextResponder isKindOfClass:[UIViewController class]]) {
			return (UIViewController*)nextResponder;
		}
	}
	return nil;
}
- (void)MJRefreshAutoContentSize{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, MJRefreshSlowAnimationDuration * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			CGFloat height = self.contentSize.height;
			if (height <= self.frame.size.height-self.contentInset.top-self.contentInset.bottom) {
				height = self.frame.size.height-self.contentInset.top-self.contentInset.bottom + 0.5;
			}
			self.contentSize = CGSizeMake(self.contentSize.width, height);
		});
	});
}

#pragma mark - 头部控件
- (void)addHeaderView:(UIView*)view height:(CGFloat)height
{
	[self addHeaderView:view height:height scale:NO];
}

- (void)addHeaderView:(UIView*)view height:(CGFloat)height scale:(BOOL)scale
{
	[self addHeaderView:view height:height scale:scale autoInset:YES];
}

- (void)addHeaderView:(UIView*)view height:(CGFloat)height scale:(BOOL)scale autoInset:(BOOL)autoInset
{
	[[self viewWithTag:MJRefreshViewTag-1] removeFromSuperview];
	CGRect frame = view.frame;
	frame.origin.y = (height - view.frame.size.height) / 2;
	if (autoInset) {
		frame.origin.y -= height;
		UIEdgeInsets insets = self.contentInset;
		insets.top += height;
		self.contentInset = insets;
		self.contentOffset = CGPointMake(0, -height);
	}
	view.frame = frame;
	view.tag = MJRefreshViewTag - 1;
	[self addSubview:view];
	[self sendSubviewToBack:view];
	self.element[@"scale"] = @(scale);
	self.element[@"autoInset"] = @(autoInset);
	self.element[@"headerView"] = view;
	self.element[@"headerHeight"] = @(height);
	self.element[@"viewHeight"] = @(frame.size.height);
	[self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	CGPoint newOffset = [change[@"new"] CGPointValue];
	[self scrollViewDidScroll:newOffset];
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset{
	UIView *view = self.element[@"headerView"];
	if (view) {
		BOOL scale = [self.element[@"scale"] boolValue];
		BOOL autoInset = [self.element[@"autoInset"] boolValue];
		CGFloat headerHeight = [self.element[@"headerHeight"] floatValue];
		CGFloat viewHeight = [self.element[@"viewHeight"] floatValue];
		BOOL isImage = [view isKindOfClass:[UIImageView class]];
		CGFloat offsetY = contentOffset.y;
		CGFloat allOffsetY = offsetY + (!autoInset ? -headerHeight : 0);
		if (allOffsetY <= 0) { //-headerHeight
			CGRect frame = view.frame;
			if (fabs(allOffsetY) >= viewHeight) {
				if (scale) {
					frame.origin.y = offsetY;
					if (isImage) {
						frame.size.height = fabs(allOffsetY);
						frame.size.width = [self fitToSize:CGSizeMake(0, frame.size.height) originSize:view.frame.size].width;
					}
					frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
				}
			} else {
				CGFloat height = 0;
				if (autoInset) height = headerHeight;
				CGFloat y = 0;
				if (viewHeight != headerHeight) y = ((headerHeight-viewHeight)/2)*(allOffsetY+headerHeight) / (viewHeight-headerHeight);
				frame.origin.y = ((headerHeight-viewHeight)/2-height) - y;
			}
			view.frame = frame;
		}
	}
}

- (NSMutableDictionary*)element{
	NSMutableDictionary *ele = objc_getAssociatedObject(self, @"MJRefreshElement");
	if (!ele) {
		ele = [[NSMutableDictionary alloc]init];
		objc_setAssociatedObject(self, @"MJRefreshElement", ele, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return ele;
}

- (CGSize)fitToSize:(CGSize)size originSize:(CGSize)origin{
	CGFloat width = size.width;
	CGFloat height = size.height;
	CGFloat iw = origin.width;
	CGFloat ih = origin.height;
	CGFloat nw = iw;
	CGFloat nh = ih;
	if (iw>0 && ih>0) {
		if (width>0 && height>0) {
			if (iw<=width && ih<=height) {
				nw = iw;
				nh = ih;
			} else {
				if (iw/ih >= width/height) {
					if (iw>width) {
						nw = width;
						nh = (ih*width)/iw;
					}
				} else {
					if (ih>height) {
						nw = (iw*height)/ih;
						nh = height;
					}
				}
			}
		} else {
			if (width==0 && height>0) {
				nw = (iw*height)/ih;
				nh = height;
			} else if (width>0 && height==0) {
				nw = width;
				nh = (ih*width)/iw;
			}
		}
	}
	if (width>0) {
		if (width>nw) {
			size = CGSizeMake(nw, size.height);
		}
	} else {
		size = CGSizeMake(nw, size.height);
	}
	if (height>0) {
		if (height>nh) {
			size = CGSizeMake(size.width, nh);
		}
	} else {
		size = CGSizeMake(size.width, nh);
	}
	return size;
}

#pragma mark - 下拉刷新
/**
 *  添加一个下拉刷新头部控件
 *
 *  @param callback 回调
 */
- (void)addHeaderWithCallback:(void (^)())callback
{
	// 1.创建新的header
	if (!self.header) {
		MJRefreshHeaderView *header = [MJRefreshHeaderView header];
		header.backgroundColor = [UIColor clearColor];
		header.tag = MJRefreshViewTag;
		header.autoCreate = YES;
		self.header = header;
	}
	
	// 2.设置block回调
	self.header.beginRefreshingCallback = callback;
	
	self.headerHidden = YES;
}

/**
 *  添加一个下拉刷新头部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addHeaderWithTarget:(id)target action:(SEL)action
{
	// 1.创建新的header
	if (!self.header) {
		MJRefreshHeaderView *header = [MJRefreshHeaderView header];
		header.backgroundColor = [UIColor clearColor];
		header.tag = MJRefreshViewTag;
		header.autoCreate = YES;
		self.header = header;
	}
	
	// 2.设置目标和回调方法
	self.header.beginRefreshingTaget = target;
	self.header.beginRefreshingAction = action;
	
	self.headerHidden = YES;
}

/**
 *  头部控件刷新完毕还原停止动画后执行
 */
- (void)headerDidEndRefreshWithCallback:(void (^)())callback{
	self.header.didEndRefreshCallback = callback;
}
- (void)headerDidEndRefreshWithTarget:(id)target action:(SEL)action{
	self.header.didEndRefreshTaget = target;
	self.header.didEndRefreshAction = action;
}

/**
 *  移除下拉刷新头部控件
 */
- (void)removeHeader
{
	[self.header removeFromSuperview];
	self.header = nil;
}

/**
 *  主动让下拉刷新头部控件进入刷新状态
 */
- (void)headerBeginRefreshing
{
	self.headerHidden = NO;
	if (self.footer) self.footerHidden = NO;
	[self.header beginRefreshing];
}

/**
 *  让下拉刷新头部控件停止刷新状态
 */
- (void)headerEndRefreshing
{
	[self.header endRefreshing];
	
	if (self.footer) [self performSelector:@selector(footerHandle) withObject:nil afterDelay:0.0];
}

/**
 *  下拉刷新头部控件的可见性
 */
- (void)setHeaderHidden:(BOOL)hidden
{
	self.header.hidden = hidden;
}

- (BOOL)isHeaderHidden
{
	return self.header.isHidden;
}

- (BOOL)isHeaderRefreshing
{
	return self.header.state == MJRefreshStateRefreshing;
}

/**
 *  箭头图片
 */
- (void)setHeaderArrowImageName:(NSString *)headerArrowImageName
{
	self.header.arrowImageName = headerArrowImageName;
}

- (NSString *)headerArrowImageName
{
	return self.header.arrowImageName;
}

/**
 *  文字
 */
- (void)setHeaderPullToRefreshText:(NSString *)headerPullToRefreshText
{
	self.header.pullToRefreshText = headerPullToRefreshText;
}

- (NSString *)headerPullToRefreshText
{
	return self.header.pullToRefreshText;
}

- (void)setHeaderReleaseToRefreshText:(NSString *)headerReleaseToRefreshText
{
	self.header.releaseToRefreshText = headerReleaseToRefreshText;
}

- (NSString *)headerReleaseToRefreshText
{
	return self.header.releaseToRefreshText;
}

- (void)setHeaderRefreshingText:(NSString *)headerRefreshingText
{
	self.header.refreshingText = headerRefreshingText;
}

- (NSString *)headerRefreshingText
{
	return self.header.refreshingText;
}

#pragma mark - 上拉刷新
/**
 *  添加一个上拉刷新尾部控件
 *
 *  @param callback 回调
 */
- (void)addFooterWithCallback:(void (^)())callback
{
	// 1.创建新的footer
	if (!self.footer) {
		[[self viewWithTag:MJRefreshViewTag+1] removeFromSuperview];
		MJRefreshFooterView *footer = [MJRefreshFooterView footer];
		footer.backgroundColor = [UIColor clearColor];
		footer.tag = MJRefreshViewTag + 1;
		footer.autoCreate = YES;
		self.footer = footer;
	}
	
	// 2.设置block回调
	self.footer.beginRefreshingCallback = callback;
	
	self.footerHidden = YES;
}

/**
 *  添加一个上拉刷新尾部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addFooterWithTarget:(id)target action:(SEL)action
{
	// 1.创建新的footer
	if (!self.footer) {
		MJRefreshFooterView *footer = [MJRefreshFooterView footer];
		footer.backgroundColor = [UIColor clearColor];
		footer.tag = MJRefreshViewTag + 1;
		footer.autoCreate = YES;
		self.footer = footer;
	}
	
	// 2.设置目标和回调方法
	self.footer.beginRefreshingTaget = target;
	self.footer.beginRefreshingAction = action;
	
	self.footerHidden = YES;
}

/**
 *  尾部控件刷新完毕还原停止动画后执行
 */
- (void)footerDidEndRefreshWithCallback:(void (^)())callback{
	self.footer.didEndRefreshCallback = callback;
}
- (void)footerDidEndRefreshWithTarget:(id)target action:(SEL)action{
	self.footer.didEndRefreshTaget = target;
	self.footer.didEndRefreshAction = action;
}

/**
 *  添加一个尾部提示文字(一般上拉加载没有数据时显示)
 */
- (void)setFooterTip:(UILabel *)footerTip{
	[self willChangeValueForKey:@"MJRefreshFooterTipKey"];
	objc_setAssociatedObject(self, &MJRefreshFooterTipKey, footerTip, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self didChangeValueForKey:@"MJRefreshFooterTipKey"];
}
- (UIView *)footerTip{
	return objc_getAssociatedObject(self, &MJRefreshFooterTipKey);
}
- (void)addFooterTipWithView:(UIView*)view{
	CGRect frame = view.frame;
	if (self.footerTip) {
		for (UIView *subview in self.footerTip.subviews) {
			[subview removeFromSuperview];
		}
		frame.origin.y = 0;
		view.frame = frame;
		[self.footerTip addSubview:view];
		self.footerTip.frame = CGRectMake(0, self.contentSize.height, self.frame.size.width, frame.size.height);
	} else {
		[[self viewWithTag:MJRefreshViewTag+2] removeFromSuperview];
		UIView *footerTip = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
		footerTip.hidden = YES;
		footerTip.tag = MJRefreshViewTag + 2;
		self.footerTip = footerTip;
		frame.origin.y = 0;
		view.frame = frame;
		[self.footerTip addSubview:view];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				self.footerTip.frame = CGRectMake(0, self.contentSize.height, self.frame.size.width, frame.size.height);
				[self insertSubview:self.footerTip belowSubview:self];
			});
		});
	}
}
- (void)addFooterTipWithText:(NSString*)text{
	if (!text.length) return;
	UILabel *footerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, MJRefreshFooterTipHeight)];
	footerLabel.text = text;
	footerLabel.textColor = [UIColor colorWithRed:204/255.f green:204/255.f blue:204/255.f alpha:1.f];
	footerLabel.textAlignment = NSTextAlignmentCenter;
	footerLabel.font = [UIFont systemFontOfSize:12.f];
	footerLabel.backgroundColor = [UIColor clearColor];
	[self addFooterTipWithView:footerLabel];
}

/**
 *  移除上拉刷新尾部控件
 */
- (void)removeFooter
{
	[self.footer removeFromSuperview];
	self.footer = nil;
}

/**
 *  主动让上拉刷新尾部控件进入刷新状态
 */
- (void)footerBeginRefreshing
{
	[self.footer beginRefreshing];
}

/**
 *  让上拉刷新尾部控件停止刷新状态
 */
- (void)footerEndRefreshing
{
	[self.footer endRefreshing];
	
	CGFloat originContentSizeHeight = self.footer.scrollViewContentSizeHeight;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (originContentSizeHeight >= self.contentSize.height) {
				self.footerHidden = YES;
				self.footerTip.hidden = NO;
				self.footerTip.frame = CGRectMake(0, self.contentSize.height, self.frame.size.width, MJRefreshFooterTipHeight);
			}
		});
	});
}

/**
 *  上拉刷新头部控件的可见性
 */
- (void)setFooterHidden:(BOOL)hidden
{
	self.footer.hidden = hidden;
}

- (BOOL)isFooterHidden
{
	return self.footer.isHidden;
}

- (BOOL)isFooterRefreshing
{
	return self.footer.state == MJRefreshStateRefreshing;
}

/**
 *  判断尾部控件是否应该隐藏
 */
- (void)footerHandle{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (self.contentSize.height + self.header.scrollViewOriginalInset.top + self.header.scrollViewOriginalInset.bottom <= self.frame.size.height) {
				self.footerHidden = YES;
				self.footerTip.hidden = YES;
			} else {
				self.footerHidden = NO;
			}
		});
	});
}

/**
 *  箭头图片
 */
- (void)setFooterArrowImageName:(NSString *)footerArrowImageName
{
	self.footer.arrowImageName = footerArrowImageName;
}

- (NSString *)footerArrowImageName
{
	return self.footer.arrowImageName;
}

/**
 *  文字
 */
- (void)setFooterPullToRefreshText:(NSString *)footerPullToRefreshText
{
	self.footer.pullToRefreshText = footerPullToRefreshText;
}

- (NSString *)footerPullToRefreshText
{
	return self.footer.pullToRefreshText;
}

- (void)setFooterReleaseToRefreshText:(NSString *)footerReleaseToRefreshText
{
	self.footer.releaseToRefreshText = footerReleaseToRefreshText;
}

- (NSString *)footerReleaseToRefreshText
{
	return self.footer.releaseToRefreshText;
}

- (void)setFooterRefreshingText:(NSString *)footerRefreshingText
{
	self.footer.refreshingText = footerRefreshingText;
}

- (NSString *)footerRefreshingText
{
	return self.footer.refreshingText;
}

@end
