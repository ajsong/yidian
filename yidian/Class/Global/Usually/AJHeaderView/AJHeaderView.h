//
//  AJHeaderView.h
//
//  Created by ajsong on 14-10-26.
//  Copyright (c) 2014 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AJHeaderViewDelegate;

@interface AJHeaderView : UIView
@property (nonatomic,retain) UIView *view; //顶部
@property (nonatomic,assign) CGFloat minHeight; //顶部最少高度
@property (nonatomic,assign) CGFloat originalHeight; //顶部原始高度
@property (nonatomic,assign) CGFloat fixY; //修复, 一般为顶部高度, scrollView内嵌scrollView才用到
@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,retain) id<AJHeaderViewDelegate> delegate;
- (id)initWithView:(UIView*)view addTo:(UIScrollView*)scrollView;
- (void)updateSubViewsWithScrollOffset:(UIScrollView*)scrollView;
- (void)headerViewDidMinHeight;
- (void)headerViewDidOriginalHeight;
@end

@protocol AJHeaderViewDelegate <NSObject>
@optional
- (void)AJHeaderViewDidOriginalHeight:(AJHeaderView*)headerView headerHeight:(CGFloat)height;
- (void)AJHeaderViewDidMinHeight:(AJHeaderView*)headerView headerHeight:(CGFloat)height;
@end
