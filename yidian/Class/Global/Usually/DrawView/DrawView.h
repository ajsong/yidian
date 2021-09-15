//
//  DrawView.h
//
//  Created by ajsong on 15/4/16.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger {
	DrawViewTypeCircle = 0, //圆形
	DrawViewTypeSquare, //矩形
	DrawViewTypeTriangle, //三角形
	DrawViewTypeDiamond, //菱形
	DrawViewTypeSector, //扇形
	DrawViewTypeSpecial, //不规则图形
} DrawViewType;

@interface DrawView : UIView
@property(nonatomic,assign)DrawViewType drawType; //绘制类型
@property(nonatomic,retain)UIColor *drawColor; //绘制颜色
@property(nonatomic,assign)CGFloat drawWidth; //边框宽度(设定后即为线框图)
@property(nonatomic,retain)NSArray *drawDash; //虚线(元素为虚实间距)(设定后即为线框图)
@property(nonatomic,retain)NSArray *drawPoints; //坐标点数组(二维数组,每个大元素代表一条线)(例如直线两个点)(把CGPoint转NSValue后存储)
@property(nonatomic,assign)BOOL drawQuadCurve; //画线时是否为贝塞尔曲线(drawPoints的小元素必须最少3个,最多4个) @[开始点, 控制点[, 控制点], 结束点]
@property(nonatomic,assign)NSTimeInterval drawAnimation; //使用动画
@property(nonatomic,retain)UIImage *drawImage; //绘制图片
@property(nonatomic,retain)UIImage *drawImageShadow; //绘制倒影图片
@property(nonatomic,retain)NSString *drawString; //绘制字符
@property(nonatomic,retain)UIFont *drawFont; //绘制字符的字体
@end
