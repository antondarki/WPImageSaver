//
//  WPImageGallerySaverStrategy.h
//  WordpressTemplate
//
//  Created by Anton Zdorov on 4/27/15.
//  Copyright (c) 2015 Webparadox, LLC. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol WPImageGallerySaverStrategy <NSObject>

@property (copy, nonatomic) void (^success)(id<WPImageGallerySaverStrategy> strategy, UIImage *image);
@property (copy, nonatomic) void (^failure)(id<WPImageGallerySaverStrategy> strategy, NSError *error);

- (void)save:(NSData *)imageData toAlbum:(NSString *)albumName callbackQueue:(dispatch_queue_t)queue;

@end