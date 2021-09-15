//
//  Global.m
//
//  Created by ajsong on 2014-9-1.
//  Copyright (c) 2014 @jsong. All rights reserved.
//

#import "Global.h"
#import "sys/utsname.h" //设备类型
#import <AVFoundation/AVFoundation.h> //声音
#import <Accelerate/Accelerate.h>
#import <AssetsLibrary/ALAssetsLibrary.h> //相册
#import <LocalAuthentication/LocalAuthentication.h> //Touch ID
#import <MessageUI/MessageUI.h> //发短信

//extern NSString *CTSettingCopyMyPhoneNumber();

@interface Global (){
	NSMutableDictionary *_dict;
}
@end

@implementation Global

#pragma mark - 系统
//获取当前显示的视图
+ (UIViewController*)currentController{
	return KEYWINDOW.currentController;
}

//判断是否竖屏
+ (BOOL)verticalScreen:(UIViewController*)view{
    if (view.interfaceOrientation==UIInterfaceOrientationPortrait || view.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
		//portrait
        return YES;
    } else {
		//landscape
        return NO;
    }
}

//是否新版本
+ (BOOL)isNewVersion{
	NSInteger version = [[[@"app_version" getUserDefaultsString] replace:@"." to:@""]integerValue];
	[@"app_version" setUserDefaultsWithData:APP_VERSION];
	if (version <= 0) return YES;
	return version > [[APP_VERSION replace:@"." to:@""]integerValue];
}

//设备类型
+ (NSString*)deviceString{
	struct utsname systemInfo;
	uname(&systemInfo);
	NSString *string = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
	return string;
}
+ (NSString*)device{
	NSString *device = [Global deviceString];
	if ([device isEqualToString:@"iPhone3,1"]) return @"iPhone4";
	if ([device isEqualToString:@"iPhone4,1"]) return @"iPhone4s";
	if ([device isEqualToString:@"iPhone5,2"]) return @"iPhone5";
	if ([device isEqualToString:@"iPhone6,1"]) return @"iPhone5s";
	if ([device isEqualToString:@"iPhone7,2"]) return @"iPhone6";
	if ([device isEqualToString:@"iPhone7,1"]) return @"iPhone6Plus";
	if ([device isEqualToString:@"iPhone8,1"]) return @"iPhone6s";
	if ([device isEqualToString:@"iPhone8,2"]) return @"iPhone6sPlus";
	if ([device isEqualToString:@"iPad2,1"] || [device isEqualToString:@"iPad2,2"] || [device isEqualToString:@"iPad2,3"]) return @"iPad2";
	if ([device isEqualToString:@"i386"]) return @"Simulator";
	if ([device isEqualToString:@"x86_64"]) return @"Simulator";
	return device;
}

//获取本机号码
+ (NSString*)getTelephonyNumber{
	//return CTSettingCopyMyPhoneNumber();
	return @"";
}

//复制到粘贴板
+ (void)copyString:(NSString*)string{
	UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
	pasteBoard.string = string;
}

//获取本地储存
+ (id)getUserDefaults:(NSString*)key{
	return [key getUserDefaults];
}
+ (NSString*)getUserDefaultsString:(NSString*)key{
	return [key getUserDefaultsString];
}
+ (NSInteger)getUserDefaultsInteger:(NSString*)key{
	return [key getUserDefaultsInteger];
}
+ (CGFloat)getUserDefaultsFloat:(NSString*)key{
	return [key getUserDefaultsFloat];
}
+ (BOOL)getUserDefaultsBool:(NSString*)key{
	return [key getUserDefaultsBool];
}
+ (NSMutableArray*)getUserDefaultsArray:(NSString*)key{
	return [key getUserDefaultsArray];
}
+ (NSMutableDictionary*)getUserDefaultsDictionary:(NSString*)key{
	return [key getUserDefaultsDictionary];
}

//保存到本地储存
+ (void)setUserDefaults:(NSString*)key data:(id)data{
	[key setUserDefaultsWithData:data];
}

//删除本地储存
+ (void)deleteUserDefaults:(NSString*)key{
	[key deleteUserDefaults];
}

#pragma mark - 检测
//是否为整型
+ (BOOL)isInt:(NSString*)string{
    return [string isInt];
}

//是否为浮点型
+ (BOOL)isFloat:(NSString*)string{
    return [string isFloat];
}

//判断是否数组
+ (BOOL)isArray:(id)data{
    return [data isArray];
}

//判断是否字典
+ (BOOL)isDictionary:(id)data{
    return [data isDictionary];
}

//是否为日期字符串
+ (BOOL)isDate:(NSString*)string{
	return [string isDate];
}

//判断数组是否包含,包含即返回所在索引,否则返回 NSNotFound
+ (NSInteger)inArray:(NSArray*)array object:(id)object{
	return [object inArray:array];
}

//判断字典是否包含,包含即返回所在索引字符串,否则返回空字符串
+ (NSString*)inDictionary:(NSDictionary*)dictionary object:(id)object{
	return [object inDictionary:dictionary];
}

//是否越狱
+ (BOOL)isJailbroken{
	NSString *cydiaPath = @"/Applications/Cydia.app";
	NSString *aptPath = @"/private/var/lib/apt/";
	if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath] || [[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
		return YES;
	}
	return NO;
}

//判断字符串是否有内容
+ (BOOL)hasString:(NSString*)string{
	return [string isset];
}

#pragma mark - 导航
//设置状态栏颜色需在Info.plist设置 View controller-based status bar appearance : NO
//[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//获取状态栏
+ (UIView*)statusBar{
	UIView *statusBar = nil;
	NSData *data = [NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9];
	NSString *key = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	id object = [UIApplication sharedApplication];
	if ([object respondsToSelector:NSSelectorFromString(key)]) statusBar = [object valueForKey:key];
	return statusBar;
}

//状态栏高度
+ (CGFloat)statusBarHeight{
	return [UIApplication sharedApplication].statusBarFrame.size.height;
}

//隐藏状态栏
+ (void)statusBarHidden:(BOOL)hidden animated:(BOOL)animated{
	UIViewController *controller = [Global currentController];
    if ([controller respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        //!IOS6
        [controller performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        //setNeedsStatusBarAppearanceUpdate 在push或present的controller里调用才起作用
        /*
		 //需在view里面增加这个方法
		 -(BOOL)prefersStatusBarHidden{
		 return YES; //隐藏为YES,显示为NO
		 }
		 */
	}
	//BOOL isFullScreen = [UIApplication sharedApplication].statusBarHidden;
	if (animated) {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationSlide];
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden];
	}
}

//状态栏文字颜色
+ (void)statusBarStyle:(UIStatusBarStyle)style animated:(BOOL)animated{
	[[UIApplication sharedApplication] setStatusBarStyle:style animated:animated];
	//[controller setNeedsStatusBarAppearanceUpdate];
}

//导航栏+状态栏高度
+ (CGFloat)navigationAndStatusBarHeight{
	UIViewController *controller = [Global currentController];
	CGFloat height = [Global statusBarHeight];
	return controller.navigationController.navigationBar.frame.size.height + height;
}

//导航栏高度
+ (CGFloat)navigationHeight{
	UIViewController *controller = [Global currentController];
	if (!controller.navigationController) return 0;
	return controller.navigationController.navigationBar.frame.size.height;
}

//导航栏背景色与文字颜色
+ (void)navigationBackgroundColor:(UIColor *)bgcolor textcolor:(UIColor *)textcolor{
	UIViewController *controller = [Global currentController];
	[Global navigationBackgroundColor:bgcolor textcolor:textcolor controller:controller];
}
+ (void)navigationBackgroundColor:(UIColor *)bgcolor textcolor:(UIColor *)textcolor controller:(UIViewController*)controller{
	if (!controller.navigationController) return;
	[controller.navigationController setBackgroundColor:bgcolor textColor:textcolor];
}

//导航栏背景图
+ (void)navigationBackgroundImage:(UIImage *)image{
	UIViewController *controller = [Global currentController];
	if (!controller.navigationController) return;
	[controller.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

//导航栏背景透明(需要一张透明图片)
+ (void)navigationTranslucent{
	UIViewController *controller = [Global currentController];
	if (!controller.navigationController) return;
	controller.navigationController.navigationBar.translucent = YES;
	[Global navigationBackgroundImage:[UIImage imageNamed:@"space"]];
}

#pragma mark - 颜色
//网页颜色转UIColor
+ (UIColor*)colorFromHexRGB:(NSString*)colorString{
    return [Global colorFromHexRGB:colorString alpha:1.f];
}

//网页颜色转UIColor+透明度
+ (UIColor*)colorFromHexRGB:(NSString*)colorString alpha:(CGFloat)alpha{
	if (colorString==nil || !colorString.length) return nil;
	if ([colorString hasPrefix:@"#"]) colorString = [colorString substringFromIndex:1];
	if (colorString.length==3) {
		NSString *red = [colorString substringWithRange:NSMakeRange(0,1)];
		NSString *green = [colorString substringWithRange:NSMakeRange(1,1)];
		NSString *blue = [colorString substringWithRange:NSMakeRange(2,1)];
		colorString = [NSString stringWithFormat:@"%@%@%@%@%@%@",red,red,green,green,blue,blue];
	}
    UIColor *result = nil;
    unsigned int colorCode = 0;
	unsigned char redByte, greenByte, blueByte;
	NSScanner *scanner = [NSScanner scannerWithString:colorString];
	(void)[scanner scanHexInt:&colorCode];
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode);
    result = [UIColor
              colorWithRed:(CGFloat)redByte / 0xff
              green:(CGFloat)greenByte/ 0xff
              blue:(CGFloat)blueByte / 0xff
              alpha:alpha];
    return result;
}

//UIColor转网页颜色
+ (NSString*)stringOfColor:(UIColor*)color{
	const CGFloat *cs = CGColorGetComponents(color.CGColor);
	NSString *hex = [NSString stringWithFormat:@"%02X%02X%02X", (int)(cs[0]*255.f), (int)(cs[1]*255.f), (int)(cs[2]*255.f)];
	return hex;
}

//UIImage转UIColor
+ (UIColor*)colorFromImage:(UIImage*)img{
    return [UIColor colorWithPatternImage:img];
}

//UIImage转UIColor, 并设宽高
+ (UIColor*)colorFromImage:(UIImage*)img size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIColor colorWithPatternImage:newImage];
}

//UIColor转UIImage
+ (UIImage*)imageFromColor:(UIColor*)color size:(CGSize)size{
	@autoreleasepool {
		CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
		UIGraphicsBeginImageContext(rect.size);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetFillColorWithColor(context, color.CGColor);
		CGContextFillRect(context, rect);
		UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return newImage;
	}
}

