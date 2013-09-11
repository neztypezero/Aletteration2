//
//  NezEmbededController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-19.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezEmbededController.h"

@interface NezEmbededController ()

@end

@implementation NezEmbededController

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[NezEmbededController class]]) {
		NezEmbededController *controller = (NezEmbededController*)segue.destinationViewController;
		controller.parentEmbedView = self.parentEmbedView;
    }
}

@end
