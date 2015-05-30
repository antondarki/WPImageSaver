//
//  WTImageGallerySaverStrategyFactory.m
//  WordpressTemplate
//
//  Created by Anton Zdorov on 4/27/15.
//  Copyright (c) 2015 Webparadox, LLC. All rights reserved.
//


#import "WPImageGallerySaverStrategyFactory.h"
#import "WPIOS7GallerySaverStrategy.h"
#import "WPIOS8GallerySaverStrategy.h"
#import "WPIMageSaverUtils.h"


static NSString *const WPIOS8StrategyKey = @"ios8";
static NSString *const WPIOS7StrategyKey = @"ios7";

@interface WPImageGallerySaverStrategyFactory()

@property (copy, nonatomic) NSDictionary *strategies;
@property (copy, nonatomic) NSString *currentKey;

@end

@implementation WPImageGallerySaverStrategyFactory

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.strategies = @{ WPIOS8StrategyKey: NSStringFromClass([WPIOS8GallerySaverStrategy class]),
                         WPIOS7StrategyKey: NSStringFromClass([WPIOS7GallerySaverStrategy class]) };
    self.currentKey = !IsIOS8OrMore() ? WPIOS7StrategyKey : WPIOS8StrategyKey;
    
    return self;
}

- (id<WPImageGallerySaverStrategy>)strategy
{
    NSString *className = self.strategies[self.currentKey];
    
    NSAssert(className != nil, @"%@ %@: Strategy class name for key %@ = (nil)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.currentKey);
    NSAssert(className.length > 0, @"%@ %@: Strategy class name is empty", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    Class strategyClass = NSClassFromString(className);
    
    id strategy = [[strategyClass alloc] init];
    
    NSAssert(strategy != nil, @"%@ %@: Instance strategy for class %@ = (nil)", NSStringFromClass([self class]), NSStringFromSelector(_cmd),className);
    
    return strategy;
}

@end
