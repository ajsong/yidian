//
//  AJCheckbox.h
//
//  Created by ajsong on 15/6/10.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

/*
AJCheckbox *cb = [[AJCheckbox alloc]init];
cb.delegate = self;
cb.orderType = CheckboxOrderTypeRight;
cb.type = CheckboxTypeCheckbox;
cb.image = IMG(@"c-tick");
cb.selectedImage = IMG(@"c-tick-x");
cb.font = FONT(14);
cb.size = CGSizeMake(25, 25);
cb.textWidth = SCREEN_WIDTH - 25 - 24;
cb.textHeight = 54;
*/

#import <Foundation/Foundation.h>

#define CHECKBOX_TAG 2987462

@class AJCheckbox;

typedef enum : NSInteger {
	CheckboxTypeRadio = 0,
	CheckboxTypeCheckbox,
} CheckboxType;

typedef enum : NSInteger {
	CheckboxOrderTypeLeft = 0,
	CheckboxOrderTypeRight,
} CheckboxOrderType;

typedef enum : NSInteger {
	CheckboxStatusUnselect = 0,
	CheckboxStatusSelect,
	CheckboxStatusAuto,
} CheckboxStatus;

@protocol AJCheckboxDelegate<NSObject>
@optional
- (void)AJCheckbox:(AJCheckbox*)checkbox didSelectObject:(UIView*)view withStatus:(CheckboxStatus)status atIndex:(NSInteger)index;
- (void)AJCheckbox:(AJCheckbox*)checkbox selectedTexts:(NSMutableArray*)texts selectedIndexs:(NSMutableArray*)indexs;
@end

@interface AJCheckbox : NSObject
@property (nonatomic,retain) id<AJCheckboxDelegate> delegate;
@property (nonatomic,retain) NSMutableArray *objects; //数据,子元素为字符串
@property (nonatomic,retain) NSMutableArray *views; //选项框组
@property (nonatomic,retain) NSMutableArray *selectedTexts; //已被选中的选项框的标签
@property (nonatomic,retain) NSMutableArray *selectedIndexs; //已被选中的选项框的索引
@property (nonatomic,assign) CheckboxType type; //选项框类型
@property (nonatomic,assign) CheckboxOrderType orderType; //选项框位置
@property (nonatomic,assign) CGSize size; //选项框尺寸
@property (nonatomic,retain) UIImage *image; //选项框默认图
@property (nonatomic,retain) UIImage *selectedImage; //选项框选中图
@property (nonatomic,retain) UIColor *textColor; //标签颜色
@property (nonatomic,assign) CGFloat textWidth; //标签宽度,不设定即自动宽度
@property (nonatomic,assign) CGFloat textHeight; //标签高度,不设定即按选项框尺寸的高度
@property (nonatomic,retain) UIFont *font; //标签字体
@property (nonatomic,assign) NSInteger tag;

- (id)initWithObjects:(NSArray*)objects type:(CheckboxType)type size:(CGSize)size image:(UIImage*)image selectedImage:(UIImage*)selectedImage font:(UIFont*)font;
- (UIView*)addObject:(NSString*)object;
- (UIView*)addObject:(NSString*)object selected:(BOOL)selected;
- (void)removeObjectWithText:(NSString*)text;
- (void)selectObjectAtIndex:(NSInteger)index;
- (void)selectObjectWithText:(NSString*)text;
- (void)selectObjectAtIndexNoDelegate:(NSInteger)index;
- (void)selectObjectWithTextNoDelegate:(NSString*)text;
- (BOOL)isSelectedIndex:(NSInteger)index;
- (BOOL)isSelectedWithText:(NSString*)text;
- (void)selectAllObject;
- (void)unselectAllObject;
@end

