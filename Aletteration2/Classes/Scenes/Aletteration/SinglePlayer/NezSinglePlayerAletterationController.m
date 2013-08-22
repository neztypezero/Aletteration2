//
//  NezSinglePlayerAletterationController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-22.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
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

-(GLKVector3)getBoxEndPos {
	NezAletterationBox *box = [NezAletterationGameState getBox];
	GLKVector3 boxSize = box.size;
	GLKVector3 blockSize = [NezAletterationLetterBlock getBlockSize];
	GLKVector3 endPos = {-boxSize.z, blockSize.y*8.0, 0.0};
	return endPos;
}

-(GLKMatrix4)getLidRotationMatrix {
	GLKMatrix4 matRotX = GLKMatrix4MakeXRotation(-M_PI);
	GLKMatrix4 matRotZ = GLKMatrix4MakeZRotation(NEZ_ALETTERATION_LID_ROTATION);
	return GLKMatrix4Multiply(matRotX, matRotZ);
}

-(GLKMatrix4)getBoxRestMatrix {
	GLKVector3 endPos = [self getBoxEndPos];
	GLKMatrix4 matRotZ = GLKMatrix4MakeZRotation(-NEZ_ALETTERATION_LID_ROTATION);
	return GLKMatrix4Multiply(GLKMatrix4MakeTranslation(endPos.x, endPos.y, endPos.z), matRotZ);
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
	
	
	NezAletterationPrefsObject *prefs = [NezAletterationGameState getPreferences];
	
	if (prefs.stateObject != nil && prefs.stateObject.turn > 0) {
		[self setupFromStateObject:prefs.stateObject];
	} else {
		[self startInitialAnimationWithStopBlock:^(NezAnimation *ani) {
			[self animateStage2];
			[self animateCameraToDefaultWithDuration:2.50 moveSelectedBlock:YES andStopBlock:nil];
		}];
	}
}

-(void)setupFromStateObject:(NezAletterationGameStateObject*)stateObject {
	NezAletterationBox *box = [NezAletterationGameState getBox];
	for (char letter='a'; letter <= 'z'; letter++) {
		NezAletterationBoxLetterPlaceHolder *placeHolder = [box getPlaceHolderForLetter:letter];
		NezAletterationLetterStack *stack = [NezAletterationGameState getLetterStackForLetter:letter];

		for (NezAletterationLetterBlock *letterBlock in placeHolder.letterBlockList) {
			[stack pushLetterBlock:letterBlock];
		}
		[placeHolder.letterBlockList removeAllObjects];
	}
	GLKVector3 endPos = [self getBoxEndPos];
	[box dettachLid].modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(endPos.x, endPos.y, endPos.z), [self getLidRotationMatrix]);
	box.modelMatrix = [self getBoxRestMatrix];
	_cameraPosition = NezAletterationCameraPositionGameboard;
	[_camera setEye:[self getCameraDefaultEye] Target:[self getCameraDefaultTarget] UpVector:[self getCameraDefaultUpVector]];
	[NezAletterationGameState startGame:stateObject];
	[self startNextTurnNoAnimation];
}

-(void)startInitialAnimationWithStopBlock:(NezAnimationBlock)stopBlock {
	GLKVector3 fromData[] = {
		_camera.eye, _camera.target, _camera.upVector
	};
	GLKVector3 toData[] = {
		GLKVector3Make(-5.0f, -10.0f, 5.0f), GLKVector3Make(0.0f, 0.0f, 0.0f), GLKVector3Make(0.0f, 0.0f, 1.0f)
	};
	NezAnimation *ani = [[NezAnimation alloc] initWithFromData:(float*)fromData ToData:(float*)toData DataLength:sizeof(GLKVector3)*3 Duration:1.0 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		float *data = ani->newData;
		[_camera setEye:GLKVector3Make(data[0], data[1], data[2]) Target:GLKVector3Make(data[3], data[4], data[5]) UpVector:GLKVector3Make(data[6], data[7], data[8])];
	} DidStopBlock:stopBlock];
	[NezAnimator addAnimation:ani];
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
	
