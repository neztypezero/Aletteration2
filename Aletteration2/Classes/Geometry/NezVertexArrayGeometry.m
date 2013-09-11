//
//  NezGeometry.m
//  Aletteration
//
//  Created by David Nesbitt on 1/22/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayGeometry.h"

@implementation NezVertexArrayGeometry

-(int)getModelVertexCount {
	return 0;
}

-(Vertex*)getModelVertexList {
	return 0;
}

-(unsigned short)getModelIndexCount {
	return 0;
}

-(unsigned short*)getModelIndexList {
	return 0;
}

-(id)initWithVertexArray:(NezVertexArray*)vertexArray {
	GLKVector4 c = {0,0,0,0};
	return [self initWithVertexArray:vertexArray modelMatrix:GLKMatrix4Identity color:c];
}

-(id)initWithVertexArray:(NezVertexArray*)vertexArray modelMatrix:(GLKMatrix4)mat color:(GLKVector4)c {
	if ((self=[super init])) {
		int iCount = [self getModelIndexCount];
		int vCount = [self getModelVertexCount];

		[vertexArray reserveVertices:vCount Indices:iCount];
		_attributes = &vertexArray.paletteArray[vertexArray.paletteCount];
		_attributes->matrix = mat;
		
		int vertexCount = vertexArray.vertexCount;
		unsigned short *indexList = &vertexArray.indexList[vertexArray.indexCount];
		[self copyIntoIndexList:indexList withStartingIndex:vertexCount];
		
		_bufferOffset = vertexCount;
		_bufferedVertexArray = vertexArray;
		
		Vertex *vertexList = &vertexArray.vertexList[vertexCount];
		[self copyIntoVertexList:vertexList];
		for (int i=0; i<vCount; i++) {
			vertexList[i].indexArray[0] = vertexArray.paletteCount;
		}
		self.color1 = c;
		self.color2 = c;
		self.mix = 0;
		[self setDimensions];
		
		vertexArray.indexCount += iCount;
		vertexArray.vertexCount += vCount;
		vertexArray.paletteCount++;
	}
	return self;
}

-(void)copyIntoVertexList:(Vertex*)vertexList {
	int vCount = [self getModelVertexCount];
	Vertex *modelVertexList = [self getModelVertexList];
	memcpy(vertexList, modelVertexList, sizeof(Vertex)*vCount);
}

-(void)copyIntoIndexList:(unsigned short*)indexList withStartingIndex:(int)startIndex {
	int iCount = [self getModelIndexCount];
	unsigned short *modelIndexList = [self getModelIndexList];
	for (int i=0; i<iCount; i++) {
		indexList[i] = startIndex+modelIndexList[i];
	}
}

-(void)setColor1:(GLKVector4)c {
	_attributes->color1 = c;
}

-(GLKVector4)getColor1 {
	return _attributes->color1;
}

-(void)setColor2:(GLKVector4)c {
	_attributes->color2 = c;
}

-(GLKVector4)getColor2 {
	return _attributes->color2;
}

-(void)setMix:(float)mix {
	_attributes->mix = mix;
}

-(float)getMix {
	return _attributes->mix;
}

-(GLKMatrix4)getModelMaxtrix {
	return _attributes->matrix;
}

-(void)setModelMaxtrix:(GLKMatrix4)mat {
	_attributes->matrix = mat;
	[self setBoundingPoints];
}

-(void)setDimensions {
	Vertex *vertexList = [self getModelVertexList];
	int vertexCount = [self getModelVertexCount];
	if (vertexCount > 0) {
		_boundingBox[0].x = vertexList[0].pos.x;
		_boundingBox[0].y = vertexList[0].pos.y;
		_boundingBox[0].z = vertexList[0].pos.z;
		_boundingBox[1] = _boundingBox[0];
		
		for (int i=0; i<vertexCount; i++) {
			if (_boundingBox[0].x > vertexList[i].pos.x) { _boundingBox[0].x = vertexList[i].pos.x; }
			if (_boundingBox[0].y > vertexList[i].pos.y) { _boundingBox[0].y = vertexList[i].pos.y; }
			if (_boundingBox[0].z > vertexList[i].pos.z) { _boundingBox[0].z = vertexList[i].pos.z; }
			if (_boundingBox[1].x < vertexList[i].pos.x) { _boundingBox[1].x = vertexList[i].pos.x; }
			if (_boundingBox[1].y < vertexList[i].pos.y) { _boundingBox[1].y = vertexList[i].pos.y; }
			if (_boundingBox[1].z < vertexList[i].pos.z) { _boundingBox[1].z = vertexList[i].pos.z; }
		}
	} else {
		_boundingBox[0] = GLKVector3Make(0, 0, 0);
		_boundingBox[1] = GLKVector3Make(0, 0, 0);
	}
	_dimensions.x = (_boundingBox[1].x-_boundingBox[0].x);
	_dimensions.y = (_boundingBox[1].y-_boundingBox[0].y);
	_dimensions.z = (_boundingBox[1].z-_boundingBox[0].z);
	[self setBoundingPoints];
}

@end
