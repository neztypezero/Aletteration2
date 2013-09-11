//
//  NezAletterationLid.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-11-04.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayGeometry.h"

@interface NezAletterationLid : NezVertexArrayGeometry

@property(nonatomic, readonly, getter = getLidThickness) float thickness;

@end
