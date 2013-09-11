//
//  NezAletterationAnimationReset.h
//  Aletteration2
//
//  Created by David Nesbitt on 2013-09-08.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAnimation.h"

@class NezSinglePlayerAletterationController;

@interface NezAletterationAnimationReset : NSObject {
}

+(void)doAnimationFor:(NezSinglePlayerAletterationController*)controller WithStopBlock:(NezAnimationBlock)stopBlock;

@end
