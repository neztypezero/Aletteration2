//
//  NezCubicBezierAnimation.m
//  Aletteration
//
//  Created by David Nesbitt on 2/26/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezCubicBezierAnimation.h"
#import "NezCubicBezier.h"


@implementation NezCubicBezierAnimation

-(id)initWithControlPointsP0:(GLKVector3)p0 P1:(GLKVector3)p1 P2:(GLKVector3)p2 P3:(GLKVector3)p3 Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	if ((self=[super initFloatWithFromData:0.0 ToData:1.0 Duration:d EasingFunction:func UpdateBlock:updateBlock DidStopBlock:didStopBlock])) {
		self.bezier = [[NezCubicBezier alloc] initWithControlPointsP0:p0 P1:p1 P2:p2 P3:p3];
	}
	return self;
}

-(void)dealloc {
	self.bezier = nil;
}

@end