//	GLKMatrix4 pM = _camera.projectionMatrix;
//	CGSize size = _camera.viewport.size;
//	
//	float inset = 5.0;
//	
//	float screenX = (size.width-inset);
//	float homogenizedX = (screenX*2.0/size.width)-1.0;
//	
//	float maxX = line.maxX;
//	float zX = (pM.m00*maxX+pM.m32)/(homogenizedX);
//	
//	float screenY = (size.height-inset);
//	float homogenizedY = (screenY*2.0/size.height)-1.0;
//	
//	float maxY = line.maxY;
//	float zY = (pM.m11*maxY+pM.m32)/(homogenizedY);
//
//	NSLog(@"cam.eye.z:%f, zX:%f, zY:%f", cam.eye.z, zX, zY);
//	if (zY > zX) {
//		return zY;
//	} else {
//		return zX;
//	}
}

-(void)animateStage2 {
	GLKVector3 blockSize = [NezAletterationLetterBlock getBlockSize];
	NezAletterationBox *box = [NezAletterationGameState getBox];
	NezAletterationLid *lid = [box dettachLid];
	GLKVector3 boxSize = box.size;
	GLKMatrix4 boxMatrix = box.modelMatrix;
	GLKMatrix4 rot = GLKMatrix4MakeRotation(M_PI*0.2, 1.0, -1.0, -1.0);
	rot.m30 = boxMatrix.m30 + boxSize.z;
	rot.m31 = boxMatrix.m31 + boxSize.y*0.5;
	rot.m32 = boxMatrix.m32 + boxSize.z*2.0f;
	
	float duration = 1.6;
	NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:boxMatrix ToData:rot Duration:duration*0.5 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		GLKMatrix4 *mat = (GLKMatrix4*)ani->newData;
		box.modelMatrix = *mat;
	} DidStopBlock:^(NezAnimation *ani) {
		self.currentAnimatingCount = 0;
		for (char letter='a'; letter <= 'z'; letter++) {
			NezAletterationBoxLetterPlaceHolder *placeHolder = [box getPlaceHolderForLetter:letter];
			float distance = blockSize.y*(0.5+randomNumber()*0.5);
			NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:0.0 ToData:distance Duration:distance*0.5 EasingFunction:easeInCubic UpdateBlock:^(NezAnimation *ani) {
				placeHolder.offset = GLKVector3Make(0.0, 0.0, ani->newData[0]);
				[placeHolder updateMatrices:box.modelMatrix];
			} DidStopBlock:^(NezAnimation *ani) {
				[self animateLetterPush:placeHolder];
				if (self.currentAnimatingCount == [NezAletterationGameState getTotalLetterCount]) {
					GLKMatrix4 mat = [self getBoxRestMatrix];
					NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:box.modelMatrix ToData:mat Duration:duration*0.75 EasingFunction:easeOutCubic UpdateBlock:^(NezAnimation *ani) {
						GLKMatrix4 *mat = (GLKMatrix4*)ani->newData;
						box.modelMatrix = *mat;
					} DidStopBlock:nil];
					[NezAnimator addAnimation:ani];
				};
			}];
			ani->delay = randomNumber()*1.25;
			[NezAnimator addAnimation:ani];
		}
	}];
	[NezAnimator addAnimation:ani];

	GLKMatrix4 lidMatrix = lid.modelMatrix;
	GLKVector3 midPoint = [lid getMidPoint];
	
	NezCubicBezierAnimation *cbani = [[NezCubicBezierAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:duration EasingFunction:easeLinear UpdateBlock:^(NezAnimation *ani) {
		NezCubicBezierAnimation *cbani = (NezCubicBezierAnimation*)ani;
		GLKMatrix4 mat = lid.modelMatrix;
		GLKVector3 p = [cbani.bezier positionAt:ani->newData[0]];
		mat.m30 = p.x;
		mat.m31 = p.y;
		mat.m32 = p.z;
		lid.modelMatrix = mat;
	} DidStopBlock:^(NezAnimation *ani) {
	}];
	GLKVector3 endPos = [self getBoxEndPos];
	GLKVector3 P1 = {midPoint.x+(endPos.x-midPoint.x)*0.25, midPoint.y+(endPos.y-midPoint.y)*0.25, midPoint.z+(endPos.z-midPoint.z)*(-10.0)};
	GLKVector3 P2 = {midPoint.x+(endPos.x-midPoint.x)*0.75, midPoint.y+(endPos.y-midPoint.y)*0.75, midPoint.z+(endPos.z-midPoint.z)*(-10.0)};
	cbani.bezier = [[NezCubicBezier alloc] initWithControlPointsP0:midPoint P1:P1 P2:P2 P3:endPos];
	[NezAnimator addAnimation:cbani];
	
	GLKMatrix4 matRotX = GLKMatrix4MakeXRotation(-M_PI/2.0);
	GLKMatrix4 lidMidMatrix = matRotX;
	
	GLKMatrix4 lidRestMatrix = [self getLidRotationMatrix];
	
	NezAnimationBlock rotBlock = ^(NezAnimation *ani) {
		GLKMatrix4 *mat = (GLKMatrix4*)ani->newData;
		GLKMatrix4 modelMatrix = lid.modelMatrix;
		mat->m30 = modelMatrix.m30;
		mat->m31 = modelMatrix.m31;
		mat->m32 = modelMatrix.m32;
		lid.modelMatrix = *mat;
	};
	NezAnimation *lidRotAni = [[NezAnimation alloc] initMat4WithFromData:lidMatrix ToData:lidMidMatrix Duration:duration*0.25 EasingFunction:easeInCubic UpdateBlock:rotBlock DidStopBlock:nil];
	lidRotAni->delay = duration*0.15;
	lidRotAni.chainLink = [[NezAnimation alloc] initMat4WithFromData:lidMidMatrix ToData:lidRestMatrix Duration:duration*0.6 EasingFunction:easeOutCubic UpdateBlock:rotBlock DidStopBlock:nil];
	[NezAnimator addAnimation:lidRotAni];
}

