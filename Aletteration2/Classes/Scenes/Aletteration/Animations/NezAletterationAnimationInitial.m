//
//  NezAnimationInitial.m
//  Aletteration2
//
//  Created by David Nesbitt on 2013-09-08.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAletterationAnimationInitial.h"
#import "NezAnimator.h"
#import "NezCamera.h"
#import "NezAletterationBox.h"
#import "NezAletterationLid.h"
#import "NezAletterationGameState.h"
#import "NezCubicBezierAnimation.h"
#import "NezCubicBezier.h"
#import "NezAletterationLetterStack.h"
#import "NezAletterationSinglePlayerController.h"
#import "NezAletterationDisplayLine.h"

#define NEZ_ALETTERATION_LID_ROTATION (M_PI/2.0*0.85)

@implementation NezAletterationAnimationInitial

+(GLKVector3)getBoxEndPos {
	NezAletterationBox *box = [NezAletterationGameState getBox];
	GLKVector3 boxSize = box.size;
	GLKVector3 blockSize = [NezAletterationLetterBlock getBlockSize];
	GLKVector3 endPos = {-boxSize.z, blockSize.y*8.5, 0.0};
	return endPos;
}

+(GLKMatrix4)getBoxEndMatrix {
	GLKVector3 endPos = [NezAletterationAnimationInitial getBoxEndPos];
	GLKMatrix4 matRotZ = GLKMatrix4MakeZRotation(-NEZ_ALETTERATION_LID_ROTATION);
	return GLKMatrix4Multiply(GLKMatrix4MakeTranslation(endPos.x, endPos.y, endPos.z), matRotZ);
}

+(GLKMatrix4)getLidRotationMatrix {
	GLKMatrix4 matRotX = GLKMatrix4MakeXRotation(-M_PI);
	GLKMatrix4 matRotZ = GLKMatrix4MakeZRotation(NEZ_ALETTERATION_LID_ROTATION);
	return GLKMatrix4Multiply(matRotX, matRotZ);
}

+(void)doAnimationFor:(NezAletterationSinglePlayerController*)controller WithStopBlock:(NezAnimationBlock)stopBlock {
	NezCamera *camera = [NezAletterationGameState getCamera];
	GLKVector3 fromData[] = {
		camera.eye, camera.target, camera.upVector
	};
	GLKVector3 toData[] = {
		GLKVector3Make(-5.0f, -10.0f, 5.0f), GLKVector3Make(0.0f, 0.0f, 0.0f), GLKVector3Make(0.0f, 0.0f, 1.0f)
	};
	NezAnimation *ani = [[NezAnimation alloc] initWithFromData:(float*)fromData ToData:(float*)toData DataLength:sizeof(GLKVector3)*3 Duration:1.0 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		float *data = ani->newData;
		[camera setEye:GLKVector3Make(data[0], data[1], data[2]) Target:GLKVector3Make(data[3], data[4], data[5]) UpVector:GLKVector3Make(data[6], data[7], data[8])];
	} DidStopBlock:^(NezAnimation *ani) {
		[NezAletterationAnimationInitial doAnimateBoxForwardWithStopBlock:^(NezAnimation *ani) {
			[NezAletterationAnimationInitial doAnimateFadeInDisplayLinesWithStopBlock:^(NezAnimation *ani) {}];
			[NezAletterationAnimationInitial doAnimateLidOffWithStopBlock:^(NezAnimation *ani) {}];
			[NezAletterationAnimationInitial doAnimateLetterGroupsWithStopBlock:^(NezAnimation *ani) {
				if ([NezAletterationGameState getTotalLetterCount] == [NezAletterationGameState getStackCurrentLetterCount]) {
					stopBlock(ani);
				}
			}];
			[controller animateCameraToDefaultWithDuration:3.50 moveSelectedBlock:YES andStopBlock:nil];
		}];
	}];
	[NezAnimator addAnimation:ani];
}

+(void)doAnimateFadeInDisplayLinesWithStopBlock:(NezAnimationBlock)stopBlock {
	NSArray *lineList = [NezAletterationGameState getDisplayLineList];
	NezAletterationDisplayLine *displayLine = lineList.lastObject;
	GLKVector4 color = displayLine.color1;
	float newAlpha = [NezAletterationDisplayLine defaultLineAlphaValue];
	NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:color.a ToData:newAlpha Duration:1.0 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		GLKVector4 c = color;
		c.a = ani->newData[0];
		for (NezAletterationDisplayLine *displayLine in lineList) {
			displayLine.color1 = c;
		}
	} DidStopBlock:stopBlock];
	[NezAnimator addAnimation:ani];
}

