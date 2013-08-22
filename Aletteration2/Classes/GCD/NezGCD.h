//
//  NezGCD.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-21.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

typedef void (^ NezGCDBlock)();

@interface NezGCD : NSObject

//This function runs workBlock in the High Priority Thread and then when that's done runs doneBlock in the Main Thread
+(void)runHighPriorityWithWorkBlock:(NezGCDBlock)workBlock DoneBlock:(NezGCDBlock)doneBlock;

//This function runs workBlock in the Default Priority Thread and then when that's done runs doneBlock in the Main Thread
+(void)runDefaultPriorityWithWorkBlock:(NezGCDBlock)workBlock DoneBlock:(NezGCDBlock)doneBlock;

//This function runs workBlock in the Low Priority Thread and then when that's done runs doneBlock in the Main Thread
+(void)runLowPriorityWithWorkBlock:(NezGCDBlock)workBlock DoneBlock:(NezGCDBlock)doneBlock;

//This function runs workBlock in the Background Priority Thread and then when that's done runs doneBlock in the Main Thread
+(void)runBackgroundPriorityWithWorkBlock:(NezGCDBlock)workBlock DoneBlock:(NezGCDBlock)doneBlock;

@end
