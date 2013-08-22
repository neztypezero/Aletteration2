//
//  NezRectangle2D.m
//  Aletteration
//
//  Created by David Nesbitt on 3/18/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezRectangle2D.h"
#import "NezAletterationGameState.h"

static unsigned short LINE_INDEX_LIST[] = {
	0, 1, 2, 
	2, 1, 3, 
};

static Vertex LINE_VERTICES[] = {
	{  0.5, 0.5, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0 },
	{ -0.5, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 },
	{  0.5,-0.5, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0 },
	{ -0.5,-0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0 },
};

@implementation NezRectangle2D

-(int)getModelVertexCount {
	return INDEXED_RECT_VERTEX_COUNT;
}

-(Vertex*)getModelVertexList {
	return LINE_VERTICES;
}

-(unsigned short)getModelIndexCount {
	return INDEXED_RECT_INDEX_COUNT;
}

-(unsigned short*)getModelIndexList {
	return LINE_INDEX_LIST;
}

-(void)setUVwithU1:(float)u1 V1:(float)v1 U2:(float)u2 V2:(float)v2 {
	GLKVector4 uv = {u1, v1, u2, v2};
	[self setUV:uv];
}

-(void)setUV:(GLKVector4)uv {
	if (_bufferedVertexArray.vertexArrayObject) {
		vertexPtr[0].uv.x = uv.x;
		vertexPtr[0].uv.y = uv.y;
		
		vertexPtr[1].uv.x = uv.z;
		vertexPtr[1].uv.y = uv.y;
		
		vertexPtr[2].uv.x = uv.x;
		vertexPtr[2].uv.y = uv.w;
		
		vertexPtr[3].uv.x = uv.z;
		vertexPtr[3].uv.y = uv.w;
		[NezAletterationGameState setBufferSubData:_bufferedVertexArray Data:vertexPtr Offset:(_bufferOffset+[self getModelVertexCount]-4)*sizeof(Vertex) Size:INDEXED_RECT_VERTEX_COUNT*sizeof(Vertex)];
	} else {
		Vertex *v = &_bufferedVertexArray.vertexList[_bufferOffset];
		v[0].uv.x = uv.x;
		v[0].uv.y = uv.y;
		
		v[1].uv.x = uv.z;
		v[1].uv.y = uv.y;
		
		v[2].uv.x = uv.x;
		v[2].uv.y = uv.w;
		
		v[3].uv.x = uv.z;
		v[3].uv.y = uv.w;
		memcpy(vertexPtr, v, INDEXED_RECT_VERTEX_COUNT*sizeof(Vertex));
	}
}

-(BOOL)intersect:(NezRay*)ray withBoundingBox:(GLKVector3*)bb {
	float tmin, tmax, tymin, tymax, tzmin, tzmax;
	
	tmin = (bb[ray.signX].x - ray.origin.x) * ray.inverseDirection.x;
	tmax = (bb[1-ray.signX].x - ray.origin.x) * ray.inverseDirection.x;
	tymin = (bb[ray.signY].y - ray.origin.y) * ray.inverseDirection.y;
	tymax = (bb[1-ray.signY].y - ray.origin.y) * ray.inverseDirection.y;
	if ( (tmin > tymax) || (tymin > tmax) )
		return false;
	if (tymin > tmin)
		tmin = tymin;
	if (tymax < tmax)
		tmax = tymax;
	tzmin = (bb[ray.signZ].z - ray.origin.z) * ray.inverseDirection.z;
	tzmax = (bb[1-ray.signZ].z - ray.origin.z) * ray.inverseDirection.z;
	if ( (tmin > tzmax) || (tzmin > tmax) )
		return false;
	return YES;
}

@end