+(void)doAnimateBoxForwardWithStopBlock:(NezAnimationBlock)stopBlock {
	NezAletterationBox *box = [NezAletterationGameState getBox];
	GLKVector3 boxSize = box.size;
	GLKMatrix4 boxMatrix = box.modelMatrix;
	GLKMatrix4 rot = GLKMatrix4MakeRotation(M_PI*0.2, 1.0, -1.0, -1.0);
	rot.m30 = boxMatrix.m30 + boxSize.z;
	rot.m31 = boxMatrix.m31 + boxSize.y*0.5;
	rot.m32 = boxMatrix.m32 + boxSize.z*2.0f;
	
	float duration = 1.6;
	NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:boxMatrix ToData:rot Duration:duration*0.5 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		GLKMatrix4 *mat = (GLKMatrix4*)ani->newData;
		box.modelMatrix = *mat;
	} DidStopBlock:^(NezAnimation *ani) {
		stopBlock(ani);
	}];
	[NezAnimator addAnimation:ani];
}

+(void)doAnimateLidOffWithStopBlock:(NezAnimationBlock)stopBlock {
	NezAletterationBox *box = [NezAletterationGameState getBox];
	NezAletterationLid *lid = [box dettachLid];

	GLKMatrix4 lidMatrix = lid.modelMatrix;
	GLKVector3 midPoint = [lid getMidPoint];
	GLKMatrix4 matRotX = GLKMatrix4MakeXRotation(-M_PI/2.0);
	GLKMatrix4 lidRestMatrix = [NezAletterationAnimationInitial getLidRotationMatrix];

	NezCubicBezierAnimation *cbani = [[NezCubicBezierAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:1.5 EasingFunction:easeLinear UpdateBlock:^(NezAnimation *ani) {
		NezCubicBezierAnimation *cbani = (NezCubicBezierAnimation*)ani;
		float position = ani->newData[0];
		GLKMatrix4 mat = lidMatrix;
		
		float start = 0.15;
		float duration1 = 0.25;
		float duration2 = 0.5;
		float ONE = 1.0;
		
		if (position < start) {
			
		} else if (position < (start+duration1)) {
			float t = (position-start)*(ONE/duration1);
			mat.m00 = easeInCubic(t, lidMatrix.m00, matRotX.m00-lidMatrix.m00, ONE);
			mat.m01 = easeInCubic(t, lidMatrix.m01, matRotX.m01-lidMatrix.m01, ONE);
			mat.m02 = easeInCubic(t, lidMatrix.m02, matRotX.m02-lidMatrix.m02, ONE);
			
			mat.m10 = easeInCubic(t, lidMatrix.m10, matRotX.m10-lidMatrix.m10, ONE);
			mat.m11 = easeInCubic(t, lidMatrix.m11, matRotX.m11-lidMatrix.m11, ONE);
			mat.m12 = easeInCubic(t, lidMatrix.m12, matRotX.m12-lidMatrix.m12, ONE);
			
			mat.m20 = easeInCubic(t, lidMatrix.m20, matRotX.m20-lidMatrix.m20, ONE);
			mat.m21 = easeInCubic(t, lidMatrix.m21, matRotX.m21-lidMatrix.m21, ONE);
			mat.m22 = easeInCubic(t, lidMatrix.m22, matRotX.m22-lidMatrix.m22, ONE);
		} else if (position < (start+duration1+duration2)) {
			float t = (position-(start+duration1))*(ONE/duration2);
			mat.m00 = easeOutCubic(t, matRotX.m00, lidRestMatrix.m00-matRotX.m00, ONE);
			mat.m01 = easeOutCubic(t, matRotX.m01, lidRestMatrix.m01-matRotX.m01, ONE);
			mat.m02 = easeOutCubic(t, matRotX.m02, lidRestMatrix.m02-matRotX.m02, ONE);
			
			mat.m10 = easeOutCubic(t, matRotX.m10, lidRestMatrix.m10-matRotX.m10, ONE);
			mat.m11 = easeOutCubic(t, matRotX.m11, lidRestMatrix.m11-matRotX.m11, ONE);
			mat.m12 = easeOutCubic(t, matRotX.m12, lidRestMatrix.m12-matRotX.m12, ONE);
			
			mat.m20 = easeOutCubic(t, matRotX.m20, lidRestMatrix.m20-matRotX.m20, ONE);
			mat.m21 = easeOutCubic(t, matRotX.m21, lidRestMatrix.m21-matRotX.m21, ONE);
			mat.m22 = easeOutCubic(t, matRotX.m22, lidRestMatrix.m22-matRotX.m22, ONE);
		} else {
			mat.m00 = lidRestMatrix.m00;
			mat.m01 = lidRestMatrix.m01;
			mat.m02 = lidRestMatrix.m02;
			
			mat.m10 = lidRestMatrix.m10;
			mat.m11 = lidRestMatrix.m11;
			mat.m12 = lidRestMatrix.m12;
			
			mat.m20 = lidRestMatrix.m20;
			mat.m21 = lidRestMatrix.m21;
			mat.m22 = lidRestMatrix.m22;
		}
		GLKVector3 p = [cbani.bezier positionAt:position];
		mat.m30 = p.x;
		mat.m31 = p.y;
		mat.m32 = p.z;
		lid.modelMatrix = mat;
	} DidStopBlock:^(NezAnimation *ani) {
		stopBlock(ani);
	}];
	GLKVector3 endPos = [NezAletterationAnimationInitial getBoxEndPos];
	GLKVector3 P1 = {midPoint.x+(endPos.x-midPoint.x)*0.25, midPoint.y+(endPos.y-midPoint.y)*0.25, midPoint.z+(endPos.z-midPoint.z)*(-1.25)};
	GLKVector3 P2 = {midPoint.x+(endPos.x-midPoint.x)*0.75, midPoint.y+(endPos.y-midPoint.y)*0.75, midPoint.z+(endPos.z-midPoint.z)*(-1.25)};
	cbani.bezier = [[NezCubicBezier alloc] initWithControlPointsP0:midPoint P1:P1 P2:P2 P3:endPos];
	[NezAnimator addAnimation:cbani];
}

+(void)doAnimateLetterGroupsWithStopBlock:(NezAnimationBlock)stopBlock {
	GLKVector3 blockSize = [NezAletterationLetterBlock getBlockSize];
	float distance = blockSize.y*1.5;
	float duration = distance*0.5;

	NezAletterationBox *box = [NezAletterationGameState getBox];
	
	for (char letter='a'; letter <= 'z'; letter++) {
		NezAletterationLetterGroup *letterGroup = [box getLetterGroupForLetter:letter];
		letterGroup.isAttached = NO;

		GLKMatrix4 startMatrix = letterGroup.modelMatrix;
		GLKMatrix4 endMatrix = GLKMatrix4Translate(startMatrix, 0.0, distance, 0.0);
		NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:startMatrix ToData:endMatrix Duration:duration EasingFunction:easeInCubic UpdateBlock:^(NezAnimation *ani) {
			letterGroup.modelMatrix = *((GLKMatrix4*)ani->newData);
		} DidStopBlock:^(NezAnimation *ani) {
			[NezAletterationAnimationInitial doAnimateLetterGroup:letterGroup ToStackWithStopBlock:^(NezAnimation *ani) {
				stopBlock(ani);
			}];
		}];
		[NezAnimator addAnimation:ani];
	}
	[NezAletterationAnimationInitial doAnimateBoxDownWithDelay:duration];
}

