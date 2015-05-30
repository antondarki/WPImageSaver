//
//  WTIOS7GallerySaverStrategy.m
//  WordpressTemplate
//
//  Created by Anton Zdorov on 4/27/15.
//  Copyright (c) 2015 Webparadox, LLC. All rights reserved.
//


#import "WPIOS7GallerySaverStrategy.h"
#import "WPImageSaverUtils.h"
#import "WPImageSaverDefines.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface WPIOS7GallerySaverStrategy()

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) dispatch_queue_t queue;

@end

@implementation WPIOS7GallerySaverStrategy

@synthesize success = _success;
@synthesize failure = _failure;

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    return self;
}

- (void)save:(NSData *)imageData toAlbum:(NSString *)albumName callbackQueue:(dispatch_queue_t)queue
{
    self.queue = queue;
    
    __weak typeof(self) weakSelf = self;
    [self.assetsLibrary addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
        if (!group) {
            [weakSelf.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
                if ([name isEqualToString:albumName]) {
                    [weakSelf addImage:imageData toAssetsGroup:group];
                }
            } failureBlock:^(NSError *error) {
                [weakSelf notifyFailure:error];
            }];
        } else {
            [weakSelf addImage:imageData toAssetsGroup:group];
        }
    } failureBlock:^(NSError *error) {
        [weakSelf notifyFailure:error];
    }];
}

- (void)addImage:(NSData *)imageData toAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    [self.assetsLibrary writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error) {
            [self.assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                if ([assetsGroup addAsset:asset]) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    [self notifySuccess:image];
                } else {
                    NSError *error = [NSError errorWithDomain:WPImagerSaverErrorDomain code:WPImageSaverFailureErrorCode userInfo:@{ NSLocalizedDescriptionKey : @"Failure save image to ALAsset" }];
                    [self notifyFailure:error];
                }
            } failureBlock:^(NSError *error) {
                [self notifyFailure:error];
            }];
        } else {
            [self notifyFailure:error];
        }
    }];
}

#pragma mark - Notifies

- (void)notifySuccess:(UIImage *)image
{
    if (self.success) {
        dispatch_sync(self.queue, ^{
            self.success(self, image);
        });
    }
}

- (void)notifyFailure:(NSError *)error
{
    if (self.failure) {
        dispatch_sync(self.queue, ^{
            self.failure(self, error);
        });
    }
}

@end
