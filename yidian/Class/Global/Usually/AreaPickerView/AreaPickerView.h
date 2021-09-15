//
//  AreaPickerView.h
//
//  Created by ajsong on 15/4/8.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCLocationManager.h"

@protocol AreaPickerViewDelegate;

@interface AreaPickerView : UIView
@property (nonatomic,weak) id<AreaPickerViewDelegate> delegate;
@property (nonatomic,strong) UIPickerView *picker;
@property (nonatomic,strong) NSString *province;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *district;
@property (nonatomic,strong) NSString *provinceCode;
@property (nonatomic,strong) NSString *cityCode;
@property (nonatomic,strong) NSString *districtCode;
@property (nonatomic,assign) BOOL autoLocation;
@property (nonatomic,assign) BOOL isAll;

- (void)show;
- (void)close;
+ (NSString*)comboWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district;
+ (NSString*)comboWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district address:(NSString*)address;
@end

@protocol AreaPickerViewDelegate<NSObject>
@optional
- (void)areaPickerView:(UIPickerView*)picker didSubmitWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district combo:(NSString*)combo;
- (void)areaPickerView:(UIPickerView*)picker didSelectWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district combo:(NSString*)combo;
- (void)areaPickerView:(UIPickerView*)picker didSubmitWithProvinceCode:(NSString*)provinceCode cityCode:(NSString*)cityCode districtCode:(NSString*)districtCode;
- (void)areaPickerView:(UIPickerView*)picker didSelectWithProvinceCode:(NSString*)provinceCode cityCode:(NSString*)cityCode districtCode:(NSString*)districtCode;
@end