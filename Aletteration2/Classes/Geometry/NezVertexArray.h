//
//  NezVertexArray.h
//  Aletteration
//
//  Created by David Nesbitt on 3/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>

#define NEZ_GLSL_MATRIX_PALETTE_COUNT 30
#define NEZ_GLSL_MAX_BLEND_COUNT 4

typedef struct Vertex {
	GLKVector3 pos;
	GLKVector2 uv;
	GLKVector3 normal;
	unsigned char indexArray[NEZ_GLSL_MAX_BLEND_COUNT];
} Vertex;

typedef struct VertexAttributePaletteItem {
	GLKMatrix4 matrix;
	GLKVector4 color1;
	GLKVector4 color2;
	float mix;
} VertexAttributePaletteItem;

@class NezGLSLProgram;

@interface NezVertexArray : NSObject {
	int _indexArrayLength;
	int _indexArrayIncrement;

	int _vertexArrayLength;
	int _vertexArrayIncrement;

	int _paletteArrayLength;

	NSMutableData *_indexData;
	NSMutableData *_vertexData;
	NSMutableData *_paletteData;
	
	GLuint _buffers[3];
	
//	BOOL animating;
//	NSTimeInterval startTime, now;
}

@property (nonatomic, readonly, getter = getVertexArrayObject) GLuint vertexArrayObject;
@property (nonatomic, readonly, getter = getVertexArrayObjectPtr) GLuint *vertexArrayObjectPtr;

@property (nonatomic, readonly, getter = getVertexArrayBuffer) GLuint vertexArrayBuffer;
@property (nonatomic, readonly, getter = getVertexArrayBufferPtr) GLuint *vertexArrayBufferPtr;

@property (nonatomic, readonly, getter = getVertexElementBuffer) GLuint vertexElementBuffer;
@property (nonatomic, readonly, getter = getVertexElementBufferPtr) GLuint *vertexElementBufferPtr;

@property (nonatomic) GLuint textureUnit;

@property (nonatomic) int vertexCount;
@property (nonatomic, readonly, getter = getVertexList) Vertex *vertexList;

@property (nonatomic) int indexCount;
@property (nonatomic, readonly, getter = getIndexList) unsigned short *indexList;

@property (nonatomic) int paletteCount;
@property (nonatomic, readonly, getter = getPaletteList) VertexAttributePaletteItem *paletteArray;

@property (nonatomic) int programType;
@property (nonatomic, strong) NezGLSLProgram *program;;

@property (nonatomic) BOOL depthTest;

+(const void*)vertexOffsetPos;
+(const void*)vertexOffsetUV;
+(const void*)vertexOffsetNormal;
+(const void*)vertexOffsetIndexArray;

-(id)initWithVertexIncrement:(int)vInc indexIncrement:(int)iInc;
-(id)initWithVertexIncrement:(int)vInc indexIncrement:(int)iInc TextureUnit:(int)texUnit ProgramType:(int)programType;

-(void)reserveVertices:(int)vertexCount Indices:(int)indexCount;
-(BOOL)canHoldMorePaletteEntries:(int)paletteCount;

-(void)attachVboWithDrawType:(unsigned int)type;

@end
