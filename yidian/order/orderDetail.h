//
//  orderDetail.h
//  syoker
//
//  Created by ajsong on 15/4/10.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol OrderDetailDelegate<NSObject>
@optional
- (void)refreshDetail;
@end

@interface orderDetail : UIViewController
@property (nonatomic,retain) NSDictionary *data;
@end
