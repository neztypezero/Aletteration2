//
//  NezAletterationGameState.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-25.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezGCD.h"
#import "NezAletterationPrefs.h"

@class NezVertexArray;
@class NezOpenALSoundLoader;
@class NezCamera;
@class NezAletterationDisplayLine;
@class NezAletterationBox;
@class NezAletterationLid;
@class NezAletterationLetterBlock;
@class NezAletterationLetterStack;
@class NezRay;
@class NezAletterationScoreboard;

static inline double randomNumber() {
	return arc4random()/4294967295.0f;
}

#define NEZ_ALETTERATION_LINE_COUNT 6

@interface NezAletterationGameState : NSObject

#pragma mark -  Drawable Vertex Array List

+(NSArray*)getVertexArrayList;

#pragma mark -  Initialization Functions

+(float)getLineWidth;
+(GLKMatrix4)getOriginalBoxMatrix;
+(const int*)getLetterBag;
+(float)getLoadingProgress;
+(void)loadInitialState:(EAGLContext*)context;

+(void)loadSounds;
+(NezOpenALSoundLoader*)getLoadedSounds;
+(void)playSound:(unsigned int)sound withPitch:(float)pitch;

+(void)loadMusicWithDoneBlock:(NezGCDBlock)doneBlock;

#pragma mark -  Cleanup Memory Functions

+(void)cleanup;

#pragma mark -  Get Geometry Objects Function

+(NezCamera*)getCamera;
+(NezAletterationBox*)getBox;
+(NezAletterationLid*)getLid;
+(NSArray*)getLetterBlockList;
+(NSArray*)getLetterStacks;
+(NezAletterationLetterStack*)getLetterStackForLetter:(char)letter;
+(NSArray*)getDisplayLineList;
+(NezAletterationDisplayLine*)getDisplayIntersectingRay:(NezRay*)ray;
+(NezAletterationScoreboard*)getScoreboard;

#pragma mark -  Aletteration Game Functions

+(void)reset;
+(void)startGame:(NezAletterationGameStateObject*)stateObject;
+(NezAletterationLetterBlock*)startNextTurn:(BOOL)animated;
+(void)endTurn:(int)lineIndex withBlock:(NezGCDBlock)endTurnBlock;
+(void)retireWordForDisplayLine:(NezAletterationDisplayLine*)displayLine;
+(int)getTotalLetterCount;
+(int)getStackCurrentLetterCount;

#pragma mark -  Preference get/set Functions

+(float)getBrightnessWithColor:(GLKVector4)color;
+(float)getBrightnessWithRed:(float)r Green:(float)g Blue:(float)b;

+(int)getBlockCountForLetter:(char)letter;
+(int)getBlockCountForIndex:(int)index;

+(void)setAletterationLogoFrame:(CGRect)frame;
+(CGRect)getAletterationLogoFrame;

+(GLKVector4)getBlockColor;
+(void)setBlockColor:(GLKVector4)color;

+(NezAletterationPrefsObject*)getPreferences;
+(void)setPreferences:(NezAletterationPrefsObject*)prefs;
+(void)savePreferences;

#pragma mark -  Set vbo subdata

+(void)setBufferSubData:(NezVertexArray*)vertexArray Data:(void*)data Offset:(unsigned int)offset Size:(unsigned int)size;

@end

