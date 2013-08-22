//
//  NezDisplayLine.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-26.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezRectangle2D.h"
#import "NezStrectableRectangle2D.h"

@class NezAletterationRetiredWord;
@class NezAletterationLetterBlock;

@interface NezAletterationDisplayLine : NezRectangle2D {
	NSMutableArray *_letterBlockList;
	NSData *_stringData;
	char *_string;
	int _currentWordIndex;
	int _currentWordLength;
	int _currentJunkLength;
	BOOL _isHighlighted;
	int _junkOffset;
}

@property(nonatomic, readonly) int lineIndex;
@property(nonatomic, readonly, getter = getString) char *string;
@property(nonatomic, readonly, getter = getCount) int count;

@property(nonatomic, setter = setCurrentWordIndex:) int currentWordIndex;
@property(nonatomic, readonly, getter = getCurrentWordLength) int currentWordLength;
@property(nonatomic, readonly, getter = getCurrentJunkLength) int currentJunkLength;
@property(nonatomic, readonly, getter = getCurrentWord) char *currentWord;
@property(nonatomic) BOOL isWord;

@property(nonatomic, weak) NezStrectableRectangle2D *highlightRect;


-(id)initWithVertexArray:(NezVertexArray*)vertexArray modelMatrix:(GLKMatrix4)mat color:(GLKVector4)c lineIndex:(int)lineIndex;

-(GLKVector3)getNextLetterBlockPosition;

-(void)addLetterBlock:(NezAletterationLetterBlock*)letterBlock;
-(void)animateSelected;
-(void)animateDeselected;

-(void)setLetterBlockColors:(BOOL)animated;

-(NezAletterationRetiredWord*)retireHighlightedWord;

@end
