//
//  NezAletterationLetterGroup.h
//  Aletteration2
//
//  Created by David Nesbitt on 2013-09-11.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezGeometry.h"
#import "NezAletterationLetterBlock.h"

@interface NezAletterationLetterGroup : NezGeometry {
	NSMutableArray *_letterBlockList;
}

@property(nonatomic) GLKVector3 offset;
@property(nonatomic,readonly,getter = getCount) int count;
@property(nonatomic,readonly,getter = getSpaceUsed) float spaceUsed;
@property(nonatomic,readonly,getter = getLetterBlockList) NSMutableArray *letterBlockList;
@property(nonatomic) char letter;
@property(nonatomic) BOOL isAttached;

-(void)addLetterBlock:(NezAletterationLetterBlock*)letterBlock;
-(GLKMatrix4)getMatrixForIndex:(int)i;

-(id)initWithLetter:(char)letter;

@end

