//
//  EaseGoodsMessageCell.h
//
//  Created by ajsong on 16/8/12.
//  Copyright © 2016年 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseMessageModel.h"

@protocol EaseGoodsMessageCellDelegate;

@interface EaseGoodsMessageCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
			  reuseIdentifier:(NSString *)reuseIdentifier
						model:(id<IMessageModel>)model
						delegate:(id<EaseGoodsMessageCellDelegate>)delegate;

+ (CGFloat)messageCellHeight;

@end

@protocol EaseGoodsMessageCellDelegate<NSObject>

@optional

- (void)EaseGoodsMessageCellSelected:(id<IMessageModel>)model;

- (EaseMessageModel*)getNameAndAvatarWithModel:(EaseMessageModel *)model;

@end
