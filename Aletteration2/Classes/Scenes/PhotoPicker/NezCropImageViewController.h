//
//  NezCropImageViewController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-29.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NezPhotoPicker.h"

@interface NezCropImageViewController : UIViewController {
	float _absoluteScale;
	float _minimumScale;
	CGPoint _absoluteTranslation;
	UIView *_cropRectView;
	CGFloat _screenScale;
	NSLayoutConstraint *_cropRectSizeConstraint;
}

@property(nonatomic,weak) IBOutlet UIView *cropView;
@property(nonatomic,weak) IBOutlet UIImageView *assetImageView;
@property(nonatomic,weak) IBOutlet UIToolbar *bottomToolbar;

@property(nonatomic,weak,setter=setAsset:) ALAsset *asset;

-(IBAction)cancelAction:(id)sender;
-(IBAction)chooseAction:(id)sender;

-(IBAction)panGestureMoveAround:(UIPanGestureRecognizer *)gesture;
-(IBAction)pinchGestureMoveAround:(UIPinchGestureRecognizer *)gestureRecognizer;

@end
