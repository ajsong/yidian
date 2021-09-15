//
//  SpecialTextField.h
//
//  Created by ajsong on 14/12/6.
//  Copyright (c) 2014 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpecialTextField : UITextField

@property (nonatomic,retain) UIColor *placeholderColor;
@property (nonatomic,retain) UIFont *placeholderFont;

@property (nonatomic,assign) UIEdgeInsets padding;

@property (nonatomic,assign) BOOL creditCard; //四位加一个空格

@property (nonatomic,assign) NSInteger maxLength; //限制字符长度

@property (nonatomic,assign) NSInteger decimalNum; //小数位数限制

@end