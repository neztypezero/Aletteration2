//
//  NezCommandsController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-19.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezCommandsController.h"
#import "NezEmbededController.h"
#import "NezSinglePlayerAletterationController.h"
#import "NezOptionsController.h"
#import "NezAletterationGameState.h"
#import <QuartzCore/QuartzCore.h>

@interface NezCommandsController () {
	UIPopoverController *popoverController;
	UIButton *popoverSource;
	CGRect popoverSourceOriginalFrame;
}
@end

@implementation NezCommandsController

-(void)viewDidLayoutSubviews {
	[NezAletterationGameState setAletterationLogoFrame:self.logoImageView.frame];
}

-(void)showDialog:(NSString*)segueID {
	self.dialogEmbedView.hidden = NO;
	NezEmbededController *controller = (NezEmbededController*)self.dialogNavController.topViewController;
	controller.parentEmbedView = self.dialogEmbedView;
	[controller performSegueWithIdentifier:segueID sender:controller];
}

-(void)showPopover:(NSString*)storyboardIdentifier Sender:(UIButton*)sender {
	UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardIdentifier];
	viewController.view.alpha = 0.0;
	popoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
	popoverController.delegate = self;
	[popoverController presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown animated:YES];
	[UIView animateWithDuration:0.25 animations:^{
		viewController.view.alpha = 1.0;
	} completion:NULL];
}

-(void)showPopover:(NSString*)segueID Sender:(UIButton*)sender animateToY:(float)y {
	if (y > 0) {
		popoverSource = sender;
		popoverSourceOriginalFrame = sender.frame;
		CGRect frame = popoverSourceOriginalFrame;
		frame.origin.y = y;
		[UIView animateWithDuration:0.25 animations:^{
			sender.frame = frame;
		} completion:^(BOOL finished) {
			[self showPopover:segueID Sender:sender];
		}];
	} else {
		[self showPopover:segueID Sender:sender];
	}
}

-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController*)popoverController {
	[UIView animateWithDuration:0.25 animations:^{
		popoverSource.frame = popoverSourceOriginalFrame;
	} completion:^(BOOL finished) {
		popoverSource = nil;
	}];
	return YES;
}

-(IBAction)showOptionsPopover:(UIButton*)sender {
	[self showPopover:@"NezOptionsController" Sender:sender animateToY:450];
}

-(IBAction)showHighScoresPopover:(UIButton*)sender {
	[self showPopover:@"NezHighScoresController" Sender:sender animateToY:500];
}

-(IBAction)showRulesPopover:(UIButton*)sender {
	[self showPopover:@"NezRulesController" Sender:sender animateToY:550];
}

-(IBAction)showOptionsDialog:(id)sender {
	[self showDialog:@"CommandsOptionsDialogSegue"];
}

-(IBAction)showHighScoresDialog:(id)sender {
	[self showDialog:@"CommandsHighScoresDialogSegue"];
}

-(IBAction)showRulesDialog:(id)sender {
	[self showDialog:@"CommandsRulesDialogSegue"];
}

-(IBAction)showCreditsDialog:(id)sender {
	[self showDialog:@"CommandsCreditsDialogSegue"];
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DialogEmbedSegue"]) {
		self.dialogNavController = segue.destinationViewController;
		self.dialogEmbedView.hidden = YES;
	} else if ([segue.identifier isEqualToString:@"OptionsPopover"]) {
		NezOptionsController *controller = (NezOptionsController*)segue.destinationViewController;
		UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue*)segue;
		controller.optionsPopoverController = popoverSegue.popoverController;
		popoverSegue.popoverController.delegate = controller;
	}
}

@end
