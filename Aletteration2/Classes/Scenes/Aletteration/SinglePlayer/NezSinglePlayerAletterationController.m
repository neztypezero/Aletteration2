//
//  NezSinglePlayerAletterationController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-22.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezSinglePlayerAletterationController.h"
#import "NezOptionsController.h"
#import "NezAletterationGameState.h"
#import "NezCamera.h"
#import "NezAnimator.h"
#import "NezAnimation.h"
#import "NezCubicBezier.h"
#import "NezCubicBezierAnimation.h"
#import "NezAletterationBox.h"
#import "NezAletterationLid.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationLetterStack.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationDisplayLine.h"
#import "NezAppDelegate.h"
#import "NezAletterationPrefs.h"
#import "NezAletterationScoreboard.h"
#import "NezAletterationAnimationInitial.h"
#import "NezAletterationAnimationReset.h"

const float NEZ_ALETTERATION_LID_ROTATION = 1.1;

typedef enum NezAletterationCameraPositionEnum {
	NezAletterationCameraPositionJunk,
	NezAletterationCameraPositionGameboard,
	NezAletterationCameraPositionScoreboard
} NezAletterationCameraPositionEnum;

@interface NezSinglePlayerAletterationController () {
	UIPopoverController *_currentPopoverController;
	NSString *_currentPopoverID;
	NezCamera *_camera;
	BOOL _tapInsideSelectedBlock;
	BOOL _tapCloseToSelectedBlock;
	GLKVector3 _eyeOnDrag;
	NezAletterationCameraPositionEnum _cameraPosition;
}

@end

@implementation NezSinglePlayerAletterationController

-(GLKVector3)getCameraDefaultEye {
	return GLKVector3Make(0.0f, 0.0f, [self getZoomForDisplayLine]);
}

-(GLKVector3)getCameraDefaultTarget {
	return GLKVector3Make(0.0f, 0.0f, 0.0);
}

-(GLKVector3)getCameraDefaultUpVector {
	return GLKVector3Make(0.0f, 1.0f, 0.0f);
}

-(id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		_camera = [NezAletterationGameState getCamera];
		_tapInsideSelectedBlock = NO;
		_tapCloseToSelectedBlock = NO;
	}
	return self;
}

-(void)viewDidLoad {
	UIPanGestureRecognizer *dragBoardHorizontal;
	dragBoardHorizontal = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragBoard:)];
	dragBoardHorizontal.cancelsTouchesInView = NO;
	dragBoardHorizontal.delaysTouchesBegan = NO;
	dragBoardHorizontal.delaysTouchesEnded = NO;
	dragBoardHorizontal.delegate = self;
	[self.view addGestureRecognizer:dragBoardHorizontal];
	
	
//	NezAletterationPrefsObject *prefs = [NezAletterationGameState getPreferences];
	
//	if (prefs.stateObject != nil && prefs.stateObject.turn > 0) {
//		[self setupFromStateObject:prefs.stateObject];
//	} else {
		[NezAletterationAnimationInitial doAnimationFor:self WithStopBlock:^(NezAnimation *ani) {
			[self startGame:nil];
		}];
//	}
}

-(void)setupFromStateObject:(NezAletterationGameStateObject*)stateObject {
	NezAletterationBox *box = [NezAletterationGameState getBox];
	for (char letter='a'; letter <= 'z'; letter++) {
		NezAletterationLetterGroup *letterGroup = [box getLetterGroupForLetter:letter];
		NezAletterationLetterStack *stack = [NezAletterationGameState getLetterStackForLetter:letter];

		for (NezAletterationLetterBlock *letterBlock in letterGroup.letterBlockList) {
			[stack pushLetterBlock:letterBlock];
		}
		[letterGroup.letterBlockList removeAllObjects];
	}
	GLKVector3 endPos = [NezAletterationAnimationInitial getBoxEndPos];
	[box dettachLid].modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(endPos.x, endPos.y, endPos.z), [NezAletterationAnimationInitial getLidRotationMatrix]);
	box.modelMatrix = [NezAletterationAnimationInitial getBoxEndMatrix];
	_cameraPosition = NezAletterationCameraPositionGameboard;
	[_camera setEye:[self getCameraDefaultEye] Target:[self getCameraDefaultTarget] UpVector:[self getCameraDefaultUpVector]];
	[NezAletterationGameState startGame:stateObject];
	[self startNextTurnNoAnimation];
}

