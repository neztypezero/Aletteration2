//
//  NezLetterBlock.h
//  Aletteration
//
//  Created by David Nesbitt on 1/22/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayGeometry.h"
#import "NezVertexArray.h"

#define LETTER_SQUARE_VERTEX_COUNT 4

@interface NezAletterationLetterBlock : NezVertexArrayGeometry {
	Vertex letterSquareVertexList[LETTER_SQUARE_VERTEX_COUNT];
}
+(GLKVector3)getBlockSize;

-(id)initWithVertexArray:(NezVertexArray*)vertexArray letter:(char)blockLetter modelMatrix:(GLKMatrix4)mat color:(GLKVector4)c;

-(GLKVector4)getUV;
-(void)setUV:(GLKVector4)uv;

@property (nonatomic, readonly) char letter;
@property (nonatomic) int lineIndex;
@property (nonatomic) GLKMatrix4 lineMat;

-(void)animateMix:(float)mix;

@end
