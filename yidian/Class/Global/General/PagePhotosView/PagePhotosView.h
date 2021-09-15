//
//  PagePhotosView.h
//
//  Created by ajsong on 15/10/18.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PAGECONTROL_HEIGHT 20

@class PagePhotosView;

@protocol PagePhotosDataSource<NSObject>
@required
- (NSInteger)pagePhotosViewNumberOfPages:(PagePhotosView*)pagePhotosView; //页数
- (UIView*)pagePhotosView:(PagePhotosView*)pagePhotosView viewAtIndex:(NSInteger)index; //每页视图
@optional
- (void)pagePhotosView:(PagePhotosView*)pagePhotosView panLeftEdge:(UIPanGestureRecognizer*)panParam; //滑动左边界时传递手势
- (void)pagePhotosView:(PagePhotosView*)pagePhotosView panRightEdge:(UIPanGestureRecognizer*)panParam; //滑动右边界时传递手势
- (void)pagePhotosView:(PagePhotosView*)pagePhotosView scrollViewDidEndDecelerating:(UIScrollView*)scrollView;
- (void)pagePhotosView:(PagePhotosView*)pagePhotosView scrollViewWillBeginDragging:(UIScrollView*)scrollView;
- (void)pagePhotosView:(PagePhotosView*)pagePhotosView scrollViewDidEndDragging:(UIScrollView*)scrollView;
@end

typedef enum : NSInteger {
	PagePhotosControlPositionCenter = 0, //居中
	PagePhotosControlPositionLeft, //居左
	PagePhotosControlPositionRight, //居右
} PagePhotosControlPosition;

@interface PagePhotosView : UIView
@property (nonatomic,retain) id<PagePhotosDataSource> dataSource;
@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,assign) NSTimeInterval scrollTime; //滚动间隔
@property (nonatomic,retain) UIPageControl *pageControl; //点容器
@property (nonatomic,assign) PagePhotosControlPosition controlPosition; //点位置
@property (nonatomic,retain) UIColor *pageIndicatorTintColor; //点默认颜色
@property (nonatomic,retain) UIColor *currentPageIndicatorTintColor; //点当前颜色
@property (nonatomic,assign) CGFloat pageControlMarginBottom; //点距离底部高度
@property (nonatomic,assign) BOOL loop;
- (void)scrollToPrevPage;
- (void)scrollToNextPage;
- (void)scrollToPage:(NSInteger)index;
- (void)start;
- (void)stop;
@end
