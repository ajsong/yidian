//
//  SUNSlideSwitchView.m
//  SUNCommonComponent
//
//  Created by 麦志泉 on 13-9-4.
//  Copyright (c) 2013年 中山市新联医疗科技有限公司. All rights reserved.
//

#import "SUNSlideSwitchView.h"

static const CGFloat kHeightOfTopScrollView = 40.0f;
static const CGFloat kWidthOfButtonMargin = 16.0f;
static const CGFloat kWidthOfButtonPadding = 10.0f;
static const CGFloat kNavControllerShadowOpacity = 0.3f;
static const CGFloat kNavControllerShadowOffsetY = 0.0f;
static const NSUInteger kTagOfRightSideButton = 20149999;
static const NSUInteger kTagOfRightSideButtonShadow = 20149998;

#define SUNSWITCHTAG 20141027

@interface SUNSlideSwitchView ()<UIScrollViewDelegate>{
	CGFloat _userContentOffsetX;
	BOOL _isLeftScroll;
	BOOL _isRootScroll;
	BOOL _isBoot;
	CGFloat _topContentOffsetX;
	NSInteger _userSelectedChannelID;
	UIImageView *_shadowImageView;
}
@end

@implementation SUNSlideSwitchView

#pragma mark - 初始化参数

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		[self initValues];
	}
	return self;
}

- (void)initValues
{
	//主滚动视图
	_rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kHeightOfTopScrollView, self.frame.size.width, self.frame.size.height-kHeightOfTopScrollView)];
	_rootScrollView.backgroundColor = [UIColor clearColor];
	_rootScrollView.delegate = self;
	_rootScrollView.pagingEnabled = YES;
	_rootScrollView.userInteractionEnabled = YES;
	_rootScrollView.bounces = NO;
	_rootScrollView.showsHorizontalScrollIndicator = NO;
	_rootScrollView.showsVerticalScrollIndicator = NO;
	_rootScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
	_rootScrollView.clipsToBounds = YES;
	[_rootScrollView.panGestureRecognizer addTarget:self action:@selector(scrollHandlePan:)];
	[self addSubview:_rootScrollView];
	
    //页签容器
    _navController = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kHeightOfTopScrollView)];
    _navController.backgroundColor = [UIColor clearColor];
    _navController.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self addSubview:_navController];
	
    //页签视图
	_topScrollView = [[UIScrollView alloc] initWithFrame:_navController.bounds];
	_topScrollView.backgroundColor = [UIColor clearColor];
    _topScrollView.delegate = self;
    _topScrollView.pagingEnabled = NO;
    _topScrollView.showsHorizontalScrollIndicator = NO;
    _topScrollView.showsVerticalScrollIndicator = NO;
    _topScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_navController addSubview:_topScrollView];
    _userSelectedChannelID = 500;
	
	_viewArray = [[NSMutableArray alloc] init];
	_controllerArray = [[NSMutableArray alloc] init];
	_tabBarHeight = kHeightOfTopScrollView;
	_tabItemFitWidth = NO;
	_tabItemFont = [UIFont systemFontOfSize:17.f];
	_tabItemNormalColor = [UIColor blackColor];
	//_tabItemSelectedColor = [UIColor blackColor];
	_tabItemNormalBackgroundColor = [UIColor clearColor];
	
	_syncLoad = NO;
	_fadeIn = YES;
	_scrollAnimation = YES;
	_scrollEnabled = YES;
	_tabItemEnabled = YES;
	_index = 0;
	
	_tabItemMargin = kWidthOfButtonMargin;
	_tabItemPadding = kWidthOfButtonPadding;
    
	_topContentOffsetX = 0;
	_userContentOffsetX = 0;
	_isBoot = YES;
}

#pragma mark - getter/setter

