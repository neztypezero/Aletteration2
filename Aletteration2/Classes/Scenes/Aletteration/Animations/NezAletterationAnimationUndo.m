//
//  NezAletterationAnimationUndo.m
//  Aletteration2
//
//  Created by David Nesbitt on 2013-09-12.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAletterationAnimationUndo.h"
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
#import "NezAletterationRetiredWord.h"

@implementation NezAletterationAnimationUndo

+(void)doAnimationFor:(NezAletterationSinglePlayerController*)controller withRetiredWordList:(NSArray*)retiredWordList andStopBlock:(NezAnimationBlock)stopBlock {
	[controller animateCameraToDefaultWithDuration:0.25 moveSelectedBlock:YES andStopBlock:^(NezAnimation *ani) {
		[NezAletterationAnimationUndo doAnimateRestack:controller withStopBlock:^(NezAnimation *ani) {
			for (NezAletterationRetiredWord *retiredWord in retiredWordList) {
				[NezAletterationAnimationUndo doAnimateUnretireWord:retiredWord withStopBlock:^(NezAnimation *ani) {
					
				}];
			}
			stopBlock(ani);
		}];
	}];
}

+(void)doAnimateRestack:(NezAletterationSinglePlayerController*)controller withStopBlock:(NezAnimationBlock)stopBlock {
	NezAletterationLetterBlock *letterBlock = controller.selectedBlock;
	NezAletterationLetterStack *stack = [NezAletterationGameState getLetterStackForLetter:letterBlock.letter];
	
	GLKVector3 stackPos = [stack getNextLetterBlockPosition];
	GLKMatrix4 stackMatrix = GLKMatrix4MakeTranslation(stackPos.x, stackPos.y, stackPos.z);
	GLKMatrix4 letterMatrix = letterBlock.modelMatrix;

	[stack deferredPushLetterBlock:letterBlock];
	
	NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:letterMatrix ToData:stackMatrix Duration:0.25 EasingFunction:easeInCubic UpdateBlock:^(NezAnimation *ani) {
		letterBlock.modelMatrix = *((GLKMatrix4*)ani->newData);
	} DidStopBlock:^(NezAnimation *ani) {
		[stack finishPushLetterBlock:letterBlock];
		stopBlock(ani);
	}];
	[NezAnimator addAnimation:ani];
}

+(void)doAnimateUnretireWord:(NezAletterationRetiredWord*)retiredWord withStopBlock:(NezAnimationBlock)stopBlock {
	NezAletterationDisplayLine *displayLine = [[NezAletterationGameState getDisplayLineList] objectAtIndex:retiredWord.lineIndex];
	GLKVector3 nextBlockPosition = [displayLine getNextLetterBlockPosition];
	GLKMatrix4 startMatrix = retiredWord.modelMatrix;
	GLKMatrix4 endMatrix = GLKMatrix4MakeTranslation(nextBlockPosition.x, nextBlockPosition.y, nextBlockPosition.z);
	
	NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:startMatrix ToData:endMatrix Duration:1.0 EasingFunction:easeInCubic UpdateBlock:^(NezAnimation *ani) {
		retiredWord.modelMatrix = *((GLKMatrix4*)ani->newData);
	} DidStopBlock:^(NezAnimation *ani) {
		stopBlock(ani);
	}];
	[NezAnimator addAnimation:ani];
}

@end
