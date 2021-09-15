//
//  scaner.h
//  yidian
//
//  Created by ajsong on 16/1/6.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCodeReaderController.h"
#import "GlobalDelegate.h"

typedef enum : NSInteger {
	ScanerFromGoods = 0,
	ScanerFromOrder,
	ScanerFromShipping,
	ScanerFromResellerApply,
} ScanerFromType;

@interface scaner : QRCodeReaderController
@property (nonatomic,assign) ScanerFromType from; //从哪个视图过来
@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic,weak) id<GlobalDelegate> globalDelegate;
@end
