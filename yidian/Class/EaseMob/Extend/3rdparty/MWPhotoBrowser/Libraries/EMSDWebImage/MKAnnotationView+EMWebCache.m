//
//  MKAnnotationView+WebCache.m
//  SDWebImage
//
//  Created by Olivier Poitrey on 14/03/12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import "MKAnnotationView+EMWebCache.h"
#import "objc/runtime.h"
#import "UIView+EMWebCacheOperation.h"

static char imageURLKey;

@implementation MKAnnotationView (EMWebCache)

- (NSURL *)em_imageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (void)em_setImageWithURL:(NSURL *)url {
    [self em_setImageWithURL:url placeholderImage:nil options:0 completed:nil];
}

- (void)em_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self em_setImageWithURL:url placeholderImage:placeholder options:0 completed:nil];
}

- (void)em_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(EMSDWebImageOptions)options {
    [self em_setImageWithURL:url placeholderImage:placeholder options:options completed:nil];
}

- (void)em_setImageWithURL:(NSURL *)url completed:(EMSDWebImageCompletionBlock)completedBlock {
    [self em_setImageWithURL:url placeholderImage:nil options:0 completed:completedBlock];
}

- (void)em_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(EMSDWebImageCompletionBlock)completedBlock {
    [self em_setImageWithURL:url placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)em_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(EMSDWebImageOptions)options completed:(EMSDWebImageCompletionBlock)completedBlock {
    [self em_cancelCurrentImageLoad];

    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.image = placeholder;

    if (url) {
        __weak MKAnnotationView *wself = self;
        id <EMSDWebImageOperation> operation = [EMSDWebImageManager.sharedManager downloadImageWithURL:url options:options progress:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                __strong MKAnnotationView *sself = wself;
                if (!sself) return;
                if (image) {
                    sself.image = image;
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
        [self em_setImageLoadOperation:operation forKey:@"MKAnnotationViewImage"];
    } else {
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:@"SDWebImageErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, EMSDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)em_cancelCurrentImageLoad {
    [self em_cancelImageLoadOperationWithKey:@"MKAnnotationViewImage"];
}

@end


@implementation MKAnnotationView (WebCacheDeprecated)

- (NSURL *)imageURL {
    return [self em_imageURL];
}

- (void)setImageWithURL:(NSURL *)url {
    [self em_setImageWithURL:url placeholderImage:nil options:0 completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self em_setImageWithURL:url placeholderImage:placeholder options:0 completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(EMSDWebImageOptions)options {
    [self em_setImageWithURL:url placeholderImage:placeholder options:options completed:nil];
}

- (void)setImageWithURL:(NSURL *)url completed:(EMSDWebImageCompletedBlock)completedBlock {
    [self em_setImageWithURL:url placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(EMSDWebImageCompletedBlock)completedBlock {
    [self em_setImageWithURL:url placeholderImage:placeholder options:0 completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(EMSDWebImageOptions)options completed:(EMSDWebImageCompletedBlock)completedBlock {
    [self em_setImageWithURL:url placeholderImage:placeholder options:options completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)cancelCurrentImageLoad {
    [self em_cancelCurrentImageLoad];
}

@end
