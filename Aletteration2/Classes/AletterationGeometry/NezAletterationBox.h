//
//  NezAletterationBox.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-11-04.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayGeometry.h"
#import "NezAletterationLetterGroup.h"

@class NezAletterationLid;

@interface NezAletterationBox : NezVertexArrayGeometry {
	NezAletterationLid *_lid;
}

-(BOOL)areAllLetterGroupsAttached;

-(void)attachLid:(NezAletterationLid*)lid;
-(NezAletterationLid*)dettachLid;

-(void)addLetterBlockList:(NSArray*)letterBlockList;
-(NezAletterationLetterGroup*)getLetterGroupForLetter:(char)letter;
-(void)layoutLetterBlocks;

-(GLKMatrix4)getMatrixForLid:(NezAletterationLid*)lid WithBoxMatrix:(GLKMatrix4)boxMatrix;
-(GLKMatrix4)getMatrixForLetterGroup:(NezAletterationLetterGroup*)letterGroup;

@end
