//
//  GlobalDelegate.h
//
//  Created by ajsong on 15/11/23.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GlobalDelegate<NSObject>
@optional
- (void)GlobalExecuteWithData:(NSDictionary*)data;
- (void)GlobalExecuteWithDatas:(NSArray*)datas;
- (void)GlobalExecuteWithCaller:(UIViewController*)caller data:(NSDictionary*)data;
- (void)GlobalExecuteWithData:(NSDictionary*)data caller:(UIViewController*)caller;
- (NSString*)GlobalExecuteGroupWithData:(NSDictionary*)data;
- (void)GlobalExecuteShippingNumberWithData:(NSDictionary*)data;
@end

/*
@property (nonatomic,weak) id<GlobalDelegate> delegate;
*/