//随机颜色
+ (UIColor*)randomColor{
	//return [UIColor colorWithRed:arc4random_uniform(100)/100. green:arc4random_uniform(100)/100. blue:arc4random_uniform(100)/100. alpha:1];
	CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
	CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
	CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

//减浅颜色
+ (UIColor*)lighterColor:(UIColor*)color{
	CGFloat r, g, b, a;
	if ([color getRed:&r green:&g blue:&b alpha:&a])
		return [UIColor colorWithRed:MIN(r + 0.2, 1.0) green:MIN(g + 0.2, 1.0) blue:MIN(b + 0.2, 1.0) alpha:a];
	return nil;
}

//加深颜色
+ (UIColor*)darkerColor:(UIColor*)color{
	CGFloat r, g, b, a;
	if ([color getRed:&r green:&g blue:&b alpha:&a])
		return [UIColor colorWithRed:MAX(r - 0.2, 0.0) green:MAX(g - 0.2, 0.0) blue:MAX(b - 0.2, 0.0) alpha:a];
	return nil;
}

//获取两个颜色之间, value偏向color2的百分比
+ (UIColor*)colorBetweenColor1:(UIColor*)color1 color2:(UIColor*)color2 percent:(CGFloat)percent{
	percent = MIN(MAX(percent, 0.0), 1.0);
	CGFloat red1 = 0.0, green1 = 0.0, blue1 = 0.0, alpha1 = 0.0;
	[color1 getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
	CGFloat red2 = 0.0, green2 = 0.0, blue2 = 0.0, alpha2 = 0.0;
	[color2 getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
	return [UIColor colorWithRed:(red2-red1) * percent + red1
						   green:(green2-green1) * percent + green1
							blue:(blue2-blue1) * percent + blue1
						   alpha:(alpha2-alpha1) * percent + alpha1];
}

//颜色渐变, 0:从上到下, 1:从左到右, 2:左上到右下, 3:右上到左下
+ (UIImage*)gradientColors:(NSArray*)colors gradientType:(NSInteger)gradientType inView:(UIView*)view{
	CGSize size = view.frame.size;
    NSMutableArray *ar = [[NSMutableArray alloc]init];
    for(UIColor *color in colors) {
        [ar addObject:(id)color.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([colors.lastObject CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    CGPoint start = CGPointMake(0.0, 0.0);
    CGPoint end = CGPointMake(0.0, 0.0);
    switch (gradientType) {
        case 0:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, size.height);
            break;
        case 1:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, 0.0);
            break;
        case 2:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, size.height);
            break;
        case 3:
            start = CGPointMake(size.width, 0.0);
            end = CGPointMake(0.0, size.height);
            break;
        default:
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    //CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - 图片
//快速加载图片(待验证)
+ (UIImage*)decodeImage:(UIImage*)image{
	if(image==nil) return nil;
	UIGraphicsBeginImageContext(image.size);
	{
		[image drawAtPoint:CGPointMake(0, 0)];
		image = UIGraphicsGetImageFromCurrentImageContext();
	}
	UIGraphicsEndImageContext();
	return image;
}

//图片转NSData
+ (NSData*)imageToData:(UIImage*)image{
	return [image imageToData];
}

//通过NSData获取图片后缀名
+ (NSString*)imageSuffix:(NSData*)data{
	return [data imageSuffix];
}

//图片等比缩放
+ (UIImage*)fitToSize:(UIImage*)image size:(CGSize)size{
	return [image fitToSize:size fix:0];
}
+ (UIImage*)fitToSize:(UIImage*)image size:(CGSize)size fix:(CGFloat)fix{
    return [image fitToSize:size fix:fix];
}

//把图片指定颜色变透明，colorArray:[NSArray arrayWithObjects:@"250",@"255",@"250",@"255",@"250",@"255",nil]
+ (UIImage*)maskingImage:(UIImage*)image colorArray:(NSArray*)color{
	CGImageRef ref = image.CGImage;
	const CGFloat colorMasking[6] = {250,255,250,255,250,255};
    //for (int i = 0; i<6; i++) colorMasking[i] = [color[i] floatValue]; //被遮蔽(透明)的颜色
	CGImageRef imageRef = CGImageCreateWithMaskingColors(ref, colorMasking);
	imageRef = [self AddAlphaChannel:imageRef];
	return [UIImage imageWithCGImage:imageRef];
}
+ (CGImageRef)AddAlphaChannel:(CGImageRef)image{
    if ( CGImageGetAlphaInfo(image) == kCGImageAlphaNone || CGImageGetAlphaInfo(image) == kCGImageAlphaNoneSkipFirst || CGImageGetAlphaInfo(image) == kCGImageAlphaNoneSkipLast ) {
        size_t width = CGImageGetWidth(image);
        size_t height = CGImageGetHeight(image);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef offScreenContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
		CGColorSpaceRelease(colorSpace);
		CGImageRef retVal = NULL;
        if (offScreenContext != NULL) {
            CGContextDrawImage(offScreenContext, CGRectMake(0, 0, width, height), image);
            retVal = CGBitmapContextCreateImage(offScreenContext);
			CGContextRelease(offScreenContext);
        }
		return retVal;
    }
    return image;
}

//保存图片到相册
+ (void)saveImageToPhotos:(UIImage*)image{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo{
	NSString *mst = nil;
	NSString *msg = nil;
	if(error != NULL){
		mst = @"保存失败";
		msg = [NSString stringWithFormat:@"%@",error];
	}else{
		mst = @"保存成功";
		msg = @"图片已保存到手机相册";
	}
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:mst message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
	[alert show];
}

//保存图片到相册,保持图片清晰
+ (void)saveToAlbumWithImage:(UIImage*)image completion:(void (^)(BOOL success))completion{
	NSData *imageData = UIImagePNGRepresentation(image);
	if (!imageData.length) imageData = UIImageJPEGRepresentation(image, 1.0f);
	ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];
	[assetsLibrary writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error){
		BOOL success = YES;
		if (error) success = NO;
		if (completion) completion(success);
	}];
}

//保存图片到Document
+ (void)saveImageToDocument:(UIImage*)image withName:(NSString*)imageName{
	NSData *imageData = UIImagePNGRepresentation(image);
	if (!imageData.length) imageData = UIImageJPEGRepresentation(image, 1.0f);
    NSString *filePath = [Global getFilePathFromDocument:imageName];
    [imageData writeToFile:filePath atomically:NO];
}

//保存图片到Tmp
+ (void)saveImageToTmp:(UIImage*)image withName:(NSString*)imageName{
	NSData *imageData = UIImagePNGRepresentation(image);
	if (!imageData.length) imageData = UIImageJPEGRepresentation(image, 1.0f);
    NSString *filePath = [Global getFilePathFromTmp:imageName];
    [imageData writeToFile:filePath atomically:NO];
}

//获取图片
+ (UIImage*)getImage:(NSString*)imageName{
	return [UIImage imageWithContentsOfFile:imageName];
}

//从Document文件夹获取图片
+ (UIImage*)getImageFromDocument:(NSString*)imageName{
    NSString *imagePath = [Global getFilePathFromDocument:imageName];
    return [UIImage imageWithContentsOfFile:imagePath];
}

//从Tmp文件夹获取图片
+ (UIImage*)getImageFromTmp:(NSString*)imageName{
	NSString *imagePath = [Global getFilePathFromTmp:imageName];
	return [UIImage imageWithContentsOfFile:imagePath];
}

//裁剪图片
+ (UIImage*)croppedImage:(UIImage*)image inRect:(CGRect)bounds{
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, bounds);
    UIImage *thumb = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	return thumb;
}

//截图指定区域
+ (UIImage*)imageWithView:(UIView*)view frame:(CGRect)frame{
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//模糊图片, 例子 radius:30, tintColor:[UIColor colorWithWhite:1.0 alpha:0.3], saturationDeltaFactor:1.8
+ (UIImage*)blurImageWith:(UIImage*)image radius:(CGFloat)blurRadius tintColor:(UIColor*)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor{
    // check pre-conditions
    if (image.size.width < 1 || image.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", image.size.width, image.size.height, image);
        return nil;
    }
    if (!image.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", image);
        return nil;
    }
    CGRect imageRect = {CGPointZero, image.size};
    UIImage *effectImage = image;
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -image.size.height);
        CGContextDrawImage(effectInContext, imageRect, image.CGImage);
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        if (hasBlur) {
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1;
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped) effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (effectImageBuffersAreSwapped) effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    // set up output context
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -image.size.height);
    // draw base image
    CGContextDrawImage(outputContext, imageRect, image.CGImage);
    // draw effect image
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    // add in color tint
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    // output image is ready
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

//合并图片
+ (UIImage*)mergeImage:(UIImage*)baseImage smallImage:(UIImage*)smallImage point:(CGPoint)point{
	CGSize finalSize = [baseImage size];
	CGSize smallSize = [smallImage size];
	UIGraphicsBeginImageContext(finalSize);
	[baseImage drawInRect:CGRectMake(0, 0, finalSize.width, finalSize.height)];
	[smallImage drawInRect:CGRectMake(point.x, point.y, smallSize.width, smallSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

//角度旋转图片
+ (UIImage*)rotatedImage:(UIImage*)image degrees:(CGFloat)degrees{
	UIView *rotatedViewBox = [[UIView alloc]initWithFrame:CGRectMake(0, 0, image.size.height, image.size.width)];
	CGAffineTransform t = CGAffineTransformMakeRotation((M_PI*(degrees)/180.0));
	rotatedViewBox.transform = t;
	CGSize rotatedSize = rotatedViewBox.frame.size;
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, rotatedSize.width/2.0f, rotatedSize.height/2.0f);
	CGContextRotateCTM(context, (M_PI*(degrees)/180.0));
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextDrawImage(context, CGRectMake(-image.size.height/2.0f, -image.size.width/2.0f, image.size.height, image.size.width), image.CGImage);
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

//旋转图片
+ (UIImage*)rotatedImage:(UIImage*)image rotate:(CGFloat)rotate{
	CGAffineTransform t = CGAffineTransformMakeRotation(rotate);
	CGRect sizeRect = (CGRect){.size = image.size};
	CGRect destRect = CGRectApplyAffineTransform(sizeRect, t);
	CGSize rotatedSize = destRect.size;
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, rotatedSize.width/2.0f, rotatedSize.height/2.0f);
	CGContextRotateCTM(context, rotate);
	[image drawInRect:CGRectMake(-image.size.width/2.0f, -image.size.height/2.0f, image.size.width, image.size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

//去色
+ (UIImage*)grayImage:(UIImage*)image{
	int type = 1;
	CGImageRef imageRef = image.CGImage;
	size_t width  = CGImageGetWidth(imageRef);
	size_t height = CGImageGetHeight(imageRef);
	size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
	size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
	size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
	CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
	bool shouldInterpolate = CGImageGetShouldInterpolate(imageRef);
	CGColorRenderingIntent intent = CGImageGetRenderingIntent(imageRef);
	CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
	CFDataRef data = CGDataProviderCopyData(dataProvider);
	UInt8 *buffer = (UInt8*)CFDataGetBytePtr(data);
	NSUInteger x, y;
	for (y = 0; y < height; y++) {
		for (x = 0; x < width; x++) {
			UInt8 *tmp;
			tmp = buffer + y * bytesPerRow + x * 4;
			UInt8 red,green,blue;
			red = *(tmp + 0);
			green = *(tmp + 1);
			blue = *(tmp + 2);
			UInt8 brightness;
			switch (type) {
				case 1: //黑白
					brightness = (77 * red + 28 * green + 151 * blue) / 256;
					*(tmp + 0) = brightness;
					*(tmp + 1) = brightness;
					*(tmp + 2) = brightness;
					break;
				case 2:
					*(tmp + 0) = red;
					*(tmp + 1) = green * 0.7;
					*(tmp + 2) = blue * 0.4;
					break;
				case 3: //反色
					*(tmp + 0) = 255 - red;
					*(tmp + 1) = 255 - green;
					*(tmp + 2) = 255 - blue;
					break;
				default: //正常
					*(tmp + 0) = red;
					*(tmp + 1) = green;
					*(tmp + 2) = blue;
					break;
			}
		}
	}
	CFDataRef effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
	CGDataProviderRef effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
	CGImageRef effectedCgImage = CGImageCreate(width, height,
											   bitsPerComponent, bitsPerPixel, bytesPerRow,
											   colorSpace, bitmapInfo, effectedDataProvider,
											   NULL, shouldInterpolate, intent);
	UIImage *effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage];
	CGImageRelease(effectedCgImage);
	CFRelease(effectedDataProvider);
	CFRelease(effectedData);
	CFRelease(data);
	return effectedImage;
}

//动画UIImageView
+ (void)animateImage:(UIImageView*)imageView duration:(NSTimeInterval)time repeat:(NSInteger)repeat images:(UIImage*)image,...{
	NSMutableArray *array = [NSMutableArray array];
	[array addObject:image];
	id obj;
	va_list args;
	va_start(args, image);
	while ((obj = va_arg(args, id))) {
		[array addObject:obj];
	}
	va_end(args);
	imageView.animationImages = [NSArray arrayWithArray:array]; //图片帧
	imageView.animationDuration = time; //动画时间
	imageView.animationRepeatCount = repeat; //重复次数,0表示无限重复
	[imageView startAnimating]; //开始动画
}

#pragma mark - FSO
//获取完整文件名(带后缀名)
+ (NSString*)getFileFullname:(NSString*)filePath{
	return [filePath getFullFilename];
}

//获取文件名(不带后缀名)
+ (NSString*)getFilename:(NSString*)filePath{
	return [filePath getFilename];
}

//获取后缀名
+ (NSString*)getSuffix:(NSString*)filePath{
	return [filePath getSuffix];
}

//获取Document文件夹路径
+ (NSString*)getDocument{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

//获取Tmp文件夹路径
+ (NSString*)getTmp{
	return NSTemporaryDirectory();
}

//获取Library/Caches文件夹路径
+ (NSString*)getCaches{
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	return [path objectAtIndex:0];
}

//从Document获取文件路径
+ (NSString*)getFilePathFromDocument:(NSString*)filename{
	NSString *documentPath = [Global getDocument];
	return [documentPath stringByAppendingPathComponent:filename];
}

//从Tmp获取文件路径
+ (NSString*)getFilePathFromTmp:(NSString*)filename{
	NSString *tempPath = NSTemporaryDirectory();
	return [tempPath stringByAppendingPathComponent:filename];
}

//从Library/Caches获取文件路径
+ (NSString*)getFilePathFromCaches:(NSString*)filename{
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachePath = [path objectAtIndex:0];
	return [cachePath stringByAppendingPathComponent:filename];
}

//从APP内部获取文件
+ (NSString*)getFilePathFromAPP:(NSString*)filename{
	return [[NSBundle mainBundle] pathForResource:filename ofType:nil];
}

//获取指定文件的内容
+ (NSData*)getFileData:(NSString*)filePath{
	return [NSData dataWithContentsOfFile:filePath];
}

//从Document获取指定文件的内容
+ (NSData*)getFileDataFromDocument:(NSString*)filename{
	return [Global getFileData:[Global getFilePathFromDocument:filename]];
}

//从Tmp获取指定文件的内容
+ (NSData*)getFileDataFromTmp:(NSString*)filename{
	return [Global getFileData:[Global getFilePathFromTmp:filename]];
}

//从Library/Caches获取指定文件的内容
+ (NSData*)getFileDataFromCaches:(NSString*)filename{
	return [Global getFileData:[Global getFilePathFromCaches:filename]];
}

//获取指定文件的字符串内容
+ (NSString*)getFileText:(NSString*)filePath{
	return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
}

//从Document获取指定文件的字符串内容
+ (NSString*)getFileTextFromDocument:(NSString*)filename{
	return [Global getFileText:[Global getFilePathFromDocument:filename]];
}

//从Tmp获取指定文件的字符串内容
+ (NSString*)getFileTextFromTmp:(NSString*)filename{
	return [Global getFileText:[Global getFilePathFromTmp:filename]];
}

//从Library/Caches获取指定文件的字符串内容
+ (NSString*)getFileTextFromCaches:(NSString*)filename{
	return [Global getFileText:[Global getFilePathFromCaches:filename]];
}

//获取文件列表
+ (NSArray*)getFileList:(NSString*)folderPath{
	return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
}

//获取Document文件列表
+ (NSArray*)getFileListFromDocument{
	return [Global getFileList:[Global getDocument]];
}

//获取Document文件列表
+ (NSArray*)getFileListFromTmp{
	return [Global getFileList:[Global getTmp]];
}

//获取Document文件列表
+ (NSArray*)getFileListFromCaches{
	return [Global getFileList:[Global getCaches]];
}

//判断文件是否存在
+ (BOOL)fileExist:(NSString*)filePath{
    return [[NSFileManager defaultManager] fileExistsAtPath:[Global replace:@"\\" to:@"/" from:filePath]];
}

//判断Document里某文件是否存在
+ (BOOL)fileExistFromDocument:(NSString*)filename{
	return [[NSFileManager defaultManager] fileExistsAtPath:[Global getFilePathFromDocument:filename]];
}

//判断Document里某文件是否存在
+ (BOOL)fileExistFromTmp:(NSString*)filename{
	return [[NSFileManager defaultManager] fileExistsAtPath:[Global getFilePathFromTmp:filename]];
}

//判断Document里某文件是否存在
+ (BOOL)fileExistFromCaches:(NSString*)filename{
	return [[NSFileManager defaultManager] fileExistsAtPath:[Global getFilePathFromCaches:filename]];
}

//判断APP里某文件是否存在
+ (BOOL)fileExistFromAPP:(NSString*)filename{
	return [[NSFileManager defaultManager] fileExistsAtPath:[Global getFilePathFromAPP:filename]];
}

//判断文件夹是否存在
+ (BOOL)folderExist:(NSString*)folderPath{
    folderPath = [Global replace:@"\\" to:@"/" from:folderPath];
    BOOL isDir;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isDir];
    return (existed==YES && isDir==YES);
}

//生成文件夹,支持多级生成
+ (BOOL)makeDir:(NSString*)folderPath{
    folderPath = [Global replace:@"\\" to:@"/" from:folderPath];
    if (![Global folderExist:folderPath]) {
        NSError *error;
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) NSLog(@"%@",error);
        return result;
    }
    return YES;
}

//在Document生成文件夹
+ (BOOL)makeDirFromDocument:(NSString*)foldername{
	foldername = [Global replace:@"\\" to:@"/" from:foldername];
	NSString *path = [Global getFilePathFromDocument:foldername];
	return [Global makeDir:path];
}

//在Tmp生成文件夹
+ (BOOL)makeDirFromTmp:(NSString*)foldername{
	foldername = [Global replace:@"\\" to:@"/" from:foldername];
	NSString *path = [Global getFilePathFromTmp:foldername];
	return [Global makeDir:path];
}

//在Library/Caches生成文件夹
+ (BOOL)makeDirFromCaches:(NSString*)foldername{
	foldername = [Global replace:@"\\" to:@"/" from:foldername];
	NSString *path = [Global getFilePathFromCaches:foldername];
	return [Global makeDir:path];
}

//清空文件夹, killme:是否同时删除自己
+ (void)deleteDir:(NSString*)folderPath killme:(BOOL)kill{
    folderPath = [Global replace:@"\\" to:@"/" from:folderPath];
    if ([Global folderExist:folderPath]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:folderPath error:NULL];
        NSEnumerator *e = [contents objectEnumerator];
        NSString *filename;
        while ((filename = [e nextObject])) {
            [fileManager removeItemAtPath:[folderPath stringByAppendingPathComponent:filename] error:NULL];
        }
        if (kill) [fileManager removeItemAtPath:folderPath error:nil];
    }
}

//在Document清空文件夹, killme:是否同时删除自己
+ (void)deleteDirFromDocument:(NSString*)foldername killme:(BOOL)kill{
    [Global deleteDir:[Global getFilePathFromDocument:foldername] killme:kill];
}

//在Tmp清空文件夹, killme:是否同时删除自己
+ (void)deleteDirFromTmp:(NSString*)foldername killme:(BOOL)kill{
	[Global deleteDir:[Global getFilePathFromTmp:foldername] killme:kill];
}

//在Library/Caches清空文件夹, killme:是否同时删除自己
+ (void)deleteDirFromCaches:(NSString*)foldername killme:(BOOL)kill{
	[Global deleteDir:[Global getFilePathFromCaches:foldername] killme:kill];
}

//生成文件,NSData内容
+ (BOOL)saveFile:(NSString*)filePath data:(NSData*)fileData{
	if ([Global fileExist:filePath]) return YES;
	NSArray *array = [Global split:filePath with:@"/"];
	[Global makeDir:[Global replace:array[array.count-1] to:@"" from:filePath]];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	return [fileManager createFileAtPath:filePath contents:fileData attributes:nil];
}

//在Document生成文件,NSData内容
+ (BOOL)saveFileToDocument:(NSString*)filename data:(NSData*)fileData{
    return [Global saveFile:[Global getFilePathFromDocument:filename] data:fileData];
}

//在Tmp生成文件,NSData内容
+ (BOOL)saveFileToTmp:(NSString*)filename data:(NSData*)fileData{
	return [Global saveFile:[Global getFilePathFromTmp:filename] data:fileData];
}

//在Library/Caches生成文件,NSData内容
+ (BOOL)saveFileToCaches:(NSString*)filename data:(NSData*)fileData{
	return [Global saveFile:[Global getFilePathFromCaches:filename] data:fileData];
}

//生成文件,NSString内容
+ (BOOL)saveFile:(NSString*)filePath content:(NSString*)content new:(BOOL)flag{
	if (![Global fileExist:filePath] || flag) {
		NSArray *array = [Global split:filePath with:@"/"];
		[Global makeDir:[Global replace:array[array.count-1] to:@"" from:filePath]];
        return [[content dataUsingEncoding:NSUTF8StringEncoding] writeToFile:filePath atomically:YES];
    }
    NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
    //找到并定位到outFile的末尾位置(在此后追加文件)
    [outFile seekToEndOfFile];
    //读取inFile并且将其内容写到outFile中
    NSData *buffer = [content dataUsingEncoding:NSUTF8StringEncoding];
    [outFile writeData:buffer];
    [outFile closeFile];
    return YES;
}

//在Document生成文件,NSString内容
+ (BOOL)saveFileToDocument:(NSString*)filename content:(NSString*)content new:(BOOL)flag{
    return [Global saveFile:[Global getFilePathFromDocument:filename] content:content new:flag];
}

//在Tmp生成文件,NSString内容
+ (BOOL)saveFileToTmp:(NSString*)filename content:(NSString*)content new:(BOOL)flag{
	return [Global saveFile:[Global getFilePathFromTmp:filename] content:content new:flag];
}

//在Library/Caches生成文件,NSString内容
+ (BOOL)saveFileToCaches:(NSString*)filename content:(NSString*)content new:(BOOL)flag{
	return [Global saveFile:[Global getFilePathFromCaches:filename] content:content new:flag];
}

//修改文件夹名
+ (void)renameFolder:(NSString*)folderPath to:(NSString*)newName{
	[Global renameFile:folderPath to:newName];
}

//修改文件名
+ (void)renameFile:(NSString*)filePath to:(NSString*)newName{
	if ([Global fileExist:filePath]) {
		NSArray *pathArr = [Global split:filePath with:@"/"];
		NSString *newPath = [NSString stringWithFormat:@"%@%@", [filePath replace:pathArr.lastObject to:@""], newName];
		[[NSFileManager defaultManager] moveItemAtPath:filePath toPath:newPath error:nil];
	}
}

//删除文件
+ (BOOL)deleteFile:(NSString*)filePath{
    if ([Global fileExist:filePath]) {
        return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    return NO;
}

//在Document删除文件
+ (BOOL)deleteFileFromDocument:(NSString*)filename{
    return [Global deleteFile:[Global getFilePathFromDocument:filename]];
}

//在Tmp删除文件
+ (BOOL)deleteFileFromTmp:(NSString*)filename{
	return [Global deleteFile:[Global getFilePathFromTmp:filename]];
}

//在Library/Caches删除文件
+ (BOOL)deleteFileFromCaches:(NSString*)filename{
	return [Global deleteFile:[Global getFilePathFromCaches:filename]];
}

//获取文件大小
+ (long long)fileSize:(NSString*)filePath{
    if ([Global fileExist:filePath]) {
        NSFileManager *manager = [NSFileManager defaultManager];
        NSDictionary *attributes = [manager attributesOfItemAtPath:filePath error:nil];
        //NSLog(@"%@",attributes);
        NSNumber *fileSize = [attributes objectForKey:NSFileSize];
        return [fileSize longLongValue];
    }
    return 0;
}

//获取目录所占空间大小
+ (long long)folderSize:(NSString*)folderPath{
    if (![Global fileExist:folderPath]) return 0;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSEnumerator *childFiles = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString *filename;
    long long size = 0;
    while ((filename = [childFiles nextObject]) != nil){
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:filename];
        size += [Global fileSize:fileAbsolutePath];
    }
    return size;
}

//格式化文件大小, %.2f 保留两位小数, %02d 不足两位即前面补0
+ (NSString*)formatSize:(long long)size unit:(NSString*)unit{
	if (!unit.length) {
        if (size>0) {
            if (size>1073741824) {
                return [NSString stringWithFormat:@"%0.2fGB", (CGFloat)size/1073741824];
            } else if (size>1048576) {
                return [NSString stringWithFormat:@"%0.2fMB", (CGFloat)size/1048576];
            } else if (size>1024) {
                return [NSString stringWithFormat:@"%0.0fKB", (CGFloat)size/1024];
            } else {
                return [NSString stringWithFormat:@"%llubytes", size];
            }
        }
    } else {
        if (size>0) {
            NSArray *unitName = @[@"GB", @"MB", @"KB"];
            NSInteger index = [unitName indexOfObject:unit];
            switch (index) {
                case 0:
                    return [NSString stringWithFormat:@"%0.2fGB", (CGFloat)size/1073741824];
                    break;
                case 1:
                    return [NSString stringWithFormat:@"%0.2fMB", (CGFloat)size/1048576];
                    break;
                case 2:
                    return [NSString stringWithFormat:@"%0.0fKB", (CGFloat)size/1024];
                    break;
                default:
                    return [NSString stringWithFormat:@"%llubytes", size];
                    break;
            }
        }
    }
    return @"0KB";
}

//获取文件(夹)属性
+ (NSMutableDictionary*)fileAttributes:(NSString*)filePath{
	NSMutableDictionary *attributes = [[NSMutableDictionary alloc]init];
	if ([Global fileExist:filePath]) {
		NSError *error = nil;
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
		if (fileAttributes != nil) {
			id fileType = [fileAttributes objectForKey:NSFileType];
			NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];
			NSString *fileOwner = [fileAttributes objectForKey:NSFileOwnerAccountName];
			NSDate *fileModDate = [fileAttributes objectForKey:NSFileModificationDate];
			NSDate *fileCreateDate = [fileAttributes objectForKey:NSFileCreationDate];
			if (fileSize) { //单位字节
				[attributes setObject:fileSize forKey:@"size"]; //[fileSize unsignedLongLongValue]
			}
			if (fileOwner) {
				[attributes setObject:fileOwner forKey:@"owner"];
			}
			if (fileModDate) {
				fileModDate = [Global localDate:fileModDate];
				[attributes setObject:fileModDate forKey:@"moddate"];
			}
			if (fileCreateDate) {
				fileCreateDate = [Global localDate:fileCreateDate];
				[attributes setObject:fileCreateDate forKey:@"createdate"];
			}
		}
	}
	return attributes;
}

//获取本地Array类型Plist文件
+ (NSMutableArray*)getPlistArray:(NSString*)filename{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
	return [[NSMutableArray alloc]initWithContentsOfFile:filePath];
}

//获取本地Dictionary类型Plist文件
+ (NSMutableDictionary*)getPlistDictionary:(NSString*)filename{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
	return [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
}

//从Tmp获取Array类型Plist文件
+ (NSMutableArray*)getPlistArrayFromTmp:(NSString*)filename{
	NSString *filePath = [Global getFilePathFromTmp:[NSString stringWithFormat:@"%@.plist",filename]];
	return [[NSMutableArray alloc]initWithContentsOfFile:filePath];
}

//从Tmp获取Dictionary类型Plist文件
+ (NSMutableDictionary*)getPlistDictionaryFromTmp:(NSString*)filename{
	NSString *filePath = [Global getFilePathFromTmp:[NSString stringWithFormat:@"%@.plist",filename]];
	return [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
}

//保存Plist文件
+ (BOOL)savePlist:(NSString*)filePath data:(id)data{
	NSString *error;
	NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:data
																   format:NSPropertyListXMLFormat_v1_0
														 errorDescription:&error];
	if (plistData) {
		return [plistData writeToFile:filePath atomically:YES];
	} else {
		NSLog(@"%@",error);
		return NO;
	}
}

//保存Plist文件到Document
+ (BOOL)savePlistToDocument:(NSString*)filename data:(id)data{
	NSString *filePath = [Global getFilePathFromDocument:[NSString stringWithFormat:@"%@.plist",filename]];
	return [Global savePlist:filePath data:data];
}

//保存Plist文件到Tmp
+ (BOOL)savePlistToTmp:(NSString*)filename data:(id)data{
	NSString *filePath = [Global getFilePathFromTmp:[NSString stringWithFormat:@"%@.plist",filename]];
	return [Global savePlist:filePath data:data];
}

//保存Plist文件到Caches
+ (BOOL)savePlistToCaches:(NSString*)filename data:(id)data{
	NSString *filePath = [Global getFilePathFromCaches:[NSString stringWithFormat:@"%@.plist",filename]];
	return [Global savePlist:filePath data:data];
}

#pragma mark - 字符串
//自动宽度
+ (CGSize)autoWidth:(NSString*)str font:(UIFont*)font height:(CGFloat)height{
	return [str autoWidth:font height:height];
}

//自动高度
+ (CGSize)autoHeight:(NSString*)str font:(UIFont*)font width:(CGFloat)width{
	return [str autoHeight:font width:width];
}

//最小字体
+ (void)minFontSizeWith:(UILabel*)label minScale:(CGFloat)scale{
	//设置最小字体及自适应宽度
	label.minimumScaleFactor = scale;
	label.adjustsFontSizeToFitWidth = YES;
}

//全小写
+ (NSString*)strtolower:(NSString*)str{
	return [str strtolower];
}

//全大写
+ (NSString*)strtoupper:(NSString*)str{
	return [str strtoupper];
}

//各单词首字母大写
+ (NSString*)strtoupperFirst:(NSString*)str{
	return [str strtoupperFirst];
}

//清除首尾空格
+ (NSString*)trim:(NSString*)string{
	return [string trim];
}

//清除首尾指定字符串
+ (NSString*)trim:(NSString*)string assign:(NSString*)assign{
	return [string trim:assign];
}

//一个字符串搜索另一个字符串
+ (NSInteger)indexOf:(NSString*)origin search:(NSString*)str{
	return [origin indexOf:str];
}

//替换字符串
+ (NSString*)replace:(NSString*)r1 to:(NSString*)r2 from:(NSString*)original{
    return [original replace:r1 to:r2];
}

//截取字符串
+ (NSString*)substr:(NSString*)string start:(NSUInteger)start length:(NSUInteger)length{
    return [string substr:start length:length];
}

//截取字符串,从指定位置开始到最后,负数:从字符串结尾的指定位置开始
+ (NSString*)substr:(NSString*)string start:(NSUInteger)start{
	return [string substr:start];
}

//从左边开始截取字符串
+ (NSString*)left:(NSString*)string length:(NSUInteger)length{
	return [string left:length];
}

//从右边开始截取字符串
+ (NSString*)right:(NSString*)string length:(NSUInteger)length{
	return [string right:length];
}

//数值转字符串且设置前导零,length:总位数
+ (NSString*)fillZero:(NSInteger)integer length:(NSInteger)length{
	NSMutableString *string = [[NSMutableString alloc]init];
	for (NSInteger i=0; i<length; i++) {
		[string appendString:@"0"];
	}
	[string appendFormat:@"%ld",(long)integer];
	NSString *str = [NSString stringWithFormat:@"%@",string];
	str = [Global right:str length:length];
	return str;
}

//获取中英文混编的字符串长度
+ (NSInteger)fontLength:(NSString*)str{
	return [str fontLength];
}

//截取所需字符串
//cropHtml(HTML代码, 所需代码前面的特征代码[会被去除], 所需代码末尾的特征代码[会被去除])
//得到代码后请自行使用str_replace所需代码部分中不需要的代码
+ (NSString*)cropHtml:(NSString*)webHtml startStr:(NSString*)startStr overStr:(NSString*)overStr{
	return [webHtml cropHtml:startStr overStr:overStr];
}

//删除例如 [xxxx] 组合的字符串段落
+ (NSString*)deleteStringPart:(NSString*)string prefix:(NSString*)prefix suffix:(NSString*)suffix{
	return [string deleteStringPart:prefix suffix:suffix];
}

//判断是否是Emoji表情
+ (BOOL)isEmoji:(NSString*)string{
	return [string isEmoji];
}

//URL编码
+ (NSString*)URLEncode:(NSString*)string{
	return [string URLEncode:NSUTF8StringEncoding];
}

//URL编码,可设置字符编码
+ (NSString*)URLEncode:(NSString*)string encoding:(NSStringEncoding)encoding{
	return [string URLEncode:encoding];
}

//URL解码
+ (NSString*)URLDecode:(NSString*)string{
	return [string URLDecode:NSUTF8StringEncoding];
}

//URL解码,可设置字符编码
+ (NSString*)URLDecode:(NSString*)string encoding:(NSStringEncoding)encoding{
	return [string URLDecode:encoding];
}

//NSString转Base64
+ (NSString*)stringToBase64:(NSString*)string{
	return [string base64];
}

//NSData转Base64
+ (NSString*)dataToBase64:(NSData*)data{
	if (data.length == 0)return @"";
	static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	char *characters = malloc(((data.length + 2) / 3) * 4);
	if (characters == NULL) return nil;
	NSUInteger length = 0;
	NSUInteger i = 0;
	while (i < data.length){
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < data.length) buffer[bufferLength++] = ((char *)[data bytes])[i++];
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';
	}
	return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

//Base64转NSString
+ (NSString*)base64ToString:(NSString*)base64{
	return [base64 base64ToString];
}

//Base64转NSData
+ (NSData*)base64ToData:(NSString*)base64{
	return [base64 base64ToData];
}

//NSString转MD5
+ (NSString*)stringToMD5:(NSString*)string{
	return [string md5];
}

//NSString转sha1
+ (NSString*)stringToSHA1:(NSString*)string{
	return [string sha1];
}

#pragma mark - 数组
//分割字符串转为数组
+ (NSMutableArray*)split:(NSString*)string with:(NSString*)symbol{
    NSArray *array = [string componentsSeparatedByString:symbol];
    return [NSMutableArray arrayWithArray:array];
}

//数组转字符串
+ (NSString*)implode:(NSArray*)array with:(NSString*)symbol{
	return [array componentsJoinedByString:symbol];
}

#pragma mark - 正则表达式
//正则表达式test
+ (BOOL)preg_test:(NSString*)string patton:(NSString*)patton{
	NSMutableArray *matcher = [Global preg_match:string patton:patton];
	return matcher.count>0;
}

//正则表达式replace
+ (NSString*)preg_replace:(NSString*)string patton:(NSString*)patton with:(NSString*)templateStr{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patton
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSString *modified = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:templateStr];
    return modified;
}

//正则表达式match
+ (NSMutableArray*)preg_match:(NSString*)string patton:(NSString*)patton{
    NSMutableArray *matcher = [[NSMutableArray alloc]init];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patton
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    //NSLog(@"%@", matches);
    for (NSTextCheckingResult *match in matches) {
		NSMutableArray *t = [[NSMutableArray alloc]init];
		for (NSInteger i=1; i<=match.numberOfRanges-1; i++) {
			if ([match rangeAtIndex:i].length) {
				[t addObject:[string substringWithRange:[match rangeAtIndex:i]]];
			} else {
				[t addObject:@""];
			}
		}
		NSString *value = [string substringWithRange:match.range];
		NSDictionary *m = @{@"value":value, @"matches":t};
        [matcher addObject:m];
    }
    return matcher;
}

//验证邮箱
+ (BOOL)isEmail:(NSString*)string{
    NSString *re = @"^(\\w)+(\\.\\w+)*@(\\w)+((\\.\\w+)+)$";
	NSPredicate *matcher = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", re];
	return [matcher evaluateWithObject:string];
}

//验证手机号码
+ (BOOL)isMobile:(NSString*)string{
	NSString *re = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
	NSPredicate *matcher = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", re];
	return [matcher evaluateWithObject:string];
}

#pragma mark - JSON
//Json字符串转Dictionary、Array
+ (id)formatJson:(NSString*)jsonString{
    return [jsonString formatJson];
}

//Dictionary/Array转Json字符串
+ (NSString*)jsonString:(id)data{
	return [data jsonString];
}

#pragma mark - NETWORK
//GET提交(不执行返回操作)
+ (void)get:(NSString*)url{
    [Global get:url data:nil completion:nil fail:nil];
}

//GET提交
+ (void)get:(NSString*)url data:(NSDictionary*)data completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	[Global get:url data:data timeout:5 completion:completion fail:fail];
}

//POST提交
+ (void)post:(NSString*)url data:(NSDictionary*)data completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	[Global post:url data:data timeout:5 completion:completion fail:fail];
}

//上传提交
+ (void)upload:(NSString*)url data:(NSDictionary*)data completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	[Global upload:url data:data timeout:20 completion:completion fail:fail];
}

//POST提交(判断是否有文件上传)
+ (void)postAuto:(NSString*)url data:(NSDictionary*)data completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	BOOL formData = NO;
	if (data.count) {
		for (NSString *key in data) {
			if ([data[key] isKindOfClass:[UIImage class]] || [data[key] isKindOfClass:[NSData class]]) {
				formData = YES;
				break;
			}
		}
	}
	if (!formData) {
		[Global post:url data:data completion:completion fail:fail];
	} else {
		[Global upload:url data:data completion:completion fail:fail];
	}
}

//POST提交,可设置超时时间(判断是否有文件上传)
+ (void)postAuto:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	BOOL formData = NO;
	if (data.count) {
		for (NSString *key in data) {
			if ([data[key] isKindOfClass:[UIImage class]] || [data[key] isKindOfClass:[NSData class]]) {
				formData = YES;
				break;
			}
		}
	}
	if (!formData) {
		[Global post:url data:data timeout:timeout completion:completion fail:fail];
	} else {
		[Global upload:url data:data timeout:timeout completion:completion fail:fail];
	}
}

