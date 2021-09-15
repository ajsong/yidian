//
//  talk.h
//
//  Created by ajsong on 15/6/12.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatView.h"

@interface talk : ChatView
@property (nonatomic,assign) BOOL isPresent;
@property (nonatomic,assign) BOOL isKefu;
/*!
 @brief 商品资料
 */
@property (nonatomic,strong) NSDictionary *goods;
@end
