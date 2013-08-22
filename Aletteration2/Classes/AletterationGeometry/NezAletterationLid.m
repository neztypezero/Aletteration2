//
//  NezAletterationLid.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-11-04.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezAletterationLid.h"
#import "NezSimpleObjLoader.h"

@interface NezAletterationLid () {
}

@property(nonatomic,strong) NezSimpleObjLoader *lidObj;

@end

@implementation NezAletterationLid

-(int)getModelVertexCount {
	return _lidObj.vertexCount;
}

-(Vertex*)getModelVertexList {
	return _lidObj.vertexList;
}

-(unsigned short)getModelIndexCount {
	return _lidObj.indexCount;
}

-(unsigned short*)getModelIndexList {
	return _lidObj.indexList;
}

-(id)initWithVertexArray:(NezVertexArray *)vertexArray modelMatrix:(GLKMatrix4)mat color:(GLKVector4)c {
	self.lidObj = [[NezSimpleObjLoader alloc] initWithFile:@"lid" Type:@"obj" Dir:@"Models"];
	
	if ((self = [super initWithVertexArray:vertexArray modelMatrix:mat color:c])) {
		self.lidObj = nil;
	}
	return self;
}

-(float)getLidThickness {
	return self.size.z*0.05;
}

@end
