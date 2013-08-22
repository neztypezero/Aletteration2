//
//  NezPhotoPickerNavigationController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-31.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NezPhotoPicker.h"

@class NezPhotoPickerNavigationController;

typedef void (^NezPhotoPickerBlock)(NezPhotoPickerNavigationController *pickerController, UIImage *img);

@interface NezPhotoPickerNavigationController : UINavigationController

@property(nonatomic, weak) id<UINavigationControllerDelegate,UIImagePickerControllerDelegate> delegate;

-(void)imagePicked:(NSDictionary*)info;
-(void)cancel;

@end
