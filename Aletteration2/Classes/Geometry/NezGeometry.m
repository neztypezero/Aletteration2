//
//  NezGeometry.m
//  Aletteration
//
//  Created by David Nesbitt on 1/22/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezGeometry.h"

@implementation NezGeometry

-(id)init {
	return [self initWithModelMatrix:GLKMatrix4Identity];
}

-(id)initWithModelMatrix:(GLKMatrix4)mat {
	if ((self=[super init])) {
		_modelMatrix = mat;
	}
	return self;
}

-(GLKMatrix4)getModelMaxtrix {
	return _modelMatrix;
}

-(void)setModelMaxtrix:(GLKMatrix4)mat {
	_modelMatrix = mat;
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
	return [self intersect:ray withBoundingBox:_boundingBox IntervalStart:0.0 IntervalEnd:1.0];
}

-(BOOL)intersect:(NezRay*)ray withExtraSize:(float)size {
	float w = (_boundingBox[1].x-_boundingBox[0].x)*size;
	float h = (_boundingBox[1].y-_boundingBox[0].y)*size;
	float d = (_boundingBox[1].z-_boundingBox[0].z)*size;
	
	GLKVector3 bb[2] = {
		GLKVector3Make(_boundingBox[0].x-w, _boundingBox[0].y-h, _boundingBox[0].z-d),
		GLKVector3Make(_boundingBox[1].x+w, _boundingBox[1].y+h, _boundingBox[1].z+d)
	};
	
	return [self intersect:ray withBoundingBox:bb IntervalStart:0.0 IntervalEnd:1.0];
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
	modelMin = GLKMatrix4MultiplyVector4(self.modelMatrix, modelMin);
	modelMax = GLKMatrix4MultiplyVector4(self.modelMatrix, modelMax);
	
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
	_dimensions.x = 0.0;
	_dimensions.y = 0.0;
	_dimensions.z = 0.0;
	[self setBoundingPoints];
}

-(void)setMidPoint:(GLKVector3)pos {
	GLKMatrix4 mat = self.modelMatrix;
	mat.m30 = pos.x;
	mat.m31 = pos.y;
	mat.m32 = pos.z;
	self.modelMatrix = mat;
}

-(GLKVector3)getMidPoint {
	GLKVector3 p = {
		(_boundingBox[1].x+_boundingBox[0].x)/2.0f,
		(_boundingBox[1].y+_boundingBox[0].y)/2.0f,
		(_boundingBox[1].z+_boundingBox[0].z)/2.0f
	};
	return p;
}

-(void)translateWithDX:(float)dx DY:(float)dy DZ:(float)dz {
	self.modelMatrix = GLKMatrix4Translate(self.modelMatrix, dx, dy, dz);
}

-(BOOL)containsPoint:(GLKVector4)point {
	if (point.x < _boundingBox[0].x || point.x > _boundingBox[1].x) return NO;
	if (point.y < _boundingBox[0].y || point.y > _boundingBox[1].y) return NO;
	if (point.z < _boundingBox[0].z || point.z > _boundingBox[1].z) return NO;
	return YES;
}

@end
