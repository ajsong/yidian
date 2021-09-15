//
//  AJPickerView.m
//
//  Created by ajsong on 15/6/8.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "AJPickerView.h"
#import "AJActionView.h"

#define SCREEN [UIScreen mainScreen].bounds

@interface AJPickerView ()<UIPickerViewDataSource,UIPickerViewDelegate,AJActionViewDelegate>{
	NSMutableArray *_pickerData;
	UIPickerView *_pickerView;
	AJActionView *_actionView;
}
@end

@implementation AJPickerView

- (id)init{
	self = [super init];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		_pickerData = [[NSMutableArray alloc]init];
		[self performSelector:@selector(loadViews) withObject:nil afterDelay:0];
	}
	return self;
}

- (void)loadViews{
	_pickerView = [[UIPickerView alloc]init];
	_pickerView.backgroundColor = [UIColor clearColor];
	_pickerView.delegate = self;
	_pickerView.dataSource = self;
	
	_actionView = [[AJActionView alloc]initWithTitle:_title view:_pickerView delegate:self];
}

- (void)setData:(NSArray *)data{
	if (!data.count) return;
	_data = data;
	[_pickerData removeAllObjects];
	if ([data[0] isKindOfClass:[NSArray class]]) {
		_pickerData = [NSMutableArray arrayWithArray:data];
	} else {
		_pickerData = [NSMutableArray arrayWithObjects:data, nil];
	}
	[_pickerView reloadAllComponents];
}

- (void)setIndex:(NSInteger)index{
	_index = index;
	[_pickerView selectRow:index inComponent:0 animated:NO];
}

- (void)show{
	[_actionView show];
}

- (void)close{
	[_actionView close];
}

#pragma mark - AJActionViewDelegate
- (void)AJActionViewWillShow:(AJActionView *)actionView{
	if (!_pickerData.count) return;
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSelectRows:)]) {
		NSMutableArray *indexs = [[NSMutableArray alloc]init];
		for (int i=0; i<_pickerData.count; i++) {
			[indexs addObject:@([_pickerView selectedRowInComponent:i])];
		}
		[_delegate AJPickerView:self didSelectRows:indexs];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSelectTexts:)]) {
		NSMutableArray *texts = [[NSMutableArray alloc]init];
		for (int i=0; i<_pickerData.count; i++) {
			[texts addObject:_pickerData[i][[_pickerView selectedRowInComponent:i]]];
		}
		[_delegate AJPickerView:self didSelectTexts:texts];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSelectRow:inComponent:)]) {
		[_delegate AJPickerView:self didSelectRow:[_pickerView selectedRowInComponent:0] inComponent:0];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSelectText:inComponent:)]) {
		NSString *text = _pickerData[0][[_pickerView selectedRowInComponent:0]];
		[_delegate AJPickerView:self didSelectText:text inComponent:0];
	}
}

- (void)AJActionViewDidSubmit:(AJActionView *)actionView{
	if (!_pickerData.count) return;
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSubmitRows:)]) {
		NSMutableArray *indexs = [[NSMutableArray alloc]init];
		for (int i=0; i<_pickerData.count; i++) {
			[indexs addObject:@([_pickerView selectedRowInComponent:i])];
		}
		[_delegate AJPickerView:self didSubmitRows:indexs];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSubmitTexts:)]) {
		NSMutableArray *texts = [[NSMutableArray alloc]init];
		for (int i=0; i<_pickerData.count; i++) {
			[texts addObject:_pickerData[i][[_pickerView selectedRowInComponent:i]]];
		}
		[_delegate AJPickerView:self didSubmitTexts:texts];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSubmitRow:inComponent:)]) {
		[_delegate AJPickerView:self didSubmitRow:[_pickerView selectedRowInComponent:0] inComponent:0];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSubmitText:inComponent:)]) {
		NSString *text = _pickerData[0][[_pickerView selectedRowInComponent:0]];
		[_delegate AJPickerView:self didSubmitText:text inComponent:0];
	}
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return _pickerData.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	if (!_pickerData.count) return 0;
	return [_pickerData[component] count];
}

#pragma mark - UIPickerViewDelegate
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	return [_pickerData[component][row] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	if (!_pickerData.count) return;
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSelectRows:)]) {
		NSMutableArray *indexs = [[NSMutableArray alloc]init];
		for (int i=0; i<_pickerData.count; i++) {
			[indexs addObject:@([_pickerView selectedRowInComponent:i])];
		}
		[_delegate AJPickerView:self didSelectRows:indexs];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSelectTexts:)]) {
		NSMutableArray *texts = [[NSMutableArray alloc]init];
		for (int i=0; i<_pickerData.count; i++) {
			[texts addObject:_pickerData[i][[_pickerView selectedRowInComponent:i]]];
		}
		[_delegate AJPickerView:self didSelectTexts:texts];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSelectRow:inComponent:)]) {
		[_delegate AJPickerView:self didSelectRow:row inComponent:component];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSelectText:inComponent:)]) {
		NSString *text = _pickerData[component][row];
		[_delegate AJPickerView:self didSelectText:text inComponent:component];
	}
}

@end