- (void)setNavOnBottom:(BOOL)navOnBottom{
	_navOnBottom = navOnBottom;
	CGRect navFrame = _navController.frame;
	CGRect rootFrame = _rootScrollView.frame;
	if (navOnBottom) {
		navFrame.origin.y = self.frame.size.height - _tabBarHeight;
		rootFrame.origin.y = 0;
	} else {
		navFrame.origin.y = 0;
		rootFrame.origin.y = _tabBarHeight;
	}
	_navController.frame = navFrame;
	_rootScrollView.frame = rootFrame;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled{
	_scrollEnabled = scrollEnabled;
	_rootScrollView.scrollEnabled = scrollEnabled;
}

- (void)setTabBarHeight:(CGFloat)tabBarHeight
{
	_tabBarHeight = tabBarHeight;
	
	CGRect frame = _navController.frame;
	frame.size.height = tabBarHeight;
	_navController.frame = frame;
	
	frame = _topScrollView.frame;
	frame.size.height = tabBarHeight;
	_topScrollView.frame = frame;
	_topScrollView.contentSize = CGSizeMake(_topScrollView.contentSize.width, frame.size.height);
	
	frame = _rootScrollView.frame;
	frame.origin.y = _navOnBottom ? 0 : tabBarHeight;
	frame.size.height = self.frame.size.height - tabBarHeight;
	_rootScrollView.frame = frame;
	_rootScrollView.contentSize = CGSizeMake(_rootScrollView.contentSize.width, frame.size.height);
}

- (void)setRightSideButton:(UIButton *)rightSideButton
{
    _rightSideButton = rightSideButton;
    UIButton *button = (UIButton *)[self viewWithTag:kTagOfRightSideButton];
    [button removeFromSuperview];
    rightSideButton.tag = kTagOfRightSideButton;
    [self addSubview:_rightSideButton];
}

- (void)setRightSideButtonShadow:(UIImageView *)rightSideButtonShadow
{
    UIImageView *shadow = (UIImageView *)[self viewWithTag:kTagOfRightSideButtonShadow];
    [shadow removeFromSuperview];
    rightSideButtonShadow.tag = kTagOfRightSideButtonShadow;
    _rightSideButtonShadow = rightSideButtonShadow;
    [self addSubview:_rightSideButtonShadow];
}

#pragma mark - 创建控件

/*!
 * @method 创建子视图UI
 * @abstract
 * @discussion
 * @param
 * @result
 */
- (void)buildUI
{
	NSUInteger number = [_delegate numberOfTab:self];
	for (int i=0; i<number; i++) {
		if (_syncLoad) { //同步加载
			UIViewController *vc = [_delegate slideSwitchView:self viewOfTab:i];
			vc.view.frame = CGRectMake(_rootScrollView.frame.size.width*i, 0, _rootScrollView.frame.size.width, _rootScrollView.frame.size.height);
			vc.view.tag = SUNSWITCHTAG + i;
			[_rootScrollView addSubview:vc.view];
			[_viewArray addObject:vc.view];
			[_controllerArray addObject:vc];
		} else {
			[_viewArray addObject:[NSNull null]];
			[_controllerArray addObject:[NSNull null]];
		}
	}
	_rootScrollView.contentSize = CGSizeMake(_rootScrollView.frame.size.width * number, _rootScrollView.frame.size.height);
	
    [self createNameButtons];
    
    if (_navControllerShadow) {
        _navController.layer.masksToBounds = NO;
        _navController.layer.shadowOffset = CGSizeMake(0, kNavControllerShadowOffsetY);
        _navController.layer.shadowOpacity = kNavControllerShadowOpacity;
        _navController.layer.shadowPath = [UIBezierPath bezierPathWithRect:_topScrollView.bounds].CGPath;
	}
	
	((UIViewController*)[self viewController:self]).edgesForExtendedLayout = UIRectEdgeNone;
    
    //创建完子视图UI才需要调整布局
	[self setNeedsLayout];
	
	[self selectButton:_index];
}

- (UIViewController*)viewController:(UIView*)view
{
	for (UIView *next = view.superview; next; next = next.superview) {
		UIResponder *nextResponder = [next nextResponder];
		if ([nextResponder isKindOfClass:[UIViewController class]]) {
			return (UIViewController*)nextResponder;
		}
	}
	return nil;
}

/*!
 * @method 初始化顶部tab的各个按钮
 * @abstract
 * @discussion
 * @param
 * @result
 */
- (void)createNameButtons
{
	if (_shadowImage) {
		_shadowImageView = [[UIImageView alloc] init];
		[_shadowImageView setImage:_shadowImage];
		if (_shadowImage.size.height > _topScrollView.frame.size.height) {
			[_navController addSubview:_shadowImageView];
		} else {
			[_topScrollView addSubview:_shadowImageView];
		}
	}
	
	NSUInteger number = [_delegate numberOfTab:self];
	if (_tabItemFitWidth) _tabItemMargin = 0;
	
    //顶部tabbar的总长度
    CGFloat topScrollViewContentWidth = _tabItemMargin;
    //每个tab偏移量
    CGFloat xOffset = _tabItemMargin;
	//tab自适应宽度用
	CGFloat fitWidth = _topScrollView.frame.size.width / number;
    for (int i = 0; i < number; i++) {
        UIViewController *vc = [_delegate slideSwitchView:self viewOfTab:i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		CGSize textSize;
		if (_tabItemFitWidth) {
			textSize = CGSizeMake(fitWidth, kHeightOfTopScrollView);
		} else {
			NSDictionary *attributes = @{NSFontAttributeName:_tabItemFont};
			NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
			CGRect rect = [vc.title boundingRectWithSize:CGSizeMake(MAXFLOAT, _topScrollView.frame.size.height) options:options attributes:attributes context:NULL];
			textSize = rect.size;
			textSize.width += _tabItemPadding * 2;
		}
        //累计每个tab文字的长度
        topScrollViewContentWidth += _tabItemMargin + textSize.width;
        //设置按钮尺寸
        button.frame = CGRectMake(xOffset, 0, textSize.width, _topScrollView.frame.size.height);
        //计算下一个tab的x偏移量
        xOffset += textSize.width + _tabItemMargin;
        
        [button setTag:i+500];
        if (i == 0) {
            if (_shadowImageView) _shadowImageView.frame = CGRectMake(_tabItemMargin, 0, textSize.width, _shadowImage.size.height);
		}
		button.adjustsImageWhenHighlighted = NO;
		button.backgroundColor = _tabItemNormalBackgroundColor;
		button.titleLabel.font = _tabItemFont;
		[button setTitle:vc.title forState:UIControlStateNormal];
        [button setTitleColor:_tabItemNormalColor forState:UIControlStateNormal];
        if (_tabItemSelectedColor) [button setTitleColor:_tabItemSelectedColor forState:UIControlStateSelected];
		if (_tabItemNormalBackgroundImage) [button setBackgroundImage:_tabItemNormalBackgroundImage forState:UIControlStateNormal];
        if (_tabItemSelectedBackgroundImage) [button setBackgroundImage:_tabItemSelectedBackgroundImage forState:UIControlStateSelected|UIControlStateHighlighted];
		if (_tabItemEnabled) [button addTarget:self action:@selector(selectNameButton:) forControlEvents:UIControlEventTouchUpInside];
        [_topScrollView addSubview:button];
    }
    
    //设置顶部滚动视图的内容总尺寸
    _topScrollView.contentSize = CGSizeMake(topScrollViewContentWidth, _topScrollView.frame.size.height);
}

- (void)toggleTopViewHidden
{
	CGRect navFrame = _navController.frame;
	CGRect rootFrame = _rootScrollView.frame;
	BOOL hidden = NO;
	if (_navController.isHidden) {
		_navController.hidden = NO;
		navFrame.size.height = _tabBarHeight;
		rootFrame.origin.y = _navOnBottom ? 0 : navFrame.size.height;
		rootFrame.size.height = self.frame.size.height - navFrame.size.height;
		[UIView animateWithDuration:0.3 animations:^{
			_navController.frame = navFrame;
			_rootScrollView.frame = rootFrame;
		}];
	} else {
		hidden = YES;
		navFrame.size.height = 0;
		rootFrame.origin.y = _navOnBottom ? 0 : navFrame.size.height;
		rootFrame.size.height = self.frame.size.height - navFrame.size.height;
		[UIView animateWithDuration:0.3 animations:^{
			_navController.frame = navFrame;
			_rootScrollView.frame = rootFrame;
		} completion:^(BOOL finished) {
			_navController.hidden = YES;
		}];
	}
	
	if (_delegate && [_delegate respondsToSelector:@selector(slideSwitchView:toggleTopViewHidden:)]) {
		[_delegate slideSwitchView:self toggleTopViewHidden:hidden];
	}
}


#pragma mark - 顶部滚动视图逻辑方法

//选中页签
- (void)selectButton:(NSInteger)index
{
	UIButton *button = (UIButton *)[_topScrollView viewWithTag:index+500];
	[self selectNameButton:button];
}
- (void)selectButtonWith:(NSInteger)index
{
	[self selectButton:index];
}

/*!
 * @method 选中tab时间
 * @abstract
 * @discussion
 * @param 按钮
 * @result
 */
- (void)selectNameButton:(UIButton *)sender
{
    //如果点击的tab文字显示不全，调整滚动视图x坐标使用使tab文字显示全
    [self adjustScrollViewContentX:sender];
	
    //如果更换按钮
    if (sender.tag != _userSelectedChannelID) {
        //取之前的按钮
        UIButton *lastButton = (UIButton *)[_topScrollView viewWithTag:_userSelectedChannelID];
		lastButton.selected = NO;
		lastButton.backgroundColor = _tabItemNormalBackgroundColor;
        //赋值按钮ID
        _userSelectedChannelID = sender.tag;
    }
	
	_index = sender.tag - 500;
	
    //按钮选中状态
    if (!sender.selected) {
		sender.selected = YES;
		if (_tabItemSelectedBackgroundColor) sender.backgroundColor = _tabItemSelectedBackgroundColor;
		
		CGFloat x = 0;
		if (_shadowImage.size.height > _topScrollView.frame.size.height) {
			x = sender.frame.origin.x-_topContentOffsetX;
		} else {
			x = sender.frame.origin.x;
		}
		
		if (_isBoot && _shadowImageView) [_shadowImageView setFrame:CGRectMake(x, 0, sender.frame.size.width, _shadowImage.size.height)];
		
        [UIView animateWithDuration:0.25 animations:^{
            if (!_isBoot && _shadowImageView) [_shadowImageView setFrame:CGRectMake(x, 0, sender.frame.size.width, _shadowImage.size.height)];
        } completion:^(BOOL finished) {
            if (finished) {
                /*
                //设置新页出现
                if (!_isRootScroll) {
                    [_rootScrollView setContentOffset:CGPointMake((sender.tag - 500)*self.frame.size.width, 0) animated:YES];
                }
                */
				NSInteger index = sender.tag - 500;
				[_rootScrollView setContentOffset:CGPointMake(index*self.frame.size.width, 0) animated:(_isBoot?NO:_scrollAnimation)];
                _isRootScroll = NO;
				_isBoot = NO;
				
				//不同步加载
				if (!_syncLoad) {
					if (![_rootScrollView viewWithTag:SUNSWITCHTAG+index]) {
						UIViewController *vc = [_delegate slideSwitchView:self viewOfTab:index];
						vc.view.frame = CGRectMake(_rootScrollView.frame.size.width * index, 0, _rootScrollView.frame.size.width, _rootScrollView.frame.size.height);
						vc.view.tag = SUNSWITCHTAG + index;
						[_rootScrollView addSubview:vc.view];
						if (_fadeIn) {
							vc.view.alpha = 0;
							[UIView animateWithDuration:0.2 animations:^{
								vc.view.alpha = 1;
							}];
						}
						if ([_viewArray[index] isKindOfClass:[NSNull class]]) {
							[_viewArray replaceObjectAtIndex:index withObject:vc.view];
						}
						if ([_controllerArray[index] isKindOfClass:[NSNull class]]) {
							[_controllerArray replaceObjectAtIndex:index withObject:vc];
						}
						if (_rootScrollView.contentSize.width < _rootScrollView.frame.size.width * (index+1)) {
							_rootScrollView.contentSize = CGSizeMake(_rootScrollView.frame.size.width * (index+1), _rootScrollView.frame.size.height);
						}
					}
				}
				
				_currentView = [_rootScrollView viewWithTag:SUNSWITCHTAG+index];
				_currentController = [_delegate slideSwitchView:self viewOfTab:index];
				
                if (_delegate && [_delegate respondsToSelector:@selector(slideSwitchView:didSelectTab:)]) {
                    [_delegate slideSwitchView:self didSelectTab:_userSelectedChannelID - 500];
				}
				if (_delegate && [_delegate respondsToSelector:@selector(slideSwitchView:scrollViewDidEndDecelerating:)]) {
					[_delegate slideSwitchView:self scrollViewDidEndDecelerating:_rootScrollView];
				}
            }
        }];
        
    } else {
        //重复点击选中按钮
    }
}

/*!
 * @method 调整顶部滚动视图x位置
 * @abstract
 * @discussion
 * @param
 * @result
 */
- (void)adjustScrollViewContentX:(UIButton *)sender
{
    //如果 当前显示的最后一个tab文字超出右边界
    if (sender.frame.origin.x + sender.frame.size.width - _topScrollView.contentOffset.x > _topScrollView.frame.size.width) {
        _topContentOffsetX = sender.frame.origin.x + sender.frame.size.width - _topScrollView.frame.size.width;
        //向左滚动视图，显示完整tab文字
        [_topScrollView setContentOffset:CGPointMake(_topContentOffsetX, 0) animated:YES];
    }
    
    //如果 （tab的文字坐标 - 当前滚动视图左边界所在整个视图的x坐标） < 按钮的隔间 ，代表tab文字已超出边界
    if (sender.frame.origin.x - _topScrollView.contentOffset.x < _tabItemMargin) {
        _topContentOffsetX = sender.frame.origin.x - _tabItemMargin;
        //向右滚动视图（tab文字的x坐标 - 按钮间隔 = 新的滚动视图左边界在整个视图的x坐标），使文字显示完整
        [_topScrollView setContentOffset:CGPointMake(_topContentOffsetX, 0)  animated:YES];
    }
}

#pragma mark - 主视图逻辑方法

//滚动视图开始时
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _rootScrollView) {
        _userContentOffsetX = scrollView.contentOffset.x;
    }
}

