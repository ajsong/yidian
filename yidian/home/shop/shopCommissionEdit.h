//
//  shopCommissionEdit.h
//  yidian
//
//  Created by ajsong on 16/1/4.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalDelegate.h"

@interface shopCommissionEdit : UIViewController
@property (nonatomic,assign) id<GlobalDelegate> delegate;
@property (nonatomic,retain) NSDictionary *data;
@end
