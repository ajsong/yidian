//
//  withdrawEdit.h
//  yidian
//
//  Created by ajsong on 15/12/26.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalDelegate.h"

@interface withdrawEdit : UIViewController
@property (nonatomic,assign) id<GlobalDelegate> delegate;
@property (nonatomic,retain) NSDictionary *data;
@end
