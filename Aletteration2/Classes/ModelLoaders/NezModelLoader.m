//
//  NezModelLoader.m
//  Aletteration
//
//  Created by David Nesbitt on 2/21/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezModelLoader.h"

@implementation NezModelLoader

+(NSString*)getModelResourcePathWithFilename:(NSString*)filename Type:(NSString*)fileType Dir:(NSString*)dir {
	return [[NSBundle mainBundle] pathForResource:filename ofType:fileType inDirectory:dir];
}

+(NezVertexArray*)loadVertexArrayWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir {
	return nil;
}

+(NezVertexArray*)loadVertexArrayWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir Groups:(NSMutableDictionary*)groupDic {
	return nil;
}

-(id)initWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir {
	if ((self=[super init])) {
		self.vertexArray = [NezModelLoader loadVertexArrayWithFile:file Type:ext Dir:dir];
		dimensions = GLKVector3Make(0, 0, 0);
	}
	return self;
}

-(int)getVertexCount {
	return self.vertexArray.vertexCount;
}

-(Vertex*)getVertexList {
	return self.vertexArray.vertexList;
}

-(int)getIndexCount {
	return self.vertexArray.indexCount;
}

-(unsigned short*)getIndexList {
	return self.vertexArray.indexList;
}

-(GLKVector3)getDimensions {
	return dimensions;
}

@end
