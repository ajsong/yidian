//
//  SpecialLabel.m
//
//  Created by ajsong on 14/12/6.
//  Copyright (c) 2014 ajsong. All rights reserved.
//

#import "Global.h"
#import <CoreText/CoreText.h>

@interface SpecialLabel (){
	BOOL _isPadding;
	BOOL _isVertical;
}
@end

@implementation SpecialLabel

- (void)setPadding:(UIEdgeInsets)padding{
	_padding = padding;
	_isPadding = YES;
	self.element[@"padding"] = NSStringFromUIEdgeInsets(padding);
	[self setNeedsDisplay];
}

- (void)setLineHeight:(CGFloat)lineHeight{
	_lineHeight = lineHeight;
	self.numberOfLines = 0;
	CGFloat width = self.frame.size.width;
	NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc]initWithString:self.text];
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
	[style setLineSpacing:_lineHeight];
	[attributed addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, self.text.length)];
	self.attributedText = attributed;
	[self sizeToFit];
	CGRect frame = self.frame;
	frame.size.width = width;
	self.frame = frame;
	[self setNeedsDisplay];
}

- (void)setVerticalAlignment:(VerticalAlignment)verticalAlignment{
	_verticalAlignment = verticalAlignment;
	_isVertical = YES;
	[self setNeedsDisplay];
}

- (void)setAttributed:(NSDictionary *)attributed{
	self.attributedText = [self.text attributedStyle:attributed];
}

- (void)setGradientColors:(NSArray *)gradientColors{
	_gradientColors = gradientColors;
	[self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines{
	CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
	switch (_verticalAlignment) {
		case VerticalAlignmentTop:
			textRect.origin.y = bounds.origin.y;
			break;
		case VerticalAlignmentBottom:
			textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
			break;
		case VerticalAlignmentMiddle:
			// Fall through.
		default:
			textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
	}
	return textRect;
}

- (void)drawRect:(CGRect)rect{
	if (_gradientColors && _gradientColors.count) {
		NSMutableArray *gradientColors = [[NSMutableArray alloc]init];
		for (NSInteger i=_gradientColors.count-1; i>=0; i--) {
			[gradientColors addObject:_gradientColors[i]];
		}
		CGContextRef context = UIGraphicsGetCurrentContext();
		NSMutableArray *colors = [[NSMutableArray alloc]init];
		[gradientColors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([obj isKindOfClass:[UIColor class]]) {
				[colors addObject:(__bridge id)[obj CGColor]];
			} else if (CFGetTypeID((__bridge void *)obj) == CGColorGetTypeID()) {
				[colors addObject:obj];
			} else {
				@throw [NSException exceptionWithName:@"CRGradientLabelError"
											   reason:@"Object in gradientColors array is not a UIColor or CGColorRef"
											 userInfo:NULL];
			}
		}];
		CGContextSaveGState(context);
		CGContextScaleCTM(context, 1.0, -1.0);
		CGContextTranslateCTM(context, 0, -rect.size.height);
		CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, NULL);
		CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
		CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
		CGContextDrawLinearGradient(context, gradient, startPoint, endPoint,
									kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation);
		CGGradientRelease(gradient);
		CGContextRestoreGState(context);
	}
	[super drawRect:rect];
}

- (void)drawTextInRect:(CGRect)rect{
	//CGContextClearRect(UIGraphicsGetCurrentContext(), rect);
	if (_isVertical) rect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
	if (_isPadding) rect = UIEdgeInsetsInsetRect(rect, _padding);
	[super drawTextInRect:rect];
	if (_lineType != LineTypeNone) {
		CGSize textSize = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
		CGFloat strikeWidth = textSize.width;
		CGRect lineRect;
		CGFloat originX = 0.0;
		CGFloat originY = 0.0;
		if (self.textAlignment == NSTextAlignmentRight) {
			originX = rect.size.width - strikeWidth;
		} else if (self.textAlignment == NSTextAlignmentCenter) {
			originX = (rect.size.width - strikeWidth)/2 ;
		} else {
			originX = 0;
		}
		if (_lineType == LineTypeTop) originY = 2;
		if (_lineType == LineTypeMiddle) originY = rect.size.height/2;
		if (_lineType == LineTypeBottom) originY = rect.size.height - 2;
		lineRect = CGRectMake(originX , originY, strikeWidth, _lineWidth>0 ? _lineWidth : 0.5);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGFloat R, G, B, A;
		UIColor *lineColor = _lineColor ? _lineColor : self.textColor;
        CGColorRef color = lineColor.CGColor;
        int numComponents = (int)CGColorGetNumberOfComponents(color);
        if (numComponents == 4) {
            const CGFloat *components = CGColorGetComponents(color);
            R = components[0];
            G = components[1];
            B = components[2];
            //A = components[3];
            CGContextSetRGBFillColor(context, R, G, B, 1.0);
        }
        CGContextFillRect(context, lineRect);
    }
}

