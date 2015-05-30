//
//  WPImageFileSaver.m
//  WordpressTemplate
//
//  Created by Anton Zdorov on 4/25/15.
//  Copyright (c) 2015 Webparadox, LLC. All rights reserved.
//


#import "WPImageFileSaver.h"
#import "WPImageSaverUtils.h"
#import "WPImageSaverConstants.h"
#import "WPImageSaverDefines.h"

#import <UIKit/UIKit.h>


@interface WPImageFileSaver()

@property (copy, nonatomic) NSString *fileFormat;
@property (copy, nonatomic) NSString *folder;
@property (copy, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSNumber *quality;

@end

@implementation WPImageFileSaver

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
    self.folder = self.config[WPImageSaverAlbumName];
    self.fileName = self.config[WPImageSaverFileName];
    self.fileFormat = self.config[WPImageSaverFileFormat];
    
    return self;
}

- (void)saveFromURL:(NSURL *)url
{
#if DEBUG
    NSAssert(url != nil, @"image URL = (nil)");
    NSAssert(url.absoluteString.length != 0, @"image URL is empty");
#else
    if (!url || url.absoluteString.length == 0) {
        NSError *error = [NSError errorWithDomain:WPImagerSaverErrorDomain code:WPImageSaverEmptyInputDataErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"URL for saving image = (nil)" }];
        [self notifyFailure:error];
    }
#endif
    
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create("com.wordpresstemplate.gallerysaver", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [weakSelf notifyStartLoading];
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        [weakSelf saveImage:data];
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
    }
#endif
    
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create("com.wordpresstemplate.gallerysaver", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [weakSelf notifyStartLoading];
        
        [weakSelf saveImage:data];
    });
}

#pragma mark - Getters / Setters

- (dispatch_queue_t)delegateQueue
{
    return _delegateQueue ? : dispatch_get_main_queue();
}

#pragma mark - Private

- (void)saveImage:(NSData *)imageData
{
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *targetFolder = documentsDirectoryPath;
    if (self.folder && self.folder.length > 0) {
        targetFolder = [documentsDirectoryPath stringByAppendingPathComponent:self.folder];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:targetFolder]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:targetFolder withIntermediateDirectories:NO attributes:nil error:&error];
            if (error) {
                [self notifyFailure:error];
                return;
            }
        }
    }
    
    NSString *fileName = self.fileName;
    if (!self.fileName || self.fileName.length == 0) {
        fileName = [NSString stringWithFormat:@"%li", imageData.hash^imageData.length];
    }
    fileName = [fileName stringByAppendingPathExtension:[self fileExtansion]];
    
    NSString *fullPath = [targetFolder stringByAppendingPathComponent:fileName];
    
    UIImage *image = [UIImage imageWithData:imageData];
    WPImageFormat format = [self imageFormat];

    if (format == WPImageFormatUnsupported) {
        NSError *error = [NSError errorWithDomain:WPImagerSaverErrorDomain code:WPImageSaverUnsupportedFileFormatErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Unsupported target file format. Support only PNG and JPEG file formats" }];
        [self notifyFailure:error];
        return;
    }
    
    NSData *representData = [self imageDataWithFileFormat:format image:image];
    if (representData && representData.length > 0) {
        if ([representData writeToFile:fullPath atomically:YES]) {
            [self notifySuccess:image];
        } else {
            NSError *error = [NSError errorWithDomain:WPImagerSaverErrorDomain code:WPImageSaverFailureErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Failure save image to folder" }];
            [self notifyFailure:error];
        }
    } else {
        NSError *error = [NSError errorWithDomain:WPImagerSaverErrorDomain code:WPImageSaverEmptyImageDataForSaveErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Converted image = nil" }];
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
    
    return nil;
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

- (NSString *)fileExtansion
{
    NSString *fileExtansion = nil;
    
    if ([self.fileFormat isEqualToString:WPImageSaverFileFormatJPEG]) {
        fileExtansion = @"jpeg";
    } else if ([self.fileFormat isEqualToString:WPImageSaverFileFormatPNG]) {
        fileExtansion = @"png";
    }
    
    return fileExtansion;
}

@end