-(void)animateSelectedBlockToDefaultPosition {
	if (self.selectedBlock != nil) {
		GLKMatrix4 defaultPositionMatrix = [self getDefaultPositionMatrix];
		
		NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:self.selectedBlock.modelMatrix ToData:defaultPositionMatrix Duration:0.25 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
			GLKMatrix4 *modelMatrix = (GLKMatrix4*)ani->newData;
			self.selectedBlock.modelMatrix = *modelMatrix;
		} DidStopBlock:^(NezAnimation *ani) {
		}];
		[NezAnimator addAnimation:ani];
	}
}

-(void)animateCameraToDefaultWithDuration:(float)duration moveSelectedBlock:(BOOL)moveBlock andStopBlock:(NezAnimationBlock)stopBlock {
	GLKVector3 fromData[] = {
		_camera.eye, _camera.target, _camera.upVector
	};
	GLKVector3 toData[] = {
		[self getCameraDefaultEye], [self getCameraDefaultTarget], [self getCameraDefaultUpVector]
	};
	_cameraPosition = NezAletterationCameraPositionGameboard;
	NezAnimation *ani = [[NezAnimation alloc] initWithFromData:(float*)fromData ToData:(float*)toData DataLength:sizeof(GLKVector3)*3 Duration:duration EasingFunction:easeOutCubic UpdateBlock:^(NezAnimation *ani) {
		float *data = ani->newData;
		[_camera setEye:GLKVector3Make(data[0], data[1], data[2]) Target:GLKVector3Make(data[3], data[4], data[5]) UpVector:GLKVector3Make(data[6], data[7], data[8])];
		if (self.selectedBlock != nil && moveBlock) {
			self.selectedBlock.modelMatrix = [self getDefaultPositionMatrix];
		}
	} DidStopBlock:stopBlock];
	[NezAnimator addAnimation:ani];
}

-(void)animateCameraToJunkWithDuration:(float)duration andStopBlock:(NezAnimationBlock)stopBlock {
	GLKVector3 fromData[] = {
		_camera.eye, _camera.target, _camera.upVector
	};
	GLKVector3 toData[] = {
		[self getCameraDefaultEye], [self getCameraDefaultTarget], [self getCameraDefaultUpVector]
	};
	float unitsPerPixel = [self getUnitsPerPixel];
	toData[0].x += unitsPerPixel*_camera.viewport.size.width;
	toData[1].x = toData[0].x;
	_cameraPosition = NezAletterationCameraPositionJunk;
	NezAnimation *ani = [[NezAnimation alloc] initWithFromData:(float*)fromData ToData:(float*)toData DataLength:sizeof(GLKVector3)*3 Duration:duration EasingFunction:easeOutCubic UpdateBlock:^(NezAnimation *ani) {
		float *data = ani->newData;
		[_camera setEye:GLKVector3Make(data[0], data[1], data[2]) Target:GLKVector3Make(data[3], data[4], data[5]) UpVector:GLKVector3Make(data[6], data[7], data[8])];
	} DidStopBlock:stopBlock];
	[NezAnimator addAnimation:ani];
}

-(void)animateCameraToScoreboardWithDuration:(float)duration andStopBlock:(NezAnimationBlock)stopBlock {
	NezAletterationScoreboard *scoreboard = [NezAletterationGameState getScoreboard];
	GLKVector3 fromData[] = {
		_camera.eye,
		_camera.target,
		_camera.upVector
	};
	NezCamera *cam = [scoreboard getCameraWithCurrentCamera:_camera andDefaultZ:[self getCameraDefaultEye].z];
	GLKVector3 toData[] = {
		cam.eye,
		cam.target,
		[self getCameraDefaultUpVector]
	};
	_cameraPosition = NezAletterationCameraPositionScoreboard;
	NezAnimation *ani = [[NezAnimation alloc] initWithFromData:(float*)fromData ToData:(float*)toData DataLength:sizeof(GLKVector3)*3 Duration:duration EasingFunction:easeOutCubic UpdateBlock:^(NezAnimation *ani) {
		float *data = ani->newData;
		[_camera setEye:GLKVector3Make(data[0], data[1], data[2]) Target:GLKVector3Make(data[3], data[4], data[5]) UpVector:GLKVector3Make(data[6], data[7], data[8])];
	} DidStopBlock:stopBlock];
	[NezAnimator addAnimation:ani];
}

