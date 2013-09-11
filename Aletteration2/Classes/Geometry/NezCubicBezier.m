//
//  NezCubicBezier.m
//  Aletteration
//
//  Created by David Nesbitt on 2/25/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezCubicBezier.h"

@implementation NezCubicBezier

-(id)initWithControlPointsP0:(GLKVector3)p0 P1:(GLKVector3)p1 P2:(GLKVector3)p2 P3:(GLKVector3)p3 {
	if ((self = [super init])) {
		P[0] = p0;
		P[1] = p1;
		P[2] = p2;
		P[3] = p3;
	}
	return self;
}

-(GLKVector3)getP0 {
	return P[0];
}

-(GLKVector3)getP1 {
	return P[1];
}

-(GLKVector3)getP2 {
	return P[2];
}

-(GLKVector3)getP3 {
	return P[3];
}

/*
 De Casteljau Algorithm
 http://en.wikipedia.org/wiki/De_Casteljau's_algorithm (Geometric interpretation)
 */
-(GLKVector3)positionAt:(float)t {
	GLKVector3 P01 = GLKVector3Lerp(P[0], P[1], t);
	GLKVector3 P12 = GLKVector3Lerp(P[1], P[2], t);
	GLKVector3 P23 = GLKVector3Lerp(P[2], P[3], t);
	GLKVector3 P0112 = GLKVector3Lerp(P01, P12, t);
	GLKVector3 P1223 = GLKVector3Lerp(P12, P23, t);
	return GLKVector3Lerp(P0112, P1223, t);
}

@end
