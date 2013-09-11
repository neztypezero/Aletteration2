//
//  NezGCD.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-21.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezGCD.h"

@interface PrivateNezGCD : NSObject

+(void)runOnPriorityQueue:(int)queueType WithWorkBlock:(NezGCDBlock)workBlock DoneBlock:(NezGCDBlock)doneBlock;

@end

@implementation PrivateNezGCD

//This function runs workBlock in the a Priority Thread and then when that's done runs doneBlock in the Main Thread
+(void)runOnPriorityQueue:(int)queueType WithWorkBlock:(NezGCDBlock)workBlock DoneBlock:(NezGCDBlock)doneBlock {
	dispatch_async(dispatch_get_global_queue(queueType, 0), ^{
		if (workBlock != NULL) {
			workBlock();
		}
		if (doneBlock != NULL) {
			dispatch_async(dispatch_get_main_queue(), ^{
				doneBlock();
			});
		}
	});
}

@end

@implementation NezGCD

//This function runs workBlock in the High Priority Thread and then when that's done runs doneBlock in the Main Thread
+(void)runHighPriorityWithWorkBlock:(NezGCDBlock)workBlock DoneBlock:(NezGCDBlock)doneBlock {
	[PrivateNezGCD runOnPriorityQueue:DISPATCH_QUEUE_PRIORITY_HIGH WithWorkBlock:workBlock DoneBlock:doneBlock];
}

//This function runs workBlock in the Default Priority Thread and then when that's done runs doneBlock in the Main Thread
+(void)runDefaultPriorityWithWorkBlock:(NezGCDBlock)workBlock DoneBlock:(NezGCDBlock)doneBlock {
	[PrivateNezGCD runOnPriorityQueue:DISPATCH_QUEUE_PRIORITY_DEFAULT WithWorkBlock:workBlock DoneBlock:doneBlock];
}

//This function runs workBlock in the Low Priority Thread and then when that's done runs doneBlock in the Main Thread
+(void)runLowPriorityWithWorkBlock:(NezGCDBlock)workBlock DoneBlock:(NezGCDBlock)doneBlock {
	[PrivateNezGCD runOnPriorityQueue:DISPATCH_QUEUE_PRIORITY_LOW WithWorkBlock:workBlock DoneBlock:doneBlock];
}

//This function runs workBlock in the Background Priority Thread and then when that's done runs doneBlock in the Main Thread
+(void)runBackgroundPriorityWithWorkBlock:(NezGCDBlock)workBlock DoneBlock:(NezGCDBlock)doneBlock {
	[PrivateNezGCD runOnPriorityQueue:DISPATCH_QUEUE_PRIORITY_BACKGROUND WithWorkBlock:workBlock DoneBlock:doneBlock];
}

@end
