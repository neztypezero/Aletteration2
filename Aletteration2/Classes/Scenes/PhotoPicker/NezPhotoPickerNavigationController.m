//
//  NezPhotoPickerNavigationController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-31.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezPhotoPickerNavigationController.h"

@interface NezPhotoPickerNavigationController ()

@end

@implementation NezPhotoPickerNavigationController

-(void)imagePicked:(NSDictionary*)info {
	if (self.delegate) {
		[self.delegate imagePickerController:nil didFinishPickingMediaWithInfo:info];
	}
}

-(void)cancel {
	if (self.delegate) {
		[self.delegate imagePickerControllerDidCancel:nil];
	}
}

@end
