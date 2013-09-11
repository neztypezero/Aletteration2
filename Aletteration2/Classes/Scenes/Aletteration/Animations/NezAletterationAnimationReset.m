//
//  NezAletterationAnimationReset.m
//  Aletteration2
//
//  Created by David Nesbitt on 2013-09-08.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAletterationAnimationReset.h"
#import "NezAnimator.h"
#import "NezCamera.h"
#import "NezAletterationBox.h"
#import "NezAletterationLid.h"
#import "NezAletterationGameState.h"
#import "NezCubicBezierAnimation.h"
#import "NezCubicBezier.h"
#import "NezAletterationLetterStack.h"
#import "NezSinglePlayerAletterationController.h"
#import "NezAletterationDisplayLine.h"

const float NEZ_ALETTERATION_LID_ROTATION = 1.1;

@implementation NezAletterationAnimationReset

+(void)doAnimationFor:(NezSinglePlayerAletterationController*)controller WithStopBlock:(NezAnimationBlock)stopBlock {
	[controller animateCameraToDefaultWithDuration:0.25 moveSelectedBlock:NO andStopBlock:^(NezAnimation *ani) {
		[NezAletterationAnimationReset doAnimateCamera3QuarterView:^(NezAnimation *ani) {
		}];
	}];
	[NezAletterationAnimationReset doAnimateRestackWithStopBlock:^(NezAnimation *ani) {
		if ([NezAletterationGameState getStackCurrentLetterCount] == [NezAletterationGameState getTotalLetterCount]) {
			[NezAletterationAnimationReset doAnimateBlocksToLetterGroupWithStopBlock:^(NezAnimation *ani) {
				if ([NezAletterationGameState getStackCurrentLetterCount] == 0) {
					[NezAletterationAnimationReset doAnimateLetterGroupsToBoxWithStopBlock:^(NezAnimation *ani) {
						NezAletterationBox *box = [NezAletterationGameState getBox];
						if ([box areAllLetterGroupsAttached]) {
							[NezAletterationAnimationReset doAnimateBoxToOriginalLocationWithStopBlock:^(NezAnimation *ani) {
							}];
							[NezAletterationAnimationReset doAnimateLidToAboveBoxWithStopBlock:^(NezAnimation *ani) {
								[NezAletterationAnimationReset doAnimateLidToBoxWithStopBlock:^(NezAnimation *ani) {
								}];
							}];
							[NezAletterationAnimationReset doAnimateCameraToAletterationView:^(NezAnimation *ani) {
								stopBlock(ani);
							}];
						}
					}];
				}
			}];
		}
	}];
	[NezAletterationAnimationReset doAnimateFadeOutDisplayLinesWithStopBlock:^(NezAnimation *ani) {}];
	[NezAletterationAnimationReset doAnimateBoxupWithStopBlock:^(NezAnimation *ani) {}];
}

+(void)doAnimateCamera3QuarterView:(NezAnimationBlock)stopBlock {
	NezCamera *camera = [NezAletterationGameState getCamera];
	GLKVector3 fromData[] = {
		camera.eye, camera.target, camera.upVector
	};
	GLKVector3 toData[] = {
		GLKVector3Make(-3.75f, -7.5f, 3.75f), GLKVector3Make(0.0f, 0.0f, 0.0f), GLKVector3Make(0.0f, 0.0f, 1.0f)
	};
	NezAnimation *ani = [[NezAnimation alloc] initWithFromData:(float*)fromData ToData:(float*)toData DataLength:sizeof(GLKVector3)*3 Duration:1.0 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		float *data = ani->newData;
		[camera setEye:GLKVector3Make(data[0], data[1], data[2]) Target:GLKVector3Make(data[3], data[4], data[5]) UpVector:GLKVector3Make(data[6], data[7], data[8])];
	} DidStopBlock:^(NezAnimation *ani) {
		stopBlock(ani);
	}];
	[NezAnimator addAnimation:ani];
}

+(void)doAnimateCameraToAletterationView:(NezAnimationBlock)stopBlock {
	NezCamera *camera = [NezAletterationGameState getCamera];
	GLKVector3 fromData[] = {
		camera.eye, camera.target, camera.upVector
	};
	GLKVector3 toData[] = {
		GLKVector3Make(0.0f, -10.0f, 20.0f), GLKVector3Make(.0f, 0.0f, 20.0f), GLKVector3Make(0.0f, 0.0f, 1.0f)
	};
	NezAnimation *ani = [[NezAnimation alloc] initWithFromData:(float*)fromData ToData:(float*)toData DataLength:sizeof(GLKVector3)*3 Duration:3.0 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		float *data = ani->newData;
		[camera setEye:GLKVector3Make(data[0], data[1], data[2]) Target:GLKVector3Make(data[3], data[4], data[5]) UpVector:GLKVector3Make(data[6], data[7], data[8])];
	} DidStopBlock:^(NezAnimation *ani) {
		stopBlock(ani);
	}];
	[NezAnimator addAnimation:ani];
}

