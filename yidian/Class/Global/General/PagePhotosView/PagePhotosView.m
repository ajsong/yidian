//
//  PagePhotosView.m
//
//  Created by ajsong on 15/10/18.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PagePhotosView.h"

@interface PagePhotosView ()<UIScrollViewDelegate>{
	NSTimer *_pageTimer;
}
@end

@implementation PagePhotosView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    if (self) {
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		_scrollView.pagingEnabled = YES;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.scrollsToTop = NO;
		_scrollView.delegate = self;
		[_scrollView.panGestureRecognizer addTarget:self action:@selector(scrollHandlePan:)];
		[self addSubview:_scrollView];
		
		_pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - PAGECONTROL_HEIGHT, frame.size.width, PAGECONTROL_HEIGHT)];
		_pageControl.currentPage = 0;
		_pageControl.backgroundColor = [UIColor clearColor];
		_pageControl.userInteractionEnabled = YES;
		[self addSubview:_pageControl];
		
		_pageTimer = nil;
		_scrollTime = 0;
		_controlPosition = PagePhotosControlPositionCenter;
		_loop = YES;
    }
    return self;
}

- (void)setPageControlMarginBottom:(CGFloat)pageControlMarginBottom{
	CGRect frame = _pageControl.frame;
	frame.origin.y = self.frame.size.height - PAGECONTROL_HEIGHT - pageControlMarginBottom;
	_pageControl.frame = frame;
}

