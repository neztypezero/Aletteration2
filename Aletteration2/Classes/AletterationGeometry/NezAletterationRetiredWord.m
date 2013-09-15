//
//  NezAletterationRetiredWord.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-11-15.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAletterationRetiredWord.h"
#import "NezAletterationLetterBlock.h"

@implementation NezAletterationRetiredWord

+(id)retiredWordWithLetterBlockList:(NSArray*)letterBlockList andLineIndex:(int)lineIndex {
	return [[NezAletterationRetiredWord alloc] initWithLetterBlockList:letterBlockList andLineIndex:lineIndex];
}

-(id)initWithLetterBlockList:(NSArray*)letterBlockList andLineIndex:(int)lineIndex  {
	if ((self = [super init])) {
		_letterBlockList = [NSArray arrayWithArray:letterBlockList];
		_string = @"";
		for (NezAletterationLetterBlock *letterBlock in _letterBlockList) {
			_string = [NSString stringWithFormat:@"%@%c", _string, letterBlock.letter];
		}
		_lineIndex = lineIndex;
	}
	return self;
}

-(GLKMatrix4)getModelMaxtrix {
	NezAletterationLetterBlock *letterBlock = _letterBlockList.firstObject;
	if (letterBlock) {
		return letterBlock.modelMatrix;
	} else {
		return GLKMatrix4Identity;
	}
}

-(void)setModelMaxtrix:(GLKMatrix4)modelMatrix {
	GLKVector3 size = [NezAletterationLetterBlock getBlockSize];
	for (NezAletterationLetterBlock *letterBlock in _letterBlockList) {
		letterBlock.modelMatrix = modelMatrix;
		modelMatrix = GLKMatrix4Translate(modelMatrix, size.x, 0.0, 0.0);
	}
}

@end
