//
//  NezSinglePlayerAletterationController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2013-09-08.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAnimation.h"

@class NezSinglePlayerAletterationController;

@interface NezAletterationAnimationInitial : NSObject {
}

+(GLKVector3)getBoxEndPos;
+(GLKMatrix4)getBoxEndMatrix;
+(GLKMatrix4)getLidRotationMatrix;

+(void)doAnimationFor:(NezSinglePlayerAletterationController*)controller WithStopBlock:(NezAnimationBlock)stopBlock;

@end
