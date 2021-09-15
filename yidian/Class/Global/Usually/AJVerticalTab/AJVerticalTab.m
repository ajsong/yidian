//
//  AJVerticalTab.m
//
//  Created by ajsong on 15/9/18.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import "AJVerticalTab.h"

@interface AJVerticalTab ()<UIScrollViewDelegate>{
	NSMutableArray *_headerArray;
	CGFloat _scrollHeight;
	UIView *_currentView;
}
@end

@implementation AJVerticalTab

- (id)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		_headerArray = [[NSMutableArray alloc]init];
		[self performSelector:@selector(initialize) withObject:nil afterDelay:0];
	}
	return self;
}

- (void)initialize{
	_selectedIndex = _index;
	[_headerArray removeAllObjects];
	CGFloat bottom = 0;
	NSInteger count = [_delegate AJVerticalTabWithNumber:self];
	for (NSInteger i=0; i<count; i++) {
		UIView *view = [_delegate AJVerticalTab:self headerOfIndex:i];
		UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, bottom, self.width, view.height)];
		header.clipsToBounds = YES;
		[header addSubview:view];
		[header click:^(UIView *view, UIGestureRecognizer *sender) {
			[self changePosition:view];
		}];
		[self addSubview:header];
		[_headerArray addObject:header];
		
		if (!_scrollHeight) _scrollHeight = self.height - header.height*count;
		CGFloat height = (i==_index ? _scrollHeight : 0);
		
		view = [_delegate AJVerticalTab:self viewOfIndex:i];
		UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, header.bottom, self.width, height)];
		scrollView.contentSize = CGSizeMake(scrollView.width, view.bottom);
		scrollView.delegate = self;
		scrollView.tag = 50 + i;
		[scrollView addSubview:view];
		[self addSubview:scrollView];
		
		if (i==_index) {
			_currentView = header;
			_selectedScrollView = scrollView;
		}
		
		bottom = scrollView.bottom;
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJVerticalTab:didSelectedIndex:)]) {
		[_delegate AJVerticalTab:self didSelectedIndex:_selectedIndex];
	}
}

- (void)changePosition:(UIView*)header{
	[self changePosition:header animated:YES];
}

- (void)changePosition:(UIView*)header animated:(BOOL)animated{
	if ([_currentView isEqual:header]) return;
	_selectedIndex = [_headerArray indexOfObject:header];
	_currentView = header;
	_selectedScrollView = (UIScrollView*)header.nextView;
	for (NSInteger i=0; i<self.subviews.count; i++) {
		UIView *view = self.subviews[i];
		if ([view isKindOfClass:[UIScrollView class]]) continue;
		if (i==0) {
			UIView *next = view.nextView;
			[UIView animateWithDuration:(animated ? 0.3 : 0) animations:^{
				if ([view isEqual:header]) {
					next.height = _scrollHeight;
				} else {
					next.height = 0;
				}
			}];
		} else {
			UIView *prev = view.prevView;
			UIView *next = view.nextView;
			[UIView animateWithDuration:(animated ? 0.3 : 0) animations:^{
				view.top = prev.bottom;
				next.top = view.bottom;
				if ([view isEqual:header]) {
					next.height = _scrollHeight;
				} else {
					next.height = 0;
				}
			}];
		}
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJVerticalTab:didSelectedIndex:)]) {
		[_delegate AJVerticalTab:self didSelectedIndex:_selectedIndex];
	}
}

- (void)selectedTabOfIndex:(NSInteger)index animated:(BOOL)animated{
	[self changePosition:_headerArray[index] animated:animated];
}

- (void)reloadData{
	[self removeAllSubviews];
	[self initialize];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	if (_delegate && [_delegate respondsToSelector:@selector(AJVerticalTab:scrollViewDidEndDecelerating:)]) {
		[_delegate AJVerticalTab:self scrollViewDidEndDecelerating:scrollView];
	}
}

@end
