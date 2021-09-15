//
//  SpecialTextView.h
//
//  Created by ajsong on 14/12/6.
//  Copyright (c) 2014 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SpecialTextViewDelegate<NSObject>
@optional
- (void)SpecialTextViewChangeHeight:(UITextView*)textView currentHeight:(CGFloat)height;
@end

@interface SpecialTextView : UITextView{
	CGFloat _minHeight;
	CGFloat _maxHeight;
}

@property (nonatomic,retain) NSString *placeholder;
@property (nonatomic,retain) UIColor *placeholderColor;
@property (nonatomic,retain) UIFont *placeholderFont;
@property (nonatomic,assign) BOOL placeholderHidden;

@property (nonatomic,assign) UIEdgeInsets padding;

@property (nonatomic,assign) CGFloat lineHeight;

@property (nonatomic,retain) UIFont *textFont;

@property (nonatomic,retain) id<SpecialTextViewDelegate> autoHeightDelegate;
@property (nonatomic,assign) NSInteger numberOfLines; //设置后自动高度

- (void)insertImage:(UIImage*)image imageMark:(NSString*)imageMark;
- (void)insertImage:(UIImage*)image imageMark:(NSString*)imageMark imageWidth:(CGFloat)width imageHeight:(CGFloat)height;
- (NSString*)code;
- (void)placeholderCheckText;
- (void)textViewDidChangeText:(UITextView*)textView;

@end
