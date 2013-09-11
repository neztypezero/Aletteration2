//
//  NezAletterationLetterStack.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-11-06.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAletterationLetterStack.h"
#import "NezAletterationGameState.h"
#import "NezAletterationLetterBlock.h"
#import "NezAnimation.h"
#import "NezAnimator.h"

#define NEZ_ALETTERATION_LETTER_STACK_SCALE 0.75

@implementation NezAletterationLetterStack

-(id)initWithVertexArray:(NezVertexArray *)vertexArray {
	if ((self = [super initWithVertexArray:vertexArray modelMatrix:GLKMatrix4Identity color:GLKVector4Make(1.0, 1.0, 1.0, 1.0)])) {
		_letterBlockStack = [NSMutableArray arrayWithCapacity:4];
		_deferredBlockCount = 0;
		self.color2 = GLKVector4Make(1.0, 1.0, 1.0, 0.0);
	}
	return self;
}

-(GLKVector3)getLetterBlockBasePosition {
	GLKVector3 size = [NezAletterationLetterBlock getBlockSize];
	float spacer = ([NezAletterationGameState getLineWidth]/13.5)-size.x;
	size.x+=spacer;

	int letterIndex = _letter - 'a';
	float dx = -size.x*6.0f+(size.x*letterIndex);
	float dy = -size.y*1.9f;
	if (_letter > 'm') {
		dx -= size.x*13.0f;
		dy -= size.y*1.85f;
	}
	return GLKVector3Make(dx, dy, 0.0);
}

-(GLKVector3)getNextLetterBlockPosition {
	GLKVector3 size = [NezAletterationLetterBlock getBlockSize];
	GLKVector3 pos = [self getLetterBlockBasePosition];
	pos.z = size.z/2.0+(size.z*_letterBlockStack.count);
	return pos;
}

-(GLKVector4)getUV {
	int index = _letterBlockStack.count-_deferredBlockCount;
	int x = index%8;
	int y = index/8;
	
	GLKVector4 uv = GLKVector4Make(((float)x+1)/8.0, ((float)y)/8.0, ((float)(x))/8.0, ((float)(y+1))/8.0);
	return uv;
}

-(GLKMatrix4)getScaledMatrix:(float)scale {
	return GLKMatrix4Multiply(GLKMatrix4MakeTranslation(_originalPosition.x, _originalPosition.y, 0.0), GLKMatrix4MakeScale(scale, scale, 1.0));
}

-(void)setLetter:(char)letter {
	_letter = letter;

	GLKVector3 size = [NezAletterationLetterBlock getBlockSize];
	_originalPosition = [self getLetterBlockBasePosition];
	_originalPosition.y -= size.y;
	_originalModelMatrix = [self getScaledMatrix:NEZ_ALETTERATION_LETTER_STACK_SCALE];
	self.modelMatrix = _originalModelMatrix;

	[self setUV:[self getUV]];
}

-(BOOL)containsLetterBlock:(NezAletterationLetterBlock*)letterBlock {
	for (NezAletterationLetterBlock *block in _letterBlockStack) {
		if (block == letterBlock) {
			return YES;
		}
	}
	return NO;
}

-(void)pushLetterBlock:(NezAletterationLetterBlock*)letterBlock {
	[self deferredPushLetterBlock:letterBlock];
	GLKVector3 pos = [self getNextLetterBlockPosition];
	letterBlock.modelMatrix = GLKMatrix4MakeTranslation(pos.x, pos.y, pos.z);
	[self finishPushLetterBlock:letterBlock];
}

-(void)deferredPushLetterBlock:(NezAletterationLetterBlock*)letterBlock {
	[_letterBlockStack addObject:letterBlock];
	_deferredBlockCount++;
}

-(void)finishPushLetterBlock:(NezAletterationLetterBlock*)letterBlock {
	_deferredBlockCount--;
	[self changeCounter];
}

-(int)getDeferredCount {
	return _deferredBlockCount;
}

-(NezAletterationLetterBlock*)popLetterBlock:(BOOL)isAnimated {
	NezAletterationLetterBlock *letterBlock = _letterBlockStack.lastObject;
	if (letterBlock != nil) {
		[_letterBlockStack removeLastObject];
	}
	if (isAnimated) {
		[self animateChangeCounter];
	} else {
		[self changeCounter];
	}
	return letterBlock;
}

-(void)changeCounter {
	[self setUV:[self getUV]];
	if (_letterBlockStack.count > 0) {
		self.mix = 0.0;
	} else {
		self.mix = 1.0;
	}
}

-(int)getCount {
	return _letterBlockStack.count;
}

-(void)animateChangeCounter {
	[self fadeCounterTo:0.0 withStopBlock:^(NezAnimation *ani) {
		[self changeCounter];
		if (_letterBlockStack.count > 0) {
			[self fadeCounterTo:1.0 withStopBlock:nil];
		}
	}];

	NezAnimation *aniScale = [[NezAnimation alloc] initFloatWithFromData:NEZ_ALETTERATION_LETTER_STACK_SCALE ToData:NEZ_ALETTERATION_LETTER_STACK_SCALE*2.0 Duration:0.25 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		self.modelMatrix = [self getScaledMatrix:ani->newData[0]];
	} DidStopBlock:^(NezAnimation *ani) {
		self.modelMatrix = [self getScaledMatrix:NEZ_ALETTERATION_LETTER_STACK_SCALE];
	}];
	[NezAnimator addAnimation:aniScale];
}

-(void)fadeCounterTo:(float)alpha withStopBlock:(NezAnimationBlock)stopBlock {
	NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:self.mix ToData:1.0-alpha Duration:0.25 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		self.mix = ani->newData[0];
	} DidStopBlock:stopBlock];
	[NezAnimator addAnimation:ani];
}

@end
