//
//  NezGeometry.m
//  Aletteration
//
//  Created by David Nesbitt on 1/22/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezGeometry.h"


@interface NezGeometry(private)

-(void)setDimensions;

@end

@implementation NezGeometry

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
}

-(void)translateWithDX:(float)dx DY:(float)dy DZ:(float)dz {
	_attributes->matrix = GLKMatrix4Translate(_attributes->matrix, dx, dy, dz);
	[self setBoundingPoints];
}

-(float)getMinX {
	return _boundingBox[0].x;
}

-(float)getMaxX {
	return _boundingBox[1].x;
}

-(float)getMinY {
	return _boundingBox[0].y;
}

-(float)getMaxY {
	return _boundingBox[1].y;
}

-(float)getMinZ {
	return _boundingBox[0].z;
}

-(float)getMaxZ {
	return _boundingBox[1].z;
}

/*
 Taken from http://www.cs.utah.edu/~awilliam/box/box.pdf
 
 An Efficient and Robust Ray–Box Intersection Algorithm
 Amy Williams Steve Barrus R. Keith Morley Peter Shirley University of Utah
*/

-(BOOL)intersect:(NezRay*)ray withBoundingBox:(GLKVector3*)bb IntervalStart:(float)t0 IntervalEnd:(float)t1 {
	float tmin, tmax, tymin, tymax, tzmin, tzmax;
	
	tmin = (bb[ray.signX].x - ray.origin.x) * ray.inverseDirection.x;
	tmax = (bb[1-ray.signX].x - ray.origin.x) * ray.inverseDirection.x;
	tymin = (bb[ray.signY].y - ray.origin.y) * ray.inverseDirection.y;
	tymax = (bb[1-ray.signY].y - ray.origin.y) * ray.inverseDirection.y;
	if ( (tmin > tymax) || (tymin > tmax) ) {
		return false;
	}
	if (tymin > tmin) {
		tmin = tymin;
	}
	if (tymax < tmax) {
		tmax = tymax;
	}
	tzmin = (bb[ray.signZ].z - ray.origin.z) * ray.inverseDirection.z;
	tzmax = (bb[1-ray.signZ].z - ray.origin.z) * ray.inverseDirection.z;
	if ( (tmin > tzmax) || (tzmin > tmax) ) {
		return false;
	}

	if (tzmin > tmin) {
		tmin = tzmin;
	}
	if (tzmax < tmax) {
		tmax = tzmax;
	}
	return ((tmin < t1) && (tmax > t0));

}

-(BOOL)intersect:(NezRay*)ray {
	[self setBoundingPoints];
	return [self intersect:ray withBoundingBox:_boundingBox IntervalStart:0.0 IntervalEnd:1.0];
}

-(BOOL)intersect:(NezRay*)ray withExtraSize:(float)size {
	[self setBoundingPoints];
	
	float w = (_boundingBox[1].x-_boundingBox[0].x)*size;
	float h = (_boundingBox[1].y-_boundingBox[0].y)*size;
	float d = (_boundingBox[1].z-_boundingBox[0].z)*size;
	
	GLKVector3 bb[2] = {
		GLKVector3Make(_boundingBox[0].x-w, _boundingBox[0].y-h, _boundingBox[0].z-d),
		GLKVector3Make(_boundingBox[1].x+w, _boundingBox[1].y+h, _boundingBox[1].z+d)
	};
	
	return [self intersect:ray withBoundingBox:bb IntervalStart:0.0 IntervalEnd:1.0];
}

-(GLKVector3)getMidPoint {
	[self setBoundingPoints];
	GLKVector3 p = {
		(_boundingBox[1].x+_boundingBox[0].x)/2.0f,
		(_boundingBox[1].y+_boundingBox[0].y)/2.0f,
		(_boundingBox[1].z+_boundingBox[0].z)/2.0f
	};
	return p;
}

-(GLKVector3)getSize {
	return _dimensions;
}

-(void)setBoundingPoints {
	float halfW = _dimensions.x/2.0f;
	float halfH = _dimensions.y/2.0f;
	float halfD = _dimensions.z/2.0f;
	
	GLKVector4 modelMin = {
		-halfW,
		-halfH,
		-halfD,
		1.0
	};
	GLKVector4 modelMax = {
		halfW,
		halfH,
		halfD,
		1.0
	};
	modelMin = GLKMatrix4MultiplyVector4(_attributes->matrix, modelMin);
	modelMax = GLKMatrix4MultiplyVector4(_attributes->matrix, modelMax);
	
	if (modelMin.x > modelMax.x) {
		_boundingBox[0].x = modelMax.x;
		_boundingBox[1].x = modelMin.x;
	} else {
		_boundingBox[0].x = modelMin.x;
		_boundingBox[1].x = modelMax.x;
	}
	if (modelMin.y > modelMax.y) {
		_boundingBox[0].y = modelMax.y;
		_boundingBox[1].y = modelMin.y;
	} else {
		_boundingBox[0].y = modelMin.y;
		_boundingBox[1].y = modelMax.y;
	}
	if (modelMin.z > modelMax.z) {
		_boundingBox[0].z = modelMax.z;
		_boundingBox[1].z = modelMin.z;
	} else {
		_boundingBox[0].z = modelMin.z;
		_boundingBox[1].z = modelMax.z;
	}
}

-(void)setDimensions {
	Vertex *vertexList = [self getModelVertexList];
	int vertexCount = [self getModelVertexCount];
	if (vertexCount > 0) {
		_boundingBox[0].x = vertexList[0].pos.x;
		_boundingBox[0].y = vertexList[0].pos.y;
		_boundingBox[0].y = vertexList[0].pos.y;
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

-(void)setMidPoint:(GLKVector3)pos {
	_attributes->matrix.m30 = pos.x;
	_attributes->matrix.m31 = pos.y;
	_attributes->matrix.m32 = pos.z;
}

-(BOOL)containsPoint:(GLKVector4)point {
	[self setBoundingPoints];
	if (point.x < _boundingBox[0].x || point.x > _boundingBox[1].x) return NO;
	if (point.y < _boundingBox[0].y || point.y > _boundingBox[1].y) return NO;
	if (point.z < _boundingBox[0].z || point.z > _boundingBox[1].z) return NO;
	return YES;
}

@end
