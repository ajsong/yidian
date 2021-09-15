/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+EMWebCache.h"
#import "objc/runtime.h"
#import "UIView+EMWebCacheOperation.h"

static char imageURLKey;

@implementation UIImageView (EMWebCache)

- (void)em_setImageWithURL:(NSURL *)url {
    [self em_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)em_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self em_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)em_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(EMSDWebImageOptions)options {
    [self em_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)em_setImageWithURL:(NSURL *)url completed:(EMSDWebImageCompletionBlock)completedBlock {
    [self em_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)em_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(EMSDWebImageCompletionBlock)completedBlock {
    [self em_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)em_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(EMSDWebImageOptions)options completed:(EMSDWebImageCompletionBlock)completedBlock {
    [self em_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)em_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(EMSDWebImageOptions)options progress:(EMSDWebImageDownloaderProgressBlock)progressBlock completed:(EMSDWebImageCompletionBlock)completedBlock {
    [self em_cancelCurrentImageLoad];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if (!(options & EMSDWebImageDelayPlaceholder)) {
        self.image = placeholder;
    }
    
    if (url) {
        __weak UIImageView *wself = self;
        id <EMSDWebImageOperation> operation = [EMSDWebImageManager.sharedManager downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                if (image) {
                    wself.image = image;
                    [wself setNeedsLayout];
                } else {
                    if ((options & EMSDWebImageDelayPlaceholder)) {
                        wself.image = placeholder;
                        [wself setNeedsLayout];
                    }
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
        [self em_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
    } else {
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:@"SDWebImageErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, EMSDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)em_setImageWithPreviousCachedImageWithURL:(NSURL *)url andPlaceholderImage:(UIImage *)placeholder options:(EMSDWebImageOptions)options progress:(EMSDWebImageDownloaderProgressBlock)progressBlock completed:(EMSDWebImageCompletionBlock)completedBlock {
    NSString *key = [[EMSDWebImageManager sharedManager] cacheKeyForURL:url];
    UIImage *lastPreviousCachedImage = [[EMSDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    
    [self em_setImageWithURL:url placeholderImage:lastPreviousCachedImage ?: placeholder options:options progress:progressBlock completed:completedBlock];    
}

- (NSURL *)em_imageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (void)em_setAnimationImagesWithURLs:(NSArray *)arrayOfURLs {
    [self em_cancelCurrentAnimationImagesLoad];
    __weak UIImageView *wself = self;

    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];

    for (NSURL *logoImageURL in arrayOfURLs) {
        id <EMSDWebImageOperation> operation = [EMSDWebImageManager.sharedManager downloadImageWithURL:logoImageURL options:0 progress:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                __strong UIImageView *sself = wself;
                [sself stopAnimating];
                if (sself && image) {
                    NSMutableArray *currentImages = [[sself animationImages] mutableCopy];
                    if (!currentImages) {
                        currentImages = [[NSMutableArray alloc] init];
                    }
                    [currentImages addObject:image];

                    sself.animationImages = currentImages;
                    [sself setNeedsLayout];
                }
                [sself startAnimating];
            });
        }];
        [operationsArray addObject:operation];
    }

    [self em_setImageLoadOperation:[NSArray arrayWithArray:operationsArray] forKey:@"UIImageViewAnimationImages"];
}

- (void)em_cancelCurrentImageLoad {
    [self em_cancelImageLoadOperationWithKey:@"UIImageViewImageLoad"];
}

- (void)em_cancelCurrentAnimationImagesLoad {
    [self em_cancelImageLoadOperationWithKey:@"UIImageViewAnimationImages"];
}

@end


@implementation UIImageView (EMWebCacheDeprecated)

- (NSURL *)imageURL {
    return [self em_imageURL];
}

- (void)setImageWithURL:(NSURL *)url {
    [self em_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self em_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(EMSDWebImageOptions)options {
    [self em_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url completed:(EMSDWebImageCompletedBlock)completedBlock {
    [self em_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(EMSDWebImageCompletedBlock)completedBlock {
    [self em_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(EMSDWebImageOptions)options completed:(EMSDWebImageCompletedBlock)completedBlock {
    [self em_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(EMSDWebImageOptions)options progress:(EMSDWebImageDownloaderProgressBlock)progressBlock completed:(EMSDWebImageCompletedBlock)completedBlock {
    [self em_setImageWithURL:url placeholderImage:placeholder options:options progress:progressBlock completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)cancelCurrentArrayLoad {
    [self em_cancelCurrentAnimationImagesLoad];
}

- (void)cancelCurrentImageLoad {
    [self em_cancelCurrentImageLoad];
}

- (void)setAnimationImagesWithURLs:(NSArray *)arrayOfURLs {
    [self em_setAnimationImagesWithURLs:arrayOfURLs];
}

@end