- (void)setDataSource:(id<PagePhotosDataSource>)dataSource{
	_dataSource = dataSource;
	CGSize size = self.frame.size;
	NSInteger pages = [dataSource pagePhotosViewNumberOfPages:self];
	if (pages==0) return;
	
	CGSize pointSize = [_pageControl sizeForNumberOfPages:pages];
	CGFloat x = 0;
	switch (_controlPosition) {
		case PagePhotosControlPositionCenter:
			x = (_scrollView.frame.size.width - pointSize.width)/2;
			break;
		case PagePhotosControlPositionLeft:
			x = 10;
			break;
		case PagePhotosControlPositionRight:
			x = _scrollView.frame.size.width - pointSize.width - 10;
			break;
	}
	_pageControl.frame = CGRectMake(x, _pageControl.frame.origin.y, pointSize.width, _pageControl.frame.size.height);
	_pageControl.numberOfPages = pages;
	
	if (!_loop) {
		_scrollView.contentSize = CGSizeMake(size.width * pages, size.height);
		for (NSInteger i=0; i<pages; i++) {
			UIView *view = [dataSource pagePhotosView:self viewAtIndex:i];
			view.frame = CGRectMake(size.width * i, 0, view.frame.size.width, view.frame.size.height);
			[_scrollView addSubview:view];
		}
		return;
	}
	
	_scrollView.contentSize = CGSizeMake(size.width * (pages+2), size.height);
	UIView *firstView = [dataSource pagePhotosView:self viewAtIndex:pages-1];
	firstView.frame = CGRectMake(0, 0, firstView.frame.size.width, firstView.frame.size.height);
	[_scrollView addSubview:firstView];
	
	for (NSInteger i=0; i<pages; i++) {
		UIView *view = [dataSource pagePhotosView:self viewAtIndex:i];
		view.frame = CGRectMake(size.width * (i+1), 0, view.frame.size.width, view.frame.size.height);
		[_scrollView addSubview:view];
	}
	
	UIView *lastView = [dataSource pagePhotosView:self viewAtIndex:0];
	lastView.frame = CGRectMake(size.width * (pages+1), 0, lastView.frame.size.width, lastView.frame.size.height);
	[_scrollView addSubview:lastView];
	
	[_scrollView scrollRectToVisible:CGRectMake(size.width, 0, size.width, size.height) animated:NO];
	
	if (_scrollTime>0) {
		[self start];
	}
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor{
	_pageIndicatorTintColor = pageIndicatorTintColor;
	_pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor{
	_currentPageIndicatorTintColor = currentPageIndicatorTintColor;
	_pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}

- (void)scrollToPrevPage{
	NSInteger pages = [_dataSource pagePhotosViewNumberOfPages:self];
	if (pages<=1) return;
	CGSize size = self.frame.size;
	NSInteger index = _pageControl.currentPage;
	index--;
	if (index<0) {
		[_scrollView scrollRectToVisible:CGRectMake(_scrollView.contentSize.width-size.width, 0, size.width, size.height) animated:NO];
		index = pages - 1;
	}
	[_scrollView scrollRectToVisible:CGRectMake(size.width*(index+(_loop?1:0)), 0, size.width, size.height) animated:YES];
	_pageControl.currentPage = index;
}

- (void)scrollToNextPage{
	NSInteger pages = [_dataSource pagePhotosViewNumberOfPages:self];
	if (pages<=1) return;
	CGSize size = self.frame.size;
	NSInteger index = _pageControl.currentPage;
	index++;
	if (index>=pages) {
		[_scrollView scrollRectToVisible:CGRectMake(0, 0, size.width, size.height) animated:NO];
		index = 0;
	}
	[_scrollView scrollRectToVisible:CGRectMake(size.width*(index+(_loop?1:0)), 0, size.width, size.height) animated:YES];
	_pageControl.currentPage = index;
}

- (void)scrollToPage:(NSInteger)index{
	NSInteger pages = [_dataSource pagePhotosViewNumberOfPages:self];
	if (pages<=1) return;
	CGSize size = self.frame.size;
	if (index>=pages) {
		index = 0;
	} else if (index<0) {
		index = pages - 1;
	}
	[_scrollView scrollRectToVisible:CGRectMake(size.width*index, 0, size.width, size.height) animated:YES];
	_pageControl.currentPage = index;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	CGSize size = self.frame.size;
	NSInteger index = fabs(_scrollView.contentOffset.x)/size.width;
	if (!_loop) {
		_pageControl.currentPage = index;
		return;
	}
	
	NSInteger pages = [_dataSource pagePhotosViewNumberOfPages:self];
	if (index==0) {
		[_scrollView scrollRectToVisible:CGRectMake(size.width*pages, 0, size.width, size.height) animated:NO];
		_pageControl.currentPage = pages - 1;
	} else if (index==pages+1) {
		[_scrollView scrollRectToVisible:CGRectMake(size.width, 0, size.width, size.height) animated:NO];
		_pageControl.currentPage = 0;
	} else {
		_pageControl.currentPage = index - 1;
	}
	if (_dataSource && [_dataSource respondsToSelector:@selector(pagePhotosView:scrollViewDidEndDecelerating:)]) {
		[_dataSource pagePhotosView:self scrollViewDidEndDecelerating:scrollView];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
	[self stop];
	if (_dataSource && [_dataSource respondsToSelector:@selector(pagePhotosView:scrollViewWillBeginDragging:)]) {
		[_dataSource pagePhotosView:self scrollViewWillBeginDragging:scrollView];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (_scrollTime>0 && _loop) {
		[self start];
	}
	if (_dataSource && [_dataSource respondsToSelector:@selector(pagePhotosView:scrollViewDidEndDragging:)]) {
		[_dataSource pagePhotosView:self scrollViewDidEndDragging:scrollView];
	}
}

//传递滑动事件给下一层
-(void)scrollHandlePan:(UIPanGestureRecognizer*)panParam{
	//当滑道左边界时，传递滑动事件给代理
	if(_scrollView.contentOffset.x <= 0) {
		if (_dataSource && [_dataSource respondsToSelector:@selector(pagePhotosView:panLeftEdge:)]) {
			[_dataSource pagePhotosView:self panLeftEdge:panParam];
		}
	} else if(_scrollView.contentOffset.x >= _scrollView.contentSize.width - _scrollView.frame.size.width) {
		if (_dataSource && [_dataSource respondsToSelector:@selector(pagePhotosView:panRightEdge:)]) {
			[_dataSource pagePhotosView:self panRightEdge:panParam];
		}
	}
}

- (void)start{
	if (_scrollTime>0) {
		[self stop];
		_pageTimer = [NSTimer scheduledTimerWithTimeInterval:_scrollTime target:self selector:@selector(scrollToNextPage) userInfo:nil repeats:YES];
	}
}

- (void)stop{
	[_pageTimer invalidate];
	_pageTimer = nil;
}

@end
