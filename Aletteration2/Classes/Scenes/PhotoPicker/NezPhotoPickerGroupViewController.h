//
//  NezPhotoPickerTableViewController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-29.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NezPhotoPicker.h"

@interface NezPhotoPickerGroupViewController : UITableViewController {
	NezPhotoPicker *_photoPicker;
	UIView *_overlayView;
}

@end
