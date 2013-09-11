//
//  NezSplashController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-19.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezSplashController.h"
#import "NezAletterationGameState.h"
#import "NezOpenALPlayer.h"

@interface NezSplashController ()

@end

@implementation NezSplashController

-(void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated {
	dispatch_async(dispatch_get_main_queue(), ^{
		[NezAletterationGameState playSound:[NezAletterationGameState getLoadedSounds].intro withPitch:1.0f];
		[self performSelector:@selector(startLoading) withObject:nil afterDelay:2.5f];
	});
}

-(void)startLoading {
	[self performSegueWithIdentifier:@"FromSplashToLoadingSegue" sender:self];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
