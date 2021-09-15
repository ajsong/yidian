//
//  shopFreeShipping.h
//  yidian
//
//  Created by ajsong on 2016/10/19.
//  Copyright © 2016年 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalDelegate.h"

@interface shopFreeShipping : UIViewController
@property (nonatomic,assign) id<GlobalDelegate> delegate;
@property (nonatomic,strong) NSString *price;
@end