//GET提交,可设置超时时间
+ (void)getGlobal:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	NSString *postUrl = [url copy];
	NSMutableDictionary *datas = [NSMutableDictionary dictionaryWithDictionary:data];
	if ([url.element[@"retry"] isset]) {
		url.element[@"retry"] = @([url.element[@"retry"]integerValue]-1);
	} else {
		url.element[@"retry"] = @3;
	}
	NSString *postData = @"";
    if (data.count) {
		NSMutableArray *param = [[NSMutableArray alloc]init];
		for (NSString *key in data) {
			[param addObject:key];
			[param addObject:[[NSString stringWithFormat:@"%@", data[key]] dataUsingEncoding:NSUTF8StringEncoding]];
		}
        postData = [param componentsJoinedByString:@"&"];
        NSRange range = [postUrl rangeOfString:@"?"];
        if ([postUrl substringFromIndex:NSMaxRange(range)]) postData = [NSString stringWithFormat:@"?%@", postData];
    }
    postUrl = [NSString stringWithFormat:@"%@%@", postUrl, postData];
    postUrl = [postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeout];
	[request setHTTPMethod:@"GET"];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
    //NSURLSession *session = [NSURLSession sharedSession];
    //NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
			NSLog(@"Httperror:%@ Errorcode:%ld\n%@", error.localizedDescription, (long)error.code, postUrl);
			if (error.code==-1001) {
				if ([url.element[@"retry"]integerValue]>1) {
					[Global get:url data:datas timeout:timeout completion:completion fail:fail];
					return;
				}
				[ProgressHUD showTrouble:@"网络超时"];
			}
			//error.code==-1003 //未能找到使用指定主机名的服务器
			if (error.code==-1005) [ProgressHUD showTrouble:@"网络不稳定，请重试"]; //网络连接已中断
            if (fail) {
				dispatch_async(dispatch_get_main_queue(), ^{
                    fail(error.localizedDescription, error.code);
                });
            }
		} else {
			NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
			NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
            if (responseCode>=200 && responseCode<300) {
                if (completion) {
					dispatch_async(dispatch_get_main_queue(), ^{
                        completion(result);
                    });
                }
			} else {
				NSLog(@"Httperror:%@ Errorcode:%ld\n%@", result, (long)responseCode, postUrl);
                if (fail) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        fail(result, responseCode);
                    });
                }
            }
        }
    }];
	//[dataTask resume];
}

