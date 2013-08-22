//
//  NezGeometry.h
//  Aletteration
//
//  Created by David Nesbitt on 1/22/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezVertexArray.h"
#import "NezRay.h"

@interface NezGeometry : NSObject {
	GLKVector3 _boundingBox[2];
	GLKVector3 _dimensions;
	
	VertexAttributePaletteItem *_attributes;
	
	NezVertexArray *_bufferedVertexArray;
	unsigned int _bufferOffset;
}
-(id)initWithVertexArray:(NezVertexArray*)vertexArray;
-(id)initWithVertexArray:(NezVertexArray*)vertexArray modelMatrix:(GLKMatrix4)mat color:(GLKVector4)c;

-(int)getModelVertexCount;
-(Vertex*)getModelVertexList;
-(unsigned short*)getModelIndexList;
-(unsigned short)getModelIndexCount;

-(void)copyIntoVertexList:(Vertex*)vertexList;
-(void)copyIntoIndexList:(unsigned short*)indexList withStartingIndex:(int)startIndex;

-(void)translateWithDX:(float)dx DY:(float)dy DZ:(float)dz;

-(void)setBoundingPoints;
-(void)setMidPoint:(GLKVector3)pos;

-(void)setMix:(float)mix;
-(float)getMix;

-(GLKVector3)getMidPoint;
//-(GLKVector2)getMidScreenPoint;
-(GLKVector3)getSize;

-(BOOL)containsPoint:(GLKVector4)point;

@property (nonatomic, getter = getColor1, setter = setColor1:) GLKVector4 color1;
@property (nonatomic, getter = getColor2, setter = setColor2:) GLKVector4 color2;

@property (nonatomic, readonly, getter=getMinX) float minX;
@property (nonatomic, readonly, getter=getMaxX) float maxX;
@property (nonatomic, readonly, getter=getMinY) float minY;
@property (nonatomic, readonly, getter=getMaxY) float maxY;
@property (nonatomic, readonly, getter=getMinZ) float minZ;
@property (nonatomic, readonly, getter=getMaxZ) float maxZ;

@property (nonatomic, readonly, getter=getSize) GLKVector3 size;
@property (nonatomic, getter=getMix, setter = setMix:) float mix;

@property (nonatomic, getter=getModelMaxtrix, setter=setModelMaxtrix:) GLKMatrix4 modelMatrix;

-(void)setDimensions;

-(BOOL)intersect:(NezRay*)ray;
-(BOOL)intersect:(NezRay*)ray withExtraSize:(float)size;

@end
