//
//  SpecialTextView.m
//
//  Created by ajsong on 14/12/6.
//  Copyright (c) 2014 ajsong. All rights reserved.
//

#import "SpecialTextView.h"

//插入图片用
@interface IIAttachment : NSTextAttachment
@property(strong, nonatomic) NSString *imageTag;
@end
@implementation IIAttachment
@end
@interface NSAttributedString (InsetImage)
- (NSString*)code;
@end
@implementation NSAttributedString (InsetImage)
- (NSString*)code{
	NSMutableString *plainString = [NSMutableString stringWithString:self.string];
	__block NSUInteger base = 0;
	[self enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
		if (value && [value isKindOfClass:[IIAttachment class]]) {
			[plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length) withString:((IIAttachment*)value).imageTag];
			base += ((IIAttachment*)value).imageTag.length - 1;
		}
	}];
	return plainString;
}
@end


@interface SpecialTextView()<UITextViewDelegate>{
	UILabel *_placeholderLabel;
	BOOL _isPadding;
}
@end

@implementation SpecialTextView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self awakeFromNib];
	}
	return self;
}

- (void)awakeFromNib {
	self.textContainerInset = UIEdgeInsetsMake(0, -5, 0, 0);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeValue:) name:UITextViewTextDidChangeNotification object:self];
	_placeholderLabel = [[UILabel alloc]init];
	_placeholderLabel.textColor = [UIColor colorWithRed:199/255.f green:199/255.f blue:199/255.f alpha:1.f];
	_placeholderLabel.numberOfLines = 0;
	[self addSubview:_placeholderLabel];
	[self performSelector:@selector(setPlaceholderLabel) withObject:nil afterDelay:0.1];
}

- (void)setPlaceholderLabel{
	_placeholderLabel.font = _placeholderFont ? _placeholderFont : (self.font ? self.font : [UIFont systemFontOfSize:12.f]);
	UIEdgeInsets edgeInsets = self.textContainerInset;
	if (edgeInsets.left<=0) edgeInsets.left = 5;
	CGRect frame = _placeholderLabel.frame;
	frame.origin.x = edgeInsets.left;
	_placeholderLabel.frame = frame;
	if (self.text.length) _placeholderLabel.hidden = YES;
	if (_placeholderLabel.text.length>0) [self setPlaceholder:_placeholderLabel.text];
}

