//
// Copyright (c) 2013 Related Code - http://relatedcode.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ProgressHUD.h"

@implementation hudBar
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor]; //设置为背景透明,可以在这里设置背景图片
        self.clearsContextBeforeDrawing = YES;
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
	
}
@end

@implementation ProgressHUD

+ (ProgressHUD*)shared {
	static dispatch_once_t once = 0;
	static ProgressHUD *progressHUD;
	dispatch_once(&once, ^{ progressHUD = [[ProgressHUD alloc] init]; });
	return progressHUD;
}

+ (void)show:(NSString*)status {
	[[self shared] hudMake:status imgage:nil imageSize:CGSizeMake(28, 28) spin:YES hide:NO];
}

+ (void)dismiss {
	[ProgressHUD dismiss:0.3];
}

+ (void)dismiss:(NSTimeInterval)delay {
	[[self shared] removeAllAutoHidePlaceholderSubviews];
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			[[self shared] hudHide];
		});
	});
}

+ (void)show:(NSString*)status image:(UIImage*)img imageSize:(CGSize)size {
	[[self shared] hudMake:status imgage:img imageSize:size spin:NO hide:YES];
}

+ (void)showSuccess:(NSString*)status {
	[[self shared] hudMake:status imgage:[UIImage imageNamed:@"success-white"] imageSize:CGSizeMake(28, 28) spin:NO hide:YES];
}

+ (void)showError:(NSString*)status {
	[[self shared] hudMake:status imgage:[UIImage imageNamed:@"error-white"] imageSize:CGSizeMake(28, 28) spin:NO hide:YES];
}

+ (void)showTrouble:(NSString*)status {
	[[self shared] hudMake:status imgage:[UIImage imageNamed:@"trouble-white"] imageSize:CGSizeMake(28, 28) spin:NO hide:YES];
}

+ (void)showWarning:(NSString*)status {
	[[self shared] hudMake:status imgage:[UIImage imageNamed:@"warning-white"] imageSize:CGSizeMake(28, 28) spin:NO hide:YES];
}

+ (BOOL)isShow{
	return [[self shared] isShow];
}

- (id)init {
	self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
	id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate respondsToSelector:@selector(window)])
		_window = [delegate performSelector:@selector(window)];
	else _window = [[UIApplication sharedApplication] keyWindow];
    _hud = nil;
    _hudColor = [UIColor colorWithWhite:0 alpha:0.6];
    _spinner = nil;
    _spinnerColor = [UIColor whiteColor];
    _image = nil;
    _label = nil;
    _textColor = [UIColor whiteColor];
	_textFont = [UIFont boldSystemFontOfSize:16];
	_autoHidePlaceholder = [[UIView alloc]init];
	self.alpha = 0;
	return self;
}

- (void)hudMake:(NSString*)status imgage:(UIImage*)img imageSize:(CGSize)size spin:(BOOL)spin hide:(BOOL)hide {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self hudCreate:size];
		_label.text = status;
		_label.hidden = (status==nil || status.length<=0) ? YES : NO;
		_image.image = img;
		_image.hidden = (img==nil) ? YES : NO;
		if (spin) [_spinner startAnimating]; else [_spinner stopAnimating];
		//[self hudOrient];
		[self hudSize];
		[self hudShow];
		if (hide) {
			[_autoHidePlaceholder addSubview:[[UIView alloc]init]];
			[NSThread detachNewThreadSelector:@selector(timedHide) toTarget:self withObject:nil];
		}
	});
}

- (void)hudCreate:(CGSize)size {
	if (_hud == nil) {
		_hud = [[hudBar alloc] initWithFrame:CGRectZero];
        _hud.backgroundColor = _hudColor;
        _hud.alpha = 1;
		_hud.layer.cornerRadius = 10;
		_hud.layer.masksToBounds = YES;
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
	}
	if (_hud.superview == nil) [_window addSubview:_hud];
	if (_spinner == nil) {
		_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_spinner.color = _spinnerColor;
		_spinner.hidesWhenStopped = YES;
	}
	if (_spinner.superview == nil) [_hud addSubview:_spinner];
	if (_image != nil) [_image removeFromSuperview];
    _image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
	if (_image.superview == nil) [_hud addSubview:_image];
	if (_label == nil) {
		_label = [[UILabel alloc] initWithFrame:CGRectZero];
		_label.font = _textFont;
		_label.textColor = _textColor;
		_label.backgroundColor = [UIColor clearColor];
		_label.textAlignment = NSTextAlignmentCenter;
		_label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		_label.numberOfLines = 0;
	}
	if (_label.superview == nil) [_hud addSubview:_label];
}

