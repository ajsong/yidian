//
//  orderShipping.h
//  ejdian
//
//  Created by ajsong on 15/6/16.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "orderDetail.h"

@interface orderShipping : UIViewController
@property (nonatomic,retain) id<OrderDetailDelegate> delegate;
@property (nonatomic,retain) NSDictionary *data;
@end
