//
//  NezNothingController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-20.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezNothingController.h"

@interface NezNothingController ()

@end

@implementation NezNothingController

-(void)viewDidAppear:(BOOL)animated {
	self.parentEmbedView.hidden = YES;
}

@end
