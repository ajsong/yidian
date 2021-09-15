//
//  SpecialTextField.m
//
//  Created by ajsong on 14/12/6.
//  Copyright (c) 2014 ajsong. All rights reserved.
//

#import "SpecialTextField.h"

@interface SpecialTextField ()<UITextFieldDelegate>{
	BOOL _numberPad;
	BOOL _secureTextEntry;
	id _beginEditingObserver;
	id _endEditingObserver;
}
@property (nonatomic, copy) NSString *string;
@end

@implementation SpecialTextField

- (void)setPlaceholderColor:(UIColor *)placeholderColor{
	_placeholderColor = placeholderColor;
	[self setValue:placeholderColor forKeyPath:@"_placeholderLabel.textColor"];
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont{
	_placeholderFont = placeholderFont;
	[self setValue:placeholderFont forKeyPath:@"_placeholderLabel.font"];
}

- (void)setPadding:(UIEdgeInsets)padding{
	_padding = padding;
	[self setNeedsDisplay];
}

//四位加一个空格
- (void)setCreditCard:(BOOL)creditCard{
	_creditCard = creditCard;
	self.keyboardType = UIKeyboardTypeNumberPad;
	self.text = [self.text stringByReplacingOccurrencesOfString:@" " withString:@""];
	if (!self.text.length || !creditCard) return;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			NSString *text = self.text;
			NSInteger size = (text.length / 4);
			NSMutableArray *arr = [[NSMutableArray alloc]init];
			for (int n=0; n<size; n++) {
				[arr addObject:[text substringWithRange:NSMakeRange(n*4, 4)]];
			}
			[arr addObject:[text substringWithRange:NSMakeRange(size*4, (text.length % 4))]];
			text = [arr componentsJoinedByString:@" "];
			self.text = text;
		});
	});
}

//根据设定的键盘类型来自动设置相关限制
- (void)setKeyboardType:(UIKeyboardType)keyboardType{
	[super setKeyboardType:keyboardType];
	if (keyboardType == UIKeyboardTypePhonePad) {
		[self setMaxLength:11];
	} else if (keyboardType == UIKeyboardTypeDecimalPad) {
		[self setDecimalNum:2]; //默认限制两位小数
	} else if (keyboardType == UIKeyboardTypeNumberPad) {
		_numberPad = YES;
		self.delegate = self;
	}
}

//限制字符长度
- (void)setMaxLength:(NSInteger)maxLength{
	_maxLength = maxLength;
	self.delegate = self;
	[self addTarget:self action:@selector(textFieldDidChangeForMaxLength:) forControlEvents:UIControlEventEditingChanged];
}

//小数位数限制
- (void)setDecimalNum:(NSInteger)decimalNum{
	_decimalNum = decimalNum;
	self.delegate = self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
	if (_creditCard) {
		if (!string.length) { //string为空即当前操作是删除字符
			if ((textField.text.length - 1) % 5 == 0) textField.text = [textField.text substringToIndex:textField.text.length-1];
			return YES;
		} else {
			NSString *text = textField.text;
			NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
			string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
			if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
				return NO;
			}
			text = [text stringByReplacingCharactersInRange:range withString:string];
			text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
			NSString *str = @"";
			while (text.length > 0) {
				NSString *subString = [text substringToIndex:MIN(text.length, 4)];
				str = [str stringByAppendingString:subString];
				if (subString.length == 4) str = [str stringByAppendingString:@" "];
				text = [text substringFromIndex:MIN(text.length, 4)];
			}
			str = [str stringByTrimmingCharactersInSet:[characterSet invertedSet]];
			textField.text = [str substringToIndex:str.length-1];
		}
	}
	if (_maxLength) {
		if (!string.length) return YES;
		NSInteger existedLength = textField.text.length;
		NSInteger selectedLength = range.length;
		NSInteger replaceLength = string.length;
		if (existedLength - selectedLength + replaceLength > _maxLength) {
			return NO;
		}
	}
	if (_decimalNum) {
		NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\\."];
		string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
		if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
			return NO;
		}
		BOOL isHaveDot = YES;
		if ([textField.text rangeOfString:@"."].location == NSNotFound) isHaveDot = NO;
		if (string.length) {
			unichar single = [string characterAtIndex:0]; //当前输入的字符
			if (single=='.') {
				if(!textField.text.length){ //首字符不能为小数点
					[textField.text stringByReplacingCharactersInRange:range withString:@""];
					return NO;
				}
				if (isHaveDot) { //text中已有小数点
					[textField.text stringByReplacingCharactersInRange:range withString:@""];
					return NO;
				}
				return YES;
			} else { //判断当前输入的字符与之前的小数点相隔的位数
				if (isHaveDot) {
					NSRange r = [textField.text rangeOfString:@"."];
					if ( (textField.text.length-r.location > _decimalNum) && (range.location > r.location) ){
						[textField.text stringByReplacingCharactersInRange:range withString:@""];
						return NO;
					}
				}
				return YES;
			}
		}
	}
	if (_numberPad) {
		NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
		string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
		if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
			return NO;
		}
	}
	return YES;
}
- (void)textFieldDidChangeForMaxLength:(UITextField *)textField{
	if (textField.text.length > _maxLength) textField.text = [textField.text substringToIndex:_maxLength];
}

- (CGRect)textRectForBounds:(CGRect)rect{
    return CGRectMake(rect.origin.x + _padding.left,
                      rect.origin.y + _padding.top,
                      rect.size.width - _padding.right,
                      rect.size.height - _padding.bottom);
}

- (CGRect)editingRectForBounds:(CGRect)rect{
    return [self textRectForBounds:rect];
}

- (void)drawRect:(CGRect)rect{
	[self textRectForBounds:rect];
	[super drawRect:rect];
}

- (void)setSecureTextEntry:(BOOL)secureTextEntry{
	_secureTextEntry = secureTextEntry;
	[self performSelector:@selector(setSecureTextEntry) withObject:nil afterDelay:0];
}

- (void)setSecureTextEntry{
	__weak SpecialTextField *_self = self;
	_beginEditingObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidBeginEditingNotification
																			  object:nil
																			   queue:nil
																		  usingBlock:^(NSNotification *note) {
																			  if (_self == note.object && _self.isSecureTextEntry) {
																				  if (_self.clearsOnBeginEditing) {
																					  _self.text = @"";
																				  } else {
																					  _self.text = _self.string;
																				  }
																			  }
																		  }];
	_endEditingObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidEndEditingNotification
																			object:nil
																			 queue:nil
																		usingBlock:^(NSNotification *note) {
																			if (_self == note.object) {
																				_self.string = _self.text;
																			}
																		}];
	BOOL isFirstResponder = self.isFirstResponder;
	[self resignFirstResponder];
	[super setSecureTextEntry:_secureTextEntry];
	if (isFirstResponder) {
		[self becomeFirstResponder];
	}
}

- (void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:_beginEditingObserver];
	[[NSNotificationCenter defaultCenter] removeObserver:_endEditingObserver];
}

@end