- (void)setPlaceholder:(NSString *)placeholder{
	_placeholder = placeholder;
	if (!placeholder.length) {
		_placeholderLabel.hidden = YES;
	} else {
		_placeholderLabel.text = placeholder;
	}
	UIEdgeInsets edgeInsets = self.textContainerInset;
	NSDictionary *attributes = @{NSFontAttributeName:_placeholderLabel.font};
	NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
	CGRect rect = [placeholder boundingRectWithSize:CGSizeMake(self.frame.size.width-edgeInsets.left-5-edgeInsets.right, MAXFLOAT) options:options attributes:attributes context:NULL];
	CGRect frame = CGRectMake(edgeInsets.left+5, edgeInsets.top, rect.size.width, rect.size.height);
	_placeholderLabel.frame = frame;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor{
	_placeholderColor = placeholderColor;
	_placeholderLabel.textColor = placeholderColor;
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont{
	_placeholderFont = placeholderFont;
	_placeholderLabel.font = placeholderFont;
}

- (void)setPlaceholderHidden:(BOOL)placeholderHidden{
	_placeholderHidden = placeholderHidden;
	_placeholderLabel.hidden = placeholderHidden;
}

- (void)placeholderCheckText{
	if (!_placeholder) return;
	NSString *text = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (text.length) {
		_placeholderLabel.hidden = YES;
	} else {
		_placeholderLabel.hidden = NO;
	}
}

- (void)didChangeValue:(NSNotification*)noti{
	if (!_placeholder.length) {
		_placeholderLabel.hidden = YES;
	} else {
		if (self.text.length) {
			_placeholderLabel.hidden = YES;
		} else {
			_placeholderLabel.hidden = NO;
		}
		_placeholderHidden = _placeholderLabel.hidden;
	}
}

- (void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_placeholderLabel removeFromSuperview];
}

- (void)setPadding:(UIEdgeInsets)padding{
	_padding = padding;
	_isPadding = YES;
	self.textContainerInset = padding;
	[self setNeedsDisplay];
	[self performSelector:@selector(setPlaceholderLabel) withObject:nil afterDelay:0.1];
}

- (void)setLineHeight:(CGFloat)lineHeight{
	_lineHeight = lineHeight;
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
	style.lineSpacing = lineHeight;
	NSDictionary *attributes = @{ NSFontAttributeName:self.font, NSParagraphStyleAttributeName:style };
	self.attributedText = [[NSAttributedString alloc]initWithString:self.text attributes:attributes];
}

- (void)drawRect:(CGRect)rect{
	if (_isPadding) self.textContainerInset = _padding;
	[super drawRect:rect];
}

- (void)setTextFont:(UIFont *)textFont{
	_textFont = textFont;
	self.font = textFont;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines{
	CGRect frame = self.frame;
	_numberOfLines = numberOfLines;
	_minHeight = frame.size.height;
	_maxHeight = self.font.lineHeight * numberOfLines;
	UIEdgeInsets textContainerInset = self.textContainerInset;
	textContainerInset.top = (frame.size.height - self.font.lineHeight) / 2;
	textContainerInset.bottom = textContainerInset.top;
	self.padding = textContainerInset;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeText:) name:UITextViewTextDidChangeNotification object:self];
}
//textView参数为空即不调用delegate
- (void)textViewDidChangeText:(UITextView*)textView{
	if (_placeholder) {
		[self placeholderCheckText];
	}
	if (_numberOfLines) {
		CGRect frame = self.frame;
		NSDictionary *attributes = @{NSFontAttributeName:self.font};
		NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
		CGRect rect = [self.text boundingRectWithSize:CGSizeMake(frame.size.width, MAXFLOAT) options:options attributes:attributes context:NULL];
		if (rect.size.height <= _minHeight - self.textContainerInset.top - self.textContainerInset.bottom) {
			frame.size.height = _minHeight;
		} else {
			if (rect.size.height < _maxHeight) {
				frame.size.height = rect.size.height + self.textContainerInset.top + self.textContainerInset.bottom;
			} else {
				frame.size.height = _maxHeight + self.textContainerInset.top + self.textContainerInset.bottom;
			}
		}
		self.frame = frame;
		self.contentOffset = CGPointMake(0, self.contentSize.height-frame.size.height);
		if (textView && _autoHeightDelegate && [_autoHeightDelegate respondsToSelector:@selector(SpecialTextViewChangeHeight:currentHeight:)]) {
			[_autoHeightDelegate SpecialTextViewChangeHeight:self currentHeight:frame.size.height];
		}
	}
}

//插入图片, image:图片, imageMark:图片标识
- (void)insertImage:(UIImage*)image imageMark:(NSString*)imageMark{
	[self insertImage:image imageMark:imageMark imageWidth:0 imageHeight:0];
}
- (void)insertImage:(UIImage*)image imageMark:(NSString*)imageMark imageWidth:(CGFloat)width imageHeight:(CGFloat)height{
	if (width>0 || height>0) image = [self imageChangeSize:image size:CGSizeMake(width, height)];
	if (!_textFont) _textFont = self.font;
	CGSize s = [self.text sizeWithAttributes:@{NSFontAttributeName:_textFont}];
	IIAttachment *attachment = [[IIAttachment alloc]init];
	attachment.imageTag = imageMark;
	attachment.image = image;
	attachment.bounds = CGRectMake(0, (s.height-image.size.height)/2-(_textFont.lineHeight*0.1), image.size.width, image.size.height);
	//Insert image
	//[self.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:attachment] atIndex:self.selectedRange.location];
	//Replace image
	[self.textStorage replaceCharactersInRange:self.selectedRange withAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
	self.selectedRange = NSMakeRange(self.selectedRange.location+1, 0);
	NSRange range = NSMakeRange(0, self.textStorage.length);
	[self.textStorage removeAttribute:NSFontAttributeName range:range];
	[self.textStorage addAttribute:NSFontAttributeName value:_textFont range:range];
}
- (UIImage*)imageChangeSize:(UIImage*)image size:(CGSize)size{
	if (image==nil) return nil;
	UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

//获取文字,包括图片标识
- (NSString*)code{
	return [self.textStorage code];
}

@end
