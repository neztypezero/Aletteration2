//
//  NezCropImageViewController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-29.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezCropImageViewController.h"
#import "NezPhotoPickerNavigationController.h"
#import "NezCropRectView.h"
#import "NezUIBarLabelItem.h"
#import "NezAppDelegate.h"

@interface NezCropImageViewController ()

@end

@implementation NezCropImageViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
	if ((self=[super initWithCoder:aDecoder])) {
		_screenScale = [NezAppDelegate screenScale];
		_absoluteTranslation.x = 0;
		_absoluteTranslation.y = 0;
	}
	return self;
}

-(IBAction)cancelAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)chooseAction:(id)sender {
	[self cropImage];
}

//Creates a transform that will correctly rotate and translate for the passed orientation.
//Based on code from niftyBean.com
- (CGAffineTransform) transformSize:(CGSize)imageSize orientation:(UIImageOrientation)orientation {
	CGAffineTransform transform = CGAffineTransformIdentity;
	switch (orientation) {
		case UIImageOrientationLeft: { // EXIF #8
			CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,M_PI_2);
			transform = txCompound;
			break;
		}
		case UIImageOrientationDown: { // EXIF #3
			CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,M_PI);
			transform = txCompound;
			break;
		}
		case UIImageOrientationRight: { // EXIF #6
			CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,-M_PI_2);
			transform = txCompound;
			break;
		}
		case UIImageOrientationUp: // EXIF #1 - do nothing
		default: // EXIF 2,4,5,7 - ignore
			break;
	}
	return transform;
}

-(void)cropImage {
	CGSize imageSize = _assetImageView.image.size;
	CGFloat ix = (_absoluteTranslation.x/_screenScale);
	CGFloat iy = (_absoluteTranslation.y/_screenScale);
	CGFloat dw = (_absoluteScale*imageSize.width)/2.0;
	CGFloat dh = (_absoluteScale*imageSize.height)/2.0;
	CGFloat cw = _cropRectView.frame.size.width/2.0;
	CGFloat ch = _cropRectView.frame.size.height/2.0;

	CGFloat sx = dw-ix-cw;
	CGFloat sy = dh-iy-ch;
	
	CGFloat px = sx/(dw*2.0);
	CGFloat py = sy/(dh*2.0);
	CGFloat pw = (cw)/(dw);
	CGFloat ph = (ch)/(dh);
	
	ALAssetRepresentation *rep = [_asset defaultRepresentation];
	CGImageRef fullResolutionImageRef = [rep fullResolutionImage];
	UIImage *fullResolutionImage = [UIImage imageWithCGImage:fullResolutionImageRef scale:rep.scale orientation:rep.orientation];
	
	CGFloat iw = fullResolutionImage.size.width;
	CGFloat ih = fullResolutionImage.size.height;

	CGRect cropRect = {(int)(px*iw), (int)(py*ih), (int)(pw*iw), (int)(ph*ih)};
	if (cropRect.size.width > cropRect.size.height) {
		cropRect.size.width = cropRect.size.height;
	} else {
		cropRect.size.height = cropRect.size.width;
	}
	CGAffineTransform rectTransform = [self transformSize:fullResolutionImage.size orientation:fullResolutionImage.imageOrientation];
	CGRect transformedRect = CGRectApplyAffineTransform(cropRect, rectTransform);
	
	CGImageRef imageRef = CGImageCreateWithImageInRect([fullResolutionImage CGImage], transformedRect);
	UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:rep.scale orientation:rep.orientation];
	CGImageRelease(imageRef);
	croppedImage = [self createPhotoThumbnailImage:croppedImage Width:370 Height:415 LeftPadding:30 BottomPadding:80];
	
	NSDictionary *metaData = [rep metadata];
	if (metaData == nil) {
		metaData = [NSDictionary dictionary];
	}
	
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSValue valueWithCGRect:cropRect], UIImagePickerControllerCropRect,
						                        croppedImage, UIImagePickerControllerEditedImage,
						                            metaData, UIImagePickerControllerMediaMetadata,
			   [_asset valueForProperty:ALAssetPropertyType], UIImagePickerControllerMediaType,
										 fullResolutionImage, UIImagePickerControllerOriginalImage,
	 					                                 nil
	];
	
	NezPhotoPickerNavigationController *navController = (NezPhotoPickerNavigationController*)self.navigationController;
	[navController.delegate imagePickerController:nil didFinishPickingMediaWithInfo:info];
}

