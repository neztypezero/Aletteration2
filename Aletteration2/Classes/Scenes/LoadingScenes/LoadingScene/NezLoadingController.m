//
//  NezLoadingController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-18.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezLoadingController.h"
#import "NezAletterationGameState.h"
#import "NezAppDelegate.h"
#import "NezViewController.h"

@interface NezLoadingController ()

@end

@implementation NezLoadingController

-(void)viewDidLoad {
    [super viewDidLoad];
	self.loadingProgressView.progress = 0.0;
}

-(void)viewDidLayoutSubviews {
	[self performSelector:@selector(updateProgress) withObject:nil afterDelay:0.1];
}

-(void)updateProgress {
	float loadingProgress = [NezAletterationGameState getLoadingProgress];
	self.loadingProgressView.progress = loadingProgress;
	if (loadingProgress < 1.0) {
		[self performSelector:@selector(updateProgress) withObject:nil afterDelay:0.1];
	} else {
		[UIView animateWithDuration:0.35
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseOut
						 animations:^{
							 self.logoImage.frame = [NezAletterationGameState getAletterationLogoFrame];
							 self.loadingProgressView.alpha = 0.0;
						 }
						 completion:^(BOOL finished) {
							 [self hideParentEmbedContainer];
						 }];
	}
}

-(void)hideParentEmbedContainer {
	[NezAppDelegate sharedAppDelegate].glkViewController.paused = NO;
	if (self.parentEmbedView != nil) {
		[UIView animateWithDuration:1.0
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^{
							 self.parentEmbedView.alpha = 0.0;
						 }
						 completion:^(BOOL finished) {
							 self.parentEmbedView.hidden = YES;
							 [self.parentEmbedView removeFromSuperview];
						 }];
	}
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
