//
//  NezRay.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-11-11.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

/*
 Taken from http://www.cs.utah.edu/~awilliam/box/box.pdf
 
 An Efficient and Robust Ray–Box Intersection Algorithm
 Amy Williams Steve Barrus R. Keith Morley Peter Shirley University of Utah
 */

#import "NezRay.h"

@implementation NezRay

-(id)initWithOrigin:(GLKVector3)origin andDirection:(GLKVector3)direction {
	if ((self = [super init])) {
		_origin = origin;
		_direction = direction;
		_inverseDirection = GLKVector3Make(1.0f/direction.x, 1.0f/direction.y, 1.0f/direction.z);
		_signX = (_inverseDirection.x < 0);
		_signY = (_inverseDirection.y < 0);
		_signZ = (_inverseDirection.z < 0);
	}
	return self;
}

-(id)initWithRay:(NezRay*)ray {
	if ((self = [super init])) {
		_origin = ray.origin;
		_direction = ray.direction;
		_inverseDirection = ray.inverseDirection;
		_signX = ray.signX;
		_signY = ray.signY;
		_signZ = ray.signZ;
	}
	return self;
}

@end