-(void)animateCameraLeftWithDuration:(float)duration andStopBlock:(NezAnimationBlock)stopBlock {
	switch (_cameraPosition) {
		case NezAletterationCameraPositionJunk:
			[self animateCameraToJunkWithDuration:duration andStopBlock:stopBlock];
			break;
		case NezAletterationCameraPositionGameboard:
			[self animateCameraToJunkWithDuration:duration andStopBlock:stopBlock];
			break;
		case NezAletterationCameraPositionScoreboard:
			[self animateCameraToDefaultWithDuration:duration moveSelectedBlock:NO andStopBlock:stopBlock];
			break;
		default:
			[self animateCameraToDefaultWithDuration:duration moveSelectedBlock:NO andStopBlock:stopBlock];
			break;
	}
}

-(void)animateCameraRightWithDuration:(float)duration andStopBlock:(NezAnimationBlock)stopBlock {
	switch (_cameraPosition) {
		case NezAletterationCameraPositionJunk:
			[self animateCameraToDefaultWithDuration:duration moveSelectedBlock:NO andStopBlock:stopBlock];
			break;
		case NezAletterationCameraPositionGameboard:
			[self animateCameraToScoreboardWithDuration:duration andStopBlock:stopBlock];
			break;
		case NezAletterationCameraPositionScoreboard:
			[self animateCameraToScoreboardWithDuration:duration andStopBlock:stopBlock];
			break;
		default:
			[self animateCameraToDefaultWithDuration:duration moveSelectedBlock:NO andStopBlock:stopBlock];
			break;
	}
}

-(void)animateCameraSameWithDuration:(float)duration andStopBlock:(NezAnimationBlock)stopBlock {
	switch (_cameraPosition) {
		case NezAletterationCameraPositionJunk:
			[self animateCameraToJunkWithDuration:duration andStopBlock:stopBlock];
			break;
		case NezAletterationCameraPositionGameboard:
			[self animateCameraToDefaultWithDuration:duration moveSelectedBlock:NO andStopBlock:stopBlock];
			break;
		case NezAletterationCameraPositionScoreboard:
			[self animateCameraToScoreboardWithDuration:duration andStopBlock:stopBlock];
			break;
		default:
			[self animateCameraToDefaultWithDuration:duration moveSelectedBlock:NO andStopBlock:stopBlock];
			break;
	}
}

-(float)getZoomForDisplayLine {
	NSArray *displayLineList = [NezAletterationGameState getDisplayLineList];
	NezAletterationDisplayLine *line = displayLineList.lastObject;
	
	float zoomOffset = 40.0;
	NezCamera *cam = [[NezCamera alloc] initWithEye:GLKVector3Make(0.0, 0.0, zoomOffset) Target:GLKVector3Make(0.0, 0.0, 0.0) UpVector:GLKVector3Make(0.0, 1.0, 0.0)];
	[cam setupProjectionMatrix:_camera.viewport];
	GLKVector3 worldCoordinates = GLKVector3Make(line.minX, line.maxY, line.minZ);
	GLKVector2 pos = [cam getScreenCoordinates:worldCoordinates];
	for (;;) {
		pos = [cam getScreenCoordinates:worldCoordinates];
		if (pos.x > 5.1) {
			zoomOffset /= 2.0;
			[cam setEye:GLKVector3Make(0.0, 0.0, cam.eye.z-zoomOffset) Target:cam.target UpVector:cam.upVector];
		} else if (pos.x < 4.9) {
			zoomOffset *= 1.5;
			[cam setEye:GLKVector3Make(0.0, 0.0, cam.eye.z+zoomOffset) Target:cam.target UpVector:cam.upVector];
		} else {
			return cam.eye.z;
		}
	}
}

-(IBAction)showScoringDialog:(id)sender {
	[self showDialog:@"CommandsScoringDialogSegue"];
}

-(IBAction)doneAction:(id)sender {
	[self exitGame];
}

-(IBAction)pauseAction:(id)sender {
	[self showToolbar];
}

-(IBAction)resumeAction:(id)sender {
	[self hideToolbar];
}

-(BOOL)hidePopoverWithIdentifier:(NSString *)identifier {
	if (_currentPopoverController != nil) {
		if (_currentPopoverController.popoverVisible) {
			[_currentPopoverController dismissPopoverAnimated:YES];
			_currentPopoverController = nil;
		} else {
			_currentPopoverController = nil;
			return YES;
		}
		if ([_currentPopoverID isEqualToString:identifier]) {
			return NO;
		}
		return YES;
	}
	return YES;
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
	return [self hidePopoverWithIdentifier:identifier];
}

