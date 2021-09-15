//
//  MJPhotoBrowser.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

/*
NSInteger tag = sender.view.tag - 100;
NSMutableArray *images = [[NSMutableArray alloc]init];
for (int i=0; i<list.count; i++) {
	MJPhoto *photo = [[MJPhoto alloc] init];
	photo.url = list[i][@"pic"];
	photo.srcImageView = pic;
	[images addObject:photo];
}
if (images.count) {
	MJPhotoBrowser *browser = [[MJPhotoBrowser alloc]init];
	browser.currentPhotoIndex = tag;
	browser.photos = images;
	browser.delegate = self;
	[browser show];
}
*/

#import <UIKit/UIKit.h>
#import "MJPhoto.h"

@protocol MJPhotoBrowserDelegate;
@interface MJPhotoBrowser : UIViewController <UIScrollViewDelegate>
// 代理
@property (nonatomic, weak) id<MJPhotoBrowserDelegate> delegate;
// 所有的图片对象
@property (nonatomic, retain) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;
// 默认显示图片信息
@property (nonatomic, assign) BOOL showInfo;
// 工具条扩展按钮
@property (nonatomic, retain) UIView *btnView;

// 显示
- (void)show;
// 更新标题与描述
- (void)reloadData;
@end

@protocol MJPhotoBrowserDelegate <NSObject>
@optional
// 切换到某一页图片
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index direction:(NSInteger)direction;
- (void)photoViewSingleTap;
- (void)photoViewDidEndZoom;
@end
