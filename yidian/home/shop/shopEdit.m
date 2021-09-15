//
//  shopEdit.m
//  yidian
//
//  Created by ajsong on 16/1/4.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "shopEdit.h"
#import "AreaPicker.h"

@interface shopEdit ()<UITextFieldDelegate,AreaPickerViewDelegate>{
	SpecialTextField *_nameField;
	SpecialTextField *_mobileField;
	SpecialTextField *_textField;
	SpecialTextView *_textView;
	UILabel *_areaLabel;
	AreaPickerView *_areaPicker;
	NSString *_province;
	NSString *_city;
	NSString *_district;
}
@end

@implementation shopEdit

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = BACKCOLOR;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"提交" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchUpInside];
	
	switch (_type) {
		case ShopEditTypeTextView:{
			_textView = [[SpecialTextView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 130)];
			_textView.text = _data[@"value"];
			_textView.placeholder = STRINGFORMAT(@"请填写%@", _data[@"placeholder"]);
			_textView.textColor = [UIColor blackColor];
			_textView.font = FONT(14);
			_textView.backgroundColor = [UIColor whiteColor];
			[self.view addSubview:_textView];
			_textView.padding = UIEdgeInsetsMake(10, 10, 10, 10);
			break;
		}
		case ShopEditTypeRefundAddress:
		case ShopEditTypeAddress:{
			UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
			view.backgroundColor = [UIColor whiteColor];
			[self.view addSubview:view];
			if (_type==ShopEditTypeRefundAddress) {
				[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
				UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 75, view.height)];
				label.text = @"联系人";
				label.textColor = COLOR333;
				label.font = FONT(13);
				label.backgroundColor = [UIColor clearColor];
				[view addSubview:label];
				_nameField = [[SpecialTextField alloc]initWithFrame:CGRectMake(label.right, 0, view.width-label.right-15, view.height)];
				_nameField.text = _data[@"nameValue"];
				_nameField.placeholder = STRINGFORMAT(@"请填写%@", label.text);
				_nameField.textColor = [UIColor blackColor];
				_nameField.font = label.font;
				[view addSubview:_nameField];
				
				view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
				view.backgroundColor = [UIColor whiteColor];
				[self.view addSubview:view];
				[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
				label = [[UILabel alloc]initWithFrame:label.frame];
				label.text = @"联系电话";
				label.textColor = COLOR333;
				label.font = FONT(13);
				label.backgroundColor = [UIColor clearColor];
				[view addSubview:label];
				_mobileField = [[SpecialTextField alloc]initWithFrame:_nameField.frame];
				_mobileField.text = _data[@"mobileValue"];
				_mobileField.placeholder = STRINGFORMAT(@"请填写%@", label.text);
				_mobileField.textColor = [UIColor blackColor];
				_mobileField.font = label.font;
				_mobileField.keyboardType = UIKeyboardTypePhonePad;
				[view addSubview:_mobileField];
				
				view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
				view.backgroundColor = [UIColor whiteColor];
				[self.view addSubview:view];
			}
			
			_areaPicker = [[AreaPickerView alloc]init];
			if (_data[@"provinceValue"]) _province = _data[@"provinceValue"];
			if (_data[@"cityValue"]) _city = _data[@"cityValue"];
			if (_data[@"districtValue"]) _district = _data[@"districtValue"];
			_areaPicker.province = _province;
			_areaPicker.city = _city;
			_areaPicker.district = _district;
			_areaPicker.delegate = self;
			if (!_province.length) _areaPicker.autoLocation = YES;
			
			CGRect frame = _areaPicker.picker.frame;
			frame.origin.y = 0;
			_areaPicker.picker.frame = frame;
			[view addSubview:_areaPicker.picker];
			view.height = _areaPicker.picker.height;
			[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
			/*
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 75, view.height)];
			label.text = @"所在地区";
			label.textColor = COLOR333;
			label.font = FONT(13);
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			_areaLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right, 0, view.width-label.right-15, view.height)];
			if (_province.length) {
				_areaLabel.text = [AreaPickerView comboWithProvince:_province city:_city district:_district];
				_areaLabel.textColor = COLOR333;
			} else {
				_areaLabel.text = @"请选择地区";
				_areaLabel.textColor = COLOR_PLACEHOLDER;
			}
			_areaLabel.font = label.font;
			_areaLabel.backgroundColor = [UIColor clearColor];
			[view addSubview:_areaLabel];
			[view click:^(UIView *view, UIGestureRecognizer *sender) {
				[_areaPicker show];
			}];
			*/
			
			view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
			view.backgroundColor = [UIColor whiteColor];
			[self.view addSubview:view];
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 75, view.height)];
			label.text = _data[@"placeholder"];
			label.textColor = COLOR333;
			label.font = FONT(13);
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			_textField = [[SpecialTextField alloc]initWithFrame:CGRectMake(label.right, 0, view.width-label.right-15, view.height)];
			_textField.text = _data[@"value"];
			_textField.placeholder = STRINGFORMAT(@"请填写%@", _data[@"placeholder"]);
			_textField.textColor = [UIColor blackColor];
			_textField.font = FONT(14);
			_textField.delegate = self;
			[view addSubview:_textField];
			break;
		}
		default:{
			_textField = [[SpecialTextField alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
			_textField.text = _data[@"value"];
			_textField.placeholder = STRINGFORMAT(@"请填写%@", _data[@"placeholder"]);
			_textField.textColor = [UIColor blackColor];
			_textField.font = FONT(14);
			_textField.backgroundColor = [UIColor whiteColor];
			_textField.delegate = self;
			[self.view addSubview:_textField];
			_textField.padding = UIEdgeInsetsMake(0, 15, 0, 15);
			break;
		}
	}
}

