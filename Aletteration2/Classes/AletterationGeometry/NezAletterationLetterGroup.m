//
//  NezAletterationBox.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-11-04.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAletterationLetterGroup.h"

@implementation NezAletterationLetterGroup

-(id)initWithLetter:(char)letter {
	if ((self=[super init])) {
		_letterBlockList = [NSMutableArray arrayWithCapacity:4];
		self.letter = letter;
		self.isAttached = YES;
	}
	return self;
}

-(void)addLetterBlock:(NezAletterationLetterBlock*)letterBlock {
	[_letterBlockList addObject:letterBlock];
	[self setDimensions];
}

-(NSMutableArray*)getLetterBlockList {
	return _letterBlockList;
}

-(int)getCount {
	return _letterBlockList.count;
}

-(float)getSpaceUsed {
	return _letterBlockList.count*[NezAletterationLetterBlock getBlockSize].z;
}

-(void)setModelMaxtrix:(GLKMatrix4)modelMatrix {
	_modelMatrix = modelMatrix;
	
	[_letterBlockList enumerateObjectsUsingBlock:^(NezAletterationLetterBlock *letterBlock, NSUInteger idx, BOOL *stop) {
		letterBlock.modelMatrix = [self getMatrixForIndex:idx];
	}];

	[self setBoundingPoints];
}

-(void)setDimensions {
	_dimensions.x = [NezAletterationLetterBlock getBlockSize].x;
	_dimensions.y = [NezAletterationLetterBlock getBlockSize].y;
	_dimensions.z = [self getSpaceUsed];
	[self setBoundingPoints];
}

-(GLKMatrix4)getMatrixForIndex:(int)i {
	float blockSize = [NezAletterationLetterBlock getBlockSize].z;
	return GLKMatrix4Translate(_modelMatrix, 0.0, 0.0, blockSize*(-i));
}

@end