-(UIImage*)createPhotoThumbnailImage:(UIImage*)image Width:(float)width Height:(float)height LeftPadding:(float)leftPadding BottomPadding:(float)bottomPadding {
	// create context, keeping original image properties
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorspace, kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease(colorspace);
	
	if(context == NULL) {
		return nil;
	}
	float ratio = image.size.width/image.size.height;
	float x = leftPadding;
	float y = bottomPadding;
	float dw = width-leftPadding*2.0;
	float dh = dw/ratio;
	
	if (image.imageOrientation == UIImageOrientationRight) {//ok
    	CGContextRotateCTM (context, GLKMathDegreesToRadians(-90));
    	CGContextTranslateCTM (context, -dw, 0);
  } else if (image.imageOrientation == UIImageOrientationLeft) { //ok
    	CGContextRotateCTM (context, GLKMathDegreesToRadians(90));
    	CGContextTranslateCTM (context, 0, -dh);
    } else if (image.imageOrientation == UIImageOrientationDown) { //ok
    	CGContextRotateCTM (context, GLKMathDegreesToRadians(180));
    	CGContextTranslateCTM (context, -dw, -dh);
    } else if (image.imageOrientation == UIImageOrientationUp) {//ok
    	// NOTHING
    }

	// draw image to context (resizing it)
	CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	CGContextDrawImage(context, CGRectMake(x, y, dw, dh), image.CGImage);
	
	CGImageRef imgRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	UIImage *thumbnail = [UIImage imageWithCGImage:imgRef];
	CGImageRelease(imgRef);
	
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	[library writeImageToSavedPhotosAlbum:thumbnail.CGImage orientation:thumbnail.imageOrientation completionBlock:nil];
	
	return thumbnail;
}

-(void)setInitialTransform {
	_screenScale = [NezAppDelegate screenScale];

	CGSize imageDimensions = _assetImageView.image.size;
	CGSize cropDimensions = {_cropRectSizeConstraint.constant, _cropRectSizeConstraint.constant};
	
	float xScale = cropDimensions.width/imageDimensions.width;
	float yScale = cropDimensions.height/imageDimensions.height;
	
	if (xScale > yScale) {
		_absoluteScale = xScale;
	} else {
		_absoluteScale = yScale;
	}
	_minimumScale = _absoluteScale;
	_absoluteTranslation.x = 0;
	_absoluteTranslation.y = 0;
	_assetImageView.transform = CGAffineTransformMake(_absoluteScale, 0, 0, _absoluteScale, _absoluteTranslation.x, _absoluteTranslation.y);
}