+(void)doAnimateBoxDownWithDelay:(float)delay {
	NezAletterationBox *box = [NezAletterationGameState getBox];
	GLKMatrix4 startMatrix = box.modelMatrix;
	GLKMatrix4 endMatrix = [NezAletterationAnimationInitial getBoxEndMatrix];
	NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:startMatrix ToData:endMatrix Duration:1.0 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		box.modelMatrix = *((GLKMatrix4*)ani->newData);
	} DidStopBlock:NULL];
	ani->delay = delay;
	[NezAnimator addAnimation:ani];
}

+(void)doAnimateLetterGroup:(NezAletterationLetterGroup*)letterGroup ToStackWithStopBlock:(NezAnimationBlock)stopBlock {
	GLKMatrix4 letterGroupMatrix = letterGroup.modelMatrix;
	NezAletterationLetterStack *stack = [NezAletterationGameState getLetterStackForLetter:letterGroup.letter];
 	GLKVector3 stackPos = [stack getNextLetterBlockPosition];

	NezCubicBezierAnimation *cbani = [[NezCubicBezierAnimation alloc] initFloatWithFromData:0.0 ToData:0.75 Duration:0.75 EasingFunction:easeInCubic UpdateBlock:^(NezAnimation *ani) {
		NezCubicBezierAnimation *cbani = (NezCubicBezierAnimation*)ani;
		float position = ani->newData[0];
		GLKMatrix4 mat = letterGroupMatrix;

		GLKVector3 p = [cbani.bezier positionAt:position];

		float t = ani->elapsedTime;
		float duration = ani->duration;
		
		mat.m00 = easeInCubic(t, letterGroupMatrix.m00, 1.0-letterGroupMatrix.m00, duration);
		mat.m01 = easeInCubic(t, letterGroupMatrix.m01, -letterGroupMatrix.m01, duration);
		mat.m02 = easeInCubic(t, letterGroupMatrix.m02, -letterGroupMatrix.m02, duration);
		
		mat.m10 = easeInCubic(t, letterGroupMatrix.m10, -letterGroupMatrix.m10, duration);
		mat.m11 = easeInCubic(t, letterGroupMatrix.m11, 1.0-letterGroupMatrix.m11, duration);
		mat.m12 = easeInCubic(t, letterGroupMatrix.m12, -letterGroupMatrix.m12, duration);
		
		mat.m20 = easeInCubic(t, letterGroupMatrix.m20, -letterGroupMatrix.m20, duration);
		mat.m21 = easeInCubic(t, letterGroupMatrix.m21, -letterGroupMatrix.m21, duration);
		mat.m22 = easeInCubic(t, letterGroupMatrix.m22, 1.0-letterGroupMatrix.m22, duration);

		mat.m30 = p.x;
		mat.m31 = p.y;
		mat.m32 = p.z;
		letterGroup.modelMatrix = mat;
	} DidStopBlock:^(NezAnimation *ani) {
		[NezAletterationAnimationInitial doAnimateLetterGroup:letterGroup StackPushWithStopBlock:^(NezAnimation *ani) {
			stopBlock(ani);
		}];
	}];
	GLKVector3 endPos = stackPos;
	GLKVector3 midPoint = letterGroup.midPoint;
	GLKVector3 P1 = {midPoint.x+(endPos.x-midPoint.x)*0.25, midPoint.y+(endPos.y-midPoint.y)*0.25, midPoint.z+(endPos.z-midPoint.z)*(-1.0)};
	GLKVector3 P2 = {midPoint.x+(endPos.x-midPoint.x)*0.75, midPoint.y+(endPos.y-midPoint.y)*0.5, midPoint.z+(endPos.z-midPoint.z)*(-1.0)};
	cbani.bezier = [[NezCubicBezier alloc] initWithControlPointsP0:midPoint P1:P1 P2:P2 P3:endPos];
	[NezAnimator addAnimation:cbani];
}