+(void)doAnimateRestackWithStopBlock:(NezAnimationBlock)stopBlock {
	NSArray *letterBlockList = [NezAletterationGameState getLetterBlockList];
	for (NezAletterationLetterBlock *letterBlock in letterBlockList) {
		NezAletterationLetterStack *stack = [NezAletterationGameState getLetterStackForLetter:letterBlock.letter];
		if (![stack containsLetterBlock:letterBlock]) {
			GLKVector3 endPos = [stack getNextLetterBlockPosition];
			GLKVector3 midPoint = [letterBlock getMidPoint];
			GLKMatrix4 curveMat = GLKMatrix4MakeTranslation(endPos.x, endPos.y, endPos.z);
			
			[stack deferredPushLetterBlock:letterBlock];
			
			GLKVector3 P1 = {midPoint.x+(endPos.x-midPoint.x)*0.25, midPoint.y+(endPos.y-midPoint.y)*0.25, 6.0};
			GLKVector3 P2 = {midPoint.x+(endPos.x-midPoint.x)*0.75, midPoint.y+(endPos.y-midPoint.y)*0.50, 6.0};
			NezCubicBezier *bezier = [[NezCubicBezier alloc] initWithControlPointsP0:midPoint P1:P1 P2:P2 P3:endPos];
			NezCubicBezierAnimation *curveAni = [[NezCubicBezierAnimation alloc] initMat4WithFromData:letterBlock.modelMatrix ToData:curveMat Duration:0.75 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *anim) {
				NezCubicBezierAnimation *ani = (NezCubicBezierAnimation*)anim;
				float t = (ani->elapsedTime/ani->duration);
				GLKMatrix4 *mat = (GLKMatrix4*)ani->newData;
				GLKVector3 p = [ani.bezier positionAt:t];
				mat->m30 = p.x;
				mat->m31 = p.y;
				mat->m32 = p.z;
				letterBlock.modelMatrix = *mat;
			} DidStopBlock:^(NezAnimation *ani) {
				[stack finishPushLetterBlock:letterBlock];
				stopBlock(ani);
			}];
			curveAni.bezier = bezier;
			[NezAnimator addAnimation:curveAni];
			
			NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:letterBlock.mix ToData:0.0 Duration:1.0 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
				letterBlock.mix = ani->newData[0];
			} DidStopBlock:nil];
			[NezAnimator addAnimation:ani];
		}
	}
}

+(void)doAnimateBlocksToLetterGroupWithStopBlock:(NezAnimationBlock)stopBlock {
	NezAletterationBox *box = [NezAletterationGameState getBox];
	for (char letter='a'; letter <= 'z'; letter++) {
		NezAletterationLetterGroup *letterGroup = [box getLetterGroupForLetter:letter];
		NezAletterationLetterStack *stack = [NezAletterationGameState getLetterStackForLetter:letter];
		[letterGroup.letterBlockList enumerateObjectsUsingBlock:^(NezAletterationLetterBlock *letterBlock, NSUInteger idx, BOOL *stop) {
			GLKMatrix4 startMatrix = letterBlock.modelMatrix;
			GLKMatrix4 endMatrix = [letterGroup getMatrixForIndex:idx];
			
			NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:startMatrix ToData:endMatrix Duration:0.5 EasingFunction:easeInCubic UpdateBlock:^(NezAnimation *ani) {
				letterBlock.modelMatrix = *((GLKMatrix4*)ani->newData);
			} DidStopBlock:^(NezAnimation *ani) {
				[stack popLetterBlock:YES];
				stopBlock(ani);
			}];
			[NezAnimator addAnimation:ani];
		}];
	}
}

+(void)doAnimateLetterGroupsToBoxWithStopBlock:(NezAnimationBlock)stopBlock {
	NezAletterationBox *box = [NezAletterationGameState getBox];
	
	for (char letter='a'; letter <= 'z'; letter++) {
		NezAletterationLetterGroup *letterGroup = [box getLetterGroupForLetter:letter];
		GLKMatrix4 startMatrix = letterGroup.modelMatrix;
		GLKMatrix4 endMatrix = GLKMatrix4Translate([box getMatrixForLetterGroup:letterGroup], 0.0, box.size.z, 0.0);
		
		NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:startMatrix ToData:endMatrix Duration:1.0 EasingFunction:easeLinear UpdateBlock:^(NezAnimation *ani) {
			letterGroup.modelMatrix = *((GLKMatrix4*)ani->newData);
		} DidStopBlock:^(NezAnimation *ani) {
			[NezAletterationAnimationReset doAnimateLetterGroup:letterGroup ToBoxWithStopBlock:stopBlock];
		}];
		[NezAnimator addAnimation:ani];
	}
}

