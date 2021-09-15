//
//  AreaPickerView.m
//
//  Created by ajsong on 15/4/8.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "AreaPicker.h"
#import "AJActionView.h"

@interface AreaPickerView ()<AJActionViewDelegate,AreaPickerViewDelegate>{
	AreaPicker *_areaPicker;
	AJActionView *_actionView;
	BOOL _firstShow;
}
@end

@implementation AreaPickerView

- (id)init{
	self = [super init];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		_firstShow = YES;
		_autoLocation = YES;
		
		_areaPicker = [[AreaPicker alloc]init];
		_areaPicker.delegate = self;
		
		_actionView = [[AJActionView alloc]initWithTitle:@"选择地区" view:_areaPicker delegate:self];
		_areaPicker.frame = CGRectMake((_actionView.frame.size.width-_areaPicker.frame.size.width)/2, 0, _areaPicker.frame.size.width, _areaPicker.frame.size.height);
		_picker = _areaPicker.picker;
		
		CGRect frame = _picker.frame;
		frame.origin.y += 25;
		_picker.frame = frame;
	}
	return self;
}

- (void)setIsAll:(BOOL)isAll{
	_areaPicker.isAll = isAll;
}

- (void)setProvince:(NSString *)province{
	if (!province.length) return;
	_province = province;
	_areaPicker.province = province;
	_autoLocation = NO;
}
- (void)setCity:(NSString *)city{
	if (!city.length) return;
	_city = city;
	_areaPicker.city = city;
	_autoLocation = NO;
}
-(void)setDistrict:(NSString *)district{
	if (!district.length) return;
	_district = district;
	_areaPicker.district = district;
	_autoLocation = NO;
}

- (void)setProvinceCode:(NSString *)provinceCode{
	if (!provinceCode.length) return;
	_provinceCode = provinceCode;
	_areaPicker.provinceCode = provinceCode;
	_autoLocation = NO;
}
- (void)setCityCode:(NSString *)cityCode{
	if (!cityCode.length) return;
	_cityCode = cityCode;
	_areaPicker.cityCode = cityCode;
	_autoLocation = NO;
}
- (void)setDistrictCode:(NSString *)districtCode{
	if (!districtCode.length) return;
	_districtCode = districtCode;
	_areaPicker.districtCode = districtCode;
	_autoLocation = NO;
}

- (void)show{
	if (_autoLocation && _firstShow && !_district.length) [_areaPicker getLocation];
	_firstShow = NO;
	[_actionView show];
}

- (void)close{
	[_actionView close];
}

#pragma mark - AJActionViewDelegate
- (void)AJActionViewWillShow:(AJActionView *)actionView{
	[_areaPicker selectRow];
	if (_delegate && [_delegate respondsToSelector:@selector(areaPickerView:didSelectWithProvince:city:district:combo:)]) {
		NSString *combo = [AreaPickerView comboWithProvince:_areaPicker.province city:_areaPicker.city district:_areaPicker.district];
		[_delegate areaPickerView:_picker didSelectWithProvince:_areaPicker.province city:_areaPicker.city district:_areaPicker.district combo:combo];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(areaPickerView:didSelectWithProvinceCode:cityCode:districtCode:)]) {
		[_delegate areaPickerView:_picker didSelectWithProvinceCode:_areaPicker.provinceCode cityCode:_areaPicker.cityCode districtCode:_areaPicker.districtCode];
	}
}

- (void)AJActionViewDidSubmit:(AJActionView *)actionView{
	if (_delegate && [_delegate respondsToSelector:@selector(areaPickerView:didSubmitWithProvince:city:district:combo:)]) {
		NSString *combo = [AreaPickerView comboWithProvince:_areaPicker.province city:_areaPicker.city district:_areaPicker.district];
		[_delegate areaPickerView:_picker didSubmitWithProvince:_areaPicker.province city:_areaPicker.city district:_areaPicker.district combo:combo];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(areaPickerView:didSubmitWithProvinceCode:cityCode:districtCode:)]) {
		[_delegate areaPickerView:_picker didSubmitWithProvinceCode:_areaPicker.provinceCode cityCode:_areaPicker.cityCode districtCode:_areaPicker.districtCode];
	}
}

- (void)areaPickerView:(UIPickerView *)picker didSelectWithProvince:(NSString *)province city:(NSString *)city district:(NSString *)district combo:(NSString *)combo{
	if (_delegate && [_delegate respondsToSelector:@selector(areaPickerView:didSelectWithProvince:city:district:combo:)]) {
		[_delegate areaPickerView:_picker didSelectWithProvince:_areaPicker.province city:_areaPicker.city district:_areaPicker.district combo:combo];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(areaPickerView:didSelectWithProvinceCode:cityCode:districtCode:)]) {
		[_delegate areaPickerView:_picker didSelectWithProvinceCode:_areaPicker.provinceCode cityCode:_areaPicker.cityCode districtCode:_areaPicker.districtCode];
	}
}

+ (NSString*)comboWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district{
	NSString *combo = @"";
	if (province.length && city.length && district.length) {
		if ([province isEqualToString:city]) {
			combo = [NSString stringWithFormat:@"%@%@", city, district];
		} else {
			combo = [NSString stringWithFormat:@"%@%@%@", province, city, district];
		}
	}
	return combo;
}

+ (NSString*)comboWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district address:(NSString*)address{
	NSString *combo = [AreaPickerView comboWithProvince:province city:city district:district];
	return [NSString stringWithFormat:@"%@%@", combo, address];
}

@end
