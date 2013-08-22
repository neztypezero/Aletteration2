//
//  NezSimpleObjLoader.m
//  Aletteration
//
//  Created by David Nesbitt on 2/21/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezSimpleObjLoader.h"

@interface NezSimpleObjGroup : NSObject {
}

@property (nonatomic, assign) int firstIndex;
@property (nonatomic, assign) int indexCount;
@property (nonatomic, assign) int firstVertex;
@property (nonatomic, assign) int vertexCount;

@end

@implementation NezSimpleObjGroup

-(id)initWithFirstVertex:(int)vertex Index:(int)index {
	if ((self = [super init])) {
		_firstVertex = vertex;
		_vertexCount = 0;
		_firstIndex = index;
		_indexCount = 0;
	}
	return self;
}

@end

@interface IndexedVertexObj : NSObject {
}

@property (nonatomic, assign) int vertexIndex;
@property (nonatomic, assign) int normalIndex;
@property (nonatomic, assign) int uvIndex;
@property (nonatomic, assign) int vertexArrayIndex;

+(IndexedVertexObj*)indexedVertexObj;

@end

@implementation IndexedVertexObj

+(IndexedVertexObj*)indexedVertexObj {
	return [[IndexedVertexObj alloc] init];
}

-(id)init {
	if ((self = [super init])) {
		_vertexIndex = -1;
		_normalIndex = -1;
		_uvIndex = -1;
		_vertexArrayIndex = -1;
	}
	return self;
}

@end

@interface NezSimpleObjLoader (private)

+(void)readVertexFrom:(char*)line into:(NSMutableArray*)vertexList;
+(void)readNormalFrom:(char*)line into:(NSMutableArray*)normalList;
+(void)readUVFrom:(char*)line into:(NSMutableArray*)uvList;
+(void)readFaceFrom:(char*)line into:(NSMutableArray*)indexList with:(NSMutableDictionary*)indexDic;
+(NezSimpleObjGroup*)readGroupFrom:(char*)line into:(NSMutableDictionary*)groupDictionary withFirstVertex:(int)firstVertex Index:(int)firstIndex;

@end

@implementation NezSimpleObjLoader

-(id)initWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir {
	if ((self = [super init])) {
		self.groupDictionary = [NSMutableDictionary dictionaryWithCapacity:4];
		self.vertexArray = [NezSimpleObjLoader loadVertexArrayWithFile:file Type:ext Dir:dir Groups:self.groupDictionary];
		if (self.vertexArray.vertexCount > 0) {
			GLKVector3 min = self.vertexArray.vertexList[0].pos;
			GLKVector3 max = self.vertexArray.vertexList[0].pos;
			for (int i=1; i<self.vertexArray.vertexCount; i++) {
				Vertex *v = &self.vertexArray.vertexList[i];
				if (min.x > v->pos.x) { min.x = v->pos.x; }
				if (min.y > v->pos.y) { min.y = v->pos.y; }
				if (min.z > v->pos.z) { min.z = v->pos.z; }
				if (max.x < v->pos.x) { max.x = v->pos.x; }
				if (max.y < v->pos.y) { max.y = v->pos.y; }
				if (max.z < v->pos.z) { max.z = v->pos.z; }
			}
			dimensions.x = max.x-min.x;
			dimensions.y = max.y-min.y;
			dimensions.z = max.z-min.z;
		} else {
			dimensions = GLKVector3Make(0, 0, 0);
		}
	}
	return self;
}

-(NezVertexArray*)makeVertexArrayForGroup:(NSString*)groupName {
	if (self.groupDictionary) {
		NezSimpleObjGroup *group = [self.groupDictionary objectForKey:groupName];
		if (group) {
			NezVertexArray *array = [[NezVertexArray alloc] initWithVertexIncrement:group.vertexCount indexIncrement:group.indexCount];
			array.indexCount = group.indexCount;
			unsigned short *indexList = array.indexList;
			for (int i=0; i<group.indexCount; i++) {
				indexList[i] = self.vertexArray.indexList[group.firstIndex+i]-group.firstVertex;
			}
			array.vertexCount = group.vertexCount;
			memcpy(array.vertexList, &self.vertexArray.vertexList[group.firstVertex], sizeof(Vertex)*group.vertexCount);
			return array;
		}
	}
	return nil;
}

+(NezVertexArray*)loadVertexArrayWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir {
	return [NezSimpleObjLoader loadVertexArrayWithFile:file Type:ext Dir:dir Groups:nil];
}