-(void)addOutsideOfCropBox:(NSLayoutAttribute)attribute {
	UIView *superview = self.cropView;

	UIView *box = [[UIView alloc] init];
	box.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
	[box setTranslatesAutoresizingMaskIntoConstraints:NO];
	[superview addSubview:box];

	NSLayoutConstraint *cn;
	
	if (attribute == NSLayoutAttributeLeft) {
		cn = [NSLayoutConstraint constraintWithItem:box attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_cropRectView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:1];
		[superview addConstraint:cn];
	} else {
		cn = [NSLayoutConstraint constraintWithItem:box attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
		[superview addConstraint:cn];
	}
	if (attribute == NSLayoutAttributeRight) {
		cn = [NSLayoutConstraint constraintWithItem:box attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_cropRectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-1];
		[superview addConstraint:cn];
	} else {
		cn = [NSLayoutConstraint constraintWithItem:box attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
		[superview addConstraint:cn];
	}
	if (attribute == NSLayoutAttributeTop) {
		cn = [NSLayoutConstraint constraintWithItem:box attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_cropRectView attribute:NSLayoutAttributeTop multiplier:1.0 constant:1];
		[superview addConstraint:cn];
	} else {
		cn = [NSLayoutConstraint constraintWithItem:box attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
		[superview addConstraint:cn];
	}
	if (attribute == NSLayoutAttributeBottom) {
		cn = [NSLayoutConstraint constraintWithItem:box attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_cropRectView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-1];
		[superview addConstraint:cn];
	} else {
		cn = [NSLayoutConstraint constraintWithItem:box attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
		[superview addConstraint:cn];
	}
}

-(void)viewDidLoad {
	[super viewDidLoad];
	if (_assetImageView.image == nil) {
		_cropRectView = [[UIView alloc] init];
		_cropRectView.backgroundColor = [UIColor clearColor];
		[_cropRectView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self.cropView addSubview:_cropRectView];
		
		UIView *superview = self.cropView;
		
		NSLayoutConstraint *cn;

		_cropRectSizeConstraint = [NSLayoutConstraint constraintWithItem:_cropRectView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:1];
		[_cropRectView addConstraint:_cropRectSizeConstraint];

		cn = [NSLayoutConstraint constraintWithItem:_cropRectView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_cropRectView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
		[_cropRectView addConstraint:cn];

		cn = [NSLayoutConstraint constraintWithItem:_cropRectView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
		[superview addConstraint:cn];
		
		cn = [NSLayoutConstraint constraintWithItem:_cropRectView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
		[superview addConstraint:cn];
		
		[self addOutsideOfCropBox:NSLayoutAttributeLeft];
		[self addOutsideOfCropBox:NSLayoutAttributeRight];
		[self addOutsideOfCropBox:NSLayoutAttributeTop];
		[self addOutsideOfCropBox:NSLayoutAttributeBottom];
		
		[self.view bringSubviewToFront:self.bottomToolbar];

		[self setAssetImage:NO];
	}
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

-(void)viewDidLayoutSubviews {
	static BOOL inside = NO;
	if (!inside) {
		inside = YES;
		dispatch_async(dispatch_get_main_queue(), ^{
			UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
			float size;
			if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) {
				size = self.cropView.frame.size.width;
			} else {
				size = self.cropView.frame.size.height;
			}
			if (size != _cropRectSizeConstraint.constant) {
				_cropRectSizeConstraint.constant = size;
				[self.view setNeedsUpdateConstraints];
				[self.view layoutIfNeeded];
				[self setInitialTransform];
			}
			inside = NO;
		});
	}
}

-(void)setAsset:(ALAsset*)asset {
	_asset = asset;
}

-(void)setAssetImage:(BOOL)fullsize {
	if (_asset != nil && _assetImageView != nil) {
		ALAssetRepresentation *rep = [_asset defaultRepresentation];
		if (fullsize) {
			CGImageRef iref = [rep fullResolutionImage];
			if (iref) {
				_assetImageView.image = [UIImage imageWithCGImage:iref scale:1.0f orientation:(UIImageOrientation)rep.orientation];
			}
		} else {
			CGImageRef iref = [rep fullScreenImage];
			if (iref) {
				_assetImageView.image = [UIImage imageWithCGImage:iref];
			}
		}
	}
}

-(CGPoint)getSpringBackOffset {
	CGPoint offset = {0,0};

	CGSize imageSize = _assetImageView.image.size;
	CGFloat ix = (_absoluteTranslation.x/_screenScale);
	CGFloat iy = (_absoluteTranslation.y/_screenScale);
	CGFloat dw = (_absoluteScale*imageSize.width)/2.0;
	CGFloat dh = (_absoluteScale*imageSize.height)/2.0;
	CGFloat cw = _cropRectView.frame.size.width/2.0;
	CGFloat ch = _cropRectView.frame.size.height/2.0;

	if (ix-dw > -cw) {
		offset.x = (-cw-(ix-dw))*_screenScale;
	} else if (ix+dw < cw) {
		offset.x = (cw-(ix+dw))*_screenScale;
	}
	if (iy-dh > -ch) {
		offset.y = (-ch-(iy-dh))*_screenScale;
	} else if (iy+dh < ch) {
		offset.y = (ch-(iy+dh))*_screenScale;
	}
	return offset;
}

-(void)springBack {
	CGPoint offset =[self getSpringBackOffset];
	if (offset.x != 0 || offset.y != 0) {
		_absoluteTranslation.x += offset.x;
		_absoluteTranslation.y += offset.y;
		
		CGAffineTransform transform = CGAffineTransformMake(_absoluteScale, 0, 0, _absoluteScale, _absoluteTranslation.x, _absoluteTranslation.y);
		[UIView animateWithDuration:0.25 delay:0.01 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
			_assetImageView.transform = transform;
			[self.view layoutIfNeeded];
		} completion:nil];
	}
}

-(void)scaleBack:(CGFloat)scale {
	if (scale > _absoluteScale) {
		CGPoint scalingOffset = [self getScalingOffsetWithPrevScale:scale NextScale:_absoluteScale];
		_absoluteTranslation.x += scalingOffset.x;
		_absoluteTranslation.y += scalingOffset.y;
	} else {
		CGPoint offset =[self getSpringBackOffset];
		_absoluteTranslation.x = offset.x;
		_absoluteTranslation.y = offset.y;
	}
	CGAffineTransform transform = CGAffineTransformMake(_absoluteScale, 0, 0, _absoluteScale, _absoluteTranslation.x, _absoluteTranslation.y);

	[UIView animateWithDuration:0.15 delay:0.01 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
		_assetImageView.transform = transform;
		[self.view layoutIfNeeded];
	} completion:nil];
}

-(CGPoint)getScalingOffsetWithPrevScale:(CGFloat)prevScale NextScale:(CGFloat)nextScale {
	CGSize imageSize = _assetImageView.image.size;
	CGFloat dw1 = (prevScale*imageSize.width)/2.0;
	CGFloat dh1 = (prevScale*imageSize.height)/2.0;
	CGFloat dw2 = (nextScale*imageSize.width)/2.0;
	CGFloat dh2 = (nextScale*imageSize.height)/2.0;
	CGFloat cx1 = (dw1+_absoluteTranslation.x)/prevScale;
	CGFloat cy1 = (dh1+_absoluteTranslation.y)/prevScale;
	CGFloat cx2 = (dw2+_absoluteTranslation.x)/nextScale;
	CGFloat cy2 = (dh2+_absoluteTranslation.y)/nextScale;
	CGFloat dcx = ((cx1-cx2)*nextScale);
	CGFloat dcy = ((cy1-cy2)*nextScale);
	CGPoint scalingOffset = {dcx,dcy};
	return scalingOffset;
}

-(IBAction)panGestureMoveAround:(UIPanGestureRecognizer *)gestureRecognizer {
	CGPoint translation = [gestureRecognizer translationInView:self.view];
	if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) {
		CGFloat tx = _absoluteTranslation.x+(translation.x*_screenScale);
		CGFloat ty = _absoluteTranslation.y+(translation.y*_screenScale);
		_assetImageView.transform = CGAffineTransformMake(_absoluteScale, 0, 0, _absoluteScale, tx, ty);
	} else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		_absoluteTranslation.x += translation.x*_screenScale;
		_absoluteTranslation.y += translation.y*_screenScale;
		[self springBack];
	}
}

-(IBAction)pinchGestureMoveAround:(UIPinchGestureRecognizer *)gestureRecognizer {
	float scale = _absoluteScale*gestureRecognizer.scale;
	CGPoint scalingOffset = [self getScalingOffsetWithPrevScale:_absoluteScale NextScale:scale];
	
	_assetImageView.transform = CGAffineTransformMake(scale, 0, 0, scale, _absoluteTranslation.x+scalingOffset.x, _absoluteTranslation.y+scalingOffset.y);

	if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled || gestureRecognizer.state == UIGestureRecognizerStateFailed) {
		_absoluteTranslation.x += scalingOffset.x;
		_absoluteTranslation.y += scalingOffset.y;
		if (scale > 4.0) {
			_absoluteScale = 4.0;
			[self scaleBack:scale];
		} else if (scale < _minimumScale) {
			_absoluteScale = _minimumScale;
			[self scaleBack:scale];
		} else {
			_absoluteScale = scale;
			[self springBack];
		}
	}
}

@end