//点击AttributedStyleAction
- (void)setAttributedStyleAction:(BOOL)attributedStyleAction{
	if (attributedStyleAction) {
		__block id _self = self;
		[self setTapAttributedStyleAction:^(CGPoint point) {
			NSDictionary *attributes = [_self textAttributesAtPoint:point];
			AttributedStyleAction *styleAction = attributes[@"AttributedStyleAction"];
			if (styleAction) styleAction.action();
		}];
	} else {
		[self setTapAttributedStyleAction:nil];
	}
}
- (void)setTapAttributedStyleAction:(void (^)(CGPoint))tapAttributedStyleAction{
	_tapAttributedStyleAction = tapAttributedStyleAction;
	if (tapAttributedStyleAction == nil) {
		if (self.gestureRecognizers.count) [self removeGestureRecognizer:self.gestureRecognizers[0]];
		return;
	}
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAttributedStyle:)];
	[self addGestureRecognizer:recognizer];
	self.userInteractionEnabled = YES;
}
- (void)tapAttributedStyle:(UITapGestureRecognizer*)recognizer{
	if (recognizer.state == UIGestureRecognizerStateRecognized) {
		CGPoint point = [recognizer locationInView:self];
		if (_tapAttributedStyleAction) _tapAttributedStyleAction(point);
	}
}
- (NSDictionary*)textAttributesAtPoint:(CGPoint)pt{
	NSDictionary *dictionary = nil;
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
	CGMutablePathRef framePath = CGPathCreateMutable();
	CGPathAddRect(framePath, NULL, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
	CFRange currentRange = CFRangeMake(0, 0);
	CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
	CGPathRelease(framePath);
	NSArray *lines = (__bridge id)CTFrameGetLines(frameRef);
	CFIndex linesCount = [lines count];
	CGPoint *lineOrigins = (CGPoint *) malloc(sizeof(CGPoint) * linesCount);
	CTFrameGetLineOrigins(frameRef, CFRangeMake(0, linesCount), lineOrigins);
	CTLineRef line = NULL;
	CGPoint lineOrigin = CGPointZero;
	CGFloat bottom = self.frame.size.height;
	for(CFIndex i=0; i<linesCount; i++) {
		lineOrigins[i].y = self.frame.size.height - lineOrigins[i].y;
		bottom = lineOrigins[i].y;
	}
	pt.y -= (self.frame.size.height - bottom)/2;
	for(CFIndex i=0; i<linesCount; i++) {
		line = (__bridge CTLineRef)[lines objectAtIndex:i];
		lineOrigin = lineOrigins[i];
		CGFloat descent, ascent;
		CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, nil);
		if (pt.y < (floor(lineOrigin.y) + floor(descent))) {
			if (self.textAlignment == NSTextAlignmentCenter) {
				pt.x -= (self.frame.size.width - width)/2;
			} else if (self.textAlignment == NSTextAlignmentRight) {
				pt.x -= (self.frame.size.width - width);
			}
			pt.x -= lineOrigin.x;
			pt.y -= lineOrigin.y;
			CFIndex i = CTLineGetStringIndexForPosition(line, pt);
			NSArray* glyphRuns = (__bridge id)CTLineGetGlyphRuns(line);
			CFIndex runCount = [glyphRuns count];
			for (CFIndex run=0; run<runCount; run++) {
				CTRunRef glyphRun = (__bridge CTRunRef)[glyphRuns objectAtIndex:run];
				CFRange range = CTRunGetStringRange(glyphRun);
				if (i >= range.location && i<= range.location+range.length) {
					dictionary = (__bridge NSDictionary*)CTRunGetAttributes(glyphRun);
					break;
				}
			}
			if (dictionary) break;
		}
	}
	free(lineOrigins);
	CFRelease(frameRef);
	CFRelease(framesetter);
	return dictionary;
}

@end