-(void)animateLetterPush:(NezAletterationBoxLetterPlaceHolder*)placeHolder {
	GLKVector3 dimensions = [NezAletterationLetterBlock getBlockSize];
	float delay = 0.0;
	float duration = 0.3;
	NSMutableArray *letterBlockList = [placeHolder getLetterBlockList];
	for (NezAletterationLetterBlock *letterBlock in letterBlockList) {
		self.currentAnimatingCount++;
		
		NezAletterationLetterStack *stack = [NezAletterationGameState getLetterStackForLetter:letterBlock.letter];

		GLKMatrix4 mat = GLKMatrix4Multiply(letterBlock.modelMatrix, GLKMatrix4MakeTranslation(0.0, -dimensions.y*1.5, 0.0));
		NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:letterBlock.modelMatrix ToData:mat Duration:duration EasingFunction:easeLinear UpdateBlock:^(NezAnimation *ani) {
			GLKMatrix4 *mat = (GLKMatrix4*)ani->newData;
			letterBlock.modelMatrix = *mat;
		} DidStopBlock:^(NezAnimation *ani) {
			GLKVector3 endPos = [stack getNextLetterBlockPosition];
			GLKVector3 midPoint = [letterBlock getMidPoint];
			GLKMatrix4 curveMat = GLKMatrix4MakeTranslation(endPos.x, endPos.y, endPos.z);

			[stack deferredPushLetterBlock:letterBlock];

			GLKVector3 P1 = {midPoint.x+(endPos.x-midPoint.x)*0.25, midPoint.y+(endPos.y-midPoint.y)*0.25, midPoint.z+(endPos.z-midPoint.z)*(-0.25)};
			GLKVector3 P2 = {midPoint.x+(endPos.x-midPoint.x)*0.75, midPoint.y+(endPos.y-midPoint.y)*0.75, midPoint.z+(endPos.z-midPoint.z)*(0.75)};
			NezCubicBezier *bezier = [[NezCubicBezier alloc] initWithControlPointsP0:midPoint P1:P1 P2:P2 P3:endPos];
			NezCubicBezierAnimation *curveAni = [[NezCubicBezierAnimation alloc] initMat4WithFromData:letterBlock.modelMatrix ToData:curveMat Duration:duration*5.0 EasingFunction:easeOutCubic UpdateBlock:^(NezAnimation *anim) {
				NezCubicBezierAnimation *ani = (NezCubicBezierAnimation*)anim;
				float t = (ani->elapsedTime/ani->duration);
				GLKMatrix4 *mat = (GLKMatrix4*)ani->newData;
				GLKVector3 p = [ani.bezier positionAt:t];
				mat->m30 = p.x;
				mat->m31 = p.y;
				mat->m32 = p.z;
				letterBlock.modelMatrix = *mat;
			} DidStopBlock:^(NezAnimation *ani) {
				[stack finishPushLetterBlock:letterBlock];
				self.currentAnimatingCount--;
				if (self.currentAnimatingCount == 0) {
					[self startGame:nil];
				}
			}];
			curveAni.bezier = bezier;
			[NezAnimator addAnimation:curveAni];
		}];
		ani->delay = delay;

		[NezAnimator addAnimation:ani];
		
		delay += ani->duration*0.25;
	}
	[letterBlockList removeAllObjects];
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
	[self restackLetterBlocks];
