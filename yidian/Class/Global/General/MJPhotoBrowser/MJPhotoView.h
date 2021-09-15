//
//  MJZoomingScrollView.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MJPhotoBrowser, MJPhoto, MJPhotoView;

@protocol MJPhotoViewDelegate <NSObject>
- (void)photoViewImageFinishLoad:(MJPhotoView *)photoView;
- (void)photoViewSingleTap:(MJPhotoView *)photoView;
- (void)photoViewDidEndZoom:(MJPhotoView *)photoView;
@end

@interface MJPhotoView : UIScrollView
// 图片
@property (nonatomic, retain) MJPhoto *photo;
// 代理
@property (nonatomic, weak) id<MJPhotoViewDelegate> photoViewDelegate;
// 状态栏状态
@property (nonatomic, assign) BOOL statusBarHidden;
// 是否显示在window
@property (nonatomic, assign) BOOL showInWidow;
// 前一张图片显示原图
- (void)setOriginImage;
@end