//POST提交,可设置超时时间
+ (void)postGlobal:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	NSString *postUrl = [url copy];
    NSData *postData = [NSData data];
	if (data.isDictionary) {
		NSMutableArray *param = [[NSMutableArray alloc]init];
		for (NSString *key in data) {
			[param addObject:[NSString stringWithFormat:@"%@=%@", key, [data[key] jsonString]]];
		}
        postData = [[param componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    }
    postUrl = [postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%ld", (unsigned long)postData.length];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeout];
    [request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Mozilla/4.0 (compatible; OpenOffice.org)" forHTTPHeaderField:@"User-Agent"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
    //NSURLSession *session = [NSURLSession sharedSession];
    //NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
			NSLog(@"Httperror:%@ Errorcode:%ld\n%@", error.localizedDescription, (long)error.code, postUrl);
			if (error.code==-1001) [ProgressHUD showTrouble:@"网络超时"];
			if (error.code==-1005) [ProgressHUD showTrouble:@"网络不稳定，请重试"];
            if (fail) {
				dispatch_async(dispatch_get_main_queue(), ^{
                    fail(error.localizedDescription, error.code);
                });
            }
		} else {
			NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
            if (responseCode>=200 && responseCode<300) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(result);
                    });
                }
			} else {
				NSLog(@"Httperror:%@ Errorcode:%ld\n%@", result, (long)responseCode, postUrl);
                if (fail) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        fail(result, responseCode);
                    });
                }
            }
        }
    }];
    //[dataTask resume];
}

