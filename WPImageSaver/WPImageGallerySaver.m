//
//  WPImageGallerySaver.m
//  WordpressTemplate
//
//  Created by Anton Zdorov on 4/25/15.
//  Copyright (c) 2015 Webparadox, LLC. All rights reserved.
//


#import "WPImageGallerySaverStrategy.h"
#import "WPImageGallerySaverStrategyFactory.h"

#import "WPImageGallerySaver.h"
#import "WPImageSaverDefines.h"
#import "WPImageSaverUtils.h"
#import "WPImageSaverConstants.h"


static NSString *const WPImageSaverDefaulAlbumName = @"Album";

@interface WPImageGallerySaver()

@property (strong, nonatomic) id<WPImageGallerySaverStrategy> saveStrategy;

@property (copy, nonatomic) NSString *album;
@property (copy, nonatomic) NSString *fileFormat;
@property (strong, nonatomic) NSNumber *quality;

@end

@implementation WPImageGallerySaver

@synthesize config = _config;
@synthesize delegate = _delegate;
@synthesize delegateQueue = _delegateQueue;

- (id)initWithConfig:(NSDictionary *)config
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.config = config;
    self.quality = self.config[WPImageSaverQuality];
    self.album = self.config[WPImageSaverAlbumName] ? : WPImageSaverDefaulAlbumName;
    self.fileFormat = self.config[WPImageSaverFileFormat];
    
    WPImageGallerySaverStrategyFactory *factory = [[WPImageGallerySaverStrategyFactory alloc] init];
    self.saveStrategy = [factory strategy];
    
    __weak typeof(self) weakSelf = self;
    if (self.saveStrategy) {
        self.saveStrategy.success = ^(id<WPImageGallerySaverStrategy> strategy, UIImage *image) {
            [weakSelf notifySuccess:image];
        };
        self.saveStrategy.failure = ^(id<WPImageGallerySaverStrategy> strategy, NSError *error) {
            [weakSelf notifyFailure:error];
        };
    }
    
    return self;
}

#pragma mark - Public

- (void)saveFromURL:(NSURL *)url
{
#if DEBUG
    NSAssert(url != nil, @"image URL = (nil)");
    NSAssert(url.absoluteString.length != 0, @"image URL is empty");
#else
    if (!url || url.absoluteString.length == 0) {
        NSError *error = [NSError errorWithDomain:WPImagerSaverErrorDomain code:WPImageSaverEmptyInputDataErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"URL for saving image = (nil)" }];
        [self notifyFailure:error];
        return;
    }
#endif
    
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create("com.wordpresstemplate.gallerysaver", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [weakSelf notifyStartLoading];
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        [weakSelf saveImage:data callbackQueue:queue];
    });
}

- (void)saveFromData:(NSData *)data
{
#if DEBUG
    NSAssert(data != nil, @"data = (nil)");
    NSAssert(data.length != 0, @"data is empty");
#else
    if (!data || data.length == 0) {
        NSError *error = [NSError errorWithDomain:WPImagerSaverErrorDomain code:WPImageSaverEmptyInputDataErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Data for saving image = (nil)" }];
        [self notifyFailure:error];
        return;
    }
#endif
    
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create("com.wordpresstemplate.gallerysaver", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [weakSelf notifyStartLoading];
        
        [weakSelf saveImage:data callbackQueue:queue];
    });
}

#pragma mark - Getters / Setters

- (dispatch_queue_t)delegateQueue
{
    return _delegateQueue ? : dispatch_get_main_queue();
}

#pragma mark - Private

- (void)saveImage:(NSData *)imageData callbackQueue:(dispatch_queue_t)queue
{
    UIImage *image = [UIImage imageWithData:imageData];
    WPImageFormat format = [self imageFormat];
    
    if (format == WPImageFormatUnsupported) {
        NSError *error = [NSError errorWithDomain:WPImagerSaverErrorDomain code:WPImageSaverUnsupportedFileFormatErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Unsupported target file format. Support only PNG and JPEG file formats" }];
        [self notifyFailure:error];
        return;
    }

    NSData *representData = [self imageDataWithFileFormat:format image:image];
    if (representData && representData.length > 0) {
        [self.saveStrategy save:representData toAlbum:[self.album copy] callbackQueue:queue];
    } else {
        NSError *error = [NSError errorWithDomain:WPImagerSaverErrorDomain code:WPImageSaverEmptyImageDataForSaveErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Converted image data is nil" }];
        [self notifyFailure:error];
    }
}

#pragma mark - Notifies

- (void)notifySuccess:(UIImage *)image
{
    if ([self.delegate respondsToSelector:@selector(imageSaver:completeSave:)]) {
        __weak typeof(self) weakSelf = self;
        dispatch_sync(self.delegateQueue, ^{
            [weakSelf.delegate imageSaver:weakSelf completeSave:image];
        });
    }
}

- (void)notifyFailure:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(imageSaver:didFailWithError:)]) {
        __weak typeof(self) weakSelf = self;
        dispatch_sync(self.delegateQueue, ^{
            [weakSelf.delegate imageSaver:weakSelf didFailWithError:error];
        });
    }
}

- (void)notifyStartLoading
{
    if ([self.delegate respondsToSelector:@selector(imageSaverDidStartSaving:)]) {
        __weak typeof(self) weakSelf = self;
        dispatch_sync(self.delegateQueue, ^{
            [weakSelf.delegate imageSaverDidStartSaving:weakSelf];
        });
    }
}

#pragma mark - Utilities

- (NSData *)imageDataWithFileFormat:(WPImageFormat)format image:(UIImage *)image
{
    NSData *data = nil;
    
    CGFloat quality = (self.quality.floatValue > 0.0 && self.quality.floatValue <= 1.0) ? self.quality.floatValue : 1.0;
    
    if (format == WPImageFormatJPEG) {
        data = WPUIImageJPEGRepresentation(image.CGImage, quality);
    } else if (format == WPImageFormatPNG) {
        data = WPUIImagePNGRepresentation(image.CGImage, quality);
    }
    
    return data;
}

- (WPImageFormat)imageFormat
{
    WPImageFormat format = WPImageFormatUnsupported;
    if ([self.fileFormat isEqualToString:WPImageSaverFileFormatPNG]) {
        format = WPImageFormatPNG;
    } else if ([self.fileFormat isEqualToString:WPImageSaverFileFormatJPEG]) {
        format = WPImageFormatJPEG;
    }
    
    return format;
}


@end
