//
//  WTImageSaverInterface.h
//  WordpressTemplate
//
//  Created by Anton Zdorov on 4/25/15.
//  Copyright (c) 2015 Webparadox, LLC. All rights reserved.
//


#import "WPImageSaverDelegate.h"
#import <Foundation/Foundation.h>

@protocol WPImageSaverInterface <NSObject>

@property (copy, nonatomic) NSDictionary *config;

@property (strong, nonatomic) id<WPImageSaverDelegate> delegate;

@property (assign, nonatomic) dispatch_queue_t delegateQueue;

- (id)initWithConfig:(NSDictionary *)config;

- (void)saveFromURL:(NSURL *)url;
- (void)saveFromData:(NSData *)data;

@end
