//
//  NezAletterationSinglePlayerController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-22.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezCommandsController.h"
#import "NezAnimation.h"

#define NEZ_ALETTERATION_SELECTION_Z 5.0f

@class NezAletterationLetterBlock;
@class NezAletterationDisplayLine;
@class NezAletterationGameStateObject;

@interface NezAletterationSinglePlayerController : UIViewController<UIGestureRecognizerDelegate> {
}

@property(nonatomic, weak) IBOutlet UIToolbar *pauseMenuToolbar;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *pauseMenuToolbarVerticalConstraint;

@property(nonatomic, weak) NezAletterationLetterBlock *selectedBlock;
@property(nonatomic, weak) NezAletterationDisplayLine *blockOverLine;

@property(nonatomic) BOOL acceptsInput;

-(void)animateCameraToDefaultWithDuration:(float)duration moveSelectedBlock:(BOOL)moveBlock andStopBlock:(NezAnimationBlock)stopBlock;

-(IBAction)showScoringDialog:(id)sender;
-(IBAction)doneAction:(id)sender;
-(IBAction)pauseAction:(id)sender;

-(GLKVector3)getCameraDefaultEye;
-(GLKVector3)getCameraDefaultTarget;
-(GLKVector3)getCameraDefaultUpVector;

-(void)startNextTurn;

@end
