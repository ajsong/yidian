//
//  UIImage+WebP.h
//  SDWebImage
//
//  Created by Olivier Poitrey on 07/06/13.
//  Copyright (c) 2013 Dailymotion. All rights reserved.
//

#ifdef EM_WEBP

#import <UIKit/UIKit.h>

// Fix for issue #416 Undefined symbols for architecture armv7 since WebP introduction when deploying to device
void WebPInitPremultiplyNEON(void);

void WebPInitUpsamplersNEON(void);

void VP8DspInitNEON(void);

@interface UIImage (WebP)

+ (UIImage *)em_imageWithWebPData:(NSData *)data;

@end

#endif