//滚动视图结束
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    if (scrollView == _topScrollView) {
        if (_rightSideButtonShadow.frame.size.width > 0) {
            if (round(offset.x + scrollView.frame.size.width - scrollView.contentSize.width) >= 0) {
                _rightSideButtonShadow.hidden = YES;
            } else {
                _rightSideButtonShadow.hidden = NO;
            }
        }
    }
    if (scrollView == _rootScrollView) {
        //判断用户是否左滚动还是右滚动
        if (_userContentOffsetX < offset.x) {
            _isLeftScroll = YES;
        } else {
            _isLeftScroll = NO;
        }
    }
}

//滚动视图释放滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _rootScrollView) {
        _isRootScroll = YES;
        //调整顶部滑条按钮状态
        NSInteger tag = (NSInteger)scrollView.contentOffset.x/self.frame.size.width;
		[self selectButtonWith:tag];
    }
}

//传递滑动事件给下一层
-(void)scrollHandlePan:(UIPanGestureRecognizer*)panParam
{
    //当滑道左边界时，传递滑动事件给代理
    if(_rootScrollView.contentOffset.x <= 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(slideSwitchView:panLeftEdge:)]) {
            [_delegate slideSwitchView:self panLeftEdge:panParam];
        }
    } else if(_rootScrollView.contentOffset.x >= _rootScrollView.contentSize.width - _rootScrollView.frame.size.width) {
        if (_delegate && [_delegate respondsToSelector:@selector(slideSwitchView:panRightEdge:)]) {
            [_delegate slideSwitchView:self panRightEdge:panParam];
        }
    }
}

@end