+(void)doAnimateLetterGroup:(NezAletterationLetterGroup*)letterGroup ToBoxWithStopBlock:(NezAnimationBlock)stopBlock {
	NezAletterationBox *box = [NezAletterationGameState getBox];
	
	GLKMatrix4 startMatrix = letterGroup.modelMatrix;
	GLKMatrix4 endMatrix = [box getMatrixForLetterGroup:letterGroup];
	
	NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:startMatrix ToData:endMatrix Duration:0.35 EasingFunction:easeOutCubic UpdateBlock:^(NezAnimation *ani) {
		letterGroup.modelMatrix = *((GLKMatrix4*)ani->newData);
	} DidStopBlock:^(NezAnimation *ani) {
		letterGroup.isAttached = YES;
		stopBlock(ani);
	}];
	[NezAnimator addAnimation:ani];
}

+(void)doAnimateBoxToOriginalLocationWithStopBlock:(NezAnimationBlock)stopBlock {
	NezAletterationBox *box = [NezAletterationGameState getBox];

	GLKMatrix4 startMatrix = box.modelMatrix;
	GLKMatrix4 endMatrix = [NezAletterationGameState getOriginalBoxMatrix];

	NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:startMatrix ToData:endMatrix Duration:1.0 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		box.modelMatrix = *((GLKMatrix4*)ani->newData);
	} DidStopBlock:^(NezAnimation *ani) {
		stopBlock(ani);
	}];
	[NezAnimator addAnimation:ani];
}

