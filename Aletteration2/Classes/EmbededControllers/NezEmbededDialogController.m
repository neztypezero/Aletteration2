//
//  NezEmbededDialogController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-20.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezEmbededDialogController.h"

@interface NezEmbededDialogController ()

@end

@implementation NezEmbededDialogController

-(void)dismissEmbededDialogWithSlide {
	if (self.navigationController != nil) {
		UIView *dstView = self.view;
		CGFloat h = dstView.frame.size.height;
		[UIView animateWithDuration:0.5
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
							 [dstView setTransform:CGAffineTransformMakeTranslation(0.0, -h)];
						 }
						 completion:^(BOOL finished) {
							 dstView.hidden = YES;
							 [self.navigationController popViewControllerAnimated:NO];
						 }
		 ];
	}
}

-(void)dismissEmbededDialogWithFade {
	if (self.navigationController != nil) {
		UIView *dstView = self.view;
		
		[UIView animateWithDuration:1.0
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^{
							 dstView.alpha = 0.0;
						 }
						 completion:^(BOOL finished) {
							 dstView.hidden = YES;
							 [self.navigationController popViewControllerAnimated:NO];
						 }
		 ];
	}
}

-(IBAction)dismissDialogAction:(id)sender {
	[self dismissEmbededDialogWithSlide];
}

@end
