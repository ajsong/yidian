//
//  AJActionView.m
//
//  Created by ajsong on 15/9/14.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "AJActionView.h"

#define SCREEN [UIScreen mainScreen].bounds

@implementation AJActionView{
	UIView *_overlay;
}

- (id)initWithTitle:(NSString*)title view:(UIView*)view delegate:(id<AJActionViewDelegate>)delegate{
	self = [super init];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		UIWindow *window = [UIApplication sharedApplication].keyWindow;
		_view = view;
		_delegate = delegate;
		
		_overlay = [[UIView alloc]initWithFrame:SCREEN];
		_overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
		_overlay.userInteractionEnabled = YES;
		_overlay.alpha = 0;
		[window addSubview:_overlay];
		
		UIButton *dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		dismissBtn.frame = _overlay.bounds;
		dismissBtn.backgroundColor = [UIColor clearColor];
		[dismissBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
		[_overlay addSubview:dismissBtn];
		
		_mainView = [[UIView alloc]initWithFrame:CGRectMake(8, 0, SCREEN.size.width-8-8, 0)];
		_mainView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
		_mainView.clipsToBounds = YES;
		_mainView.layer.masksToBounds = YES;
		_mainView.layer.cornerRadius = 5;
		[self addSubview:_mainView];
		
		CGRect frame = _view.frame;
		if (title.length) {
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _mainView.frame.size.width, 30)];
			label.text = title;
			label.textColor = [UIColor colorWithRed:153/255.f green:153/255.f blue:153/255.f alpha:1.f];
			label.textAlignment = NSTextAlignmentCenter;
			label.font = [UIFont systemFontOfSize:12];
			label.backgroundColor = [UIColor clearColor];
			[_mainView addSubview:label];
			
			frame.origin.y += label.frame.size.height;
			_view.frame = frame;
		}
		
		frame.origin.x = (_mainView.frame.size.width - frame.size.width) / 2;
		_view.frame = frame;
		[_mainView addSubview:_view];
		
		CGFloat top = _view.frame.origin.y + _view.frame.size.height;
		UIView *ge = [[UIView alloc]initWithFrame:CGRectMake(0, top-0.5, _mainView.frame.size.width, 0.5)];
		ge.backgroundColor = [UIColor colorWithWhite:0.756 alpha:1.000];
		[_mainView addSubview:ge];
		
		if (_buttons && _buttons.count) {
			for (int i=0; i<_buttons.count; i++) {
				UIColor *color;
				if (_buttonColors && _buttonColors.count && i<=_buttonColors.count-1) {
					color = _buttonColors[i];
				} else {
					color = [UIColor colorWithRed:0.f/255 green:122.f/255 blue:255.f/255 alpha:1];
				}
				UIButton *submit = [UIButton buttonWithType:UIButtonTypeCustom];
				submit.frame = CGRectMake(0, top, _mainView.frame.size.width, 44);
				submit.titleLabel.font = [UIFont systemFontOfSize:22];
				submit.backgroundColor = [UIColor clearColor];
				[submit setTitle:_buttons[i] forState:UIControlStateNormal];
				[submit setTitleColor:color forState:UIControlStateNormal];
				[submit addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
				submit.tag = i + 50;
				[_mainView addSubview:submit];
				top += submit.frame.size.height;
			}
		} else {
			UIButton *submit = [UIButton buttonWithType:UIButtonTypeCustom];
			submit.frame = CGRectMake(0, top, _mainView.frame.size.width, 44);
			submit.titleLabel.font = [UIFont systemFontOfSize:22];
			submit.backgroundColor = [UIColor clearColor];
			[submit setTitle:@"确定" forState:UIControlStateNormal];
			[submit setTitleColor:[UIColor colorWithRed:0.f/255 green:122.f/255 blue:255.f/255 alpha:1] forState:UIControlStateNormal];
			[submit addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
			[_mainView addSubview:submit];
			top += submit.frame.size.height;
		}
		
		_mainView.frame = CGRectMake(_mainView.frame.origin.x, 0, _mainView.frame.size.width, top);
		
		UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
		cancel.frame = CGRectMake(_mainView.frame.origin.x, _mainView.frame.size.height+8, _mainView.frame.size.width, 44);
		cancel.titleLabel.font = [UIFont boldSystemFontOfSize:22];
		cancel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
		[cancel setTitle:@"取消" forState:UIControlStateNormal];
		[cancel setTitleColor:[UIColor colorWithRed:0.f/255 green:122.f/255 blue:255.f/255 alpha:1] forState:UIControlStateNormal];
		[cancel addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
		cancel.layer.masksToBounds = YES;
		cancel.layer.cornerRadius = 5;
		[self addSubview:cancel];
		
		self.frame = CGRectMake(0, SCREEN.size.height, SCREEN.size.width, cancel.frame.origin.y+cancel.frame.size.height+8);
		[window addSubview:self];
	}
	return self;
}

- (UIViewController*)currentController{
	UIWindow *window = (UIWindow*)[[UIApplication sharedApplication].windows objectAtIndex:0];
	return window.rootViewController;
}

- (void)show{
	UIViewController *controller = [self currentController];
	[controller.view endEditing:YES];
	[UIView animateWithDuration:0.3 animations:^{
		if (_scale) controller.view.transform = CGAffineTransformMakeScale(_scale, _scale);
		_overlay.alpha = 1;
		self.frame = CGRectMake(0, SCREEN.size.height-self.frame.size.height, SCREEN.size.width, self.frame.size.height);
		if (_delegate && [_delegate respondsToSelector:@selector(AJActionViewWillShow:)]) {
			[_delegate AJActionViewWillShow:self];
		}
	}];
}

- (void)close{
	UIViewController *controller = [self currentController];
	[UIView animateWithDuration:0.3 animations:^{
		if (_scale) controller.view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
		_overlay.alpha = 0;
		self.frame = CGRectMake(0, SCREEN.size.height, SCREEN.size.width, self.frame.size.height);
	} completion:^(BOOL finished) {
		if (_delegate && [_delegate respondsToSelector:@selector(AJActionViewDidClose:)]) {
			[_delegate AJActionViewDidClose:self];
		}
	}];
}

- (void)submit{
	if (_delegate && [_delegate respondsToSelector:@selector(AJActionViewDidSubmit:)]) {
		[_delegate AJActionViewDidSubmit:self];
	}
	[self close];
}

- (void)clickedButton:(UIButton*)sender{
	if (_delegate && [_delegate respondsToSelector:@selector(AJActionView:clickedButtonAtIndex:)]) {
		NSInteger tag = sender.tag - 50;
		[_delegate AJActionView:self clickedButtonAtIndex:tag];
	}
	[self close];
}

@end
