//
//  factoryScaner.h
//  yidian
//
//  Created by ajsong on 16/7/4.
//  Copyright © 2016年 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalDelegate.h"
#import "QRCodeReaderController.h"

typedef enum : NSInteger {
	PackageType1 = 0,
	PackageType2,
	PackageType3,
} FactoryScanerType;

typedef enum : NSInteger {
	PackageSubType1 = 0,
	PackageSubType2,
} FactoryScanerSubType;

@interface factoryScaner : QRCodeReaderController
@property (nonatomic,weak) id<GlobalDelegate> globalDelegate;
@property (nonatomic,assign) FactoryScanerType type;
@property (nonatomic,assign) FactoryScanerSubType subType;
@property (nonatomic,strong) NSDictionary *data;
@end
