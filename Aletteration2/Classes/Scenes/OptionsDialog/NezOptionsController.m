//
//  NezOptionsPopoverController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-26.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezOptionsController.h"
#import "NezAletterationGameState.h"
#import "NezAppDelegate.h"
#import "NezViewController.h"
#import "NezPhotoPickerNavigationController.h"
#import "NezCropImageViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

@interface NezOptionsController ()

@property(nonatomic) NezAletterationPrefsObject *prefs;

@end

@implementation NezOptionsController

-(id)initWithCoder:(NSCoder *)aDecoder {
	if ((self=[super initWithCoder:aDecoder])) {
		self.prefs = [NezAletterationGameState getPreferences];
		_originalSize = CGSizeMake(480,300);
		self.contentSizeForViewInPopover = _originalSize;
		_rotating = NO;
	}
	return self;
}

//-(void)updateViewConstraints {
//	[super updateViewConstraints];
//}

-(void)setPhotoImageForPopover {
	CGFloat rotationAngle = GLKMathDegreesToRadians(5.0);
	CGAffineTransform rotateTransform = CGAffineTransformMakeScale(0.8, 0.8);
	rotateTransform = CGAffineTransformRotate(rotateTransform, rotationAngle);
	
	_photoPaperImageView.transform = rotateTransform;
	_portraitImageView.transform = rotateTransform;
}

-(void)setPhotoImageForLandscape {
	CGPoint center = self.portraitView.center;
	CGPoint cp = [self.view convertPoint:center fromView:self.portraitView];
	CGFloat rotationAngle = GLKMathDegreesToRadians(5.0);
	CGAffineTransform rotateTransform = CGAffineTransformMakeTranslation(cp.x-8, cp.y-18);
	rotateTransform = CGAffineTransformScale(rotateTransform, 0.8, 0.8);
	rotateTransform = CGAffineTransformRotate(rotateTransform, rotationAngle);
	
	_photoPaperImageView.transform = rotateTransform;
	_portraitImageView.transform = rotateTransform;
	
	_portraitViewWidthConstraint.constant = 60;
}

-(void)setPhotoImageForPortrait {
	CGSize size = self.view.frame.size;
	CGFloat rotationAngle = GLKMathDegreesToRadians(-5.0);
	CGAffineTransform rotateTransform = CGAffineTransformMakeTranslation(size.width/2.0, size.height*1.2);
	rotateTransform = CGAffineTransformScale(rotateTransform, 2.0, 2.0);
	rotateTransform = CGAffineTransformRotate(rotateTransform, rotationAngle);
	
	_photoPaperImageView.transform = rotateTransform;
	_portraitImageView.transform = rotateTransform;
	
	_portraitViewWidthConstraint.constant = 1;
}

-(void)setPhotoImage {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self setPhotoImageForPopover];
	} else {
		UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
		if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
			[self setPhotoImageForLandscape];
		} else {
			[self setPhotoImageForPortrait];
		}
	}
}

-(void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	if (_layoutFirstTime) {
		dispatch_async(dispatch_get_main_queue(), ^{
			_layoutFirstTime = NO;
			[self setPhotoImage];
		});
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.view setNeedsUpdateConstraints];
			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
				[self setPhotoImage];
				[self.view layoutIfNeeded];
			} completion:nil];
		});
	}
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[NezAppDelegate sharedAppDelegate].glkViewController.paused = NO;
}

-(void)hideKeyboard {
	if (self.nameTextField.isFirstResponder) {
		[self.nameTextField resignFirstResponder];
		self.optionsPopoverController.popoverContentSize = _originalSize;
	}
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self hideKeyboard];
	return NO;
}

-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController*)popoverController {
	if (self.nameTextField.isFirstResponder) {
		[self hideKeyboard];
		return NO;
	}
	return YES;
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	[self hideKeyboard];
}

-(IBAction)dismissKeyboard:(UITextField*)sender {
	[sender resignFirstResponder];
}