//上传提交,可设置超时时间
+ (void)uploadGlobal:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	NSString *postUrl = [url copy];
	NSInteger count = 0;
	for (NSString *key in data) {
		if ([data[key] isKindOfClass:[UIImage class]] || [data[key] isKindOfClass:[NSData class]]) count++;
	}
	if (!count) count = 1;
	timeout = timeout * count;
    postUrl = [postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeout];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"----WebKitFormBoundaryEmJo8eX0Rq7BDl9l";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    NSMutableData *body = [NSMutableData data];
	int i = 1;
	for (NSString *key in data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        if ([data[key] isKindOfClass:[UIImage class]]) {
			UIImage *post = data[key];
			NSData *imageData = [post imageToData];
			NSString *suffix = [post imageSuffix];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%d.%@\"\r\nContent-Type: application/octet-stream\r\n\r\n", key, i, suffix] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[NSData dataWithData:imageData]];
        } else if ([data[key] isKindOfClass:[NSData class]]) {
            NSData *post = data[key];
            NSArray *postArr = [[NSString stringWithFormat:@"%@", key] componentsSeparatedByString:@"."];
            NSString *prefix = postArr[0];
            NSString *suffix = postArr[1];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%d.%@\"\r\nContent-Type: application/octet-stream\r\n\r\n", prefix, i, suffix] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[NSData dataWithData:post]];
        } else {
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[data[key] jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        i++;
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
    //NSURLSession *session = [NSURLSession sharedSession];
    //NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
			NSLog(@"Httperror:%@ Errorcode:%ld\n%@", error.localizedDescription, (long)error.code, postUrl);
			if (error.code==-1001) [ProgressHUD showTrouble:@"网络超时"];
			if (error.code==-1005) [ProgressHUD showTrouble:@"网络不稳定，请重试"];
            if (fail) {
				dispatch_async(dispatch_get_main_queue(), ^{
                    fail(error.localizedDescription, error.code);
                });
            }
		} else {
			NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
			NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
            if (responseCode>=200 && responseCode<300) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(result);
                    });
                }
			} else {
				NSLog(@"Httperror:%@ Errorcode:%ld\n%@", result, (long)responseCode, postUrl);
                if (fail) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        fail(result, responseCode);
                    });
                }
            }
        }
    }];
    //[dataTask resume];
}

//GET提交,可设置超时时间(timeout==[-1不限制, 0默认60秒, >0自定义秒数])
+ (void)get:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	NSString *postUrl = [url copy];
	NSMutableDictionary *datas = [NSMutableDictionary dictionaryWithDictionary:data];
	if ([url.element[@"retry"] isset]) {
		url.element[@"retry"] = @([url.element[@"retry"]integerValue]-1);
	} else {
		url.element[@"retry"] = @3;
	}
	AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
	manager.requestSerializer = [AFHTTPRequestSerializer serializer];
	if (timeout==-1) {
		manager.requestSerializer.timeoutInterval = INFINITY;
	} else if (timeout>0) {
		manager.requestSerializer.timeoutInterval = timeout;
	}
	//manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	[manager GET:postUrl parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), ^{
				NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
				completion(result);
			});
		}
	} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"Httperror:%@ Errorcode:%ld\n%@", error.localizedDescription, (long)error.code, postUrl);
			NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
			if (error.code==-1001) {
				if ([url.element[@"retry"]integerValue]>1) {
					[Global get:url data:datas timeout:timeout completion:completion fail:fail];
					return;
				}
				[ProgressHUD showTrouble:@"网络超时"];
			}
			//error.code==-1003 //未能找到使用指定主机名的服务器
			if (error.code==-1005) [ProgressHUD showTrouble:@"网络不稳定，请重试"];
			if (fail) fail(error.localizedDescription, error.code);
		});
	}];
}

//POST提交,可设置超时时间(timeout==[-1不限制, 0默认60秒, >0自定义秒数])
+ (void)post:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	return [Global post:url data:data type:nil timeout:timeout completion:completion fail:fail];
}
+ (void)postJSON:(NSString*)url data:(id)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	return [Global post:url data:data type:@"json" timeout:timeout completion:completion fail:fail];
}
+ (void)post:(NSString*)url data:(id)data type:(NSString*)type timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	NSString *postUrl = [url copy];
	AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
	manager.requestSerializer = [type isEqualToString:@"json"] ? [AFJSONRequestSerializer serializer] : [AFHTTPRequestSerializer serializer];
	if (timeout==-1) {
		manager.requestSerializer.timeoutInterval = INFINITY;
	} else if (timeout>0) {
		manager.requestSerializer.timeoutInterval = timeout;
	}
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	[manager POST:postUrl parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), ^{
				NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
				completion(result);
			});
		}
	} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"Httperror:%@ Errorcode:%ld\n%@", error.localizedDescription, (long)error.code, postUrl);
			NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
			if (error.code==-1001) [ProgressHUD showTrouble:@"网络超时"];
			if (error.code==-1005) [ProgressHUD showTrouble:@"网络不稳定，请重试"];
			if (fail) fail(error.localizedDescription, error.code);
		});
	}];
}

//上传提交,可设置超时时间(timeout==[-1不限制, 0默认60秒, >0自定义秒数])
+ (void)upload:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	NSString *postUrl = [url copy];
	NSInteger count = 0;
	NSMutableDictionary *datas = [NSMutableDictionary dictionaryWithDictionary:data];
	for (NSString *key in data) {
		if ([data[key] isKindOfClass:[UIImage class]] || [data[key] isKindOfClass:[NSData class]]) {
			count++;
		} else {
			[datas setObject:data[key] forKey:key];
		}
	}
	if (!count) count = 1;
	timeout = timeout * count;
	AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
	manager.requestSerializer = [AFHTTPRequestSerializer serializer];
	if (timeout==-1) {
		manager.requestSerializer.timeoutInterval = INFINITY;
	} else if (timeout>0) {
		manager.requestSerializer.timeoutInterval = timeout;
	}
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	[manager POST:postUrl parameters:datas constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
		for (NSString *key in data) {
			if ([data[key] isKindOfClass:[UIImage class]]) {
				UIImage *post = data[key];
				NSData *imageData = post.imageToData;
				NSString *suffix = post.imageSuffix;
				NSString *mimeType = post.imageMimeType;
				[formData appendPartWithFileData:imageData name:key fileName:STRINGFORMAT(@"%@.%@", key, suffix) mimeType:mimeType];
			} else if ([data[key] isKindOfClass:[NSData class]]) {
				NSData *post = data[key];
				NSArray *postArr = [key componentsSeparatedByString:@"."];
				NSString *name = postArr[0];
				NSString *mimeType = post.imageMimeType;
				[formData appendPartWithFileData:post name:name fileName:key mimeType:mimeType];
			}
		}
	} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), ^{
				NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
				completion(result);
			});
		}
	} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"Httperror:%@ Errorcode:%ld\n%@", error.localizedDescription, (long)error.code, postUrl);
			NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
			if (error.code==-1001) [ProgressHUD showTrouble:@"网络超时"];
			if (error.code==-1005) [ProgressHUD showTrouble:@"网络不稳定，请重试"];
			if (fail) fail(error.localizedDescription, error.code);
		});
	}];
}

//下载网络图片
+ (void)downloadImage:(NSString*)url completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist))completion{
	[Global downloadImage:url size:CGSizeZero completion:completion];
}

//下载网络图片,且直接缩放
+ (void)downloadImage:(NSString*)url size:(CGSize)size completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist))completion{
	if (!url.length) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (completion) completion(nil, nil, NO);
		});
		return;
	}
	if ([url indexOf:@"://"]==NSNotFound) url = [NSString stringWithFormat:@"%@%@", API_URL, url];
	[FileDownloader downloadWithUrl:url completion:^(NSData *data, BOOL exist) {
		UIImage *image = [UIImage imageWithData:data];
		if (size.width) image = [image fitToSize:size];
		if (completion) completion(image, size.width ? [image imageToData] : data, YES);
	} fail:^(NSString *description, NSInteger code) {
		if (code == 404) [ProgressHUD showError:@"图片不存在"];
		if (completion) completion(nil, nil, NO);
	}];
}

//直接下载网络图片到指定路径
+ (void)downloadImageToPath:(NSString*)savePath url:(NSString*)url completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist))completion{
	if (!savePath.length || !url.length) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (completion) completion(nil, nil, NO);
		});
		return;
	}
	if ([Global fileExist:savePath]) {
		if (completion) completion([Global getImage:savePath], [Global getFileData:savePath], YES);
		return;
	}
	[Global downloadImage:url completion:^(UIImage *image, NSData *imageData, BOOL exist) {
		[Global saveFile:savePath data:imageData];
		if (completion) completion(image, imageData, exist);
	}];
}

//缓存网络图片
+ (void)cacheImageWithUrl:(NSString*)url completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion{
	if (!url.length) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (completion) completion(nil, nil, NO, NO);
		});
		return;
	}
	if ([url indexOf:@"://"]==NSNotFound) url = [NSString stringWithFormat:@"%@%@", API_URL, url];
	[[TMCache sharedCache] objectForKey:url block:^(TMCache *cache, NSString *key, id object) {
		if (object) {
			dispatch_async(dispatch_get_main_queue(), ^{
				UIImage *image = [object gif];
				if (completion) completion(image, object, YES, YES);
			});
			return;
		}
		[FileDownloader downloadWithUrl:url completion:^(NSData *data, BOOL exist) {
			[[TMCache sharedCache] setObject:data forKey:url];
			UIImage *image = [data gif];
			if (completion) completion(image, data, YES, NO);
		} fail:^(NSString *description, NSInteger code) {
			if (code == 404) [ProgressHUD showError:@"图片不存在"];
		}];
	}];
}

//缓存网络图片到UIImageView
+ (void)cacheToImageView:(UIImageView*)imageView url:(NSString*)url placeholder:(id)placeholder completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion{
	[Global cacheToImageView:imageView url:url placeholder:placeholder completion:completion animate:nil];
}

//缓存网络图片到UIImageView,支持完成后动画显示
+ (void)cacheToImageView:(UIImageView*)imageView url:(NSString*)url placeholder:(id)placeholder completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion animate:(void (^)(UIImageView *imageView, BOOL isCache))animate{
	CGFloat maxImageWidth = 90.f;
	CGFloat placeholderWidth = 70.f;
	[imageView removeAllSubviews];
	imageView.image = nil;
	imageView.clipsToBounds = YES;
	imageView.contentMode = UIViewContentModeScaleAspectFill;
	if (!url.length) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (placeholder) {
				UIImage *subImg;
				if ([placeholder isKindOfClass:[NSString class]]) {
					subImg = [UIImage imageNamed:placeholder];
				} else if ([placeholder isKindOfClass:[NSData class]]) {
					subImg = [[UIImage alloc]initWithData:placeholder];
				} else if ([placeholder isKindOfClass:[UIImage class]]) {
					subImg = placeholder;
				}
				if (imageView.width <= maxImageWidth) {
					imageView.image = subImg;
				} else {
					UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake((imageView.width-placeholderWidth)/2, (imageView.height-placeholderWidth)/2, placeholderWidth, placeholderWidth)];
					img.image = subImg;
					imageView.image = nil;
					[imageView addSubview:img];
				}
			}
			if (completion) completion(nil, nil, NO, NO);
			imageView.element[@"exist"] = @NO;
		});
		return;
	}
	if ([url indexOf:@"://"]==NSNotFound) url = [NSString stringWithFormat:@"%@%@", API_URL, url];
	[[TMCache sharedCache] objectForKey:url block:^(TMCache *cache, NSString *key, id object) {
		if (object) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if ([imageView isKindOfClass:[GIFImageView class]]) {
					UIImage *image = [GIFImage imageWithData:object];
					imageView.image = image;
					if (completion) completion(image, object, YES, YES);
					if (animate) animate(imageView, YES);
					imageView.element[@"exist"] = @YES;
				} else {
					if ([GIFImage isGif:object]) {
						UIImage *image = [GIFImage imageWithData:object];
						GIFImageView *gifView = [[GIFImageView alloc]initWithFrame:imageView.frame];
						gifView.image = image;
						gifView.clipsToBounds = imageView.clipsToBounds;
						gifView.contentMode = imageView.contentMode;
						gifView.layer.masksToBounds = imageView.layer.masksToBounds;
						gifView.layer.cornerRadius = imageView.layer.cornerRadius;
						gifView.tag = imageView.tag;
						[imageView.superview addSubview:gifView];
						[imageView removeFromSuperview];
						if (completion) completion(image, object, YES, YES);
						if (animate) animate(gifView, YES);
						gifView.element[@"exist"] = @YES;
					} else {
						UIImage *image = [[UIImage alloc]initWithData:object];
						image = [image fitToSize:CGSizeMake(imageView.size.width*2, 0)];
						imageView.image = image;
						if (completion) completion(image, object, YES, YES);
						if (animate) animate(imageView, YES);
						imageView.element[@"exist"] = @YES;
					}
				}
			});
			return;
		}
		__block MDRadialProgressView *progressView = nil;
		BOOL showLoading = imageView.frame.size.width>=35 && imageView.frame.size.height>=35;
		if (showLoading) {
			dispatch_async(dispatch_get_main_queue(), ^{
				progressView = [[MDRadialProgressView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
				progressView.center = imageView.center;
				progressView.progressTotal = 100;
				progressView.progressCounter = 1;
				progressView.theme.thickness = 10;
				progressView.theme.incompletedColor = [UIColor colorWithWhite:0 alpha:0.1];
				progressView.theme.completedColor = MAINCOLOR;
				progressView.theme.sliceDividerHidden = YES;
				progressView.label.hidden = YES;
				[imageView.superview addSubview:progressView];
			});
		}
		[FileDownloader downloadWithUrl:url timeout:DOWNLOAD_TIMEOUT progress:^(double progress, long dataSize, long long currentSize, long long totalSize) {
			progressView.progressCounter = progress * 100;
		} completion:^(NSData *data, BOOL exist) {
			[[TMCache sharedCache] setObject:data forKey:url];
			if (showLoading) {
				[progressView removeFromSuperview];
				progressView = nil;
			}
			if ([imageView isKindOfClass:[GIFImageView class]]) {
				UIImage *image = [GIFImage imageWithData:data];
				imageView.image = image;
				if (completion) completion(image, data, YES, NO);
				if (animate) {
					animate(imageView, NO);
				} else {
					imageView.alpha = 0;
					[UIView animateWithDuration:0.3 animations:^(void) {
						imageView.alpha = 1;
					}];
				}
				imageView.element[@"exist"] = @YES;
			} else {
				if ([GIFImage isGif:data]) {
					UIImage *image = [GIFImage imageWithData:data];
					GIFImageView *gifView = [[GIFImageView alloc]initWithFrame:imageView.frame];
					gifView.image = image;
					gifView.clipsToBounds = imageView.clipsToBounds;
					gifView.contentMode = imageView.contentMode;
					gifView.layer.masksToBounds = imageView.layer.masksToBounds;
					gifView.layer.cornerRadius = imageView.layer.cornerRadius;
					gifView.tag = imageView.tag;
					[imageView.superview addSubview:gifView];
					[imageView removeFromSuperview];
					if (completion) completion(image, data, YES, NO);
					if (animate) {
						animate(gifView, NO);
					} else {
						gifView.alpha = 0;
						[UIView animateWithDuration:0.3 animations:^(void) {
							gifView.alpha = 1;
						}];
					}
					gifView.element[@"exist"] = @YES;
				} else {
					UIImage *image = [[UIImage alloc]initWithData:data];
					image = [image fitToSize:CGSizeMake(imageView.size.width*2, 0)];
					imageView.image = image;
					if (completion) completion(image, data, YES, NO);
					if (animate) {
						animate(imageView, NO);
					} else {
						imageView.alpha = 0;
						[UIView animateWithDuration:0.3 animations:^(void) {
							imageView.alpha = 1;
						}];
					}
					imageView.element[@"exist"] = @YES;
				}
			}
		} fail:^(NSString *description, NSInteger code) {
			if (showLoading) {
				[progressView removeFromSuperview];
				progressView = nil;
			}
			if (placeholder) {
				UIImage *subImg;
				if ([placeholder isKindOfClass:[NSString class]]) {
					subImg = [UIImage imageNamed:placeholder];
				} else if ([placeholder isKindOfClass:[NSData class]]) {
					subImg = [[UIImage alloc]initWithData:placeholder];
				} else if ([placeholder isKindOfClass:[UIImage class]]) {
					subImg = placeholder;
				}
				if (imageView.width <= maxImageWidth) {
					imageView.image = subImg;
				} else {
					UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake((imageView.width-placeholderWidth)/2, (imageView.height-placeholderWidth)/2, placeholderWidth, placeholderWidth)];
					img.image = subImg;
					imageView.image = nil;
					[imageView addSubview:img];
				}
				imageView.alpha = 0;
				[UIView animateWithDuration:0.3 animations:^(void) {
					imageView.alpha = 1;
				}];
			}
			if (completion) completion(nil, nil, NO, NO);
			imageView.element[@"exist"] = @NO;
		}];
	}];
}

