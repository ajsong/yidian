//
//  DrawView.m
//
//  Created by ajsong on 15/4/16.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DrawView.h"

@implementation DrawView

- (id)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

//线
- (void)drawLine:(CGRect)rect{
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	for (int i=0; i<_drawPoints.count; i++) {
		NSArray *points = _drawPoints[i];
		if (!_drawQuadCurve) {
			for (int j=0; j<points.count-1; j++) {
				[bezierPath moveToPoint:[points[j] CGPointValue]];
				[bezierPath addLineToPoint:[points[j+1] CGPointValue]];
			}
		} else {
			//贝塞尔曲线
			if (points.count<3) continue;
			CGPoint point = [points[1] CGPointValue];
			CGPoint lastPoint = [points[2] CGPointValue];
			if (points.count>3) {
				point = [points[2] CGPointValue];
				lastPoint = [points[3] CGPointValue];
			}
			[bezierPath moveToPoint:[points[0] CGPointValue]];
			[bezierPath addCurveToPoint:lastPoint controlPoint1:[points[1] CGPointValue] controlPoint2:point];
		}
	}
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = bezierPath.CGPath;
	shapeLayer.fillColor = [UIColor clearColor].CGColor;
	shapeLayer.strokeColor = _drawColor.CGColor;
	shapeLayer.lineWidth = _drawWidth>0 ? _drawWidth : 0.5;
	if (_drawDash.count) shapeLayer.lineDashPattern = _drawDash;
	shapeLayer.frame = rect;
	[self.layer addSublayer:shapeLayer];
	if (_drawAnimation>0) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
		animation.duration = _drawAnimation;
		animation.delegate = self;
		animation.fromValue = @0;
		animation.toValue = @1;
		[shapeLayer addAnimation:animation forKey:@"key"];
	}
}

//圆形
- (void)drawCircle:(CGRect)rect{
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	[bezierPath appendPath:[UIBezierPath bezierPathWithOvalInRect:rect]];
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = bezierPath.CGPath;
	shapeLayer.fillColor = [UIColor clearColor].CGColor;
	shapeLayer.strokeColor = _drawColor.CGColor;
	shapeLayer.lineWidth = _drawWidth>0 ? _drawWidth : 0.5;
	if (_drawDash.count) shapeLayer.lineDashPattern = _drawDash;
	shapeLayer.frame = rect;
	[self.layer addSublayer:shapeLayer];
	if (_drawAnimation>0) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
		animation.duration = _drawAnimation;
		animation.delegate = self;
		animation.fromValue = @0;
		animation.toValue = @1;
		[shapeLayer addAnimation:animation forKey:@"key"];
	}
}

//填充圆形
- (void)drawCircleFill:(CGRect)rect{
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	[bezierPath appendPath:[UIBezierPath bezierPathWithOvalInRect:rect]];
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = bezierPath.CGPath;
	shapeLayer.fillColor = _drawColor.CGColor;
	shapeLayer.frame = rect;
	[self.layer addSublayer:shapeLayer];
}

//矩形
- (void)drawSquare:(CGRect)rect{
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	[bezierPath appendPath:[UIBezierPath bezierPathWithRect:rect]];
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = bezierPath.CGPath;
	shapeLayer.fillColor = [UIColor clearColor].CGColor;
	shapeLayer.strokeColor = _drawColor.CGColor;
	shapeLayer.lineWidth = _drawWidth>0 ? _drawWidth : 0.5;
	if (_drawDash.count) shapeLayer.lineDashPattern = _drawDash;
	shapeLayer.frame = rect;
	[self.layer addSublayer:shapeLayer];
	if (_drawAnimation>0) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
		animation.duration = _drawAnimation;
		animation.delegate = self;
		animation.fromValue = @0;
		animation.toValue = @1;
		[shapeLayer addAnimation:animation forKey:@"key"];
	}
}

//填充矩形
- (void)drawSquareFill:(CGRect)rect{
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	[bezierPath appendPath:[UIBezierPath bezierPathWithRect:rect]];
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = bezierPath.CGPath;
	shapeLayer.fillColor = _drawColor.CGColor;
	shapeLayer.frame = rect;
	[self.layer addSublayer:shapeLayer];
}