-(void)showPopover:(UIStoryboardPopoverSegue*)popoverSegue {
	_currentPopoverController = popoverSegue.popoverController;
	_currentPopoverID = popoverSegue.identifier;

	UIViewController *viewController = popoverSegue.destinationViewController;
	viewController.view.alpha = 0.0;
	[UIView animateWithDuration:0.25 animations:^{
		viewController.view.alpha = 1.0;
	} completion:NULL];
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"OptionsPopover"]) {
		NezOptionsController *controller = (NezOptionsController*)segue.destinationViewController;
		UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue*)segue;
		controller.optionsPopoverController = popoverSegue.popoverController;
		popoverSegue.popoverController.delegate = controller;
		[self showPopover:popoverSegue];
	} else if ([segue.identifier isEqualToString:@"ScoringPopoverSegue"]) {
		UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue*)segue;
		[self showPopover:popoverSegue];
	}
	[super prepareForSegue:segue sender:sender];
}

-(GLKMatrix4)getDefaultPositionMatrix {
	CGSize size = _camera.viewport.size;
	GLKVector2 screenPos = GLKVector2Make(size.width/2.0, size.height*0.75);
	GLKVector3 pos = [_camera getWorldCoordinates:screenPos atWorldZ:NEZ_ALETTERATION_SELECTION_Z];
	return GLKMatrix4MakeTranslation(pos.x, pos.y, pos.z);
}

-(void)startGame:(NezAletterationGameStateObject*)stateObject  {
	[NezAletterationGameState startGame:stateObject];
	[self performSelector:@selector(startNextTurn) withObject:nil afterDelay:0.25];
}

-(void)exitGame {
	[self hidePopoverWithIdentifier:nil];
	[self hideToolbar];
	
	[NezAletterationAnimationReset doAnimationFor:self WithStopBlock:^(NezAnimation *ani) {
		[self performSegueWithIdentifier:@"ResetGameSeque" sender:self];
		[NezAletterationGameState reset];
	}];
}

-(void)showToolbar {
	self.pauseMenuToolbarVerticalConstraint.constant = 0;
	[self.view setNeedsUpdateConstraints];
	
	[UIView animateWithDuration:0.25f animations:^{
		[self.view layoutIfNeeded];
	}];
}

-(void)hideToolbar {
	[self hidePopoverWithIdentifier:nil];
	self.pauseMenuToolbarVerticalConstraint.constant = -self.pauseMenuToolbar.frame.size.height;
	[self.view setNeedsUpdateConstraints];
	
	[UIView animateWithDuration:0.25f animations:^{
		[self.view layoutIfNeeded];
	}];
}

-(GLKVector2)getPositionForAnyTouch:(NSSet*)touches TapCount:(int*)tapCount {
	return [self getPositionTouch:[touches anyObject] TapCount:tapCount];
}

-(GLKVector2)getPositionTouch:(UITouch*)touch TapCount:(int*)tapCount {
	if (tapCount) {
		*tapCount = [touch tapCount];
	}
	CGPoint currentLocation = [touch locationInView:self.view];
	return GLKVector2Make(currentLocation.x, currentLocation.y);
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	NSLog(@"touchesBegan");
	int tapCount;
	GLKVector2 touchPos = [self getPositionForAnyTouch:touches TapCount:&tapCount];
	NezRay *ray = [_camera getWorldRay:touchPos];
	if ([self.selectedBlock intersect:ray]) {
		_tapInsideSelectedBlock = YES;
	} else {
		_tapInsideSelectedBlock = NO;
		if ([self.selectedBlock intersect:ray withExtraSize:0.5]) {
			_tapCloseToSelectedBlock = YES;
		} else {
			_tapCloseToSelectedBlock = NO;
		}
	}
}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	NSLog(@"touchesMoved");
	int tapCount;
	GLKVector2 touchPos = [self getPositionForAnyTouch:touches TapCount:&tapCount];
	NezRay *ray = [_camera getWorldRay:touchPos];
	if (_tapCloseToSelectedBlock) {
		if ([self.selectedBlock intersect:ray]) {
			_tapInsideSelectedBlock = YES;
			_tapCloseToSelectedBlock = NO;
		}
	}
	if (_tapInsideSelectedBlock) {
		GLKVector3 worldPos = [_camera getWorldCoordinates:touchPos atWorldZ:NEZ_ALETTERATION_SELECTION_Z];
		[self.selectedBlock setMidPoint:worldPos];
		NezAletterationDisplayLine *displayLine = [NezAletterationGameState getDisplayIntersectingRay:ray];
		if (displayLine != self.blockOverLine) {
			[self.blockOverLine animateDeselected];
			self.blockOverLine = displayLine;
			[self.blockOverLine animateSelected];
		}
	}
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	NSLog(@"touchesEnded");
	if (self.blockOverLine) {
		GLKVector3 linePos = [self.blockOverLine getNextLetterBlockPosition];
		NezAnimation *ani = [[NezAnimation alloc] initVec3WithFromData:[self.selectedBlock getMidPoint] ToData:linePos Duration:0.25 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
			GLKVector3 *midPoint = (GLKVector3*)ani->newData;
			[self.selectedBlock setMidPoint:*midPoint];
		} DidStopBlock:^(NezAnimation *ani) {
			[self.blockOverLine animateDeselected];
			[self endTurn];
		}];
		[NezAnimator addAnimation:ani];
	} else {
		if (_tapInsideSelectedBlock) {
			[self animateSelectedBlockToDefaultPosition];
		} else {
			int tapCount = 0;
			GLKVector2 touchPos = [self getPositionForAnyTouch:touches TapCount:&tapCount];
			if (tapCount == 2) {
				NezRay *ray = [_camera getWorldRay:touchPos];
				NezAletterationDisplayLine *displayLine = [NezAletterationGameState getDisplayIntersectingRay:ray];
				if (displayLine && displayLine.isWord) {
					[NezAletterationGameState retireWordForDisplayLine:displayLine];
				}
			}
		}
	}
	_tapInsideSelectedBlock = NO;
	_tapCloseToSelectedBlock = NO;
}

