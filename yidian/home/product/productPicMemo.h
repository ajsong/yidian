//
//  productPicMemo.h
//  yidian
//
//  Created by ajsong on 16/1/23.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalDelegate.h"
@class MJPhotoBrowser;

@interface productPicMemo : UIViewController
@property (nonatomic,weak) id<GlobalDelegate> delegate;
@property (nonatomic,retain) NSDictionary *data;
@property (nonatomic,retain) MJPhotoBrowser *browser;
@end
