//
//  NezCreditsController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-20.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezCreditsController.h"
#import "NezAppDelegate.h"
#import "NezViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface NezCreditsController ()

@end

@implementation NezCreditsController

-(IBAction)dismissDialogAction:(id)sender {
	[NezAppDelegate sharedAppDelegate].glkViewController.paused = NO;
	[self dismissEmbededDialogWithFade];
}

-(void)scrollCredits {
	self.creditsScrollView.contentSize = self.creditsTextView.frame.size;
	scrollingCredits = YES;
	self.creditsScrollView.contentOffset = CGPointMake(0.0, -self.creditsScrollView.bounds.size.height);
	CGPoint bottomOffset = CGPointMake(0, self.creditsScrollView.contentSize.height - self.creditsScrollView.bounds.size.height);

	self.creditsScrollView.hidden = NO;

	[UIView animateWithDuration:20.0
						  delay:0.0
						options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 self.creditsScrollView.contentOffset = bottomOffset;
					 }
					 completion:^(BOOL finished) {
						 if (!finished) {
							 self.creditsScrollView.contentOffset = scrolledToPoint;
						 }
						 self.linkButton.enabled = YES;
					 }
	 ];
}

-(void)viewDidLoad {
	[NezAppDelegate sharedAppDelegate].glkViewController.paused = YES;
	self.creditsScrollView.hidden = YES;
	self.linkButton.enabled = NO;
	scrollingCredits = NO;
	[self performSelector:@selector(scrollCredits)withObject:nil afterDelay:0.25];
}

-(void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
	if (scrollingCredits == YES) {
		scrollingCredits = NO;
		CALayer *presentationLayer = self.creditsScrollView.layer.presentationLayer;
		scrolledToPoint = presentationLayer.bounds.origin;
		[self.creditsScrollView.layer removeAllAnimations];
	}
}

-(IBAction)linkTap:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.aletteration.com"]];
}

@end
