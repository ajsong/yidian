/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "EaseChatBarMoreView.h"
#import "EaseSDKHelper.h"

#define CHAT_BUTTON_SIZE 50
#define INSETS 10
#define MOREVIEW_COL 4
#define MOREVIEW_ROW 2
#define MOREVIEW_BUTTON_TAG 1000

@implementation UIView (MoreView)

- (void)removeAllSubview
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

@end

@interface EaseChatBarMoreView ()<UIScrollViewDelegate>
{
	EMChatToolbarType _type;
	NSInteger _maxIndex;
	NSInteger _index;
}

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *takePicButton;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UIButton *audioCallButton;
@property (nonatomic, strong) UIButton *videoCallButton;

@end

@implementation EaseChatBarMoreView

+ (void)initialize
{
    // UIAppearance Proxy Defaults
    EaseChatBarMoreView *moreView = [self appearance];
    moreView.moreViewBackgroundColor = [UIColor whiteColor];
}

- (instancetype)initWithFrame:(CGRect)frame type:(EMChatToolbarType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _type = type;
		[self setupSubviewsForType:_type];
    }
    return self;
}

- (void)setupSubviewsForType:(EMChatToolbarType)type
{
    //self.backgroundColor = [UIColor clearColor];
	_maxIndex = -1;
    
    _scrollview = [[UIScrollView alloc] init];
    _scrollview.pagingEnabled = YES;
    _scrollview.showsHorizontalScrollIndicator = NO;
    _scrollview.showsVerticalScrollIndicator = NO;
    _scrollview.delegate = self;
    [self addSubview:_scrollview];
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = 1;
    [self addSubview:_pageControl];
	
	NSInteger index = 0;
	CGFloat insets = (self.frame.size.width - 4 * CHAT_BUTTON_SIZE) / 5;
	
	_photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_photoButton setFrame:CGRectMake(insets * (index+1) + CHAT_BUTTON_SIZE * index, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
	[_photoButton setImage:IMGEASE(@"chatBar_colorMore_photo") forState:UIControlStateNormal];
	[_photoButton setImage:IMGEASE(@"chatBar_colorMore_photoSelected") forState:UIControlStateHighlighted];
	[_photoButton addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
	_photoButton.tag = MOREVIEW_BUTTON_TAG + index;
	[_scrollview addSubview:_photoButton];
	index++;
	_maxIndex++;
	
	_takePicButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_takePicButton setFrame:CGRectMake(insets * (index+1) + CHAT_BUTTON_SIZE * index, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
	[_takePicButton setImage:IMGEASE(@"chatBar_colorMore_camera") forState:UIControlStateNormal];
	[_takePicButton setImage:IMGEASE(@"chatBar_colorMore_cameraSelected") forState:UIControlStateHighlighted];
	[_takePicButton addTarget:self action:@selector(takePicAction) forControlEvents:UIControlEventTouchUpInside];
	_takePicButton.tag = MOREVIEW_BUTTON_TAG + index;
	[_scrollview addSubview:_takePicButton];
	index++;
	_maxIndex++;
	
	_locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_locationButton setFrame:CGRectMake(insets * (index+1) + CHAT_BUTTON_SIZE * index, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
	[_locationButton setImage:IMGEASE(@"chatBar_colorMore_location") forState:UIControlStateNormal];
	[_locationButton setImage:IMGEASE(@"chatBar_colorMore_locationSelected") forState:UIControlStateHighlighted];
	[_locationButton addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];
	_locationButton.tag = MOREVIEW_BUTTON_TAG + index;
	[_scrollview addSubview:_locationButton];
	index++;
	_maxIndex++;

    CGRect frame = self.frame;
    if (type == EMChatToolbarTypeChat) {
		frame.size.height = 150;
		_audioCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_audioCallButton setFrame:CGRectMake(insets * (index+1) + CHAT_BUTTON_SIZE * index, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
		[_audioCallButton setImage:IMGEASE(@"chatBar_colorMore_audioCall") forState:UIControlStateNormal];
		[_audioCallButton setImage:IMGEASE(@"chatBar_colorMore_audioCallSelected") forState:UIControlStateHighlighted];
		[_audioCallButton addTarget:self action:@selector(takeAudioCallAction) forControlEvents:UIControlEventTouchUpInside];
		_audioCallButton.tag = MOREVIEW_BUTTON_TAG + index;
		[_scrollview addSubview:_audioCallButton];
		index++;
		_maxIndex++;
		
		CGFloat x = insets * (index+1) + CHAT_BUTTON_SIZE * index;
		CGFloat y = 10;
		if (index && !fmod(index, 4)) {
			x = insets;
			y = 10 * 2 + CHAT_BUTTON_SIZE + 10;
		}
		_videoCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_videoCallButton setFrame:CGRectMake(x, y, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
		[_videoCallButton setImage:IMGEASE(@"chatBar_colorMore_videoCall") forState:UIControlStateNormal];
		[_videoCallButton setImage:IMGEASE(@"chatBar_colorMore_videoCallSelected") forState:UIControlStateHighlighted];
		[_videoCallButton addTarget:self action:@selector(takeVideoCallAction) forControlEvents:UIControlEventTouchUpInside];
		_videoCallButton.tag = MOREVIEW_BUTTON_TAG + index;
		[_scrollview addSubview:_videoCallButton];
		index++;
		_maxIndex++;
    }
    else if (type == EMChatToolbarTypeGroup)
    {
        frame.size.height = 80;
    }
    self.frame = frame;
    _scrollview.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
    _pageControl.frame = CGRectMake(0, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame), 20);
    _pageControl.hidden = _pageControl.numberOfPages<=1;
	
	_index = index;
	
	[self performSelector:@selector(resetButtonsPosition) withObject:nil afterDelay:0];
}

- (void)setShowMoreViewPhotoBtn:(BOOL)showMoreViewPhotoBtn{
	_photoButton.hidden = !showMoreViewPhotoBtn;
}
- (void)setShowMoreViewTakePicBtn:(BOOL)showMoreViewTakePicBtn{
	_takePicButton.hidden = !showMoreViewTakePicBtn;
}
- (void)setShowMoreViewLocationBtn:(BOOL)showMoreViewLocationBtn{
	_locationButton.hidden = !showMoreViewLocationBtn;
}
- (void)setShowMoreViewAudioCallBtn:(BOOL)showMoreViewAudioCallBtn{
	_audioCallButton.hidden = !showMoreViewAudioCallBtn;
}
- (void)setShowMoreViewVideoCallBtn:(BOOL)showMoreViewVideoCallBtn{
	_videoCallButton.hidden = !showMoreViewVideoCallBtn;
}
- (void)setMoreViewOtherBtnImage:(UIImage *)moreViewOtherBtnImage{
	UIButton *otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[otherButton setFrame:CGRectMake(0, 0, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
	[otherButton setImage:moreViewOtherBtnImage forState:UIControlStateNormal];
	[otherButton addTarget:self action:@selector(otherAction) forControlEvents:UIControlEventTouchUpInside];
	otherButton.tag = MOREVIEW_BUTTON_TAG + _index;
	[_scrollview addSubview:otherButton];
	_index++;
	_maxIndex++;
}

- (void)resetButtonsPosition{
	NSInteger index = 0;
	CGFloat insets = (self.frame.size.width - 4 * CHAT_BUTTON_SIZE) / 5;
	
	CGFloat y = 0;
	for (UIView *subview in _scrollview.subviews) {
		if ([subview isKindOfClass:[UIButton class]] && !subview.hidden) {
			CGFloat x = insets * (index+1) + CHAT_BUTTON_SIZE * index;
			if (index && !fmod(index, 4)) {
				x = insets;
				y += 10 + CHAT_BUTTON_SIZE;
				index = 0;
			}
			CGRect frame = subview.frame;
			frame.origin.x = x;
			frame.origin.y = y + 10;
			subview.frame = frame;
			index++;
		}
	}
}

- (void)insertItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highLightedImage title:(NSString *)title
{
    CGFloat insets = (self.frame.size.width - MOREVIEW_COL * CHAT_BUTTON_SIZE) / 5;
    CGRect frame = self.frame;
    _maxIndex++;
    NSInteger pageSize = MOREVIEW_COL*MOREVIEW_ROW;
    NSInteger page = _maxIndex/pageSize;
    NSInteger row = (_maxIndex%pageSize)/MOREVIEW_COL;
    NSInteger col = _maxIndex%MOREVIEW_COL;
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setFrame:CGRectMake(page * CGRectGetWidth(self.frame) + insets * (col + 1) + CHAT_BUTTON_SIZE * col, INSETS + INSETS * 2 * row + CHAT_BUTTON_SIZE * row, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [moreButton setImage:image forState:UIControlStateNormal];
    [moreButton setImage:highLightedImage forState:UIControlStateHighlighted];
    [moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.tag = MOREVIEW_BUTTON_TAG+_maxIndex;
    [_scrollview addSubview:moreButton];
    [_scrollview setContentSize:CGSizeMake(CGRectGetWidth(self.frame) * (page + 1), CGRectGetHeight(self.frame))];
    [_pageControl setNumberOfPages:page + 1];
    if (_maxIndex >=5) {
        frame.size.height = 150;
        _scrollview.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        _pageControl.frame = CGRectMake(0, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame), 20);
    }
    self.frame = frame;
    _pageControl.hidden = _pageControl.numberOfPages<=1;
}

- (void)updateItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highLightedImage title:(NSString *)title atIndex:(NSInteger)index
{
    UIView *moreButton = [_scrollview viewWithTag:MOREVIEW_BUTTON_TAG+index];
    if (moreButton && [moreButton isKindOfClass:[UIButton class]]) {
        [(UIButton*)moreButton setImage:image forState:UIControlStateNormal];
        [(UIButton*)moreButton setImage:highLightedImage forState:UIControlStateHighlighted];
    }
}

- (void)removeItematIndex:(NSInteger)index
{
    UIView *moreButton = [_scrollview viewWithTag:MOREVIEW_BUTTON_TAG+index];
    if (moreButton && [moreButton isKindOfClass:[UIButton class]]) {
        [self _resetItemFromIndex:index];
        [moreButton removeFromSuperview];
    }
}

#pragma mark - private

- (void)_resetItemFromIndex:(NSInteger)index
{
    CGFloat insets = (self.frame.size.width - MOREVIEW_COL * CHAT_BUTTON_SIZE) / 5;
    CGRect frame = self.frame;
    for (NSInteger i = index + 1; i<_maxIndex + 1; i++) {
        UIView *moreButton = [_scrollview viewWithTag:MOREVIEW_BUTTON_TAG+i];
        if (moreButton && [moreButton isKindOfClass:[UIButton class]]) {
            NSInteger moveToIndex = i - 1;
            NSInteger pageSize = MOREVIEW_COL*MOREVIEW_ROW;
            NSInteger page = moveToIndex/pageSize;
            NSInteger row = (moveToIndex%pageSize)/MOREVIEW_COL;
            NSInteger col = moveToIndex%MOREVIEW_COL;
            [moreButton setFrame:CGRectMake(page * CGRectGetWidth(self.frame) + insets * (col + 1) + CHAT_BUTTON_SIZE * col, INSETS + INSETS * 2 * row + CHAT_BUTTON_SIZE * row, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
            moreButton.tag = MOREVIEW_BUTTON_TAG+moveToIndex;
            [_scrollview setContentSize:CGSizeMake(CGRectGetWidth(self.frame) * (page + 1), CGRectGetHeight(self.frame))];
            [_pageControl setNumberOfPages:page + 1];
        }
    }
    _maxIndex--;
    if (_maxIndex >=5) {
        frame.size.height = 150;
    } else {
        frame.size.height = 80;
    }
    self.frame = frame;
    _scrollview.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
    _pageControl.frame = CGRectMake(0, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame), 20);
    _pageControl.hidden = _pageControl.numberOfPages<=1;
}

#pragma setter
//- (void)setMoreViewColumn:(NSInteger)moreViewColumn
//{
//    if (_moreViewColumn != moreViewColumn) {
//        _moreViewColumn = moreViewColumn;
//        [self setupSubviewsForType:_type];
//    }
//}
//
//- (void)setMoreViewNumber:(NSInteger)moreViewNumber
//{
//    if (_moreViewNumber != moreViewNumber) {
//        _moreViewNumber = moreViewNumber;
//        [self setupSubviewsForType:_type];
//    }
//}

- (void)setMoreViewBackgroundColor:(UIColor *)moreViewBackgroundColor
{
    _moreViewBackgroundColor = moreViewBackgroundColor;
    if (_moreViewBackgroundColor) {
        [self setBackgroundColor:_moreViewBackgroundColor];
    }
}

/*
- (void)setMoreViewButtonImages:(NSArray *)moreViewButtonImages
{
    _moreViewButtonImages = moreViewButtonImages;
    if ([_moreViewButtonImages count] > 0) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if (button.tag < [_moreViewButtonImages count]) {
                    NSString *imageName = [_moreViewButtonImages objectAtIndex:button.tag];
                    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
                }
            }
        }
    }
}

- (void)setMoreViewButtonHignlightImages:(NSArray *)moreViewButtonHignlightImages
{
    _moreViewButtonHignlightImages = moreViewButtonHignlightImages;
    if ([_moreViewButtonHignlightImages count] > 0) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if (button.tag < [_moreViewButtonHignlightImages count]) {
                    NSString *imageName = [_moreViewButtonHignlightImages objectAtIndex:button.tag];
                    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
                }
            }
        }
    }
}*/

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset =  scrollView.contentOffset;
    if (offset.x == 0) {
        _pageControl.currentPage = 0;
    } else {
        int page = offset.x / CGRectGetWidth(scrollView.frame);
        _pageControl.currentPage = page;
    }
}

#pragma mark - action

- (void)photoAction
{
	if (_delegate && [_delegate respondsToSelector:@selector(moreViewPhotoAction:)]) {
		[_delegate moreViewPhotoAction:self];
	}
}

- (void)takePicAction{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewTakePicAction:)]){
        [_delegate moreViewTakePicAction:self];
    }
}

- (void)locationAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewLocationAction:)]) {
        [_delegate moreViewLocationAction:self];
    }
}

- (void)takeAudioCallAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewAudioCallAction:)]) {
        [_delegate moreViewAudioCallAction:self];
    }
}

- (void)takeVideoCallAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewVideoCallAction:)]) {
        [_delegate moreViewVideoCallAction:self];
    }
}

- (void)otherAction
{
	if (_delegate && [_delegate respondsToSelector:@selector(moreViewOtherAction:)]) {
		[_delegate moreViewOtherAction:self];
	}
}

- (void)moreAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    if (button && _delegate && [_delegate respondsToSelector:@selector(moreView:didItemInMoreViewAtIndex:)]) {
        [_delegate moreView:self didItemInMoreViewAtIndex:button.tag-MOREVIEW_BUTTON_TAG];
    }
}

@end
