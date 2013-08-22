//
//  NezStrectableRectangle2D.m
//  Aletteration
//
//  Created by David Nesbitt on 11-10-21.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "NezStrectableRectangle2D.h"
#import "NezAletterationGameState.h"

#define SIDE_OFFSET 0.25

static unsigned short LINE_INDEX_LIST[] = {
	0, 1, 2, 
	2, 1, 3, 
	
	4, 5, 6,
	6, 5, 7,
	
	8, 9, 10,
	10, 9, 11,
};

static Vertex LINE_VERTICES[] = {
	{  0.5, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 }, 
	{  0.5-SIDE_OFFSET, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 }, 
	{  0.5,-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 }, 
	{  0.5-SIDE_OFFSET,-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 }, 

	{  0.5-SIDE_OFFSET, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 }, 
	{ -0.5+SIDE_OFFSET, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 }, 
	{  0.5-SIDE_OFFSET,-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 }, 
	{ -0.5+SIDE_OFFSET,-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 }, 

	{ -0.5+SIDE_OFFSET, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 }, 
	{ -0.5, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 }, 
	{ -0.5+SIDE_OFFSET,-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 }, 
	{ -0.5,-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 }, 
};

@implementation NezStrectableRectangle2D

-(int)getModelVertexCount {
	return NSR_INDEXED_LINE_VERTEX_COUNT;
}

-(Vertex*)getModelVertexList {
	return LINE_VERTICES;
}

-(unsigned short)getModelIndexCount {
	return NSR_INDEXED_LINE_INDEX_COUNT;
}

-(unsigned short*)getModelIndexList {
	return LINE_INDEX_LIST;
}

-(id)initWithVertexArray:(NezVertexArray*)vertexArray modelMatrix:(GLKMatrix4)mat color:(GLKVector4)c {
	if ((self = [super initWithVertexArray:vertexArray modelMatrix:mat color:c])) {
		self.color2 = GLKVector4Make(0.0, 0.0, 0.0, 0.0);
		self.mix = 1.0;
		rectWidth = 1.0;
		[self setUVwithU1:0.0 V1:0.0 U2:1.0 V2:1.0];
	}
	return self;
}

-(void)setUVwithU1:(float)u1 V1:(float)v1 U2:(float)u2 V2:(float)v2 {
	GLKVector4 uv = {u1, v1, u2, v2};
	[self setUV:uv];
}

-(void)setUV:(GLKVector4)uv {
	float width = uv.w-uv.x;
	float sideWidth = width*SIDE_OFFSET;
	
	Vertex *v;
	if (_bufferedVertexArray.vertexArrayBuffer) {
		v = vertexPtr;
	} else {
		v = &_bufferedVertexArray.vertexList[_bufferOffset];
	}
	v[0].uv.x = uv.x;
	v[0].uv.y = uv.y;
	
	v[1].uv.x = uv.x+sideWidth;
	v[1].uv.y = uv.y;
	
	v[2].uv.x = uv.x;
	v[2].uv.y = uv.w;
	
	v[3].uv.x = uv.x+sideWidth;
	v[3].uv.y = uv.w;
	
	v[4].uv.x = uv.x+sideWidth;
	v[4].uv.y = uv.y;
	
	v[5].uv.x = uv.z-sideWidth;
	v[5].uv.y = uv.y;
	
	v[6].uv.x = uv.x+sideWidth;
	v[6].uv.y = uv.w;
	
	v[7].uv.x = uv.z-sideWidth;
	v[7].uv.y = uv.w;
	
	v[8].uv.x = uv.z-sideWidth;
	v[8].uv.y = uv.y;
	
	v[9].uv.x = uv.z;
	v[9].uv.y = uv.y;
	
	v[10].uv.x = uv.z-sideWidth;
	v[10].uv.y = uv.w;
	
	v[11].uv.x = uv.z;
	v[11].uv.y = uv.w;

	if (_bufferedVertexArray.vertexArrayBuffer) {
		[NezAletterationGameState setBufferSubData:_bufferedVertexArray Data:v Offset:(_bufferOffset)*sizeof(Vertex) Size:NSR_INDEXED_LINE_VERTEX_COUNT*sizeof(Vertex)];
	} else {
		memcpy(vertexPtr, v, NSR_INDEXED_LINE_VERTEX_COUNT*sizeof(Vertex));
	}
}

-(void)setRectWidth:(float)newWidth andHeight:(float)newHeight {
	float halfWidth = newWidth/2.0;
	float halfHeight = newHeight/2.0;
	
	Vertex *v;
	if (_bufferedVertexArray.vertexArrayBuffer) {
		v = vertexPtr;
	} else {
		v = &_bufferedVertexArray.vertexList[_bufferOffset];
	}

	v[0].pos.x = halfWidth;
	v[0].pos.y = halfHeight;
	v[1].pos.x = halfWidth-SIDE_OFFSET;
	v[1].pos.y = halfHeight;
	v[2].pos.x = halfWidth;
	v[2].pos.y = -halfHeight;
	v[3].pos.x = halfWidth-SIDE_OFFSET;
	v[3].pos.y = -halfHeight;

	v[4].pos.x = halfWidth-SIDE_OFFSET;
	v[4].pos.y = halfHeight;
	v[5].pos.x = -halfWidth+SIDE_OFFSET;
	v[5].pos.y = halfHeight;
	v[6].pos.x = halfWidth-SIDE_OFFSET;
	v[6].pos.y = -halfHeight;
	v[7].pos.x = -halfWidth+SIDE_OFFSET;
	v[7].pos.y = -halfHeight;
	
	v[8].pos.x = -halfWidth+SIDE_OFFSET;
	v[8].pos.y = halfHeight;
	v[9].pos.x = -halfWidth;
	v[9].pos.y = halfHeight;
	v[10].pos.x = -halfWidth+SIDE_OFFSET;
	v[10].pos.y = -halfHeight;
	v[11].pos.x = -halfWidth;
	v[11].pos.y = -halfHeight;
	
	if (_bufferedVertexArray.vertexArrayBuffer) {
		[NezAletterationGameState setBufferSubData:_bufferedVertexArray Data:v Offset:(_bufferOffset)*sizeof(Vertex) Size:NSR_INDEXED_LINE_VERTEX_COUNT*sizeof(Vertex)];
	} else {
		memcpy(vertexPtr, v, NSR_INDEXED_LINE_VERTEX_COUNT*sizeof(Vertex));
	}
}

@end