- (void)hudDestroy {
	//[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[_label removeFromSuperview]; _label = nil;
	[_image removeFromSuperview]; _image = nil;
	[_spinner removeFromSuperview]; _spinner = nil;
	[_hud removeFromSuperview]; _hud = nil;
}

- (void)rotate:(NSNotification*)notification {
	//[self hudOrient];
}

- (BOOL)isShow{
	return self.alpha == 1;
}

- (void)removeAllAutoHidePlaceholderSubviews{
	for (UIView *subview in _autoHidePlaceholder.subviews) {
		[subview removeFromSuperview];
	}
}

- (void)hudOrient {
	CGFloat rotate = 0.0;
	UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
	if (orient == UIInterfaceOrientationPortrait)			rotate = 0.0;
	if (orient == UIInterfaceOrientationPortraitUpsideDown)	rotate = M_PI;
	if (orient == UIInterfaceOrientationLandscapeLeft)		rotate = - M_PI_2;
	if (orient == UIInterfaceOrientationLandscapeRight)		rotate = + M_PI_2;
	_hud.transform = CGAffineTransformMakeRotation(rotate);
}

- (void)hudSize {
	CGRect labelRect = CGRectZero;
	CGFloat hudWidth = 100, hudHeight = 100;
	if (_label.text != nil) {
		NSDictionary *attributes = @{NSFontAttributeName:_label.font};
		NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
		labelRect = [_label.text boundingRectWithSize:CGSizeMake(200, 300) options:options attributes:attributes context:NULL];
		labelRect.origin.x = 12;
		labelRect.origin.y = 66;
		hudWidth = labelRect.size.width + 24;
        if (_image != nil) {
            if (hudWidth < 22 + _image.frame.size.width + 22) {
                hudWidth = 22 + _image.frame.size.width + 22;
                labelRect.origin.x = 0;
                labelRect.size.width = hudWidth;
            }
            hudHeight = 22 + _image.frame.size.height + 22 + labelRect.size.height + 8;
            labelRect.origin.y = 22 + _image.frame.size.height + 15;
        }else{
            hudHeight = labelRect.size.height + 80;
        }
		if (hudWidth < 100) {
			hudWidth = 100;
			labelRect.origin.x = 0;
			labelRect.size.width = hudWidth;
		}
	}
	CGSize screen = [UIScreen mainScreen].bounds.size;
	_hud.center = CGPointMake(screen.width/2, screen.height/2);
	_hud.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
    CGRect frame = _image.frame;
    frame.origin.x = (hudWidth-frame.size.width)/2;
    frame.origin.y = (_label.text==nil) ? (hudHeight-frame.size.height)/2 : 22;
    _image.frame = frame;
    _spinner.center = _image.center;
	_label.frame = labelRect;
}

- (void)hudShow {
	if (self.alpha == 0) {
		self.alpha = 1;
		_hud.alpha = 0;
		_hud.transform = CGAffineTransformScale(_hud.transform, 1.4, 1.4);
		NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut;
		[UIView animateWithDuration:0.15 delay:0 options:options animations:^{
			_hud.transform = CGAffineTransformScale(_hud.transform, 1/1.4, 1/1.4);
			_hud.alpha = 1;
		} completion:nil];
	}
}

- (void)hudHide {
	if (_autoHidePlaceholder.subviews.count>0) return;
	if (self.alpha == 1) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn;
			[UIView animateWithDuration:0.15 delay:0 options:options animations:^{
				_hud.transform = CGAffineTransformScale(_hud.transform, 0.7, 0.7);
				_hud.alpha = 0.5;
			} completion:^(BOOL finished){
				[self hudDestroy];
				self.alpha = 0;
			}];
		});
	}
}

- (void)timedHide {
	@autoreleasepool{
		double length = _label.text.length;
		NSTimeInterval sleep = length * 0.2 + 0.5;
		[NSThread sleepForTimeInterval:sleep];
		[self removeAllAutoHidePlaceholderSubviews];
		[self hudHide];
	}
}

@end