//下载网络文件
+ (void)download:(NSString*)url completion:(void (^)(NSString *fileName, NSData *fileData, BOOL exist))completion{
	if (!url.length) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (completion) completion(nil, nil, NO);
		});
		return;
	}
	if ([url indexOf:@"://"]==NSNotFound) url = [NSString stringWithFormat:@"%@%@", API_URL, url];
	dispatch_queue_t queue = dispatch_queue_create("downloadFile", DISPATCH_QUEUE_CONCURRENT);
	//dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:DOWNLOAD_TIMEOUT];
		[request setHTTPMethod:@"GET"];
		NSOperationQueue *queue = [[NSOperationQueue alloc]init];
		[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
			if (error) {
				NSLog(@"Httperror:%@%ld", error.localizedDescription, (long)error.code);
			} else {
				NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
				NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
				if (responseCode>=200 && responseCode<300) {
					dispatch_async(dispatch_get_main_queue(), ^{
						if (completion) completion([url getFilename], data, YES);
					});
					return;
				} else {
					NSLog(@"Httperror:%ld\n%@", (long)responseCode, result);
					if (responseCode == 404) [ProgressHUD showError:@"远程文件不存在"];
				}
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				if (completion) completion(nil, nil, NO);
			});
		}];
	});
}

#pragma mark - 日期
//本地当前时间
+ (NSString*)now{
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	return [formatter stringFromDate:[NSDate date]];
}

//本地当前时间
+ (NSDate*)nowDate{
	NSString *date = [Global now];
	return [Global dateFromString:date];
}

//转换为本地时间
+ (NSDate*)localDate:(NSDate*)date{
	NSTimeZone *zone = [NSTimeZone systemTimeZone];
	NSInteger interval = [zone secondsFromGMTForDate:date];
	return [date dateByAddingTimeInterval:interval];
}

//本地当前时间Unix
+ (NSTimeInterval)unix{
    return [[NSDate date] timeIntervalSince1970];
}

//时间转为Unix
+ (NSTimeInterval)unixFromDate:(id)dt{
	if ([dt isKindOfClass:[NSString class]]) dt = [Global dateFromString:dt];
    return [dt timeIntervalSince1970];
}

//Unix转为时间
+ (NSDate*)dateFromUnix:(NSTimeInterval)unix{
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:unix];
	NSTimeZone *zone = [NSTimeZone systemTimeZone];
	NSInteger interval = [zone secondsFromGMTForDate:date];
	return [date dateByAddingTimeInterval:interval];
}

//NSDateFormatter格式
//unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns
//字符串转日期
+ (NSDate*)dateFromString:(NSString*)str{
	NSArray *match = [Global preg_match:str patton:@"\\d+"];
	if (!match.count) {
		return [Global nowDate];
	} else {
		NSDateComponents *compt = [[NSDateComponents alloc] init];
		compt.year = match.count>0 ? [match[0][@"value"]integerValue] : 1970;
		compt.month = match.count>1 ? [match[1][@"value"]integerValue] : 1;
		compt.day = match.count>2 ? [match[2][@"value"]integerValue] : 1;
		compt.hour = match.count>3 ? [match[3][@"value"]integerValue] : 0;
		compt.minute = match.count>4 ? [match[4][@"value"]integerValue] : 0;
		compt.second = match.count>5 ? [match[5][@"value"]integerValue] : 0;
		NSCalendar *calendar = [NSCalendar currentCalendar];
		[calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		return [calendar dateFromComponents:compt];
	}
}

//日期转字符串
+ (NSString*)formatDate:(id)dt{
	return [Global formatDate:dt format:@"yyyy-MM-dd"];
}

//时间格式化
+ (NSString*)formatDate:(id)dt format:(NSString*)str{
	if ([dt isKindOfClass:[NSString class]]) dt = [Global dateFromString:dt];
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[formatter setDateFormat:str];
	if ([str indexOf:@"eee"]!=NSNotFound) {
		NSArray *weekdayAry = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
		[formatter setShortWeekdaySymbols:weekdayAry]; //eee使用上面自定义
	}
	return [formatter stringFromDate:dt];
}

//日期时间转字符串
+ (NSString*)formatDateTime:(id)dt{
	return [Global formatDate:dt format:@"yyyy-MM-dd HH:mm:ss"];
}

//时间转字符串
+ (NSString*)formatTime:(id)dt{
	return [Global formatDate:dt format:@"HH:mm:ss"];
}

//获取年份
+ (NSInteger)getYear:(NSDate*)date{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDateComponents *comps = [calendar components:NSYearCalendarUnit fromDate:date];
	return [comps year];
}

//获取月份
+ (NSInteger)getMonth:(NSDate*)date{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDateComponents *comps = [calendar components:NSMonthCalendarUnit fromDate:date];
	return [comps month];
}

//获取日
+ (NSInteger)getDay:(NSDate*)date{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDateComponents *comps = [calendar components:NSDayCalendarUnit fromDate:date];
	return [comps day];
}

//获取时
+ (NSInteger)getHour:(NSDate*)date{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDateComponents *comps = [calendar components:NSHourCalendarUnit fromDate:date];
	return [comps hour];
}

//获取分
+ (NSInteger)getMinute:(NSDate*)date{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDateComponents *comps = [calendar components:NSMinuteCalendarUnit fromDate:date];
	return [comps minute];
}

//获取秒
+ (NSInteger)getSecond:(NSDate*)date{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDateComponents *comps = [calendar components:NSSecondCalendarUnit fromDate:date];
	return [comps second];
}

+ (NSTimeInterval)oneYear{
	return 60 * 60 * 24 * 365;
}

+ (NSTimeInterval)oneMonth{
	return 60 * 60 * 24 * 30;
}
+ (NSTimeInterval)oneMonth:(NSInteger)days{
	return 60 * 60 * 24 * days;
}

+ (NSTimeInterval)oneWeek{
	return 60 * 60 * 24 * 7;
}

+ (NSTimeInterval)oneDay{
	return 60 * 60 * 24;
}

//获取偏移时间
+ (NSInteger)getDateOffset:(NSInteger)delay range:(NSString*)range{
	NSArray *intervalName = @[@"yyyy", @"m", @"w", @"d", @"h", @"n", @"s"];
	NSInteger index = [intervalName indexOfObject:range];
	NSDate *dateNow;
	switch (index) {
		case 0:case 1:case 3:dateNow = [NSDate dateWithTimeIntervalSinceNow:delay*24*60*60];break;
		case 2:dateNow = [NSDate dateWithTimeIntervalSinceNow:delay*7*24*60*60];break;
		case 4:dateNow = [NSDate dateWithTimeIntervalSinceNow:delay*60*60];break;
		case 5:dateNow = [NSDate dateWithTimeIntervalSinceNow:delay*60];break;
		case 6:default:dateNow = [NSDate dateWithTimeIntervalSinceNow:delay];break;
	}
	NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];//设置成中国阳历
	[calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDateComponents *comps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:dateNow];
	NSInteger num = 0;
	switch (index) {
		case 0:num = [comps year];break;
		case 1:num = [comps month];break;
		case 2:num = [comps weekday];break;
		case 3:num = [comps day];break;
		case 4:num = [comps hour];break;
		case 5:num = [comps minute];break;
		case 6:default:num = [comps second];break;
	}
	return num;
}

//时间递增
+ (NSDate*)dateAdd:(NSString*)range interval:(NSInteger)number date:(id)dt{
	if ([dt isKindOfClass:[NSString class]]) dt = [Global dateFromString:dt];
	NSArray *intervalName = @[@"yyyy", @"m", @"w", @"d", @"h", @"n", @"s"];
	NSInteger index = [intervalName indexOfObject:range];
	NSInteger time = 0;
	switch (index) {
		case 0:time = 60 * 60 * 24 * 365;break;
		case 1:time = 60 * 60 * 24 * 30;break;
		case 2:time = 60 * 60 * 24 * 7;break;
		case 3:time = 60 * 60 * 24;break;
		case 4:time = 60 * 60;break;
		case 5:time = 60;break;
		case 6:default:time = 1;break;
	}
	return [dt dateByAddingTimeInterval:number * time];
}

//时间相隔
+ (NSInteger)dateDiff:(NSString*)range earlyDate:(id)earlyDate lateDate:(id)lateDate{
	if ([earlyDate isKindOfClass:[NSString class]]) earlyDate = [Global dateFromString:earlyDate];
	if ([lateDate isKindOfClass:[NSString class]]) lateDate = [Global dateFromString:lateDate];
	NSArray *intervalName = @[@"yyyy", @"m", @"w", @"d", @"h", @"n", @"s"];
	NSInteger index = [intervalName indexOfObject:range];
	NSTimeInterval time = [lateDate timeIntervalSinceDate:earlyDate];
	switch (index) {
		case 0:time = time / (60 * 60 * 24 * 365);break;
		case 1:time = time / (60 * 60 * 24 * 30);break;
		case 2:time = time / (60 * 60 * 24 * 7);break;
		case 3:time = time / (60 * 60 * 24);break;
		case 4:time = time / (60 * 60);break;
		case 5:time = time / 60;break;
		case 6:default:time = time;break;
	}
	return time;
}

//获取指定时间所在周的第一天与最后一天(根据系统本地区域)
+ (NSArray*)getWeeksBeginAndEnd:(id)dt{
	if ([dt isKindOfClass:[NSString class]]) dt = [Global dateFromString:dt];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDateComponents *dateComps = [calendar components:NSWeekdayCalendarUnit fromDate:dt];
    NSInteger daycount = [dateComps weekday] - 2;
    NSDate *weekdaybegin = [dt dateByAddingTimeInterval:-daycount*60*60*24];
    NSDate *weekdayend = [dt dateByAddingTimeInterval:(6-daycount)*60*60*24];
    return [NSArray arrayWithObjects:weekdaybegin, weekdayend, nil];
}

//判断日期为周几, 1:日, 2:一, 3:二, 4:三, 5:四, 6:五, 7:六
+ (NSInteger)getWeek:(id)dt{
	if ([dt isKindOfClass:[NSString class]]) dt = [Global dateFromString:dt];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	calendar.timeZone = [NSTimeZone systemTimeZone];
	NSInteger week = [[calendar components:NSWeekdayCalendarUnit fromDate:dt] weekday];
	return week;
}

//日期时间+4位随机数
+ (NSString*)datetimeAndRandom{
	CGFloat rand = (arc4random() % 8999) + 1000;
	NSString *datetime = [Global formatDate:[NSDate date] format:@"yyyyMMddHHmmss"];
	return [NSString stringWithFormat:@"%@%.f", datetime, rand];
}

