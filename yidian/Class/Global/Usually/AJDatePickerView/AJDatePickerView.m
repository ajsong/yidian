//
//  AJDatePickerView.m
//
//  Created by ajsong on 15/10/12.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import "AJDatePickerView.h"
#import "AJActionView.h"

@interface AJDatePickerView ()<UIPickerViewDataSource,UIPickerViewDelegate,AJActionViewDelegate>{
	UIDatePicker *_datepicker;
	NSMutableArray *_years;
	NSMutableArray *_months;
	UIPickerView *_pickerView;
	AJActionView *_actionView;
	NSInteger _minYear;
	NSInteger _maxYear;
}
@end

@implementation AJDatePickerView

- (id)init{
	self = [super init];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		_years = [[NSMutableArray alloc]init];
		_months = [[NSMutableArray alloc]init];
		_date = [NSDate date];
		[self performSelector:@selector(loadViews) withObject:nil afterDelay:0];
	}
	return self;
}

- (void)loadViews{
	if (_shortType) {
		NSDate *date  = [NSDate date];
		if (!_minimumDate) {
			if (_maximumDate) {
				_minimumDate = [self dateAdd:@"yyyy" interval:-24 date:_maximumDate];
			} else {
				_minimumDate = [self dateAdd:@"yyyy" interval:-12 date:date];
			}
		}
		if (!_maximumDate) {
			if (_minimumDate) {
				_maximumDate = [self dateAdd:@"yyyy" interval:24 date:_minimumDate];
			} else {
				_maximumDate = [self dateAdd:@"yyyy" interval:12 date:date];
			}
		}
		_minYear = [self getYear:_minimumDate];
		_maxYear = [self getYear:_maximumDate];
		NSInteger curYear = [self getYear:_date ? _date : date];
		if (curYear<_minYear) curYear = _minYear;
		if (curYear>_maxYear) curYear = _maxYear;
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
		[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		
		[formatter setDateFormat:@"yyyy"];
		for (NSInteger i=_minYear-10; i<=_maxYear+10; i++) {
			NSString *year = [NSString stringWithFormat:@"%ld", (long)i];
			[_years addObject:year];
		}
		
		[formatter setDateFormat:@"MM"];
		for (NSInteger i=1; i<=12; i++) {
			NSString *month = [NSString stringWithFormat:@"%ld", (long)i];
			[_months addObject:month];
		}
		
		_pickerView = [[UIPickerView alloc]init];
		_pickerView.backgroundColor = [UIColor clearColor];
		_pickerView.delegate = self;
		_pickerView.dataSource = self;
		
		_actionView = [[AJActionView alloc]initWithTitle:_title view:_pickerView delegate:self];
		[_pickerView selectRow:[_years indexOfObject:[NSString stringWithFormat:@"%ld", (long)curYear]] inComponent:0 animated:NO];
		[self selectMonth];
	} else {
		_datepicker = [[UIDatePicker alloc]init];
		_datepicker.backgroundColor = [UIColor clearColor];
		_datepicker.datePickerMode = UIDatePickerModeDate;
		_datepicker.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
		if (_date) _datepicker.date = _date;
		if (_minimumDate) _datepicker.minimumDate = _minimumDate;
		if (_maximumDate) _datepicker.maximumDate = _maximumDate;
		
		_actionView = [[AJActionView alloc]initWithTitle:_title view:_datepicker delegate:self];
	}
}

- (void)setDate:(NSDate *)date{
	_date = date;
	NSInteger curYear = [self getYear:_date];
	if (curYear<_minYear) curYear = _minYear;
	if (curYear>_maxYear) curYear = _maxYear;
	[_pickerView selectRow:[_years indexOfObject:[NSString stringWithFormat:@"%ld", (long)curYear]] inComponent:0 animated:NO];
	[self selectMonth];
}

- (void)setMinimumDate:(NSDate *)minimumDate{
	_minimumDate = minimumDate;
	_maximumDate = [self dateAdd:@"yyyy" interval:24 date:_minimumDate];
	if (!_pickerView) return;
	_minYear = [self getYear:_minimumDate];
	_maxYear = [self getYear:_maximumDate];
	NSInteger curYear = [self getYear:_date];
	if (curYear<_minYear) curYear = _minYear;
	if (curYear>_maxYear) curYear = _maxYear;
	
	[_years removeAllObjects];
	[_months removeAllObjects];
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	[formatter setDateFormat:@"yyyy"];
	for (NSInteger i=_minYear-10; i<=_maxYear+10; i++) {
		NSString *year = [NSString stringWithFormat:@"%ld", (long)i];
		[_years addObject:year];
	}
	
	[formatter setDateFormat:@"MM"];
	for (int i=1; i<=12; i++) {
		NSString *month = [NSString stringWithFormat:@"%d", i];
		[_months addObject:month];
	}
	
	[_pickerView reloadAllComponents];
	[_pickerView selectRow:[_years indexOfObject:[NSString stringWithFormat:@"%ld", (long)curYear]] inComponent:0 animated:NO];
	[self selectMonth];
}

- (void)setMaximumDate:(NSDate *)maximumDate{
	_maximumDate = maximumDate;
	_minimumDate = [self dateAdd:@"yyyy" interval:-24 date:_maximumDate];
	if (!_pickerView) return;
	_minYear = [self getYear:_minimumDate];
	_maxYear = [self getYear:_maximumDate];
	NSInteger curYear = [self getYear:_date];
	if (curYear<_minYear) curYear = _minYear;
	if (curYear>_maxYear) curYear = _maxYear;
	
	[_years removeAllObjects];
	[_months removeAllObjects];
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	[formatter setDateFormat:@"yyyy"];
	for (NSInteger i=_minYear-10; i<=_maxYear+10; i++) {
		NSString *year = [NSString stringWithFormat:@"%ld", (long)i];
		[_years addObject:year];
	}
	
	[formatter setDateFormat:@"MM"];
	for (int i=1; i<=12; i++) {
		NSString *month = [NSString stringWithFormat:@"%d", i];
		[_months addObject:month];
	}
	
	[_pickerView reloadAllComponents];
	[_pickerView selectRow:[_years indexOfObject:[NSString stringWithFormat:@"%ld", (long)curYear]] inComponent:0 animated:NO];
	[self selectMonth];
}

- (void)show{
	[_actionView show];
}

- (void)close{
	[_actionView close];
}

#pragma mark - AJActionViewDelegate
- (void)AJActionViewWillShow:(AJActionView *)actionView{
	if (_delegate && [_delegate respondsToSelector:@selector(AJDatePickerView:didSelectWithDate:year:month:)]) {
		if (_shortType) {
			NSInteger year = [_pickerView selectedRowInComponent:0];
			NSInteger month = [_pickerView selectedRowInComponent:1];
			NSDate *date = [self strToDateWithYear:_years[year] month:_months[month]];
			[_delegate AJDatePickerView:self didSelectWithDate:date year:_years[year] month:_months[month]];
		} else {
			NSString *year = [NSString stringWithFormat:@"%ld", (long)[self getYear:_datepicker.date]];
			NSString *month = [NSString stringWithFormat:@"%ld", (long)[self getMonth:_datepicker.date]];
			[_delegate AJDatePickerView:self didSelectWithDate:_datepicker.date year:year month:month];
		}
	}
}

- (void)AJActionViewDidSubmit:(AJActionView *)actionView{
	if (_delegate && [_delegate respondsToSelector:@selector(AJDatePickerView:didSubmitWithDate:year:month:)]) {
		if (_shortType) {
			NSInteger year = [_pickerView selectedRowInComponent:0];
			NSInteger month = [_pickerView selectedRowInComponent:1];
			NSDate *date = [self strToDateWithYear:_years[year] month:_months[month]];
			[_delegate AJDatePickerView:self didSubmitWithDate:date year:_years[year] month:_months[month]];
		} else {
			NSString *year = [NSString stringWithFormat:@"%ld", (long)[self getYear:_datepicker.date]];
			NSString *month = [NSString stringWithFormat:@"%ld", (long)[self getMonth:_datepicker.date]];
			[_delegate AJDatePickerView:self didSubmitWithDate:_datepicker.date year:year month:month];
		}
	}
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	return component==0 ? _years.count : _months.count;
}

#pragma mark - UIPickerViewDelegate
- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
	UILabel *label = [[UILabel alloc]init];
	if (component==0) {
		label.text = [NSString stringWithFormat:@"%@年", _years[row]];
		if ([_years[row] integerValue]<_minYear || [_years[row] integerValue]>_maxYear) label.textColor = [UIColor lightGrayColor];
	} else {
		label.text = [NSString stringWithFormat:@"%@月", _months[row]];
		NSInteger year = [_pickerView selectedRowInComponent:0];
		NSInteger minMonth = [self getMonth:_minimumDate];
		NSInteger maxMonth = [self getMonth:_maximumDate];
		if ( ([_years[year]integerValue]==_minYear && [_months[row]integerValue]<minMonth) ||
			([_years[year]integerValue]==_maxYear && [_months[row]integerValue]>maxMonth) ) {
			label.textColor = [UIColor lightGrayColor];
		}
	}
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont systemFontOfSize:24.f];
	label.backgroundColor = [UIColor clearColor];
	return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	if (component==0) {
		if (_minYear>[_years[row]integerValue]) {
			[_pickerView selectRow:[_years indexOfObject:[NSString stringWithFormat:@"%ld", (long)_minYear]] inComponent:0 animated:YES];
		}
		if (_maxYear<[_years[row]integerValue]) {
			[_pickerView selectRow:[_years indexOfObject:[NSString stringWithFormat:@"%ld", (long)_maxYear]] inComponent:0 animated:YES];
		}
		[pickerView reloadComponent:1];
	}
	[self selectMonth:YES];
	if (_delegate && [_delegate respondsToSelector:@selector(AJDatePickerView:didSelectWithDate:year:month:)]) {
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				NSInteger year = [_pickerView selectedRowInComponent:0];
				NSInteger month = [_pickerView selectedRowInComponent:1];
				NSDate *date = [self strToDateWithYear:_years[year] month:_months[month]];
				[_delegate AJDatePickerView:self didSelectWithDate:date year:_years[year] month:_months[month]];
			});
		});
	}
}

