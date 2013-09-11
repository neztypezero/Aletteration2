//
//  NezAletterationBox.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-11-04.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAletterationBox.h"
#import "NezAletterationLid.h"
#import "NezAletterationLetterBlock.h"
#import "NezSimpleObjLoader.h"
#import "NezAletterationGameState.h"

@interface NezAletterationBox () {
	NSMutableArray *_letterGroupList;
}

@property(nonatomic,strong) NezSimpleObjLoader *boxObj;

@end

@implementation NezAletterationBox

-(int)getModelVertexCount {
	return _boxObj.vertexCount;
}

-(Vertex*)getModelVertexList {
	return _boxObj.vertexList;
}

-(unsigned short)getModelIndexCount {
	return _boxObj.indexCount;
}

-(unsigned short*)getModelIndexList {
	return _boxObj.indexList;
}

-(id)initWithVertexArray:(NezVertexArray *)vertexArray modelMatrix:(GLKMatrix4)mat color:(GLKVector4)c {
	self.boxObj = [[NezSimpleObjLoader alloc] initWithFile:@"box" Type:@"obj" Dir:@"Models"];
	
	//Model is slightly too small. Better to scale it in the 3d program but can't do it right now...
	Vertex *v = [self getModelVertexList];
	for (int i=0, n=[self getModelVertexCount]; i<n; i++) {
		v[i].pos = GLKVector3MultiplyScalar(v[i].pos, 1.05);
	}
	////////////////////////////////////////////////////////////////////////////////////////////////
	
	if ((self = [super initWithVertexArray:vertexArray modelMatrix:mat color:c])) {
		_letterGroupList = [NSMutableArray arrayWithCapacity:26];
		for (char letter='a'; letter <= 'z'; letter++) {
			[_letterGroupList addObject:[[NezAletterationLetterGroup alloc] initWithLetter:letter]];
		}
		self.boxObj = nil;
		_lid = nil;
	}
	return self;
}

-(void)updateAttachedObjectMatrices {
	if (_lid) {
		_lid.modelMatrix = [self getMatrixForLid:_lid WithBoxMatrix:self.modelMatrix];
	}
	for (NezAletterationLetterGroup *letterGroup in _letterGroupList) {
		if (letterGroup.isAttached) {
			letterGroup.modelMatrix = [self getMatrixForLetterGroup:letterGroup];
		}
	}
}

-(BOOL)areAllLetterGroupsAttached {
	for (NezAletterationLetterGroup *letterGroup in _letterGroupList) {
		if (!letterGroup.isAttached) {
			return NO;
		}
	}
	return YES;
}

-(void)attachLid:(NezAletterationLid*)lid {
	_lid = lid;
	[self updateAttachedObjectMatrices];
}

-(NezAletterationLid*)dettachLid {
	NezAletterationLid *lid = _lid;
	_lid = nil;
	return lid;
}

-(GLKMatrix4)getMatrixForLid:(NezAletterationLid*)lid WithBoxMatrix:(GLKMatrix4)boxMatrix {
	return GLKMatrix4TranslateWithVector3(boxMatrix, GLKVector3Make(0.0, 0.0, self.size.z-lid.size.z+lid.thickness));
}

-(void)translateWithDX:(float)dx DY:(float)dy DZ:(float)dz {
	[super translateWithDX:dx DY:dy DZ:dz];
	[self updateAttachedObjectMatrices];
}

-(void)setModelMaxtrix:(GLKMatrix4)mat {
	[super setModelMaxtrix:mat];
	[self updateAttachedObjectMatrices];
}

-(void)addLetterBlockList:(NSArray*)letterBlockList {
	for (NezAletterationLetterBlock *letterBlock in letterBlockList) {
		NezAletterationLetterGroup *letterGroup = [self getLetterGroupForLetter:letterBlock.letter];
		[letterGroup addLetterBlock:letterBlock];
	}
	[self layoutLetterBlocks];
}

-(NezAletterationLetterGroup*)getLetterGroupForLetter:(char)letter {
	NezAletterationLetterGroup *letterGroup = [_letterGroupList objectAtIndex:letter-'a'];
	return letterGroup;
}

-(GLKMatrix4)getMatrixForLetterGroup:(NezAletterationLetterGroup*)letterGroup {
	return GLKMatrix4Rotate(GLKMatrix4Translate(self.modelMatrix, letterGroup.offset.x, letterGroup.offset.y, letterGroup.offset.z), GLKMathDegreesToRadians(90.0), 1.0, 0.0, 0.0);
}

-(void)layoutX:(float)x Space:(float)totalSpace LetterGroupList:(NSArray*)letterGroupList {
	float y = -totalSpace/2.0;
	float z = self.size.z/2.0;
	for (NezAletterationLetterGroup *letterGroup in letterGroupList) {
		letterGroup.offset = GLKVector3Make(x, y, z);
		letterGroup.modelMatrix = [self getMatrixForLetterGroup:letterGroup];
		y += letterGroup.spaceUsed;
	}
}

-(void)layoutLetterBlocks {
	GLKVector3 blockSize = [NezAletterationLetterBlock getBlockSize];
	GLKVector3 size = self.size;
	float boxLength = size.y*0.85;
	float totalSpace = 0.0;
	float x = -blockSize.x*0.54;
	NSMutableArray *letterGroupList = [NSMutableArray arrayWithCapacity:26];
	for (NezAletterationLetterGroup *letterGroup in _letterGroupList) {
		if (totalSpace+letterGroup.spaceUsed > boxLength) {
			NSLog(@"%f, %f", totalSpace+letterGroup.spaceUsed, boxLength);
			[self layoutX:x Space:totalSpace LetterGroupList:letterGroupList];
			x = blockSize.x*0.54;
			[letterGroupList removeAllObjects];
			totalSpace = 0.0;
		}
		totalSpace += letterGroup.spaceUsed;
		[letterGroupList addObject:letterGroup];
	}
	if(totalSpace > 0) {
		[self layoutX:x Space:totalSpace LetterGroupList:letterGroupList];
	}
}

@end