#pragma mark - UI操作
//UILabel多行
+ (UILabel*)multiLine:(CGRect)frame string:(NSString*)string font:(UIFont*)font{
	CGSize size = [Global autoHeight:string font:font width:frame.size.width];
	frame.size.height = size.height;
	UILabel *label = [[UILabel alloc]initWithFrame:frame];
	label.text = string;
	label.font = font;
	label.numberOfLines = 0;
	return label;
}

//UILabel多行且设定行高
+ (UILabel*)multiLine:(CGRect)frame string:(NSString*)string font:(UIFont*)font lineheight:(CGFloat)linespace{
	UILabel *label = [Global multiLine:frame string:string font:font];
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:string];
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
	[paragraphStyle setLineSpacing:linespace];
	[attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, string.length)];
	label.attributedText = attributedString;
	[label sizeToFit];
	return label;
}

//克隆view
+ (id)cloneView:(UIView*)view{
	return [view cloneView];
}

//放大且渐隐view
+ (void)zoomView:(UIView*)view{
	[Global zoomView:view duration:0.3 percent:1.4];
}
+ (void)zoomView:(UIView*)view duration:(CGFloat)duration percent:(CGFloat)percent{
	[UIView animateWithDuration:duration animations:^{
		[Global scaleView:view percent:percent];
		view.alpha = 0;
	} completion:^(BOOL finished) {
		[view removeFromSuperview];
	}];
}

//动画移动view
+ (void)moveView:(UIView*)view to:(CGRect)frame time:(CGFloat)time{
	// 动画开始
	[UIView beginAnimations:nil context:nil];
	// 动画时间曲线 EaseInOut效果
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	// 动画时间
	[UIView setAnimationDuration:time];
	[view setFrame:frame];
	// 动画结束
	[UIView commitAnimations];
}

//抛物线移动view
+ (void)throwView:(UIView*)view endpoint:(CGPoint)endpoint completion:(void (^)())completion{
	UIBezierPath *path = [UIBezierPath bezierPath];
	CGPoint startPoint = view.center; //起点
	[path moveToPoint:startPoint];
	//贝塞尔曲线控制点
	CGFloat sx = startPoint.x;
	CGFloat sy = startPoint.y;
	CGFloat ex = endpoint.x;
	CGFloat ey = endpoint.y;
	CGFloat x = sx + (ex - sx) / 3;
	CGFloat y = sy + (ey - sy) * 0.5 - 400;
	[path addQuadCurveToPoint:endpoint controlPoint:CGPointMake(x, y)];
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	animation.path = path.CGPath;
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	animation.duration = 0.8;
	animation.autoreverses = NO;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	[view.layer addAnimation:animation forKey:@"throw"];
	if (completion) {
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				completion();
			});
		});
	}
}

//渐显隐藏与显示
+ (void)opacityOutIn:(UIView*)view duration:(CGFloat)duration afterHidden:(void (^)())afterHidden completion:(void (^)())completion{
	[view opacityFn:duration afterHidden:afterHidden completion:completion];
}

//旋转屏幕
+ (void)transformScreen:(UIViewController*)view{
	[Global transformScreen:view orientation:@"top"];
}

//旋转屏幕,可设置方向
+ (void)transformScreen:(UIViewController*)view orientation:(NSString*)orientation{
	UIInterfaceOrientation o;
	CGRect navFrame;
	CGRect viewFrame;
	CGAffineTransform m;
	
	if ([orientation isEqualToString:@"left"]) {
		o = UIInterfaceOrientationLandscapeLeft;
		navFrame = CGRectMake(64, 224, SCREEN_ALL_HEIGHT, 32);
		viewFrame = CGRectMake(0, 0, SCREEN_ALL_HEIGHT, view.view.frame.size.width);
		m = CGAffineTransformMakeRotation(M_PI_2);
	} else if ([orientation isEqualToString:@"right"]) {
		o = UIInterfaceOrientationLandscapeRight;
		navFrame = CGRectMake(64, 224, SCREEN_ALL_HEIGHT, 32);
		viewFrame = CGRectMake(0, 0, SCREEN_ALL_HEIGHT, view.view.frame.size.width);
		m = CGAffineTransformMakeRotation(M_PI*1.5);
	} else if ([orientation isEqualToString:@"bottom"]) {
		o = UIInterfaceOrientationPortraitUpsideDown;
		navFrame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
		viewFrame = CGRectMake(0, 0, view.view.frame.size.width, view.view.frame.size.height);
		m = CGAffineTransformMakeRotation(0);
	} else {
		o = UIInterfaceOrientationPortrait;
		navFrame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
		viewFrame = CGRectMake(0, 0, view.view.frame.size.width, view.view.frame.size.height);
		m = CGAffineTransformMakeRotation(0);
	}
	
	//状态栏动画持续时间
	CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
	//设置旋转动画
	[UIView animateWithDuration:duration animations:^{
		[[UIApplication sharedApplication] setStatusBarOrientation:o animated:YES];
		//设置导航栏旋转
		view.navigationController.navigationBar.frame = navFrame;
		view.navigationController.navigationBar.transform = m;
		//设置视图旋转
		view.view.bounds = viewFrame;
		view.view.transform = m;
	}];
}

//缩放View
+ (void)scaleView:(UIView*)view percent:(CGFloat)percent{
	if (percent==0) percent = 0.01;
	view.transform = CGAffineTransformMakeScale(percent, percent);
}

//动画缩放View
+ (void)scaleAnimate:(UIView*)view time:(NSTimeInterval)time percent:(CGFloat)percent completion:(void (^)())completion{
	if (percent==0) percent = 0.01;
	[UIView animateWithDuration:time animations:^{
		view.transform = CGAffineTransformMakeScale(percent, percent);
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

//动画缩放View,回弹效果
+ (void)scaleAnimateBounces:(UIView*)view time:(NSTimeInterval)time percent:(CGFloat)percent completion:(void (^)())completion{
	[Global scaleAnimateBounces:view time:time percent:percent bounce:0.2 completion:completion];
}
+ (void)scaleAnimateBounces:(UIView*)view time:(NSTimeInterval)time percent:(CGFloat)percent bounce:(CGFloat)bounce completion:(void (^)())completion{
	if (percent==0) percent = 0.01;
	/*
	[Global scaleAnimate:view time:time percent:percent+bounce completion:^{
		[Global scaleAnimate:view time:time percent:percent completion:^{
			if (completion) completion();
		}];
	}];
	*/
	[view.layer removeAllAnimations];
	CAKeyframeAnimation *scaoleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	scaoleAnimation.duration = time;
	scaoleAnimation.values = @[@(percent), @(percent+bounce), @(percent)];
	scaoleAnimation.fillMode = kCAFillModeForwards;
	[view.layer addAnimation:scaoleAnimation forKey:@"transform.rotate"];
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (completion) completion();
		});
	});
}

//角度旋转View
+ (void)rotatedView:(UIView*)view degrees:(CGFloat)degrees{
	view.transform = CGAffineTransformMakeRotation((M_PI*(degrees)/180.0));
}

//指定中心点旋转View,CGPoint参数为百分比
+ (void)rotatedView:(UIView*)view degrees:(CGFloat)degrees center:(CGPoint)center{
	CGRect frame = view.frame;
	view.layer.anchorPoint = center; //设置旋转的中心点
	view.frame = frame; //设置anchorPont会使view的frame改变,需重新赋值
	view.transform = CGAffineTransformMakeRotation((M_PI*(degrees)/180.0));
}

//2D动画旋转
+ (void)rotateAnimate:(UIView*)view time:(NSTimeInterval)time degrees:(CGFloat)degrees completion:(void (^)())completion{
	CGAffineTransform t = view.transform;
	[UIView animateWithDuration:time animations:^{
		view.transform = CGAffineTransformRotate(t, (M_PI*(degrees)/180.0));
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

//指定中心点2D动画旋转
+ (void)rotateAnimate:(UIView*)view time:(NSTimeInterval)time degrees:(CGFloat)degrees center:(CGPoint)center completion:(void (^)())completion{
	CGAffineTransform t = view.transform;
	CGRect frame = view.frame;
	view.layer.anchorPoint = center;
	view.frame = frame;
	[UIView animateWithDuration:time animations:^{
		view.transform = CGAffineTransformRotate(t, (M_PI*(degrees)/180.0));
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

//3D动画旋转
+ (void)rotate3DAnimate:(UIView*)view delegate:(NSObject*)delegate{
	CAAnimation *animateRotate = [Global rotate3DAnimate];
	CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
	groupAnimation.delegate = delegate;
	groupAnimation.removedOnCompletion = NO;
	groupAnimation.duration = 1;
	groupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	groupAnimation.repeatCount = 1;
	groupAnimation.fillMode = kCAFillModeForwards;
	groupAnimation.animations = [NSArray arrayWithObjects:animateRotate,nil];
	[view.layer addAnimation:groupAnimation forKey:@"animationRotate"];
	/*
	 在delegate里面可增加动画结束后执行的方法
	 -(void)animationDidStop:(CAAnimation*)animation finished:(BOOL)flag
	 */
}
+ (CAAnimation*)rotate3DAnimate{
	CATransform3D rotationTransform = CATransform3DMakeRotation(M_PI/2, 0, 1, 0);
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
	animation.toValue = [NSValue valueWithCATransform3D:rotationTransform];
	animation.duration = 0.3;
	animation.autoreverses = YES;
	animation.cumulative = YES;
	animation.repeatCount = 1;
	animation.beginTime = 0.1;
	animation.delegate = self;
	return animation;
}

//地图翻起动画效果
+ (void)pageCurlAnimation:(UIView*)view time:(NSTimeInterval)time delegate:(NSObject*)delegate{
	CATransition *animation = [CATransition animation];
	[animation setDelegate:delegate];
	[animation setDuration:time];
	[animation setTimingFunction:UIViewAnimationCurveEaseInOut];
	if (!view.element[@"pageCurl"]) {
		animation.type = @"pageCurl";
		animation.fillMode = kCAFillModeForwards;
		animation.endProgress = 0.40;
		view.element[@"pageCurl"] = @YES;
	} else {
		animation.type = @"pageUnCurl";
		animation.fillMode = kCAFillModeBackwards;
		animation.startProgress = 0.30;
		[view removeElement:@"pageCurl"];
	}
	[animation setRemovedOnCompletion:NO];
	[view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
	[view.layer addAnimation:animation forKey:@"pageCurlAnimation"];
}

//指定列数for循环自动调整X、Y坐标(换行),需在循环外部设定uIndex、vIndex为[NSNumber numberWithFloat:0]
/*
NSNumber *k = [NSNumber numberWithInteger:0];
NSNumber *l = [NSNumber numberWithInteger:0];
for(int i=0; i<arr.count; i++){
	ele.frame = [Global autoXYWithCellCount:2 width:100 height:50 blank:10 marginTop:10 marginLeft:10 uIndex:&k vIndex:&l];
}
 */
+ (CGRect)autoXYWithCellCount:(NSInteger)count width:(CGFloat)w height:(CGFloat)h blank:(CGFloat)b marginTop:(CGFloat)t marginLeft:(CGFloat)l uIndex:(NSNumber**)u vIndex:(NSNumber**)v{
	CGFloat i = [*u floatValue];
	CGFloat j = [*v floatValue];
	CGFloat x = l + (w + b) * i;
	CGFloat y = t + (h + b) * j;
	CGRect frame = CGRectMake(x, y, w, h);
	if (fmod(i+1, count)==0) {
		i = 0;
		j++;
	} else {
		i++;
	}
	*u = [NSNumber numberWithFloat:i];
	*v = [NSNumber numberWithFloat:j];
	return frame;
}

//固定宽度区域内自动调整X、Y坐标(换行),需在循环外部设定prevRight、prevBottom为[NSNumber numberWithFloat:0]
+ (CGRect)autoXYInWidth:(CGFloat)width subview:(UIView*)subview marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r prevRight:(NSNumber**)pr prevBottom:(NSNumber**)pb{
	return [Global autoXYInWidth:width subview:subview frame:subview.frame marginPT:t marginPL:l marginPR:r prevRight:pr prevBottom:pb];
}
+ (CGRect)autoXYInWidth:(CGFloat)width subview:(UIView*)subview frame:(CGRect)subviewFrame marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r prevRight:(NSNumber**)pr prevBottom:(NSNumber**)pb{
	CGFloat x = [*pr floatValue];
	CGFloat y = [*pb floatValue];
	CGFloat w = floor(subviewFrame.size.width);
	CGFloat h = floor(subviewFrame.size.height);
	if (x==0) x = l;
	if (y==0) y = t;
	if (!subview.element[@"first"]) x += floor(subviewFrame.origin.x);
	CGRect frame = CGRectMake(x, y, w, h);
	if (x+w > width-r) {
		UIView *prevView = [subview prevView:[subview.superview.element[@"cellCount"]integerValue]];
		x = l;
		y = floor(prevView.frame.origin.y) + floor(prevView.frame.size.height) + floor(subviewFrame.origin.y);
		frame = CGRectMake(x, y, w, h);
	}
	x += w;
	*pr = [NSNumber numberWithFloat:x];
	*pb = [NSNumber numberWithFloat:y];
	return frame;
}

//在指定UIView内自动排版,类似于WEB的DIV+CSS自动排版
+ (void)autoLayoutWithView:(UIView*)view subviews:(NSMutableArray*)subviews marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r{
	if (!subviews.count) return;
	[view autoLayoutSubviews:subviews marginPT:t marginPL:l marginPR:r];
}

+ (void)showMenuControllerWithTarget:(UIView*)target titles:(NSArray*)titles actions:(NSArray*)actions{
	[target.superview becomeFirstResponder];
	UIMenuController *menuController = [UIMenuController sharedMenuController];
	menuController.element[@"view"] = target;
	NSMutableArray *items = [[NSMutableArray alloc]init];
	for (int i=0; i<titles.count; i++) {
		UIMenuItem *menuItem = [[UIMenuItem alloc]initWithTitle:titles[i] action:NSSelectorFromString(actions[i])];
		[items addObject:menuItem];
	}
	menuController.menuItems = items;
	[menuController setTargetRect:target.frame inView:target.superview];
	[menuController setMenuVisible:NO];
	[menuController setMenuVisible:YES animated:YES];
}

#pragma mark - 其他
//获取当前IP
+ (NSString*)getIP{
	NSError *error;
	NSString *url = @"http://ip.taobao.com/service/getIpInfo.php?ip=myip";
	NSString *string = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://pv.sohu.com/cityjson"] encoding:0x80000421 error:&error];
	NSDictionary *json = [string formatJson];
	if ([json[@"code"]integerValue] != 0) return @"";
	return json[@"data"][@"ip"];
	/*
	NSError *error;
	NSString *ip = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://pv.sohu.com/cityjson"] encoding:0x80000421 error:&error];
	if (error) {
		NSLog(@"%@",error);
		ip = @"";
	} else {
		ip = [Global cropHtml:ip startStr:@"cip\": \"" overStr:@"\", \"cid"];
		ip = [Global trim:ip];
	}
	return ip;
	*/
}

//等比缩放
+ (CGSize)fitToSize:(CGSize)size originSize:(CGSize)origin{
	return [Global fitToSize:size originSize:origin fix:0];
}
+ (CGSize)fitToSize:(CGSize)size originSize:(CGSize)origin fix:(CGFloat)fix{
	CGFloat width = size.width;
	CGFloat height = size.height;
	CGFloat iw = origin.width;
	CGFloat ih = origin.height;
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
		}
	} else {
		size = CGSizeMake(nw, size.height);
	}
	if (height>0) {
		if (height>nh) {
			size = CGSizeMake(size.width, nh);
		}
	} else {
		size = CGSizeMake(size.width, nh);
	}
	return size;
}

//拨打电话
+ (void)openCall:(NSString*)tel{
	if (!tel.length) {
		[ProgressHUD showError:@"电话号码为空"];
		return;
	}
	UIViewController *controller = [Global currentController];
	UIWebView *webView = [[UIWebView alloc]init];
	[controller.view addSubview:webView];
	[webView loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:STRINGFORMAT(@"tel://%@",tel)]]];
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			[webView removeFromSuperview];
		});
	});
}

