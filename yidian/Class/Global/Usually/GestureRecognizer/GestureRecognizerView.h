//
//  GestureRecognizerView.h
//
//  Created by ajsong on 15/4/21.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DragGestureRecognizerViewDelegate<NSObject>
@optional
- (UIEdgeInsets)dragGestureRecognizerViewWithMoveInMaxArea:(UIView*)view;
- (void)dragGestureRecognizerViewWithMove:(UIView*)view;
@end

@interface GestureRecognizerView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic,retain) id<DragGestureRecognizerViewDelegate> delegate;

- (void)addTapGestureRecognizerWithTarget:(id)target action:(SEL)action;
- (void)addLongPressGestureRecognizerWithTarget:(id)target action:(SEL)action;
- (void)addPanGestureRecognizerWithCompletion:(void (^)(NSInteger direction))completion;
- (void)addRotationGestureRecognizerWithCompletion:(void (^)(NSInteger rotate))completion;
- (void)addPinchGestureRecognizerWithCompletion:(void (^)(NSInteger scale))completion;
- (void)addDragGestureRecognizerWithOutParent:(BOOL)outParent completion:(void (^)(CGPoint center))completion;

@end
