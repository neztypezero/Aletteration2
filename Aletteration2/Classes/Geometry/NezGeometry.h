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
	GLKMatrix4 _modelMatrix;
}
-(id)init;
-(id)initWithModelMatrix:(GLKMatrix4)mat;

-(void)translateWithDX:(float)dx DY:(float)dy DZ:(float)dz;

-(void)setMidPoint:(GLKVector3)pos;

-(BOOL)containsPoint:(GLKVector4)point;

@property (nonatomic, readonly, getter=getMinX) float minX;
@property (nonatomic, readonly, getter=getMaxX) float maxX;
@property (nonatomic, readonly, getter=getMinY) float minY;
@property (nonatomic, readonly, getter=getMaxY) float maxY;
@property (nonatomic, readonly, getter=getMinZ) float minZ;
@property (nonatomic, readonly, getter=getMaxZ) float maxZ;

@property (nonatomic, getter=getMidPoint, setter = setMidPoint:) GLKVector3 midPoint;

@property (nonatomic, readonly, getter=getSize) GLKVector3 size;

@property (nonatomic, getter=getModelMaxtrix, setter=setModelMaxtrix:) GLKMatrix4 modelMatrix;

-(void)setDimensions;

-(BOOL)intersect:(NezRay*)ray;
-(BOOL)intersect:(NezRay*)ray withExtraSize:(float)size;

-(void)setBoundingPoints;

@end