//三角形
- (void)drawTriangle:(CGRect)rect{
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	[bezierPath moveToPoint:CGPointMake(rect.size.width/2, _drawWidth)];
	[bezierPath addLineToPoint:CGPointMake(rect.size.width-_drawWidth, rect.size.height-_drawWidth/2)];
	[bezierPath addLineToPoint:CGPointMake(_drawWidth, rect.size.height-_drawWidth/2)];
	[bezierPath closePath];
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = bezierPath.CGPath;
	shapeLayer.fillColor = [UIColor clearColor].CGColor;
	shapeLayer.strokeColor = _drawColor.CGColor;
	shapeLayer.lineWidth = _drawWidth>0 ? _drawWidth : 0.5;
	if (_drawDash.count) shapeLayer.lineDashPattern = _drawDash;
	shapeLayer.frame = rect;
	[self.layer addSublayer:shapeLayer];
	if (_drawAnimation>0) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
		animation.duration = _drawAnimation;
		animation.delegate = self;
		animation.fromValue = @0;
		animation.toValue = @1;
		[shapeLayer addAnimation:animation forKey:@"key"];
	}
}

//填充三角形
- (void)drawTriangleFill:(CGRect)rect{
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	[bezierPath moveToPoint:CGPointMake(rect.size.width/2, _drawWidth)];
	[bezierPath addLineToPoint:CGPointMake(rect.size.width-_drawWidth, rect.size.height-_drawWidth/2)];
	[bezierPath addLineToPoint:CGPointMake(_drawWidth, rect.size.height-_drawWidth/2)];
	[bezierPath closePath];
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = bezierPath.CGPath;
	shapeLayer.fillColor = _drawColor.CGColor;
	shapeLayer.frame = rect;
	[self.layer addSublayer:shapeLayer];
}

//菱形
- (void)drawDiamond:(CGRect)rect{
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	[bezierPath moveToPoint:CGPointMake(rect.size.width/2, _drawWidth)];
	[bezierPath addLineToPoint:CGPointMake(rect.size.width-_drawWidth, rect.size.height/2)];
	[bezierPath addLineToPoint:CGPointMake(rect.size.width/2, rect.size.height-_drawWidth)];
	[bezierPath addLineToPoint:CGPointMake(_drawWidth, rect.size.height/2)];
	[bezierPath closePath];
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = bezierPath.CGPath;
	shapeLayer.fillColor = [UIColor clearColor].CGColor;
	shapeLayer.strokeColor = _drawColor.CGColor;
	shapeLayer.lineWidth = _drawWidth>0 ? _drawWidth : 0.5;
	if (_drawDash.count) shapeLayer.lineDashPattern = _drawDash;
	shapeLayer.frame = rect;
	[self.layer addSublayer:shapeLayer];
	if (_drawAnimation>0) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
		animation.duration = _drawAnimation;
		animation.delegate = self;
		animation.fromValue = @0;
		animation.toValue = @1;
		[shapeLayer addAnimation:animation forKey:@"key"];
	}
}

//填充菱形
- (void)drawDiamondFill:(CGRect)rect{
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	[bezierPath moveToPoint:CGPointMake(rect.size.width/2, _drawWidth)];
	[bezierPath addLineToPoint:CGPointMake(rect.size.width-_drawWidth, rect.size.height/2)];
	[bezierPath addLineToPoint:CGPointMake(rect.size.width/2, rect.size.height-_drawWidth)];
	[bezierPath addLineToPoint:CGPointMake(_drawWidth, rect.size.height/2)];
	[bezierPath closePath];
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = bezierPath.CGPath;
	shapeLayer.fillColor = _drawColor.CGColor;
	shapeLayer.frame = rect;
	[self.layer addSublayer:shapeLayer];
}

//扇形
- (void)drawSector:(CGRect)rect{
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	//center圆心, radius半径, startAngle起始弧度, endAngle结束弧度, clockwise[YES为顺时针,NO为逆时针]
	[bezierPath moveToPoint:CGPointMake(rect.size.width/2, rect.size.height/2)];
	[bezierPath addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:rect.size.width/2 startAngle:M_PI+0.5 endAngle:2*M_PI-0.5 clockwise:YES];
	[bezierPath addLineToPoint:CGPointMake(rect.size.width/2, rect.size.height/2)];
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = bezierPath.CGPath;
	shapeLayer.fillColor = [UIColor clearColor].CGColor;
	shapeLayer.strokeColor = _drawColor.CGColor;
	shapeLayer.lineWidth = _drawWidth>0 ? _drawWidth : 0.5;
	if (_drawDash.count) shapeLayer.lineDashPattern = _drawDash;
	shapeLayer.frame = rect;
	[self.layer addSublayer:shapeLayer];
	if (_drawAnimation>0) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
		animation.duration = _drawAnimation;
		animation.delegate = self;
		animation.fromValue = @0;
		animation.toValue = @1;
		[shapeLayer addAnimation:animation forKey:@"key"];
	}
}

//填充扇形
- (void)drawSectorFill:(CGRect)rect{
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	[bezierPath moveToPoint:CGPointMake(rect.size.width/2, rect.size.height/2)];
	[bezierPath addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:rect.size.width/2 startAngle:M_PI+0.5 endAngle:2*M_PI-0.5 clockwise:YES];
	[bezierPath addLineToPoint:CGPointMake(rect.size.width/2, rect.size.height/2)];
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = bezierPath.CGPath;
	shapeLayer.fillColor = _drawColor.CGColor;
	shapeLayer.frame = rect;
	[self.layer addSublayer:shapeLayer];
}

