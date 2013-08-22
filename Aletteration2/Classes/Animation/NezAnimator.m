//
//  NezAnimator.m
//  Aletteration
//
//  Created by David Nesbitt on 2/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezAnimator.h"
#import "NezAnimation.h"

//This class is NOT thread safe!!!

NSMutableArray *animationList;
NSMutableArray *addedList;
NSMutableArray *removedList;

@implementation NezAnimator

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;

		animationList = [NSMutableArray arrayWithCapacity:128];
		addedList = [NSMutableArray arrayWithCapacity:128];
		removedList = [NSMutableArray arrayWithCapacity:128];
	}
}

+(void)addAnimation:(NezAnimation*)ani {
	ani->elapsedTime = -ani->delay;
	[addedList addObject:ani];
}

+(void)removeAnimation:(NezAnimation*)animation {
	[removedList addObject:animation];
}

+(void)removeAllAnimations {
	[removedList addObjectsFromArray:animationList];
}

+(void)cancelAnimation:(NezAnimation*)animation {
	animation->cancelled = YES;
	[removedList addObject:animation];
}

+(void)updateWithTimeSinceLastUpdate:(NSTimeInterval)timeSinceLastUpdate {
	if ([removedList count] > 0) {
		[animationList removeObjectsInArray:removedList];
		[removedList removeAllObjects];
	}
	if ([addedList count] > 0) {
		[animationList addObjectsFromArray:addedList];
		[addedList removeAllObjects];
	}
	for (NezAnimation *ani in animationList) {
		if (!ani->cancelled) {
			ani->elapsedTime += timeSinceLastUpdate;
			if (ani->elapsedTime >= ani->duration) {
				ani->elapsedTime = ani->duration;
				for (int i=0; i<ani->dataLength; i++) {
					ani->newData[i] = ani->toData[i];
				}
				if (--ani->repeatCount > 0 || ani->loop == NEZ_ANI_LOOP_FORWARD) {
					ani.updateFrameBlock(ani);
					ani->elapsedTime = -ani->delay;
				} else if(ani->loop == NEZ_ANI_LOOP_PINGPONG) {
					ani.updateFrameBlock(ani);
					ani->elapsedTime = -ani->delay;
					
					float *toData = ani->fromData;
					float *fromData = ani->toData;
					
					ani->toData = toData;
					ani->fromData = fromData;
				} else {
					ani.updateFrameBlock(ani);
					if (ani.chainLink) {
						[self addAnimation:ani.chainLink];
						ani.chainLink->elapsedTime = -ani.chainLink->delay;
						ani.chainLink = nil;
					}
					if (ani->removedWhenFinished) {
						[self removeAnimation:ani];
					}
					if (ani.didStopBlock != NULL) {
						ani.didStopBlock(ani);
					}
				}
			} else if(ani->elapsedTime >= 0) {
				for (int i=0; i<ani->dataLength; i++) {
					ani->newData[i] = ani->easingFunction(ani->elapsedTime, ani->fromData[i], ani->toData[i]-ani->fromData[i], ani->duration);
				}
				ani.updateFrameBlock(ani);
			}
		}
	}
}

@end
