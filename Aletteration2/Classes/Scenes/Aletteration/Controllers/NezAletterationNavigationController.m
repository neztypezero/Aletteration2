//
//  NezAletterationNavigationController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2013-09-14.
//  Copyright (c) 2013 Nezsoft. All rights reserved.
//

#import "NezAletterationNavigationController.h"
#import "NezFadeCustomSegue.h"

@implementation NezAletterationNavigationController

-(UIStoryboardSegue*)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
	if ([identifier isEqualToString:@"ResetGameSeque"]) {
		NezFadeCustomSegue *fadeUnwindSegue = [[NezFadeCustomSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
		fadeUnwindSegue.isUnwinding = YES;
		return fadeUnwindSegue;
	}
	return [super segueForUnwindingToViewController:toViewController fromViewController:fromViewController identifier:identifier];
}

@end
