//
//  NezAnimator.h
//  Aletteration
//
//  Created by David Nesbitt on 2/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

@class NezAnimation;

@interface NezAnimator : NSObject {
}

+(void)initialize;

+(void)addAnimation:(NezAnimation*)animation;

+(void)removeAnimation:(NezAnimation*)animation;
+(void)removeAllAnimations;

+(void)cancelAnimation:(NezAnimation*)animation;

+(void)updateWithTimeSinceLastUpdate:(NSTimeInterval)timeSinceLastUpdate;

@end
