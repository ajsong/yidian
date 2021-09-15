//
//  factoryEdit.h
//  yidian
//
//  Created by ajsong on 16/4/8.
//  Copyright © 2016年 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "factoryGoods.h"
#import "factoryScaner.h"

@interface factoryEdit : UIViewController
@property (nonatomic,strong) UIView *currentView;
- (void)pushScanerWithIndex:(NSInteger)listIndex data:(NSDictionary*)data type:(FactoryScanerType)type subType:(FactoryScanerSubType)subType;
@end
