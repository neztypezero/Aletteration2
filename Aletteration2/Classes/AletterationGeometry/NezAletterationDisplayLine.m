//
//  NezDisplayLine.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-26.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAletterationDisplayLine.h"
#import "NezAletterationLetterBlock.h"
#import "NezAnimator.h"
#import "NezAnimation.h"
#import "NezAletterationGameState.h"
#import "NezAletterationRetiredWord.h"

@implementation NezAletterationDisplayLine

-(id)initWithVertexArray:(NezVertexArray*)vertexArray modelMatrix:(GLKMatrix4)mat color:(GLKVector4)c lineIndex:(int)lineIndex {
	if ((self = [super initWithVertexArray:vertexArray modelMatrix:mat color:c])) {
		_letterBlockList = [NSMutableArray arrayWithCapacity:16];
		_lineIndex = lineIndex;
		c.a = 0.9;
		self.color2 = c;
		
		int length = [NezAletterationGameState getTotalLetterCount]+1;
		char letters[length];
		_stringData = [NSMutableData dataWithBytesNoCopy:letters length:length freeWhenDone:NO];
		_string = (char*)_stringData.bytes;
		[self reset];
	}
	return self;
}

-(void)reset {
	_string[0] = '\0';
	
	_currentWordIndex = 0;
	_currentWordLength = 0;
	_currentJunkLength = 0;
	_isHighlighted = NO;
	_junkOffset = 0;
	
	[_letterBlockList removeAllObjects];
}

-(GLKVector3)getNextLetterBlockPosition {
	GLKVector3 midPoint = [self getMidPoint];
	GLKVector3 size = [NezAletterationLetterBlock getBlockSize];
	float w = size.x;
	return GLKVector3Make(self.minX+w/2.0+w*_letterBlockList.count-_junkOffset*w, midPoint.y, midPoint.z+size.z/2.0);
}

-(void)addLetterBlock:(NezAletterationLetterBlock*)letterBlock {
	_string[_letterBlockList.count] = letterBlock.letter;
	[_letterBlockList addObject:letterBlock];
	_string[_letterBlockList.count] = '\0';
	[self setCurrentWordIndex:_currentWordIndex];
}

-(void)animateSelected {
	NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:self.mix ToData:1.0 Duration:0.25 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		self.mix = ani->newData[0];
	} DidStopBlock:nil];
	[NezAnimator addAnimation:ani];
}

-(void)animateDeselected {
	NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:self.mix ToData:0.0 Duration:0.25 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		self.mix = ani->newData[0];
	} DidStopBlock:nil];
	[NezAnimator addAnimation:ani];
}

-(char*)getString {
	return _string;
}

-(int)getCount {
	return _letterBlockList.count;
}

-(void)setCurrentWordIndex:(int)wordIndex {
	_currentWordIndex = wordIndex;
	_currentWordLength = self.count-wordIndex;
	_currentJunkLength = wordIndex;
}

-(int)getCurrentWordLength {
	return _currentWordLength;
}

-(int)getCurrentJunkLength {
	return _currentJunkLength;
}

-(char*)getCurrentWord {
	return _string+_currentWordIndex;
}

-(void)setLetterBlockColors:(BOOL)animated {
	GLKVector3 midPoint = [self getMidPoint];
	if (self.count > 0) {
		if ((_currentJunkLength - _junkOffset >= 4) || _junkOffset > _currentJunkLength || (_currentWordLength == 0 && _junkOffset >= _currentJunkLength)) {
			if (_currentWordLength > 0) {
				_junkOffset = _currentJunkLength;
			} else {
				_junkOffset = _currentJunkLength-1;
			}
			[self slideJunk:animated];
		}
		for (int i=0; i<_currentWordIndex; i++) {
			NezAletterationLetterBlock *letterBlock = [_letterBlockList objectAtIndex:i];
			letterBlock.mix = 1.0;
		}
		for (int i=_currentWordIndex; i<self.count; i++) {
			NezAletterationLetterBlock *letterBlock = [_letterBlockList objectAtIndex:i];
			letterBlock.mix = 0.0;
		}
	}
	if (self.isWord) {
		[self setBoundingPoints];
		GLKVector3 size = [NezAletterationLetterBlock getBlockSize];
		float xOffset = self.minX+(size.x*_currentJunkLength)-_junkOffset*size.x;
		float w = (size.x*_currentWordLength);
		float h = (_boundingBox[1].y-_boundingBox[0].y);
		[self.highlightRect setRectWidth:w*1.02 andHeight:h*1.12];
		[self.highlightRect setMidPoint:GLKVector3Make(xOffset+w/2.0, _boundingBox[0].y+h/2.0, midPoint.z+size.z)];
		if (_isHighlighted == NO) {
			_isHighlighted = YES;
			if (animated) {
				[self fadeHighlight:0.0];
			} else {
				self.highlightRect.mix = 0.0;
			}
		}
	} else {
		if (_isHighlighted == YES) {
			_isHighlighted = NO;
			if (animated) {
				[self fadeHighlight:1.0];
			} else {
				self.highlightRect.mix = 1.0;
			}
		}
	}
}

-(void)slideJunk:(BOOL)animated {
	GLKVector3 midPoint = [self getMidPoint];
	float w = [NezAletterationLetterBlock getBlockSize].x;
	GLKVector3 pos = GLKVector3Make(self.minX+w/2.0-_junkOffset*w, midPoint.y, midPoint.z);
	for (NezAletterationLetterBlock *letterBlock in _letterBlockList) {
		if (animated) {
			[self slideLetter:letterBlock toPos:pos];
		} else {
			[letterBlock setMidPoint:pos];
		}
		pos.x += w;
	}
}

-(void)slideLetter:(NezAletterationLetterBlock*)letterBlock toPos:(GLKVector3)pos {
	NezAnimation *ani = [[NezAnimation alloc] initVec3WithFromData:[letterBlock getMidPoint] ToData:pos Duration:0.25 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		GLKVector3 *pos = (GLKVector3*)ani->newData;
		[letterBlock setMidPoint:*pos];
	} DidStopBlock:nil];
	[NezAnimator addAnimation:ani];
}

-(void)fadeHighlight:(float)to {
	NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:1.0-to ToData:to Duration:0.25 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		self.highlightRect.mix = ani->newData[0];
	} DidStopBlock:nil];
	[NezAnimator addAnimation:ani];
}

-(NezAletterationRetiredWord*)retireHighlightedWord {
	NSRange wordRange = { _currentWordIndex, _currentWordLength };
	NSArray *letterBlockList = [_letterBlockList subarrayWithRange:wordRange];
	[_letterBlockList removeObjectsInRange:wordRange];

	_string[_currentWordIndex] = '\0';
	_currentWordLength = 0;
	_isWord = NO;
	
	return [NezAletterationRetiredWord retiredWordWithLetterBlockList:letterBlockList];
}

@end
