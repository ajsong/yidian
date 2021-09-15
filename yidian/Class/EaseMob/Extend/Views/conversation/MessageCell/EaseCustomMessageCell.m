/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "Global.h"
#import "EaseCustomMessageCell.h"
#import "EaseBubbleView+Gif.h"
#import "IMessageModel.h"
#import "UIImageView+EMWebCache.h"

@interface EaseCustomMessageCell ()

@end

@implementation EaseCustomMessageCell

+ (void)initialize
{
    // UIAppearance Proxy Defaults
}

#pragma mark - IModelCell

- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    return YES;
}

- (void)setCustomModel:(id<IMessageModel>)model
{
    UIImage *image = model.image;
    if (!image) {
		self.bubbleView.imageView.image = [UIImage imageNamed:model.failImageName];
		[self.bubbleView.imageView em_setImageWithURL:[NSURL URLWithString:model.fileURLPath] placeholderImage:nil];
    } else {
        _bubbleView.imageView.image = image;
    }
	self.avatarView.image = model.avatarImage;
    if (model.avatarURLPath) {
		[self.avatarView em_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:nil];
    }
}

- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    [_bubbleView setupGifBubbleView];
    
    _bubbleView.imageView.image = [UIImage imageNamed:@"imageDownloadFail"];
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    [_bubbleView updateGifMargin:bubbleMargin];
}

+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    return model.isSender?@"EaseMessageCellSendGif":@"EaseMessageCellRecvGif";
}

+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    return 100;
}

@end
