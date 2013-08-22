//
//  NezFadeCustomSegue.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-18.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezFadeCustomSegue.h"
#import "QuartzCore/QuartzCore.h"

@implementation NezFadeCustomSegue

-(void)perform {
    CATransition* transition = [CATransition animation];
	
    transition.duration = 0.5;
    transition.type = kCATransitionFade;
	
    [[self.sourceViewController navigationController].view.layer addAnimation:transition forKey:kCATransition];
    [[self.sourceViewController navigationController] pushViewController:[self destinationViewController] animated:NO];
}

@end