-(IBAction)colorSliderChanged:(id)sender {
	[self updateBlockColor];
}

-(void)soundVolumeChanged:(id)sender {
	[self updateSoundVolume];
}

-(void)musicVolumeChanged:(id)sender {
	[self updateMusicVolume];
}

-(void)soundSwitchChanged:(id)sender {
	[self updateSoundSwitch];
}

-(void)musicSwitchChanged:(id)sender {
	[self updateMusicSwitch];
}

-(void)viewDidLoad {
    [super viewDidLoad];
	
	_layoutFirstTime = YES;
	
	GLKVector4 color = self.prefs.blockColor;
	
	self.redSlider.value = color.r;
	self.greenSlider.value = color.g;
	self.blueSlider.value = color.b;
	[self updateBlockColor];
	
	self.soundSlider.value = self.prefs.soundVolume;
	[self updateSoundVolume];
	
	self.soundSwitch.on = self.prefs.soundEnabled;
	[self updateSoundSwitch];
	
	self.musicSlider.value = self.prefs.musicVolume;
	[self updateMusicVolume];
	
	self.musicSwitch.on = self.prefs.musicEnabled;
	[self updateMusicSwitch];
	
	self.nameTextField.text = self.prefs.playerName;

	UIView *superview = self.view;

	NSLayoutConstraint *cn;

	UIImage *paperImage = [UIImage imageNamed:@"GKPhotoFrameChallengeList"];
	CGSize photoPaperSize = paperImage.size;
	self.photoPaperImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,photoPaperSize.width,photoPaperSize.height)];
	_photoPaperImageView.backgroundColor = [UIColor clearColor];
	[_photoPaperImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[superview addSubview:_photoPaperImageView];
	
	cn = [NSLayoutConstraint constraintWithItem:_photoPaperImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:photoPaperSize.width];
	[_photoPaperImageView addConstraint:cn];
	
	cn = [NSLayoutConstraint constraintWithItem:_photoPaperImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:photoPaperSize.height];
	[_photoPaperImageView addConstraint:cn];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		cn = [NSLayoutConstraint constraintWithItem:_photoPaperImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.portraitView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
		[superview addConstraint:cn];
		
		cn = [NSLayoutConstraint constraintWithItem:_photoPaperImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.portraitView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
		[superview addConstraint:cn];
	} else {
		cn = [NSLayoutConstraint constraintWithItem:_photoPaperImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
		[superview addConstraint:cn];
		
		cn = [NSLayoutConstraint constraintWithItem:_photoPaperImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
		[superview addConstraint:cn];
	}
	_photoPaperImageView.image = paperImage;
	
	self.portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,1,1)];

	_portraitImageView.image = self.prefs.playerPortrait;
	
	UIImage *imageMask = [UIImage imageNamed:@"GKPhotoFrameChallengeListMask"];
	CALayer *layerMask = [CALayer layer];
	layerMask.contents = (id)[imageMask CGImage];
	layerMask.frame = CGRectMake(0, 0, photoPaperSize.width, photoPaperSize.height);
	self.portraitImageView.layer.mask = layerMask;

	_portraitImageView.backgroundColor = [UIColor clearColor];
	[_portraitImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[superview addSubview:_portraitImageView];
	
	cn = [NSLayoutConstraint constraintWithItem:_portraitImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:photoPaperSize.width];
	[_portraitImageView addConstraint:cn];
	
	cn = [NSLayoutConstraint constraintWithItem:_portraitImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:photoPaperSize.height];
	[_portraitImageView addConstraint:cn];
	
	cn = [NSLayoutConstraint constraintWithItem:_portraitImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_photoPaperImageView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
	[superview addConstraint:cn];
	
	cn = [NSLayoutConstraint constraintWithItem:_portraitImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_photoPaperImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
	[superview addConstraint:cn];
	
	[superview bringSubviewToFront:_photoPaperImageView];
}

-(void)viewDidDisappear:(BOOL)animated {
	[self savePreferences];
	[super viewDidDisappear:animated];
}

-(void)savePreferences {
	self.prefs.playerName = self.nameTextField.text;
	self.prefs.playerPortrait = self.portraitImageView.image;
	self.prefs.soundEnabled = self.soundSwitch.on;
	self.prefs.soundVolume = self.soundSlider.value;
	self.prefs.musicEnabled = self.musicSwitch.on;
	self.prefs.musicVolume = self.musicSlider.value;
	self.prefs.blockColor = GLKVector4Make(self.redSlider.value,self.greenSlider.value,self.blueSlider.value, 1.0f);

	[NezAletterationGameState setPreferences:self.prefs];
}

-(void)updateSoundSwitch {
	self.soundSlider.enabled = self.soundSwitch.on;
	self.soundVolumeImageView.alpha = self.soundSwitch.on?1.0:0.3;
	
	//	gameState.soundEnabled = self.soundSwitch.on;
}

-(void)updateMusicSwitch {
	self.musicSlider.enabled = self.musicSwitch.on;
	self.musicVolumeImageView.alpha = self.musicSwitch.on?1.0:0.3;
	//	gameState.musicEnabled = self.musicSwitch.on;
}

-(void)changeVolumeIcon:(UIImageView*)volumeIconView Volume:(float)vol {
	if (vol > 0.666) {
		volumeIconView.image = [UIImage imageNamed:@"vol3"];
	} else if (vol > 0.333) {
		volumeIconView.image = [UIImage imageNamed:@"vol2"];
	} else if (vol > 0) {
		volumeIconView.image = [UIImage imageNamed:@"vol1"];
	} else {
		volumeIconView.image = [UIImage imageNamed:@"vol0"];
	}
}

-(void)updateSoundVolume {
	[self changeVolumeIcon:self.soundVolumeImageView Volume:self.soundSlider.value];
	//	gameState.soundVolume = view.soundSlider.value;
}

-(void)updateMusicVolume {
	[self changeVolumeIcon:self.musicVolumeImageView Volume:self.musicSlider.value];
	//	gameState.musicVolume = view.musicSlider.value;
}

-(void)updateBlockColor {
	float r = self.redSlider.value;
	float g = self.greenSlider.value;
	float b = self.blueSlider.value;
	
	GLKVector4 color = GLKVector4Make(r, g, b, 1.0);
	[NezAletterationGameState setBlockColor:color];
	
	self.colorImageView.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
	
	float luma = [NezAletterationGameState getBrightnessWithRed:r Green:g Blue:b];
	if (luma > 0.5) {
		self.colorImageView.image = [UIImage imageNamed:@"a-black"];
	} else {
		self.colorImageView.image = [UIImage imageNamed:@"a-white"];
	}
}

-(void)showImagePicker:(NSString*)identifier {
	[NezAppDelegate sharedAppDelegate].glkViewController.paused = YES;
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ImagePicker" bundle:nil];
	NezPhotoPickerNavigationController *vc = [sb instantiateViewControllerWithIdentifier:identifier];
	vc.delegate = self;
	vc.modalPresentationStyle = UIModalPresentationFullScreen;
	[self presentViewController:vc animated:YES completion:NULL];
}

-(IBAction)pickImage:(id)sender {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
		[self showImagePicker:@"NezPhotoPicker"];
	}
}

-(IBAction)useCamera:(id)sender {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		picker.modalPresentationStyle = UIModalPresentationFullScreen;
		picker.allowsEditing = YES;
		picker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage, nil];
		picker.delegate = self;
		[self presentViewController:picker animated:YES completion:nil];
	}
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
	UIImage *img;
	if (!(img = [info valueForKey:UIImagePickerControllerEditedImage])) {
		img = [info valueForKey:UIImagePickerControllerOriginalImage];
	}
	if (img) {
		self.portraitImageView.image = img;
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
