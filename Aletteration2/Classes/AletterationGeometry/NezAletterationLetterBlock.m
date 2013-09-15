//
//  NezLetterBlock.m
//  Aletteration
//
//  Created by David Nesbitt on 1/22/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

//#import "AletterationGameState.h"
//#import "OpenGLES2Graphics.h"
#import "NezAletterationLetterBlock.h"
//#import "AletterationBox.h"
//#import "Math.h"
#import "NezAnimator.h"
#import "NezAnimation.h"
#import "NezCubicBezierAnimation.h"
#import "NezSimpleObjLoader.h"
//#import "matrix.h"
//#import "NezOpenAL.h"
#import "NezCubicBezier.h"
#import "NezAletterationGameState.h"


NezVertexArray* BLOCK_VERTEX_ARRAY = nil;
GLKVector3 BLOCK_SIZE;

@implementation NezAletterationLetterBlock

+(GLKVector3)getBlockSize {
	return BLOCK_SIZE;
}

+(void)initialize {
	static BOOL initialized = NO;
	if(!initialized) {
		initialized = YES;
		NezSimpleObjLoader *blockObj = [[NezSimpleObjLoader alloc] initWithFile:@"block" Type:@"obj" Dir:@"Models"];
		BLOCK_VERTEX_ARRAY = blockObj.vertexArray;
		BLOCK_SIZE = blockObj.size;
	}
}

-(int)getModelVertexCount {
	return BLOCK_VERTEX_ARRAY.vertexCount;
}

-(Vertex*)getModelVertexList {
	return BLOCK_VERTEX_ARRAY.vertexList;
}

-(unsigned short)getModelIndexCount {
	return BLOCK_VERTEX_ARRAY.indexCount;
}

-(unsigned short*)getModelIndexList {
	return BLOCK_VERTEX_ARRAY.indexList;
}

-(id)initWithVertexArray:(NezVertexArray*)vertexArray letter:(char)blockLetter modelMatrix:(GLKMatrix4)mat color:(GLKVector4)c {
	if ((self = [super initWithVertexArray:vertexArray modelMatrix:mat color:c])) {
		_letter = blockLetter;

		int vertexCount = [self getModelVertexCount];
		Vertex *firstVertex = &vertexArray.vertexList[vertexArray.vertexCount-vertexCount];
		for (int i=0; i<vertexCount-4; i++) {
			firstVertex[i].uv.x = 0;
			firstVertex[i].uv.y = 0;
		}
		letterSquareVertexList[0] = firstVertex[vertexCount-4];
		letterSquareVertexList[1] = firstVertex[vertexCount-3];
		letterSquareVertexList[2] = firstVertex[vertexCount-2];
		letterSquareVertexList[3] = firstVertex[vertexCount-1];
		
		[self setUV:[self getUV]];

		self.color2 = GLKVector4Make(0.5, 0.5, 0.5, 1.0);
	}
	return self;
}

-(GLKVector4)getUV {
	int index = _letter-'a';
	int x = index%8;
	int y = index/8;
	
	float luma = [NezAletterationGameState getBrightnessWithColor:self.color1];
	if (luma > 0.5) {
		y += 4;
	}

	GLKVector4 uv = GLKVector4Make(((float)x+1)/8.0, ((float)y)/8.0, ((float)(x))/8.0, ((float)(y+1))/8.0);
	return uv;
}

-(void)setUV:(GLKVector4)uv {
	if (_bufferedVertexArray.vertexArrayBuffer) {
		letterSquareVertexList[0].uv.x = uv.x;
		letterSquareVertexList[0].uv.y = uv.y;
		
		letterSquareVertexList[1].uv.x = uv.z;
		letterSquareVertexList[1].uv.y = uv.y;
		
		letterSquareVertexList[2].uv.x = uv.z;
		letterSquareVertexList[2].uv.y = uv.w;
		
		letterSquareVertexList[3].uv.x = uv.x;
		letterSquareVertexList[3].uv.y = uv.w;
		[NezAletterationGameState setBufferSubData:_bufferedVertexArray Data:letterSquareVertexList Offset:(_bufferOffset+[self getModelVertexCount]-4)*sizeof(Vertex) Size:LETTER_SQUARE_VERTEX_COUNT*sizeof(Vertex)];
	} else {
		int vertexCount = (_bufferOffset+[self getModelVertexCount]);
		Vertex *v = _bufferedVertexArray.vertexList;
		v[vertexCount-4].uv.x = uv.x;
		v[vertexCount-4].uv.y = uv.y;
		
		v[vertexCount-3].uv.x = uv.z;
		v[vertexCount-3].uv.y = uv.y;
		
		v[vertexCount-2].uv.x = uv.z;
		v[vertexCount-2].uv.y = uv.w;
		
		v[vertexCount-1].uv.x = uv.x;
		v[vertexCount-1].uv.y = uv.w;
	}
}

-(void)animateMix:(float)mix {
	NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:self.mix ToData:mix Duration:0.25 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		self.mix = ani->newData[0];
	} DidStopBlock:nil];
	[NezAnimator addAnimation:ani];
}

@end
