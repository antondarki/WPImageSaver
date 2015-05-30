//
//  WTIOS8GallerySaverStrategy.m
//  WordpressTemplate
//
//  Created by Anton Zdorov on 4/27/15.
//  Copyright (c) 2015 Webparadox, LLC. All rights reserved.
//


#import "WPIOS8GallerySaverStrategy.h"
#import "WPImageSaverDefines.h"
#import "WPImageSaverUtils.h"

#import <Photos/Photos.h>
#import <UIKit/UIKit.h>


@interface WPIOS8GallerySaverStrategy()

@property (strong, nonatomic) dispatch_queue_t queue;
@property (assign, nonatomic) CGFloat quality;

@end

@implementation WPIOS8GallerySaverStrategy

@synthesize success = _success;
@synthesize failure = _failure;

-(void)save:(NSData *)imageData toAlbum:(NSString *)albumName callbackQueue:(dispatch_queue_t)queue
{
    self.queue = queue;
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status != PHAuthorizationStatusAuthorized) {
        __weak typeof(self) weakSelf = self;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus newStatus) {
            if (newStatus != PHAuthorizationStatusAuthorized) {
                NSError *error = [NSError errorWithDomain:WPImagerSaverErrorDomain code:WPImageSaverPhotoAccessDeniedErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Access denied" }];
                [weakSelf notifyFailure:error];
            } else {
                [self addImage:imageData toAlbum:albumName];
            }
        }];
    } else {
        [self addImage:imageData toAlbum:albumName];
    }
}

- (PHAssetCollection *)assetCollectionWithTitle:(NSString *)title
{
    // fetch asset collection with predicate
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"self.title = %@", title];
    
    PHFetchResult *usersAlbums = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:options];
    PHAssetCollection *collection = usersAlbums.firstObject;
    
    return collection;
}

- (void)addImage:(NSData *)imageData toAlbum:(NSString *)name
{
    NSString *title = [name copy];
    
    PHAssetCollection *collection = [self assetCollectionWithTitle:title];
    
    __weak typeof(self) weakSelf = self;
    if (!collection) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        } completionHandler:^(BOOL success, NSError *error) {
            if (error) {
                [weakSelf notifyFailure:error];
                return;
            }
            if (!success) {
                NSError *error = [NSError errorWithDomain:WPImagerSaverErrorDomain code:WPImageSaverPhotoAccessDeniedErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Access denied" }];
                [weakSelf notifyFailure:error];
                return;
            }
            // try add image again
            [self addImage:imageData toAlbum:title];
        }];
    } else {
        UIImage *image = [UIImage imageWithData:imageData];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            
            if ([collection canPerformEditOperation:PHCollectionEditOperationAddContent]) {
                PHAssetCollectionChangeRequest *assetCollectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            
                [assetCollectionRequest addAssets:@[ assetChangeRequest.placeholderForCreatedAsset ]];
            } else {
                NSError *error = [NSError errorWithDomain:WPImagerSaverErrorDomain code:WPImageSaverFailureErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Failure save image to PHAssetCollection" }];
                [weakSelf notifyFailure:error];
                return;
            }
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
                [weakSelf notifyFailure:error];
            } else {
                [weakSelf notifySuccess:image];
            }
        }];
    }
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
