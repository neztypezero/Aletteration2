//
//  NezVertexArray.m
//  Aletteration
//
//  Created by David Nesbitt on 3/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezVertexArray.h"
//#import "OpenGLES2Graphics.h"

#define ADDR_OFFSET(b, a) ((const void*)((unsigned int)a-(unsigned int)b))

typedef struct VertexOffset {
	const void *pos;
	const void *uv;
	const void *normal;
	const void *indexArray;
} VertexOffset;

VertexOffset gVertexOffset;

@interface NezVertexArray(private)

-(void)extendData:(NSMutableData*)data length:(int*)length count:(int)currentCount total:(int)total increment:(int)increment stride:(int)stride;

@end

@implementation NezVertexArray

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
		
		Vertex a;
		gVertexOffset.pos        = ADDR_OFFSET(&a, &a.pos);
		gVertexOffset.uv         = ADDR_OFFSET(&a, &a.uv);
		gVertexOffset.normal     = ADDR_OFFSET(&a, &a.normal);
		gVertexOffset.indexArray = ADDR_OFFSET(&a, &a.indexArray);
    }
}

+(const void*)vertexOffsetPos {
	return gVertexOffset.pos;
}

+(const void*)vertexOffsetUV {
	return gVertexOffset.uv;
}

+(const void*)vertexOffsetNormal {
	return gVertexOffset.normal;
}

+(const void*)vertexOffsetIndexArray {
	return gVertexOffset.indexArray;
}

-(id)initWithVertexIncrement:(int)vInc indexIncrement:(int)iInc {
	return [self initWithVertexIncrement:vInc indexIncrement:iInc TextureUnit:-1 ProgramType:-1];
}

-(id)initWithVertexIncrement:(int)vInc indexIncrement:(int)iInc TextureUnit:(int)texUnit ProgramType:(int)programType {
	if ((self = [super init])) {
		_depthTest = YES;

		_indexArrayIncrement = iInc;
		_vertexArrayIncrement = vInc;
		
		_indexArrayLength = 0;
		_vertexArrayLength = 0;
		_paletteArrayLength = 0;
		
		_indexCount = 0;
		_vertexCount = 0;
		_paletteCount = 0;
		
		_textureUnit = texUnit;
		_programType = programType;
		
//		animating = NO;
//		startTime = 0;
//		now = 0;
		
		_buffers[0] = 0;
		_buffers[1] = 0;
		_buffers[2] = 0;

		_vertexData = [NSMutableData dataWithCapacity:0];
		_indexData = [NSMutableData dataWithCapacity:0];
		_paletteData = [NSMutableData dataWithCapacity:0];
		
		[self extendData:_paletteData length:&_paletteArrayLength count:0 total:NEZ_GLSL_MATRIX_PALETTE_COUNT increment:NEZ_GLSL_MATRIX_PALETTE_COUNT stride:sizeof(VertexAttributePaletteItem)];
		[self extendData:_indexData length:&_indexArrayLength count:0 total:_indexArrayIncrement increment:_indexArrayIncrement stride:sizeof(unsigned short)];
		[self extendData:_vertexData length:&_vertexArrayLength count:0 total:_vertexArrayIncrement increment:_vertexArrayIncrement stride:sizeof(Vertex)];
	}
	return self;
}

-(GLuint)getVertexArrayObject {
	return _buffers[0];
}

-(GLuint*)getVertexArrayObjectPtr {
	return _buffers;
}

-(GLuint)getVertexArrayBuffer {
	return _buffers[1];
}

-(GLuint*)getVertexArrayBufferPtr {
	return _buffers+1;
}

-(GLuint)getVertexElementBuffer {
	return _buffers[2];
}

-(GLuint*)getVertexElementBufferPtr {
	return _buffers+2;
}

-(Vertex*)getVertexList {
	return (Vertex*)_vertexData.bytes;
}

-(unsigned short*)getIndexList {
	return (unsigned short*)_indexData.bytes;
}

-(VertexAttributePaletteItem*)getPaletteList {
	return (VertexAttributePaletteItem*)_paletteData.bytes;
}

-(void)extendData:(NSMutableData*)data length:(int*)length count:(int)currentCount total:(int)total increment:(int)increment stride:(int)stride {
	int count = (*length)+increment;
	while (count < total) {
		count += increment;
	}
	[data setLength:stride*count];
	*length = count;
}

-(void)reserveVertices:(int)vCount Indices:(int)iCount {
	if (self.indexCount+iCount > _indexArrayLength) {
		[self extendData:_indexData length:&_indexArrayLength count:self.indexCount total:self.indexCount+iCount increment:_indexArrayIncrement stride:sizeof(unsigned short)];
	}
	if (self.vertexCount+vCount > _vertexArrayLength) {
		[self extendData:_vertexData length:&_vertexArrayLength count:self.vertexCount total:self.vertexCount+vCount increment:_vertexArrayIncrement stride:sizeof(Vertex)];
	}
}

-(BOOL)canHoldMorePaletteEntries:(int)extraEntries {
	return (self.paletteCount+extraEntries <= _paletteArrayLength);
}

-(void)attachVboWithDrawType:(unsigned int)type {
//	[[OpenGLES2Graphics instance] attachVboToVertexArray:self DrawType:type];
	_indexData = nil;
	_vertexData = nil;
}

-(void)dealloc {
	_indexData = nil;
	_vertexData = nil;
	_paletteData = nil;
//	[[OpenGLES2Graphics instance] deleteVboFromVertexArray:self];
}

@end