- (void)selectMonth{
	[self selectMonth:NO];
}

- (void)selectMonth:(BOOL)control{
	if (!_years.count || !_months.count || !_pickerView) return;
	NSInteger year = [_pickerView selectedRowInComponent:0];
	NSInteger month = [_pickerView selectedRowInComponent:1];
	NSInteger minMonth = [self getMonth:_minimumDate];
	NSInteger maxMonth = [self getMonth:_maximumDate];
	if ([_years[year]integerValue]==_minYear && [_months[month]integerValue]<minMonth) {
		[_pickerView selectRow:[_months indexOfObject:[NSString stringWithFormat:@"%ld", (long)minMonth]] inComponent:1 animated:YES];
	} else if ([_years[year]integerValue]==_maxYear && [_months[month]integerValue]>maxMonth) {
		[_pickerView selectRow:[_months indexOfObject:[NSString stringWithFormat:@"%ld", (long)maxMonth]] inComponent:1 animated:YES];
	} else {
		if (control) return;
		NSInteger curMonth = [self getMonth:_date ? _date : [NSDate date]];
		[_pickerView selectRow:curMonth-1 inComponent:1 animated:NO];
	}
}

- (NSDate*)dateAdd:(NSString*)range interval:(NSInteger)number date:(id)dt{
	NSArray *intervalName = [NSArray arrayWithObjects:@"yyyy",@"m",@"w",@"d",@"h",@"n",@"s",nil];
	NSInteger index = [intervalName indexOfObject:range];
	NSInteger time = 0;
	switch (index) {
		case 0:
			time = 60 * 60 * 24 * 365;break;
		case 1:
			time = 60 * 60 * 24 * 30;break;
		case 2:
			time = 60 * 60 * 24 * 7;break;
		case 3:
			time = 60 * 60 * 24;break;
		case 4:
			time = 60 * 60;break;
		case 5:
			time = 60;break;
		case 6:
			time = 1;break;
	}
	return [dt dateByAddingTimeInterval:number * time];
}

- (NSInteger)getYear:(NSDate*)date{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDateComponents *comps = [calendar components:NSYearCalendarUnit fromDate:date];
	return [comps year];
}

- (NSInteger)getMonth:(NSDate*)date{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDateComponents *comps = [calendar components:NSMonthCalendarUnit fromDate:date];
	return [comps month];
}

- (NSDate*)strToDateWithYear:(NSString*)year month:(NSString*)month{
	NSDateComponents *compt = [[NSDateComponents alloc] init];
	[compt setYear:[year integerValue]];
	[compt setMonth:[month integerValue]];
	[compt setDay:1];
	[compt setHour:0];
	[compt setMinute:0];
	[compt setSecond:0];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	return [calendar dateFromComponents:compt];
}

@end