+(void)doAnimateLidToAboveBoxWithStopBlock:(NezAnimationBlock)stopBlock {
	NezAletterationBox *box = [NezAletterationGameState getBox];
	NezAletterationLid *lid = [NezAletterationGameState getLid];

	GLKMatrix4 startMatrix = lid.modelMatrix;
	GLKMatrix4 endMatrix = [box getMatrixForLid:lid WithBoxMatrix:[NezAletterationGameState getOriginalBoxMatrix]];
	GLKMatrix4 matRotX = GLKMatrix4MakeXRotation(-M_PI/2.0);

	NezCubicBezierAnimation *cbani = [[NezCubicBezierAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:1.5 EasingFunction:easeInCubic UpdateBlock:^(NezAnimation *ani) {
		NezCubicBezierAnimation *cbani = (NezCubicBezierAnimation*)ani;
		float position = ani->newData[0];
		GLKVector3 p = [cbani.bezier positionAt:position];

		GLKMatrix4 mat = startMatrix;
		
		float start = 0.15;
		float duration1 = 0.45;
		float duration2 = 0.45;
		float ONE = 1.0;
		
		if (position < start) {
			
		} else if (position < (start+duration1)) {
			float t = (position-start)*(ONE/duration1);
			mat.m00 = easeInCubic(t, startMatrix.m00, matRotX.m00-startMatrix.m00, ONE);
			mat.m01 = easeInCubic(t, startMatrix.m01, matRotX.m01-startMatrix.m01, ONE);
			mat.m02 = easeInCubic(t, startMatrix.m02, matRotX.m02-startMatrix.m02, ONE);
			
			mat.m10 = easeInCubic(t, startMatrix.m10, matRotX.m10-startMatrix.m10, ONE);
			mat.m11 = easeInCubic(t, startMatrix.m11, matRotX.m11-startMatrix.m11, ONE);
			mat.m12 = easeInCubic(t, startMatrix.m12, matRotX.m12-startMatrix.m12, ONE);
			
			mat.m20 = easeInCubic(t, startMatrix.m20, matRotX.m20-startMatrix.m20, ONE);
			mat.m21 = easeInCubic(t, startMatrix.m21, matRotX.m21-startMatrix.m21, ONE);
			mat.m22 = easeInCubic(t, startMatrix.m22, matRotX.m22-startMatrix.m22, ONE);
		} else if (position < (start+duration1+duration2)) {
			float t = (position-(start+duration1))*(ONE/duration2);
			mat.m00 = easeOutCubic(t, matRotX.m00, endMatrix.m00-matRotX.m00, ONE);
			mat.m01 = easeOutCubic(t, matRotX.m01, endMatrix.m01-matRotX.m01, ONE);
			mat.m02 = easeOutCubic(t, matRotX.m02, endMatrix.m02-matRotX.m02, ONE);
			
			mat.m10 = easeOutCubic(t, matRotX.m10, endMatrix.m10-matRotX.m10, ONE);
			mat.m11 = easeOutCubic(t, matRotX.m11, endMatrix.m11-matRotX.m11, ONE);
			mat.m12 = easeOutCubic(t, matRotX.m12, endMatrix.m12-matRotX.m12, ONE);
			
			mat.m20 = easeOutCubic(t, matRotX.m20, endMatrix.m20-matRotX.m20, ONE);
			mat.m21 = easeOutCubic(t, matRotX.m21, endMatrix.m21-matRotX.m21, ONE);
			mat.m22 = easeOutCubic(t, matRotX.m22, endMatrix.m22-matRotX.m22, ONE);
		} else {
			mat = endMatrix;
		}

		mat.m30 = p.x;
		mat.m31 = p.y;
		mat.m32 = p.z;
		lid.modelMatrix = mat;
	} DidStopBlock:^(NezAnimation *ani) {
		stopBlock(ani);
	}];
	GLKVector3 startPoint = lid.midPoint;
	GLKVector3 endPoint = GLKVector3Make(endMatrix.m30, endMatrix.m31, endMatrix.m32+box.size.z*1.5);
	GLKVector3 P1 = {startPoint.x+(endPoint.x-startPoint.x)*0.25, startPoint.y+(endPoint.y-startPoint.y)*0.25, startPoint.z+(endPoint.z-startPoint.z)*(1.5)};
	GLKVector3 P2 = {startPoint.x+(endPoint.x-startPoint.x)*0.75, startPoint.y+(endPoint.y-startPoint.y)*0.75, startPoint.z+(endPoint.z-startPoint.z)*(2.5)};
	cbani.bezier = [[NezCubicBezier alloc] initWithControlPointsP0:startPoint P1:P1 P2:P2 P3:endPoint];
	[NezAnimator addAnimation:cbani];
}

+(void)doAnimateLidToBoxWithStopBlock:(NezAnimationBlock)stopBlock {
	NezAletterationBox *box = [NezAletterationGameState getBox];
	NezAletterationLid *lid = [NezAletterationGameState getLid];
	
	GLKMatrix4 startMatrix = lid.modelMatrix;
	GLKMatrix4 endMatrix = [box getMatrixForLid:lid WithBoxMatrix:[NezAletterationGameState getOriginalBoxMatrix]];
	
	NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:startMatrix ToData:endMatrix Duration:0.25 EasingFunction:easeOutCubic UpdateBlock:^(NezAnimation *ani) {
		lid.modelMatrix = *((GLKMatrix4*)ani->newData);
	} DidStopBlock:^(NezAnimation *ani) {
		[box attachLid:lid];
		stopBlock(ani);
	}];
	[NezAnimator addAnimation:ani];
}

+(void)doAnimateFadeOutDisplayLinesWithStopBlock:(NezAnimationBlock)stopBlock {
	NSArray *lineList = [NezAletterationGameState getDisplayLineList];
	NezAletterationDisplayLine *displayLine = lineList.lastObject;
	GLKVector4 color = displayLine.color1;
	NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:color.a ToData:0.0 Duration:1.0 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		GLKVector4 c = color;
		c.a = ani->newData[0];
		for (NezAletterationDisplayLine *displayLine in lineList) {
			displayLine.color1 = c;
		}
	} DidStopBlock:stopBlock];
	[NezAnimator addAnimation:ani];
}

+(void)doAnimateBoxupWithStopBlock:(NezAnimationBlock)stopBlock {
	NezAletterationBox *box = [NezAletterationGameState getBox];
	GLKVector3 boxSize = box.size;
	GLKMatrix4 boxMatrix = [NezAletterationGameState getOriginalBoxMatrix];
	GLKMatrix4 rot = GLKMatrix4MakeRotation(M_PI*0.2, 1.0, -1.0, -1.0);
	rot.m30 = boxMatrix.m30 + boxSize.z;
	rot.m31 = boxMatrix.m31 + boxSize.y*0.5;
	rot.m32 = boxMatrix.m32 + boxSize.z*2.0f;
	
	NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:box.modelMatrix ToData:rot Duration:1.0 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		GLKMatrix4 *mat = (GLKMatrix4*)ani->newData;
		box.modelMatrix = *mat;
	} DidStopBlock:stopBlock];
	[NezAnimator addAnimation:ani];
}

@end
