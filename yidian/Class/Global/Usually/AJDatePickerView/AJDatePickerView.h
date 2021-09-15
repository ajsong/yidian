//
//  AJDatePickerView.h
//
//  Created by ajsong on 15/10/12.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AJDatePickerView;
@protocol AJDatePickerViewDelegate<NSObject>
@optional
- (void)AJDatePickerView:(AJDatePickerView*)pickerView didSelectWithDate:(NSDate*)date year:(NSString*)year month:(NSString*)month;
- (void)AJDatePickerView:(AJDatePickerView*)pickerView didSubmitWithDate:(NSDate*)date year:(NSString*)year month:(NSString*)month;
@end

@interface AJDatePickerView : UIView
@property (nonatomic,retain) id<AJDatePickerViewDelegate> delegate;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSDate *date;
@property (nonatomic,retain) NSDate *minimumDate;
@property (nonatomic,retain) NSDate *maximumDate;
@property (nonatomic,assign) BOOL shortType; //短日期(只有年月)
- (void)show;
- (void)close;
@end

