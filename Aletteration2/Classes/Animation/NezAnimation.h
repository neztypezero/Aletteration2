//
//  NezAnimation.h
//  Aletteration
//
//  Created by David Nesbitt on 2/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezAnimationEasingFunction.h"
#import "NezVertexArrayGeometry.h"

typedef enum LOOP_TYPES {
	NEZ_ANI_NO_LOOP,
	NEZ_ANI_LOOP_FORWARD,
	NEZ_ANI_LOOP_PINGPONG,
} LOOP_TYPES;

@class NezAnimation;

typedef void (^NezAnimationBlock)(NezAnimation *ani);

@interface NezAnimation : NSObject {
@public //This is for speed. Basically using this class as a struct
	int dataLength;
	float *fromData;
	float *toData;
	float *newData;
	float delay;
	int repeatCount;
	int animationSlot;
	BOOL cancelled;
	BOOL removedWhenFinished;
	
	LOOP_TYPES loop;
	
	EasingFunctionPtr easingFunction;
	
	NSTimeInterval duration;
	NSTimeInterval elapsedTime;
}
-(id)initWithFromData:(float*)fromDataPtr ToData:(float*)toDataPtr DataLength:(int)length Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;

-(id)initFloatWithFromData:(float)from ToData:(float)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;
-(id)initVec2WithFromData:(GLKVector2)from ToData:(GLKVector2)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;
-(id)initVec3WithFromData:(GLKVector3)from ToData:(GLKVector3)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;
-(id)initVec4WithFromData:(GLKVector4)from ToData:(GLKVector4)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;
-(id)initMat4WithFromData:(GLKMatrix4)from ToData:(GLKMatrix4)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;

@property (nonatomic, weak) NSObject *updateObject;
@property (nonatomic, strong) NezAnimation *chainLink;
@property (nonatomic, copy) NezAnimationBlock updateFrameBlock;
@property (nonatomic, copy) NezAnimationBlock didStopBlock;
@property (nonatomic, strong) NSMutableData *data;

@end
