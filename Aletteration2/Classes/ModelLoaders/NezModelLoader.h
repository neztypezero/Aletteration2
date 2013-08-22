//
//  NezModelLoader.h
//  Aletteration
//
//  Created by David Nesbitt on 2/21/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezVertexArray.h"


@interface NezModelLoader : NSObject {
	GLKVector3 dimensions;
}

+(NSString*)getModelResourcePathWithFilename:(NSString*)filename Type:(NSString*)fileType Dir:(NSString*)dir;

+(NezVertexArray*)loadVertexArrayWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir;
+(NezVertexArray*)loadVertexArrayWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir Groups:(NSMutableDictionary*)groupDic;

-(id)initWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir;

@property(nonatomic, strong) NezVertexArray *vertexArray;

@property(nonatomic, readonly, getter=getVertexCount) int vertexCount;
@property(nonatomic, readonly, getter=getVertexList) Vertex* vertexList;
@property(nonatomic, readonly, getter=getIndexCount) int indexCount;
@property(nonatomic, readonly, getter=getIndexList) unsigned short *indexList;
@property(nonatomic, readonly, getter=getDimensions) GLKVector3 size;

@end