+(void)doAnimateLetterGroup:(NezAletterationLetterGroup*)letterGroup StackPushWithStopBlock:(NezAnimationBlock)stopBlock {
	NezAletterationLetterStack *stack = [NezAletterationGameState getLetterStackForLetter:letterGroup.letter];

	float delayIncrement = 0.15;
	float delay = 0.0;
	
	for (int i=letterGroup.letterBlockList.count-1; i>=0; i--) {
		NezAletterationLetterBlock *letterBlock = [letterGroup.letterBlockList objectAtIndex:i];
		GLKVector3 stackPos = [stack getNextLetterBlockPosition];
		GLKMatrix4 stackMatrix = GLKMatrix4MakeTranslation(stackPos.x, stackPos.y, stackPos.z);
		GLKMatrix4 letterMatrix = letterBlock.modelMatrix;
		float distance = GLKVector3Distance(stackPos, letterBlock.midPoint);
		
		[stack deferredPushLetterBlock:letterBlock];
		
		NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:letterMatrix ToData:stackMatrix Duration:distance*0.25 EasingFunction:easeInCubic UpdateBlock:^(NezAnimation *ani) {
			letterBlock.modelMatrix = *((GLKMatrix4*)ani->newData);
		} DidStopBlock:^(NezAnimation *ani) {
			[stack finishPushLetterBlock:letterBlock];
			stopBlock(ani);
		}];
		ani->delay = delay;
		[NezAnimator addAnimation:ani];
		delay += delayIncrement;
	}
}

@end