+(NezVertexArray*)loadVertexArrayWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir Groups:(NSMutableDictionary*)groupDic {
	NSMutableArray *vertexList = [NSMutableArray arrayWithCapacity:128];
	NSMutableArray *normalList = [NSMutableArray arrayWithCapacity:128];
	NSMutableArray *uvList = [NSMutableArray arrayWithCapacity:128];
	NSMutableArray *indexList = [NSMutableArray arrayWithCapacity:128];
	NSMutableDictionary *indexDic = [NSMutableDictionary dictionaryWithCapacity:128];
	
	NSString *path = [NezSimpleObjLoader getModelResourcePathWithFilename:file Type:ext Dir:dir];
	
	FILE *objFile = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "rb");
	char line[1024];
	
	NezSimpleObjGroup *curentGroup = nil;
	
	while (fgets(line, 1023, objFile)) {
		switch (line[0]) {
			case 'v':
				switch (line[1]) {
					case ' ':
						[NezSimpleObjLoader readVertexFrom:line into:vertexList];
						break;
					case 't':
						[NezSimpleObjLoader readUVFrom:line into:uvList];
						break;
					case 'n':
						[NezSimpleObjLoader readNormalFrom:line into:normalList];
						break;
					default:
						break;
				}
				break;
			case 'f':
				[NezSimpleObjLoader readFaceFrom:line into:indexList with:indexDic];
				break;
			case 'g':
				if (groupDic != nil && line[1] ==  ' ') {
					curentGroup = [NezSimpleObjLoader readGroupFrom:line into:groupDic withFirstVertex:[indexDic count] Index:[indexList count]];
				} else if (curentGroup) {
					curentGroup.vertexCount = [indexDic count]-curentGroup.firstVertex;
					curentGroup.indexCount = [indexList count]-curentGroup.firstIndex;
					curentGroup = nil;
				}
				break;
			default:
				break;
		}
	}
	if (curentGroup) {
		curentGroup.vertexCount = [indexDic count]-curentGroup.firstVertex;
		curentGroup.indexCount = [indexList count]-curentGroup.firstIndex;
		curentGroup = nil;
	}
	if ([indexList count] > 0) {
		NezVertexArray *varray = [[NezVertexArray alloc] initWithVertexIncrement:[indexDic count] indexIncrement:[indexList count]];
		varray.indexCount = [indexList count];
		varray.vertexCount = [indexDic count];
		for (IndexedVertexObj *indexedVertex in [indexDic objectEnumerator]) {
			Vertex *v = &varray.vertexList[indexedVertex.vertexArrayIndex];
			[((NSValue*)[vertexList objectAtIndex:indexedVertex.vertexIndex]) getValue:&v->pos];
			[((NSValue*)[uvList objectAtIndex:indexedVertex.uvIndex]) getValue:&v->uv];
			[((NSValue*)[normalList objectAtIndex:indexedVertex.normalIndex]) getValue:&v->normal];
			for (int j=0; j<NEZ_GLSL_MAX_BLEND_COUNT; j++) {
				v->indexArray[j] = 0;
			}
		}
		int i=0;
		unsigned short *vaIndexList = varray.indexList;
		for (IndexedVertexObj *indexedVertex in indexList) {
			vaIndexList[i++] = indexedVertex.vertexArrayIndex;
		}
		return varray;
	} else {
		return nil;
	}
}

+(float)getFloatFromCString:(char*)string Next:(char**)next {
	char *start = string;
	for(;;start++) {
		if (*start == '-') {
			break;
		}
		if (*start >= '0' && *start <= '9') {
			break;
		}
	}
	char *end = start;
	for(;;end++) {
		if ((*end >= '0' && *end <= '9') || *end == '-' || *end == '.') {
			continue;
		}
		break;
	}
	*end = '\0';
	*next = end+1;
	return atof(start);
}

+(void)readVertexFrom:(char*)line into:(NSMutableArray*)vertexList {
	GLKVector3 pos = {
		[NezSimpleObjLoader getFloatFromCString:line Next:&line],
		[NezSimpleObjLoader getFloatFromCString:line Next:&line],
		[NezSimpleObjLoader getFloatFromCString:line Next:&line]
	};
	[vertexList addObject:[NSValue valueWithBytes:&pos objCType:@encode(GLKVector3)]];
}

+(void)readNormalFrom:(char*)line into:(NSMutableArray*)normalList {
	GLKVector3 normal = {
		[NezSimpleObjLoader getFloatFromCString:line Next:&line],
		[NezSimpleObjLoader getFloatFromCString:line Next:&line],
		[NezSimpleObjLoader getFloatFromCString:line Next:&line]
	};
	[normalList addObject:[NSValue valueWithBytes:&normal objCType:@encode(GLKVector3)]];
}

+(void)readUVFrom:(char*)line into:(NSMutableArray*)uvList {
	GLKVector2 uv = {
		[NezSimpleObjLoader getFloatFromCString:line Next:&line],
		1.0-[NezSimpleObjLoader getFloatFromCString:line Next:&line],
	};
	[uvList addObject:[NSValue valueWithBytes:&uv objCType:@encode(GLKVector2)]];
}

+(void)readFaceFrom:(char*)line into:(NSMutableArray*)indexList with:(NSMutableDictionary*)indexDic {
	NSString *string = [NSString stringWithFormat:@"%s", line];
	NSArray *lines = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSCharacterSet *slashCharSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
	for (NSString *s in lines) {
		NSRange range = [s rangeOfCharacterFromSet:slashCharSet];
		if (range.location != NSNotFound) {
			IndexedVertexObj *indexedVertex = [IndexedVertexObj indexedVertexObj];
			IndexedVertexObj *value = [indexDic objectForKey:s];
			if (value) {
				indexedVertex.vertexArrayIndex = value.vertexArrayIndex;
			} else {
				NSArray *iList = [s componentsSeparatedByCharactersInSet:slashCharSet];
				indexedVertex.vertexIndex = [[iList objectAtIndex:0] integerValue]-1;
				indexedVertex.uvIndex = [[iList objectAtIndex:1] integerValue]-1;
				indexedVertex.normalIndex = [[iList objectAtIndex:2] integerValue]-1;
				indexedVertex.vertexArrayIndex = [indexDic count];
				[indexDic setObject:indexedVertex forKey:s];
			}
			[indexList addObject:indexedVertex];
		}
	}
}

+(NezSimpleObjGroup*)readGroupFrom:(char*)line into:(NSMutableDictionary*)groupDictionary withFirstVertex:(int)firstVertex Index:(int)firstIndex {
	NSString *string = [NSString stringWithFormat:@"%s", line];
	NSArray *words = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([words count] > 1) {
		NezSimpleObjGroup *group = [[NezSimpleObjGroup alloc] initWithFirstVertex:firstVertex Index:firstIndex];
		[groupDictionary setObject:group forKey:[words objectAtIndex:1]];
		return group;
	}
	return nil;
}

@end
