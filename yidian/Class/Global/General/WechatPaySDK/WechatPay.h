//
//  WechatPay.h
//
//  Created by ajsong on 15/8/4.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WEIXIN_PAY_NOTIFICATION @"WEIXIN_PAY_NOTIFICATION"

@interface WechatPay : NSObject

- (void)wechatPayWithTradeNO:(NSString*)tradeNO productName:(NSString*)name totalprice:(NSString*)totalprice notifyURL:(NSString*)notifyURL;

@end
