//
//  UIImage+Extend.m
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import "Global.h"
//gif用
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

#pragma mark - UIImageView+Extend
@implementation UIImageView (GlobalExtend)
- (UIImage*)placeholder{
	return self.element[@"placeholder"];
}
- (void)setPlaceholder:(UIImage*)placeholder{
	self.element[@"placeholder"] = placeholder;
	CGFloat placeholderWidth = 70.f;
	if (placeholder.size.width < placeholderWidth) placeholderWidth = placeholder.size.width;
	UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake((self.width-placeholderWidth)/2, (self.height-placeholderWidth)/2, placeholderWidth, placeholderWidth)];
	img.image = placeholder;
	[self addSubview:img];
}
- (BOOL)indicator{
	return [self.element[@"indicator"] boolValue];
}
- (void)setIndicator:(BOOL)indicator{
	self.element[@"indicator"] = @(indicator);
	if (indicator) {
		UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[self addSubview:indicatorView];
		CGRect frame = indicatorView.frame;
		frame.origin.x = (self.width-frame.size.width)/2;
		frame.origin.y = (self.height-frame.size.height)/2;
		indicatorView.frame = frame;
		[indicatorView startAnimating];
	}
}
- (id)url{
	return self.element[@"url"];
}
- (void)setUrl:(id)url{
	[self setUrl:url placeholder:self.image completion:nil];
}
- (void)setUrl:(id)url placeholder:(id)placeholder completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion{
	[self setUrl:url placeholder:placeholder completion:completion animate:nil];
}
- (void)setUrl:(id)url placeholder:(id)placeholder completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion animate:(void (^)(UIImageView *imageView, BOOL isCache))animate{
	if ([self.url isset] && [self.url isEqual:url]) return;
	if (![url isKindOfClass:[NSString class]] && ![url isKindOfClass:[NSData class]] && ![url isKindOfClass:[UIImage class]]) return;
	if ([url isKindOfClass:[NSData class]] || [url isKindOfClass:[UIImage class]]) {
		self.element[@"url"] = url;
		BOOL isData = [url isKindOfClass:[NSData class]];
		self.image = isData ? [UIImage imageWithData:url] : url;
		if (completion) completion(self.image, isData ? url : self.image.imageToData, YES, NO);
		return;
	}
	NSString *imageUrl = ((NSString*)url).length ? url : @"";
	self.element[@"url"] = imageUrl;
	[Global cacheToImageView:self url:imageUrl placeholder:placeholder completion:completion animate:animate];
}
- (void)cacheImageWithUrl:(id)url placeholder:(id)placeholder completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion{
	[self setUrl:url placeholder:placeholder completion:completion animate:nil];
}
- (void)cacheImageWithUrl:(id)url placeholder:(id)placeholder completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion animate:(void (^)(UIImageView *imageView, BOOL isCache))animate{
	[self setUrl:url placeholder:placeholder completion:completion animate:animate];
}
- (void)animationWithPlist:(NSString *)plistName duration:(NSTimeInterval)duration completion:(void (^)())completion{
	if (self.isAnimating) return;
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
	NSArray *plist = [[NSArray alloc]initWithContentsOfFile:plistPath];
	NSMutableArray *images = [[NSMutableArray alloc]init];
	for (NSInteger i=0; i<plist.count; i++) {
		//imageNamed: 有缓存直到程序退出(文件名)
		//imageWithContentsOfFile: 没有缓存自动释放(文件全路径)
		NSString *filePath = [[NSBundle mainBundle] pathForResource:plist[i] ofType:nil];
		UIImage *image = [UIImage imageWithContentsOfFile:filePath];
		[images addObject:image];
	}
	self.animationImages = images;
	self.animationRepeatCount = 1; //重复次数,0表示无限重复
	self.animationDuration = duration; //动画总时间
	[self startAnimating];
	
	[self performSelector:@selector(startAnimating) withObject:nil afterDelay:duration];
	[self performSelector:@selector(setAnimationImages:) withObject:nil afterDelay:duration]; //播放完后清除内存
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC + 0.1);
	dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion();
			});
		}
	});
}
@end


