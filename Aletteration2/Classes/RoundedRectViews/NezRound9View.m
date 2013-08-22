//
//  NezRound9View.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-21.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezRound9View.h"
#import <QuartzCore/QuartzCore.h>

@implementation NezRound9View

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setRoundBorders];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setRoundBorders];
    }
    return self;
}

-(void)setRoundBorders {
	self.layer.borderColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.85].CGColor;
	self.layer.borderWidth = 2.0;
	self.layer.cornerRadius = 9;
}

@end
