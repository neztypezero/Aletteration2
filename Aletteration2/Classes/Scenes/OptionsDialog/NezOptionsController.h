//
//  NezOptionsPopoverController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-26.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NezEmbededDialogController.h"

@interface NezOptionsController : NezEmbededDialogController<UIPopoverControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
	CGSize _originalSize;
	BOOL _layoutFirstTime;
	BOOL _rotating;
}

@property (nonatomic, weak) IBOutlet UISlider *redSlider;
@property (nonatomic, weak) IBOutlet UISlider *greenSlider;
@property (nonatomic, weak) IBOutlet UISlider *blueSlider;
@property (nonatomic, weak) IBOutlet UIImageView *colorImageView;
@property (nonatomic, weak) IBOutlet UISwitch *musicSwitch;
@property (nonatomic, weak) IBOutlet UISlider *musicSlider;
@property (nonatomic, weak) IBOutlet UIImageView *musicVolumeImageView;
@property (nonatomic, weak) IBOutlet UISwitch *soundSwitch;
@property (nonatomic, weak) IBOutlet UISlider *soundSlider;
@property (nonatomic, weak) IBOutlet UIImageView *soundVolumeImageView;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UIView *portraitView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *portraitViewWidthConstraint;

@property (nonatomic, strong) UIImageView *photoPaperImageView;
@property (nonatomic, strong) UIImageView *portraitImageView;

-(IBAction)dismissKeyboard:(UITextField*)sender;

-(IBAction)colorSliderChanged:(id)sender;
-(IBAction)soundVolumeChanged:(id)sender;
-(IBAction)musicVolumeChanged:(id)sender;
-(IBAction)soundSwitchChanged:(id)sender;
-(IBAction)musicSwitchChanged:(id)sender;

-(IBAction)useCamera:(id)sender;
-(IBAction)pickImage:(id)sender;

@property(nonatomic, weak) UIPopoverController *optionsPopoverController;

@end
