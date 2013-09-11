//
//  NezAletterationLetterStack.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-11-06.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezRectangle2D.h"
#import "NezAnimation.h"

@class NezAletterationLetterBlock;

@interface NezAletterationLetterStack : NezRectangle2D {
	GLKMatrix4 _originalModelMatrix;
	NSMutableArray *_letterBlockStack;
	int _deferredBlockCount;
	GLKVector3 _originalPosition;
}

@property(nonatomic, setter = setLetter:) char letter;
@property(nonatomic, readonly, getter = getCount) int count;
@property(nonatomic, readonly, getter = getDeferredCount) int deferredCount;

-(id)initWithVertexArray:(NezVertexArray *)vertexArray;

-(GLKVector3)getNextLetterBlockPosition;

-(void)pushLetterBlock:(NezAletterationLetterBlock*)letterBlock;
-(void)deferredPushLetterBlock:(NezAletterationLetterBlock*)letterBlock;
-(void)finishPushLetterBlock:(NezAletterationLetterBlock*)letterBlock;

-(BOOL)containsLetterBlock:(NezAletterationLetterBlock*)letterBlock;

-(NezAletterationLetterBlock*)popLetterBlock:(BOOL)isAnimated;

-(void)fadeCounterTo:(float)alpha withStopBlock:(NezAnimationBlock)stopBlock;

@end
