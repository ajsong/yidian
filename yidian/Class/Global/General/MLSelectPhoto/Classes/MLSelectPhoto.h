//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  ZLPicker.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-12-17.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#ifndef ZLAssetsPickerDemo_ZLPicker_h
#define ZLAssetsPickerDemo_ZLPicker_h

#import "MLSelectPhotoPickerViewController.h"
#import "MLSelectPhotoAssets.h"

/**
 *
 
 // Use
 ZLPhotoPickerViewController *picker = [[ZLPhotoPickerViewController alloc] init];
 // 默认显示相册里面的内容SavePhotos
 picker.status = PickerViewShowStatusCameraRoll;
 // 选择图片的最小数，默认是9张图片
 picker.maxCount = 4;
 // 设置代理回调
 picker.delegate = self;
 // 展示控制器
 [picker showInController:self];
 
 第一种回调方法：- (void)pickerViewControllerDoneAssets:(NSArray *)assets
 第二种回调方法pickerVc.callBack = ^(NSArray *assets){
 // TODO 回调结果，可以不用实现代理
 };
 
 */
#endif
