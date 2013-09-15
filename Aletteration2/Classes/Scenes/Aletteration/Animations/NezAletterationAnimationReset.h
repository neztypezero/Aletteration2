//
//  NezAletterationAnimationReset.h
//  Aletteration2
//
//  Created by David Nesbitt on 2013-09-08.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAnimation.h"

@class NezAletterationSinglePlayerController;

@interface NezAletterationAnimationReset : NSObject {
}

+(void)doAnimationFor:(NezAletterationSinglePlayerController*)controller WithStopBlock:(NezAnimationBlock)stopBlock;

@end
