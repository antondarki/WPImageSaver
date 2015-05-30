//
//  WPImageSaverDelegate.h
//  WordpressTemplate
//
//  Created by Anton Zdorov on 4/25/15.
//  Copyright (c) 2015 Webparadox, LLC. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol WPImageSaverInterface;

@protocol WPImageSaverDelegate <NSObject>

- (void)imageSaverDidStartSaving:(id<WPImageSaverInterface>)saver;

- (void)imageSaver:(id<WPImageSaverInterface>)saver didFailWithError:(NSError *)error;

- (void)imageSaver:(id<WPImageSaverInterface>)saver completeSave:(UIImage *)image;

@end
