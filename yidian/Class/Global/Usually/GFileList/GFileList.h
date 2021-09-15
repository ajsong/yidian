//
//  GFileList.h
//
//  Created by ajsong on 15/6/30.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFileList : UIViewController
@property (nonatomic,retain) NSString *folderPath;
- (id)initWithFolderPath:(NSString*)folderPath;
@end
