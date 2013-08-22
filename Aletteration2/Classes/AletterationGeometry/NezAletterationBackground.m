//
//  NezAletterationBackground.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-11-04.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezAletterationBackground.h"
#import "NezSimpleObjLoader.h"
#import "NezAletterationGameState.h"

@interface NezAletterationBackground () {
}

@property(nonatomic,strong) NezSimpleObjLoader *backgroundObj;

@end

@implementation NezAletterationBackground

-(int)getModelVertexCount {
	return _backgroundObj.vertexCount;
}

-(Vertex*)getModelVertexList {
	return _backgroundObj.vertexList;
}

-(unsigned short)getModelIndexCount {
	return _backgroundObj.indexCount;
}

-(unsigned short*)getModelIndexList {
	return _backgroundObj.indexList;
}

-(id)initWithVertexArray:(NezVertexArray *)vertexArray modelMatrix:(GLKMatrix4)mat color:(GLKVector4)c {
	self.backgroundObj = [[NezSimpleObjLoader alloc] initWithFile:@"bg" Type:@"obj" Dir:@"Models"];
	
	if ((self=[super init])) {
		int iCount = [self getModelIndexCount];
		int vCount = [self getModelVertexCount];
		
		[vertexArray reserveVertices:vCount Indices:iCount];
		
		int vertexCount = vertexArray.vertexCount;
		unsigned short *indexList = &vertexArray.indexList[vertexArray.indexCount];
		[self copyIntoIndexList:indexList withStartingIndex:vertexCount];
		
		_bufferOffset = vertexCount;
		_bufferedVertexArray = vertexArray;
		
		Vertex *vertexList = &vertexArray.vertexList[vertexCount];
		[self copyIntoVertexList:vertexList];
		
		GLKVector4 colors[] = {
			{255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0}, // 0
			{255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0}, // 1
			{255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0}, // 2
			{255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0}, // 3
			{255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0}, // 4
			{255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0}, // 5
			{255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0}, // 6
			{255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0}, // 7
			{255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0}, // 8
			{255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0}, // 9
			{255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0}, //10
			{255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0}, //11
			{0.94f, 0.36f, 0.32f, 1.0f}, //12
			{0.94f, 0.36f, 0.32f, 1.0f}, //13
			{241.0/255.0,  92.0/255.0,  86.0/255.0, 1.0}, //14  --> 14 == 16
			{240.0/255.0,  79.0/255.0, 117.0/255.0, 1.0}, //15  --> 15 == 17
			{241.0/255.0,  92.0/255.0,  86.0/255.0, 1.0}, //16
			{240.0/255.0,  79.0/255.0, 117.0/255.0, 1.0}, //17
			{241.0/255.0,  97.0/255.0,  70.0/255.0, 1.0}, //18
			{240.0/255.0,  84.0/255.0, 105.0/255.0, 1.0}, //19
			{241.0/255.0,  97.0/255.0,  70.0/255.0, 1.0}, //20  --> 20 == 18
			{240.0/255.0,  84.0/255.0, 105.0/255.0, 1.0}, //21  --> 21 == 19
			{0.94f, 0.36f, 0.32f, 1.0f}, //22
			{0.94f, 0.36f, 0.32f, 1.0f}, //23
		};

		_attributes = &vertexArray.paletteArray[vertexArray.paletteCount];
		for (int i=0; i<vCount; i++) {
			_attributes[i].matrix = mat;
			_attributes[i].color1 = colors[i];
			_attributes[i].color2 = _attributes[i].color1;
			_attributes[i].mix = 0.0;
			vertexList[i].indexArray[0] = vertexArray.paletteCount++;
//			vertexList[i].uv = GLKVector2Make(0.0, 0.0);
		}
		[self setDimensions];
		
		vertexArray.indexCount += iCount;
		vertexArray.vertexCount += vCount;
	}
	return self;
}

@end
