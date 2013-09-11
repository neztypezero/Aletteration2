//
//  NezCreditsController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-20.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezEmbededDialogController.h"

@interface NezCreditsController : NezEmbededDialogController<UIScrollViewDelegate> {
	BOOL scrollingCredits;
	CGPoint scrolledToPoint;
}

@property(nonatomic, strong) IBOutlet UIScrollView *creditsScrollView;
@property(nonatomic, strong) IBOutlet UITextView *creditsTextView;
@property(nonatomic, strong) IBOutlet UIButton *linkButton;

-(IBAction)linkTap:(id)sender;

@end
