//
//  Alipay.h
//
//  Created by ajsong on 15/4/10.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Alipay : NSObject
- (void)payWithTradeNO:(NSString*)tradeNO productName:(NSString*)name description:(NSString*)description totalprice:(NSString*)totalprice notifyURL:(NSString*)notifyURL completion:(void (^)())completion fail:(void (^)(int statusCode))fail;
@end
