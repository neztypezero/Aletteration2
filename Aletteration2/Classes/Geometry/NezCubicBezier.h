//
//  NezCubicBezier.h
//  Aletteration
//
//  Created by David Nesbitt on 2/25/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>


@interface NezCubicBezier : NSObject {
}

-(id)initWithControlPointsP0:(GLKVector3)p0 P1:(GLKVector3)p1 P2:(GLKVector3)p2 P3:(GLKVector3)p3;

-(GLKVector3)positionAt:(float)t;

@property(nonatomic, readonly) GLKVector3 p0;
@property(nonatomic, readonly) GLKVector3 p1;
@property(nonatomic, readonly) GLKVector3 p2;
@property(nonatomic, readonly) GLKVector3 p3;
	
@end
