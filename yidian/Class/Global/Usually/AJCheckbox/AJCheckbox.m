//
//  AJCheckbox.m
//
//  Created by ajsong on 15/6/10.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "AJCheckbox.h"
#import <objc/runtime.h>

@interface UIView (AJCheckbox)
- (void)viewClick:(void(^)(UIView *view))block;
@end
@implementation UIView (AJCheckbox)
- (void)viewClick:(void(^)(UIView *view))block{
	if (!block) return;
	objc_setAssociatedObject(self, @"block", block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	self.userInteractionEnabled = YES;
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onViewClick:)];
	[self addGestureRecognizer:tap];
}
- (void)onViewClick:(UIGestureRecognizer*)sender{
	void(^block)(UIView *view) = objc_getAssociatedObject(self, @"block");
	block(sender.view);
}
@end


@implementation AJCheckbox

- (id)init{
	self = [super init];
	if (self) {
		[self setup];
	}
	return self;
}

- (id)initWithObjects:(NSArray*)objects type:(CheckboxType)type size:(CGSize)size image:(UIImage*)image selectedImage:(UIImage*)selectedImage font:(UIFont*)font{
	self = [super init];
	if (self) {
		[self setup];
		_type = type;
		_size = size;
		_image = image;
		_selectedImage = selectedImage;
		_font = font;
		[self performSelector:@selector(delayAddObject:) withObject:objects afterDelay:0];
	}
	return self;
}

- (void)setup{
	_views = [[NSMutableArray alloc]init];
	_objects = [[NSMutableArray alloc]init];
	_selectedTexts = [[NSMutableArray alloc]init];
	_selectedIndexs = [[NSMutableArray alloc]init];
	_size = CGSizeMake(25.f, 25.f);
	_textColor = [UIColor blackColor];
	_font = [UIFont systemFontOfSize:13.f];
}

- (void)delayAddObject:(NSArray*)objects{
	for (int i=0; i<objects.count; i++) {
		[self addObject:objects[i]];
	}
}

- (UIView*)addObject:(NSString*)object{
	return [self addObject:object selected:NO];
}

- (UIView*)addObject:(NSString*)object selected:(BOOL)selected{
	if (!_textHeight) _textHeight = _size.height;
	CGSize s = CGSizeMake(_textWidth, _textHeight);
	if (_textWidth<=0) {
		NSDictionary *attributes = @{NSFontAttributeName:_font};
		NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
		CGRect rect = [object boundingRectWithSize:CGSizeMake(MAXFLOAT, _size.height) options:options attributes:attributes context:NULL];
		s = CGSizeMake(rect.size.width, _size.height);
	}
	
	UIView *boxView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _size.width + 3 + s.width, _textHeight)];
	boxView.userInteractionEnabled = YES;
	[boxView viewClick:^(UIView *view) {
		[self changeView:view];
	}];
	
	CGFloat boxX = 0;
	CGFloat labelX = _size.width + 3;
	if (_orderType == CheckboxOrderTypeRight) {
		boxX = boxView.frame.size.width - _size.width;
		labelX = 0;
	}
	
	UIImageView *box = [[UIImageView alloc]initWithFrame:CGRectMake(boxX, (boxView.frame.size.height-_size.height)/2, _size.width, _size.height)];
	box.image = selected ? _selectedImage : _image;
	box.tag = CHECKBOX_TAG;
	[boxView addSubview:box];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(labelX, 0, s.width, boxView.frame.size.height)];
	label.text = object;
	label.textColor = _textColor;
	label.font = _font;
	label.backgroundColor = [UIColor clearColor];
	label.tag = CHECKBOX_TAG + 1;
	[boxView addSubview:label];
	
	[_views addObject:boxView];
	[_objects addObject:object];
	if (selected) {
		[_selectedTexts addObject:object];
		[_selectedIndexs addObject:@(_objects.count-1)];
		if (_delegate && [_delegate respondsToSelector:@selector(AJCheckbox:selectedTexts:selectedIndexs:)]) {
			[_delegate AJCheckbox:self selectedTexts:_selectedTexts selectedIndexs:_selectedIndexs];
		}
	}
	
	return boxView;
}

- (void)removeObjectWithText:(NSString*)text{
	for (int i=0; i<_views.count; i++) {
		UIView *boxView = _views[i];
		UILabel *label = (UILabel*)[boxView viewWithTag:CHECKBOX_TAG+1];
		if ([label.text isEqualToString:text]) {
			[_views removeObjectAtIndex:i];
			[_objects removeObjectAtIndex:i];
			NSUInteger index = [_selectedTexts indexOfObject:text];
			if (index != NSNotFound) {
				[_selectedTexts removeObjectAtIndex:index];
				[_selectedIndexs removeObjectAtIndex:index];
			}
			[boxView removeFromSuperview];
			break;
		}
	}
}

- (void)selectObjectAtIndex:(NSInteger)index{
	if (index>=_views.count || index<0) return;
	UIView *boxView = _views[index];
	[self changeView:boxView];
}

- (void)selectObjectWithText:(NSString *)text{
	if (!text.length) return;
	NSUInteger index = [_objects indexOfObject:text];
	if (index == NSNotFound) return;
	UIView *boxView = _views[index];
	[self changeView:boxView];
}

- (void)selectObjectAtIndexNoDelegate:(NSInteger)index{
	if (index>=_views.count || index<0) return;
	UIView *boxView = _views[index];
	[self changeView:boxView status:CheckboxStatusAuto useDidSelectObjectDelegate:NO];
}

