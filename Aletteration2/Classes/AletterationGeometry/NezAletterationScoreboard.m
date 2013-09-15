//
//  NezAletterationScoreboard.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-11-16.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAletterationScoreboard.h"
#import "NezAletterationLetterBlock.h"
#import "NezAppDelegate.h"
#import "NezCamera.h"
#import "NezAnimator.h"
#import "NezAnimation.h"

@implementation NezAletterationScoreboard

+(id)scoreboardWithStartingPosition:(GLKVector3)pos andLineSpace:(float)lineSpace {
	return [[NezAletterationScoreboard alloc] initWithStartingPosition:pos andLineSpace:lineSpace];
}

-(id)initWithStartingPosition:(GLKVector3)pos andLineSpace:(float)lineSpace  {
	if ((self = [super init])) {
		_retiredWordList = [NSMutableArray arrayWithCapacity:16];
		_pos = pos;
		_lineSpace = lineSpace;
		_wordBounds[0] = pos;
		_wordBounds[1] = pos;
	}
	return self;
}


-(void)recalculateBounds {
	_wordBounds[0] = _pos;
	_wordBounds[1] = _pos;
	
	for (NezAletterationRetiredWord *retiredWord in _retiredWordList) {
		[self recalculateBoundsWithRetiredWord:retiredWord];
	}
}

-(void)recalculateBoundsWithRetiredWord:(NezAletterationRetiredWord*)retiredWord {
	for (NezAletterationLetterBlock *letterBlock in retiredWord.letterBlockList) {
		if (_wordBounds[0].x > letterBlock.minX) {
			_wordBounds[0].x = letterBlock.minX;
		}
		if (_wordBounds[0].y > letterBlock.minY) {
			_wordBounds[0].y = letterBlock.minY;
		}
		if (_wordBounds[0].z > letterBlock.minZ) {
			_wordBounds[0].z = letterBlock.minZ;
		}
		if (_wordBounds[1].x < letterBlock.maxX) {
			_wordBounds[1].x = letterBlock.maxX;
		}
		if (_wordBounds[1].y < letterBlock.maxY) {
			_wordBounds[1].y = letterBlock.maxY;
		}
		if (_wordBounds[1].z < letterBlock.maxZ) {
			_wordBounds[1].z = letterBlock.maxZ;
		}
	}
}

-(NezAletterationRetiredWord*)removeLastRetiredWord {
	NezAletterationRetiredWord *retiredWord = _retiredWordList.lastObject;
	[_retiredWordList removeLastObject];
	return retiredWord;
}

-(void)addRetiredWord:(NezAletterationRetiredWord*)retiredWord {
	GLKVector3 size = [NezAletterationLetterBlock getBlockSize];
	GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(_pos.x, _pos.y-(size.y+_lineSpace)*_retiredWordList.count, _pos.z);
	retiredWord.modelMatrix = modelMatrix;
	[_retiredWordList addObject:retiredWord];
	[self recalculateBoundsWithRetiredWord:retiredWord];
}

-(void)addRetiredWord:(NezAletterationRetiredWord*)retiredWord withStopBlock:(NezGCDBlock)stopBlock {
	GLKVector3 size = [NezAletterationLetterBlock getBlockSize];
	GLKMatrix4 matrix = retiredWord.modelMatrix;
	GLKVector3 startPosition = GLKVector3Make(matrix.m30, matrix.m31, matrix.m32);
	GLKVector3 endPosition = GLKVector3Make(_pos.x, _pos.y-(size.y+_lineSpace)*_retiredWordList.count, _pos.z);
	
	NezAnimation *ani = [[NezAnimation alloc] initVec3WithFromData:startPosition ToData:endPosition Duration:2.5 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		GLKVector3 *midPoint = (GLKVector3*)ani->newData;
		GLKMatrix4 modelMatrix = matrix;
		modelMatrix.m30 = midPoint->x;
		modelMatrix.m31 = midPoint->y;
		modelMatrix.m32 = midPoint->z;
		retiredWord.modelMatrix = modelMatrix;
	} DidStopBlock:^(NezAnimation *ani) {
		[_retiredWordList addObject:retiredWord];
		[self recalculateBoundsWithRetiredWord:retiredWord];
		if (stopBlock) {
			stopBlock();
		}
	}];
	[NezAnimator addAnimation:ani];
}

-(GLKVector3)getCameraTarget {
	GLKVector3 boundsMidPoint = GLKVector3Make((_wordBounds[0].x+_wordBounds[1].x)/2.0, 0.0, (_wordBounds[0].z+_wordBounds[1].z)/2.0);
	return boundsMidPoint;
}

-(NezCamera*)getCameraWithCurrentCamera:(NezCamera*)camera andDefaultZ:(float)z {
	GLKVector3 target = [self getCameraTarget];
	GLKVector3 eye = GLKVector3Make(target.x, target.y, z);
	NezCamera *cam = [[NezCamera alloc] initWithEye:eye Target:target UpVector:camera.upVector];
	[cam setupProjectionMatrix:camera.viewport];
	GLKVector2 pos = [cam getScreenCoordinates:GLKVector3Make(0.0, _wordBounds[0].y, 0.0)];
	if (pos.y < 5) {
		target.y = (_wordBounds[0].y+_wordBounds[1].y)/2.0;
		float zoom = z;
		for (;;) {
			pos = [cam getScreenCoordinates:GLKVector3Make(0.0, _wordBounds[0].y, 0.0)];
			if (pos.y > 5.1) {
				zoom /= 2.0;
				[cam setEye:GLKVector3Make(target.x, target.y, cam.eye.z-zoom) Target:target UpVector:cam.upVector];
			} else if (pos.y < 4.9) {
				zoom *= 1.5;
				[cam setEye:GLKVector3Make(target.x, target.y, cam.eye.z+zoom) Target:target UpVector:cam.upVector];
			} else {
				break;
			}
		}
	}
	return cam;
}

-(void)reset {
	_wordBounds[0] = _pos;
	_wordBounds[1] = _pos;
	
	[_retiredWordList removeAllObjects];
}

@end
