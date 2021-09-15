//
//  AJActionView.h
//  dsx
//
//  Created by ajsong on 15/9/14.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AJActionViewDelegate;

@interface AJActionView : UIView
@property (nonatomic,retain) id<AJActionViewDelegate> delegate;
@property (nonatomic,retain) UIView *mainView;
@property (nonatomic,retain) UIView *view;
@property (nonatomic,retain) NSArray *buttons;
@property (nonatomic,retain) NSArray *buttonColors;
@property (nonatomic,assign) CGFloat scale;
- (id)initWithTitle:(NSString*)title view:(UIView*)view delegate:(id<AJActionViewDelegate>)delegate;
- (void)show;
- (void)close;
@end

@protocol AJActionViewDelegate<NSObject>
@optional
- (void)AJActionViewWillShow:(AJActionView*)actionView;
- (void)AJActionViewDidSubmit:(AJActionView*)actionView;
- (void)AJActionViewDidClose:(AJActionView*)actionView;
- (void)AJActionView:(AJActionView*)actionView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end
