//
//  NezAletterationAnimationUndo.h
//  Aletteration2
//
//  Created by David Nesbitt on 2013-09-12.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAnimation.h"

@class NezAletterationSinglePlayerController;
@class NezAletterationGameStateTurn;

@interface NezAletterationAnimationUndo : NSObject {
}

+(void)doAnimationFor:(NezAletterationSinglePlayerController*)controller withRetiredWordList:(NSArray*)retiredWordList andStopBlock:(NezAnimationBlock)stopBlock;

@end
