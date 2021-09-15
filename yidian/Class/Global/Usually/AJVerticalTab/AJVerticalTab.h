//
//  AJVerticalTab.h
//
//  Created by ajsong on 15/9/18.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AJVerticalTab;

@protocol AJVerticalTabDelegate<NSObject>
@optional
- (void)AJVerticalTab:(AJVerticalTab*)verticalTab didSelectedIndex:(NSInteger)index;
- (void)AJVerticalTab:(AJVerticalTab*)verticalTab scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
@required
- (NSInteger)AJVerticalTabWithNumber:(AJVerticalTab*)verticalTab;
- (UIView*)AJVerticalTab:(AJVerticalTab*)verticalTab headerOfIndex:(NSInteger)index;
- (UIView*)AJVerticalTab:(AJVerticalTab*)verticalTab viewOfIndex:(NSInteger)index;
@end

@interface AJVerticalTab : UIView
@property (nonatomic,retain) id<AJVerticalTabDelegate> delegate;
@property (nonatomic,assign) NSInteger index; //默认打开的索引
@property (nonatomic,assign) NSInteger selectedIndex; //当前选中的索引
@property (nonatomic,retain) UIScrollView *selectedScrollView;
- (void)reloadData;
- (void)selectedTabOfIndex:(NSInteger)index animated:(BOOL)animated;
@end
