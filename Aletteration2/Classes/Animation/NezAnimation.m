//
//  NezAnimation.m
//  Aletteration
//
//  Created by David Nesbitt on 2/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezAnimation.h"

@implementation NezAnimation

-(id)initWithFromData:(float*)fromDataPtr ToData:(float*)toDataPtr DataLength:(int)length Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	if ((self = [super init])) {
		dataLength = length/sizeof(float);
		self.data = [NSMutableData dataWithCapacity:length*3];
		
		fromData = (float*)[self.data bytes];
		memcpy(fromData, fromDataPtr, length);
		toData = &fromData[dataLength];
		memcpy(toData, toDataPtr, length);
		newData = &fromData[dataLength*2];

		easingFunction = func;
		
		duration = d;
		repeatCount = 0;
		delay = 0;
		
		cancelled = NO;
		removedWhenFinished = YES;
		
		loop = NEZ_ANI_NO_LOOP;
		
		self.updateFrameBlock = updateBlock;
		self.didStopBlock = didStopBlock;
	}
	return self;
}

-(id)initFloatWithFromData:(float)from ToData:(float)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	return [self initWithFromData:&from ToData:&to DataLength:sizeof(float) Duration:d EasingFunction:func UpdateBlock:updateBlock DidStopBlock:didStopBlock];
}

-(id)initVec2WithFromData:(GLKVector2)from ToData:(GLKVector2)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	return [self initWithFromData:from.v ToData:to.v DataLength:sizeof(GLKVector2) Duration:d EasingFunction:func UpdateBlock:updateBlock DidStopBlock:didStopBlock];
}

-(id)initVec3WithFromData:(GLKVector3)from ToData:(GLKVector3)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	return [self initWithFromData:from.v ToData:to.v DataLength:sizeof(GLKVector3) Duration:d EasingFunction:func UpdateBlock:updateBlock DidStopBlock:didStopBlock];
}

-(id)initVec4WithFromData:(GLKVector4)from ToData:(GLKVector4)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	return [self initWithFromData:from.v ToData:to.v DataLength:sizeof(GLKVector4) Duration:d EasingFunction:func UpdateBlock:updateBlock DidStopBlock:didStopBlock];
}

-(id)initMat4WithFromData:(GLKMatrix4)from ToData:(GLKMatrix4)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	return [self initWithFromData:from.m ToData:to.m DataLength:sizeof(GLKMatrix4) Duration:d EasingFunction:func UpdateBlock:updateBlock DidStopBlock:didStopBlock];
}

-(void)dealloc {
	self.updateObject = nil;
	self.chainLink = nil;
	self.updateFrameBlock = nil;
	self.didStopBlock = nil;
	self.data = nil;
}

@end
