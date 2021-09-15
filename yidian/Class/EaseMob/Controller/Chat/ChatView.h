//
//  ChatView.h
//
//  Created by ajsong on 15/6/12.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseMessageViewController.h"

@class EaseConversationModel;

@interface ChatView : EaseMessageViewController <EaseMessageViewControllerDelegate, EaseMessageViewControllerDataSource>

@property (nonatomic,assign) BOOL showClearButton;

@end
