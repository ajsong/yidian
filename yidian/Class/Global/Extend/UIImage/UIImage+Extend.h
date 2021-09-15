//
//  UIImage+Extend.h
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - UIImageView+Extend
@interface UIImageView (GlobalExtend)
- (UIImage*)placeholder;
- (void)setPlaceholder:(UIImage*)placeholder;
- (BOOL)indicator;
- (void)setIndicator:(BOOL)indicator;
- (id)url;
- (void)setUrl:(id)url;
- (void)setUrl:(id)url placeholder:(id)placeholder completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion;
- (void)setUrl:(id)url placeholder:(id)placeholder completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion animate:(void (^)(UIImageView *imageView, BOOL isCache))animate;
- (void)cacheImageWithUrl:(id)url placeholder:(id)placeholder completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion;
- (void)cacheImageWithUrl:(id)url placeholder:(id)placeholder completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion animate:(void (^)(UIImageView *imageView, BOOL isCache))animate;
- (void)animationWithPlist:(NSString *)plistName duration:(NSTimeInterval)duration completion:(void (^)())completion;
@end


#pragma mark - UIImage+Extend
@interface UIImage (GlobalExtend)
+ (UIImage*)imageFile:(NSString*)name;
+ (UIImage*)imageFilename:(NSString*)name;
- (void)saveImageToPhotos;
- (void)saveToAlbumWithCompletion:(void (^)(BOOL success))completion;
- (void)saveImageToDocumentWithName:(NSString*)name;
- (void)saveImageToTmpWithName:(NSString*)name;
- (NSData*)imageQuality:(CGFloat)quality;
- (NSData*)imageQualityHigh;
- (NSData*)imageQualityMiddle;
- (NSData*)imageQualityLow;
- (UIImage*)fitToSize:(CGSize)size;
- (UIImage*)fitToSize:(CGSize)size fix:(CGFloat)fix;
- (UIImage*)croppedImage:(CGRect)bounds;
- (NSData*)imageToData;
- (NSData*)data;
- (NSString*)base64;
- (NSString*)imageToBase64;
- (NSString*)imageSuffix;
- (NSString*)imageMimeType;
- (BOOL)isPNG;
- (BOOL)isGIF;
- (UIImage*)imageBlackToTransparent;
- (UIImage*)imageWithTintColor:(UIColor*)color;
- (UIImage*)overlayWithColor:(UIColor*)color;
- (void)UploadToUpyun:(NSString*)upyunFolder completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion;
- (void)UploadToUpyun:(NSString*)upyunFolder imageName:(NSString*)imageName completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion;
@end
