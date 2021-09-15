//
//  MJRefreshHeaderView.h
//
//  Created by mj on 13-2-26.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJRefreshBaseView.h"

@interface MJRefreshHeaderView : MJRefreshBaseView
+ (instancetype)header;
@property (nonatomic, weak) UILabel *lastUpdateTimeLabel;
@end