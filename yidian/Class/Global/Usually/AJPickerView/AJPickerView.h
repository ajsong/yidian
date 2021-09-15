//
//  AJPickerView.h
//
//  Created by ajsong on 15/6/8.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AJPickerViewDelegate;

@interface AJPickerView : UIView
@property (nonatomic,retain) id<AJPickerViewDelegate> delegate;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSArray *data;
@property (nonatomic,assign) NSInteger index;
- (void)show;
- (void)close;
@end

@protocol AJPickerViewDelegate<NSObject>
@optional
- (void)AJPickerView:(AJPickerView*)pickerView didSelectRows:(NSArray*)indexs;
- (void)AJPickerView:(AJPickerView*)pickerView didSelectTexts:(NSArray*)texts;
- (void)AJPickerView:(AJPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
- (void)AJPickerView:(AJPickerView*)pickerView didSelectText:(NSString*)text inComponent:(NSInteger)component;
- (void)AJPickerView:(AJPickerView*)pickerView didSubmitRows:(NSArray*)indexs;
- (void)AJPickerView:(AJPickerView*)pickerView didSubmitTexts:(NSArray*)texts;
- (void)AJPickerView:(AJPickerView*)pickerView didSubmitRow:(NSInteger)row inComponent:(NSInteger)component;
- (void)AJPickerView:(AJPickerView*)pickerView didSubmitText:(NSString*)text inComponent:(NSInteger)component;
@end