#pragma mark - UIImage+Extend
@implementation UIImage (GlobalExtend)
//加载图片,png专用
+ (UIImage*)imageFile:(NSString*)name{
	BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:STRINGFORMAT(@"%@@2x.png", name) ofType:nil]];
	if (fileExist) {
		return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:STRINGFORMAT(@"%@@2x.png", name) ofType:nil]];
	} else {
		return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:STRINGFORMAT(@"%@.png", name) ofType:nil]];
	}
}
+ (UIImage*)imageFilename:(NSString*)name{
	return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:STRINGFORMAT(@"%@", name) ofType:nil]];
}
//保存图片到相册
- (void)saveImageToPhotos{
	[Global saveImageToPhotos:self];
}
//保存图片到相册,保持图片清晰
- (void)saveToAlbumWithCompletion:(void (^)(BOOL success))completion{
	[Global saveToAlbumWithImage:self completion:completion];
}
//保存图片到Document
- (void)saveImageToDocumentWithName:(NSString*)name{
	[Global saveImageToDocument:self withName:name];
}
//保存图片到Tmp
- (void)saveImageToTmpWithName:(NSString*)name{
	[Global saveImageToTmp:self withName:name];
}
//修改图片质量,且转为NSData,只支持jpg图片
- (NSData*)imageQuality:(CGFloat)quality{
	return UIImageJPEGRepresentation(self, quality);
}
- (NSData*)imageQualityHigh{
	return [self imageQuality:0.8];
}
- (NSData*)imageQualityMiddle{
	return [self imageQuality:0.5];
}
- (NSData*)imageQualityLow{
	return [self imageQuality:0.1];
}
//等比缩放
- (UIImage*)fitToSize:(CGSize)size{
	return [self fitToSize:size fix:0.0];
}
- (UIImage*)fitToSize:(CGSize)size fix:(CGFloat)fix{
	if (self == nil || self.isGIF) return nil;
	CGFloat left = 0;
	CGFloat top = 0;
	CGFloat width = size.width;
	CGFloat height = size.height;
	CGFloat iw = self.size.width;
	CGFloat ih = self.size.height;
	CGFloat nw = iw;
	CGFloat nh = ih;
	if (iw>0 && ih>0) {
		if (width>0 && height>0) {
			if (iw<=width && ih<=height) {
				nw = iw;
				nh = ih;
			} else {
				if (iw/ih >= width/height) {
					if (iw>width) {
						nw = width;
						nh = (ih*width)/iw;
					}
				} else {
					if (ih>height) {
						nw = (iw*height)/ih;
						nh = height;
					}
				}
			}
		} else {
			if (width==0 && height>0) {
				nw = (iw*height)/ih;
				nh = height;
			} else if (width>0 && height==0) {
				nw = width;
				nh = (ih*width)/iw;
			} else if (width==0 && height==0 && fix>0) {
				if (iw>ih) {
					nw = (iw*fix)/ih;
					nh = fix;
				} else {
					nw = fix;
					nh = (ih*fix)/iw;
				}
			}
		}
	}
	if (width>0) {
		if (width>nw) {
			size = CGSizeMake(nw, size.height);
		} else {
			left = (width-nw)/2;
		}
	} else {
		size = CGSizeMake(nw, size.height);
	}
	if (height>0) {
		if (height>nh) {
			size = CGSizeMake(size.width, nh);
		} else {
			top = (height-nh)/2;
		}
	} else {
		size = CGSizeMake(size.width, nh);
	}
	//创建一个bitmap的context,并把它设置成为当前正在使用的context
	UIGraphicsBeginImageContext(size);
	//绘制改变大小的图片
	[self drawInRect:CGRectMake(left, top, nw, nh)];
	//从当前context中创建一个改变大小后的图片
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	//使当前的context出堆栈
	UIGraphicsEndImageContext();
	//返回新的改变大小后的图片
	return newImage;
}
//裁剪图片
- (UIImage*)croppedImage:(CGRect)bounds{
	CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, bounds);
	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawImage(context, bounds, imageRef);
	UIImage *smallImage = [UIImage imageWithCGImage:imageRef];
	UIGraphicsEndImageContext();
	CGImageRelease(imageRef);
	return smallImage;
}
//转NSData
- (NSData*)imageToData{
	return self.data;
}
- (NSData*)data{
	if (!self.images) {
		NSData *data = UIImageJPEGRepresentation(self, 1.0f);
		if (!data) data =  UIImagePNGRepresentation(self);
		return data;
	} else {
		NSDictionary *userInfo = nil;
		NSMutableArray *images = [[NSMutableArray alloc]init];
		for (int i=0; i<self.images.count; i++) {
			if (![self.images[i] isKindOfClass:[NSNull class]]) {
				[images addObject:self.images[i]];
			}
		}
		size_t frameCount = images.count;
		NSTimeInterval frameDuration = self.duration / frameCount;
		NSDictionary *frameProperties = @{(__bridge NSString *)kCGImagePropertyGIFDictionary: @{(__bridge NSString *)kCGImagePropertyGIFDelayTime:@(frameDuration)}};
		NSMutableData *mutableData = [NSMutableData data];
		CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)mutableData, kUTTypeGIF, frameCount, NULL);
		NSUInteger loopCount = 1;
		NSDictionary *imageProperties = @{(__bridge NSString *)kCGImagePropertyGIFDictionary: @{(__bridge NSString *)kCGImagePropertyGIFLoopCount: @(loopCount)}};
		CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)imageProperties);
		for (size_t idx = 0; idx < images.count; idx++) {
			CGImageDestinationAddImage(destination, [[images objectAtIndex:idx] CGImage], (__bridge CFDictionaryRef)frameProperties);
		}
		BOOL success = CGImageDestinationFinalize(destination);
		CFRelease(destination);
		if (!success) {
			NSLog(@"%@", @{NSLocalizedDescriptionKey:@"无法完成目标图像"});
		}
		return [NSData dataWithData:mutableData];
	}
}
//转base64
- (NSString*)base64{
	NSData *imageData = self.imageToData;
	return [imageData base64EncodedStringWithOptions:0];
}
//转base64,带标识
- (NSString*)imageToBase64{
	NSString *mimeType = @"image/jpeg";
	if (self.isPNG) mimeType = @"image/png";
	return [NSString stringWithFormat:@"data:%@;base64,%@", mimeType, self.base64];
}
//后缀名
- (NSString*)imageSuffix{
	NSString *format = @"";
	uint8_t c;
	[self.imageToData getBytes:&c length:1];
	switch (c) {
		case 0xFF:
			format = @"jpg";
			break;
		case 0x89:
			format = @"png";
			break;
		case 0x47:
			format = @"gif";
			break;
		case 0x49:
		case 0x4D:
			format = @"tiff";
			break;
		case 0x42:
			format = @"bmp";
			break;
	}
	return format;
}
//图片MimeType
- (NSString*)imageMimeType{
	NSString *format = @"image/jpeg";
	uint8_t c;
	[self.imageToData getBytes:&c length:1];
	switch (c) {
		case 0xFF:
			format = @"image/jpeg";
			break;
		case 0x89:
			format = @"image/png";
			break;
		case 0x47:
			format = @"image/gif";
			break;
		case 0x49:
		case 0x4D:
			format = @"image/tiff";
			break;
		case 0x42:
			format = @"application/x-bmp";
			break;
	}
	return format;
}
//是否PNG
- (BOOL)isPNG{
	BOOL isPNG = NO;
	uint8_t c;
	[self.imageToData getBytes:&c length:1];
	switch (c) {
		case 0x89:
			isPNG = YES;
			break;
		default:
			break;
	}
	return isPNG;
	/*
	CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
	return (alpha == kCGImageAlphaFirst || alpha == kCGImageAlphaLast || alpha == kCGImageAlphaPremultipliedFirst ||
			alpha == kCGImageAlphaPremultipliedLast);
	*/
}
//是否GIF
- (BOOL)isGIF{
	BOOL isGIF = NO;
	uint8_t c;
	[self.imageToData getBytes:&c length:1];
	switch (c) {
		case 0x47:
			isGIF = YES;
			break;
		default:
			break;
	}
	return isGIF;
}
//将白色变成透明
void ProviderReleaseData(void *info, const void *data, size_t size){
	free((void*)data);
}
- (UIImage*)imageBlackToTransparent{
	const int imageWidth = self.size.width;
	const int imageHeight = self.size.height;
	size_t bytesPerRow = imageWidth * 4;
	uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
												 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
	CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
	//遍历像素
	int pixelNum = imageWidth * imageHeight;
	uint32_t* pCurPtr = rgbImageBuf;
	for (int i=0; i<pixelNum; i++, pCurPtr++){
		if ((*pCurPtr & 0xFFFFFF00) == 0xffffff00) { //将白色变成透明
			uint8_t* ptr = (uint8_t*)pCurPtr;
			ptr[0] = 0;
		} else {
			//改成下面的代码，会将图片转成想要的颜色
			uint8_t* ptr = (uint8_t*)pCurPtr;
			ptr[3] = 0; //0~255
			ptr[2] = 0;
			ptr[1] = 0;
		}
	}
	CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
	CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
										kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
										NULL, true, kCGRenderingIntentDefault);
	CGDataProviderRelease(dataProvider);
	UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	return resultUIImage;
}
//渲染颜色
- (UIImage*)imageWithTintColor:(UIColor*)color{
	CGBlendMode blendMode = kCGBlendModeOverlay;
	UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
	[color setFill];
	CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
	UIRectFill(bounds);
	[self drawInRect:bounds blendMode:blendMode alpha:1.0f];
	if (blendMode != kCGBlendModeDestinationIn) [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
	UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return tintedImage;
}
//颜色叠加
- (UIImage*)overlayWithColor:(UIColor*)color{
	UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0, self.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
	CGContextClipToMask(context, rect, self.CGImage);
	[color setFill];
	CGContextFillRect(context, rect);
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}
//又拍云上传图片
- (void)UploadToUpyun:(NSString*)upyunFolder completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	[self UploadToUpyun:upyunFolder imageName:nil completion:completion];
}
//又拍云上传图片, 指定文件名(不包含后缀)
- (void)UploadToUpyun:(NSString*)upyunFolder imageName:(NSString*)imageName completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	if (self.size.width<=0) {
		[ProgressHUD showError:@"图片无效"];
		return;
	}
	if (!imageName.length) imageName = [Global datetimeAndRandom];
	NSData *imageData = self.imageToData;
	[imageData UploadToUpyun:upyunFolder imageName:imageName completion:completion];
}
@end