//	[self.navigationController popViewControllerAnimated:NO];
}

-(void)restackLetterBlocks {
	NSArray *letterBlockList = [NezAletterationGameState getLetterBlockList];
	for (NezAletterationLetterBlock *letterBlock in letterBlockList) {
		NezAletterationLetterStack *stack = [NezAletterationGameState getLetterStackForLetter:letterBlock.letter];
		if (![stack containsLetterBlock:letterBlock]) {
			GLKVector3 endPos = [stack getNextLetterBlockPosition];
			GLKVector3 midPoint = [letterBlock getMidPoint];
			GLKMatrix4 curveMat = GLKMatrix4MakeTranslation(endPos.x, endPos.y, endPos.z);
			
			[stack deferredPushLetterBlock:letterBlock];
			
			GLKVector3 P1 = {midPoint.x+(endPos.x-midPoint.x)*0.25, midPoint.y+(endPos.y-midPoint.y)*0.25, 6.0};
			GLKVector3 P2 = {midPoint.x+(endPos.x-midPoint.x)*0.75, midPoint.y+(endPos.y-midPoint.y)*0.75, 6.0};
			NezCubicBezier *bezier = [[NezCubicBezier alloc] initWithControlPointsP0:midPoint P1:P1 P2:P2 P3:endPos];
			NezCubicBezierAnimation *curveAni = [[NezCubicBezierAnimation alloc] initMat4WithFromData:letterBlock.modelMatrix ToData:curveMat Duration:1.5 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *anim) {
				NezCubicBezierAnimation *ani = (NezCubicBezierAnimation*)anim;
				float t = (ani->elapsedTime/ani->duration);
				GLKMatrix4 *mat = (GLKMatrix4*)ani->newData;
				GLKVector3 p = [ani.bezier positionAt:t];
				mat->m30 = p.x;
				mat->m31 = p.y;
				mat->m32 = p.z;
				letterBlock.modelMatrix = *mat;
			} DidStopBlock:^(NezAnimation *ani) {
				[stack finishPushLetterBlock:letterBlock];
			}];
			curveAni.bezier = bezier;
			[NezAnimator addAnimation:curveAni];

			NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:letterBlock.mix ToData:0.0 Duration:1.0 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
				letterBlock.mix = ani->newData[0];
			} DidStopBlock:nil];
			[NezAnimator addAnimation:ani];
		}
	}
	NSArray *lineList = [NezAletterationGameState getDisplayLineList];
	NezAletterationDisplayLine *displayLine = lineList.lastObject;
	GLKVector4 color = displayLine.color1;
	NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:color.a ToData:0.0 Duration:1.0 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		GLKVector4 c = color;
		c.a = ani->newData[0];
		for (NezAletterationDisplayLine *displayLine in lineList) {
			displayLine.color1 = c;
		}
	} DidStopBlock:nil];
	[NezAnimator addAnimation:ani];
	
	for (NezAletterationLetterStack *stack in [NezAletterationGameState getLetterStacks]) {
		[stack fadeCounterTo:0.0 withStopBlock:nil];
	}
	
	NezAletterationBox *box = [NezAletterationGameState getBox];
	GLKVector3 boxSize = box.size;
	GLKMatrix4 boxMatrix = [NezAletterationGameState getOriginalBoxMatrix];
	GLKMatrix4 rot = GLKMatrix4MakeRotation(M_PI*0.2, 1.0, -1.0, -1.0);
	rot.m30 = boxMatrix.m30 + boxSize.z;
	rot.m31 = boxMatrix.m31 + boxSize.y*0.5;
	rot.m32 = boxMatrix.m32 + boxSize.z*2.0f;

	ani = [[NezAnimation alloc] initMat4WithFromData:box.modelMatrix ToData:rot Duration:1.0 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		GLKMatrix4 *mat = (GLKMatrix4*)ani->newData;
		box.modelMatrix = *mat;
	} DidStopBlock:^(NezAnimation *ani) {
	}];
	[NezAnimator addAnimation:ani];
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
