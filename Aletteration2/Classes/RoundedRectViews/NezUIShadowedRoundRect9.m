//
//  NezUIShadowedRoundRect9.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-21.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezUIShadowedRoundRect9.h"
#import <QuartzCore/QuartzCore.h>

@implementation NezUIShadowedRoundRect9

-(void)setupRoundBorders {
	self.layer.cornerRadius = 5.5;
	self.layer.borderColor = self.backgroundColor.CGColor;
	self.layer.borderWidth = 1.0;
//	[[self layer] setMasksToBounds:NO];
//	[[self layer] setShadowColor:[UIColor blackColor].CGColor];
//	[[self layer] setShadowOpacity:0.5f];
//	[[self layer] setShadowRadius:10.0f];
//	[[self layer] setShadowOffset:CGSizeMake(5, 5)];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		[self setupRoundBorders];
	}
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setupRoundBorders];
    }
    return self;
}

@end
