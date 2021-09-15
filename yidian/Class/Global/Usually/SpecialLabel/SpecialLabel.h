//
//  SpecialLabel.h
//
//  Created by ajsong on 14/12/6.
//  Copyright (c) 2014 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    LineTypeNone, //没有画线
    LineTypeTop, //上边画线
    LineTypeMiddle, //中间画线
    LineTypeBottom, //下边画线
} LineType;

typedef enum{
	VerticalAlignmentMiddle = 0, //default
	VerticalAlignmentTop,
	VerticalAlignmentBottom,
} VerticalAlignment;

@interface SpecialLabel : UILabel

@property (nonatomic,assign) LineType lineType; //画线类型
@property (nonatomic,retain) UIColor *lineColor; //画线颜色
@property (nonatomic,assign) CGFloat lineWidth; //画线厚度

@property (nonatomic,assign) UIEdgeInsets padding; //填充空间

/*!
 @brief 行高
 */
@property (nonatomic,assign) IBInspectable CGFloat lineHeight; //行高

@property (nonatomic,assign) VerticalAlignment verticalAlignment; //垂直位置

@property (nonatomic,retain) NSDictionary *attributed; //样式设置

@property (nonatomic,retain) NSArray *gradientColors; //背景色渐变数组

@property (nonatomic,assign) BOOL attributedStyleAction;
@property (nonatomic,readwrite,copy) void(^tapAttributedStyleAction)(CGPoint);

@end
