//
//  NezAletterationBox.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-11-04.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezAletterationBox.h"
#import "NezAletterationLid.h"
#import "NezAletterationLetterBlock.h"
#import "NezSimpleObjLoader.h"
#import "NezAletterationGameState.h"

@implementation NezAletterationBoxLetterPlaceHolder

-(id)init {
	if ((self=[super init])) {
		_letterBlockList = [NSMutableArray arrayWithCapacity:4];
		_offset = GLKVector3Make(0.0, 0.0, 0.0);
	}
	return self;
}

-(void)addLetterBlock:(NezAletterationLetterBlock*)letterBlock {
	[_letterBlockList addObject:letterBlock];
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

-(void)updateMatrices:(GLKMatrix4)boxMatrix {
	float blockDepth = [NezAletterationLetterBlock getBlockSize].z;
	int i=0;
	GLKMatrix4 standingRotation = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-90.0), 1.0, 0.0, 0.0);
	for (NezAletterationLetterBlock *letterBlock in _letterBlockList) {
		GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(_position.x+_offset.x, _position.y+i*blockDepth+_offset.y, _position.z+_offset.z);
		i++;
		letterBlock.modelMatrix = GLKMatrix4Multiply(boxMatrix, GLKMatrix4Multiply(modelMatrix, standingRotation));
	}
}

@end

@interface NezAletterationBox () {
	NSMutableArray *_placeHolderList;
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
	
	if ((self = [super initWithVertexArray:vertexArray modelMatrix:mat color:c])) {
		_placeHolderList = [NSMutableArray arrayWithCapacity:26];
		for (char letter='a'; letter <= 'z'; letter++) {
			[_placeHolderList addObject:[[NezAletterationBoxLetterPlaceHolder alloc] init]];
		}
		self.boxObj = nil;
		_lid = nil;
	}
	return self;
}

-(void)updateAttachedObjectMatrices {
	if (_lid) {
		_lid.modelMatrix = GLKMatrix4TranslateWithVector3(self.modelMatrix, GLKVector3Make(0.0, 0.0, self.size.z-_lid.size.z+_lid.thickness));
	}
	for (NezAletterationBoxLetterPlaceHolder *placeHolder in _placeHolderList) {
		[placeHolder updateMatrices:self.modelMatrix];
	}
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
		NezAletterationBoxLetterPlaceHolder *placeHolder = [_placeHolderList objectAtIndex:letterBlock.letter-'a'];
		[placeHolder addLetterBlock:letterBlock];
	}
	[self layoutLetterBlocks];
}

-(NezAletterationBoxLetterPlaceHolder*)getPlaceHolderForLetter:(char)letter {
	NezAletterationBoxLetterPlaceHolder *placeHolder = [_placeHolderList objectAtIndex:letter-'a'];
	return placeHolder;
}

-(void)layoutX:(float)x Space:(float)totalSpace LetterPlaceHolderList:(NSArray*)letterPlaceHolderList {
	float y = -totalSpace/2.0;
	for (NezAletterationBoxLetterPlaceHolder *pHolder in letterPlaceHolderList) {
		pHolder.position = GLKVector3Make(x, y, self.size.z/2.0);
		y += pHolder.spaceUsed;
		[pHolder updateMatrices:self.modelMatrix];
	}
}

-(void)layoutLetterBlocks {
	GLKVector3 blockSize = [NezAletterationLetterBlock getBlockSize];
	GLKVector3 size = self.size;
	float boxLength = size.y*0.85;
	float totalSpace = 0.0;
	float x = -blockSize.x*0.54;
	NSMutableArray *letterPlaceHolderList = [NSMutableArray arrayWithCapacity:26];
	for (NezAletterationBoxLetterPlaceHolder *placeHolder in _placeHolderList) {
		if (totalSpace+placeHolder.spaceUsed > boxLength) {
			[self layoutX:x Space:totalSpace LetterPlaceHolderList:letterPlaceHolderList];
			x = blockSize.x*0.54;
			[letterPlaceHolderList removeAllObjects];
			totalSpace = 0.0;
		}
		totalSpace += placeHolder.spaceUsed;
		[letterPlaceHolderList addObject:placeHolder];
	}
	[self layoutX:x Space:totalSpace LetterPlaceHolderList:letterPlaceHolderList];
}

@end
