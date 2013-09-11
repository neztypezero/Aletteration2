//
//  NezAletterationBox.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-11-04.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezGeometry.h"

@class NezAletterationLid;

@interface NezAletterationBoxLetterPlaceHolder : NSObject {
	NSMutableArray *_letterBlockList;
}

@property(nonatomic,readonly,getter = getCount) int count;
@property(nonatomic,readonly,getter = getSpaceUsed) float spaceUsed;
@property(nonatomic) GLKVector3 position;
@property(nonatomic) GLKVector3 offset;
@property(nonatomic,readonly,getter = getLetterBlockList) NSMutableArray *letterBlockList;

-(void)updateMatrices:(GLKMatrix4)boxMatrix;

@end

@interface NezAletterationBox : NezGeometry {
	NezAletterationLid *_lid;
}

-(void)attachLid:(NezAletterationLid*)lid;
-(NezAletterationLid*)dettachLid;
-(void)addLetterBlockList:(NSArray*)letterBlockList;
-(NezAletterationBoxLetterPlaceHolder*)getPlaceHolderForLetter:(char)letter;
-(void)layoutLetterBlocks;

@end
