//
// QR Code Generator - generates UIImage from NSString
//
// Copyright (C) 2012 http://moqod.com Andrew Kopanev <andrew@moqod.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
// of the Software, and to permit persons to whom the Software is furnished to do so, 
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all 
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.
//

#import "QRCodeGenerator.h"
//#import "ZXingObjC.h"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_SCALE (SCREEN_HEIGHT>568.0f ? SCREEN_HEIGHT/568.0f : 1.0f)

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
#define kCGImageAlphaPremultipliedLast (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast)
#else
#define kCGImageAlphaPremultipliedLast kCGImageAlphaPremultipliedLast
#endif

@implementation QRCodeGenerator

#pragma mark - 从字符串生成二维码图片
+ (UIImage *)createQRCode:(NSString *)string size:(CGFloat)size{
	return [QRCodeGenerator createQRCode:string size:size color:[UIColor blackColor]];
}

+ (UIImage *)createQRCode:(NSString *)string size:(CGFloat)size color:(UIColor *)color{
	return [QRCodeGenerator createQRCode:string size:size color:color logo:nil];
}

+ (UIImage *)createQRCode:(NSString *)string size:(CGFloat)size logo:(UIImage *)logo{
	return [QRCodeGenerator createQRCode:string size:size color:nil logo:logo];
}

+ (UIImage *)createQRCode:(NSString *)string size:(CGFloat)size color:(UIColor *)color logo:(UIImage *)logo{
	if (!string.length || size < 15.f) return nil;
	
	//生成二维码,原生态生成二维码需要导入CoreImage.framework
	CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
	[filter setDefaults];
	//字符串转换为data
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	//通过KVO设置滤镜inputMessage数据
	[filter setValue:data forKey:@"inputMessage"];
	//纠错级别
	[filter setValue:@"M" forKey:@"inputCorrectionLevel"];
	//获得滤镜输出的图像
	CIImage *outPutImage = [filter outputImage];
	UIImage *QRImage = [QRCodeGenerator createNonInterpolatedUIImageFormCIImage:outPutImage withSize:size];
	
	if (color) {
		CGFloat r, g, b, a;
		if ([color getRed:&r green:&g blue:&b alpha:&a])
			QRImage = [QRCodeGenerator imageBlackToTransparent:QRImage withRed:r*255 andGreen:g*255 andBlue:b*255];
	}
	
	if (logo) {
		CGFloat size = logo.size.width;
		logo = [QRCodeGenerator changeToSize:logo size:CGSizeMake(size*SCREEN_SCALE, size*SCREEN_SCALE)];
		QRImage = [QRCodeGenerator addImage:logo toImage:QRImage size:size];
	}
	
	return QRImage;
}

+ (UIImage*)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
	CGRect extent = CGRectIntegral(image.extent);
	CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
	// 创建bitmap;
	size_t width = CGRectGetWidth(extent) * scale;
	size_t height = CGRectGetHeight(extent) * scale;
	CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
	CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
	CIContext *context = [CIContext contextWithOptions:nil];
	CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
	CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
	CGContextScaleCTM(bitmapRef, scale, scale);
	CGContextDrawImage(bitmapRef, extent, bitmapImage);
	// 保存bitmap到图片
	CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
	CGContextRelease(bitmapRef);
	CGImageRelease(bitmapImage);
	return [UIImage imageWithCGImage:scaledImage];
}

void SetProviderReleaseData (void *info, const void *data, size_t size){
	free((void*)data);
}
+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
	const int imageWidth = image.size.width;
	const int imageHeight = image.size.height;
	size_t      bytesPerRow = imageWidth * 4;
	uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
												 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
	CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
	// 遍历像素
	int pixelNum = imageWidth * imageHeight;
	uint32_t* pCurPtr = rgbImageBuf;
	for (int i = 0; i < pixelNum; i++, pCurPtr++){
		if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) { // 将白色变成透明
			// 改成下面的代码，会将图片转成想要的颜色
			uint8_t* ptr = (uint8_t*)pCurPtr;
			ptr[3] = red; //0~255
			ptr[2] = green;
			ptr[1] = blue;
		} else {
			uint8_t* ptr = (uint8_t*)pCurPtr;
			ptr[0] = 0;
		}
	}
	// 输出图片
	CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, SetProviderReleaseData);
	CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
										kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
										NULL, true, kCGRenderingIntentDefault);
	CGDataProviderRelease(dataProvider);
	UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
	// 清理空间
	CGImageRelease(imageRef);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	return resultUIImage;
}

#pragma mark - 从图片解析二维码
+ (NSString *)QRStringFromImage:(UIImage *)QRImage{
	NSString *QRString = @"";
	UIImage *image = [QRCodeGenerator fitToSize:QRImage size:CGSizeMake(280*SCREEN_SCALE, 280*SCREEN_SCALE)];
	CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
											  context:[CIContext contextWithOptions:nil]
											  options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
	NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
	if (features.count > 0) {
		CIQRCodeFeature *feature = features.firstObject;
		QRString = feature.messageString;
	} else {
		NSLog(@"CIDetector在iPhone5s及以上真机才能识别, 要兼容所有设备需要导入ZXingObjC");
//		CGImageRef imageToDecode = image.CGImage;
//		ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
//		ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
//		NSError *error = nil;
//		ZXDecodeHints *hints = [ZXDecodeHints hints];
//		ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
//		ZXResult *result = [reader decode:bitmap hints:hints error:&error];
//		if (result) {
//			return result.text;
//		}
		UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含二维码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
		[alertView show];
	}
	return QRString;
}

+ (UIImage*)fitToSize:(UIImage*)image size:(CGSize)size{
	if (image == nil) return nil;
	CGFloat left = 0;
	CGFloat top = 0;
	CGFloat width = size.width;
	CGFloat height = size.height;
	CGFloat iw = image.size.width;
	CGFloat ih = image.size.height;
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
	[image drawInRect:CGRectMake(left, top, nw, nh)];
	//从当前context中创建一个改变大小后的图片
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	//使当前的context出堆栈
	UIGraphicsEndImageContext();
	//返回新的改变大小后的图片
	return newImage;
}

+ (UIImage*)changeToSize:(UIImage*)image size:(CGSize)size{
	UIGraphicsBeginImageContext(size);
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

+ (UIImage*)addImage:(UIImage*)smallImage toImage:(UIImage*)image size:(CGFloat)size{
	UIGraphicsBeginImageContext(image.size);
	[image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
	[smallImage drawInRect:CGRectMake((image.size.width-size)/2, (image.size.height-size)/2, size, size)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end
