//
//  NezGeometry.h
//  Aletteration
//
//  Created by David Nesbitt on 1/22/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezGeometry.h"
#import "NezVertexArray.h"
#import "NezRay.h"

@interface NezVertexArrayGeometry : NezGeometry {
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

-(void)setMix:(float)mix;
-(float)getMix;

@property (nonatomic, getter = getColor1, setter = setColor1:) GLKVector4 color1;
@property (nonatomic, getter = getColor2, setter = setColor2:) GLKVector4 color2;

@property (nonatomic, getter=getMix, setter = setMix:) float mix;

-(void)setDimensions;

@end