- (void)selectObjectWithTextNoDelegate:(NSString *)text{
	if (!text.length) return;
	NSUInteger index = [_objects indexOfObject:text];
	if (index == NSNotFound) return;
	UIView *boxView = _views[index];
	[self changeView:boxView status:CheckboxStatusAuto useDidSelectObjectDelegate:NO];
}

- (BOOL)isSelectedIndex:(NSInteger)index{
	if (index>=0 && index<_objects.count) {
		return [_selectedIndexs containsObject:@(index)];
	}
	return NO;
}

- (BOOL)isSelectedWithText:(NSString *)text{
	if (text.length) {
		return [_selectedTexts containsObject:text];
	}
	return NO;
}

- (void)animateImage:(UIImageView*)box{
	[box.layer removeAllAnimations];
	CAKeyframeAnimation *scaoleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	scaoleAnimation.duration = 0.25;
	scaoleAnimation.values = @[@1.0, @1.2, @1.0];
	scaoleAnimation.fillMode = kCAFillModeForwards;
	[box.layer addAnimation:scaoleAnimation forKey:@"transform.rotate"];
}

- (void)selectAllObject{
	if (_type == CheckboxTypeRadio) return;
	[_selectedTexts removeAllObjects];
	[_selectedIndexs removeAllObjects];
	for (int i=0; i<_objects.count; i++) {
		[_selectedTexts addObject:_objects[i]];
		[_selectedIndexs addObject:@(i)];
	}
	for (int i=0; i<_views.count; i++) {
		UIView *boxView = _views[i];
		UIImageView *box = (UIImageView*)[boxView viewWithTag:CHECKBOX_TAG];
		box.image = _selectedImage;
		[self animateImage:box];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJCheckbox:selectedTexts:selectedIndexs:)]) {
		[_delegate AJCheckbox:self selectedTexts:_selectedTexts selectedIndexs:_selectedIndexs];
	}
}

- (void)unselectAllObject{
	[_selectedTexts removeAllObjects];
	[_selectedIndexs removeAllObjects];
	for (int i=0; i<_views.count; i++) {
		UIView *boxView = _views[i];
		UIImageView *box = (UIImageView*)[boxView viewWithTag:CHECKBOX_TAG];
		box.image = _image;
		[self animateImage:box];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJCheckbox:selectedTexts:selectedIndexs:)]) {
		[_delegate AJCheckbox:self selectedTexts:_selectedTexts selectedIndexs:_selectedIndexs];
	}
}

- (void)changeView:(UIView*)view{
	[self changeView:view status:CheckboxStatusAuto useDidSelectObjectDelegate:YES];
}

- (void)changeView:(UIView*)view status:(CheckboxStatus)status useDidSelectObjectDelegate:(BOOL)flag{
	NSUInteger index = NSNotFound;
	if (_type == CheckboxTypeRadio) {
		[_selectedTexts removeAllObjects];
		[_selectedIndexs removeAllObjects];
		for (int i=0; i<_views.count; i++) {
			UIView *boxView = _views[i];
			UIImageView *box = (UIImageView*)[boxView viewWithTag:CHECKBOX_TAG];
			box.image = _image;
			if ([boxView isEqual:view]) index = i;
		}
		UIImageView *box = (UIImageView*)[view viewWithTag:CHECKBOX_TAG];
		box.image = _selectedImage;
		[self animateImage:box];
		UILabel *label = (UILabel*)[view viewWithTag:CHECKBOX_TAG+1];
		[_selectedTexts addObject:label.text];
		[_selectedIndexs addObject:@([_objects indexOfObject:label.text])];
		status = CheckboxStatusSelect;
	} else if (_type == CheckboxTypeCheckbox) {
		for (int i=0; i<_views.count; i++) {
			UIView *boxView = _views[i];
			if ([boxView isEqual:view]) index = i;
		}
		UIImageView *box = (UIImageView*)[view viewWithTag:CHECKBOX_TAG];
		if (status == CheckboxStatusAuto) {
			if ([box.image isEqual:_image]) {
				box.image = _selectedImage;
				status = CheckboxStatusSelect;
			} else {
				box.image = _image;
				status = CheckboxStatusUnselect;
			}
		} else if (status == CheckboxStatusSelect) {
			box.image = _selectedImage;
		} else if (status == CheckboxStatusUnselect) {
			box.image = _image;
		}
		[self animateImage:box];
		UILabel *label = (UILabel*)[view viewWithTag:CHECKBOX_TAG+1];
		if (status == CheckboxStatusSelect) {
			[_selectedTexts addObject:label.text];
			[_selectedIndexs addObject:@([_objects indexOfObject:label.text])];
		} else {
			NSUInteger i = [_selectedTexts indexOfObject:label.text];
			if (i != NSNotFound) {
				[_selectedTexts removeObjectAtIndex:i];
				[_selectedIndexs removeObjectAtIndex:i];
			}
		}
	}
	if (index != NSNotFound && flag && _delegate && [_delegate respondsToSelector:@selector(AJCheckbox:didSelectObject:withStatus:atIndex:)]) {
		[_delegate AJCheckbox:self didSelectObject:view withStatus:status atIndex:index];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJCheckbox:selectedTexts:selectedIndexs:)]) {
		[_delegate AJCheckbox:self selectedTexts:_selectedTexts selectedIndexs:_selectedIndexs];
	}
}

@end
