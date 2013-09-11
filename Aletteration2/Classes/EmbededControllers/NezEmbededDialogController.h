//
//  NezEmbededDialogController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-20.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezEmbededController.h"

@interface NezEmbededDialogController : NezEmbededController

-(void)dismissEmbededDialogWithSlide;
-(void)dismissEmbededDialogWithFade;

-(IBAction)dismissDialogAction:(id)sender;

@end
