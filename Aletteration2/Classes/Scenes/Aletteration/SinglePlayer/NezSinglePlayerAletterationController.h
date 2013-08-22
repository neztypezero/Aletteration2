//
//  NezSinglePlayerAletterationController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-22.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezCommandsController.h"

#define NEZ_ALETTERATION_SELECTION_Z 5.0f

@class NezAletterationLetterBlock;
@class NezAletterationDisplayLine;

@interface NezSinglePlayerAletterationController : NezCommandsController<UIGestureRecognizerDelegate> {
}

@property(nonatomic, weak) IBOutlet UIToolbar *pauseMenuToolbar;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *pauseMenuToolbarVerticalConstraint;

@property(nonatomic, weak) NezAletterationLetterBlock *selectedBlock;
@property(nonatomic, weak) NezAletterationDisplayLine *blockOverLine;

@property(nonatomic) int currentAnimatingCount;

-(IBAction)showScoringDialog:(id)sender;
-(IBAction)doneAction:(id)sender;
-(IBAction)pauseAction:(id)sender;

@end
