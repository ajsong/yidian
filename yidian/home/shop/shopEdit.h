//
//  shopEdit.h
//  yidian
//
//  Created by ajsong on 16/1/4.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalDelegate.h"

typedef enum : NSInteger {
	ShopEditTypeTextField = 0,
	ShopEditTypeTextView,
	ShopEditTypeRefundAddress,
	ShopEditTypeAddress,
} ShopEditType;

@interface shopEdit : UIViewController
@property (nonatomic,assign) id<GlobalDelegate> delegate;
@property (nonatomic,assign) ShopEditType type;
@property (nonatomic,retain) NSDictionary *data;
@end