-(void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
	_tapInsideSelectedBlock = NO;
	_tapCloseToSelectedBlock = NO;
	if (self.blockOverLine) {
		
	} else {
		[self animateSelectedBlockToDefaultPosition];
	}
}

-(void)endTurn {
	[NezAletterationGameState endTurn:self.blockOverLine.lineIndex withBlock:^{
		self.blockOverLine = nil;
		[self startNextTurn];
	}];
}

-(void)startNextTurn {
	self.selectedBlock = [NezAletterationGameState startNextTurn:YES];
	if (self.selectedBlock != nil) {
		[self performSelector:@selector(animateSelectedBlockToDefaultPosition) withObject:nil afterDelay:0.25];
	} else {
		// do game over!!!
	}
}

-(void)startNextTurnNoAnimation {
	self.selectedBlock = [NezAletterationGameState startNextTurn:NO];
	GLKMatrix4 defaultPositionMatrix = [self getDefaultPositionMatrix];
	self.selectedBlock.modelMatrix = defaultPositionMatrix;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	CGRect viewport = [NezAppDelegate getScreenBoundsForOrientation:toInterfaceOrientation];
	[_camera setupProjectionMatrix:viewport];
	[self animateCameraToDefaultWithDuration:duration moveSelectedBlock:YES andStopBlock:nil];
}

-(float)getUnitsPerPixel {
	GLKVector3 pZero = [_camera getWorldCoordinates:GLKVector2Make(0, 0) atWorldZ:_camera.target.z];
	GLKVector3 pOne = [_camera getWorldCoordinates:GLKVector2Make(1, 0) atWorldZ:_camera.target.z];
	return pZero.x-pOne.x;
}

-(void)dragBoard:(UIPanGestureRecognizer*)sender {
	if (_tapInsideSelectedBlock == NO && _tapCloseToSelectedBlock == NO) {
		CGPoint translation = [sender translationInView:self.view];
		if (sender.state == UIGestureRecognizerStateBegan) {
			_eyeOnDrag = _camera.eye;
		} else if (sender.state == UIGestureRecognizerStateChanged) {
			float unitsPerPixel = [self getUnitsPerPixel];
			GLKVector3 eye = {_eyeOnDrag.x+translation.x*unitsPerPixel, _eyeOnDrag.y, _eyeOnDrag.z};
			GLKVector3 target = {eye.x, eye.y, _camera.target.z};
			[_camera setEye:eye Target:target UpVector:_camera.upVector];
		} else if (sender.state == UIGestureRecognizerStateEnded) {
			if (translation.x > _camera.viewport.size.width/2.0) {
				[self animateCameraLeftWithDuration:0.25 andStopBlock:nil];
			} else if (translation.x < -_camera.viewport.size.width/2.0) {
				[self animateCameraRightWithDuration:0.25 andStopBlock:nil];
			} else {
				CGPoint velocity = [sender velocityInView:self.view];
				if (velocity.x > 800.0) {
					[self animateCameraLeftWithDuration:0.25 andStopBlock:nil];
				} else if (velocity.x < -800.0) {
					[self animateCameraRightWithDuration:0.25 andStopBlock:nil];
				} else {
					[self animateCameraSameWithDuration:0.25 andStopBlock:nil];
				}
			}
		}
	}
}

@end