//发短信
+ (void)openSms:(NSString*)tel{
	if (!tel.length) {
		[ProgressHUD showError:@"电话号码为空"];
		return;
	}
	if (![MFMessageComposeViewController canSendText]) {
		[ProgressHUD showWarning:@"设备不能发短信"];
		return;
	}
	MFMessageComposeViewController *msg = [[MFMessageComposeViewController alloc] init];
	msg.messageComposeDelegate = (id<MFMessageComposeViewControllerDelegate>)GlobalShared;
	msg.recipients = @[tel];
	//msg.body = @"";
	[[Global currentController] presentViewController:msg animated:YES completion:nil];
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
	[controller dismissViewControllerAnimated:YES completion:nil];
}

//调用QQ客户端查看指定QQ号
+ (void)openQQ:(NSString*)uin{
	if (![ShareHelper isQQInstalled]) {
		[ProgressHUD showWarning:@"设备没有QQ客户端"];
		return;
	}
	NSString *link = [NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web", uin];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
}

//调用微信客户端打开指定账号
+ (void)openWechat:(NSString*)uin{
	if (![ShareHelper isQQInstalled]) {
		[ProgressHUD showWarning:@"设备没有微信客户端"];
		return;
	}
	NSString *link = [NSString stringWithFormat:@"weixin://qr/%@", uin];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
}

//快速显示UIAlertView
+ (void)alert:(NSString*)message{
	[Global alert:message delegate:nil];
}

//快速显示UIAlertView,可使用代理
+ (void)alert:(NSString*)message delegate:(NSObject*)delegate{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:delegate cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

//快速显示UIAlertView,且使用取消、确定按钮,直接使用block操作
+ (void)alert:(NSString*)message block:(void(^)(NSInteger buttonIndex))block{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
	[alert showWithBlock:^(NSInteger buttonIndex) {
		if (block) block(buttonIndex);
	}];
}

//创建数量标记小圆点
+ (UILabel*)createMarkWithFrame:(CGRect)frame font:(UIFont*)font{
	UILabel *mark = [[UILabel alloc]initWithFrame:frame];
	mark.text = @"0";
	mark.textColor = [UIColor whiteColor];
	mark.textAlignment = NSTextAlignmentCenter;
	mark.font = font;
	mark.backgroundColor = [UIColor redColor];
	mark.layer.masksToBounds = YES;
	mark.layer.cornerRadius = frame.size.width/2;
	return mark;
}
+ (void)updateMark:(UILabel*)mark text:(NSString*)text{
	CGRect frame = mark.frame;
	CGSize s = [Global autoWidth:text font:mark.font height:frame.size.height];
	s.width += 6;
	if (s.width<frame.size.width) s.width = frame.size.width;
	frame.size.width = s.width;
	mark.frame = frame;
	mark.text = text;
	[mark.layer removeAllAnimations];
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	animation.duration = 0.25;
	animation.values = @[@1.0, @1.2, @1.0];
	animation.fillMode = kCAFillModeForwards;
	[mark.layer addAnimation:animation forKey:@"transform.rotate"];
}

//获取范围随机数
+ (NSInteger)randomFrom:(NSInteger)from to:(NSInteger)to{
	NSInteger t = to + 1 - from;
	NSInteger random = (arc4random() % t) + from;
	return random;
}

//获取范围随机小数
+ (double)randomFloatFrom:(double)from to:(double)to{
	double t = to + 1 - from;
	double random = ((double)arc4random() / 0x100000000) + from;
	return random;
}

//获取指定位数的随机字符串
+ (NSString*)randomString:(NSInteger)length{
	NSString *sourceStr = @"9zML5pGCkBAJQ2Zh4de1RlqNPno8m3FKijbrc6SDEas7O0TUXYtwxuVHWvIfgy";
	NSMutableString *result = [[NSMutableString alloc]init];
	srand((unsigned int)time(0));
	for (int i=0; i<length; i++) {
		unsigned index = rand() % [sourceStr length];
		NSString *one = [sourceStr substringWithRange:NSMakeRange(index, 1)];
		[result appendString:one];
	}
	return result;
}

//获取滑动方向, 0:无,1:上,2:下,3:左,4:右
/*
NSInteger _direction;
- (void)handlePan:(UIPanGestureRecognizer *)recognizer{
	CGPoint translation = [recognizer translationInView:recognizer.view];
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		_direction = 0;
	} else if (recognizer.state == UIGestureRecognizerStateChanged && _direction==0) {
		_direction = [Global getMoveDirectionWithTranslation:translation direction:_direction];
	} else if (recognizer.state == UIGestureRecognizerStateEnded) {
		switch (_direction) {
			case 1:
				//NSLog(@"moved up");
				break;
			case 2:
				//NSLog(@"moved down");
				break;
			case 3:
				//NSLog(@"moved left");
				break;
			case 4:
				//NSLog(@"moved right");
				break;
			default:
				//NSLog(@"no moved");
				break;
		}
	}
}
*/
+ (NSInteger)getMoveDirectionWithTranslation:(CGPoint)translation direction:(NSInteger)direction{
	CGFloat gestureMinimumTranslation = 50.f;
	if (direction != 0) return direction;
	if (fabs(translation.x) > gestureMinimumTranslation) {
		BOOL gestureHorizontal = (translation.y==0.0) ? YES : (fabs(translation.x / translation.y) > 5.0);
		if (gestureHorizontal) {
			if (translation.x > 0.0) return 4;
			else return 3;
		}
	} else if (fabs(translation.y) > gestureMinimumTranslation) {
		BOOL gestureVertical = (translation.x==0.0) ? YES : (fabs(translation.y / translation.x) > 5.0);
		if (gestureVertical) {
			if (translation.y > 0.0) return 2;
			else return 1;
		}
	}
	return direction;
}

//相隔一定时间后重复执行
+ (void)repeatDo:(NSTimeInterval)delay function:(void (^)())function{
	if (function) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				function();
				[Global repeatDo:delay function:function];
			});
		});
	}
}

//通过 NSUserDefaults 检测当前网络
+ (BOOL)isNetwork:(BOOL)noNetShowMsg{
	BOOL isNetwork = NO;
	NSDictionary *network = [@"network" getUserDefaultsDictionary];
	if (network) {
		isNetwork = [CheckNetwork isNetworkFor:network[@"network"] noNetShowMsg:noNetShowMsg];
	} else {
		isNetwork = [CheckNetwork isNetwork:noNetShowMsg];
	}
	return isNetwork;
}

//列出指定目录下的文件列表
+ (void)GFileList:(NSString *)folderPath{
	GFileList *e = [[GFileList alloc]init];
	e.folderPath = folderPath;
	[APPCurrentController.navigationController pushViewController:e animated:YES];
}

//显示本地推送
+ (void)showLocalNotification:(NSString*)body{
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	notification.fireDate = [NSDate date];
	notification.alertBody = body;
	notification.alertAction = @"打开";
	notification.timeZone = [NSTimeZone defaultTimeZone];
	notification.soundName = UILocalNotificationDefaultSoundName;
	//NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	//notification.userInfo = userInfo;
	[[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

//注册通知
+ (void)notificationRegisterWithObserver:(id)observer selector:(SEL)selector name:(NSString*)name object:(id)object{
	[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:name object:object];
}
//发送通知
+ (void)notificationPostWithName:(NSString*)name object:(id)object{
	NSNotification *notification = [NSNotification notificationWithName:name object:object];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}
//移除通知
+ (void)notificationRemoveObserver:(id)observer{
	[[NSNotificationCenter defaultCenter]removeObserver:observer];
}

//清除缓存
+ (void)removeCache{
	[[TMCache sharedCache] removeAllObjects];
}

//播放声音文件, [[NSBundle mainBundle] pathForResource:@"EMReply.mp3" ofType:nil]
+ (void)playVoice:(NSString*)voicePath{
	NSURL *url = [NSURL fileURLWithPath:voicePath];
	SystemSoundID soundID = 0;
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
	//AudioServicesDisposeSystemSoundID(soundID);
	//AudioServicesPlayAlertSound(soundID); //声音带震动
	AudioServicesPlaySystemSound(soundID); //声音
	//AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); //震动
}

//Touch ID, passwordTitle:nil即不显示输入密码按钮
+ (void)touchIDWithReason:(NSString*)reason passwordTitle:(NSString*)passwordTitle success:(void (^)())successBlock fail:(void (^)(NSError *error))fail nosupport:(void (^)())nosupport{
	LAContext *context = [[LAContext alloc]init];
	NSError *error = nil;
	if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
		context.localizedFallbackTitle = passwordTitle;
		[context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError *error) {
			if (success) {
				if (successBlock) {
					dispatch_async(dispatch_get_main_queue(), ^{
						successBlock();
					});
				}
			} else {
				//用户取消认证
				if (fail) {
					dispatch_async(dispatch_get_main_queue(), ^{
						fail(error);
					});
				}
			}
		}];
	} else {
		if (nosupport) {
			nosupport();
		} else {
			[ProgressHUD showError:@"设备不支持指纹认证"];
		}
	}
}

#pragma mark - 本类方法
+ (Global*)shared{
	static dispatch_once_t once = 0;
	static Global *global;
	dispatch_once(&once, ^{ global = [[Global alloc] init]; });
	return global;
}
- (id)init{
	self = [super init];
	if (self) {
		_dict = [[NSMutableDictionary alloc]init];
		_cacheObject = [[NSCache alloc]init];
		_cacheObject.countLimit = 20;
	}
	return self;
}
- (id)getValue:(NSString*)key{
	return _dict[key];
}
- (NSMutableDictionary*)allValues{
	return _dict;
}
- (NSMutableDictionary*)setValue:(id)value key:(NSString*)key{
	[_dict setObject:value forKey:key];
	return _dict;
}
- (NSMutableDictionary*)setValues:(NSArray*)values keys:(NSArray*)keys{
	if (values.count != keys.count) return _dict;
	for (int i=0; i<keys.count; i++) {
		[_dict setObject:values[i] forKey:keys[i]];
	}
	return _dict;
}
- (NSMutableDictionary*)removeAllValues{
	[_dict removeAllObjects];
	return _dict;
}
+ (id)cacheObjectForKey:(id)key{
	return [[self shared].cacheObject objectForKey:key];
	/*
	 NSString *objectKey = STRINGFORMAT(@"%@%ld%ld", self.class, (long)indexPath.section, (long)indexPath.row);
	 UIImageView *pic = [Global cacheObjectForKey:objectKey];
	 if (pic) {
		[view addSubview:pic];
	 } else {
		pic = [[UIImageView alloc]initWithFrame:CGRectMake(0, (view.height-60)/2, 60, 60)];
		pic.image = IMG(@"nopic");
		pic.url = _ms[row][@"pic"];
		[view addSubview:pic];
		[Global setCacheObject:pic forKey:objectKey];
	 }
	 */
}
+ (void)setCacheObject:(id)obj forKey:(id)key{
	[[self shared].cacheObject setObject:obj forKey:key];
}
+ (void)removeAllCacheObjects{
	[[self shared].cacheObject removeAllObjects];
}
+ (void)removeCacheObjectForKey:(id)key{
	[[self shared].cacheObject removeObjectForKey:key];
}

@end
