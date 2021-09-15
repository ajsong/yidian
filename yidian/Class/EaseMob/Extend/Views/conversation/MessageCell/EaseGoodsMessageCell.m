//
//  EaseGoodsMessageCell.m
//
//  Created by ajsong on 16/8/12.
//  Copyright © 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "EaseGoodsMessageCell.h"
#import "UIImageView+EMWebCache.h"
#import "EaseSDKHelper.h"

#define NAME_HEIGHT 15
#define GOODS_IMAGE_HEIGHT 80

@implementation EaseGoodsMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
			  reuseIdentifier:(NSString *)reuseIdentifier
						model:(id<IMessageModel>)model
						delegate:(id<EaseGoodsMessageCellDelegate>)delegate
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryType = UITableViewCellAccessoryNone;
		
		if (delegate && [delegate respondsToSelector:@selector(getNameAndAvatarWithModel:)]) {
			model = [delegate getNameAndAvatarWithModel:model];
		}
		
		UIImage *background = nil;
		CGFloat avatarSize = 40;
		CGFloat goodsSize = GOODS_IMAGE_HEIGHT;
		CGFloat bubbleViewWidth = 200;
		CGFloat avatarX = 10;
		CGFloat nameX = avatarX+avatarSize + 10;
		CGFloat nameWidth = SCREEN_WIDTH - nameX;
		NSTextAlignment nameAlign = NSTextAlignmentLeft;
		CGFloat bubbleViewX = avatarX+avatarSize + 10;
		if (model.isSender) {
			background = [IMGEASE(@"chat_sender_bg") stretchableImageWithLeftCapWidth:15 topCapHeight:30];
			avatarX = SCREEN_WIDTH - avatarSize - 10;
			nameX = 0;
			nameAlign = NSTextAlignmentRight;
			bubbleViewX = SCREEN_WIDTH - (bubbleViewWidth + 10 + avatarSize + 10);
		} else {
			background = [IMGEASE(@"chat_receiver_bg") stretchableImageWithLeftCapWidth:15 topCapHeight:30];
		}
		
		UIImageView *avatar = [[UIImageView alloc]initWithFrame:CGRectMake(avatarX, 10, avatarSize, avatarSize)];
		[avatar em_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:model.avatarImage];
		avatar.layer.masksToBounds = YES;
		avatar.layer.cornerRadius = avatarSize/2;
		avatar.clipsToBounds = YES;
		avatar.contentMode = UIViewContentModeScaleAspectFill;
		[self.contentView addSubview:avatar];
		
		UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(nameX, 0, nameWidth, NAME_HEIGHT)];
		name.text = model.nickname;
		name.textColor = [UIColor grayColor];
		name.textAlignment = nameAlign;
		name.font = [UIFont systemFontOfSize:10.f];
		name.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:name];
		
		UIView *bubbleView = [[UIView alloc]initWithFrame:CGRectMake(bubbleViewX, name.bottom, bubbleViewWidth, goodsSize+5*2)];
		[self.contentView addSubview:bubbleView];
		
		UIImageView *backgroundPic = [[UIImageView alloc]initWithFrame:bubbleView.bounds];
		backgroundPic.image = background;
		[bubbleView addSubview:backgroundPic];
		
		UIImageView *goodsPic = [[UIImageView alloc]initWithFrame:CGRectMake(model.isSender?5:10, 5, goodsSize, goodsSize)];
		goodsPic.clipsToBounds = YES;
		goodsPic.contentMode = UIViewContentModeScaleAspectFill;
		[goodsPic em_setImageWithURL:[NSURL URLWithString:model.message.ext[@"goods"][@"goods_image"]] completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
			if (error) {
				goodsPic.image = IMG(@"nopic");
			}
		}];
		[bubbleView addSubview:goodsPic];
		
		NSString *text = model.message.ext[@"goods"][@"goods_name"];
		CGSize s = [text autoHeight:FONT(13) width:bubbleViewWidth-(goodsPic.right+5)-(model.isSender?10:5)];
		if (s.height > goodsPic.height) {
			s.height = goodsPic.height;
		}
		
		UILabel *goodsName = [[UILabel alloc]initWithFrame:CGRectMake(goodsPic.right+5, goodsPic.top, bubbleViewWidth-(goodsPic.right+5)-(model.isSender?10:5), s.height)];
		goodsName.text = text;
		goodsName.textColor = [UIColor blackColor];
		goodsName.font = FONT(13);
		goodsName.backgroundColor = [UIColor clearColor];
		goodsName.numberOfLines = 0;
		[bubbleView addSubview:goodsName];
		
		[bubbleView click:^(UIView *view, UIGestureRecognizer *sender) {
			if (delegate && [delegate respondsToSelector:@selector(EaseGoodsMessageCellSelected:)]) {
				[delegate EaseGoodsMessageCellSelected:model];
			}
		}];
	}
	
	return self;
}

+ (CGFloat)messageCellHeight {
    return NAME_HEIGHT + GOODS_IMAGE_HEIGHT+5*2 + 15;
}

@end
