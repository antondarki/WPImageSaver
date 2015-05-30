//
//  WPImageGallerySaverStrategyFactory.h
//  WordpressTemplate
//
//  Created by Anton Zdorov on 4/27/15.
//  Copyright (c) 2015 Webparadox, LLC. All rights reserved.
//


#import "WPImageGallerySaverStrategy.h"


@interface WPImageGallerySaverStrategyFactory : NSObject

- (id<WPImageGallerySaverStrategy>)strategy;

@end