- (void)areaPickerView:(UIPickerView *)picker didSelectWithProvince:(NSString *)province city:(NSString *)city district:(NSString *)district combo:(NSString *)combo{
	_province = province;
	_city = city;
	_district = district;
	_areaLabel.text = [AreaPickerView comboWithProvince:_province city:_city district:_district];
	_areaLabel.textColor = COLOR333;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[self pass];
	return YES;
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)pass{
	[self backgroundTap];
	if (_nameField && !_nameField.text.length) {
		[ProgressHUD showError:@"请输入联系人"];
		return;
	}
	if (_mobileField && !_mobileField.text.length) {
		[ProgressHUD showError:@"请输入联系电话"];
		return;
	}
	if (_textField && !_textField.text.length) {
		[ProgressHUD showError:STRINGFORMAT(@"请输入%@", _data[@"placeholder"])];
		return;
	}
	if (_textView && !_textView.text.length) {
		[ProgressHUD showError:STRINGFORMAT(@"请输入%@", _data[@"placeholder"])];
		return;
	}
	if (_areaPicker && !_province.length) {
		[ProgressHUD showError:@"请选择地区"];
		return;
	}
	[ProgressHUD show:nil];
	NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	if (_nameField) {
		[postData setValue:_nameField.text forKey:_data[@"name"]];
		[data setValue:_nameField.text forKey:@"name"];
	}
	if (_mobileField) {
		[postData setValue:_mobileField.text forKey:_data[@"mobile"]];
		[data setValue:_mobileField.text forKey:@"mobile"];
	}
	if (_textField) {
		[postData setValue:_textField.text forKey:_data[@"field"]];
		[data setValue:_textField.text forKey:@"value"];
	}
	if (_textView) {
		[postData setValue:_textView.text forKey:_data[@"field"]];
		[data setValue:_textView.text forKey:@"value"];
	}
	if (_areaPicker) {
		[postData setValue:_province forKey:_data[@"province"]];
		[postData setValue:_city forKey:_data[@"city"]];
		[postData setValue:_district forKey:_data[@"district"]];
		[data setValue:_province forKey:@"province"];
		[data setValue:_city forKey:@"city"];
		[data setValue:_district forKey:@"district"];
	}
	[Common postApiWithParams:@{@"app":@"eshop", @"act":@"edit_info"} data:postData success:^(NSMutableDictionary *json) {
		if (_delegate && [_delegate respondsToSelector:@selector(GlobalExecuteWithCaller:data:)]) {
			[_delegate GlobalExecuteWithCaller:self data:data];
		}
		[self.navigationController popViewControllerAnimated:YES];
	} fail:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
