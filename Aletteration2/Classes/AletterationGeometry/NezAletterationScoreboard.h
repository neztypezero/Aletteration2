//
//  NezAletterationScoreboard.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-11-16.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezAletterationRetiredWord.h"
#import "NezGCD.h"

@class NezCamera;

@interface NezAletterationScoreboard : NSObject {
	NSMutableArray *_retiredWordList;
	GLKVector3 _pos;
	float _lineSpace;
	GLKVector3 _wordBounds[2];
}

+(id)scoreboardWithStartingPosition:(GLKVector3)pos andLineSpace:(float)lineSpace ;
-(id)initWithStartingPosition:(GLKVector3)pos andLineSpace:(float)lineSpace ;

-(void)addRetiredWord:(NezAletterationRetiredWord*)retiredWord;
-(void)addRetiredWord:(NezAletterationRetiredWord*)retiredWord withStopBlock:(NezGCDBlock)stopBlock;

-(NezCamera*)getCameraWithCurrentCamera:(NezCamera*)camera andDefaultZ:(float)z;
-(GLKVector3)getCameraTarget;

-(void)reset;

-(NezAletterationRetiredWord*)removeLastRetiredWord;
-(void)recalculateBounds;

@end
