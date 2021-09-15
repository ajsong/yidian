//
//  AJHeaderView.m
//
//  Created by ajsong on 14-10-26.
//  Copyright (c) 2014 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "AJHeaderView.h"

@interface AJHeaderView ()<UIScrollViewDelegate>{
	BOOL _didMinHeight;
	BOOL _didOriginalHeight;
}
@end

@implementation AJHeaderView

- (id)initWithView:(UIView*)view addTo:(UIScrollView*)scrollView{
	self = [super initWithFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, view.frame.size.height)];
	if (self) {
		[[self viewController:scrollView] setEdgesForExtendedLayout:UIRectEdgeNone];
		self.clipsToBounds = YES;
		_scrollView = scrollView;
		scrollView.delegate = self;
		_minHeight = 0;
		_originalHeight = view.frame.size.height;
		UIEdgeInsets edgeInsets = _scrollView.contentInset;
		edgeInsets.top = self.frame.size.height;
		_scrollView.contentInset = edgeInsets;
		_scrollView.contentOffset = CGPointMake(0, -self.frame.size.height);
		_view = view;
		[self addSubview:_view];
		_didOriginalHeight = YES;
	}
	return self;
}

- (UIViewController*)viewController:(UIView*)view{
	for (UIView *next = self.superview; next; next = next.superview) {
		UIResponder *nextResponder = [next nextResponder];
		if ([nextResponder isKindOfClass:[UIViewController class]]) {
			return (UIViewController*)nextResponder;
		}
	}
	return nil;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	[self updateSubViewsWithScrollOffset:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (!decelerate) [self updateSubViewsWithScrollOffset:scrollView];
}

- (void)updateSubViewsWithScrollOffset:(UIScrollView*)scrollView{
	if (scrollView.contentSize.height < scrollView.frame.size.height*1.5) return;
	CGPoint offset = scrollView.contentOffset;
	if (offset.y-_fixY > -_originalHeight && !_didMinHeight) { //顶部最小化
		_didMinHeight = YES;
		_didOriginalHeight = NO;
		CGRect frame = self.frame;
		frame.size.height = _minHeight;
		UIEdgeInsets edgeInsets = _scrollView.contentInset;
		edgeInsets.top = _minHeight;
		[UIView animateWithDuration:0.3 animations:^{
			self.frame = frame;
			_scrollView.contentInset = edgeInsets;
			BOOL isBottom = offset.y >= scrollView.contentSize.height - scrollView.frame.size.height;
			scrollView.contentOffset = CGPointMake(offset.x, isBottom ? offset.y : offset.y-_fixY+_originalHeight);
		}];
		[self headerViewDidMinHeight];
	} else if (offset.y-_fixY <= -_minHeight && !_didOriginalHeight) { //顶部恢复
		_didMinHeight = NO;
		_didOriginalHeight = YES;
		CGRect frame = self.frame;
		frame.size.height = _originalHeight;
		UIEdgeInsets edgeInsets = _scrollView.contentInset;
		edgeInsets.top = _originalHeight;
		[UIView animateWithDuration:0.3 animations:^{
			self.frame = frame;
			_scrollView.contentInset = edgeInsets;
			scrollView.contentOffset = CGPointMake(offset.x, _fixY-_originalHeight);
		}];
		[self headerViewDidOriginalHeight];
	}
}

- (void)headerViewDidMinHeight{
	if (_delegate && [_delegate respondsToSelector:@selector(AJHeaderViewDidMinHeight:headerHeight:)]) {
		[_delegate AJHeaderViewDidMinHeight:self headerHeight:_minHeight];
	}
}

- (void)headerViewDidOriginalHeight{
	if (_delegate && [_delegate respondsToSelector:@selector(AJHeaderViewDidOriginalHeight:headerHeight:)]) {
		[_delegate AJHeaderViewDidOriginalHeight:self headerHeight:_originalHeight];
	}
}

@end