//不规则图形
- (void)drawSpecial:(CGRect)rect{
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	for (int i=0; i<_drawPoints.count; i++) {
		NSArray *points = _drawPoints[i];
		for (int j=0; j<points.count-1; j++) {
			[bezierPath moveToPoint:[points[j] CGPointValue]];
			[bezierPath addLineToPoint:[points[j+1] CGPointValue]];
		}
	}
	[bezierPath closePath];
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = bezierPath.CGPath;
	shapeLayer.fillColor = [UIColor clearColor].CGColor;
	shapeLayer.strokeColor = _drawColor.CGColor;
	shapeLayer.lineWidth = _drawWidth>0 ? _drawWidth : 0.5;
	if (_drawDash.count) shapeLayer.lineDashPattern = _drawDash;
	shapeLayer.frame = rect;
	[self.layer addSublayer:shapeLayer];
	if (_drawAnimation>0) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
		animation.duration = _drawAnimation;
		animation.delegate = self;
		animation.fromValue = @0;
		animation.toValue = @1;
		[shapeLayer addAnimation:animation forKey:@"key"];
	}
}

//填充不规则图形
- (void)drawSpecialFill:(CGRect)rect{
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	for (int i=0; i<_drawPoints.count; i++) {
		NSArray *points = _drawPoints[i];
		for (int j=0; j<points.count-1; j++) {
			[bezierPath moveToPoint:[points[j] CGPointValue]];
			[bezierPath addLineToPoint:[points[j+1] CGPointValue]];
		}
	}
	[bezierPath closePath];
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = bezierPath.CGPath;
	shapeLayer.fillColor = _drawColor.CGColor;
	shapeLayer.frame = rect;
	[self.layer addSublayer:shapeLayer];
}

//绘制图片
- (void)drawImage:(CGRect)rect{
	//[_drawImage drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)]; //在坐标中画出图片
	[_drawImage drawAtPoint:CGPointMake(0, 0)];//保持图片大小在point点开始画图片
}

//绘制倒影图片
- (void)drawImageShadow:(CGRect)rect{
	CGContextRef context = UIGraphicsGetCurrentContext();
	[_drawImageShadow drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)];
	CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), _drawImageShadow.CGImage);
}

//绘制字符
- (void)drawFont:(CGRect)rect{
	//NSStrokeWidthAttributeName: 负数填充,正数中空
	NSDictionary *attributes = @{ NSFontAttributeName:_drawFont, NSForegroundColorAttributeName:_drawColor, NSStrokeWidthAttributeName:@(_drawWidth) };
	[_drawString drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height) withAttributes:attributes];
}

- (void)drawRect:(CGRect)rect{
	rect = CGRectMake(0, 0, rect.size.width, rect.size.height);
	if (_drawPoints.count>0) {
		if (_drawType == DrawViewTypeSpecial) {
			if (_drawWidth>0 || _drawDash.count>0) {
				[self drawSpecial:rect];
			} else {
				[self drawSpecialFill:rect];
			}
		} else {
			[self drawLine:rect];
		}
		return;
	}
	if (_drawImage) {
		[self drawImage:rect];
		return;
	}
	if (_drawImageShadow) {
		[self drawImageShadow:rect];
		return;
	}
	if (_drawString) {
		[self drawFont:rect];
		return;
	}
	switch (_drawType) {
		case DrawViewTypeCircle:{
			if (_drawWidth>0 || _drawDash.count>0) {
				[self drawCircle:rect];
			} else {
				[self drawCircleFill:rect];
			}
			break;
		}
		case DrawViewTypeSquare:{
			if (_drawWidth>0 || _drawDash.count>0) {
				[self drawSquare:rect];
			} else {
				[self drawSquareFill:rect];
			}
			break;
		}
		case DrawViewTypeTriangle:{
			if (_drawWidth>0 || _drawDash.count>0) {
				[self drawTriangle:rect];
			} else {
				[self drawTriangleFill:rect];
			}
			break;
		}
		case DrawViewTypeDiamond:{
			if (_drawWidth>0 || _drawDash.count>0) {
				[self drawDiamond:rect];
			} else {
				[self drawDiamondFill:rect];
			}
			break;
		}
		case DrawViewTypeSector:{
			if (_drawWidth>0 || _drawDash.count>0) {
				[self drawSector:rect];
			} else {
				[self drawSectorFill:rect];
			}
			break;
		}
		default:{
			break;
		}
	}
}

@end
