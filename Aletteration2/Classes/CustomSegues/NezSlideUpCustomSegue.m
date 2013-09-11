//
//  NezSlideUpCustomSegue.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-20.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezSlideUpCustomSegue.h"

@implementation NezSlideUpCustomSegue

-(void)perform {
	UIViewController *src = [self sourceViewController];
	UIViewController *dst = [self destinationViewController];
	UIView *dstView = dst.view;
	
	[dstView setTransform:CGAffineTransformMakeTranslation(0.0, -src.view.bounds.size.height)];
    [[self.sourceViewController navigationController] pushViewController:dst animated:NO];

	[UIView animateWithDuration:0.5
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 [dstView setTransform:CGAffineTransformMakeTranslation(0.0, 0.0)];
					 }
					 completion:NULL
	 ];
}

@end
