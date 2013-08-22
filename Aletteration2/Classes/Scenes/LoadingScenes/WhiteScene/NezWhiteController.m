//
//  NezWhiteController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-19.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezWhiteController.h"
#import "NezAletterationGameState.h"

@interface NezWhiteController ()

@end

@implementation NezWhiteController

-(void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self startLoading];
	});
}
-(void)startLoading {
	[NezAletterationGameState loadSounds];
	[self performSegueWithIdentifier:@"FromWhiteToSplashSegue" sender:self];
}

@end
